FROM alpine:latest

RUN apk add --update git bash wget openssl groff less python py-pip jq perl openssh make
RUN pip install --upgrade pip
RUN pip install --quiet awscli

# https://hub.docker.com/r/azuresdk/azure-cli-python/~/dockerfile/
ENV JP_VERSION="0.1.3"
ENV AZURE_CLI_VERSION="2.0.52"
RUN apk add --no-cache bash openssh ca-certificates curl openssl \
 && apk add --no-cache --virtual .build-deps gcc make openssl-dev libffi-dev musl-dev python-dev \
 && curl https://github.com/jmespath/jp/releases/download/${JP_VERSION}/jp-linux-amd64 -o /usr/local/bin/jp \
 && chmod +x /usr/local/bin/jp \
 && pip install --no-cache-dir --upgrade jmespath-terminal \
 && pip install azure-cli==${AZURE_CLI_VERSION} \
 && apk del .build-deps

# https://github.com/hashicorp/docker-hub-images/blob/master/packer/Dockerfile-light
ENV PACKER_VERSION=1.3.3
ENV PACKER_SHA256SUM=2e3ea8f366d676d6572ead7e0c773158dfea0aed9c6a740c669d447bcb48d65f

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS ./

RUN sed -i '/.*linux_amd64.zip/!d' packer_${PACKER_VERSION}_SHA256SUMS
RUN sha256sum -cs packer_${PACKER_VERSION}_SHA256SUMS
RUN unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin
RUN rm -f packer_${PACKER_VERSION}_linux_amd64.zip

# https://github.com/hashicorp/docker-hub-images/blob/master/terraform/Dockerfile-light
# https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_SHA256SUMS
ENV TERRAFORM_VERSION=0.11.11
ENV TERRAFORM_SHA256SUM=94504f4a67bad612b5c8e3a4b7ce6ca2772b3c1559630dfd71e9c519e3d6149c

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS ./

RUN echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin
RUN rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# irrelevant
CMD ["/bin/ash"]
