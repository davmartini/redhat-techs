# High Availability and Balancing with OpenShift Virtualization

**Doc :** https://docs.redhat.com/en/documentation/workload_availability_for_red_hat_openshift/25.1/html/remediation_fencing_and_maintenance/about-remediation-fencing-maintenance


## VMs High Availability

1. Install Operators

* Install **Node Health Check Operator**
* Install **Self Node Remediation**

2. Create a SelfNodeRemediationTemplate CRD
```
apiVersion: self-node-remediation.medik8s.io/v1alpha1
kind: SelfNodeRemediationTemplate
metadata:
  name: selfnoderemediationtemplate-bm1
  namespace: openshift-workload-availability
spec:
  template:
    spec:
      remediationStrategy: Automatic

```

3. Create a nodehealthcheck CRD

```
apiVersion: remediation.medik8s.io/v1alpha1
kind: NodeHealthCheck
metadata:
  name: nodehealthcheck-bm1
spec:
  minHealthy: 51% 
  remediationTemplate: 
    apiVersion: self-node-remediation.medik8s.io/v1alpha1
    name: selfnoderemediationtemplate-bm1
    namespace: openshift-workload-availability
    kind: SelfNodeRemediationTemplate
    order: 1
    timeout: 30s
  selector: 
    matchExpressions:
      - key: node-role.kubernetes.io/worker
        operator: Exists
  unhealthyConditions: 
    - type: Ready
      status: "False"
      duration: 30s 
    - type: Ready
      status: Unknown
      duration: 30s
```

## VMs Balancing

1. Create dedicated namespace **openshift-kube-descheduler-operator**

2. Install Operator

* Install **Kube Descheduler Operator**

3. Create a **KubeDescheduler** CRD in **automatic** mode and **LongLifecycle** profile
```
apiVersion: operator.openshift.io/v1
kind: KubeDescheduler
metadata:
  name: cluster
  namespace: openshift-kube-descheduler-operator
spec:
  profileCustomizations:
    devEnableEvictionsInBackground: true
  logLevel: Normal
  mode: Automatic
  operatorLogLevel: Normal
  profiles:
    - LongLifecycle
  deschedulingIntervalSeconds: 60
  managementState: Managed
```