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
