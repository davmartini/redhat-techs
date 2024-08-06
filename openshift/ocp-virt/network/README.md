# OpenShift Virtualizaztion Network


## Description
MULTUS configuration to provide VLAN access to OpenShift Virtualiaztion VMs

## One interface with VLAN in access mode

1. Create NodeNetworkConfigurationPolicy to deploy configuration on OpenShift worker nodes: 

```
apiVersion: nmstate.io/v1
kind: NodeNetworkConfigurationPolicy
metadata:
  name: br1-eno49-policy
spec:
  desiredState:
    interfaces:
      - bridge:
          options:
            stp:
              enabled: false
          port:
            - name: eno49
        description: Linux bridge with eno49 as a port
        ipv4:
          enabled: false
        name: br1
        state: up
        type: linux-bridge
```

2. Attach network to a specific namespace 

```
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: vms-bridge
  namespace: vms
spec:
  config: '{
    "name":"vms-bridge",
    "type":"cnv-bridge",
    "cniVersion":"0.3.1",
    "bridge":"br1",
    "macspoofchk":true,
    "ipam":{},
    "preserveDefaultVlan":false
  }'
```

## BOND with multiple interfaces with VLAN in trunk mode (Option 1 - VLAN option in NetworkAttachmentDefinition ressource)

1. Create NodeNetworkConfigurationPolicy to deploy configuration on OpenShift worker nodes: 

```
apiVersion: nmstate.io/v1
kind: NodeNetworkConfigurationPolicy
metadata:
  name: bond0-br0-policy
spec:
  desiredState:
    interfaces:
    - name: bond0
      type: bond
      state: up
      ipv4:
        dhcp: false
        enabled: false
      link-aggregation:
        mode: balance-rr
        options:
          miimon: '140'
        port:
        - ens1
        - ens3
    - name: br1
      description: br0 with bond0
      type: linux-bridge
      ipv4
        enabled: false
      bridge:
        options:
          stp:
            enabled: false
        port:
          - name: bond0
```

2. Attach network to a specific namespace and vlan 

```
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: vms-bridge-1085
  namespace: vms
spec:
  config: '{
    "name":"vms-bridge-1085",
    "type":"cnv-bridge",
    "cniVersion":"0.3.1",
    "bridge":"br0",
    "macspoofchk":true,
    "vlan": 1085,
    "preserveDefaultVlan":false
  }'
```


## BOND with multiple interfaces with VLAN in trunk mode (Option 2 - VLAN option in NodeNetworkConfigurationPolicy ressource)

1. Create NodeNetworkConfigurationPolicy to deploy configuration on OpenShift worker nodes: 

```
apiVersion: nmstate.io/v1
kind: NodeNetworkConfigurationPolicy
metadata:
  name: vlan-1085-bond0
spec:
  desiredState:
    interfaces:
    - name: bond0
      type: bond
      state: up
      ipv4:
        dhcp: true
        enabled: true
      link-aggregation:
        mode: balance-rr
        options:
          miimon: '140'
        port:
        - ens1
        - ens3
    - name: bond0.1085
      type: vlan
      state: up
      ipv4:
        dhcp: true
        enabled: true
      vlan:
        id: 1085
        base-iface: bond0
    - bridge:
        options:
          stp:
            enabled: false
        port:
          - name: bond0.1085
      name: bridge-1085
      description: br with bond0.1085
      type: linux-bridge
      ipv4:
        enabled: false
```

2. Attach network to a specific namespace and vlan 

```
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: vms-bridge-1085
  namespace: vms
spec:
  config: '{
    "name":"vms-bridge-1085",
    "type":"cnv-bridge",
    "cniVersion":"0.3.1",
    "bridge":"bridge-1085",
    "macspoofchk":true
  }'
```

## Enable Multi-network policy

Link : https://docs.openshift.com/container-platform/4.15/networking/multiple_networks/configuring-multi-network-policy.html#nw-multi-network-policy-enable_configuring-multi-network-policy

1. Enable the cluster-wide feature :

```
apiVersion: operator.openshift.io/v1
kind: Network
metadata:
  name: cluster
spec:
  useMultiNetworkPolicy: true
```

```
oc patch network.operator.openshift.io cluster --type=merge --patch-file=multinetwork-enable-patch.yaml
```

2. Add a new policy

```
apiVersion: k8s.cni.cncf.io/v1beta1
kind: MultiNetworkPolicy
metadata:
  name: deny-by-default
  namespace: vms
  annotations:
    k8s.v1.cni.cncf.io/policy-for: vms/vms-bridge-1085
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress: []
```