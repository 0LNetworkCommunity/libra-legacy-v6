//! account: shashank, 1000000GAS
//! account: bob, 10000GAS

// We test processing of autopay at differnt epochs and balance transfers
// Finally, we also check the end_epoch functionality of autopay

// creating the pledge
//! new-transaction
//! sender: shashank
script {
  use 0x1::AutoPay;
  use 0x1::Signer;
  fun main(sender: &signer) {
    AutoPay::enable_autopay(sender);
    assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    AutoPay::create_pledge(sender, 1, {{bob}}, 2, 5);
    let (payee, end_epoch, percentage) = AutoPay::query_pledge(Signer::address_of(sender), 1);
    assert(payee == {{bob}}, 1);
    assert(end_epoch == 2, 1);
    assert(percentage == 5, 1);
    }
}
// check: EXECUTED


// Processing AutoPay to see if payments are done
//! new-transaction
//! sender: libraroot
script {
  use 0x1::AutoPay;
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;
  fun main(sender: &signer) {
    let _sha_balance = LibraAccount::balance<GAS>({{shashank}});
    let _bob_balance = LibraAccount::balance<GAS>({{bob}});
    // assert(sha_balance==1000000, 1);
    AutoPay::process_autopay(sender, 1);
    
    // let sha_balance_later = LibraAccount::balance<GAS>({{shashank}});
    // assert(sha_balance_later < sha_balance, 2);
    
    // let sha_transfered = sha_balance - sha_balance_later ;
    // let bob_recieved = LibraAccount::balance<GAS>({{bob}}) - bob_balance;
    // assert(bob_recieved == sha_transfered, 2);
    }
}
// check: EXECUTED


// // Processing AutoPay to see if payments are done
// //! new-transaction
// //! sender: libraroot
// script {
//   use 0x1::AutoPay;
//   use 0x1::LibraAccount;
//   use 0x1::GAS::GAS;
//   fun main(sender: &signer) {
//     let sha_balance = LibraAccount::balance<GAS>({{shashank}});
//     let bob_balance = LibraAccount::balance<GAS>({{bob}});
//     AutoPay::process_autopay(sender, 2);
    
//     let sha_balance_later = LibraAccount::balance<GAS>({{shashank}});
//     assert(sha_balance_later < sha_balance, 2);
    
//     let sha_transfered = sha_balance - sha_balance_later ;
//     let bob_recieved = LibraAccount::balance<GAS>({{bob}}) - bob_balance;
//     assert(bob_recieved == sha_transfered, 2);
//     }
// }
// // check: EXECUTED

// // Processing AutoPay to check if the transaction terminates at end_epoch (3rd epoch)
// //! new-transaction
// //! sender: libraroot
// script {
//   use 0x1::AutoPay;
//   use 0x1::LibraAccount;
//   use 0x1::GAS::GAS;
//   fun main(sender: &signer) {
//     let sha_balance = LibraAccount::balance<GAS>({{shashank}});
//     AutoPay::process_autopay(sender, 3);
    
//     let sha_balance_later = LibraAccount::balance<GAS>({{shashank}});
    
//     assert(sha_balance == sha_balance_later, 2);
//     }
// }
// // check: EXECUTED
