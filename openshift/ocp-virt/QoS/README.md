# QoS

## Network QoS

1. Add QoS annotations on VM
```
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: testvm2
  namespace: blue
  labels:
    app: testvm2
    kubevirt.io/dynamic-credentials-support: 'true'
    vm.kubevirt.io/template: rhel9-server-small
    vm.kubevirt.io/template.namespace: openshift
    vm.kubevirt.io/template.revision: '1'
    vm.kubevirt.io/template.version: v0.35.0
spec:
  dataVolumeTemplates:
    - apiVersion: cdi.kubevirt.io/v1beta1
      kind: DataVolume
      metadata:
        name: testvm2
      spec:
        sourceRef:
          kind: DataSource
          name: rhel9
          namespace: openshift-virtualization-os-images
        storage:
          resources:
            requests:
              storage: 30Gi
  runStrategy: RerunOnFailure
  template:
    metadata:
      annotations:
        kubernetes.io/egress-bandwidth: 50M             <<<--- Add this annotation for egress flow
        kubernetes.io/ingress-bandwidth: 50M            <<<--- Add this annotation for ingress flow
        kubevirt.io/pci-topology-version: v3
        vm.kubevirt.io/flavor: small
        vm.kubevirt.io/os: rhel9
        vm.kubevirt.io/workload: server
      labels:
        kubevirt.io/domain: testvm2
        kubevirt.io/size: small
        vm.kubevirt.io/name: testvm2
    spec:
      accessCredentials:
        - sshPublicKey:
            propagationMethod:
              noCloud: {}
            source:
              secret:
                secretName: dm-key-blue
      architecture: amd64
      domain:
        cpu:
          cores: 1
          sockets: 1
          threads: 1
        devices:
          disks:
            - disk:
                bus: virtio
              name: rootdisk
            - disk:
                bus: virtio
              name: cloudinitdisk
          interfaces:
            - binding:
                name: l2bridge
              macAddress: '02:78:0c:4c:a7:0c'
              model: virtio
              name: default
          rng: {}
        features:
          acpi: {}
          smm:
            enabled: true
        firmware:
          bootloader:
            efi: {}
          serial: 5278d459-55e4-4000-8abe-66ec7b0a56a1
          uuid: 276525b9-9a71-449e-b37d-fb9fa3aa4615
        machine:
          type: pc-q35-rhel9.8.0
        memory:
          guest: 2Gi
        resources: {}
      networks:
        - name: default
          pod: {}
      terminationGracePeriodSeconds: 180
      volumes:
        - dataVolume:
            name: testvm2
          name: rootdisk
        - cloudInitNoCloud:
            userData: |-
              #cloud-config
              user: cloud-user
              password: 40wd-ni1c-j1a4
              chpasswd: { expire: False }
          name: cloudinitdisk
```

2. Test QoS limitation

**On server side:**
```
[root@testvm-server ~]# iperf3 -s
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```

