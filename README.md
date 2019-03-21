# hashicorp-pipeline

container with tools for use in a hashicorp based CI/CD pipeline

* awscli from pip
* azure-cli from pip (pinned to 2.0.52)
* jq, perl & python from apk

This uses `alpine:latest` as the base, and then adds in packer & terraform, validating the SHASUM etc where possible.

This repo should trigger an automatic build on docker hub: [https://cloud.docker.com/repository/docker/simonmcc/hashicorp-pipeline](https://cloud.docker.com/repository/docker/simonmcc/hashicorp-pipeline)

## build

    ./build.sh

## test/experiment


    docker run -it --rm simonmcc/hashicorp-pipeline:latest /bin/ash
