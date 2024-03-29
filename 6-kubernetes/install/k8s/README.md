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

3. Der skal tilføjes til host-filen på alle tre maskiner:
```bash
cat <<EOT >>/etc/hosts
10.0.0.10 manager1
10.0.0.20 worker1
10.0.0.30 worker2
EOT
```

4. Firewalld skal disables og iptables enables på manager(s) og workers:
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

5. På manager(s) og workers skal repo tilføjes og software installeres:
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

6. På manager(s) og workers skal docker+kubelet OS-service enables og startes:
```bash
systemctl enable docker.service kubelet.service
systemctl start docker.service kubelet.service
```

7. På manager(s) og workers er det rart med bash tab-completions:
```bash
yum install -y bash-completion
kubectl completion bash >/etc/bash_completion.d/kubectl
```

8. På manager:
```bash
kubeadm init --pod-network-cidr=10.0.1.0/24 --apiserver-advertise-address=10.0.0.10 # erstat 10.0.0.10 med managers ip. Tager lang tid
```

9. Reboot alle maskiner
```bash
reboot
```

10. Kør på de to workere, så de kan blive en del af clusteret:
```bash
kubeadm join <manager-ip:port> --token <token> --discovery-token-ca-cert-hash <hash>
```

11. På manageren resten køres som en alm. bruger med sudo-rettigheder:
```bash
  usermod -aG wheel bruger
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

13. Hvis noderne ikke er joinet endu, så kør på manageren:
```bash
kubeadm token create --print-join-command
```

og brug outputtet på workers:
```bash
kubeadm join <manager-ip:port> --token <token> --discovery-token-ca-cert-hash <hash>
```

14. Og test tilsidst på manager med:
```bash
kubectl get nodes
kubectl apply -f https://k8s.io/examples/service/access/hello-application.yaml
```

15. Og se alt er ok med kommandoerne:
```bash
kubectl get deployments
kubectl get pods
```
