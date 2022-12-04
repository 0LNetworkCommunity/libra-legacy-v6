
## Run forge tests
cargo r -p forge-cli -- test local-swarm

## run smoke tests
`cargo x` is a libra hack and runs the compilation and tests in the foreground.

cargo x test --package smoke-test -- `<test name>`

### get list of smoke tests
cargo x test --package smoke-test -- --list