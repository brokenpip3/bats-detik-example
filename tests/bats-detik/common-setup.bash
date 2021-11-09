#!/usr/bin/env bash
# Following bats best pratices:
# - https://bats-core.readthedocs.io/en/latest/tutorial.html#let-s-do-some-setup
# - https://bats-core.readthedocs.io/en/latest/tutorial.html#avoiding-costly-repeated-setups

_common_setup() {
    load "/lib/bats-assert/load.bash"
    load "/lib/bats-support/load.bash"
    load "/lib/bats-detik/utils.bash"
    load "/lib/bats-detik/detik.bash"
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
    PATH="$PROJECT_ROOT/src:$PATH"

    # Define the context to avoid mistake
    CONTEXT="kind-kind"

    export DETIK_CLIENT_NAME="kubectl"
    export DETIK_CLIENT_NAMESPACE="testing-bats"

    export KUBECTL="kubectl --context=${CONTEXT} -n ${DETIK_CLIENT_NAMESPACE}"

    #kubectl create ns testing-bats
    export RES_K8S="resources/kubernetes"
}
