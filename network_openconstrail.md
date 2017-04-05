# 1.Overview of OpenContrail
## 1.1  Use Cases

Được sử dụng chính trong các use case sau 
```
Cloud Networking – Private clouds for Enterprises or Service Providers, Infrastructure as a Service (IaaS) and Virtual Private Clouds (VPCs) for Cloud Service Providers
Network Function Virtualization (NFV) in Service Provider Network – This provides Value Added Services (VAS) for Service Provider edge networks such as business edge networks, broadband subscriber management edge networks, and mobile edge networks.
```

## 1.2  OpenContrail Controller and the vRouter
```
The OpenContrail System bao gồm 2 thành phần chính : OpenContrail Controller và the OpenContrail vRouter
The OpenContrail Controller is a logically centralized but physically distributed Software Defined Networking (SDN) controller that is responsible for providing the management, control, and analytics functions of the virtualized network.
The OpenContrail Controller is a logically centralized but physically distributed Software Defined Networking (SDN) controller that is responsible for providing the management, control, and analytics functions of the virtualized network.
```

## 1.3  Virtual Networks
```
Virtual networks are used to replace VLAN-based isolation and provide multi-tenancy in a virtualized data center. Each tenant or an application can have one or more virtual networks. Each virtual network is isolated from all the other virtual networks unless explicitly allowed by security policy.

Virtual networks can be connected to, and extended across physical Multi-Protocol Label Switching (MPLS) Layer 3 Virtual Private Networks (L3VPNs) and Ethernet Virtual Private Networks (EVPNs) networks using a datacenter edge router.
```

## 1.4  Overlay Networking
```
Virtual networks can be implemented using a variety of mechanisms. For example, each virtual network could be implemented as a Virtual Local Area Network (VLAN), Virtual Private Networks (VPNs), etc.

Virtual Networks can also be implemented using two networks – a physical underlay network and a virtual overlay network. 

The role of the physical underlay network is to provide an “IP fabric” – its responsibility is to provide unicast IP connectivity from any physical device (server, storage device, router, or switch) to any other physical device. An ideal underlay network provides uniform low-latency, non-blocking, high-bandwidth connectivity from any point in the network to any other point in the network.

The vRouters running in the hypervisors of the virtualized servers create a virtual overlay network on top of the physical underlay network using a mesh of dynamic “tunnels” amongst themselves. In the case of OpenContrail these overlay tunnels can be MPLS over GRE/UDP tunnels, or VXLAN tunnels.

The underlay physical routers and switches do not contain any per-tenant state: they do not contain any Media Access Control (MAC) addresses, IP address, or policies for virtual machines. The forwarding tables of the underlay physical routers and switches only contain the IP prefixes or MAC addresses of the physical servers. Gateway routers or switches that connect a virtual network to a physical network are an exception – they do need to contain tenant MAC or IP addresses.
```

## 1.5  Overlays based on MPLS L3VPNs and EVPNs
```
Each of the many processes of a router or switch can be assigned to one of three conceptual planes of operation:
Forwarding Plane - Moves packets from input to output
Control Plane - Determines how packets should be forwarded
Management Plane - Methods of configuring the control plane (CLI, SNMP, etc.)

For example, you might SSH into the CLI of a router (the management plane) and configure EIGRP to exchange routing information with neighbors (the control plane), which gets installed into its local CEF table (the forwarding plane).


The OpenContrail System is inspired by and conceptually very similar to standard MPLS L3VPNs (for L3 overlays) and MPLS EVPNs (for L2 overlays).

In the data plane, OpenContrail supports MPLS over GRE, a data plane encapsulation that is widely supported by existing routers from all major vendors. OpenContrail also supports other data plane encapsulation standards such as MPLS over UDP (better multi-pathing and CPU utilization) and VXLAN. Additional encapsulation standards such as NVGRE can easily be added in future releases.

The control plane protocol between the control plane nodes of the OpenContrail system or a physical gateway router (or switch) is BGP (and Netconf for management). This is the exact same control plane protocol that is used for MPLS L3VPNs and MPLS EVPNs.

The protocol between the OpenContrail controller and the OpenContrail vRouters is based on XMPP [ietf-xmpp-wg]. The schema of the messages exchanged over XMPP is described in an IETF draft [draft-ietf-l3vpn-end-system] and this protocol, while syntactically different, is semantically very similar to BGP.
```

## 1.6  OpenContrail and Open Source
```
The OpenContrail System is integrated with open source hypervisors such as Kernel-based Virtual Machines (KVM) and Xen.
The OpenContrail System is integrated with open source virtualization orchestration systems such as OpenStack and CloudStack.
The OpenContrail System is integrated with open source physical server management systems such as chef, puppet, cobbler, and ganglia.
```

## 1.7 Scale-Out Architecture and High Availability
```
Physically distributed means that the OpenContrail Controller consists of multiple types of nodes, each of which can have multiple instances for high availability and horizontal scaling. Those node instances can be physical servers or virtual machines. For minimal deployments, multiple node types can be combined into a single server. There are three types of nodes:

Configuration nodes are responsible for the management layer. The configuration nodes provide a north-bound Representational State Transfer (REST) Application Programming Interface (API) that can be used to configure the system or extract operational status of the system. 

Control nodes implement the logically centralized portion of the control plane. Not all control plane functions are logically centralized – some control plane functions are still implemented in a distributed fashion on the physical and virtual routers and switches in the network. 

Analytics nodes are responsible for collecting, collating and presenting analytics information for trouble shooting problems and for understanding network usage. Each component of the OpenContrail System generates detailed event records for every significant event in the system.
```

## 1.8 The Central Role of Data Models: SDN as a Compiler
```
There are two types of data models: the high-level service data model and the low-level technology data model. Both data models are described using a formal data modeling language that is currently based on an IF-MAP XML schema although YANG is also being considered as a future possible modeling language.

The high-level service data model describes the desired state of the network at a very high level of abstraction, using objects that map directly to services provided to end-users – for example, a virtual network, or a connectivity policy, or a security policy.

The low-level technology data model describes the desired state of the network at a very low level of abstraction, using objects that map to specific network protocol constructs such as for example a BGP route-target, or a VXLAN network identifier.

The configuration nodes are responsible for transforming any change in the high-level service data model to a corresponding set of changes in the low-level technology data model. This is conceptually similar to a Just In Time (JIT) compiler – hence the term “SDN as a compiler” is sometimes used to describe the architecture of the OpenContrail System.
```


## 1.9  North-Bound Application Programming Interfaces
```
The configuration nodes in the OpenContrail Controller provide a northbound Representational State Transfer (REST) Application Programming Interface (API) to the provisioning or orchestration system. This northbound REST APIs are automatically generated from the formal high-level data model.
```

### 1.10  Graphical User Interface
```
The OpenContrail System also provides a Graphical User Interface (GUI). This GUI is built entirely using the REST APIs described earlier and this ensures that there is no lag in APIs.
```

### 1.11   An Extensible Platform
```

```