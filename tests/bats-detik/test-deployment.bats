#!/usr/bin/env bats

setup() {
    load 'common-setup'
    _common_setup
}

@test "Reseting the debug file if present" {
	reset_debug
}

@test "Create testing namespace" {
    printf "apiVersion: v1\nkind: Namespace\nmetadata:\n  name: %s" "${DETIK_CLIENT_NAMESPACE}" | kubectl apply -f -
    run ${KUBECTL} get ns ${DETIK_CLIENT_NAMESPACE}
    assert_success
	sleep 2
}

@test "Applying the testing resources and check return code" {
    run ${KUBECTL} apply -f ${RES_K8S}/my-dog-deployment.yaml
    assert_success
    # Sleep to let k8s deploy
	sleep 15
}

@test "Verifying PODs number" {
    run verify "there are 4 pods named 'my-dog'"
    assert_success
}

@test "Verifying PODs labels" {
    run verify "'.spec.template.metadata.labels.app' is 'my-dog' for deployment named 'my-dog'"
    assert_success
}

@test "Verifying PODs status 3 times every 30s" {
    # Check every 30s for 3 times if the pods are running, if true continue
	run try "at most 3 times every 30s to get pods named 'my-dog' and verify that 'status' is 'running'"
    assert_success
}

@test "Verifying SVC is present" {
	run verify "there is 1 service named 'my-dog-svc'"
    assert_success
}

@test "Verifying EP is present" {
	run verify "there is 1 endpoints named 'my-dog-svc'"
    assert_success
}

@test "Verifying CM is present" {
    run verify "there is 1 configmap named 'nginx-dog-config'"
    assert_success

    # Tell others tests that all the k8s object are in place
    echo "started" > ${PROJECT_ROOT}/tests.status.tmp
}
