# How to perform storage test on OpenShift

## 1. Get container image with FIO and scipts

**quay.io/david_martini/fio:latest**

## 2. Deploy PVC and deployement based on this FIO image

```
kind: Namespace
apiVersion: v1
metadata:
  name: perf-storage-test
```

```
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: storage-pvc-standard
  namespace: perf-storage-test
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 200Gi
  storageClassName: $your-storage-class
  volumeMode: Filesystem
---
kind: Deployment
apiVersion: apps/v1
metadata:
  namespace: perf-storage-test
  name: perf-standard
spec:
  replicas: 1
  selector:
    matchLabels:
      app: perf-standard
  template:
    metadata:
      labels:
        app: perf-standard
    spec:
      strategy:
        type: Recreate
      containers:
        - name: fio
          image: 'quay.io/david_martini/fio:latest'
          command:
            - bash
            - '-c'
            - tail -f /dev/null
          volumeMounts:
            - name: v1
              mountPath: /fio-test-dir
      volumes:
        - name: v1
          persistentVolumeClaim:
            claimName: storage-pvc-standard
---

```

## 3. Pre commands before start tests

```
oc rsh $pod
sh-5.2$ source /usr/local/bin/z_init.sh
bash-5.2$ cd /fio-test-dir/
```

Add fio.sh script and execute it

## 4. Recover results locally 

```
oc rsync $pod:/fio-test-dir/ .
```