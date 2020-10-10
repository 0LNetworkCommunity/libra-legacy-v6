//! account: shashank, 1000000GAS, 0, validator
//! account: bob, 10000GAS, 0, validator

// Check autopay is triggered in block prologue correctly i.e., middle of epoch boundary

// creating the pledge
//! new-transaction
//! sender: shashank
script {
  use 0x0::AutoPay;
  use 0x0::Transaction;
  use 0x0::Signer;
  fun main(sender: &signer) {
    AutoPay::enable_autopay();
    Transaction::assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    AutoPay::create_pledge(1, {{bob}}, 2, 5);
    let (payee, end_epoch, percentage) = AutoPay::query_pledge(Signer::address_of(sender), 1);
    Transaction::assert(payee == {{bob}}, 1);
    Transaction::assert(end_epoch == 2, 1);
    Transaction::assert(percentage == 5, 1);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: bob
//! block-time: 2

//! block-prologue
//! proposer: bob
//! block-time: 3

//! block-prologue
//! proposer: bob
//! block-time: 4

//! block-prologue
//! proposer: bob
//! block-time: 5

//! block-prologue
//! proposer: bob
//! block-time: 6

// Checking balance before autopay module
//! new-transaction
//! sender: association
script {
  use 0x0::Transaction;
  use 0x0::LibraAccount;
  use 0x0::GAS;
  fun main() {
    let sha_balance = LibraAccount::balance<GAS::T>({{shashank}});
    let bob_balance = LibraAccount::balance<GAS::T>({{bob}});
    Transaction::assert(sha_balance==1000000, 1);
    Transaction::assert(bob_balance == 10000, 2);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: bob
//! block-time: 7

//! block-prologue
//! proposer: bob
//! block-time: 8

// Processing AutoPay to see if payments are done
//! new-transaction
//! sender: association
script {
  use 0x0::Transaction;
  use 0x0::LibraAccount;
  use 0x0::GAS;
  fun main() {
    let sha_balance = 1000000; 
    let bob_balance = 10000; 
    
    let sha_balance_later = LibraAccount::balance<GAS::T>({{shashank}});
    Transaction::assert(sha_balance_later < sha_balance, 2);
    
    let sha_transfered = sha_balance - sha_balance_later ;
    let bob_recieved = LibraAccount::balance<GAS::T>({{bob}}) - bob_balance;
    Transaction::assert(bob_recieved == sha_transfered, 2);
    }
}
// check: EXECUTED