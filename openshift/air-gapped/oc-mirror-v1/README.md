1. List available operators
```
oc-mirror list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.17
```

2. Create imageset-config.yaml

3. Configure auth for public and private registry

4. Mirror from public to local file
```
oc mirror --config=./imageset-config.yaml file://mirror
```

5. Mirror from local file to private registry
```
oc mirror --from=./mirror_seq1_000000.tar docker://registry-quay-quay.apps.ocp.drkspace.fr/ocp-mirror --dest-skip-tls
```

6. Disable all default catalog sources
```
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```

7. Add private registry secret tp OCP Cluster
```
oc create secret generic private-registry-secret \
    -n openshift-marketplace \
    --from-file=.dockerconfigjson=private-registry.json \
    --type=kubernetes.io/dockerconfigjson
```

8. Add new catalog source
```
oc apply -f imageset-config.yaml
````