#!/usr/bin/env bash

#
# database.sh
#
# Quick setup of a local database running in a container. Not persisted,
# use for the purpose of the showcase only. If possible, use the Codespace
# instead
#

set -euxo pipefail

# optional database password for all administrative accounts
DB_PASSWORD=${1:-changeOnInstall}

# determine the correct container runtime
CONTAINER_RUNTIME=none

which docker && CONTAINER_RUNTIME=docker
which podman && CONTAINER_RUNTIME=podman

if [[ ${CONTAINER_RUNTIME} == none ]]; then
    echo ERR: must either have docker or podman installed or in the path
    exit 1
fi

# start the database
${CONTAINER_RUNTIME} run \
--rm \
--name=mleshowcase \
--env ORACLE_PASSWORD="${DB_PASSWORD}" \
--detach \
--publish 1521:1521 \
--volume ./01_setup/init:/opt/oracle/scripts/startup \
docker.io/gvenzl/oracle-free:23.26.0

# show the container status, should be healthy
sleep 15 && ${CONTAINER_RUNTIME} ps

echo INFO: DONE