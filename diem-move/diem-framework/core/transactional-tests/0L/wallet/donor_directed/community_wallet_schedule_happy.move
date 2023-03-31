//# init --parent-vasps Dummy Alice Dummy2 Bob Dummy3 Carol Dummy4 Dave
// Dummy, Dummy2:     validators with 10M GAS
// Alice, Bob:    non-validators with  1M GAS

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
    }
}
// check: EXECUTED