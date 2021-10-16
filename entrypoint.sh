#!/bin/sh

# GitHub Action Parameters
export IBMCLOUD_APIKEY="$1" # - IBM Cloud API Key
export IBMCLOUD_REGION="$2" # - IBM Cloud Region
export CLUSTER_NAME="$3" # - Name of cluster to be (re)deployed

# Install k8s plugin
ibmcloud plugin install container-service

# Login to provided region using the provided API key
ibmcloud login --apikey "$IBMCLOUD_APIKEY" -r "$IBMCLOUD_REGION"

# Set kubernetes endpoint to desired region, and create a new free cluster inside that region.  
ibmcloud ks init --host "https://${IBMCLOUD_REGION}.containers.cloud.ibm.com"

# Configure kubectl
echo "Configuring kubectl..."
ibmcloud ks cluster config -c "$CLUSTER_NAME"

# Get the IP address and port of the ingress service, and output to the github action
INGRESS_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses}' | jq -r '.[] | select(.type=="ExternalIP").address')
INGRESS_PORT=$(kubectl get -n ingress-nginx service/ingress-nginx-controller -o jsonpath='{.spec.ports}' | jq -r '.[] | select(.appProtocol=="http").nodePort')

echo "Cluster $CLUSTER_NAME creation complete!"
echo "Ingress is available at $INGRESS_IP:$INGRESS_PORT"
echo "::set-output name=ingress-ip::$INGRESS_IP"
echo "::set-output name=ingress-port::$INGRESS_PORT"

# Output kubeconfig file in base64
echo "::set-output name=kubeconfig::$(cat ~/.kube/config|base64 -w 0)"
