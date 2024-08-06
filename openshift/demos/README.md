# OpenShift sample apps

## Github Webhook

1. Create a secret in your OpenShift Project

github-secret.yaml
```
kind: Secret
apiVersion: v1
metadata:
  name: github-secret
  creationTimestamp:
data:
  WebHookSecretKey: c2VjcmV0dmFsdWUx
````

oc create -f github-secret.yaml -n sample-apps

