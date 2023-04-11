//# init --validators Alice Bob Carol Dave Eve

// This tests that a non-performing validator (Case 4)
// will be removed from the validator set in the next epoch.
// Eve will be case 4.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Mock;


    fun main(dr:signer, _sender: signer) {

      Mock::mock_case_1(&dr, @Alice, 0, 10);
      Mock::mock_case_1(&dr, @Bob, 0, 10);
      Mock::mock_case_1(&dr, @Carol, 0, 10);
      Mock::mock_case_1(&dr, @Dave, 0, 10);
      Mock::mock_case_4(&dr, @Eve, 0, 10);

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
      assert!(DiemSystem::is_validator(@Bob), 10002);
      assert!(DiemSystem::is_validator(@Carol), 10003);
      assert!(DiemSystem::is_validator(@Dave), 10004);
      assert!(DiemSystem::is_validator(@Eve) == false, 10005);
      
    }
}