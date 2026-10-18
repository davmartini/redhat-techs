# Restore ETCD

## Introduction

Procedure to restore ETCD control plane with only one etcd pod active on 3.

## Recovery procedure

1. Export vars
```
export CLUSTER_NAME="hcp01"
export CLUSTER_NAMESPACE="clusters"
export CONTROL_PLANE_NAMESPACE="${CLUSTER_NAMESPACE}-${CLUSTER_NAME}"
export ETCD_POD="etcd-0" # Replace by the existing etcd pod
```

2. Stop reconcilation
```
oc patch -n ${CLUSTER_NAMESPACE} hostedclusters/${CLUSTER_NAME} -p '{"spec":{"pausedUntil":"true"}}' --type=merge
```

3. Export snapshoft from the active etcd pod
```
oc exec -n ${CONTROL_PLANE_NAMESPACE} -c etcd -t ${ETCD_POD} -- \
  env ETCDCTL_API=3 /usr/bin/etcdctl \
  --cacert /etc/etcd/tls/etcd-ca/ca.crt \
  --cert /etc/etcd/tls/client/etcd-client.crt \
  --key /etc/etcd/tls/client/etcd-client.key \
  --endpoints=https://localhost:2379 \
  snapshot save /var/lib/snapshot.db
```

4. Copy snapshoft localy
```
oc cp -c etcd ${CONTROL_PLANE_NAMESPACE}/${ETCD_POD}:/var/lib/snapshot.db ./etcd.snapshot.db
```

5. Scale control plane to 0
```
oc scale -n ${CONTROL_PLANE_NAMESPACE} statefulset/etcd --replicas=0
```

6. Delete all PVCs
```
oc delete -n ${CONTROL_PLANE_NAMESPACE} pvc/data-etcd-0 pvc/data-etcd-1 pvc/data-etcd-2
```

7. Create new PVC data-etcd-0 with 8Go

8. Get ETCD image for your cluster
```
ETCD_IMAGE=$(oc get -n ${CONTROL_PLANE_NAMESPACE} statefulset/etcd \
  -o jsonpath='{ .spec.template.spec.containers[0].image }')
```

9. Create a new deployment using your new pvc
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: etcd-data
spec:
  replicas: 1
  selector:
    matchLabels:
      app: etcd-data
  template:
    metadata:
      labels:
        app: etcd-data
    spec:
      containers:
      - name: access
        image: $ETCD_IMAGE
        volumeMounts:
        - name: data
          mountPath: /var/lib
        command:
        - /usr/bin/bash
        args:
        - -c
        - |-
          while true; do
            sleep 1000
          done
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: data-etcd-0
```

10. Get the name of the new created pod
```
DATA_POD=$(oc get -n ${CONTROL_PLANE_NAMESPACE} pods --no-headers \
  -l app=etcd-data -o name | cut -d/ -f2)
```

11. Copy your snapshot from localy to your new pod
```
oc cp ./etcd.snapshot.db ${CONTROL_PLANE_NAMESPACE}/${DATA_POD}:/var/lib/restored.snap.db
```

12. Remove old data
```
oc exec -n ${CONTROL_PLANE_NAMESPACE} ${DATA_POD} -- rm -rf /var/lib/data
oc exec -n ${CONTROL_PLANE_NAMESPACE} ${DATA_POD} -- mkdir -p /var/lib/data
```

13. Restore ETCD snapshot
```
oc exec -n ${CONTROL_PLANE_NAMESPACE} ${DATA_POD} -- \
     etcdutl snapshot restore /var/lib/restored.snap.db \
     --data-dir=/var/lib/data --skip-hash-check \
     --name etcd-0 \
     --initial-cluster-token=etcd-cluster \
     --initial-cluster etcd-0=https://etcd-0.etcd-discovery.${CONTROL_PLANE_NAMESPACE}.svc:2380,etcd-1=https://etcd-1.etcd-discovery.${CONTROL_PLANE_NAMESPACE}.svc:2380,etcd-2=https://etcd-2.etcd-discovery.${CONTROL_PLANE_NAMESPACE}.svc:2380 \
     --initial-advertise-peer-urls https://etcd-0.etcd-discovery.${CONTROL_PLANE_NAMESPACE}.svc:2380
```

14. Remove old snapshoft
```
oc exec -n ${CONTROL_PLANE_NAMESPACE} ${DATA_POD} -- rm /var/lib/restored.snap.db
```

15. Remove temporary deployement
```
oc delete -n ${CONTROL_PLANE_NAMESPACE} deployment/etcd-data
```

16. Scale up control plane
```
oc scale -n ${CONTROL_PLANE_NAMESPACE} statefulset/etcd --replicas=3
``` 

17. Unpause reconsilation
```
oc patch -n ${HOSTED_CLUSTER_NAMESPACE} hostedclusters/${CLUSTER_NAME} \
  -p '{"spec":{"pausedUntil":null}}' --type=merge
```