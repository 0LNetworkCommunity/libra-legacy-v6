//# init --validators Alice Bob

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::ValidatorConfig;
  use DiemFramework::ValidatorUniverse;
  use DiemFramework::ProofOfFee;
  use Std::Signer;

  fun main(_vm: signer, a_sig: signer) {
    ValidatorUniverse::is_in_universe(@Alice);
    ValidatorConfig::is_valid(@Alice);

    ProofOfFee::init(&a_sig);
    let (bid, expires) = ProofOfFee::current_bid(@Alice);
    assert!(bid == 0, 1001);
    assert!(expires == 0, 1002);
    
    // should not fail if already initialized
    ProofOfFee::init(&a_sig);

    ProofOfFee::set_bid(&a_sig, 100, 0);
    let acc = Signer::address_of(&a_sig);
    let (bid, expires) = ProofOfFee::current_bid(acc);
    assert!(@Alice == acc, 33333);
    assert!(bid == 100, 1003);
    assert!(expires == 0, 1004);
  }
}


//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::ProofOfFee;

  fun main(_vm: signer, b_sig: signer) {
    // should initialize if not already initialized
    ProofOfFee::set_bid(&b_sig, 30, 1111);
    let (bid, expires) = ProofOfFee::current_bid(@Bob);
    assert!(bid == 30, 1005);
    assert!(expires == 1111, 1006);
  }
}

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::ProofOfFee;
  use DiemFramework::DiemConfig;

  fun main(_vm: signer, b_sig: signer) {
    let this_epoch = DiemConfig::get_current_epoch();
    // should initialize if not already initialized
    ProofOfFee::retract_bid(&b_sig);
    let (bid, expires) = ProofOfFee::current_bid(@Bob);
    let (is_rectracted, epoch) = ProofOfFee::is_already_retracted(@Bob);
    assert!(is_rectracted, 1007);
    assert!(epoch == this_epoch, 1008);
    assert!(bid == 0, 1009);
    assert!(expires == 0, 10010);
  }
}