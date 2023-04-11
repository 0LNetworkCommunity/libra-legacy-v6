//# init --parent-vasps Alice Bob Carol DaveMultiSig
// Alice:     validators with 10M GAS
// Bob:   non-validators with  1M GAS
// Carol:   non-validators with  1M GAS
// Dave:   non-validators with  1M GAS

// Using Governance template, we want to check that the expiration of ballot is unchanged when the second voter proposes a different deadline.
// Only the first voter/proposer will set the expiration epoch.

//# run --admin-script --signers DiemRoot DaveMultiSig
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::MultiSig;
  use DiemFramework::MultiSigPayment::PaymentType;

  use Std::Vector;
  fun main(_dr: signer, d_sig: signer) {
    let bal = DiemAccount::balance<GAS>(@DaveMultiSig);
    assert!(bal == 1000000, 7357001);


    let addr = Vector::singleton<address>(@Alice);
    Vector::push_back(&mut addr, @Bob);

    MultiSig::init_gov(&d_sig, 2, &addr);
    MultiSig::init_type<PaymentType>(&d_sig, true);
    MultiSig::finalize_and_brick(&d_sig);
  }
}

// Alice is going to propose to change the authorities to add Carol

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::MultiSig;
  use Std::Option;
  use Std::Vector;

  fun main(_dr: signer, a_sig: signer) {

    MultiSig::propose_governance(&a_sig, @DaveMultiSig, Vector::empty(), true, Option::some(1), Option::some(10));

    let a = MultiSig::get_authorities(@DaveMultiSig);
    assert!(Vector::length(&a) == 2, 7357002);
  }
}


//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::MultiSig;
  use Std::Option;
  use Std::Vector;

  fun main(_dr: signer, b_sig: signer) {
    // the expiration should be igored
    // NOTE: the expiration here is NONE. But the voting should be on the same ballot as the previous proposal.
    MultiSig::propose_governance(&b_sig, @DaveMultiSig, Vector::empty(), true, Option::some(1), Option::none());

    let a = MultiSig::get_authorities(@DaveMultiSig);
    assert!(Vector::length(&a) == 2, 7357002);

    let (b, _) = MultiSig::get_n_of_m_cfg(@DaveMultiSig);
    assert!(b == 1, 7357003);
  }
}

