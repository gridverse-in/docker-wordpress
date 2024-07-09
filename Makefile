export DOCKER_ORG ?= gridverse-in
export DOCKER_TAG ?= latest
export ECR_IMAGE ?= wordpress
export DOCKER_IMAGE ?= gcr.io/$(DOCKER_ORG)/$(ECR_IMAGE)
export DOCKER_IMAGE_NAME ?= $(DOCKER_IMAGE):$(DOCKER_TAG)


# Default install path, if lacking permissions, ~/.local/bin will be used instead
export INSTALL_PATH ?= /usr/local/bin

-include $(shell curl -sSL -o .build-harness "https://cloudposse.tools/build-harness"; echo .build-harness)

.DEFAULT_GOAL := all

.PHONY: all build build-clean install run run/new run/check push


all: init deps build
	@exit 0

## Install dependencies (if any)
deps: init
	@exit 0

## Build docker image
build: export DOCKER_FILE=Dockerfile
build:
	@$(MAKE) --no-print-directory docker/build

## Build docker image with no cache
build-clean: export DOCKER_BUILD_FLAGS=--no-cache
build-clean: build
	@exit 0

.PHONY: rebuild-aws-config rebuild-docs ecr-auth

