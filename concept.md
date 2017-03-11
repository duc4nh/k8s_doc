- ReplicationController :  
+ A ReplicationController ensures that a specified number of pod “replicas” are running at any one time.
+ If there are too many pods, it will kill some. If there are too few, the ReplicationController will start more. 

- Labels
+ Labels are key/value pairs that are attached to objects, such as pods.
+ Example : "release" : "stable", "release" : "canary"

- Selector
+ Via a label selector, the client/user can identify a set of objects. The label selector is the core grouping primitive in Kubernetes.
+ The selector tells Kubernetes which labels to use in finding pods to forward traffic for that service.
+ The API currently supports two types of selectors: equality-based and set-based.
+ Equality-based requirement :  environment = production , tier != frontend
+ Set-based requirement : environment in (production, qa), tier notin (frontend, backend), !partition

- Service
+ A Kubernetes Service is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called a micro-service. 
+ For Kubernetes-native applications, Kubernetes offers a simple Endpoints API that is updated whenever the set of Pods in a Service changes.
+ For non-native applications, Kubernetes offers a virtual-IP-based bridge to Services which redirects to the backend Pods.
+ When created, each Service is assigned a unique IP address (also called clusterIP). This address is tied to the lifespan of the Service, and will not change while the Service is alive. Pods can be configured to talk to the Service, and know that communication to the Service will be automatically load-balanced out to some pod that is a member of the Service.

- Health check
+ This is our core health check element. From there, we can specify httpGet , tcpScoket , or exec .
+ Status codes between 200 and 399 are all considered healthy by the probe.
+ Finally, initialDelaySeconds gives us the flexibility to delay health checks until the pod has finished initializing. timeoutSeconds is simply the timeout value for the probe.
+ Liveness Probes : If the app never starts up or responds with an HTTP error code then Kubernetes will restart the pod. 
+ Readiness Probes : Readiness probes are meant to check if your application is ready to serve traffic. If the readiness probe for your app fails, then that pod is removed from the endpoints that make up a service.

- Life cycle hooks or graceful shutdown
+ Kubernetes actually provides life cycle hooks : take additional action before containers are shutdown or right after they are started.

- Application scheduling
+ Scheduler will place new pods on nodes with the least number of other pods belonging to matching services or replication controllers.
+ Additionally, the scheduler provides the ability to add constraints based on resources available to the node : cpu-shares and memory limit flags
+ When additional constraints are defined, Kubernetes will check a node for available resources. If a node does not meet all the constraints, it will move to the next. If no nodes can be found that meet the criteria, then we will see a scheduling error in the logs.


# Core Concepts – Networking, Storage, and Advanced Services

- Kubernetes networking
+ Networking in Kubernetes requires that each pod have its own IP address.
+ Kubernetes does not allow the use of Network Address Translation (NAT) for container-to-container or for container-to-node (minion) traffic.
+ K8s achieves this pod-wide IP magic by using a placeholder (pod infrastructure container)
+ the pause container holds the networking namespace and IP address for the entire pod and can be used by all the containers running within.

- Networking comparisons
* Docker: 
+ Deefault uses a bridged networking mode. In this mode, the container has its own networking namespace and is then bridged via virtual interfaces to the host (or node in the case of K8s) network.
+ In the bridged mode, two containers can use the same IP range because they are completely isolated.
+ Docker also supports a host mode, which allows the containers to use the host network stack. 
+ Docker supports a container mode, which shares a network namespace between two containers. The containers will share the namespace and IP address, so containers cannot use the same ports.
+ Connecting containers across two machines then requires Network Address Translation (NAT) and port mapping for communication.

* Docker plugins (libnetwork)
+ This plugin allows networks to be created independent of the containers themselves. In this way, containers can join the same existing networks.
+ It’s important to note that the plugin mechanism will allow a wide range of networking possibilities in Docker.

* Flannel
+ Flannel gives a full subnet to each host/node enabling a similar pattern to the Kubernetes practice of a routable IP per pod or group of containers.
+ Flannel includes an in-kernel VXLAN encapsulation mode for better performance and has an experimental multinetwork mode similar to the overlay Docker plugin.

* Project Calico
+ Project Calico is a layer 3-based networking model that uses the built-in routing functions of the Linux kernel. Routes are propagated to virtual routers on each host via Border Gateway Protocol (BGP).
+ Because it works at a lower level on the network stack, there is no need for additional NAT, tunneling, or overlays. It can interact directly with the underlying network infrastructure.

- Balanced design
+ It’s important to point out the balance Kubernetes is trying to achieve by placing the IP at the pod level.

- Advanced services
+ Kubernetes is using kube-proxy to determine the proper pod IP address and port serving each request. Behind the scenes, kube-proxy is actually using virtual IPs and iptables to make all this magic work.
+ Recall that kube-proxy is running on every host. Its first duty is to monitor the API from the Kubernetes master. Any updates to services will trigger an update to iptables from kube-proxy.
+ It is also possible to always forward traffic from the same client IP to same backend pod/container using the sessionAffinity element in your service definition.

- External services
+ This was configured by the type: LoadBalancer element in our service definition. The LoadBalancer type creates an external load balancer on the cloud provider.

- Internal services
+ By default, services are internally facing only. You can specify a type of clusterIP to achieve this, but if no type is defined, clusterIP is the assumed type.
+ Further, the IP address is not externally accessible. We won’t be able to test the service from a web browser this time. However, we can use the handy kubectl exec command and attempt to connect from one of the other pods.

