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
ENV PACKER_VERSION=1.3.5
ENV PACKER_SHA256SUM=14922d2bca532ad6ee8e936d5ad0788eba96f773bcdcde8c2dc7c95f830841ec

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS ./

RUN sed -i '/.*linux_amd64.zip/!d' packer_${PACKER_VERSION}_SHA256SUMS
RUN sha256sum -cs packer_${PACKER_VERSION}_SHA256SUMS
RUN unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin
RUN rm -f packer_${PACKER_VERSION}_linux_amd64.zip

# This is the Hashicorp public key: https://www.hashicorp.com/security
# https://github.com/hashicorp/terraform/blob/master/scripts/docker-release/releases_public_key
COPY releases_public_key .

# What's going on here?
# - Download the indicated release along with its checksums and signature for the checksums
# - Verify that the checksums file is signed by the Hashicorp releases key
# - Verify that the zip file matches the expected checksum
# - Extract the zip file so it can be run
#
# https://github.com/hashicorp/terraform/blob/master/scripts/docker-release/Dockerfile-release

ENV TERRAFORM_VERSION=0.11.14
RUN echo Building image for Terraform ${TERRAFORM_VERSION} && \
    apk add --update git curl openssh gnupg && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig > terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS > terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    gpg --import releases_public_key && \
    gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    grep linux_amd64 terraform_${TERRAFORM_VERSION}_SHA256SUMS >terraform_${TERRAFORM_VERSION}_SHA256SUMS_linux_amd64 && \
    sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS_linux_amd64 && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_SHA256SUMS*

# irrelevant
CMD ["/bin/ash"]
