# Tuning OCP

## Set max pod per nodes

1. Get machineconfigpools
```
oc get machineconfigpools
NAME     CONFIG                                             UPDATED   UPDATING   DEGRADED   MACHINECOUNT   READYMACHINECOUNT   UPDATEDMACHINECOUNT   DEGRADEDMACHINECOUNT   AGE
master   rendered-master-9409d199e9de60ffd56ef0ce61a631cf   True      False      False      1              1                   1                     0                      49d
worker   rendered-worker-a2d0aec881ad53de87a94746850caed7   True      False      False      0              0                   0                     0                      49d
```

2. Label machineconfigpool
```
oc label machineconfigpool worker custom-kubelet=max-pods
```

3. Create KubeletConfig file
```
cat max-pods.yaml 
apiVersion: machineconfiguration.openshift.io/v1
kind: KubeletConfig
metadata:
  name: set-max-pods
spec:
  machineConfigPoolSelector:
    matchLabels:
      custom-kubelet: max-pods
  kubeletConfig:
    podsPerCore: 0
    maxPods: 500

oc create -f max-pods.yaml
``` 

4. Check update
```
oc get machineconfigpools
NAME     CONFIG                                             UPDATED   UPDATING   DEGRADED   MACHINECOUNT   READYMACHINECOUNT   UPDATEDMACHINECOUNT   DEGRADEDMACHINECOUNT   AGE
master   rendered-master-9409d199e9de60ffd56ef0ce61a631cf   False     True       False      1              0                   0                     0                      49d
worker   rendered-worker-a2d0aec881ad53de87a94746850caed7   True      False      False      0              0                   0                     0                      49
```

