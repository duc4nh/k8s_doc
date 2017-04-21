# Namespace
- Namespace là khai niệm giúp phân định rõ quyền truy cập và sử dụng các tài nguyên của một nhóm (team, project, customer)
- Nếu Pod không được chỉ định namespace sẽ mặc định vào namespace default
- Trong mỗi namespace này phần lớn đều isolated : secret, network ...

# Resource type
- Các rất nhiều loại resource type khác, mỗi loại có công dụng khác nhau.
- Các resource-type thường có tên và alias, alias giúp việc thực hiện các command ngắn gọn hơn.
- Một số resource type hay dùng.
    + Pods: là đơn vị nhỏ nhất của kubernetes, Pod tạo ra vơi mục đích chạy đơn, thường chạy với mục đích test.
    + ReplicationController : đảm bảo luôn có một số lượng nhất định pod đưọc runing tại một thời điểm, số lượng pod này không nhất thiết phải phân đều ở các node. Thường sử dụng cho các ứng stateless như nginx, http server ...
    + ReplicaSet: thừa kế ReplicationController và support thêm selector và không support rolling-update.
    + Deployment: là next-generation của ReplicaSet với nhiều tính năng : update runtime, rolling-update, rollout, rollback update, scaling, pause and resume. Với những tính năng này deploment được khuyên dùng vì có đầy đủ tính năng, dễ thao tác.
    + DaemonSet: chắc chắn mỗi node của cluster chạy 1 pod, trong trường hợp node bị down hoặc out, pod sẽ bị delete ra khỏi daemonsets. DaemonSet phù hợp với application nhưng storage daemon( ceph, glusterfs ..), các ứng dụng distributed, logging (fluentd, logstash, cassandra)
    + StatefulSets : beta ở bản 1.5, với tên gọi nhưng vậy resource type này phù hợp với các ứng dụng stateful như là db (postgreql, môngdb). Các pod start lại lên theo đúng thứ tự và được delete theo thứ tự ngược lại. Khác với DaemonSet, các pod được khởi tạo song song.
    + Secrets : chứa những thông tin nhạy cảm : password, key. Password, key thường được mã hóa dưới dạng base64.
    + ConfigMap : là key-value config data có thể dược sử dụng trong pod (mount to file). Thường được sử dụng để lưu file config của application. Với config-map có thể thao tác với file config mà không cần truy cập vào pod. Một số application phải restart hoặc reload lại service có thể viết script check thay đổi file rồi restart.
    + Service : là abstraction định nghĩa logic nhiều Pod, định nghĩa ra policy để truy cập vào Pod. Mỗi Service được gán 1 ip duy nhất. Service sẽ tự động làm load balancing cho các Pod có labal và selector tương ứng.

# Label and selector
- Các Pod sẽ được tạo sẽ tăng lên rất nhanh, để tìm kiếm và phân loại được các Pod cần có Label và Selector
- Label là cặp key-value được gán vào resoure type như là pod, service, deployment hoặc các objects.
    + Ví dụ như application mysql có label "release: test, version=5.3"
- Selector : Với việc được gán label, selector có thể tìm đến chính xác objcect qua key.
    + API hiện tại hỗ trợ các selector : dạng tìm kiếm chính xác và tìm kiếm theo set
    + Vi dụ tìm kiems chính xác : environment = production, tier != frontend
    + Vi dụ tìm kiems theo set : environment in (production, qa), tier notin (frontend, backend), !partition

# Kubectl
- Là cli tương tác với kuberentes cluster 
- Cú pháp của cli
    + kubectl [command] [TYPE] [NAME] [flags]
    + một số command : get, set, exec, apply, update ...
    + một số type : pd, replicate controller, deployment, secret ...
    + name : tên của type bao gồm <namespace->/name
    + Nếu các resouce type thuộc namespace khác ngoài default cần thêm tham số -n ten_namespace trong các command.
    + Xem chi tiết các label --show-labels
    + Tham số  -l sẽ tìm tất cả resource type có label match. Tham số này có thể  sử dụng trong tất cả câu lệnh kubectl 

