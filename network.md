# Cluster Networking
- Kubernetes có 4 vấn đền network cần giải quyết
    + Container-to-container : được giải quyết bằng localhost commmunication
    + Pod to pod commmunication : mõi Pod được gán 1 IP ở trong  flat shared networking namespace.
    + Pod to service communication : service được gán Virtual IP, client truy cập qua qua transparently proxied tới các Pod group. Request được đi qua kube-proxy.
    + External-to-Internal Communication : truy cập service từ bên ngoài bằng cách cấu hình external loadbalancer target tất cả các host. Traffiec đi vào 1 node sẽ dược route tới service backend qua Kube-proxy.
- Một số network
```
Contiv
Contrail
Flannel
Google Compute Engine (GCE)
L2 networks and linux bridging
Nuage Networks VCS (Virtualized Cloud Services)
OpenVSwitch
OVN (Open Virtual Networking)
Project Calico
Romana
Weave Net from Weaveworks
```

# Compare some networks
- So sánh một số network.
```
http://chunqi.li/2015/11/15/Battlefield-Calico-Flannel-Weave-and-Docker-Overlay-Network/
http://blog.kubernetes.io/2016/09/high-performance-network-policies-kubernetes.html
https://www.projectcalico.org/project-calico-needs-to-communicate-better/
```

![alt text](network/compare_network.png?raw=true "Compare some networks")

# Ingress Resources

## Một vài thuật ngữ
- Node máy ảo hoặc máy chủ vật lý trong Kuberetes cluster.
- Cluster : nhóm các node được nằm trong firewall.
- Edge router : một router bắt buộc firewall policy ở trong cluster. Có thể là gateway của cloudprovider hoặc là fireall cứng
- Cluster network : bộ các links, logical hay physical, liên kết cluster to kubernetes network mode. Ví dụ là cluster network bao gồm overlay như flannel hoặc SDN (OVS).
- Service : kubernetes service xác định nhóm 

## Ingress là gì 
- Ingress là tập hơp các rules cho phép các inbound connection tới cluster service.
```
internet
    |
[ Ingress ]
--|-----|--
[ Services ]
``` 
- Ingress có thể được coi như : services externally-reachable urls, load balance traffic, terminate SSL, offer name based virtual hosting 
- User request ingress bằng cách POST ingress reosource tới API. Ingress Controller ( 1 phần trong kube-controller-manager) sẽ phản hồi lại.
- Ingress Sample
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        backend:
          serviceName: test
          servicePort: 80
```

## Type of Ingress 

### Single Service Ingress
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
spec:
  backend:
    serviceName: testsvc
    servicePort: 80
```

- Expose service testsvc qua port 80


### Simple fanout
- Có thể nhận ingress traffic và proxy tới đúng endpoints ví dụ.
```
foo.bar.com -> 178.91.123.132 -> / foo    s1:80
                                 / bar    s2:80
```

- Ingress sẽ được cấu hình
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /foo
        backend:
          serviceName: s1
          servicePort: 80
      - path: /bar
        backend:
          serviceName: s2
          servicePort: 80
```

### Name based virtual hosting
- Sử dụng ingress traffic dựng vào hostname và proxy tới đúng nơi.
```
foo.bar.com --|                 |-> foo.bar.com s1:80
              | 178.91.123.132  |
bar.foo.com --|                 |-> bar.foo.com s2:80
```

- Cấu hình ingress
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - backend:
          serviceName: s1
          servicePort: 80
  - host: bar.foo.com
    http:
      paths:
      - backend:
          serviceName: s2
          servicePort: 80
```

### TLS 
- Tạo TLS private key và certificate, sau đó tạo secrets
```
apiVersion: v1
data:
  tls.crt: base64 encoded cert
  tls.key: base64 encoded key
kind: Secret
metadata:
  name: testsecret
  namespace: default
type: Opaque
```

