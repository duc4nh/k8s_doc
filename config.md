# Yêu cầu trước khi cài dặt
- OS : CentOS 7
- Version : kuberenetes 1.5
- Tắt iptables và selinux
- 1 server master và 2 server worker
- Cấu hình sẽ dược thực hiên qua ip, nếu cấu hình qua hostname cần cài đặt và cấu hình dns cho các node.
- Các thành phần sẽ dược cài đặt
    + kuber-apiserver
    + kube-controller-manager
    + kube-scheduler
    + kube-proxy
    + kubelet
    + docker
    + Flannel 
    + etcd
+ Guide sẽ cấu hình 
    + 1 master ip 10.3.105.202
    + 2 worker ip 10.3.105.203 và 10.3.105.204

# Cài đặt 

## Tạo repo kubernetes
Thực hiện trên tất cả các node

Them mới file /etc/yum.repos.d/virt7-docker-common-release.repo

```
[virt7-docker-common-release]
name=virt7-docker-common-release
baseurl=http://cbs.centos.org/repos/virt7-docker-common-release/x86_64/os/
gpgcheck=0
```

## Cài đặt package
Thực hiện trên tất cả các node
```
yum -y install --enablerepo=virt7-docker-common-release kubernetes etcd flannel
```
Các package được cài đặt đầy đủ trên các node, để node đó là master hay worker node chỉ cần start các service tương ứng của node.


## Cấu hình kubenetes config
Thực hiện trên tất cả các node.

Edit file /etc/kubernetes/config

```
KUBE_LOGTOSTDERR="--logtostderr=true"

# journal message level, 0 is debug
KUBE_LOG_LEVEL="--v=0"

# Should this cluster be allowed to run privileged docker containers
KUBE_ALLOW_PRIV="--allow-privileged=false"

# How the controller-manager, scheduler, and proxy find the apiserver
KUBE_MASTER="--master=http://10.3.105.202:8080"
```

## Cấu hình master node

### Cấu hình etcd trên master node
Thực hiện trên master node

Edit file  /etc/etcd/etcd.conf

```
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
[cluster]
ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"
```
Etcd sẽ listen trên tất cả các NIC.

### Cấu hình apiserver
Thực hiện trên master node

Edit file /etc/kubernetes/apiserver

```
# The address on the local server to listen to.
KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"

# The port on the local server to listen on.
KUBE_API_PORT="--port=8080"

# Port minions listen on
KUBELET_PORT="--kubelet-port=10250"

# Comma separated list of nodes in the etcd cluster
KUBE_ETCD_SERVERS="--etcd-servers=http://10.3.105.202:2379"

# Address range to use for services
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.254.0.0/16"

# default admission control policies
KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota"

# Add your own!
KUBE_API_ARGS=""
```

- Kube api sẽ bind vào tất cả các NIC
- API port là 8080
- Kube connnect tới etcd ở ip và port http://10.3.105.202:2379
- Các service trong kubernetes sẽ có ip range : 10.254.0.0/16
- Admission control : các plugin được sử dụng trong kubernetes

### Start and config etcd
Thực hiện trên master node.

Thực hiện các command.

```
systemctl start etcd
etcdctl mkdir /kube-centos/network
etcdctl mk /kube-centos/network/config "{ \"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"
```
- Start etcd
- Tạo network config 172.30.0.0/16 và subnet 24 dạng vxlan

### Cấu hình flannel overlay docker network.
Thực hiện trên tất cả các node

Edit file /etc/sysconfig/flanneld

```
# etcd url location.  Point this to the server where etcd runs
FLANNEL_ETCD_ENDPOINTS="http://10.3.105.202:2379"

# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_PREFIX="/kube-centos/network"

# Any additional options that you want to pass
#FLANNEL_OPTIONS=""
```

- Cấu hình flannel trỏ đến etcd và config key network.
- Flannel dựa vào config của etcd để tạo network

### Start các service trong master node
Thực hiện trên master node

Thực hiện command.

```
for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler flanneld; do systemctl restart $SERVICES; systemctl enable $SERVICES;    systemctl status $SERVICES;done
```
Nếu có process nào không start lên dược, view log bằng command
```
journalctl -u <Ten process>
```

## Cấu hình worker node

### Cấu hình kubelet
Edit file /etc/kubernetes/kubelet

```
# The address for the info server to serve on (set to 0.0.0.0 or "" for all interfaces)
KUBELET_ADDRESS="--address=0.0.0.0"

# The port for the info server to serve on
# KUBELET_PORT="--port=10250"

# You may leave this blank to use the actual hostname
KUBELET_HOSTNAME="--hostname-override=10.3.105.203"

# location of the api-server
KUBELET_API_SERVER="--api-servers=http://10.3.105.202:8080"

# pod infrastructure container
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest"

# Add your own!
KUBELET_ARGS=""
```

