#!/bin/bash

# Configuration - Replace with your actual values
NAMESPACE="ingress-nginx"
DEV_CONTEXT="sharedServices-dev-eks-multiaz-cluster-01"
PROD_CONTEXT="shared-service-prod-eks-multiaz-cluster-01"

check_health() {
    local CONTEXT=$1
    local CLUSTER_NAME=$2

    # Fetch the ingress controller pod name
    INGRESS_CONTROLLER_POD_NAME=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=ingress-nginx -o jsonpath="{.items[0].metadata.name}" --context $CONTEXT)

    if [ -z "$INGRESS_CONTROLLER_POD_NAME" ]; then
        echo "Failed to get the ingress controller pod name for context $CONTEXT"
        exit 1
    fi

    # Define the command to check health
    COMMAND="kubectl exec -n $NAMESPACE $INGRESS_CONTROLLER_POD_NAME --context $CONTEXT -- curl -s http://localhost:10254/healthz"

    # Execute the command
    RESULT=$(eval $COMMAND)

    # Print the result
    echo "Health Check Result for $CLUSTER_NAME: $RESULT"

    # Check if the result indicates healthy status
    if [ "$RESULT" == "ok" ]; then
        echo "Ingress NGINX in $CLUSTER_NAME is healthy."
    else
        echo "Ingress NGINX in $CLUSTER_NAME is not healthy: $RESULT"
        exit 1
    fi
}

# Check health in the development cluster
check_health $DEV_CONTEXT "Development Cluster"

# Check health in the production cluster
check_health $PROD_CONTEXT "Production Cluster"