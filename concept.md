# ReplicationController :  
```
A ReplicationController ensures that a specified number of pod “replicas” are running at any one time.
If there are too many pods, it will kill some. If there are too few, the ReplicationController will start more. 
```

- DaemonSet
    + A DaemonSet ensures that all (or some) nodes run a copy of a pod. As nodes are added to the cluster, pods are added to them. As nodes are removed from the cluster, those pods are garbage collected. Deleting a DaemonSet will clean up the pods it created.
    + Use a replication controller for stateless services, like frontends, where scaling up and down the number of replicas and rolling out updates are more important than controlling exactly which host the pod runs on. Use a Daemon Controller when it is important that a copy of a pod always run on all or certain hosts, and when it needs to start before other pods.
    + Normally, the machine that a pod runs on is selected by the Kubernetes scheduler. However, pods created by the Daemon controller have the machine already selected (.spec.nodeName is specified when the pod is created, so it is ignored by the scheduler). 
    + You cannot update a DaemonSet.

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

- SSL for container
+ Use secret tls to create secret, mount tls use mountPath

- Init Containers
+ A Pod can have multiple Containers running apps within it, but it can also have one or more Init Containers, which are run before the app Containers are started.
+ Init Containers support all the fields and features of app Containers, including resource limits, volumes, and security settings. However, the resource requests and limits for an Init Container are handled slightly differently, which are documented in Resources below. Also, Init Containers do not support readiness probes because they must run to completion before the Pod can be ready.
+ They can contain and run utilities that are not desirable to include in the app Container image for security reasons.
+ They can contain utilities or custom code for setup that is not present in an app image. For example, there is no need to make an image FROM another image just to use a tool like sed, awk, python, or dig during setup.
+ The application image builder and deployer roles can work independently without the need to jointly build a single app image.
+ They use Linux namespaces so that they have different filesystem views from app Containers. Consequently, they can be given access to Secrets that app Containers are not able to access.
+ They run to completion before any app Containers start, whereas app Containers run in parallel, so Init Containers provide an easy way to block or delay the startup of app Containers until some set of preconditions are

# Resource limit
```
CPU and memory are each a resource type. A resource type has a base unit. CPU is specified in units of cores, and memory is specified in units of bytes.
Limits and requests for CPU resources are measured in cpu units. One cpu, in Kubernetes, is equivalent to:
    1 AWS vCPU
    1 GCP Core
    1 Azure vCore
    1 Hyperthread on a bare-metal Intel processor with Hyperthreading
Limits and requests for memory are measured in bytes. You can express memory as a plain integer or as a fixed-point integer using one of these SI suffixes: E, P, T, G, M, K. You can also use the power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. For example, the following represent roughly the same value:
requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
        Each Container has a request of 0.25 cpu and 64MiB (226 bytes) of memory Each Container has a limit of 0.5 cpu and 128MiB of memory. 
Each node has a maximum capacity for each of the resource types: the amount of CPU and memory it can provide for Pods. The scheduler ensures that, for each resource type, the sum of the resource requests of the scheduled Containers is less than the capacity of the node.
```

#. 

- The number and meanings of Pod phase values are tightly guarded. Other than what is documented here, nothing should be assumed about Pods that have a given phase value.
    + Pending: The Pod has been accepted by the Kubernetes system, but one or more of the Container images has not been created. This includes time before being scheduled as well as time spent downloading images over the network, which could take a while.
    + Running: The Pod has been bound to a node, and all of the Containers have been created. At least one Container is still running, or is in the process of starting or restarting.
    + Succeeded: All Containers in the Pod have terminated in success, and will not be restarted.
    + Failed: All Containers in the Pod have terminated, and at least one Container has terminated in failure. That is, the Container either exited with non-zero status or was terminated by the system.
    + Unknown: For some reason the state of the Pod could not be obtained, typically due to an error in communicating with the host of the Pod

