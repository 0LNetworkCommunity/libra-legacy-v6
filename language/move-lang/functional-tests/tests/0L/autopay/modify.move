//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

// Initialize alice account with a transaction
//! new-transaction
//! sender: alice
script {
  use 0x0::AutoPay;
  use 0x0::Vector;
  use 0x0::Transaction;
  fun main() {
    AutoPay::init_status(true);
    AutoPay::init_data(Vector::empty());
    AutoPay::create(true, 0, 0, {{alice}}, 1, 0, 5, 1, 0, true);
    Transaction::assert(AutoPay::get_enabled({{alice}}, 0), 1);
    Transaction::assert(AutoPay::get_name({{alice}}, 0) == 0, 2);
    Transaction::assert(AutoPay::get_frequency({{alice}}, 0) == 1, 3);
    Transaction::assert(AutoPay::get_start({{alice}}, 0) == 0, 4);
    Transaction::assert(AutoPay::get_end({{alice}}, 0) == 5, 5);
    Transaction::assert(AutoPay::get_amount({{alice}}, 0) == 1, 6);
    Transaction::assert(AutoPay::get_from_earmarked({{alice}}, 0), 7);
    Transaction::assert(AutoPay::get_payee({{alice}}, 0) == {{alice}}, 8);
  }
}
// check: EXECUTED

// Change things to test change functions
//! new-transaction
//! sender: alice
script {
  use 0x0::AutoPay;
  fun main() {
    AutoPay::change_enabled(0, false);
    AutoPay::change_name(0, 1);
    AutoPay::change_frequency(0, 2);
    AutoPay::change_start(0, 1);
    AutoPay::change_end(0, 6);
    AutoPay::change_amount(0, 2);
    AutoPay::change_from_earmarked(0, false);
    AutoPay::change_payee(0, {{bob}});
  }
}
// check: EXECUTED

// Verify the changes happened and test get functions (from a different account)
//! new-transaction
//! sender: bob
script {
  use 0x0::AutoPay;
  use 0x0::Transaction;
  fun main() {
    Transaction::assert(!AutoPay::get_enabled({{alice}}, 0), 1);
    Transaction::assert(AutoPay::get_name({{alice}}, 0) == 1, 2);
    Transaction::assert(AutoPay::get_frequency({{alice}}, 0) == 2, 3);
    Transaction::assert(AutoPay::get_start({{alice}}, 0) == 1, 4);
    Transaction::assert(AutoPay::get_end({{alice}}, 0) == 6, 5);
    Transaction::assert(AutoPay::get_amount({{alice}}, 0) == 2, 6);
    Transaction::assert(!AutoPay::get_from_earmarked({{alice}}, 0), 7);
    Transaction::assert(AutoPay::get_payee({{alice}}, 0) == {{bob}}, 8);
  }
}
// check: EXECUTED