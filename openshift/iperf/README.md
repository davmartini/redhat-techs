# Network Benchmark in an OpenShift Cluster

## Build Iperf image if needed (optional)

1. Use Dockerfile in build directory to create a new image
```
podman build -t quay.io/david_martini/iperf:0.1 .
```

2. Push the image
```
podman push quay.io/david_martini/iperf:0.1
```

## Deploy Iperf container in your OpenShift Cluster
```
apiVersion: v1
kind: Pod
metadata:
  name: iperf-server
  namespace: test-network
spec:
  #hostNetwork: true #<--------- UNCOMMENT THIS SETTING IF THE IPERF POD MUST RUN IN THE HOST NETWORK
  nodeName: worker-1.rh.hpecic.net #<-------- REPLACE THIS WITH THE NODE WHERE IPERF SERVER MUST RUN
  containers:
  - name: server
    image: quay.io/david_martini/iperf:0.1  #<---------- REPLACE THIS
---
apiVersion: v1
kind: Pod
metadata:
  name: iperf-client
  namespace: test-network
spec:
  #hostNetwork: true #<--------- UNCOMMENT THIS SETTING IF THE IPERF POD MUST RUN IN THE HOST NETWORK
  nodeName: worker-4.rh.hpecic.net #<-------- REPLACE THIS WITH THE NODE WHERE IPERF CLIENT MUST RUN
  containers:
  - name: client
    image: quay.io/david_martini/iperf:0.1  #<---------- REPLACE THIS
```

## Connect to the Iperf server
```
$ oc get pod iperf-server -n test-network -o wide
NAME           READY   STATUS    RESTARTS   AGE   IP
iperf-server   1/1     Running   0          8s    10.130.2.13
```

```
oc exec -it iperf-server -n test-network -- iperf3 -i 5 -s
```

## Start Iperf client
```
oc exec -it iperf-client -n test-network -- iperf3 -i 5 -t 60 -c $(oc get pod iperf-server -n test-network -o jsonpath='{.status.podIP}')
```


## Sample Result
```
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 10.128.4.81, port 34966
[  5] local 10.128.6.3 port 5201 connected to 10.128.4.81 port 34978
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-5.00   sec  4.09 GBytes  7.02 Gbits/sec                  
[  5]   5.00-10.00  sec  4.43 GBytes  7.62 Gbits/sec                  
[  5]  10.00-15.00  sec  4.40 GBytes  7.56 Gbits/sec                  
[  5]  15.00-20.00  sec  4.41 GBytes  7.58 Gbits/sec                  
[  5]  20.00-25.00  sec  4.41 GBytes  7.58 Gbits/sec                  
[  5]  25.00-30.00  sec  4.19 GBytes  7.20 Gbits/sec                  
[  5]  30.00-35.00  sec  4.51 GBytes  7.74 Gbits/sec  
...
```