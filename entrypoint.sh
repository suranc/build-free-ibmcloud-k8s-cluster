#!/bin/sh

# GitHub Action Parameters
export IBM_APIKEY="$1" # - IBM Cloud API Key
export IBM_REGION="$2" # - IBM Cloud Region
export CLUSTER_NAME="$3" # - Name of cluster to be (re)deployed

# Login to provided region using the provided API key
ibmcloud login --apikey "$IBM_APIKEY" -r "$IBM_REGION"

# Delete existing cluster, if any, and wait for deletion to complete
ibmcloud ks cluster rm -c "$CLUSTER_NAME" -f
while [ $(ibmcloud ks cluster get -c "$CLUSTER_NAME" | egrep '^Name:' | awk '{print $2}') == "$CLUSTER_NAME" ]
do
    echo "Waiting for $CLUSTER_NAME deletion to complete..."
    sleep 10
done

# Set kubernetes endpoint to desired region, and create a new free cluster inside that region.  
ibmcloud ks init --host "https://${IBM_REGION}.containers.cloud.ibm.com"
ibmcloud ks cluster create classic --name "$CLUSTER_NAME"

#Sleep for 10 seconds to give it time to start
sleep 10

# Poll for completion of the cluster creation
while [ $(ibmcloud ks cluster get -c "$CLUSTER_NAME" | egrep '^State:' | awk '{print $2}') != 'normal' ]
do
    echo waiting
    sleep 30
done

# Configure kubectl
echo "Configuring kubectl..."
ibmcloud ks cluster config -c "$CLUSTER_NAME"

# Install nginx ingress controller
kubectl create ns ingress-nginx
helm -n ingress-nginx install ingress-nginx ingress-nginx/ingress-nginx

# Block until nginx ingress controller is ready
sleep 1
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s

# Get the IP address and port of the ingress service, and output to the github action
INGRESS_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses}' | jq -r '.[] | select(.type=="ExternalIP").address')
INGRESS_PORT=$(kubectl get -n ingress-nginx service/ingress-nginx-controller -o jsonpath='{.spec.ports}' | jq -r '.[] | select(.appProtocol=="http").nodePort')

echo "Cluster $CLUSTER_NAME creation complete!"
echo "Ingress is available at $INGRESS_IP:$INGRESS_PORT"
echo "::set-output name=ingress-ip::$INGRESS_IP"
echo "::set-output name=ingress-port::$INGRESS_PORT"