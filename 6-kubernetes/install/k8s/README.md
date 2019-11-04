# Kubernetes install guide til CentOS 7

1. Swap skal disables på manager(s) og workers:
```bash
swapoff /dev/dm-1
sed -i '/swap/s/^/#/' /etc/fstab
```

2. Desværre så skal SELinux disables:
```bash
# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

3. Firewalld skal disables og iptables enables på manager(s) og workers:
```bash
modprobe br_netfilter # might be br_filter on your linux
systemctl disable firewalld
systemctl stop firewalld
echo '1' | tee /proc/sys/net/bridge/bridge-nf-call-{iptables,ip6tables,arptables}
echo 'net.bridge.bridge-nf-call-iptables = 1' > /etc/sysctl.d/99-nf-call-iptables.conf
echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.d/99-nf-call-iptables.conf
echo 'net.bridge.bridge-nf-call-arptables = 1' >> /etc/sysctl.d/99-nf-call-iptables.conf
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
```

4. På manager(s) og workers skal repo tilføjes og software installeres:
```bash
cat <<EOT > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOT
yum install -y kubectl kubeadm docker etcd
```

5. På manager(s) og workers skal docker+kubelet OS-service enables og startes:
```bash
systemctl enable docker.service kubelet.service
systemctl start docker.service kubelet.service
```

6. På manager(s) og workers er det rart med bash tab-completions:
```bash
yum install -y bash-completion
kubectl completion bash >/etc/bash_completion.d/kubectl
```

7. Og tilføje hostname/ip'er til host-filen (eller i DNS)
```bash
cat <<EOT >> /etc/hosts
10.0.0.10 manager
10.0.0.20 worker1
10.0.0.30 worker2
```

8. Shutdown manager and workers. Do a snapshot in Virtual Box and call it "After Initialize"

9. På manager:
```bash
kubeadm init --pod-network-cidr=10.0.1.0/24 --apiserver-advertise-address=10.0.0.10 # erstat 10.0.0.10 med managers ip. Tager lang tid
```

10. Run the command that is printed on the screen on the nodes to get them to join the cluster.
The command have the following form:
```bash
kubeadm join <manager-ip:port> --token <token> --discovery-token-ca-cert-hash <hash>
```

11. På manageren resten køres som en alm. bruger med sudo-rettigheder:
```bash
  su - bruger
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

12. Der skal vælges en network provider fra listen på https://kubernetes.io/docs/concepts/cluster-administration/addons/ \\
Her vælges Calico:
```bash
kubectl apply -f https://docs.projectcalico.org/v3.10/manifests/calico.yaml
```


13. Og installeres Kube Dashboard. Bagefter forbinde på adressen: \\
http://<manager-exteral-ip>:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl proxy
```

14. Do only this if the nodes is not joined!

```bash
kubeadm token create --print-join-command
```

og brug outputtet på workers:
```bash
kubeadm join <manager-ip:port> --token <token> --discovery-token-ca-cert-hash <hash>
```

15. Og test tilsidst på manager med:
```bash
kubectl get nodes
kubectl apply -f https://k8s.io/examples/service/access/hello-application.yaml
```

16. Observe the deployment using the following commands:

```bash
kubectl get deployments
kubectl get pods
```



