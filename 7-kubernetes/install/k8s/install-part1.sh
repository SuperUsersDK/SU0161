#!/bin/bash

# stop script on any failure
set -e

echo "[+] Install part 1 begin"
# must run as root
[ "$UID" -ne 0 ] && echo "This script must run as root" && exit 1

echo "[+] Disable swap"
set +e
swapoff /dev/dm-1
set -e
sed -i '/swap/s/^/#/' /etc/fstab
echo

echo "[+] Disable SELinux"
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
echo

echo "[+] Disable firewalld. Enable iptables"
/bin/systemctl disable firewalld
/bin/systemctl stop firewalld
/sbin/modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 'net.bridge.bridge-nf-call-iptables = 1' > /etc/sysctl.d/99-nf-call-iptables.conf
echo

echo "[+] Flush iptables"
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
echo

echo "[+] Setup kubernetes repo"
cat <<EOT > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOT
echo

echo "[+] Install kubectl, kubeadm, docker and etcd"
yum install -y kubectl kubeadm docker etcd
echo 

echo "[+] Enable and start docker and kubelet"
systemctl enable docker.service kubelet.service
systemctl start docker.service kubelet.service
echo

echo "[+] Bash tab completions"
yum install -y bash-completion
kubectl completion bash > /etc/bash_completion.d/kubectl

echo "[+] Add hostname/ip to /etc/hosts"
cat <<EOT >> /etc/hosts
10.0.0.10 kubemanager
10.0.0.20 kubenode1
10.0.0.30 kubenode2
EOT
echo

echo "[+] Install part 1 finished"
