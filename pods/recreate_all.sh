kubectl create -f skydns-rc.yaml.in
kubectl create -f skydns-svc.yaml
kubectl create -f run-my-nginx.yaml
kubectl create -f nginx-svc.yaml
kubectl create -f busybox.yaml
