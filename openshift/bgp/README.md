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
    advertise: yes
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

3. Enable BGP feature
```
oc patch network.operator cluster --type merge --patch \
'{
   "spec":{
      "additionalRoutingCapabilities":{
         "providers":[
            "FRR"
         ]
      },
      "defaultNetwork":{
         "ovnKubernetesConfig":{
            "routeAdvertisements":"Enabled"
         }
      }
   }
}'
```

4. Create FRRConfiguration
```
apiVersion: frrk8s.metallb.io/v1beta1
kind: FRRConfiguration
metadata:
  name: receive-all
  namespace: openshift-frr-k8s
  labels:
    routeAdvertisements: receive-all
spec:
  bgp:
    routers:
    - asn: 64512
      neighbors:
      - address: 10.6.187.9
        asn: 64512
        disableMP: true
        toReceive:
          allowed:
            mode: all
  nodeSelector:
    matchLabels:
      node-role.kubernetes.io/worker: ''
```

5. Create RouteAdvertisements CR
```
apiVersion: k8s.ovn.org/v1
kind: RouteAdvertisements
metadata:
  name: advertise-cudns
spec:
  advertisements:
  - PodNetwork
  networkSelectors:
  - networkSelectionType: ClusterUserDefinedNetworks
    clusterUserDefinedNetworkSelector:
      networkSelector:
        matchLabels:
          advertise: "yes"
  frrConfigurationSelector:
    matchLabels:
      routeAdvertisements: receive-all
  nodeSelector: {}
```


