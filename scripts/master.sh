
#!/bin/bash
#
# Setup for Control Plane (Master) servers

#set -euxo pipefail

# If you need public access to API server using the servers Public IP adress, change PUBLIC_IP_ACCESS to true.

PUBLIC_IP_ACCESS="false"
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"
SERVICE_CIDR="192.168.0.0/18"
CALICO_VERSION="v3.29.2"
CRI_SOCKET="unix:///var/run/containerd/containerd.sock"
# Pull required images

sudo kubeadm config images pull

# Initialize kubeadm based on PUBLIC_IP_ACCESS
MASTER_IP=""

if [ "$PUBLIC_IP_ACCESS" = "false" ]; then

    MASTER_PRIVATE_IP=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
    $MASTER_IP=$MASTER_PRIVATE_IP

elif [ "$PUBLIC_IP_ACCESS" == "true" 

]; then

    MASTER_PUBLIC_IP=$(curl ifconfig.me && echo "")
    $MASTER_IP=$MASTER_PUBLIC_IP

else
    echo "Error: MASTER_PUBLIC_IP has an invalid value: $PUBLIC_IP_ACCESS"
    exit 1
fi

sudo kubeadm init --cri-socket=$CRI_SOCKET \
                  --apiserver-advertise-address="$MASTER_IP" \
                  --apiserver-cert-extra-sans="$MASTER_IP" \
                  --pod-network-cidr="$POD_CIDR" \
                  --service-cidr="$SERVICE_CIDR" \
                  --node-name "$NODENAME" \
                  --ignore-preflight-errors Swap \


# Configure kubeconfig

mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config

# Install Calico Network Plugin Network 

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/tigera-operator.yaml
curl "https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/custom-resources.yaml" -O
kubectl create -f custom-resources.yaml


# create the join command
echo "sudo $(kubeadm token create --print-join-command) --cri-socket=$CRI_SOCKET"  > join.sh


# download and apply the metrics server
kubectl apply -f https://raw.githubusercontent.com/techiescamp/kubeadm-scripts/main/manifests/metrics-server.yaml


# watch the pods in the kube-system namespace
kubectl get pods -n kube-system