- List các resource type.
    + kubectl get <resource-type>,[<resource-type> ...] -o <output> -n <namespaces>
    + Ví dụ list tất cả các Pod, Service, Deployment, Secret ở dạng đầy đủ và thuộc tất cả namespaces
    ```
    [root@hoannv-k8s-master dns]# kubectl get pods,svc,deploy,secrets -o wide --all-namespaces                                              
    NAMESPACE     NAME                                       READY     STATUS    RESTARTS   AGE       IP             NODE
    default       po/busybox                                 1/1       Running   100        4d        172.30.61.2    10.3.105.204
    default       po/trireme-c4qrv                           1/1       Running   0          6d        10.3.105.204   10.3.105.204
    default       po/trireme-whpbs                           1/1       Running   0          7d        10.3.105.203   10.3.105.203
    demo          po/backend                                 1/1       Running   14         8d        172.30.20.3    10.3.105.203
    demo          po/external                                1/1       Running   12         8d        172.30.20.4    10.3.105.203
    demo          po/frontend                                1/1       Running   13         8d        172.30.20.2    10.3.105.203
    kube-system   po/heapster-b09xc                          1/1       Running   0          6d        172.30.20.7    10.3.105.203
    kube-system   po/kube-dns-613265574-mv77d                4/4       Running   0          7d        172.30.20.5    10.3.105.203
    kube-system   po/kubernetes-dashboard-3543765157-ngtbd   1/1       Running   0          7d        172.30.20.6    10.3.105.203

    NAMESPACE     NAME                       CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE       SELECTOR
    default       svc/kubernetes             10.254.0.1       <none>        443/TCP         8d        <none>
    kube-system   svc/heapster               10.254.105.180   <none>        80/TCP          6d        k8s-app=heapster
    kube-system   svc/kube-dns               10.254.3.100     <none>        53/UDP,53/TCP   8d        k8s-app=kube-dns
    kube-system   svc/kubernetes-dashboard   10.254.102.104   <none>        80/TCP          7d        k8s-app=kubernetes-dashboard

    NAMESPACE     NAME                          DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    kube-system   deploy/kube-dns               1         1         1            1           7d
    kube-system   deploy/kubernetes-dashboard   1         1         1            1           7d

    NAMESPACE     NAME                          TYPE                                  DATA      AGE
    default       secrets/default-token-8rbj6   kubernetes.io/service-account-token   3         8d
    default       secrets/trireme               Opaque                                1         8d
    demo          secrets/default-token-0z43p   kubernetes.io/service-account-token   3         8d
    kube-system   secrets/default-token-ttr46   kubernetes.io/service-account-token   3         8d
    ```
    + List tất cả các pods,svc,deploy,secrets có label là kube-dns và thuộc tất cả namespaces
    ```
    kubectl get pods,svc,deploy,secrets -l k8s-app=kube-dns --all-namespaces
    ```

- Thêm mới resource type
    + Kuberntes có thể run 1 Pod với 1 câu lệnh với các tham số có thể delete Pod sau khi thực hiện 1 câu lệnh.
    ```
    kubectl run nginx --image=nginx
    kubectl run -i --tty busybox --image=busybox --restart=Never --rm -- nslookup kubernetes
    ```
    + Để maintaince trong kubernetes thường sẽ viết config ra file dạng yaml hoăc là json. Sau đó dùng lệnh
    ```
    kubectl create -f busybox.yml
    ```
- Update resource type
    + kubectl edit <resource-type><resource-name>: thay đổi file cấu hình runtime, sau khi thay đổi sẽ apply luôn. Các cấu hình có thể thay đổi rất hạn chế. Ví dụ:
    ```
    kubectl edit po/busybox
    ```
    + kubectl apply : apply cấu hình dựa vào file yaml hoặc json.
    ```
    kubectl apply -f busybox.yml
    ```
    + kubectl patch : thay đổi lại tài nguyên dựa vào merge path
    ```
    kubectl patch -f node.json -p '{"spec":{"unschedulable":true}}'
    ```
    + kubectl replace : thay thế các trường hợp mà không thể thay đổi được bằng lệnh trên
    ```
    kubectl replace --force -f ./pod.json
    ```
    + rolling update : update mà k cần downtime nhưng chỉ apply với rc, có thể thay đổi image, deployment là resource cao hơn nên được khuyên dùng
    ```
    kubectl rolling-update frontend-v1 -f frontend-v2.json
    ```
- Delete Resource type
    + kubectl delete Podkubectl delete po/busybox
    ```
    kubectl delete po/busybox
    ```
- Xem info, describe và log của resource type
    + Describe cung cấp thông tin ressouce-type :  ngày tạo, namespaces, labels, spec và các event trong resouce type đó
    ```
    Xem thông tin của deployment kube-dns trong namespace kube-system
    kubectl describe deploy/kube-dns -n kube-system
    ```
    + Logs : xem log của các resouce type. thông tin quan trọng đẻ debug khi Pod tạo lỗi
    ```
    Xem log của deployment kube-dns. Vì deployment kube-dns có nhiều container nên cần chỉ định container cần xem logs bằng tham số -c 
    kubectl logs deploy/kube-dns -n kube-system -c kubedns
    ```
- Link tham khảo
```
https://kubernetes.io/docs/user-guide/kubectl-overview/
http://vishh.github.io/docs/user-guide/kubectl/kubectl_logs/
https://kubernetes.io/docs/user-guide/kubectl-cheatsheet/
```

