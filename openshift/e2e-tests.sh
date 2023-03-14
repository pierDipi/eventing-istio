#!/usr/bin/env bash

repo_root_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/..

export SKIP_INITIALIZE=true
"${repo_root_dir}/test/e2e-tests.sh"