- Custom load balancing
+ A third type of service K8s allows is the NodePort type. This type allows us to expose a service through the host or minion on a specific port. In this way, we can use the IP address of any node (minion) and access our service on the assigned node port.
+ Kubernetes will assign a node port by default in the range of 3000–32767
 
- Cross-node proxy
+ Remember that kube-proxy is running on all the nodes, so even if the pod is not running there, traffic will be given a proxy to the appropriate host.
+ Kube-proxy simply passes traffic on to the pod IP for this service

- Migrations, multicluster, and more
+ To allow access to non-pod–based applications, the services construct allows you to useendpoints that are outside the cluster. + + Kubernetes is actually creating an endpoint resource every time you create a service that uses selectors. 
+ The endpoints object keeps track of the pod IPs in the load balancing pool.

- Service discovery
+ Discovery can occur in one of three ways. The first two methods use Linux environment variables. There is support for the Docker link style of environment variables, but Kubernetes also has its own naming convention.
+ Another option for discovery is through DNS.

- DNS
+ DNS solves the issues seen with environment variables by allowing us to reference the services by their name.
+ Kubernetes offers a DNS cluster addon Service that uses skydns to automatically assign dns names to other Services. 

- Proxies
+ The kubectl proxy: - runs on a user’s desktop or in a pod - proxies from a localhost address to the Kubernetes apiserver - client to proxy uses HTTP - proxy to apiserver uses HTTPS - locates apiserver - adds authentication headers
+ The apiserver proxy: - is a bastion built into the apiserver - connects a user outside of the cluster to cluster IPs which otherwise might not be reachable - runs in the apiserver processes - client to proxy uses HTTPS (or http if apiserver so configured) - proxy to target may use HTTP or HTTPS as chosen by proxy using available information - can be used to reach a Node, Pod, or Service - does load balancing when used to reach a Service
+ The kube proxy: - runs on each node - proxies UDP and TCP - does not understand HTTP - provides load balancing - is just used to reach services
+ A Proxy/Load-balancer in front of apiserver(s): - existence and implementation varies from cluster to cluster (e.g. nginx) - sits between all clients and one or more apiservers - acts as load balancer if there are several apiservers.
+ Cloud Load Balancers on external services: - are provided by some cloud providers (e.g. AWS ELB, Google Cloud Load Balancer) - are created automatically when the Kubernetes service has type LoadBalancer - use UDP/TCP only - implementation varies by cloud provider.

- Scale
+ Kubernetes can scale up, scale down, autoscale form i to n

- Change config using kubectl apply
+ Note: To use apply, always create resource initially with either kubectl apply or kubectl create --save-config

- Có thể thay đổi các rc,service bằng cách
+ kubectl edit : thay đổi file cấu hình
+ kubectl apply : apply cấu hình dựa vào file yaml hoặc json
+ kubectl patch : thay đổi lại tài nguyên dựa vào merge path
+ kubectl replace : thay thế các trường hợp mà k thể thay đổi được bằng lệnh trên
+ rolling update : update mà k cần downtime nhưng chỉ apply với rc, có thể thay đổi image, deployment là resource cao hơn nên được khuyên dùng

- ConfigMap :The ConfigMap API resource holds key-value pairs of configuration data that can be consumed in pods or used to store configuration data for system components such as controllers.
+ Populate the value of environment variables
+ Set command-line arguments in a container
+ Populate config files in a volume
+ ConfigMaps can be used to populate environment variables. 
+ ConfigMaps must be created before they are consumed in pods.
+ ConfigMaps reside in a namespace. 

- Horizontal Pod Autoscaling
+ use autoscale
+ Examepl : --cpu-percent=50 --min=1 --max=10, with a cpu-percent is 50, kubectl scale up pod to 1
+ if cpu is 350%, number of pod is 7

- full example config
+ https://github.com/kubernetes/kubernetes/blob/master/examples/guestbook/all-in-one/guestbook-all-in-one.yaml

- Network policy
+ Support 
    Calico
    Romana
    Weave Net
+ kubectl annotate ns default "net.beta.kubernetes.io/network-policy={\"ingress\": {\"isolation\": \"DefaultDeny\"}}"

- Jobs
+ A job creates one or more pods and ensures that a specified number of them successfully terminate. 
+ As pods successfully complete, the job tracks the successful completions. When a specified number of successful completions is reached, the job itself is complete. 
+ Deleting a Job will cleanup the pods it created.
    Non-parallel Jobs
        normally only one pod is started, unless the pod fails.
        job is complete as soon as Pod terminates successfully.
    Parallel Jobs with a fixed completion count:
        specify a non-zero positive value for .spec.completions
        the job is complete when there is one successful pod for each value in the range 1 to .spec.completions.
        not implemented yet: each pod passed a different index in the range 1 to .spec.completions.
    Parallel Jobs with a work queue:
        do not specify .spec.completions, default to .spec.Parallelism
        the pods must coordinate with themselves or an external service to determine what each should work on
        each pod is independently capable of determining whether or not all its peers are done, thus the entire Job is done.
        when any pod terminates with success, no new pods are created.
        once at least one pod has terminated with success and all pods are terminated, then the job is completed with success.
        once any pod has exited with success, no other pod should still be doing any work or writing any output. They should all be in the process of exiting.

+ Cron Jobs: link crontab

- 















