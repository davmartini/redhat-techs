# Backup and Restore procedure

## Backup

### 1. Start a debug session for a control plane node
````
oc debug node/<node_name>
````

### 2. Change your root directory to the host
````
chroot /host
````

### 3. Run the cluster-backup.sh script and pass in the location to save the backup to.
````
/usr/local/bin/cluster-backup.sh /home/core/assets/backup
sh-4.4# /usr/local/bin/cluster-backup.sh /home/core/assets/backup
found latest kube-apiserver: /etc/kubernetes/static-pod-resources/kube-apiserver-pod-17
found latest kube-controller-manager: /etc/kubernetes/static-pod-resources/kube-controller-manager-pod-13
found latest kube-scheduler: /etc/kubernetes/static-pod-resources/kube-scheduler-pod-11
found latest etcd: /etc/kubernetes/static-pod-resources/etcd-pod-6
294f79a4f57219f2fda5a0a496e4f0194ab74d8962db40a89c3139ce1be59705
etcdctl version: 3.5.0
API version: 3.5
{"level":"info","ts":1644855256.6708472,"caller":"snapshot/v3_snapshot.go:68","msg":"created temporary db file","path":"/home/core/assets/backup/snapshot_2022-02-14_161413.db.part"}
{"level":"info","ts":1644855256.6807897,"logger":"client","caller":"v3/maintenance.go:211","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":1644855256.6808472,"caller":"snapshot/v3_snapshot.go:76","msg":"fetching snapshot","endpoint":"https://10.42.61.132:2379"}
{"level":"info","ts":1644855258.5356717,"logger":"client","caller":"v3/maintenance.go:219","msg":"completed snapshot read; closing"}
{"level":"info","ts":1644855258.7735107,"caller":"snapshot/v3_snapshot.go:91","msg":"fetched snapshot","endpoint":"https://10.42.61.132:2379","size":"161 MB","took":"2 seconds ago"}
{"level":"info","ts":1644855258.773707,"caller":"snapshot/v3_snapshot.go:100","msg":"saved","path":"/home/core/assets/backup/snapshot_2022-02-14_161413.db"}
Snapshot saved at /home/core/assets/backup/snapshot_2022-02-14_161413.db
Deprecated: Use `etcdutl snapshot status` instead.

{"hash":394703127,"revision":27863222,"totalKey":15817,"totalSize":160841728}
snapshot db and kube resources are successfully saved to /home/core/assets/backup
sh-4.4# cd /home/core/assets/backup/
sh-4.4# ls
snapshot_2022-02-14_161413.db  static_kuberesources_2022-02-14_161413.tar.gz
sh-4.4# ls -lrt
total 157156
-rw-------. 1 root root     78617 Feb 14 16:14 static_kuberesources_2022-02-14_161413.tar.gz
-rw-------. 1 root root 160841760 Feb 14 16:14 snapshot_2022-02-14_161413.db
````

## Restore

https://docs.openshift.com/container-platform/4.9/backup_and_restore/control_plane_backup_and_restore/disaster_recovery/scenario-2-restoring-cluster-state.html#dr-restoring-cluster-state
