#!/bin/sh

# GitHub Action Parameters
export IBMCLOUD_APIKEY="$1" # - IBM Cloud API Key
export IBMCLOUD_REGION="$2" # - IBM Cloud Region
export CLUSTER_NAME="$3" # - Name of cluster to be (re)deployed

export INGRESS_IP="86.7.30.9"
export INGRESS_PORT="5309"

cd ~; pwd
ls -al ~
whoami

echo "Cluster $CLUSTER_NAME creation complete!"
echo "Ingress is available at $INGRESS_IP:$INGRESS_PORT"
echo "::set-output name=ingress-ip::$INGRESS_IP"
echo "::set-output name=ingress-port::$INGRESS_PORT"

# Output kubeconfig file
echo "::set-output name=kubeconfig::$(echo -e 'line1:\n  line2:\n    - end: "test"'|base64)"
