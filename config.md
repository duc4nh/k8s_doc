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