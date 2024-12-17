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







# HCP + External OCP-V

**Source :** https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html/hosted_control_planes/deploying-hosted-control-planes#hcp-virt-create-hc-ext-infra_hcp-deploy-virt

## What you need

1. Create dedicated namesapce on target cluster
```
oc create ns hcp-external
```

2. Create a SA account with cluster admin role

3. Extract kubeconfig from target cluster with SA account
```
oc login --server=api.example.com:6443 --token=$TOKEN --kubeconfig=/tmp/serviceaccount-kubeconfig 
```

4. Create cluster from ACM cluster
```
hcp create cluster kubevirt \
  --name hcp02 \
  --node-pool-replicas 3 \
  --pull-secret pull.txt \
  --memory 8Gi \
  --cores 4 \
  --infra-namespace=hcp-external \
  --infra-kubeconfig-file=sa.kubeconfig
```