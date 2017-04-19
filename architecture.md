
# Architecture 

![alt text](architecture/architecture.png?raw=true "Architecture kubernetes")


Trong hình architecture có bao gồm etcd nhưng etcd k nằm trong kubernetes mà là key-value store.


## Master node

- Là cluster control plane của kuberentes.

- Master cung cấp REST API cho các thao tác CRUD của các resource : Pods, Service, ReplicateController...

### API Server

- API Server cung cấp chức năng cơ bản của api: 

    * REST semantics, watch, durability and consistency guarantees, API versioning, defaulting, and validation
    * Built-in admission-control semantics, synchronous admission-control hooks, and asynchronous resource initialization
    * API registration and discovery

- Ngoài ra API server còn là gateway cho cluster.

- Tất cả data persistence được lưu trong etcd (key-value store).

- Kube-api được document theo swagger 1.2 và OpenAPI. Location cho kube-api là /swaggerapi.
- Kube-api có thể được vieu trực tiếp bằng cách thêm tham số --enable-swagger-ui=true vào api-server.

- Khi cài đặt api server có service là kube-apiserver. File config /etc/kubernetes/api-server.

### Controller-Manager Server

- Controller thực hiện các chức năng ở cluster-level.

- Thông qua api controller-manager chuyển trạng thái hiện tại thành trạng thái để mong đợi (move the current state towards the desired state.)

- Chức năng quản lý lifecycle : thêm, sửa, xóa, event gc và các api business logic (scale pods..)

- Controller-manager cài đặt trên OS có service là kube-controller-manager
- File config /etc/kubernetes/controller-manager

### Scheduler

- Scheduler watch unscheduled pods và bind vào các kube node.

- Việc binding dựa vào các tham số : tài nguyên yêu cầu, số lượng service, các spec và các constraint.

- Kube-scheduler cài đặt trên OS có service là kube-scheduler

- File config /etc/kubernetes/scheduler


## The Kubernetes Node

- Node có service để run container và đưuọc quản lý bởi kubenetes master.

### Kubelet

- Là node agent trên từng node.

- Kubelet phải register với master node bằng cách cấu hình với api-master/

- Khi tạo container scheduler thông qua kubelet xác định các tài nguyên có trong node đó. Nếu phù hợp điều kiện sẽ thực hiện tạo container trong node đó.

- Kubelet cài đặt trên OS có service là kubelet

- File config /etc/kubernetes/kubelet

### Container runtime

- Container runtime sẽ download image và running container.

- Kubelet không link tới base container runtime mà sẽ định nghĩa Container Runtime Interface để control underlying runtime.

- Runtime support hiện tại bao gồm docker, rkt, cro-o, frakti

### Kube Proxy

- Kube proxy group các pods với nhau dưới 1 common access policy.

- Proxy sẽ tạo 1 VIP client có thể truy cập.

- Mỗi node run kube-proxy có một iptables trap access và redirect tới các backend.

- Kube Proxy cài đặt trên OS có service là kube-proxy

- File config /etc/kubernetes/proxy

# Distributed Watchable Storage

- Như trong hình có 1 phần không thuộc về architecture của kubernetes là etcd

- Etcd là distributed key-value store. Etcd là thành phần chính của kubernetes, lưu trữ và replicate cluster state của kubenetes

- Etcd hoạt động theo 3 bước

    + Observe : kiểm tra trạng thái hiện tại thông qua api server
    + Analyze : tìm sự khác nhau giữa curent statue với desired state
    + Act : Thực hiện các lệnh fix sự khác nhau đó

- Etcd cài đặt trên OS có service là etcd

- File config /etc/etcd/etcd.conf


















