# Configure BGP OpenShift for CUDN

## OpenShift Side

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

## VyOS Side

1. Basic configuration
```
configure
set interfaces ethernet eth0 address 10.6.187.9/24
set system time-zone Europe/Paris
set service ntp server 10.11.0.10
set service ssh port 22
commit
save
```

2. Configure BGP
```
configure
set protocols bgp system-as 64512
set protocols bgp neighbor 10.6.187.14 remote-as 64512
set protocols bgp neighbor 10.6.187.14 description worker-1.rh.hpecic.net
set protocols bgp neighbor 10.6.187.14 capability dynamic
set protocols bgp neighbor 10.6.187.14 address-family ipv4-unicast

set protocols bgp neighbor 10.6.187.15 remote-as 64512
set protocols bgp neighbor 10.6.187.15 description worker-2.rh.hpecic.net
set protocols bgp neighbor 10.6.187.15 capability dynamic
set protocols bgp neighbor 10.6.187.15 address-family ipv4-unicast

set protocols bgp neighbor 10.6.187.16 remote-as 64512
set protocols bgp neighbor 10.6.187.16 description worker-3.rh.hpecic.net
set protocols bgp neighbor 10.6.187.16 capability dynamic
set protocols bgp neighbor 10.6.187.16 address-family ipv4-unicast

set protocols bgp neighbor 10.6.187.17 remote-as 64512
set protocols bgp neighbor 10.6.187.17 description worker-4.rh.hpecic.net
set protocols bgp neighbor 10.6.187.17 capability dynamic
set protocols bgp neighbor 10.6.187.17 address-family ipv4-unicast

commit
save
```


1. show ip bgp summary
```
vyos@vmroute01:~$ show ip bgp summary 

IPv4 Unicast Summary (VRF default):
BGP router identifier 10.6.187.9, local AS number 64512 vrf-id 0
BGP table version 26
RIB entries 1, using 96 bytes of memory
Peers 5, using 101 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.6.187.14     4      64512     70603     70588       26    0    0 01w2d21h            1        0 worker-1.rh.hpecic.n
10.6.187.15     4      64512     70614     70596       26    0    0 01w2d21h            1        0 worker-2.rh.hpecic.n
10.6.187.16     4      64512     70611     70599       26    0    0 01w3d00h            1        0 worker-3.rh.hpecic.n
10.6.187.17     4      64512     70610     70596       26    0    0 01w3d00h            1        0 worker-4.rh.hpecic.n
```

2. show ip bgp
```
vyos@vmroute01:~$ show ip bgp
BGP table version is 26, local router ID is 10.6.187.9, vrf id 0
Default local pref 100, local AS 64512
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

    Network          Next Hop            Metric LocPrf Weight Path
 *=i192.168.1.0/24   10.6.187.15              0    100      0 i
 *=i                 10.6.187.17              0    100      0 i
 *=i                 10.6.187.14              0    100      0 i
 *>i                 10.6.187.16              0    100      0 i
```