- Cấu hình kubelet listen trên tất cả các NIC
- Cấu hình port kubelet 10250
- Cấu hình kubelet hostname là tên của node khi dùng lệnh kubectl get nodes. Ở đây dùng ip vì không có dns.
- Cấu hình trỏ đến api master.

### Start service kublet

```
for SERVICES in kube-proxy kubelet flanneld docker; do systemctl restart $SERVICES; systemctl enable $SERVICES; systemctl status $SERVICES;done
```
- Kiểm tra lại các process bằng command systemctl status $tenprocess
- Đến bước này khi login vào node master gõ lệnh sau, tráng thái của các worker node phải là ready

```
[root@hoannv-k8s-master kubernetes]# kubectl get nodes
NAME           STATUS    AGE
10.3.105.203   Ready     7d
10.3.105.204   Ready     7d
```


## Token cho  service-account của kubernetes

### Link tham khảo
```
https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
https://kubernetes.io/docs/admin/service-accounts-admin/
```

### ServiceAccount và token
- Service account cung cấp Identity cho process run trong pod, việc xác thực sẽ chuyển xuống apiserver.
- Nhiều Pod yêu cầu phải service account vì vậy cần phải có token cho serviceaccount.
- Nếu Service account không được set, kubernetes sẽ set ServiceAccount là "default"
- Khi service account token được add vào trong pod sẽ có sepc token dạng như sau:
```
volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-8rbj6
      readOnly: true

```
- Token controller trong controller-manager của kubernetes quản lý việc thêm, sửa, xóa, add token vào trong Pod. => Phải cấu hình token controller trong controller-manager và apiserver.
- Đẻ tạo token cần phải cấu hình service account private key file trong controller-manager sử dụng options: --service-account-private-key-file và cấu hình public key cho kube-apiserver sử dụng tham số --service-account-key-file.

### Cấu hình service account token
Để tạo được public key và private kubernetes có sẵn script đê generate.

```
wget https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.5.4/cluster/saltbase/salt/generate-cert/make-ca-cert.sh
```

Edit file make-ca-cert.sh
```
Thay đổi variable cert_group từ kube-cert thành kube. Nếu không đổi sẽ bị vướng permission khi generate ra key
```

Run file make-ca-cert.sh với các tham số
```
bash make-ca-cert.sh "<ip-master>" "IP:<ip-master>,IP:<ip-kubernetes-service>,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local"

<ip-kubernetes-service> lấy trong tham số KUBE_SERVICE_ADDRESSES của apiserver.
DNS:kubernetes.default.svc.cluster.local : lúc cấu hình DNS phải đặt dns là cluster.local
Trong trường hợp đặt sai hoặc đổi dns có thể dùng script để tạo lại sau đó restart lại controller-manager và apiserver

bash make-ca-cert.sh "172.16.0.1" "IP:172.16.0.1,IP:10.254.0.1,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local"
```

Cấu hình apisever

```
Edit file /etc/kubernetes/apiserver
KUBE_API_ARGS="--client-ca-file=/srv/kubernetes/ca.crt --tls-cert-file=/srv/kubernetes/server.cert --tls-private-key-file=/srv/kubernetes/server.key"
```

Cấu hình controller-manager
```
Edit file  /etc/kubernetes/controller-manager
KUBE_CONTROLLER_MANAGER_ARGS="--root-ca-file=/srv/kubernetes/ca.crt --service-account-private-key-file=/srv/kubernetes/server.key"
```

Restart lại service apiserver và controller-manager
```
systemctl restart kube-apiserve
systemctl restart kube-controller-manager
```

Sau khi restart lại sẽ có secret token được tạo cho default service-account
```
kubectl get secret 

[root@hoannv-k8s-master pods]# kubectl get secret 
NAME                  TYPE                                  DATA      AGE
default-token-8rbj6   kubernetes.io/service-account-token   3         7d

Token được tạo ra và DATA phải có số lớn hơn 1
```

