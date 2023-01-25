As of Jan 23rd 2022, these tests aren't all passing. And some have false positives.
## Run default Forge suite
```
cargo r -p forge-cli -- test local-swarm
```

## run default smoke tests (based on Forge)
`cargo x` is a libra hack and runs the compilation and tests in the foreground.

cargo x test --package smoke-test -- `<test name>`

### get list of default smoke tests
cargo x test --package smoke-test -- --list