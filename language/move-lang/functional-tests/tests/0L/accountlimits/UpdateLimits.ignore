// //! account: alice, 1000000GAS, 0, validator
// //! account: bob, 100, 0

// //! block-prologue
// //! proposer: alice
// //! block-time: 31000000
// //! round: 1

// //! new-transaction
// //! sender: libraroot
// script {
//   use 0x1::LibraTimestamp;
//   use 0x1::LibraConfig;
//   fun main() {
//     let time = LibraTimestamp::now_seconds();
//     assert(time == 31, 7357001);
//     assert(LibraConfig::get_current_epoch() == 1, 0);
//   }
// }
// // check: EXECUTED

// //! block-prologue
// //! proposer: alice
// //! block-time: 61000000
// //! round: 15

// // check: NewEpochEvent

// // Will only work if transfer limit epoch is set to 1
// //! new-transaction
// //! sender: alice
// script {
//   use 0x1::LibraTimestamp;
//   use 0x1::LibraAccount;
//   use 0x1::LibraConfig;
//   use 0x1::AccountLimits;
//   use 0x1::GAS::GAS;
//   fun main(account: &signer) {
//     let time = LibraTimestamp::now_seconds();
//     assert(time == 61, 7357001);
//     assert(LibraConfig::get_current_epoch() == 2, 0);
//     let with_cap = LibraAccount::extract_withdraw_capability(account);
//     assert(AccountLimits::has_limits_published<GAS>({{alice}}), 1);
//     LibraAccount::pay_from<GAS>(&with_cap, {{bob}}, 10, x"", x"");
//     assert(LibraAccount::balance<GAS>({{alice}}) == 999990, 2);
//     assert(LibraAccount::balance<GAS>({{bob}}) == 110, 3);
//     LibraAccount::restore_withdraw_capability(with_cap); 
//   }
// }
// // check: EXECUTED

// // Check if the transfer will work in the same epoch for more amount
// //! new-transaction
// //! sender: alice
// script {
//   use 0x1::LibraAccount;
//   use 0x1::AccountLimits;
//   use 0x1::GAS::GAS;
//   fun main(account: &signer) {
//     let with_cap = LibraAccount::extract_withdraw_capability(account);
//     assert(AccountLimits::has_limits_published<GAS>({{alice}}), 1);
//     LibraAccount::pay_from<GAS>(&with_cap, {{bob}}, 10, x"", x"");
//     assert(LibraAccount::balance<GAS>({{alice}}) == 999980, 2);
//     assert(LibraAccount::balance<GAS>({{bob}}) == 120, 3);
//     LibraAccount::restore_withdraw_capability(with_cap); 
//   }
// }
// // check: ABORTED { code: 1544