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
    AutoPay::create_instruction(sender, 1, {{bob}}, 2, 5);
    let (payee, end_epoch, percentage) = AutoPay::query_instruction(Signer::address_of(sender), 1);
    assert(payee == {{bob}}, 1);
    assert(end_epoch == 2, 1);
    assert(percentage == 5, 1);
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
    let sha_balance = LibraAccount::balance<GAS>({{alice}});
    let bob_balance = LibraAccount::balance<GAS>({{bob}});
    assert(sha_balance==1000000, 1);
    assert(bob_balance == 10000, 2);
    }
}
// check: EXECUTED

///////////////////////////////////////////////
///// Trigger Autopay Tick at 0.5 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 100000
//! round: 1

///// Trigger Autopay Tick at 0.5 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 200000
//! round: 2

///// Trigger Autopay Tick at 0.5 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 300000
//! round: 3

//////////////////////////////////////////////


//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraTimestamp;
  use 0x1::Debug::print;
  fun main() {
    let time = LibraTimestamp::now_seconds();
    print(&time);
  }
}

// // Processing AutoPay to see if payments are done
// //! new-transaction
// //! sender: libraroot
// script {
//   use 0x1::LibraAccount;
//   use 0x1::GAS::GAS;
//   fun main() {
//     let starting_balance = 1000000; 
    
//     // check GAS was withdrawn
//     let ending_balance = LibraAccount::balance<GAS>({{alice}});
//     assert(ending_balance < starting_balance, 416854);
    
//     // let sha_transfered = sha_balance - sha_balance_later ;
//     // let bob_recieved = LibraAccount::balance<GAS>({{bob}}) - bob_balance;
//     // assert(bob_recieved == sha_transfered, 416855);
//     }
// }
// // check: EXECUTED