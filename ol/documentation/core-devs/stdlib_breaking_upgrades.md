# Stdlib: Breaking upgrades

## Reproduction

branch `break-upgrade`

## How to break an upgrade

Upgrades break by changing the fields on a `resource struct` which is used in a function. Either adding a new field or removing a previous field will cause a failure. If the upgrade is executed through the usual oracle process the network will halt and be in an unrecoverable state.

The module Epoch.move has a breaking version called Epoch.break, for testing.

A stdlib binary is created using the .break version, and is placed in /fixtures/upgrade_payload/break_stdlib.mv

To simulate a change of schema (which breaks stdlib upgrades) the Epoch.break adds a `dummy: bool` to the struct Timer. This causes an unrecoverable failure on the network.
 
```
  resource struct Timer { 
    epoch: u64,
    height_start: u64,
    seconds_start: u64,
    //// TESTING UPGRADE ///
    dummy: bool,
  }
```

### Create break_stdlib.mv

Create a `break_stdlib.mv` file by:

1. uncomment the last lines in Upgrade.move to enable the foo() command. (as per a working stdlib.mv test fixture).
2. rename Epoch.move Epoch.safe
3. rename Epoch.break -> Epoch.move
4. compile stdlib with `cargo run --release -p stdlib`
5. concatenate files with `cargo run --release -p stdlib -- --create-upgrade-payload`

NOTE: After building the fixtures REMEMBER TO REVERSE THE CHANGES AND REBUILD STDLIB BEFORE COMMITTING CHANGES


## With e2e tests

Run the test_breaking_upgrade test, which simulates four validators, with three voting. 

`/e2e_testsuite> cargo test test_breaking_upgrade`

You should then see:

````
thread 'tests::ol_upgrade_oracle::test_breaking_upgrade' panicked at 'Executing block prologue should succeed: ERROR { status_code: UNEXPECTED_ERROR_FROM_KNOWN_MOVE_FUNCTION }', language/testing-infra/e2e-tests/src/executor.rs:316:14
stack backtrace:
```

## With Swarm

1. Start a swarm of one validator, [link to instructions].
2. Swarm will prompt for mnemonic. Use `alice` account (see fixtures/mnemonic/alice.mnem file for mnemonic).
3. Submit upgrade tx using the fixtures/upgrade_payload/break_stdlib.mv binary in the transaction.

`oracle upgrade 0 /root/libra/fixtures/upgrade_payload/break_stdlib.mv`

In the log file `swarm_temp/logs/0.log` you should see:

```
ERROR { status_code: MISCELLANEOUS_ERROR }
CORE DUMP
```
