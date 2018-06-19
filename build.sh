#!/bin/bash

THIS_SCRIPT=${BASH_SOURCE[0]:-$0}
if [[ -L "${THIS_SCRIPT}" ]]; then
  THIS_SCRIPT=$(readlink "${THIS_SCRIPT}" 2>&1)
fi
SCRIPT_HOME="$( cd "$( dirname "${THIS_SCRIPT}" )/" && pwd )"

GITHUB_URL=""
GITHUB_ORG=""
GITHUB_PROJECT=""

docker build -f Dockerfile -t jenkins201/hashicorp-ci .
docker push jenkins201/hashicorp-ci:latest
