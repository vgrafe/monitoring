#!/usr/bin/env bash

set -eo pipefail
set -o xtrace

# Find and change to repo root directory
OS=$(uname)
if [[ "$OS" == "Darwin" ]]; then
	# OSX uses BSD readlink
	BASEDIR="$(dirname "$0")"
else
	BASEDIR=$(readlink -e "$(dirname "$0")")
fi
cd "${BASEDIR}/.." || exit 1

if [ -z "${DO_NOT_BUILD_MONITORING}" ]; then
  monitoring/build.sh || exit 1
  export DO_NOT_BUILD_MONITORING=true
fi

action=${1:?The action must be specified as --check or --generate}

# shellcheck disable=SC2086
docker run --name type_schema_manager \
  --rm \
  -v "$(pwd):/app" \
  interuss/monitoring \
  python /app/schemas/manage_type_schemas.py "${action}"
