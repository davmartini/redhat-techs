# Backup/Restore application with OADP

## Steps

### 1. Install OADP operator from OperatorHub

### 2. Create S3 Bucket from your provider

### 3. Create OADP secret to connect to your bucket
```
kind: Secret
apiVersion: v1
metadata:
  name: cloud-credentials
  namespace: openshift-adp
data:
  cloud: >-
    [default]
    aws_access_key_id=<AK>
    aws_secret_access_key=<SK>
type: Opaque
```

### 4. Create a DataProtectionApplication CRD
```
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: oadp-nutanix-s3
  namespace: openshift-adp
spec:
  backupLocations:
    - velero:
        config:
          profile: default
          region: us-east-1
          s3ForcePathStyle: 'true'
          s3Url: 'http://s3.rhntnx.hpecic.net/'
        credential:
          key: cloud
          name: cloud-credentials
        default: true
        objectStorage:
          bucket: openshift-backup
          prefix: ocp01
        provider: aws
  configuration:
    restic:
      enable: true
    velero:
      defaultPlugins:
        - openshift
        - csi
        - aws
      featureFlags:
        - EnableCSI
```

### 5. Create application in oadp-demo namespace
```
From git https://github.com/davmartini/redhat-techs.git
path "openshift/demos/ocp-oadp/app"
```

### 6. Generate data in application database

### 7. Create an application backup
```
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: backup-namespace-oadp-demo
  labels:
    velero.io/storage-location: default
  namespace: openshift-adp
spec:
  defaultVolumesToRestic: true 
  includedNamespaces:
    - oadp-demo
```

### 8. Delete oadp-demo namespace

### 9. Create an application restore
```
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: restore-namespace-oadp-demo
  namespace: openshift-adp
spec:
  backupName: backup-namespace-oadp-demo
  includedResources: [] 
  excludedResources:
  - nodes
  - events
  - events.events.k8s.io
  - backups.velero.io
  - restores.velero.io
  - resticrepositories.velero.io
  restorePVs: true
```
