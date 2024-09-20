#!/usr/bin/env bash

# Usage: create-release-branch.sh v0.4.1 release-0.4

set -ex # Exit immediately on error.

release=$1
target=$2

# Fetch the latest tags and checkout a new branch from the wanted tag.
git fetch upstream -v --tags
git checkout -b "$target" "$release"

# Remove GH Action hooks from upstream
rm -rf .github/workflows
git commit -sm ":fire: remove unneeded workflows" .github/

# Copy the openshift extra files from the OPENSHIFT/main branch.
git fetch openshift main
git checkout openshift/main -- openshift OWNERS OWNERS_ALIASES Makefile

tag=${target/release-/}
yq write --inplace openshift/project.yaml project.tag "knative-$tag"

# Update submodules to point to midstream repos with correct branch
git submodule set-branch --branch "$target" -- "third_party/eventing"
git submodule set-url -- "third_party/eventing" https://github.com/openshift-knative/eventing.git

git submodule set-branch --branch "$target" -- "third_party/eventing-kafka-broker"
git submodule set-url -- "third_party/eventing-kafka-broker" https://github.com/openshift-knative/eventing-kafka-broker.git

# Generate our OCP artifacts
make generate
git apply openshift/patches/*
git add .
git commit -m "Add openshift specific files."