- Life cycle hooks or graceful shutdown :As you run into failures in real-life scenarios, you may find that you want to take
additional action before containers are shutdown or right after they are started. 
+ Kubernetes actually provides life cycle hooks for just this kind of use case.
+ Controller definition defines both a postStart and a preStop action to take place before Kubernetes moves the container into the next stage of its life cycle

- Assigning Pods to Nodes
+ There are several ways to do this, and they all use label selectors to make the selection. Generally such constraints are unnecessary, as the scheduler will automatically do a reasonable placement 
+ Then, to add a label to the node you’ve chosen, run kubectl label nodes <node-name> <label-key>=<label-value>
+ You can verify that it worked by re-running kubectl get nodes --show-labels and checking that the node now has a label.
+ Node affinity is conceptually similar to nodeSelector – it allows you to constrain which nodes your pod is eligible to schedule on, based on labels on the node.
- Inter-pod affinity and anti-affinity allow you to constrain which nodes your pod is eligible to schedule on based on labels on pods that are already running on the node rather than based on labels on nodes.

- Exposing Pod Information to Containers Using a DownwardApiVolumeFile
+ This page shows how a Pod can use a DownwardAPIVolumeFile to expose information about itself to Containers running in the Pod. A DownwardAPIVolumeFile can expose Pod fields and Container fields.
```
The following information is available to Containers through environment variables and DownwardAPIVolumeFiles:

    The node’s name
    The Pod’s name
    The Pod’s namespace
    The Pod’s IP address
    The Pod’s service account name
    A Container’s CPU limit
    A container’s CPU request
    A Container’s memory limit
    A Container’s memory request

In addition, the following information is available through DownwardAPIVolumeFiles.

    The Pod’s labels
    The Pod’s annotations
```

- StatefulSets
    + https://kubernetes.io/docs/tutorials/stateful-application/run-replicated-stateful-application/
    + StatefulSets are valuable for applications that require one or more of the following.

        Stable, unique network identifiers.
        Stable, persistent storage.
        Ordered, graceful deployment and scaling.
        Ordered, graceful deletion and termination.

```
StatefulSet is a beta resource, not available in any Kubernetes release prior to 1.5.
As with all alpha/beta resources, you can disable StatefulSet through the --runtime-config option passed to the apiserver.
The storage for a given Pod must either be provisioned by a PersistentVolume Provisioner based on the requested storage class, or pre-provisioned by an admin.
Deleting and/or scaling a StatefulSet down will not delete the volumes associated with the StatefulSet. This is done to ensure data safety, which is generally more valuable than an automatic purge of all related StatefulSet resources.
StatefulSets currently require a Headless Service to be responsible for the network identity of the Pods. You are responsible for creating this Service.
Updating an existing StatefulSet is currently a manual process
```

- Volume : On-disk files in a container are ephemeral, which presents some problems for non-trivial applications when running in containers. First, when a container crashes kubelet will restart it, but the files will be lost - the container starts with a clean state. Second, when running containers together in a Pod it is often necessary to share files between those containers.
+ Consequently, a volume outlives any containers that run within the Pod, and data is preserved across Container restarts. Of course, when a Pod ceases to exist, the volume will cease to exist, too. Perhaps more importantly than this, Kubernetes supports many type of volumes, and a Pod can use any number of them simultaneously.
    * Types of Volumes
        + emptyDir
        + hostPath
        + gcePersistentDisk
        + awsElasticBlockStore
        + nfs
        + iscsi
        + flocker
        + glusterfs
        + rbd
        + cephfs
        + gitRepo
        + secret
        + persistentVolumeClaim
        + downwardAPI
        + azureFileVolume
        + azureDisk
        + vsphereVolume
        + Quobyte
    * Using subPath
        + Sometimes, it is useful to share one volume for multiple uses in a single pod. The volumeMounts.subPath property can be used to specify a sub-path inside the referenced volume instead of its root.

