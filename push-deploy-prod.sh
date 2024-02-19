#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [ -n "$(git status --porcelain)" ]; then
  echo "Please ensure there are no changes or untracked files before rebuilding"
  exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${SCRIPT_DIR}/vars.sh

# Override
export KUBECONFIG=~/.kube/config.ijmacd

for project in "${PROJECTS}"; do
  docker push ${REGISTRY_NAME}/${REPO}/${project}:${GIT_TAG}
done

helm upgrade --install logbook \
  $SCRIPT_DIR/kube/chart/logbook/ \
  --namespace ${APPNAME} --create-namespace \
  -f ${SCRIPT_DIR}/kube/chart/logbook/overrides.prod.yaml \
  --set web.repository.tag=${GIT_TAG}
