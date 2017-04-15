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