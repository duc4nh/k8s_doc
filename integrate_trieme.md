groupadd -r kube-cert
wget https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.5.4/cluster/saltbase/salt/generate-cert/make-ca-cert.sh
bash make-ca-cert.sh 10.3.105.127 IP:10.3.105.127,IP:10.0.0.1,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DN
S:kubernetes.default.svc.cluster.local


http://www.dasblinkenlichten.com/kubernetes-authentication-plugins-and-kubeconfig/

http://docs.iorchard.co.kr/kubic/k8s_tls_howto

http://www.tothenew.com/blog/how-to-install-kubernetes-on-centos/