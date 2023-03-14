#!/usr/bin/env bash

repo_root_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/..

GO111MODULE=off go get -u github.com/openshift-knative/hack/cmd/generate

generate \
  --root-dir "${repo_root_dir}" \
  --generators dockerfile \
  --excludes "vendor.*" \
  --excludes "third_party.*"

"$repo_root_dir/hack/update-codegen.sh"
