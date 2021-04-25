//! account: alice, 1000000GAS, 0, validator
//! account: bob, 10000GAS, 0, validator

// Check autopay is triggered in block prologue correctly i.e., middle of epoch boundary

// creating the payment
//! new-transaction
//! sender: alice
script {
  use 0x1::AutoPay;
  use 0x1::Signer;
  fun main(sender: &signer) {
    AutoPay::enable_autopay(sender);
    assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    
    // send a 5.00% instruction
    AutoPay::create_instruction(sender, 1, {{bob}}, 2, 500); 

    let (payee, end_epoch, percentage) = AutoPay::query_instruction(Signer::address_of(sender), 1);
    assert(payee == {{bob}}, 73570010);
    assert(end_epoch == 2, 73570011);
    assert(percentage == 500, 73570012);
  }
}
// check: EXECUTED

// Checking balance before autopay module
//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;
  fun main() {
    let alice_balance = LibraAccount::balance<GAS>({{alice}});
    let bob_balance = LibraAccount::balance<GAS>({{bob}});
    assert(alice_balance == 1000000, 73570021);
    assert(bob_balance == 10000, 73570022);
    }
}
// check: EXECUTED

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: alice
//! block-time: 31000000
//! round: 23
///////////////////////////////////////////////////


// Weird. This next block needs to be added here otherwise the prologue above does not run.
///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: alice
//! block-time: 32000000
//! round: 24
///////////////////////////////////////////////////

//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;
  use 0x1::Debug::print;
  fun main(_vm: &signer) {
    let ending_balance = LibraAccount::balance<GAS>({{alice}});
    print(&ending_balance);
    assert(ending_balance < 1000000, 73570023);
    assert(ending_balance == 950001, 73570024);
  }
}
// check: EXECUTED

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: alice
//! block-time: 33000000
//! round: 25
///////////////////////////////////////////////////

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: alice
//! block-time: 34000000
//! round: 26
///////////////////////////////////////////////////