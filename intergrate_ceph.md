https://arpnetworks.com/blog/2016/08/26/fixing-ceph-rbd-map-failed-6-no-such-device-or-address.html

I was getting "rbd: map failed fork/exec /usr/bin/rbd: invalid argument" as well. I fixed it by encoding the ceph secret with base64.

So on a ceph-mon:
sudo ceph auth get-key client.admin | base64

and put that value in your ceph-secret.