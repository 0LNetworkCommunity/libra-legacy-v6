//# init --parent-vasps Alice Bob Carol DaveMultiSig
// Alice:     validators with 10M GAS
// Bob:   non-validators with  1M GAS
// Carol:   non-validators with  1M GAS
// Dave:   non-validators with  1M GAS

// DAVE is going to become a multisig wallet. It's going to get bricked.
// From that point forward only Alice, Bob, are signers

// We want to add Carol to the multisig wallet

//# run --admin-script --signers DiemRoot DaveMultiSig
script {
  use Std::Option;
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::MultiSig::{Self, PropPayment};
  use Std::Vector;
  fun main(_dr: signer, d_sig: signer) {
    let bal = DiemAccount::balance<GAS>(@DaveMultiSig);
    assert!(bal == 1000000, 7357001);


    let addr = Vector::singleton<address>(@Alice);
    Vector::push_back(&mut addr, @Bob);

    // payment type of multisigs need withdraw capability
    let cap = DiemAccount::extract_withdraw_capability(&d_sig);

    MultiSig::init_type<PropPayment>(&d_sig, addr, 2, Option::some(cap));
    MultiSig::finalize_and_brick(&d_sig);
  }
}

// Alice is going to propose to change the authorities to add Carol

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::MultiSig::{Self, PropPayment};
  use Std::Vector;

  fun main(_dr: signer, a_sig: signer) {
    MultiSig::propose_governance<PropPayment>(&a_sig, @DaveMultiSig, Vector::singleton(@Carol), true);

    let a = MultiSig::get_authorities<PropPayment>(@DaveMultiSig);
    assert!(Vector::length(&a) == 2, 7357002);
  }
}


//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::MultiSig::{Self, PropPayment};
  use Std::Vector;

  fun main(_dr: signer, b_sig: signer) {
    MultiSig::propose_governance<PropPayment>(&b_sig, @DaveMultiSig, Vector::singleton(@Carol), true);

    let a = MultiSig::get_authorities<PropPayment>(@DaveMultiSig);
    assert!(Vector::length(&a) == 3, 7357002);
  }
}


// NOW CAROL AND BOB CONSPIRE TO REMOVE ALICE


//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::MultiSig::{Self, PropPayment};
  use Std::Vector;
  fun main(_dr: signer, b_sig: signer) {
    MultiSig::propose_governance<PropPayment>(&b_sig, @DaveMultiSig, Vector::singleton(@Alice), false);
    
    // no change yet
    let a = MultiSig::get_authorities<PropPayment>(@DaveMultiSig);
    assert!(Vector::length(&a) == 3, 7357003);

  }
}



//# run --admin-script --signers DiemRoot Carol
script {
  use DiemFramework::MultiSig::{Self, PropPayment};
  use Std::Vector;
  fun main(_dr: signer, b_sig: signer) {
    MultiSig::propose_governance<PropPayment>(&b_sig, @DaveMultiSig, Vector::singleton(@Alice), false);
    
    // no change yet
    let a = MultiSig::get_authorities<PropPayment>(@DaveMultiSig);
    assert!(Vector::length(&a) == 2, 7357003);

  }
}