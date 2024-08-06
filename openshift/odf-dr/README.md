# Regional DR with ODF

## Docs

https://access.redhat.com/documentation/en-us/red_hat_openshift_data_foundation/4.14/html/configuring_openshift_data_foundation_disaster_recovery_for_openshift_workloads/rdr-solution#requirements-for-enabling-regional-disaster-recovery_rdr

## Prerequisites

* Primary cluster with ODF
* Secondardy cluster with ODF
* Hub Cluster with RHACM

## Operators Needed

* Primary cluster : ODF, Submariner
* Secondary cluster : ODF, Submarine
* Hub Cluster : RHACM


## Questions 

* RHACM label only one node for gateway (oc get nodes -L submariner.io/gateway). Ok if node shutdown ?


## Notes 

* Need to modify limits for RAMEN and ODFMO deployments


## Subscription demo with RHACM

1. Create a new subscription application with RHACM (BM1)
2. 