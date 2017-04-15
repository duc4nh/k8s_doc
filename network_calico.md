http://docs.iorchard.co.kr/kubic/k8s_tls_howto
http://www.dasblinkenlichten.com/kubernetes-authentication-plugins-and-kubeconfig/

http://docs.projectcalico.org/v2.1/getting-started/kubernetes/installation/integration

export KUBECONFIG=/var/lib/kubelet/kubeconfig
export MINION=$(hostname)
export TOKEN=EqK0vssaxHH5obY0OpPdvGqrbfEmgQU1
export CLUSTER=default-cluster
export MASTER=10.3.105.186
sudo rm -f ${KUBECONFIG}
sudo kubectl config --kubeconfig=${KUBECONFIG} set-cluster ${CLUSTER} --server=https://${MASTER}:6443 --certificate-authority=/srv/kubernetes/ca.crt --embed-certs=true
sudo kubectl config --kubeconfig=${KUBECONFIG} set-credentials kubelet --client-certificate=/srv/kubernetes/${MINION}.crt --client-key=/srv/kubernetes/${MINION}.key - embed-certs=true   --token=${TOKEN}
sudo kubectl config --kubeconfig=${KUBECONFIG} set-context kubelet-context --cluster=${CLUSTER} --user=kubelet
sudo kubectl config --kubeconfig=${KUBECONFIG} use-context kubelet-context