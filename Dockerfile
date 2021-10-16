FROM alpine

ADD entrypoint.sh /entrypoint.sh

# Add dependencies
RUN apk add curl jq git openssl

# Install the IBM Cloud cli and kubernetes service plugin
RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
RUN ibmcloud plugin install container-service

# Add kubectl, helm and the nginx ingress controller helm repo
ADD https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sh
RUN helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
RUN helm repo update

ENTRYPOINT ["/entrypoint.sh"]
