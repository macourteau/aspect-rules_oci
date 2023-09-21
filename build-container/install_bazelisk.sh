#!/bin/bash

set -o errexit -o nounset -o pipefail

export ARCH=${TARGETPLATFORM#*/}

curl \
    --fail \
    --location \
    --remote-name \
    "https://github.com/bazelbuild/bazelisk/releases/download/${BAZELISK_VERSION}/bazelisk-linux-${ARCH}"

mv "bazelisk-linux-${ARCH}" bazelisk
chmod +x bazelisk
