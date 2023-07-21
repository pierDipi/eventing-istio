#!/usr/bin/env bash

repo_root_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/..

export SKIP_INITIALIZE=true
export GOPATH=/tmp/go
export GOCACHE=/tmp/go-cache
export ARTIFACTS=${ARTIFACT_DIR:-$(mktemp -u -t -d)}

pushd "${repo_root_dir}/third_party/eventing"
echo "Apply eventing submodule patches"
git apply -v ../../openshift/submodule-patches/eventing/*
popd

"${repo_root_dir}/test/e2e-tests.sh"
