# Stdlib Upgrade payload

## Hot Upgrades for production

Generate a stdlib file which can be used in the Upgrade Oracle.

0. Run the stdlib build.

You need a newly compiled stdlib, otherwise you risk using stale code.

 `cargo run --release -p stdlib`
 
1. Create a concatenated stdlib.mv file.

`cargo run --release -p stdlib -- --create-upgrade-payload`

- this should write a stdlib file to `language/stdlib/staged/stdlib.mv`


## e2e Testing
The e2e test simulates the oracle process, by updating the stdlib to include a new function, foo().

### Generate fixtures.
On every major Stdlib refactor (including renaming of *resource structs*), new fixtures for e2e tests need to be generated.
The main fixtures is a `fixture_upgraded_stdlib.mv`.
The important feature of this file is that it is essentially identical to the stdlib (in development) with one exception, it contains a function foo() which is only located in it.

1. Uncomment the code at the end of Upgrade.move, which includes foo()

2. Run the stdlib compiler to include stdlib with the dummy function in Upgrade.

`cargo run --release`

3. Create a concatenated stdlib.mv file.

`cargo run --release -- --create-upgrade-payload`

- this should write a stdlib file to stdlib/staged/

4. Copy concatenated file from `stdlib/staged/stdlib.mv`, to `fixtures/upgrade_payload/foo_stdlib.mv`

- `cp language/stdlib/staged/stdlib.mv fixtures/upgrade_payload/foo_stdlib.mv`

5. Important, you must now *comment away* the foo() code again in Upgrade.move.
6. Rebuild stdlib again.  Otherwise the e2e test will be starting from an stdlib which includes foo(), when it should not.
`cargo run --release`
