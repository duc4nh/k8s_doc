# Install Kubeadm và kubenetes cluster trên linux.


## Preinstall

- Ubuntu/Centos installed

> Trước khi setup kubernetes ở các node, cần setup trước 1 số thành phần: kubeadm, kubelet, docker, kubenetes-cni.

> Hiện tại kubeadm mới support network với plugin `CNI (Container network interface)` của kubernetes, chưa support plugin `kubenet` để làm virtual network trong local các node.

- ***Ubuntu:***
```
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
# Install docker if you don't have it already.
apt-get install -y docker-engine
apt-get install -y kubelet kubeadm kubectl kubernetes-cni
```

- ***CentOS:***
```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y docker kubelet kubeadm kubectl kubernetes-cni
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet
```

## Install

- Trên node master
```
kubeadm init --pod-network-cidr=10.244.0.0/16 --token=...
```

- Output master node:
```
[kubeadm] WARNING: kubeadm is in beta, please do not use it for production clusters.
[init] Using Kubernetes version: v1.6.0
[init] Using Authorization mode: RBAC
[preflight] Running pre-flight checks
[preflight] Starting the kubelet service
[certificates] Generated CA certificate and key.
[certificates] Generated API server certificate and key.
[certificates] API Server serving cert is signed for DNS names [kubeadm-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 10.138.0.4]
[certificates] Generated API server kubelet client certificate and key.
[certificates] Generated service account token signing key and public key.
[certificates] Generated front-proxy CA certificate and key.
[certificates] Generated front-proxy client certificate and key.
[certificates] Valid certificates and keys now exist in "/etc/kubernetes/pki"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/admin.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/controller-manager.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/scheduler.conf"
[apiclient] Created API client, waiting for the control plane to become ready
[apiclient] All control plane components are healthy after 16.772251 seconds
[apiclient] Waiting for at least one node to register and become ready
[apiclient] First node is ready after 5.002536 seconds
[apiclient] Test deployment succeeded
[token] Using token: <token>
[apiconfig] Created RBAC rules
[addons] Created essential addon: kube-proxy
[addons] Created essential addon: kube-dns

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run (as a regular user):

  sudo cp /etc/kubernetes/admin.conf $HOME/
  sudo chown $(id -u):$(id -g) $HOME/admin.conf
  export KUBECONFIG=$HOME/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  http://kubernetes.io/docs/admin/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join --token <token> <master-ip>:<master-port>
```

- Minion node:
```
~ kubeadm join --token <token> <master-ip>:<master-port>
```

## Setup kubectl

- Sau khi install xong kubenetes cluster bằng kubeadm, có thể access kiểm tra cụm cluster = kubectl
```
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf
```

hoặc 
```
$ mkdir -p $HOME/.kube
$ sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- Sau khi đã cài xong, có thể check lại cụm kubernetes vừa được khởi tạo 
```
$ kubectl get nodes
$ kubectl get pods
$ kubectl cluster-info
```

- Kube-proxy sẽ cần mod network trên kubernetes được enables, do đó buộc phải cài đặt các mod network cho kubernetes để start full các pods requirements, nếu không các nodes sẽ luôn trong trạng thái `NotReady`

## Setup flannel network

- kubernetes 1.6 sử dụng RBAC để authen, do đó cần tạo clusterRoles trước khi install flannel pods theo cách thông thường
```
kubectl create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml
kubectl create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

- Chờ flannel pods và DNS pods start, sẽ thấy list pods của cluster như sau:
```
kube-system   etcd-kubernetes-master                        1/1       Running   0          8d
kube-system   heapster-2315332064-d1tm3                     1/1       Running   0          8d
kube-system   kube-apiserver-kubernetes-master              1/1       Running   0          8d
kube-system   kube-controller-manager-kubernetes-master     1/1       Running   0          8d
kube-system   kube-dns-3913472980-s6sgt                     3/3       Running   0          8d
kube-system   kube-flannel-ds-dmnxb                         2/2       Running   1          6d
kube-system   kube-flannel-ds-vhn5k                         2/2       Running   0          8d
kube-system   kube-flannel-ds-w4h74                         2/2       Running   0          8d
kube-system   kube-proxy-mm77k                              1/1       Running   0          6d
kube-system   kube-proxy-n9kck                              1/1       Running   0          8d
kube-system   kube-proxy-tnmqx                              1/1       Running   0          8d
kube-system   kube-scheduler-kubernetes-master              1/1       Running   0          8d
```