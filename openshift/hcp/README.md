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







# HCP + OCP-V + VLAN

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


## HCP customized deployment 

### HCP for OCP-V documentation
```
hcp create cluster kubevirt -h
Creates basic functional HostedCluster resources on KubeVirt platform

Usage:
  hcp create cluster kubevirt [flags]

Flags:
      --additional-network stringArray                   Specify additional network that should be attached to the nodes, the "name" field should point to a multus network attachment definition with the format "[namespace]/[name]", it can be specified multiple times to attach to multiple networks. Supported parameters: name:string, example: "name:ns1/nad-foo
      --attach-default-network                           Specify if the default pod network should be attached to the nodes. This can only be set if --additional-network is configured (default true)
      --cores uint32                                     The number of cores inside the vmi, Must be a value greater or equal 1 (default 2)
  -h, --help                                             help for kubevirt
      --host-device-name stringArray                     PCI device name to expose from the infra cluster to the guest cluster nodes. Can be specified multiple times for different device names. Example: <device-name>,count:3. count is optional and the default is 1.
      --infra-kubeconfig-file string                     Path to a kubeconfig file of an external infra cluster to be used to create the guest clusters nodes onto
      --infra-namespace string                           The namespace in the external infra cluster that is used to host the KubeVirt virtual machines. The namespace must exist prior to creating the HostedCluster
      --infra-storage-class-mapping stringArray          KubeVirt CSI mapping of an infra StorageClass to a guest cluster StorageCluster. Mapping is structured as <infra storage class>/<guest storage class>. Example, mapping the infra storage class ocs-storagecluster-ceph-rbd to a guest storage class called ceph-rdb. --infra-storage-class-mapping=ocs-storagecluster-ceph-rbd/ceph-rdb. Group storage classes and volumesnapshot classes by adding ,group=<group name>
      --infra-volumesnapshot-class-mapping stringArray   KubeVirt CSI mapping of an infra VolumeSnapshotClass to a guest cluster VolumeSnapshotCluster. Mapping is structured as <infra volume snapshot class>/<guest volume snapshot class>. Example, mapping the infra volume snapshot class ocs-storagecluster-rbd-snap to a guest volume snapshot class called rdb-snap. --infra-volumesnapshot-class-mapping=ocs-storagecluster-rbd-snap/rdb-snap. Group storage classes and volumesnapshot classes by adding ,group=<group name>
      --memory string                                    The amount of memory which is visible inside the Guest OS (type BinarySI, e.g. 5Gi, 100Mi) (default "4Gi")
      --network-multiqueue string                        If "Enable", virtual network interfaces configured with a virtio bus will also enable the vhost multiqueue feature for network devices. supported values are "Enable" and "Disable"; default = "Enable" (default "Enable")
      --qos-class string                                 If "Guaranteed", set the limit cpu and memory of the VirtualMachineInstance, to be the same as the requested cpu and memory; supported values: "Burstable" and "Guaranteed" (default "Burstable")
      --root-volume-access-modes string                  The access modes of the root volume to use for machines in the NodePool (comma-delimited list)
      --root-volume-cache-strategy string                Set the boot image caching strategy; Supported values:
                                                         - "None": no caching (default).
                                                         - "PVC": Cache into a PVC; only for QCOW image; ignored for container images
      --root-volume-size uint32                          The size of the root volume for machines in the NodePool in Gi (default 32)
      --root-volume-storage-class string                 The storage class to use for machines in the NodePool
      --root-volume-volume-mode string                   The volume mode of the root volume to use for machines in the NodePool. Supported values are "Block", "Filesystem"
      --vm-node-selector stringToString                  A comma separated list of key=value pairs to use as the node selector for the KubeVirt VirtualMachines to be scheduled onto. (e.g. role=kubevirt,size=large) (default [])

Global Flags:
      --additional-trust-bundle string              Path to a file with user CA bundle
      --annotations stringArray                     Annotations to apply to the hostedcluster (key=value). Can be specified multiple times.
      --arch string                                 The default processor architecture for the NodePool (e.g. arm64, amd64) (default "amd64")
      --auto-repair                                 Enables machine autorepair with machine health checks
      --base-domain string                          The ingress base domain for the cluster
      --base-domain-prefix string                   The ingress base domain prefix for the cluster, defaults to cluster name. Use 'none' for an empty prefix
      --cluster-cidr stringArray                    The CIDR of the cluster network. Can be specified multiple times. (default [10.132.0.0/14])
      --control-plane-availability-policy string    Availability policy for hosted cluster components. Supported options: SingleReplica, HighlyAvailable (default "HighlyAvailable")
      --default-dual                                Defines the Service and Cluster CIDRs as dual-stack default values. Cannot be defined with service-cidr or cluster-cidr flag.
      --etcd-storage-class string                   The persistent volume storage class for etcd data volumes
      --external-dns-domain string                  Sets hostname to opinionated values in the specificed domain for services with publishing type LoadBalancer or Route.
      --fips                                        Enables FIPS mode for nodes in the cluster
      --generate-ssh                                If true, generate SSH keys
      --image-content-sources string                Path to a file with image content sources
      --infra-availability-policy string            Availability policy for infrastructure services in guest cluster. Supported options: SingleReplica, HighlyAvailable
      --infra-id string                             Infrastructure ID to use for hosted cluster resources.
      --name string                                 A name for the cluster (default "example")
      --namespace string                            A namespace to contain the generated resources (default "clusters")
      --network-type string                         Enum specifying the cluster SDN provider. Supports either Calico, OVNKubernetes, OpenShiftSDN or Other. (default "OVNKubernetes")
      --node-drain-timeout duration                 The NodeDrainTimeout on any created NodePools
      --node-pool-replicas int32                    If 0 or greater, creates a nodepool with that many replicas; else if less than 0, does not create a nodepool.
      --node-selector stringToString                A comma separated list of key=value to use as node selector for the Hosted Control Plane pods to stick to. E.g. role=cp,disk=fast (default [])
      --node-upgrade-type UpgradeType               The NodePool upgrade strategy for how nodes should behave when upgraded. Supported options: Replace, InPlace
      --node-volume-detach-timeout duration         The NodeVolumeDetachTimeout on any created NodePools
      --olm-catalog-placement OLMCatalogPlacement   The OLM Catalog Placement for the HostedCluster. Supported options: Management, Guest (default management)
      --olm-disable-default-sources                 Disables the OLM default catalog sources for the HostedCluster.
      --pausedUntil string                          If a date is provided in RFC3339 format, HostedCluster creation is paused until that date. If the boolean true is provided, HostedCluster creation is paused until the field is removed.
      --pull-secret string                          File path to a pull secret.
      --release-image string                        The OCP release image for the cluster
      --release-stream string                       The OCP release stream for the cluster (e.g. 4-stable-multi), this flag is ignored if release-image is set
      --render                                      Render output as YAML to stdout instead of applying
      --render-into string                          Render output as YAML into this file instead of applying. If unset, YAML will be output to stdout.
      --render-sensitive                            enables rendering of sensitive information in the output
      --service-cidr stringArray                    The CIDR of the service network. Can be specified multiple times. (default [172.31.0.0/16])
      --ssh-key string                              Path to an SSH key file
      --timeout duration                            If the --wait flag is set, set the optional timeout to limit the waiting duration. The format is duration; e.g. 30s or 1h30m45s; 0 means no timeout; default = 0
      --toleration stringArray                      A comma separated list of options for a toleration that will be applied to the hcp pods. Valid options are, key, value, operator, effect, tolerationSeconds. E.g. key=node-role.kubernetes.io/master,operator=Exists,effect=NoSchedule. Can be specified multiple times to add multiple tolerations
      --wait               
```



