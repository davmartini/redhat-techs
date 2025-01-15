# Add custom Ingress for network segmentation

## 1. Add new ingress

This new ingress use MetalLB pool to have a dedicated IP to serve specific routes. The new domain is "apps-l2.ocp.drkspace.fr" and a new DNS record was created.
With set some specs on this new ingress to be used by specific namespace via "namespaceSelector". 

```
apiVersion: operator.openshift.io/v1
kind: IngressController
metadata:
    name: l2-ingress
    namespace: openshift-ingress-operator
spec:
    replicas: 4
    endpointPublishingStrategy:
      type: LoadBalancerService
    domain: apps-l2.ocp.drkspace.fr
    namespaceSelector:
        matchExpressions:
        - key: name
            operator: In
            values:
            - dev-l2
            - ops-l2
```