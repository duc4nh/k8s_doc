# Pod

- Là đơn vị nhỏ nhát của kubernretes.
- Pod encapsulates một application container (bao gồm storage, network ip, options đẻ run application)
- Pod đại diện cho một instance của application trong kubernetes
- Docker là container runtime thường được sử dụng.
- 1 Pod có thể chứa một hoặc nhiều container.
- Ví dụ câu hình một port
```
apiVersion: v1
  kind: Pod
  metadata:
    name: node-js-pod
  spec:
    containers:
      - name: node-js-pod
      image: bitnami/apache:latest
      ports:
      - containerPort: 80

apiVersion : ở mỗi version của kubernetes các route ở các dạng alpha1, beta1 hoặc release là v1 ..
kind : Pod là tên resource.
metadata ; là các thông tin meta được lưu dưới dạng key-value, thông tin này về sau có thể được sử dụng để tim kiếm
spec : đặc tả mỗi thông tin của các resource, các spec của mỗi version khác ví dụ spec của pod trong version 1.5: https://kubernetes.io/docs/api-reference/v1.5/#podspec-v1-core

```

# Kubernetes networking
- Mỗi pod được gán 1 Ip duy nhất
- Kubernetes không sử dụng NAT để kết nối giữa các container hoặc là container tới node
- Kubernetes sử dụng placeholder(pod infrastructure container) để cấp phát ip 
- Networking in Kubernetes requires that each pod have its own IP address.
- Container bên trong pod có thể communicate với nhau sử dụng localhost.

# Network compare
- Kuberenetes support nhiều network khác nhau
* Docker:
    + Mặc định sử dụng bridged networking mode. Với mode này, cotainer có networking namespace riêng và bridged qua virtual interface tới host ( hoặc node trong k8s)
    + Ở mode bridged, 2 cotainer có thể có cùng IP range vì các container isolated.
    + Docker support host mode, container có thể sử dụng host network stack.
    + Docker hỗ trợ container mode, share network namespace giữa 2 container. Container share namespace và IP address. Vì vậy mà cotainer không thể sử dụng cùng port.
    + Liên kết giữa 2 machine yêu cầu NAT và port mapping.

* Docker plugins (libnetwork)
    + Với plugin này, network trong các container sẽ được tạo độc lập với nhau. Container có thể join vào cùng 1 network.
    + Pugin không cho phép wide range network.

* Flannel
    + Flannel lấy full subnet cho từng host/node.
    + Flannel bao gồm in-kernel VXLAN encapsulation mode cho hiệu năng tốt hơn, có multinetwork mode giống nhau mà overlay docker plugin.

* Project Calico
    + Project Calico là layer 3-based networking model sử dụng buil-in routing function trong linux kernel. Route được truyền tới virtual router trên từng host qua BGP (Border Gateway Protocol)
    + Bởi vì nằm ở level thấp trong network stack, không cần thêm NAT, tunneling hay overlay. Calico có thể tương tác trực tiếp với underlying network infrastructure.
* So sánh một số network khi tích hợp với kubernetes. Dựa vào các yêu cầu của bài toán có thể lựa chọn giải pháp.
```
http://chunqi.li/2015/11/15/Battlefield-Calico-Flannel-Weave-and-Docker-Overlay-Network/
```

* Ngoài ra thêm một phần khi run kubernetes trên openstack cần xác định network cho openstack và kubernetes để đạt được performance tốt nhất. Đây là một số link tham khảo network cho cả openstack và kuberentes.
```
http://www.opencontrail.org/bgpaas-in-openstack-kubernetes-with-calico-in-openstack-with-opencontrail/
https://www.slideshare.net/JakubPavlik1/kubernetes-sdn-performance-and-architecture
```

## Storage in pods
- Pod có thể có nhiều storage gọi là volume
- Pod có thể truy cập vào share storage.
- Volume sẽ không bị xóa data khi pods restart

- Để có thể kết nối với các storage khác nhau, Kuberenetes đưa ra các khái niệm.
    + StorageClass : dùng từ class là vì ở đây ta có thể chia dược các loại storage khác nhau như ceph, scaleio, cinder-volume. Với mỗi loại storage có thể chia đến các pool hoặc là volume.
    + PersistentVolume(pv) : là 1 phẩn nhỏ trong share storage, pv có thể là share storage của các node, lấy từ các storageclass. Nó như là 1 box chứa 1 khoảng dung lượng storage.
    + PersistentVolumeClaim(pvc ) : là request storage của pod. Nếu request này match với pv thì sẽ được boud vào pv. Các điều kiện dùng là anootation storageclass và label.

- Một số lưu ý về pv và pvc
+ Một pv chỉ có thể boud 1 pvc, pvc sẽ nếu k tìm được match pv sẽ ở trạng thái pending, các pod đang yêu cầu storage cũng sẽ ở trạng thái pending. Nếu có một pv match với pvc, pvc sẽ chueyển trạng thái thành boud -> pod sẽ chuyển trạng thái.
+ Các storage Pvc support 
```
AWS
GCE
Glusterfs
OpenStack Cinder
vSphere
Ceph RBD
Quobyte
Azure Disk
Portworx Volume
ScaleIO (1.6 mới alpha)
```
+ Các Storage không đáp ứng hết được các loại storage nên cần có 1 container data volume orchestrator khác là flocker. Sẽ đi sâu vào flocker sau. Hiện tại flocker đang dừng và không biết có được dev tiếp nữa không
