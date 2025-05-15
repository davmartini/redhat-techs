# Create persistent storage for Monitoring Stack

1. Create ConfigMaps **cluster-monitoring-config** in **openshift-monitoring** namespace/project  

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    prometheusK8s:
      retention: 7d
      retentionSize: 20GB
      volumeClaimTemplate:
        spec:
          storageClassName: ocs-storagecluster-ceph-rbd
          resources:
            requests:
              storage: 20Gi
```