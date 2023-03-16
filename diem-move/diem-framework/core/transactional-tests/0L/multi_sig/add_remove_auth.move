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
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::MultiSig;
  use Std::Vector;
  fun main(_dr: signer, d_sig: signer) {
    let bal = DiemAccount::balance<GAS>(@DaveMultiSig);
    assert!(bal == 1000000, 7357001);

    let addr = Vector::singleton<address>(@Alice);
    Vector::push_back(&mut addr, @Bob);

    MultiSig::init_and_brick(&d_sig, addr, 2);
  }
}

// Alice is going to propose a transaction from the MultiSig wallet.

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::MultiSig;
  use Std::Vector;

  fun main(_dr: signer, a_sig: signer) {
    MultiSig::propose_add_authorities(&a_sig, @DaveMultiSig, Vector::singleton(@Carol));

    let a = MultiSig::get_authorities(@DaveMultiSig);
    assert!(Vector::length(&a) == 2, 7357002);
  }
}


//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::MultiSig;
  use Std::Vector;
  fun main(_dr: signer, b_sig: signer) {
    MultiSig::propose_add_authorities(&b_sig, @DaveMultiSig, Vector::singleton(@Carol));
    
    // now there were sufficient votes to add Carol
    let a = MultiSig::get_authorities(@DaveMultiSig);
    assert!(Vector::length(&a) == 3, 7357003);

  }
}

// NOW CAROL AND BOB CONSPIRE TO REMOVE ALICE


//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::MultiSig;
  use Std::Vector;
  fun main(_dr: signer, b_sig: signer) {
    MultiSig::propose_remove_authorities(&b_sig, @DaveMultiSig, Vector::singleton(@Alice));
    
    // no change yet
    let a = MultiSig::get_authorities(@DaveMultiSig);
    assert!(Vector::length(&a) == 3, 7357003);

  }
}



//# run --admin-script --signers DiemRoot Carol
script {
  use DiemFramework::MultiSig;
  use Std::Vector;
  fun main(_dr: signer, c_sig: signer) {
    MultiSig::propose_remove_authorities(&c_sig, @DaveMultiSig, Vector::singleton(@Alice));
    
    // no change yet
    let a = MultiSig::get_authorities(@DaveMultiSig);
    assert!(Vector::length(&a) == 2, 7357003);

  }
}