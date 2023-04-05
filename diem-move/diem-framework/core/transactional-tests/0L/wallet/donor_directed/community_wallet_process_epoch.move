//# init --validators Alice Bob Carol Dave

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DonorDirected;
    use Std::Vector;

    fun main(_dr: signer, sender: signer) {
      DonorDirected::init_donor_directed(&sender, @Bob, @Carol, @Dave, 2);
      DonorDirected::finalize_init(&sender);
      let list = DonorDirected::get_root_registry();
      assert!(Vector::length(&list) == 1, 7357001);

      assert!(DonorDirected::is_donor_directed(@Alice), 7357002);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::DonorDirected;
    
    fun main(_dr: signer, sender: signer) {
      let uid = DonorDirected::propose_payment(&sender, @Alice, @Bob, 100, b"thanks bob");
      let (found, idx, status_enum, completed) = DonorDirected::get_multisig_proposal_state(@Alice, &uid);

      assert!(found, 7357004);
      assert!(idx == 0, 7357005);
      assert!(status_enum == 1, 7357006);
      assert!(!completed, 7357007);

      // it is not yet scheduled, it's still only a proposal by a donor directed wallet.
      assert!(!DonorDirected::is_scheduled(@Alice, &uid), 7357003);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::DonorDirected;
    use Std::Vector;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    // // use DiemFramework::Debug::print;
    
    fun main(_dr: signer, sender: signer) {
      let uid = DonorDirected::propose_payment(&sender, @Alice, @Bob, 100, b"thanks bob");
      let (found, idx, status_enum, completed) = DonorDirected::get_multisig_proposal_state(@Alice, &uid);

      assert!(found, 7357004);
      assert!(idx == 0, 7357005);
      assert!(status_enum == 1, 7357006);
      assert!(completed, 7357007);

      // Now it's scheduled since we got over the threshold
      assert!(DonorDirected::is_scheduled(@Alice, &uid), 7357003);

      // the default timed payment is 3 epochs, we are in epoch 1
      let list = DonorDirected::find_by_deadline(@Alice, 4);
      assert!(Vector::contains(&list, &uid), 7357008);
      // // print(&list);

      let bob_balance_pre = DiemAccount::balance<GAS>(@Bob);
      // // print(&bob_balance_pre);
      assert!(bob_balance_pre == 10000000, 7357004);
    }
}
// check: EXECUTED

//////////////////////////////////////////////
//// Trigger reconfiguration at 61 seconds ///
//# block --proposer Alice --time 61000000 --round 15

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////

//////////////////////////////////////////////
//// Trigger reconfiguration at 61 seconds ///
//# block --proposer Alice --time 122000000 --round 30

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////

//////////////////////////////////////////////
//// Trigger reconfiguration at 61 seconds ///
//# block --proposer Alice --time 200000000 --round 90

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////

//////////////////////////////////////////////
//// Trigger reconfiguration at 61 seconds ///
//# block --proposer Alice --time 270000000 --round 90

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////


//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    // use DiemFramework::DonorDirected;
    // use Std::Vector;
    // use DiemFramework::Debug::print;

    fun main(_vm: signer, _: signer) {
      // EpochBoundary::reconfigure(&vm);


      // process epoch 2 accounts
      // DonorDirected::process_donor_directed_accounts(&vm, 2);

      let bob_balance = DiemAccount::balance<GAS>(@Bob);
      // print(&bob_balance);
      // assert!(bob_balance > bob_balance_pre, 7357005);
      assert!(bob_balance == 10000100, 7357006);


      // // in testnet the veto window duration is 1 epoch from current epoch
      // let list = DonorDirected::find_by_deadline(@Alice, 2);
      // assert!(Vector::contains(&list, &uid), 7357008);

    }
}
// check: EXECUTED

