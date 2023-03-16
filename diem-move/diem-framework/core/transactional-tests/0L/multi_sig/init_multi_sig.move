//# init --parent-vasps Alice Bob Carol Dave
// Alice:     validators with 10M GAS
// Bob:   non-validators with  1M GAS
// Carol:   non-validators with  1M GAS
// Dave:   non-validators with  1M GAS

// DAVE is going to become a multisig wallet. It's going to get bricked.
// From that point forward only Alice, Bob, and Carol are the only ones 
// who can submit multi-sig transactions.

//# run --admin-script --signers DiemRoot Dave
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::MultiSig;
  use Std::Vector;
  fun main(_dr: signer, d_sig: signer) {
    let bal = DiemAccount::balance<GAS>(@Bob);
    assert!(bal == 1000000, 7357001);

    let addr = Vector::singleton<address>(@Alice);
    Vector::push_back(&mut addr, @Bob);
    Vector::push_back(&mut addr, @Carol);

    MultiSig::init_and_brick(&d_sig, addr, 2);
  }
}