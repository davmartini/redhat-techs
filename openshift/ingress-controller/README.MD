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
    replicas: 1
    endpointPublishingStrategy:
      type: LoadBalancerService
      loadBalancer:
        scope: External
        allowedSourceRangesallowedSourceRanges:
          - 192.168.1.0/24
          - 192.168.2.0/24
    domain: apps-l2.ocp.drkspace.fr
    namespaceSelector:
        matchExpressions:
        - key: name
          operator: In
          values:
            - dev-l2
            - ops-l2
```

## 2. Modify default ingress

You have to modify default ingress to indicate him to not serve specific namespace's routes serve by our new ingress

```
apiVersion: operator.openshift.io/v1
kind: IngressController
metadata:
  name: default
  namespace: openshift-ingress-operator
spec:
  namespaceSelector: <<-- Add this part
    matchExpressions:
      - key: name
        operator: NotIn
        values:
          - dev-l2
          - ops-l2
```

## 3. Create new namespace with defined names

```
kind: Namespace
apiVersion: v1
metadata:
  name: dev-l2
  labels:
    name: dev-l2
---
kind: Namespace
apiVersion: v1
metadata:
  name: ops-l2
  labels:
    name: ops-l2
```