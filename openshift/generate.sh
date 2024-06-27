#!/usr/bin/env bash

set -euo pipefail

repo_root_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/..

release=$(yq r openshift/project.yaml project.tag)
release=${release/knative/release}

function resolve_resources(){
  echo $@

  local dir=$1
  local resolved_file_name=$2

  local version=${release/release-/}

  echo "Writing resolved yaml to $resolved_file_name"

  for yaml in "$dir"/*.yaml; do
    echo "Resolving ${yaml}"

    echo "---" >> "$resolved_file_name"

    sed \
        -e "s+eventing.knative.dev/release: devel+eventing.knative.dev/release: ${version}+" \
        -e "s+app.kubernetes.io/version: devel+app.kubernetes.io/version: ${version}+" \
        "$yaml" >> "$resolved_file_name"
  done
}

"${repo_root_dir}/hack/update-deps.sh"

tmp_dir=$(mktemp -d)
git clone --branch main https://github.com/openshift-knative/hack "$tmp_dir"

pushd "$tmp_dir"
go install github.com/openshift-knative/hack/cmd/generate
popd

rm -rf "$tmp_dir"

$(go env GOPATH)/bin/generate \
  --root-dir "${repo_root_dir}" \
  --generators dockerfile \
  --excludes "vendor.*" \
  --excludes "third_party.*" \
  --images-from eventing \
  --images-from eventing-kafka-broker

"$repo_root_dir/hack/update-codegen.sh"

rm -rf "${repo_root_dir}/openshift/release/artifacts"
mkdir -p "${repo_root_dir}/openshift/release/artifacts"
resolve_resources "${repo_root_dir}/config/eventing-istio/roles" "${repo_root_dir}/openshift/release/artifacts/eventing-istio-controller.yaml"
resolve_resources "${repo_root_dir}/config/eventing-istio/controller" "${repo_root_dir}/openshift/release/artifacts/eventing-istio-controller.yaml"
