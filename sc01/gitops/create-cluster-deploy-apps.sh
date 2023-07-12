export SUPERVISOR_CLUSTER='vc01cl01-wcp.h2o-4-8875.h2o.vmware.com'
export USER='administrator@vsphere.local'
export VSPHERENAMESPACE='ns1'

#kubectl config use-context tkg-cluster-services
#kubectl apply -f application.yaml
#kubectl config use-context $VSPHERENAMESPACE
#echo "Waiting for cluster to be ready"
#while kubectl get machineset | grep -i "tanzu-cluster   1          1       1" | wc -l | grep "1"; [ $? -ne 0 ]; do
#  kubectl get machineset
##  sleep 5
#done
#echo "Cluster ready"
#kubectl vsphere login --server $SUPERVISOR_CLUSTER -u $USER --tanzu-kubernetes-cluster-namespace $VSPHERENAMESPACE --tanzu-kubernetes-cluster-name tanzu-cluster --insecure-skip-tls-verify
#kubectl config use-context tanzu-cluster
#kubectl create ns argocd
#kubectl create serviceaccount argocd-robot -n argocd
#kubectl create clusterrolebinding argocd-edit-binding --clusterrole=edit --serviceaccount=argocd:argocd-robot -o yaml --dry-run=client | kubectl apply -f-
ARGOCDSATOKEN=$(kubectl get serviceaccounts argocd-robot -n argocd -o json | jq -r '.secrets[] .name' | xargs -I {} sh -c "kubectl get secret -n argocd -o json {} | jq -r '.data .token'" | base64 -d)
echo "$ARGOCDSATOKEN"
mkdir -p generated/tanzu-cluster
#ytt -f secret-argocd.yaml -v argocdsatoken=$ARGOCDSATOKEN > generated/secret-argocd.yaml
cat <<EOF | kubectl apply  -n argocd -f 
apiVersion: v1
kind: Secret
metadata:
  labels:
    argocd.argoproj.io/secret-type: cluster
  name: sv-tanzu-cluster-argocd
  namespace: argocd
type: Opaque
stringData:
  name: sv-tanzu-cluster-argocd
  namespaces: argocd
  server: https://vc01cl01-wcp.h2o-4-8875.h2o.vmware.com:6443
  config: |
    {
      "bearerToken": "${ARGOCDSATOKEN}",
      "tlsClientConfig": {
        "insecure": true
      }
    }
EOF
kubectl config view -o jsonpath="{.contexts[?(@.name==\"tanzu-cluster\")].context.cluster}"







