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
  snapshotLocations: []
```

![dpa](images/dpa.png)

3. 