- Tạo ingress
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: no-rules-map
spec:
  tls:
    - secretName: testsecret
  backend:
    serviceName: s1
    servicePort: 80
```

# Network Policy

## Network Policy là gì
- Network policy : policy xác định các Pod có thể communicate với nhau như thế nào. Bình thường các Pod thông với nhau.
```

```

Node: A single virtual or physical machine in a Kubernetes cluster.
Cluster: A group of nodes firewalled from the internet, that are the primary compute resources managed by Kubernetes.
Edge router: A router that enforces the firewall policy for your cluster. This could be a gateway managed by a cloudprovider or a physical piece of hardware.
Cluster network: A set of links, logical or physical, that facilitate communication within a cluster according to the Kubernetes networking model. Examples of a Cluster network include Overlays such as flannel or SDNs such as OVS.
Service: A Kubernetes Service that identifies a set of pods using label selectors. Unless mentioned otherwise, Services are assumed to have virtual IPs only routable within the cluster network.


##

# Link compare network

```
http://www.dasblinkenlichten.com/kubernetes-101-external-access-into-the-cluster/
http://blog.kubernetes.io/2015/10/some-things-you-didnt-know-about-kubectl_28.html

http://chunqi.li/2015/11/15/Battlefield-Calico-Flannel-Weave-and-Docker-Overlay-Network/
https://github.com/projectcalico/canal

http://blog.kubernetes.io/2016/09/high-performance-network-policies-kubernetes.html
https://www.projectcalico.org/project-calico-needs-to-communicate-better/

http://machinezone.github.io/research/networking-solutions-for-kubernetes/
```

# kubernetes
```
http://blog.octo.com/en/how-does-it-work-kubernetes-episode-1-kubernetes-general-architecture/
http://blog.octo.com/en/how-does-it-work-kubernetes-episode-2-kubernetes-networking/
http://blog.octo.com/en/how-does-it-work-kubernetes-episode-3-infrastructure-as-code-the-tools-of-the-trade/
http://blog.octo.com/en/how-does-it-work-kubernetes-episode-4-how-to-ansible-your-coreos-and-etcd/
http://blog.octo.com/en/how-does-it-work-kubernetes-episode-5-master-and-worker-at-last/
```

# kubernetes netowrk
```
http://blog.octo.com/en/how-does-it-work-kubernetes-episode-2-kubernetes-networking/
```

# kubernetes-calico
```
http://docs.projectcalico.org/v2.1/getting-started/kubernetes/installation/integration
http://leebriggs.co.uk/blog/2017/02/18/kubernetes-networking-calico.html
```

# kubernetes-trireme
```
https://github.com/aporeto-inc/trireme-kubernetes
http://www.eweek.com/security/trireme-open-source-security-project-debuts-for-kubernetes-docker
http://packetpushers.net/new-open-source-software-trireme-tackles-container-security/
```

# calico project
```
https://www.linux.com/news/project-calico-open-source-high-scale-network-fabric-cloud
```

# calico openstack
```
http://docs.projectcalico.org/v2.0/getting-started/openstack/
```

# openstack openconstrail & kubernetes calico
```
http://www.opencontrail.org/bgpaas-in-openstack-kubernetes-with-calico-in-openstack-with-opencontrail/
https://www.slideshare.net/JakubPavlik1/kubernetes-sdn-performance-and-architecture
```

# openstack on kubernetes
```
http://superuser.openstack.org/articles/making-openstack-production-ready-with-kubernetes-and-openstack-salt-part-2/
```

# canal
```
https://github.com/projectcalico/canal
```

# romana
```
https://github.com/romana/romana
http://romana.io/how/performance/
```

# open constrail
```
http://www.opencontrail.org/opencontrail-architecture-documentation/
https://blogs.rdoproject.org/7640/a-journey-of-a-packet-within-opencontrail
```

# open constrail vs openvswitch 
```
http://www.opencontrail.org/i-studied-opencontrail/
```

# So sánh



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
