# Architecture 

![alt text](architecture/architecture.png?raw=true "Architecture kubernetes")

## Master node
Là cluster control plane của kuberentes.

Master cung cấp REST API cho các thao tác CRUD của các resource : Pods, Service, ReplicateController...

### API Server
API Server cung cấp chức năng cơ bản của api.

* REST semantics, watch, durability and consistency guarantees, API versioning, defaulting, and validation
* Built-in admission-control semantics, synchronous admission-control hooks, and asynchronous resource initialization
* API registration and discovery

Ngoài ra API server còn là gateway cho cluster.

Tất cả data persistence được lưu trong etcd (key-value store).

Kube-api được document theo swagger 1.2 và OpenAPI. Location cho kube-api là /swaggerapi.
Kube-api có thể được vieu trực tiếp bằng cách thêm tham số --enable-swagger-ui=true vào api-server.

Khi cài đặt api server có service là kube-apiserver. File config /etc/kubernetes/api-server.

### Controller-Manager Server
Controller thực hiện các chức năng ở cluster-level.

Chức năng quản lý lifecycle : thêm, sửa, xóa, event gc và các api business logic (scale pods..)

Controller-manager cài đặt trên OS có service là kube-controller-manager
File config /etc/kubernetes/controller-manager

### Scheduler
Scheduler watch unscheduled pods và bind vào các kube node.

Việc binding dựa vào các tham số : tài nguyên yêu cầu, số lượng service, các spec và các constraint.

Controller-manager cài đặt trên OS có service là kube-scheduler

File config /etc/kubernetes/scheduler

## The Kubernetes Node









