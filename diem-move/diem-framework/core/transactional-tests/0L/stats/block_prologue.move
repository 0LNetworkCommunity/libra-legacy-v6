// Case 1: Validators are compliant. 
// This test is to check if validators are present after the first epoch.
// Here EPOCH-LENGTH = 15 Blocks.
// NOTE: This test will fail with Staging and Production Constants, only for Debug - due to epoch length.

//# init --validators Alice
//! account: bob, 1000000, 0, validator


//! block-prologue
//! proposer: alice
//! block-time: 1
