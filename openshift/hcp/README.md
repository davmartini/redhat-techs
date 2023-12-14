# OCP on OCP with HCP and OCP Virt

## What you need

1. vars.hcp file to store your custer variables
2. Your OpenShift Pull Secret
3. Your SSH public key
4. **deploy-hcp-cluster.sh** to automate deployment

## Create new node pool

```
hcp create nodepool  kubevirt --name=test --cluster-name=hcp01 --cores=2 --node-count=3 
```