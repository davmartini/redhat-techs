#!/bin/bash
#author: David Martini - dmartini@redhat.com
source ./vars.hcp 

# Inputs Readings
echo "What do you whant to do (new-cluster or node-pool-creation): "
read OPERATION

if [ $OPERATION == "new-cluster" ]; then

  echo "Network mode deployment (mutualized or dedicated): "
  read NETWORK_DEPLOYMENT_MODE

  # Prints VARS
  echo "Network mode deployment: $NETWORK_DEPLOYMENT_MODE"
  echo "Cluster name: $CLUSTER_NAME"
  echo "OCP release: $RELEASE_IMAGE"
  echo "Number of workers: $WORKER_COUNT"
  echo "CPU by worker: $CPU"
  echo "MEM by worker: $MEM"
  echo "Control plane availability policy: $CP_DEPLOYMENT_MODE"
  echo "Infra availability policy: $INFRA_DEPLOYMENT_MODE"
  echo "Base domain: $BASE_DOMAIN"

  if [ $NETWORK_DEPLOYMENT_MODE == "mutualized" ]; then

    hcp create cluster kubevirt \
    --name $CLUSTER_NAME \
    --release-image $RELEASE_IMAGE \
    --node-pool-replicas $WORKER_COUNT \
    --pull-secret $PULL_SECRET \
    --ssh-key $SSH_KEY \
    --memory $MEM \
    --cores $CPU \
    --control-plane-availability-policy $CP_DEPLOYMENT_MODE \
    --infra-availability-policy $INFRA_DEPLOYMENT_MODE

  elif [ $NETWORK_DEPLOYMENT_MODE == "dedicated" ]; then

    hcp create cluster kubevirt \
    --name $CLUSTER_NAME \
    --release-image $RELEASE_IMAGE \
    --node-pool-replicas $WORKER_COUNT \
    --pull-secret $PULL_SECRET \
    --ssh-key $SSH_KEY \
    --memory $MEM \
    --cores $CPU \
    --control-plane-availability-policy $CP_DEPLOYMENT_MODE \
    --infra-availability-policy $INFRA_DEPLOYMENT_MODE \
    --base-domain $BASE_DOMAIN

  else

    echo "Inputs errors"

  fi

elif [ $OPERATION == "node-pool-creation" ]; then

  echo "node-pool"

else

  echo "Inputs errors"

fi