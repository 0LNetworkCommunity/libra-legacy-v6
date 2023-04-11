//# init --validators Alice Bob Carol Dave Eve

// This tests consensus Case 1.
// ALICE is a validator.
// DID validate successfully.
// DID mine above the threshold for the epoch.

//# block --proposer Alice --time 1 --round 0

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::RecoveryMode;
    use Std::Vector;

    fun main(vm: signer, _: signer){
      RecoveryMode::test_init_recovery(&vm, Vector::empty<address>(), 2);
      assert!(RecoveryMode::is_recovery(), 7357001);
    }
}


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
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;

    fun main() {
        let starting_balance = 10000000;

        // Rescue mode should not pay validators
        assert!(DiemAccount::balance<GAS>(@Alice) <= starting_balance, 7357000180113);
 
     }
}