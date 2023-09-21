#!/bin/sh

readonly OCI_REPOSITORY=$1
readonly BAZELISK_VERSION=$2
readonly TAG=$3

set -o errexit -o nounset -o pipefail

function print_usage() {
    >&2 echo "Usage: $0 <OCI_REPOSITORY> <BAZELISK_VERSION> <TAG>"
}

if [ -z "${OCI_REPOSITORY}" ]; then
    >&2 echo "ERROR: missing 'OCI_REPOSITORY' argument"
    print_usage
    exit 1
fi

if [ -z "${BAZELISK_VERSION}" ]; then
    >&2 echo "ERROR: missing 'BAZELISK_VERSION' argument"
    print_usage
    exit 1
fi

if [ -z "${TAG}" ]; then
    >&2 echo "ERROR: missing 'TAG' argument"
    print_usage
    exit 1
fi

readonly GIT_ROOT=$(git rev-parse --show-toplevel)

docker buildx build \
    --platform linux/arm64,linux/amd64 \
    --file "${GIT_ROOT}/build-container/Dockerfile" \
    --tag "${OCI_REPOSITORY}:${TAG}" \
    --tag "${OCI_REPOSITORY}:latest" \
    --push \
    --build-arg BAZELISK_VERSION="${BAZELISK_VERSION}" \
    "${GIT_ROOT}"
