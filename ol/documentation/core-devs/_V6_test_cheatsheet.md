## Build Move Binaries
Usually a safe bet to do this before any tests. Smoketests and Forge tests depend on this step. 

Functional aka transactional tests do not depend on this step (but things could get weird if the binary outputs are not found in the right places).

```
sh ol/util/build-stdlib.sh
```

## Run Functional Move Tests aka Transactional Tests
```
NODE_ENV="test" cargo test -p diem-framework --test ol_transactional_tests <optional keyword>
```

## Run 0L smoke Tests

The 0L smoke tests exists outside of the Diem default smoke tests and Forge suite.

```
cd ol/smoke-tests
cargo test -- --test-threads=1
```
TODO: add a mining test, to replace the e2e shell scripts

# Default Diem Forge and Smoketests
[See documentation here for Diem tests.](./smoke_tests.md)
