//# init --validators Alice Bob Carol Dave Eve

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::ProofOfFee;
  // use DiemFramework::Debug::print;
  use DiemFramework::DiemAccount;
  use Std::Signer;
  use Std::Vector;

  fun main(vm: signer, a_sig: signer) {
    DiemAccount::slow_wallet_epoch_drip(&vm, 1000); // unlock some coins for the validators
    ProofOfFee::set_bid(&a_sig, 0001, 10); // 0.1% bid, and expired on epoch 10
    let acc = Signer::address_of(&a_sig);
    let (bid, expires) = ProofOfFee::current_bid(acc);
    assert!(bid == 1, 1000);
    assert!(expires == 10, 1000);
    // print(&bid);
    // print(&expires);
    let vals = Vector::singleton(@Alice);
    Vector::push_back(&mut vals, @Bob);
    Vector::push_back(&mut vals, @Carol);
    Vector::push_back(&mut vals, @Dave);
    Vector::push_back(&mut vals, @Eve);

    let sorted_by_bid = ProofOfFee::get_sorted_vals(false);

    let (seats, _p) = ProofOfFee::fill_seats_and_get_price(&vm, 5, &sorted_by_bid, &vals);

    assert!(Vector::contains(&seats, &@Alice), 1000);

    // filling the seat updated the computation of the consensu reward.
    let (reward, win_bid, median_bid) = ProofOfFee::get_consensus_reward();
    assert!(reward == 1000000, 1001);
    assert!(win_bid == 1, 1002);
    // print(&median_bid);
    assert!(median_bid == 1, 1003);

    // we expect no change in the reward_thermostat because there haven't been 5 epochs or more of historical data.
    ProofOfFee::reward_thermostat(&vm);

    let (reward, win_bid, median_bid) = ProofOfFee::get_consensus_reward();
    assert!(reward == 1000000, 1004);
    assert!(win_bid == 1, 1005);
    assert!(median_bid == 1, 1006);

  }
}
