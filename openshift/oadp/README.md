# OADP for OpenShift Virtualization

## Prerequisits

* OpenShift Virtualization
* OADP Operator installed
* S3 Bucket

## Backup steps

1. Create a secret with S3 AK/SK

2. Create DataProtectionApplication with kubevirt plugin and external S3
```
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: minio-oadp
  namespace: openshift-adp
spec:
  configuration:
    velero:
      concurrentBackups: 10
      defaultPlugins:
        - aws
        - kubevirt
        - csi
        - openshift
      resourceTimeout: 10m
    nodeAgent:
      enable: true
      uploaderType: kopia
    vmFileRestore:
      enable: true
  backupLocations:
    - name: default
      velero:
        provider: aws
        default: true
        objectStorage:
          bucket: oadp
          prefix: sno
        config:
          region: minio
          profile: "default"
          s3Url: "http://minio-api-minio.apps.ocp.drkspace.fr"
          s3ForcePathStyle: "true"
        credential:
          key: cloud
          name: cloud-credentials
  snapshotLocations:
    - velero:
        config:
          region: minio
          profile: "default"
        provider: aws
  vmFileRestore:
    enable: true
```

![dpa](images/dpa.png)

3. Create a VM
```
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: testvm
  generation: 1
  namespace: vms
  finalizers:
    - kubevirt.io/virtualMachineControllerFinalize
  labels:
    app: testvm
    velero.io/restore-name: restore-testvm
    vm.kubevirt.io/template: rhel9-server-small
    kubevirt.io/dynamic-credentials-support: 'true'
    velero.io/backup-name: testvm
    vm.kubevirt.io/template.version: v0.35.0
    vm.kubevirt.io/template.namespace: openshift
    vm.kubevirt.io/template.revision: '1'
spec:
  dataVolumeTemplates:
    - apiVersion: cdi.kubevirt.io/v1beta1
      kind: DataVolume
      metadata:
        name: testvm
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
        kubevirt.io/pci-topology-version: v3
        vm.kubevirt.io/flavor: small
        vm.kubevirt.io/os: rhel9
        vm.kubevirt.io/workload: server
      labels:
        kubevirt.io/domain: testvm
        kubevirt.io/size: small
    spec:
      accessCredentials:
        - sshPublicKey:
            propagationMethod:
              qemuGuestAgent:
                users:
                  - cloud-user
            source:
              secret:
                secretName: dm-key
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
            - macAddress: '02:78:0c:f4:fc:17'
              masquerade: {}
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
          serial: 00cdebc9-6034-430c-a2af-64fc85bc823b
          uuid: 94d288ab-a8e6-4534-a84c-4cd12622fc6d
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
            name: testvm
          name: rootdisk
        - cloudInitNoCloud:
            userData: |
              #cloud-config
              user: cloud-user
              password: vlar-q3ri-e668
              chpasswd:
                expire: false
              runcmd:
                - setsebool -P virt_qemu_ga_manage_ssh on
          name: cloudinitdisk
```

4. Create a single VM backup
```
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: testvm
  namespace: openshift-adp
spec:
  snapshotMoveData: true
  includedNamespaces:
  - vms
  labelSelector:
    matchLabels:
      app: testvm
  storageLocation: default
```

5. Create a multiple VM backup
```
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: testvm-2
  namespace: openshift-adp
spec:
  snapshotMoveData: true
  includedNamespaces:
  - vms-demo
  storageLocation: default
```

![backup](images/backup.png)

5. Delete the VM

6. Restore a single VM from a multiple VM backup
```
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: test-vm-restore
  namespace: openshift-adp
spec:
  backupName: testvm-2
  restorePVs: true
  orLabelSelectors:
    - matchLabels:
        app: rhel9-vm1
```

![restore](images/restore.png)

## Backup a single file inside a VM

1. Create a bacup discovery
```
apiVersion: oadp.openshift.io/v1alpha1
kind: VirtualMachineBackupsDiscovery
metadata:
  name: find-my-vm-backups
  namespace: openshift-adp
spec:
  virtualMachineName: "testvm"
  virtualMachineNamespace: "vms"
```

2. Result
```
apiVersion: oadp.openshift.io/v1alpha1
kind: VirtualMachineBackupsDiscovery
...
status:
  backupDiscoveryProgress:
    - createdAt: '2026-10-02T08:44:17Z'
      lastUpdated: '2026-10-02T08:45:29Z'
      message: VM found in backup
      name: testvm
      namespace: openshift-adp
      status: Completed
  conditions:
    - lastTransitionTime: '2026-10-02T08:45:29Z'
      message: Successfully discovered 1 valid backups
      reason: DiscoverySuccessful
      status: 'True'
      type: Ready
  discoveryStats:
    completed: 1
    completionTime: '2026-10-02T08:45:29Z'
    failed: 0
    inProgress: 0
    pending: 0
    skipped: 0
    startTime: '2026-10-02T08:45:29Z'
    totalCandidates: 1
  observedGeneration: 1
  phase: Completed
  validBackups:
    - createdAt: '2026-10-02T08:44:17Z'
      name: testvm
      namespace: openshift-adp
```

3. Create a VirtualMachineFileRestore
```
apiVersion: oadp.openshift.io/v1alpha1
kind: VirtualMachineFileRestore
metadata:
  name: restore-config-files
  namespace: openshift-adp
spec:
  backupsDiscoveryRef: find-my-vm-backups
  fileAccess:
    fileBrowser:
      credentialsSecretRef:
        name: vmfr-credentials
      exposeExternally: true
```