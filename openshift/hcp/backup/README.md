# HCP Backup & Restore with OADP

1. Install OADP operator from OperatorHub

2. Create a S3 bucket

3. Create a secret in OADP namespace with bucket credentials
```
cat << EOF > ./credentials
[default]
aws_access_key_id=<AWS_ACCESS_KEY_ID>
aws_secret_access_key=<AWS_SECRET_ACCESS_KEY>
EOF
```

```
oc create secret generic cloud-credentials -n openshift-adp --from-file cloud=credentials
```

4. Create a backup location
```
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: oadp-backup-location-bm1
  namespace: openshift-adp
spec:
  configuration:
    nodeAgent:hosted constrol 
      enable: true
      uploaderType: kopia
    velero:
      defaultPlugins:
        - aws
        - kubevirt
        - openshift
        - csi
      defaultSnapshotMoveData: true 
  backupLocations:
    - velero:
        config:
          profile: "default"
          region: noobaa
          s3Url: https://s3.openshift-storage.svc 
          s3ForcePathStyle: "true"
          insecureSkipTLSVerify: "true"
        provider: aws
        default: true
        credential:
          key: cloud
          name:  cloud-credentials
        objectStorage:
          bucket: oadp-backup-de08413c-a747-4a9f-af38-bf6e06c14316 
          prefix: oadp
```

5. Create a backup
```
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: hcp01-clusters-hosted-backup
  namespace: openshift-adp
  labels:
    velero.io/storage-location: default
spec:
  includedNamespaces: 
  - clusters
  - clusters-hcp01
  includedResources:
  - sa
  - role
  - rolebinding
  - deployment
  - statefulset
  - pv
  - pvc
  - bmh
  - configmap
  - infraenv
  - priorityclasses
  - pdb
  - hostedcluster
  - nodepool
  - secrets
  - hostedcontrolplane
  - cluster
  - datavolume
  - service
  - route
  excludedResources: [ ]
  labelSelector: 
    matchExpressions:
    - key: 'hypershift.openshift.io/is-kubevirt-rhcos'
      operator: 'DoesNotExist'
  storageLocation: oadp-backup-location-bm1-1
  preserveNodePorts: true
  ttl: 4h0m0s
  snapshotMoveData: true 
  datamover: "velero" 
  defaultVolumesToFsBackup: false 
```

6. With Kaster
```
kind: Policy
apiVersion: config.kio.kasten.io/v1alpha1
metadata:
  name: backup-hcp01
  namespace: kasten-io
  uid: c85a5897-7be2-47a3-8d3a-bb80fff9a85b
  resourceVersion: "86885224"
  generation: 4
  creationTimestamp: 2025-05-07T14:39:00Z
spec:
  frequency: "@onDemand"
  selector:
    matchExpressions:
      - key: k10.kasten.io/appNamespace
        operator: In
        values:
          - clusters
          - clusters-hcp01
  actions:
    - action: backup
      backupParameters:
        filters:
          includeResources:
            - resource: roles
            - resource: rolebindings
            - resource: deployments
            - resource: statefulsets
            - resource: persistentvolumeclaims
            - resource: baremetalhosts
            - resource: configmaps
            - resource: infraenvs
            - resource: poddisruptionbudgets
            - resource: hostedclusters
            - resource: nodepools
            - resource: secrets
            - resource: hostedcontrolplanes
            - resource: clusters
            - resource: datavolumes
            - resource: services
            - resource: routes
            - resource: serviceaccounts
          excludeResources:
            - resource: persistentvolumeclaims
              matchExpressions:
                - key: hypershift.openshift.io/is-kubevirt-rhcos
                  operator: In
                  values:
                    - "true"
        profile:
          name: backup-bm1
          namespace: kasten-io
        imageRepoProfile:
          name: backup-bm1
          namespace: kasten-io
    - action: export
      exportParameters:
        frequency: "@onDemand"
        receiveString: bIzAPpoanmE+lQwgoBws0IsgTz4RClKh8yyN2n0+cs0IZdkbpkG2c7mLZtfEm+4OMTXWzKuNGU+u7zELhTr9nzV7kjwcH+yKT4ORxuG21oGll/1Gzn12GFCiv83GKpB+WIsQvVpEg7VCu7OQ7Nz+nnX6AtqIlA8d4SDFGEmr5OeP67UQGxWkwVrRgkLZIDV1+6A7TZeXt1h600o3MTiL9929XXSzHSjrpihH94zbaJdioYyeZS3AdosHtK2Qh965Mo7HaaGIcsFhEjSyoQslrTLd7+SZYe/YkBeWDnV2TGA9RWbE+Slw+nW2tZ2Yt8Js11olJpdKgHUBg9pniW3THLYW9LURaBhOu8Mm0N797KWuzB+U3oma6y0qmQD+gHtu/s35eNURwvynFD9p/pmmKk/diqwWU76VlAbthshQMT9b0bgNKoDcOn8vEAXLm7ipa1fAvqZjL6mwAgAavUhyBmD9iJcn4eguLC3qfDRTpYYWugYJjRbLFRtMJntHQoDuiaTXMFqJnSBopOZVkgr+xG9ps/w+VOuBbT85JJj4iix9p9UeZpTfCgQZcVzxdWHaHRpcmz53hYdv8WZn/+VG8dAuRouV1Yl77n3bfe65Ouw6tPqGhz8GdMN7NscTraG3JpYt04Mm1prfB2dATkoLd/TNAoFb1zUVp8O4fvmbcST1MFHmp3+yTteRY2c
        profile:
          name: backup-bm1
          namespace: kasten-io
        migrationToken:
          name: backup-hcp01-migration-token
          namespace: kasten-io
        exportData:
          enabled: true
  createdBy: kasten-io:k10-k10
  modifiedBy: kasten-io:k10-k10
  lastModifyHash: 1600967295
status:
  validation: Success
  hash: 3495942259
  specModifiedTime: 2025-05-07T14:39:18Z
```