# hashicorp-ci

container with packer & terraform for hashicorp based CI/CD pipeline usage

This uses `alpine:latest` as the base, and then add in packer & terraform, using the same technique Hashicorp build there own packer & terraform containers:

* [Packer Docker-light](https://github.com/hashicorp/docker-hub-images/blob/master/packer/Dockerfile-light)
* [Terraform Docker-light](https://github.com/hashicorp/docker-hub-images/blob/master/terraform/Dockerfile-light)


## build

    ./build.sh

## test/experiment


    docker run -it --rm jenkins201/hashicorp-ci:latest /bin/ash
