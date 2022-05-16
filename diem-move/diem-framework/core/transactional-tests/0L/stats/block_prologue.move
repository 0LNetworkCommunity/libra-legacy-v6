//# init --validators Alice Bob

// Case 1: Validators are compliant. 
// This test is to check if validators are present after the first epoch.
// Here EPOCH-LENGTH = 15 Blocks.
// NOTE: This test will fail with Staging and Production Constants,
//       only for Debug - due to epoch length.

//# block --proposer Alice --time 1 --round 0