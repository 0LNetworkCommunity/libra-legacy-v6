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
  use DiemFramework::MultiSig::{Self, PaymentType};
  use Std::Option;
  use Std::Vector;
  fun main(_dr: signer, d_sig: signer) {
    let bal = DiemAccount::balance<GAS>(@Bob);
    assert!(bal == 1000000, 7357001);

    let addr = Vector::singleton<address>(@Alice);
    Vector::push_back(&mut addr, @Bob);
    Vector::push_back(&mut addr, @Carol);

    MultiSig::init_type<PaymentType>(&d_sig, addr, 2, Option::none(), b"payment");
    MultiSig::finalize_and_brick(&d_sig);
  }
}

  // public fun init_type<HandlerType: key + store >(
  //   sig: &signer,
  //   m_seed_authorities: vector<address>,
  //   cfg_default_n_sigs: u64,
  //   withdraw_capability: Option<DiemAccount::WithdrawCapability>,
  //   handler_name: vector<u8>,


//# run --admin-script --signers DiemRoot Carol
script {
  use DiemFramework::MultiSig::{Self, PaymentType};
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;

  fun main(_dr: signer, b_sig: signer) {

    let p = MultiSig::new_payment(@Alice, 10, b"send it");

    MultiSig::propose<PaymentType>(&b_sig, @DaveMultiSig, p);
    
    MultiSig::process_payment_type(@DaveMultiSig);

    // no change yet
    // let a = MultiSig::get_authorities<PropPayment>(@DaveMultiSig);
    // assert!(Vector::length(&a) == 2, 7357003);
    let bal = DiemAccount::balance<GAS>(@Bob);
    assert!(bal < 1000000, 7357002);

  }
}