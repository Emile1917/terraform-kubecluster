#!/bin/bash
#
# Common setup for all servers (Control Plane and Nodes)

#set -euxo pipefail


sudo apt update -y && sudo apt upgrade -y 
# Kubernetes Variable Declaration
KUBERNETES_VERSION="v1.30"
CRIO_VERSION="v1.30"
KUBERNETES_INSTALL_VERSION="1.30.0-1.1"
DNS_SERVERS=8.8.8.8,1.1.1.1

# DNS Setting
if [ ! -d /etc/systemd/resolved.conf.d ]; then
	sudo mkdir /etc/systemd/resolved.conf.d/
fi
cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
DNS="$DNS_SERVERS"
EOF



# Disable swap
sudo swapoff -a

# Keeps the swap off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
sudo apt-get update -y

# Create the .conf file to load the modules at bootup
sudo cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Sysctl params required by setup, params persist across reboots
sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Install CRI-O Runtime
sudo apt-get update -y
sudo apt-get install -y software-properties-common curl apt-transport-https ca-certificates

sudo curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
sudo  gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

sudo echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
sudo  tee /etc/apt/sources.list.d/cri-o.list

sudo apt-get update -y
sudo apt-get install -y cri-o

sudo systemctl daemon-reload
sudo systemctl enable crio --now
sudo systemctl start crio.service

sudo echo "CRI runtime installed successfully"

sudo  systemctl stop crio
#Install containerd
sudo apt install containerd -y

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Install kubelet, kubectl, and kubeadm
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key |
sudo  gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" |
sudo  tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt-get install -y kubelet="$KUBERNETES_INSTALL_VERSION" kubectl="$KUBERNETES_INSTALL_VERSION" kubeadm="$KUBERNETES_INSTALL_VERSION"

# Prevent automatic updates for kubelet, kubeadm, and kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo apt-get update -y

# Install jq, a command-line JSON processor
sudo apt-get install -y jq

# Retrieve the local IP address of the eth0 interface and set it for kubelet
local_ip="$(ip --json addr show eth0 | jq -r '.[0].addr_info[] | select(.family == "inet") | .local')"

# Write the local IP address to the kubelet default configuration file
sudo cat <<EOF | sudo tee /etc/default/kubelet 
KUBELET_EXTRA_ARGS=--node-ip=$local_ip
EOF

