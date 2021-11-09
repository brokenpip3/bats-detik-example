#!/usr/bin/env bats

setup() {
    load 'common-setup'
    _common_setup
}

k_inside_curl() {
  ${KUBECTL} exec -it deploy/"$1" -- curl "$2"
}

k_port_forward(){
  ${KUBECTL} port-forward svc/"$1" "$2"  > /dev/null 2>&1 &
  pid=$!
  sleep 0.5
  export pf_pid=$pid
}

@test "Verifying that my-dog is up and running checking liveness from inside" {
    # Skip if the application was not deployed
    [[ ! -f "${PROJECT_ROOT}/tests.status.tmp" ]] && skip "My-Dog was not correctly deployed"
    run k_inside_curl my-dog localhost:9080/healthz
    assert_success
}

@test "Verifying that my-dog is up and running checking liveness from inside with correct output" {
    # Skip if the application was not deployed
    [[ ! -f "${PROJECT_ROOT}/tests.status.tmp" ]] && skip "My-Dog was not correctly deployed"
    run k_inside_curl my-dog localhost:9080/healthz
    assert_output 'OK'
}

@test "Verifying that my-dog is up and running from inside" {
    [[ ! -f "${PROJECT_ROOT}/tests.status.tmp" ]] && skip "My-Dog was not correctly deployed"
    run k_inside_curl my-dog localhost:8080
    assert_success
}

@test "Verifying that my-dog endpoint reply with the right data from inside" {
    [[ ! -f "${PROJECT_ROOT}/tests.status.tmp" ]] && skip "My-Dog was not correctly deployed"
    run k_inside_curl my-dog localhost:8080
    assert_output 'My Dog Deployment'
}

@test "Verifying that my-dog json endpoint reply with the right json data from inside" {
    [[ ! -f "${PROJECT_ROOT}/tests.status.tmp" ]] && skip "My-Dog was not correctly deployed"
    run k_inside_curl my-dog localhost:8080/json
    assert_output '{"data":"My Dog Deployment"}'
}

@test "Verifying that my-dog json endpoint reply with the right json data from outside" {
    [[ ! -f "${PROJECT_ROOT}/tests.status.tmp" ]] && skip "My-Dog was not correctly deployed"
    k_port_forward my-dog-svc 8080:8080
    run curl -s localhost:8080/json && kill ${pf_pid} || kill ${pf_pid}
    assert_output '{"data":"My Dog Deployment"}'
}

@test "clean the test environment" {
	rm "${PROJECT_ROOT}/tests.status.tmp"
}
