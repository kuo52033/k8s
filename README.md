k8s
===

### Tool
* Multipass

### Step 1 : Generate VM
```
multipass launch --name master --cpus 2 --memory 8G --disk 10G
```
### Step 2 : Disable swap
```
sudo swapoff -a
# Check swap status
cat /proc/swaps 
```
### Step 3 : Check required post is not used
```
# Connection refused
nc -v 127.0.0.1 6443
```
### Step 4 : Install some tool
```
sudo apt update
sudo apt-get install -y nano jq net-tools
```
### Step 4 : Set hostname and update mapping host file
```
sudo hostnamectl set-hostname k8s-master1.local
sudo nano /etc/hosts
192.168.*.* k8s-master1.local master
```
### Step 5 : Enable and Load Kernel modules
```
sudo tee /etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
```
### Step 6 : Add k8s settings and reload
```
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system
```
### Step 7 : Install container runtime
```
sudo apt install -y apt-transport-https ca-certificates curl gpg
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list 
sudo apt update >/dev/null 2>&1
sudo apt install -y containerd.io > /dev/null 2>&1
sudo containerd config default |sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd >/dev/null 2>&1
```
### Step 8 : Install k8s dependencies
```
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt list -a kubeadm
sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

## Control Plane
### Init
```
 sudo kubeadm init --apiserver-advertise-address=<your control plane IP>  --pod-network-cidr=<pod network IP base on CNI>
```
### Configure .kube
```
mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
### Get node/pod status
```
kubectl get node
kubectl get pod -A
```
### Install [CNI](https://kubernetes.io/docs/concepts/cluster-administration/addons/) (Use flannel)
```
sudo curl -LO https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
sudo nano kube-flannel.yml
```
#### Make sure podCiDR is same as <--pod-network-cidr >
```
net-conf.json: |
  {
    "Network": "10.10.0.0/16",
    "Backend": {
      "Type": "vxlan"
    }
  }
```
#### Add kube-flannel args "iface=<--apiserver-advertise-address>"
```
- name: kube-flannel
  image: docker.io/flannel/flannel:v0.24.2
  command:
  - /opt/bin/flanneld
  args:
  - --ip-masq
  - --kube-subnet-mgr
  - --iface=enp0s1
```
### Create join Token
```
kubeadm token create --print-join-command
```


