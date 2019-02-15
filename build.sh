#!/bin/bash -e

THIS_SCRIPT=${BASH_SOURCE[0]:-$0}
if [[ -L "${THIS_SCRIPT}" ]]; then
  THIS_SCRIPT=$(readlink "${THIS_SCRIPT}" 2>&1)
fi
SCRIPT_HOME="$( cd "$( dirname "${THIS_SCRIPT}" )/" && pwd )"


get_git_branch () {
  # output the current branch, handling detached HEAD as found in Jenkins
  # https://stackoverflow.com/questions/6059336/how-to-find-the-current-git-branch-in-detached-head-state
  local GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  # Jenkins will often checkout the SHA of a branch, (detached HEAD)
  if [[ "${GIT_BRANCH}" == 'HEAD' ]]; then
    # lookup branch against remotes, without network access (we may not have creds to talk to git remote)
    echo "$(git branch --remote --verbose --no-abbrev --contains | sed -Ene 's/^[^\/]*\/([^\ ]+).*$/\1/p')"
  else
    echo "${GIT_BRANCH}"
  fi
}

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


GIT_BRANCH=$(get_git_branch)
GIT_DIRTY=$([[ -z $(git status -s) ]] || echo '-DIRTY')
IMAGE_TAG=$(echo ${GIT_BRANCH}${GIT_DIRTY} | tr  :/ -)
IMAGE_NAME="${GITHUB_ORG}/${GITHUB_PROJECT}"

docker build -f Dockerfile -t ${GITHUB_ORG}/${GITHUB_PROJECT}:${IMAGE_TAG} .

if [ "${IMAGE_TAG}" == 'master' ]; then
  docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${IMAGE_NAME}:latest"
  docker push ${GITHUB_ORG}/${GITHUB_PROJECT}:latest
else
  echo "IMAGE_TAG=${IMAGE_TAG}"
  docker push "${IMAGE_NAME}:${IMAGE_TAG}"
fi
