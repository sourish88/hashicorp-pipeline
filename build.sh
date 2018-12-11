#!/bin/bash -e

THIS_SCRIPT=${BASH_SOURCE[0]:-$0}
if [[ -L "${THIS_SCRIPT}" ]]; then
  THIS_SCRIPT=$(readlink "${THIS_SCRIPT}" 2>&1)
fi
SCRIPT_HOME="$( cd "$( dirname "${THIS_SCRIPT}" )/" && pwd )"

# git@github.com:jenkins201/terraform-iac.git
# https://github.com/jenkins201/terraform-iac.git
GITHUB_URL=$(git remote get-url origin)
#GITHUB_URL="https://github.com/jenkins201/terraform-iac.git"
GITHUB_REGEX="(git@github.com:|https://github.com/)([a-zA-Z0-9]+)/([a-zA-Z0-9\-]+).git"
if [[ $GITHUB_URL =~ $GITHUB_REGEX ]]; then
  export GITHUB_ORG="${BASH_REMATCH[2]}"
  export GITHUB_PROJECT="${BASH_REMATCH[3]}"
else
  echo "ERROR: Can't detect GITHUB_ORG and GITHUB_PROJECT"
  exit 2
fi

docker build -f Dockerfile -t ${GITHUB_ORG}/${GITHUB_PROJECT} .
docker push ${GITHUB_ORG}/${GITHUB_PROJECT}:latest