Xem thông tin secret khi được truyền vào trong pod
```
kubectl describe secret/default-token-8rbj6

[root@hoannv-k8s-master pods]# kubectl describe secret/default-token-8rbj6
Name:           default-token-8rbj6
Namespace:      default
Labels:         <none>
Annotations:    kubernetes.io/service-account.name=default
                kubernetes.io/service-account.uid=4ba0ff74-1ff0-11e7-88cd-fa163e4b4b82

Type:   kubernetes.io/service-account-token

Data
====
token:          eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlZmF1bHQtdG9rZW4tOHJiajYiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjRiYTBmZjc0LTFmZjAtMTFlNy04OGNkLWZhMTYzZTRiNGI4MiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlZmF1bHQifQ.n3k__1J44Wew0AYe3N2pOuaQKX3JMpdtzyxeBjixV6iB8Wq0Ae0TEk952uoahafMx18_lbVpUP4BD8L2fvObx9fdiwC8EqDAs_xEn4GepGzXJDu_oPiO58dFb9dw8v7xXaMOl4bAnOlS_mMZPu-4SN-DHPbvxMLgjYxlbtbyYIhZvOKroajv4Y-gJYcalVSjws8p4NN-AKNkS4XjOM88guPn4xtM4oRNb0cALcJQrkYskCdyWbE81DcrOWbkVdCyiusx1nBnRRoYQpkn3tVhURLvESAjtjuho6DHs1YYUEzvpo4Wvat_mpzyJlJjuRhTIfyJPutWIKQOrYPpp7GIzw
ca.crt:         1220 bytes
namespace:      7 bytes
```

## Cài đặt dns cho kubernetes

### Link tham khảo
```
https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
```
### Dns name 
- Dns trong kubernetes có dạng <service-name>.<namespaces>.svc.<domain-name>
- Với domain name là : cluster.local, pod có metadata.name là pod-name, thuộc namespace là default thì dns sẽ có dạng sau.
```
pod-name.default.svc.cluster.local
```

### Tạo pod dns
```
wget https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.5.4/cluster/addons/dns/skydns-rc.yaml.in
wget https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.5.4/cluster/addons/dns/skydns-svc.yaml.in
```

Sửa file skydns-rc.yaml.in
```
Thay {{ pillar['dns_domain'] }}  bằng domain-name 
Ở đây thay bằng cluster.local.
Chú ý ở dòng 81 vẫn có phải có dâu . ở cuối dòng "- --domain=cluster.local."

Thêm vào tham số 
- --kube-master-url=http://<ip-master>:8080 vào dòng 82
"- --kube-master-url=http://10.3.105.202:8080"
```

Sửa file skydns-svc.yaml.in
```
Thay {{ pillar['dns_server'] }} bằng IP DNS.
Ví dụ lấy IP 10.254.3.100
Ip này sau sẽ được cấu hình vào trong kubelet để các pod trỏ đén dns server
```

Thực hiện command đê tạo các pod và service dns
```
kubectl create -f skydns-rc.yaml.in
kubectl create -f skydns-svc.yaml.in
```













# Config skydns

```
Trong container kubedns phần args phải chỉ định tham số cho kube-master-url ví dụ như 
--kube-master-url=http://172.16.86.162:8080

issue skydns
https://github.com/kubernetes/kubernetes/issues/42243


http://www.marcolenzo.eu/create-a-kubernetes-cluster-on-centos-7/
```

# config secret kubernetes 1.5
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/nginx.key -out /tmp/nginx.crt -subj "/CN=nginxsvc/O=nginxsvc"
kubectl create secret tls nginxsecret --key /tmp/nginx.key --cert /tmp/nginx.crt


$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $(KEY) -out $(CERT) -subj "/CN=nginxsvc/O=nginxsvc"
$ kubectl create secret tls nginxsecret --key /tmp/nginx.key --cert /tmp/nginx.crt


# bug ssl nginx

https://github.com/kubernetes/kubernetes/issues/42987

# k8s external access cluster
http://www.dasblinkenlichten.com/kubernetes-101-external-access-into-the-cluster/

https://kubernetes.io/docs/user-guide/services/#external-ips


# kubenetes mysql 
https://kubernetes.io/docs/tutorials/stateful-application/run-replicated-stateful-application/

# kubernetes and flocker
https://clusterhq.com/2015/04/24/data-migration-kubernetes-flocker/
https://clusterhq.com/2015/12/22/ha-demo-kubernetes-flocker/
https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/flocker



for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler flanneld kube-scheduler; do systemctl restart $SERVICES;systemctl enable SERVICES;systemctl status $SERVICES;done
    
for SERVICES in kube-proxy kubelet flanneld docker; do systemctl restart $SERVICES; systemctl enable $SERVICES; systemctl status $SERVICES;
done


bash make-ca-cert.sh "10.3.105.202" "IP:10.3.105.202,IP:10.254.0.1,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local"

./make-ca-cert.sh 192.168.127.100 IP:192.168.127.100,IP:10.0.0.1,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local

chmod 777 /srv/kubernetes/ca.crt