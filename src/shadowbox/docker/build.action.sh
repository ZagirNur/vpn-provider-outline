#!/bin/bash -eu
#
# Copyright 2018 The Outline Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export DOCKER_CONTENT_TRUST="${DOCKER_CONTENT_TRUST:-1}"
# Enable Docker BuildKit (https://docs.docker.com/develop/develop-images/build_enhancements)
export DOCKER_BUILDKIT=1

# Docker image build architecture. Supported architectures: x86_64, arm64
export ARCH=${ARCH:-x86_64}

# Newer node images have no valid content trust data.
# Pin the image node:16.18.0-alpine3.16 by hash.
# See image at https://hub.docker.com/_/node/tags?page=1&name=18.18.0-alpine3.18


# Doing an explicit `docker pull` of the container base image to work around an issue where
# Travis fails to pull the base image when using BuildKit. Seems to be related to:
# https://github.com/moby/buildkit/issues/606 and https://github.com/moby/buildkit/issues/1397
docker pull --disable-content-trust "arm64v8/node:hydrogen-alpine"
docker buildx create --name mybuilder --use
docker buildx inspect mybuilder --bootstrap

docker buildx build --disable-content-trust --platform linux/arm64 \
  --build-arg ARCH="arm64" \
  --build-arg NODE_IMAGE="arm64v8/node:hydrogen-alpine" \
  --build-arg GITHUB_RELEASE="${TRAVIS_TAG:-none}" \
  -f src/shadowbox/docker/Dockerfile \
  -t "${SB_IMAGE:-outline/shadowbox}" \
  "${ROOT_DIR}" \
  --push

