//! account: shashank, 100
//! account: bob, 100

// We are trying to query a pledge which doesnot exist in the network

// Create pledge and retrieve it
//! new-transaction
//! sender: shashank
script {
  use 0x0::AutoPay;
  use 0x0::Transaction;
  use 0x0::Signer;
  fun main(sender: &signer) {
    AutoPay::enable_autopay();
    Transaction::assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    
    let (payee, end_epoch, percentage) = AutoPay::query_pledge(Signer::address_of(sender), 1);
    // If autopay pledge doesn't exists, it returns (0x0, 0, 0)
    Transaction::assert(payee == {{0x0}}, 1);
    Transaction::assert(end_epoch == 0, 1);
    Transaction::assert(percentage == 0, 1);
    }
}
// check: EXECUTED
