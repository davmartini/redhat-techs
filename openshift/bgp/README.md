# Configure BGP OpenShift for CUDN

1. Create a namespace
```
kind: Namespace
apiVersion: v1
metadata:
  name: vms-blue
  labels:
    apps: cudn01
    k8s.ovn.org/primary-user-defined-network: ''
```


2. Create a CUDN
```
apiVersion: k8s.ovn.org/v1
kind: ClusterUserDefinedNetwork
metadata:
  labels:
    advertise: true
  name: cudn01
spec:
  namespaceSelector:
    matchLabels:
      apps: cudn01
  network:
    layer2:
      ipam:
        lifecycle: Persistent
      role: Primary
      subnets:
        - 192.168.10.0/24
    topology: Layer2
```