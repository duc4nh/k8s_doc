# 1.Cài đăt ceph
## Tạo user k8s và pool là k8s-pool và phân quyền cho user k8s trên pool k8s-pool
```
ceph osd pool create k8s-pool 64 64 replicated
ceph auth get-or-create client.k8s mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=k8s-pool'
```
# 2.Cấu hình tích hợp kubernetes và ceph
## 2.1 Tạo secrets
Key trong secret là base64 của key auth user k8s
```
client.k8s
        key: AQBostxYAM0YMRAAEAb7Ep69blctPRxDpJDpaw==
        caps: [mon] allow r
        caps: [osd] allow class-read object_prefix rbd_children, allow rwx pool=k8s-pool
```

Với key trên thì key của secret là
```
echo "AQBostxYAM0YMRAAEAb7Ep69blctPRxDpJDpaw==" | base64
QVFCb3N0eFlBTTBZTVJBQUVBYjdFcDY5YmxjdFBSeERwSkRwYXc9PQo=
```

Cấu hình secret 
```
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret
type: "kubernetes.io/rbd"  
data:
  key: QVFCb3N0eFlBTTBZTVJBQUVBYjdFcDY5YmxjdFBSeERwSkRwYXc9PQ==
```
## 2.2 Tạo storage class
Với thông tin trên của ceph và 
```
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: ceph-storage
  annotations:
    storageclass.beta.kubernetes.io/is-default-class: "true" 
provisioner: kubernetes.io/rbd
parameters:
  fsType: ext4
  monitors: 10.3.105.11:6789,10.3.105.12:6789,10.3.105.130:6789
  adminId: k8s
  adminSecretName: ceph-secret
  adminSecretNamespace: kube-system
  pool: k8s-pool
  userId: k8s
  userSecretName: ceph-secret
```

# 3. Cấu hình ứng dụng sử dụng ceph 
Ví dụ với ứng dụng mysql 
```
volumeClaimTemplates:
- metadata:
    name: data
    annotations:
    volume.beta.kubernetes.io/storage-class: ceph-storage
spec:
    accessModes: ["ReadWriteOnce"]
    resources:
    requests:
        storage: 10Gi   
```
Với tham số volumeClaimTemplates  ứng dụng mysql sẽ tạo persistence volume và persistence volume claim động 
(có bao nhiêu node sẽ tạo ra tương ứng số PV,PVC)

https://arpnetworks.com/blog/2016/08/26/fixing-ceph-rbd-map-failed-6-no-such-device-or-address.html

I was getting "rbd: map failed fork/exec /usr/bin/rbd: invalid argument" as well. I fixed it by encoding the ceph secret with base64.

So on a ceph-mon:
sudo ceph auth get-key client.admin | base64

and put that value in your ceph-secret.


http://ceph.com/geen-categorie/bring-persistent-storage-for-your-containers-with-krbd-on-kubernetes/
https://sysdig.com/blog/ceph-persistent-volume-for-kubernetes-or-openshift/