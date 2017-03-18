# Install
yum list installed clusterhq-release || yum install -y https://clusterhq-archive.s3.amazonaws.com/centos/clusterhq-release$(rpm -E %dist).noarch.rpm
yum install -y clusterhq-flocker-node

## k8s-master:
```
mkdir /etc/flocker

cd /home/hoannv/flocker/
flocker-ca initialize k8s-flocker
flocker-ca create-control-certificate  k8s-master
scp control-k8s-master.* cluster.crt /etc/flocker/

cd /etc/flocker/
mv control-k8s-master.crt control-service.crt
mv control-k8s-master.key control-service.key

chmod 0700 /etc/flocker
chmod 0600 /etc/flocker/control-service.key

cd /home/hoannv/flocker/
flocker-ca create-node-certificate

scp 6126c86c-4fb4-445c-b966-1123514e8733.* cluster.crt k8s-minion1:/etc/flocker
scp 6126c86c-4fb4-445c-b966-1123514e8733.* cluster.crt k8s-minion2:/etc/flocker
```

## k8s-minion{1..2}
```
mv 6126c86c-4fb4-445c-b966-1123514e8733.crt node.crt
mv 6126c86c-4fb4-445c-b966-1123514e8733.key node.key
chmod 0700 /etc/flocker
chmod 0600 /etc/flocker/node.key
```

# Generating an API Client Certificate
k8s-master
```
flocker-ca create-api-certificate hoannv-flocker
scp hoannv-flocker.* k8s-minion1:/home/hoannv/
scp hoannv-flocker.* k8s-minion2:/home/hoannv/
```

# Enabling the Flocker Control Service
## k8s-master
```
systemctl enable flocker-control
systemctl start flocker-control
```

## k8s-minon
```
curl --cacert /etc/flocker/cluster.crt --cert /home/hoannv/hoannv-flocker.crt --key /home/hoannv/hoannv-flocker.key https://k8s-master:4523/v1/configuration/containers
```

# Configuring the Nodes and Storage Backends
##k8s-master
```
install repo openvstorage
wget ftp://bo.mirror.garr.it/1/centos/7.3.1611/cloud/x86_64/openstack-liberty/common/zeromq-4.0.5-4.el7.x86_64.rpm
rpm -Uvh zeromq-4.0.5-4.el7.x86_64.rpm
yum install blktap-utils.x86_64 blktap.x86_64 kmod-blktap.x86_64
```

##k8s-minion
```
vi /etc/flocker/agent.yml

"version": 1
"control-service":
   "hostname": "k8s-master"
   "port": 4524

# The dataset key below selects and configures a dataset backend (see below: aws/openstack/etc).
# All nodes will be configured to use only one backend

"dataset":
    "backend": "openvstorage_flocker_plugin"
    "vpool_conf_file": "/opt/OpenvStorage/config/storagedriver/storagedriver/.json


scp  /etc/flocker/agent.yml k8s-minion2:/etc/flocker/
```