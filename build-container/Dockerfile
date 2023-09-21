# ATTENTION: use the build.sh script to build this image.
# ./build.sh <OCI_REPOSITORY> <BAZELISK_VERSION> <TAG>

FROM ubuntu:20.04

ARG TARGETPLATFORM
ARG BAZELISK_VERSION=v1.18.0

RUN --mount=source=build-container/install_packages.sh,target=/mnt/install_packages.sh,type=bind \
  /mnt/install_packages.sh

RUN --mount=source=build-container/install_docker.sh,target=/mnt/install_docker.sh,type=bind \
  /mnt/install_docker.sh

WORKDIR /var/bazel
RUN --mount=source=build-container/install_bazelisk.sh,target=/mnt/install_bazelisk.sh,type=bind \
  /mnt/install_bazelisk.sh
RUN mv /var/bazel/bazelisk /usr/local/bin/bazel

RUN useradd --system --create-home --home-dir=/home/ubuntu --shell=/bin/bash --gid=root --groups=sudo --uid=1000 ubuntu
USER ubuntu
WORKDIR /home/ubuntu
