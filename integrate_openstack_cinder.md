# Cáu hình tích hợp với openstack cinder-volume
- Cài đặt một số package.
- Cấu hình kubernetes với kuberlet
- Tạo volume và test
- Run ứng dụng wordpress với persistence volume

## Cài thêm thư viện udevadm
- Thực hiện với tất cả worker node.
- Khi mount lên workder node, cần có thêm thư viện udevadm để kubernetes thực hiện một số tham tác.
- Với centos 7 thực hiện command.
```
yum install libgudev1.x86_64
```

## Cấu hình kubelet với openstack cinder
- https://github.com/kubernetes/kubernetes/blob/release-1.5.4/pkg/cloudprovider/providers/openstack/openstack.go

Với link trên có thể thấy các tham số được phép truyền vào.
```
AuthUrl    string `gcfg:"auth-url"`
Username   string
UserId     string `gcfg:"user-id"`
Password   string
ApiKey     string `gcfg:"api-key"`
TenantId   string `gcfg:"tenant-id"`
TenantName string `gcfg:"tenant-name"`
TrustId    string `gcfg:"trust-id"`
DomainId   string `gcfg:"domain-id"`
DomainName string `gcfg:"domain-name"`
Region     string
```

- File cấu hình openstack /etc/kubernetes/openstack_config
```
[Global]
auth-url=http://103.69.194.14:5000/v3/
username=demo
password=VCC123**
region=Nam-Thang-Long
domain-name=Default
tenant-name=CS-Production
```


- Cấu hình kubelet 
Edit file /etc/kubernetes/kubelet, thêm vào tham số KUBELET_ARGS=
```
--cloud-config=/etc/kubernetes/openstack_config --cloud-provider=openstack
```

- Restart lại kubelet
```
systemctl restart kubelet 
```

# Tạo volume và chạy ứng dụng trên persistence volume

## Tạo storage-class
Edit file storage-class-cinder-volume.yaml
```
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: cinder-volume
provisioner: kubernetes.io/cinder
parameters:
  type: TRUE_SSD
  availability: nova
```
Name: cinder-volume, được sử dụng để tạo Persistence Volume và Persistence Volume Claim.
Type:  là volume type trong cinder-volume
availability: zone openstack 

## Tích hợp với ứng dụng chạy persistce volume

### Dynamic Provisioning.
- Tạo PersistentVolumeClaim
```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-dynamic-pvc
  annotations:
    volume.beta.kubernetes.io/storage-class: cinder-volume
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```
- Với PersistentVolumeClaim này, openstack sẽ tựng động tạo PersistentVolume và 1 PersistentVolumeClaim có Recycle là Delete. Tức là sau khi Pod bị xóa thì volume này cũng bị xóa.

- Muôn volume này không bị xóa cần thay đổi  Recycle của Volume thành Retain

### Static Provisioning.
- Đẻ match được Peristent Volume và Peristent Volume (sử dụng chung 1 storage class, có chung size) có thể dụng labal và selector, cùng với annotation là storage-classs.
- Tạo Peristent Volume
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-cinder-volume
  labels:
    volume: mysql-app
  annotations:
    volume.beta.kubernetes.io/storage-class: cinder-volume
spec:
  capacity:
    storage: 32Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  cinder:
    fsType: ext4
    volumeID: ef213b16-dfce-401f-809b-c0d72971b087
```
- Peristent Volume có annotation storage-class là cinder-volume và label là mysql-app
- Khi tạo Persistent Volume Claim cần có label là mysql-app
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  annotations:
    volume.beta.kubernetes.io/storage-class: cinder-volume
  labels:
    app: wordpress
    volume: mysql-app
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 32Gi
  selector:
    matchLabels:
      volume: mysql-app
```
- Với cấu hình như trên PersistentVolumeClaim sẽ bound với PersistentVolume có annotation storage-class là cinder-volume và label volume=mysql-app 
- Cấu hình mysql sử dụng PersistentVolumeClaim ở trên 
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
          # $ kubectl create secret generic mysql-pass --from-file=password.txt
          # make sure password.txt does not have a trailing newline
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password.txt
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
```
- Với cấu hình dưới đây, mysql sẽ sử dụng persistentVolumeClaim có tên là mysql-persistent-storage
```
volumes:
- name: mysql-persistent-storage
persistentVolumeClaim:
    claimName: mysql-pv-claim
```






https://github.com/kubernetes/kubernetes/tree/master/examples/mysql-cinder-pd

http://stackoverflow.com/questions/40162641/kubernetes-cinder-volumes-do-not-mount-with-cloud-provider-openstack


http://blog.kubernetes.io/2016/10/dynamic-provisioning-and-storage-in-kubernetes.html

http://blog.kubernetes.io/2017/03/dynamic-provisioning-and-storage-classes-kubernetes.html