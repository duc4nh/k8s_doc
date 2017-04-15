kubectl delete po/busybox
kubectl delete svc/kube-dns -n=kube-system
kubectl delete rc/kube-dns-v20 -n=kube-system
kubectl delete svc/my-nginx
kubectl delete deploy/my-nginx