- Persistent Volumes
+ A PersistentVolume (PV) is a piece of networked storage in the cluster that has been provisioned by an administrator. 
+ A PersistentVolumeClaim (PVC) is a request for storage by a user. It is similar to a pod. Pods consume node resources and PVCs consume PV resources. 
+ While PersistentVolumeClaims allow a user to consume abstract storage resources, it is common that users need PersistentVolumes with varying properties, such as performance, for different problems. 
+ A StorageClass provides a way for administrators to describe the “classes” of storage they offer. Different classes might map to quality-of-service levels, or to backup policies, or to arbitrary policies determined by the cluster administrators

- Lifecycle of a volume and claim
+ PVs are resources in the cluster. PVCs are requests for those resources and also act as claim checks to the resource. The interaction between PVs and PVCs follows this lifecycle:
+ Provisioning : There are two ways PVs may be provisioned: statically or dynamically. 
    + Static
        + A cluster administrator creates a number of PVs. They carry the details of the real storage which is available for use by cluster users. They exist in the Kubernetes API and are available for consumption.
    + Dynamic
        + When none of the static PVs the administrator created matches a user’s PersistentVolumeClaim, the cluster may try to dynamically provision a volume specially for the PVC. This provisioning is based on StorageClasses: the PVC must request a class and the administrator must have created and configured that class in order for dynamic provisioning to occur. Claims that request the class "" effectively disable dynamic provisioning for themselves.
+ Binding
    + A user creates, or has already created in the case of dynamic provisioning, a PersistentVolumeClaim with a specific amount of storage requested and with certain access modes. A control loop in the master watches for new PVCs, finds a matching PV (if possible), and binds them together. If a PV was dynamically provisioned for a new PVC, the loop will always bind that PV to the PVC. Otherwise, the user will always get at least what they asked for, but the volume may be in excess of what was requested. Once bound, PersistentVolumeClaim binds are exclusive, regardless of the mode used to bind them.

    + Claims will remain unbound indefinitely if a matching volume does not exist. Claims will be bound as matching volumes become available. For example, a cluster provisioned with many 50Gi PVs would not match a PVC requesting 100Gi. The PVC can be bound when a 100Gi PV is added to the cluster.
+ Using
    + Pods use claims as volumes. The cluster inspects the claim to find the bound volume and mounts that volume for a pod. For volumes which support multiple access modes, the user specifies which mode desired when using their claim as a volume in a pod.

    + Once a user has a claim and that claim is bound, the bound PV belongs to the user for as long as they need it. Users schedule Pods and access their claimed PVs by including a persistentVolumeClaim in their Pod’s volumes block. See below for syntax details.
+ Releasing
    + When a user is done with their volume, they can delete the PVC objects from the API which allows reclamation of the resource. The volume is considered “released” when the claim is deleted, but it is not yet available for another claim. The previous claimant’s data remains on the volume which must be handled according to policy.
+ Reclaiming
    + The reclaim policy for a PersistentVolume tells the cluster what to do with the volume after it has been released of its claim. Currently, volumes can either be Retained, Recycled or Deleted. Retention allows for manual reclamation of the resource. For those volume plugins that support it, deletion removes both the PersistentVolume object from Kubernetes, as well as deleting the associated storage asset in external infrastructure (such as an AWS EBS, GCE PD, Azure Disk, or Cinder volume). Volumes that were dynamically provisioned are always deleted.
    + Recycling
    + If supported by appropriate volume plugin, recycling performs a basic scrub (rm -rf /thevolume/*) on the volume and makes it available again for a new claim.

- Access mode
+ The access modes are:
    + ReadWriteOnce – the volume can be mounted as read-write by a single node
    + ReadOnlyMany – the volume can be mounted read-only by many nodes
    + ReadWriteMany – the volume can be mounted as read-write by many nodes
+ Important! A volume can only be mounted using one access mode at a time, even if it supports many. 

- 
