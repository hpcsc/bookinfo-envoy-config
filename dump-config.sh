#!/bin/bash

ROOT_DIR=${PWD}

function dump() {
  local TYPE=$1
  DELIMITED_POD_NAMES=$(kubectl get pods --template '{{range .items}}{{.metadata.name}}{{","}}{{end}}')
  IFS=',' read -ra POD_NAMES <<< "${DELIMITED_POD_NAMES}"

  mkdir -p envoy && pushd envoy

  rm -rf ./${TYPE} && mkdir -pv ${TYPE}

  for POD in "${POD_NAMES[@]}"; do
      FILE_NAME=$(echo ${POD} | sed 's/v\([0-9]\).*/v\1/g').json
      echo "=== Dumping proxy config ${TYPE} for ${POD} to ${FILE_NAME}"
      kubectl exec ${POD} -c istio-proxy -- curl -s localhost:15000/${TYPE}?format=json | jq -S -f ${ROOT_DIR}/normalize.jq > ./${TYPE}/${FILE_NAME}
  done

  popd
}

CONFIG_TYPE=${1:-config_dump}

if [ "${CONFIG_TYPE}" != "clusters" ] && [ "${CONFIG_TYPE}" != "listeners" ] && [ "${CONFIG_TYPE}" != "config_dump" ]; then
  echo "=== invalid config type to dump"
  echo "Usage: $0 [clusters|listeners|config_dump], default is config_dump"
  exit 1
fi;

dump ${CONFIG_TYPE}
