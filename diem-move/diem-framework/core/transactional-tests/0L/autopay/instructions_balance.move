// Todo: These GAS values have no effect, all accounts start with 1M GAS
//! account: alice, 10000000GAS, 0
//! account: bob,   1000000GAS, 0, validator
//! account: jim,   1000000GAS, 0

// test runs various autopay instruction types to ensure they are being executed as expected

//! new-transaction
//! sender: jim
script {
    use DiemFramework::Wallet;
    use Std::Vector;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 1, 7357001);
    }
}

// check: EXECUTED

// alice commits to paying jim 5% of her worth per epoch
//! new-transaction
//! sender: alice
script {
  use DiemFramework::AutoPay;
  use Std::Signer;
  fun main(sender: signer) {
    let sender = &sender;
    AutoPay::enable_autopay(sender);
    assert!(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    
    // instruction type percent of balance
    AutoPay::create_instruction(
      sender,
      1, // UID
      0, // percent of balance type
      @{{jim}},
      2, // until epoch two
      500 // 5 percent
    );

    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(
      Signer::address_of(sender), 1
    );
    assert!(type == 0, 735701);
    assert!(payee == @{{jim}}, 735702);
    assert!(end_epoch == 2, 735703);
    assert!(percentage == 500, 735704);
  }
}
// check: EXECUTED


///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: bob
//! block-time: 31000000
//! round: 23
///////////////////////////////////////////////////


// Weird. This next block needs to be added here otherwise the prologue above does not run.
///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: bob
//! block-time: 32000000
//! round: 24
///////////////////////////////////////////////////

//! new-transaction
//! sender: diemroot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;

  fun main(_vm: signer) {
    let ending_balance = DiemAccount::balance<GAS>(@{{alice}});
    assert!(ending_balance == 9500001, 735705);
  }
}
// check: EXECUTED

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: bob
//! block-time: 61000000
//! round: 65
///////////////////////////////////////////////////

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: bob
//! block-time: 92000000
//! round: 66
///////////////////////////////////////////////////
///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: bob
//! block-time: 93000000
//! round: 67
///////////////////////////////////////////////////

//! new-transaction
//! sender: diemroot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  // use DiemFramework::Debug::print;

  fun main(_vm: signer) {
    let ending_balance = DiemAccount::balance<GAS>(@{{alice}});
    // print(&ending_balance);
    assert!(ending_balance == 9025001, 735711);

    // check balance of recipients
    let ending_balance = DiemAccount::balance<GAS>(@{{jim}});
    // print(&ending_balance);
    assert!(ending_balance == 1974999, 735712);
  }
}
// check: EXECUTED