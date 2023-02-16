//# init --validators Alice Bob Carol Dave Eve

// This tests consensus Case 1.
// ALICE is a validator, validated successfully
// put in the lowest bid, but there are enough seats to include her.

//# block --proposer Alice --time 1 --round 0

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Mock;


    fun main(dr:signer, _sender: signer) {
      // all vals compliant
      Mock::all_good_validators(&dr);
      // everyone bids
      Mock::pof_default(&dr);
        
    }
}


//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {  
    use DiemFramework::DiemSystem;
    fun main(_vm: signer, _: signer) {
      assert!(DiemSystem::is_validator(@Alice), 10001);
      
    }
}