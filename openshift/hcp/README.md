# OCP on OCP with HCP and OCP Virt

## What you need

1. vars.hcp file to store your custer variables
2. Your OpenShift Pull Secret
3. Your SSH public key
4. **deploy-hcp-cluster.sh** to automate deployment
5. Configure LB and DNS in case of dedicated ingress

## Create new node pool

```
hcp create nodepool  kubevirt --name=test --cluster-name=hcp01 --cores=2 --node-count=3 
```

## Configure dedicated Ingress

```
hcp create kubeconfig --name $CLUSTER_NAME > $CLUSTER_NAME-kubeconfig
oc --kubeconfig $CLUSTER_NAME-kubeconfig get co
export HTTP_NODEPORT=$(oc --kubeconfig $CLUSTER_NAME-kubeconfig get services -n openshift-ingress router-nodeport-default -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
export HTTPS_NODEPORT=$(oc --kubeconfig $CLUSTER_NAME-kubeconfig get services -n openshift-ingress router-nodeport-default -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
oc apply -f dedicated-lb.yaml
```