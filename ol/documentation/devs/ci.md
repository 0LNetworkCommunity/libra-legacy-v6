
# CI

0L runs its own continuous integration tests using Githunb Actions, but not upstream tests.

The files that automate thes can be found in `./.github/workflows/*yaml`

The relevant 0L test suites are:
1. Move "functional" tests
2. E2E tests
3. 0L tooling tests
4. 0L Integration Tests


## 1. Move "functional" tests

These are our tests, adapted from upstream.

Run with:
```
cd language/move-lang/functional-tests && cargo test 0L
```

See writing_vm_tests.md

## 2. E2E tests
These are lower level tests that can be done when the higher level functional testsuite don't provide sufficient flexibility. The 0L tests are adapted from upstream.

See writing_vm_tests.md


```
cd language/e2e-testsuite && cargo test ol
```


## 3. 0L tooling tests

These are predominantly unit test style tests in idividual 0L components which are separate from upstream.

Each 0L cli executable is found under `./ol`, for each one run `cargo t` to run all tests.

## 4. 0L Integration Tests

These were created by 0L, and are simple Makefiles to drive 0L command line tools against a "swarm".

```
cd ol/integration-tests
# miner tests

make -f ol/integration-tests/test-mining.mk test

# autopay test submit all types of txs
make -f ol/integration-tests/test-autopay.mk test
# autopay payment completion:  percent of balance
make -f ol/integration-tests/test-autopay.mk test-percent-bal
# autopay payment completion: fixed one time
make -f ol/integration-tests/test-autopay.mk test-fixed-once

# onboarding new accounts tests
make -f ol/integration-tests/test-onboard.mk test

# upgrade the stdlib via oracle tests
make -f ol/integration-tests/test-upgrade.mk test
```


Note: This repo does not run upstream tests given the need for sophisticated testing infrastructure. Though this is planned at a later date.