### HCP cluster with dedicated storageclass and external network 

1. Create HCP cluster
```
hcp create cluster kubevirt \
  --name hcp04 \
  --pull-secret pull-secret \
  --memory 16Gi \
  --cores 4 \
  --etcd-storage-class ocs-storagecluster-ceph-rbd \
  --root-volume-storage-class ocs-storagecluster-ceph-rbd-virtualization \
  --root-volume-size 50 \
  --root-volume-access-modes ReadWriteMany \
  --root-volume-volume-mode Block \
  --qos-class Guaranteed \
  --attach-default-network=false \
  --additional-network name:clusters-hcp04/vlan82 \
  --base-domain redhat.hpecic.net \
  --cluster-cidr 10.136.0.0/14 \
  --service-cidr 172.31.0.0/16 \
  --control-plane-availability-policy HighlyAvailable \
  --infra-availability-policy HighlyAvailable \
  --node-pool-replicas 3 \
  --node-upgrade-type Replace \
  --auto-repair \
  --release-image quay.io/openshift-release-dev/ocp-release:4.17.7-multi
```

2. Add NAD for external VLAN
```
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: vlan82
  namespace: clusters-hcp04
spec:
  config: |-
    {
            "cniVersion": "0.3.1", 
            "name": "vlan82", 
            "type": "ovn-k8s-cni-overlay", 
            "topology": "localnet", 
            "netAttachDefName": "clusters-hcp04/vlan82" 
    }
```



# HCP + OCP-V + UDN

1. Create Namespace
```
apiVersion: v1
kind: Namespace
metadata:
  name: clusters-hcp02
  labels:
    k8s.ovn.org/primary-user-defined-network: ""
```

2. Create UDN
```
apiVersion: k8s.ovn.org/v1
kind: UserDefinedNetwork
metadata:
  name: udn-l2
  namespace: clusters-hcp02
spec:
  topology: Layer2
  layer2:
    role: Primary
    subnets:
      - "192.168.1.0/24"
    ipam:
      lifecycle: Persistent
```

3. Create HCP cluster
```
hcp create cluster kubevirt \
  --name hcp02 \
  --pull-secret pull-secret \
  --memory 8Gi \
  --cores 2 \
  --etcd-storage-class ocs-storagecluster-ceph-rbd \
  --root-volume-storage-class ocs-storagecluster-ceph-rbd-virtualization \
  --root-volume-size 50 \
  --root-volume-access-modes ReadWriteMany \
  --root-volume-volume-mode Block \
  --qos-class Guaranteed \
  --attach-default-network=false \
  --additional-network name:clusters-hcp02/udn-l2 \
  --base-domain redhat.hpecic.net \
  --cluster-cidr 10.136.0.0/14 \
  --service-cidr 172.31.0.0/16 \
  --control-plane-availability-policy HighlyAvailable \
  --infra-availability-policy HighlyAvailable \
  --node-pool-replicas 3 \
  --node-upgrade-type Replace \
  --auto-repair \
  --release-image quay.io/openshift-release-dev/ocp-release:4.17.7-multi
```