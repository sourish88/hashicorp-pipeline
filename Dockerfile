FROM microsoft/azure-cli:2.0.52
COPY --from=hashicorp/terraform:0.11.14 /bin/terraform /bin/terraform
COPY --from=hashicorp/packer:1.3.5 /bin/packer /bin/packer

# WARNING USE_PROXY just needs to be set to use a proxy, actual value is ignored
ARG USE_PROXY
ENV http_proxy=${USE_PROXY:+'http://squid:3128'}
ENV https_proxy=${USE_PROXY:+'http://squid:3128'}

RUN apk add --update git bash wget openssl groff less python py-pip jq perl openssh make ca-certificates curl
RUN pip install --upgrade pip
RUN pip install --quiet awscli

# irrelevant
CMD ["/bin/ash"]
