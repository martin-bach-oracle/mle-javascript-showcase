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
    echo ERR: must either have docker or podman installed
    exit 1
fi

# get the latest image version based on the processor's architecture
# this should prevent you from pulling the wrong image
ARCH=$(uname -p)
IMAGEVERSION=undefined

if [[ ${ARCH} == aarch64 || ${ARCH} == arm ]]; then
    # still waiting for the 23.8 ARM image  to be released
    IMAGEVERSION=23.7.0.0-arm64
elif [[ ${ARCH} == aarch64 || ${ARCH} == arm ]]; then
    IMAGEVERSION=23.8.0.0-amd64
fi

# start the database
${CONTAINER_RUNTIME} run \
--rm \
--name=mleshowcase \
--env ORACLE_PWD=secret \
--detach \
--publish 1521:1521 \
--volume ./01_setup/init:/opt/oracle/scripts/startup \
container-registry.oracle.com/database/free:${IMAGEVERSION}

# show the container status, should be healthy
sleep 5 && ${CONTAINER_RUNTIME} ps

echo INFO: DONE