#!/usr/bin/env bash

repo_root_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/..

"${repo_root_dir}/hack/update-deps.sh"

release=$(yq r openshift/project.yaml project.tag)
release=${release/knative/release}

GO111MODULE=off go get -u github.com/openshift-knative/hack/cmd/generate

generate \
  --root-dir "${repo_root_dir}" \
  --generators dockerfile \
  --excludes "vendor.*" \
  --excludes "third_party.*" \
  --images-from eventing \
  --images-from eventing-kafka-broker

"$repo_root_dir/hack/update-codegen.sh"
