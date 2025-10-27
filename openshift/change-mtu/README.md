# Change cluster MTU for HCP on OCP-V

**Official Doc:** https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/advanced_networking/changing-cluster-network-mtu#nw-cluster-mtu-change_changing-cluster-network-mtu


1. Show wich interface you need to change
```
oc debug node/<node_name> -- chroot /host nmcli -g connection.interface-name c show ovs-if-phys0
```

2. Create your conf file with your specific interface
```
[connection-eno49-mtu]
match-device=interface-name:eno49
ethernet.mtu=9100
```

3. Create your butane control-plane-interface.bu
```
variant: openshift
version: 4.19.0
metadata:
  name: 01-control-plane-interface
  labels:
    machineconfiguration.openshift.io/role: master
storage:
  files:
    - path: /etc/NetworkManager/conf.d/99-eno49-mtu.conf 
      contents:
        local: eno49-mtu.conf 
      mode: 0600
```

4. Create your butane worker-interface.bu
```
variant: openshift
version: 4.19.0
metadata:
  name: 01-worker-interface
  labels:
    machineconfiguration.openshift.io/role: worker
storage:
  files:
    - path: /etc/NetworkManager/conf.d/99-eno49-mtu.conf 
      contents:
        local: eno49-mtu.conf 
      mode: 0600
```

5. Generate your MachineConfig files with butane
```
for manifest in control-plane-interface worker-interface; do
    butane --files-dir . $manifest.bu > $manifest.yaml
done
```

> [!WARNING]  
> Do not apply new MachineConfig right now


6. Begin the migration process
```
oc patch Network.operator.openshift.io cluster --type=merge --patch \
  '{"spec": { "migration": { "mtu": { "network": { "from": 1400, "to": 9000 } , "machine": { "to" : 9100 } } } } }'
```
> [!WARNING]  
> Wait all nodes are totaly updated

7. Apply MachineConfig files
```
for manifest in control-plane-interface worker-interface; do
    oc create -f $manifest.yaml
  done
```
> [!WARNING]  
> Wait all nodes are totaly updated

8. Finalize migration porcess
```
oc patch Network.operator.openshift.io cluster --type=merge --patch \
  '{"spec": { "migration": null, "defaultNetwork":{ "ovnKubernetesConfig": { "mtu": 9000 }}}}'
```