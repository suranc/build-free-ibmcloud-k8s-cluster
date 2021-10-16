FROM alpine

ADD entrypoint.sh /entrypoint.sh

RUN apk add curl jq git
RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
RUN ibmcloud plugin install container-service
ADD https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

ENTRYPOINT ["/entrypoint.sh"]
