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