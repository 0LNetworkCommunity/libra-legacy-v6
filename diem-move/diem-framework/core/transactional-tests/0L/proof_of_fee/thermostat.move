//# init --validators Alice Bob Carol Dave Eve

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::ProofOfFee;

  fun main(_vm: signer, bob_sig: signer) {
    ProofOfFee::set_bid(&bob_sig, 0021, 10); 
  }
}

//# run --admin-script --signers DiemRoot Carol
script {
  use DiemFramework::ProofOfFee;

  fun main(_vm: signer, carol_sig: signer) {
    ProofOfFee::set_bid(&carol_sig, 0001, 10); 
  }
}


//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::ProofOfFee;
  use DiemFramework::Debug::print;
  use DiemFramework::DiemAccount;
  // use Std::Signer;
  use Std::Vector;

  fun main(vm: signer, a_sig: signer) {
    ProofOfFee::set_bid(&a_sig, 0070, 10); // 0.1% bid, and expired on epoch 10

    
    // simulate 6 epochs
    DiemAccount::slow_wallet_epoch_drip(&vm, 100000); // unlock some coins for the validators

    let vals = Vector::singleton(@Alice);
    Vector::push_back(&mut vals, @Bob);
    Vector::push_back(&mut vals, @Carol);
    let i = 0;
    while (i < 11) {


      ProofOfFee::fill_seats_and_get_price(&vm, 3, &vals);
      ProofOfFee::reward_thermostat(&vm, &vals);

      i = i + 1;
    };

    // filling the seat updated the computation of the consensu reward.
    let (reward, win_bid, median_bid) = ProofOfFee::get_consensus_reward();
    print(&reward);
    print(&win_bid);
    print(&median_bid);

    assert!(reward == 1000000, 1001); // TODO: find some setting to make this change
    assert!(win_bid == 1, 1002);
    assert!(median_bid == 21, 1003);

    // we expect no change in the reward_thermostat because there haven't been 5 epochs or more of historical data.
    

    // let (reward, win_bid, median_bid) = ProofOfFee::get_consensus_reward();
    // print(&reward);
    // print(&win_bid);
    // print(&median_bid);
    // assert!(reward == 1000000, 1001);
    // assert!(win_bid == 1, 1002);
    // assert!(median_bid == 0, 1003);

  }
}
