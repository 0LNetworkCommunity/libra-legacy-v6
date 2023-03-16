//# init --parent-vasps Alice Bob Carol DaveMultiSig
// Alice:     validators with 10M GAS
// Bob:   non-validators with  1M GAS
// Carol:   non-validators with  1M GAS
// Dave:   non-validators with  1M GAS

// DAVE is going to become a multisig wallet. It's going to get bricked.
// From that point forward only Alice, Bob, and Carol are the only ones 
// who can submit multi-sig transactions.

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
    Vector::push_back(&mut addr, @Carol);

    MultiSig::init_and_brick(&d_sig, addr, 2);
  }
}

// Alice is going to propose a transaction from the MultiSig wallet.

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::MultiSig;
  fun main(_dr: signer, a_sig: signer) {
    MultiSig::propose_tx(&a_sig, @DaveMultiSig, @Carol, 20, 3, b"hello");

  }
}

// Bob will do the same

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::MultiSig;
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Debug::print;

  fun main(_dr: signer, b_sig: signer) {

    let bal_before = DiemAccount::balance<GAS>(@DaveMultiSig);
    assert!(bal_before == 1000000, 7357001);

    let payment = 20;
    MultiSig::propose_tx(&b_sig, @DaveMultiSig, @Carol, payment, 3, b"hello");

    let bal_now = DiemAccount::balance<GAS>(@DaveMultiSig);
    print(&bal_now);

    assert!(bal_now == bal_before - payment, 7357002);

  }
}