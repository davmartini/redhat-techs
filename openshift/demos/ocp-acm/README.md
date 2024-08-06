# Demo scenario for ACM

## URLs

**HUB Cluster :** https://console-openshift-console.apps.ocp.drkspace.fr/  
**HPE vSphere :** https://hitvcenter6.hybridit.hpecic.net/  
**ACM HPE CIC :** https://multicloud-console.apps.ocp1.redhat.hpecic.net/multicloud/welcome  
**Bastion HPE CIC :** ssh root@10.6.80.10  


## Steps

### 1. Navigate OperatorHub on HUB cluster to show ACM operator installed

### 2. Navigate on RHACM console
    - Overview
    - Cluster creation
    - Import cluster
    - Upgrade cluster

### 3. Create a cluster on VMWare on HPE CIC
```
API : 10.6.82.117 -  api.dm01.redhat.hpecic.net
APPS : 10.6.82.118 - *.apps.dm01.redhat.hpecic.net
Network: Openshift
```

### 4. Show observability stack

### 5. Search stack
    - nodes:>=3
    - kubernetesVersion
    - Kind:pod stats:Error
    - Namespace:openshift-cnv
    - image:debian


### 6. Governance stack
    - Deploy a policy
    - **GIT :** https://github.com/davmartini/lab_platform
    - **Policy name :** policy-edb-operator.yaml
    - **Command :** oc apply -f policy-edb-operator.yaml -n acm-policies-ns
    - Delete manually operators to see force install

### 7. Create an application
    - **GIT :** https://github.com/davmartini/lab_platform




