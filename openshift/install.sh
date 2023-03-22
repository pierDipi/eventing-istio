#!/usr/bin/env bash

function install_eventing_with_mesh() {
    local operator_dir=/tmp/serverless-operator
    git clone --branch main https://github.com/openshift-knative/serverless-operator.git $operator_dir

    pushd $operator_dir || return $?

    export ON_CLUSTER_BUILDS=true
    export DOCKER_REPO_OVERRIDE=image-registry.openshift-image-registry.svc:5000/openshift-marketplace

    make OPENSHIFT_CI="true" TRACING_BACKEND=zipkin images install-strimzi install-kafka-with-mesh || return $?

    popd || return $?
}

install_eventing_with_mesh || exit 1
