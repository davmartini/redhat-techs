# Doc to add new node to an existing cluster

1. Log to your cluster with **oc** cli

2. create a nodes-config.yaml (example)

3. Generate a new iso image
```
oc adm node-image create nodes-config.yaml
```