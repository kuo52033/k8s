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
### Step 4 : Install Docker
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Check status
sudo docker info
```
### Step 5 : Check docker cgroup driver is systemd (same as k8s)
```
sudo docker info | grep Cgroup
```
### Step 6 : Install [cri-dockerd](https://github.com/Mirantis/cri-dockerd)
```
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.12/cri-dockerd_0.3.12.3-0.ubuntu-jammy_amd64.deb
sudo dpkg -i cri-dockerd_0.3.12.3-0.ubuntu-jammy_amd64.deb.1

# Reload service
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket

# Check service status
sudo systemctl status cri-docker.socket
```
### Step 7 : Install k8s packages
```
sudo apt-get install -y apt-transport-https gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install kubelet kubeadm kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

