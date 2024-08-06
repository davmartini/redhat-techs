# Examples APPS for ArgoCD

## Structure

**applications** : YAML files to create application in ArgoCD Product
**apps** : Manifest YAML files to declare each application objects

## BDF example

1. Login to OpenShift
```
oc login ...
```

2. Create ArgoCD Application
```
oc create -f applications/bdf-app.yaml
```

3. Modify colour env parameter in deployment manifest

4. Resynchronise project with ArgoCD

5. Modify SyncPolicy on Apllication manifest
```
spec:
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```