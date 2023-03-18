//# init --parent-vasps Alice Bob Carol DaveMultiSig
// Alice:     validators with 10M GAS
// Bob:   non-validators with  1M GAS
// Carol:   non-validators with  1M GAS
// DaveMultiSig:   non-validators with  1M GAS

// DAVE is going to become a multisig wallet. It's going to get bricked.
// From that point forward only Alice, Bob, and Carol are the only ones 
// who can submit multi-sig transactions.

//# run --admin-script --signers DiemRoot DaveMultiSig
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::MultiSig;
  use DiemFramework::MultiSigPayment;
  use Std::Option;
  use Std::Vector;
  fun main(_dr: signer, d_sig: signer) {
    let bal = DiemAccount::balance<GAS>(@DaveMultiSig);
    assert!(bal == 1000000, 7357001);

    let addr = Vector::singleton<address>(@Alice);
    Vector::push_back(&mut addr, @Bob);
    Vector::push_back(&mut addr, @Carol);

    // NOTE: there is no withdraw capability being sent.
    // so transactions will fail.
    let withdraw = Option::none();
    MultiSig::init_type<MultiSigPayment::PaymentType>(&d_sig, addr, 2, withdraw, b"payment");
    MultiSig::finalize_and_brick(&d_sig);
  }
}



//# run --admin-script --signers DiemRoot Bob
script {
  // use DiemFramework::MultiSig;
  use DiemFramework::MultiSigPayment;
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Debug::print;

  fun main(_dr: signer, b_sig: signer) {

    // let p = MultiSigPayment::new_payment(@Alice, 10, b"send it");

    MultiSigPayment::propose_payment(&b_sig, @DaveMultiSig, @Alice, 10, b"send it");
    
    // MultiSig::process_payment_type(@DaveMultiSig);

    // no change yet
    // let a = MultiSig::get_authorities<PropPayment>(@DaveMultiSig);
    // assert!(Vector::length(&a) == 2, 7357003);
    let bal = DiemAccount::balance<GAS>(@DaveMultiSig);
    print(&bal);
    // assert!(bal < 1000000, 7357002);

  }
}


//# run --admin-script --signers DiemRoot Carol
script {
  // use DiemFramework::MultiSig;
  use DiemFramework::MultiSigPayment;
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;

  fun main(_dr: signer, c_sig: signer) {

    // let p = MultiSigPayment::new_payment(@Alice, 10, b"send it");

    MultiSigPayment::propose_payment(&c_sig, @DaveMultiSig, @Alice, 10, b"send it");
    
    // MultiSig::process_payment_type(@DaveMultiSig);

    // no change yet
    // let a = MultiSig::get_authorities<PropPayment>(@DaveMultiSig);
    // assert!(Vector::length(&a) == 2, 7357003);
    let bal = DiemAccount::balance<GAS>(@DaveMultiSig);
    // tHERE's no Withdraw Capability added so no changed.
    assert!(bal == 1000000, 7357002);

  }
}