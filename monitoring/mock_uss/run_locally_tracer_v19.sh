#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if [ -z "${DO_NOT_BUILD_MONITORING}" ]; then
  "${SCRIPT_DIR}/../build.sh" || exit 1
fi

MOCK_CONTAINER_NAME="mock_uss_tracer_v19" \
MOCK_USS_RID_VERSION="F3411-19" \
MOCK_USS_DSS_URL="http://host.docker.internal:8082" \
PORT=8088 \
"${SCRIPT_DIR}/run_locally_tracer.sh" "$@"