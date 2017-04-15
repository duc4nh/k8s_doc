kubectl delete statefulsets/mysql
kubectl delete pvc/data-mysql-0
kubectl delete pvc/data-mysql-1
kubectl delete pvc/data-mysql-2
kubectl delete po/mysql-0 --grace-period=0 --force
