# Stdlib Upgrade payload (v5)

## Hot Upgrades for production

Generate a stdlib file which can be used in the Upgrade Oracle.

#### 1. Run the stdlib build.

You need a newly compiled stdlib, otherwise you risk using stale code.

 `ol/util/build-stdlib.sh`
 
#### 2. Create a concatenated stdlib.mv file.

`ol/util/create-upgrade-payload.sh`

- this should write a stdlib file to `language/diem-framework/staged/stdlib.mv`


## e2e Testing

`cargo test -p language-e2e-testsuite -- --nocapture test_successful_upgrade_txs`  

The e2e test simulates the oracle process, by updating the stdlib to include a new function, foo(). 

**Note:** 
The following steps are required when there is a major change in move-stdlib or Move lang etc.. (e.g. upgrade to new diem-core version). Otherwise, this test expected to pass without any code/file change.

### Generate fixtures.
On every major Stdlib refactor (including renaming of *resource structs*), new fixtures for e2e tests need to be generated.
The main fixtures is a `fixture_upgraded_stdlib.mv`.
The important feature of this file is that it is essentially identical to the stdlib (in development) with one exception, it contains a function foo() which is only located in it.

1. - Uncomment the code at the end of Upgrade.move, which includes foo().
   - Remove .e2e extension of `language/diem-framework/modules/0L_transaction_scripts/ol_e2e_test_upgrade_foo_tx.move.e2e`.

2. Build stdlib: `ol/util/build-stdlib.sh`

3. Create a concatenated stdlib.mv file: `ol/util/create-upgrade-payload.sh`.  
   This should write a stdlib file to `stdlib/staged/stdlib.mv`  
   Check: Open `stdlib.mv` as text and search/verify both `ol_oracle_upgrade_foo_tx` and `foo` exist (in different lines).

4. Copy `fn encode_ol_oracle_upgrade_foo_tx_script_function()` from `sdk/transaction-builder/src/stdlib.rs` into `ol_oracle_setup.rs`

5. Copy concatenated file from `language/diem-framework/staged/stdlib.mv`, to `fixtures/upgrade_payload/foo_stdlib.mv`

- `cp language/diem-framework/staged/stdlib.mv ol/fixtures/upgrade_payload/foo_stdlib.mv`

6. Important, you must now *comment away* the foo() code again in Upgrade.move and 
   add `.e2e` extension - rename to `language/diem-framework/modules/0L_transaction_scripts/ol_e2e_test_upgrade_foo_tx.move.e2e`.

7. Rebuild stdlib again. (Otherwise the e2e test will be starting from an stdlib which includes foo(), when it should not)
`ol/util/build-stdlib.sh`
