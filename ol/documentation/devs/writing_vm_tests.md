# Functional tests
Evaluates Move modules. This exists primarily for testing Move Stdlib files. Tests are written in Move. There are declarations to set up simple mocks, and perform basic system level checks.

Notable exceptions: any test that requires a system level information that is not included in the basic checks, needs to be tested with e2e. This is because the executor in the functional test framework does not run consensus protocols (e.g. voting, validator management, etc). The framework also only keeps shallow copies of related information (i.e. simulated number of validators is 10 by default, even though none of them actually exist to vote on blocks). This test framework is described in [this article from Libra blog](https://libra.org/en-US/blog/how-to-use-the-end-to-end-tests-framework-in-move/) (despite the poor naming convention, the article describes functional tests). E.g. If you need information about the validator-set from blockmetadata. This will not be available in functional-tests, because there is only a "faked" VM with state inserted, and that state does not include validator-sets (as of Jun 20 2020).

Run with:

``` 
# Run the tests
> cd language/move-lang/functional-tests
> cargo test <optional: keyword for test or directory name>
# example
> cargo test 0L

# Are usually parallelized by default. If you suspect side-effects you should disable this. Instead run with:
> cargo test <keyword> -- --test-threads 1
# example
> cargo test 0L -- --test-threads 1


```
### Writing tests
TEST SETUP: If you add a "validator", functional tests will add only that validator to genesis. By default 0L tests load 3 random validators on genesis. This is slow. So adding a dummy validator will only run the initialize_miners once instead of three times, and speeds up testing..
`//! account: dummy-prevents-genesis-reload, 100000 ,0, validator`

# e2e tests
Can test transactions and simulate a network with 10 validators. These tests exist primarily to check system properties by submitting transactions. Tests are written in Rust

Run with:
```
# build your stdlib files first
cd language/stdlib
cargo run -- --no-doc

# run tests 
cd language/e2e-tests
# use xtest custom cargo task with package language-e2e-tests, matching tests by keyword "ol"
cargo xtest -p language-e2e-tests 0L

# or to see all prints
cargo test -p language-e2e-tests -- 0L --nocapture
```

## Writing tests:
Different than Cargo. New test are not automatically discovered on test runs. You must update `e2e-tests/src/tests.rs` with the FILENAME of your test which sits in `e2e-test/src/tests`

#### using custom transaction scripts in your e2e tests.

[WARNING There's some seriously tedious set up involved here.]



Create a new .move file and place your script in language/stdlib/src/transaction-scripts
Then you must MAP the name of that FILENAME to a module name, for the rust test runner in e2e. There are THREE places in this file your module needs to be included.

NOTE: Whenever you change transaction-scripts, there are multiple places you need to change. If you remove, or comment out a transaction script, you also need to chase down the mappings and remove them.

./language/stdlib/src/transaction_scripts.rs

This looks like this:

```
impl fmt::Display for StdlibScript {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        use StdlibScript::*;
        write!(
            f,
            "{}",
            match self {
                AddValidator => "add_validator",
                AddCurrencyToAccount => "add_currency_to_account", // MODULE NAME => FILENAME.move
                Burn => "burn",
```

Then you need to go back to the e2e folder, and create *another* helper file in rust, to be able to execute that Move script in the test runner.

For example:

./language/e2e-tests/src/librablock_setup.rs

```
pub fn librablock_helper_tx(
    sender: &Account,
    new_account: &Account,
    seq_num: u64,
) -> SignedTransaction {
    let mut args: Vec<TransactionArgument> = Vec::new();

    sender.create_signed_txn_with_args(
        StdlibScript::LibraBlockTestHelper
            .compiled_bytes()
            .into_vec(),
        vec![lbr_type_tag()], // TODO: what is this parameter, and why do we need to pass an lbr type? Fails if removed.
        args, //TODO: Why does args not match the previous param ty_args in length?
        seq_num,
        gas_costs::TXN_RESERVED * 3,
        0,
        LBR_NAME.to_owned(),
    )
}

```

Next, you need to export this module in e2e-tests/src/lib.rs

```
pub mod librablock_setup;
pub mod txfee_setup;
```

Finally, cargo needs to be able to recognize that your test is actually a test. Add the name of your test file to e2e-tests/src/tests.rs

```
mod librablock_test;
mod transaction_fees_new;
```
