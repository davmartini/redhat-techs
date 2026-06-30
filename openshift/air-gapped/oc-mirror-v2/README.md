# OC MIRROR V2

## Red Hat's registry to tar file

1. Push credential
```
mv auth.json /containers/ && chmod 0600 /containers/auth.json
```

2. Create directories
```
mkdir -p /root/mirror /root/cache /root/workspace
```

3. Red Hat to local tar
```
oc-mirror -c /root/ImageSetConfiguration.yaml file:///root/mirror/
```

4. local tar to local registry
```
oc-mirror -c /root/ImageSetConfiguration.yaml --from file:///root/mirror/ docker://quay.vms-airgapped.svc.cluster.local:8443 --v2 --dest-tls-verify=false
```

## Red Hat's registry to local registry

1. Push credential
```
mv auth.json /containers/ && chmod 0600 /containers/auth.json
```

2. Create directories
```
mkdir -p /root/mirror /root/cache /root/workspace
```

3. Red Hat to local tar
```
oc-mirror -c /root/ImageSetConfiguration.yaml --workspace file:///root/mirror/workspace/ docker://quay.vms-airgapped.svc.cluster.local:8443 --v2 --dest-tls-verify=false --cache-dir /root/mirror/cache/ --parallel-images 6 --parallel-layers 4 --authfile /containers/auth.json
```

## List OpenShift Operators

1. List Operator channels
```

[root@bastion-vm ~]# oc-mirror --v2 list operators --catalogs --version=4.21 --authfile /containers/auth.json 
2026/06/30 08:10:56  [INFO]   : 👋 Hello, welcome to oc-mirror
2026/06/30 08:10:56  [INFO]   : ⚙️  setting up the environment for you...
2026/06/30 08:10:56  [INFO]   : ⚙️  environment version: 4.22.0-202606161751.p2.g41d68b1.assembly.stream.el9-41d68b1
Available OpenShift OperatorHub catalogs:
OpenShift 4.21:
registry.redhat.io/redhat/redhat-operator-index:v4.21
registry.redhat.io/redhat/certified-operator-index:v4.21
registry.redhat.io/redhat/community-operator-index:v4.21
registry.redhat.io/redhat/redhat-marketplace-index:v4.21
```

2. List all Operators in a specific channel
```
oc-mirror --v2 list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.21
2026/06/30 08:12:40  [INFO]   : 👋 Hello, welcome to oc-mirror
2026/06/30 08:12:40  [INFO]   : ⚙️  setting up the environment for you...
2026/06/30 08:12:40  [INFO]   : ⚙️  environment version: 4.22.0-202606161751.p2.g41d68b1.assembly.stream.el9-41d68b1
NAME                                            DISPLAY NAME                                             DEFAULT CHANNEL
3scale-operator                                 Red Hat Integration - 3scale                             threescale-2.16
advanced-cluster-management                     Advanced Cluster Management for Kubernetes               release-2.17
agent-sandbox-operator                          Red Hat build of Agent Sandbox                           preview-0.9
amq-broker-rhel8                                Red Hat Integration - AMQ Broker for RHEL 8 (Multiarch)  7.12.x
amq-broker-rhel9                                Red Hat Integration - AMQ Broker for RHEL 9 (Multiarch)  7.14.x
amq-streams                                     Streams for Apache Kafka                                 stable
amq-streams-console                             Streams for Apache Kafka Console                         stable
amq-streams-proxy                               Streams for Apache Kafka Proxy                           stable
amq7-interconnect-operator                      Red Hat Integration - AMQ Interconnect                   1.10.x
ansible-automation-platform-operator            Ansible Automation Platform                              stable-2.7
ansible-cloud-addons-operator                   Ansible Cloud Addons                                     stable-2.5-cluster-scoped
apicast-operator                                Red Hat Integration - 3scale APIcast gateway             threescale-2.16
apicurio-registry-3                             Red Hat build of Apicurio Registry 3                     3.x
authorino-operator                              Authorino Operator                                       stable
aws-efs-csi-driver-operator                     AWS EFS CSI Driver Operator                              stable
...
```

3. List all available versions for a specified operator in a channel
```
oc-mirror --v2 list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.21 --package=kubevirt-hyperconverged --channel=stable
2026/06/30 08:14:33  [INFO]   : 👋 Hello, welcome to oc-mirror
2026/06/30 08:14:33  [INFO]   : ⚙️  setting up the environment for you...
2026/06/30 08:14:33  [INFO]   : ⚙️  environment version: 4.22.0-202606161751.p2.g41d68b1.assembly.stream.el9-41d68b1
VERSIONS
4.12.0
4.12.1
4.12.2
4.13.0
4.13.1
4.13.2
4.13.3
4.13.4
4.14.0
4.14.1
4.14.2
...
```