**On client side without limitation:**
```
[root@testvm-client ~]# iperf3 -c 192.168.1.4 -t 20
Connecting to host 192.168.1.4, port 5201
[  5] local 192.168.1.3 port 34754 connected to 192.168.1.4 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  2.47 GBytes  21.2 Gbits/sec    0   3.84 MBytes       
[  5]   1.00-2.00   sec  2.38 GBytes  20.4 Gbits/sec    0   3.84 MBytes       
[  5]   2.00-3.00   sec  2.25 GBytes  19.3 Gbits/sec    0   3.84 MBytes       
[  5]   3.00-4.00   sec  1.98 GBytes  17.0 Gbits/sec    0   3.84 MBytes       
[  5]   4.00-5.00   sec  2.00 GBytes  17.2 Gbits/sec    0   3.84 MBytes       
[  5]   5.00-6.00   sec  2.43 GBytes  20.8 Gbits/sec    0   3.84 MBytes       
[  5]   6.00-7.00   sec  2.40 GBytes  20.7 Gbits/sec    0   3.84 MBytes       
[  5]   7.00-8.00   sec  2.31 GBytes  19.8 Gbits/sec    0   3.84 MBytes       
[  5]   8.00-9.00   sec  2.40 GBytes  20.6 Gbits/sec    0   3.84 MBytes       
[  5]   9.00-10.00  sec  2.29 GBytes  19.7 Gbits/sec    0   3.84 MBytes       
[  5]  10.00-11.00  sec  2.35 GBytes  20.2 Gbits/sec    0   3.84 MBytes       
[  5]  11.00-12.00  sec  2.26 GBytes  19.4 Gbits/sec    0   3.84 MBytes       
[  5]  12.00-13.00  sec  2.36 GBytes  20.2 Gbits/sec    0   3.84 MBytes       
[  5]  13.00-14.00  sec  2.34 GBytes  20.1 Gbits/sec    0   3.84 MBytes       
[  5]  14.00-15.00  sec  2.40 GBytes  20.6 Gbits/sec    0   3.84 MBytes       
[  5]  15.00-16.00  sec  2.35 GBytes  20.2 Gbits/sec    0   3.84 MBytes       
[  5]  16.00-17.00  sec  2.30 GBytes  19.7 Gbits/sec    0   3.84 MBytes       
[  5]  17.00-18.00  sec  2.38 GBytes  20.5 Gbits/sec    1   3.84 MBytes       
[  5]  18.00-19.00  sec  2.33 GBytes  20.0 Gbits/sec    0   3.84 MBytes       
[  5]  19.00-20.00  sec  2.33 GBytes  20.0 Gbits/sec    0   3.84 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-20.00  sec  46.3 GBytes  19.9 Gbits/sec    1             sender
[  5]   0.00-20.04  sec  46.3 GBytes  19.9 Gbits/sec                  receiver

iperf Done.
```

**On client side with QoS annotation:**
```
[root@testvm-client ~]# iperf3 -c 192.168.1.4 -t 20
Connecting to host 192.168.1.4, port 5201
[  5] local 192.168.1.3 port 51270 connected to 192.168.1.4 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  3.81 MBytes  31.9 Mbits/sec  376   6.58 KBytes       
[  5]   1.00-2.00   sec  3.09 MBytes  25.9 Mbits/sec  311   9.21 KBytes       
[  5]   2.00-3.00   sec  2.96 MBytes  24.8 Mbits/sec  329   7.90 KBytes       
[  5]   3.00-4.00   sec  2.65 MBytes  22.3 Mbits/sec  276   2.63 KBytes       
[  5]   4.00-5.00   sec  3.09 MBytes  25.9 Mbits/sec  352   47.4 KBytes       
[  5]   5.00-6.00   sec  3.02 MBytes  25.4 Mbits/sec  298   44.8 KBytes       
[  5]   6.00-7.00   sec  3.21 MBytes  26.9 Mbits/sec  311   34.2 KBytes       
[  5]   7.00-8.00   sec  2.47 MBytes  20.7 Mbits/sec  273   7.90 KBytes       
[  5]   8.00-9.00   sec  3.95 MBytes  33.1 Mbits/sec  305   6.58 KBytes       
[  5]   9.00-10.00  sec  3.21 MBytes  26.9 Mbits/sec  225   11.8 KBytes       
[  5]  10.00-11.00  sec  2.65 MBytes  22.3 Mbits/sec  259   7.90 KBytes       
[  5]  11.00-12.00  sec  2.96 MBytes  24.8 Mbits/sec  338   9.21 KBytes       
[  5]  12.00-13.00  sec  3.27 MBytes  27.4 Mbits/sec  331   6.58 KBytes       
[  5]  13.00-14.00  sec  3.15 MBytes  26.4 Mbits/sec  332   11.8 KBytes       
[  5]  14.00-15.00  sec  2.47 MBytes  20.7 Mbits/sec  298   3.95 KBytes       
[  5]  15.00-16.00  sec  3.15 MBytes  26.4 Mbits/sec  325   56.6 KBytes       
[  5]  16.00-17.00  sec  3.09 MBytes  25.9 Mbits/sec  332   23.7 KBytes       
[  5]  17.00-18.00  sec  2.90 MBytes  24.3 Mbits/sec  348   9.21 KBytes       
[  5]  18.00-19.00  sec  2.96 MBytes  24.8 Mbits/sec  280   7.90 KBytes       
[  5]  19.00-20.00  sec  3.15 MBytes  26.4 Mbits/sec  355   10.5 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-20.00  sec  61.2 MBytes  25.7 Mbits/sec  6254             sender
[  5]   0.00-20.12  sec  60.6 MBytes  25.3 Mbits/sec                  receiver

iperf Done.
```