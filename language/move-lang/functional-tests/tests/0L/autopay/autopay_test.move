//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

// Alice initializes autopay with empty
//! new-transaction
//! sender: alice
script {
  // This is in block 0
  use 0x0::AutoPay;
  use 0x0::Vector;
  use 0x0::Transaction;
  use 0x0::LibraAccount;
  use 0x0::GAS;
  use 0x0::Libra;
  fun main() {
    AutoPay::init_status(true);
    AutoPay::init_data(Vector::empty());
    AutoPay::create(true, 0, 0, {{bob}}, 2, 2, 5, 1, Libra::currency_code<GAS::T>(), true);
    Transaction::assert(AutoPay::exists({{alice}}, 0), 1);
    Transaction::assert(LibraAccount::balance<GAS::T>({{alice}}) == 1000000, 1);
    Transaction::assert(LibraAccount::balance<GAS::T>({{bob}}) == 1000000, 2);
  }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 2

//! new-transaction
//! sender: alice
script {
  // This is in block 1
  use 0x0::LibraAccount;
  use 0x0::GAS;
  use 0x0::Transaction;
  fun main() {
    Transaction::assert(LibraAccount::balance<GAS::T>({{alice}}) == 1000000, 3);
    Transaction::assert(LibraAccount::balance<GAS::T>({{bob}}) == 1000000, 4);
  }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 3

//! new-transaction
//! sender: alice
script {
  // This is in block 2
  use 0x0::LibraAccount;
  use 0x0::GAS;
  use 0x0::Transaction;
  fun main() {
    Transaction::assert(LibraAccount::balance<GAS::T>({{alice}}) == 1000000, 5);
    Transaction::assert(LibraAccount::balance<GAS::T>({{bob}}) == 1000000, 6);
  }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 4

//! new-transaction
//! sender: alice
script {
  // This is in block 3
  use 0x0::LibraAccount;
  use 0x0::GAS;
  use 0x0::Transaction;
  fun main() {
    Transaction::assert(LibraAccount::balance<GAS::T>({{alice}}) == 999999, 7);
    Transaction::assert(LibraAccount::balance<GAS::T>({{bob}}) == 1000001, 8);
  }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 5

//! new-transaction
//! sender: alice
script {
  // This is in block 4
  use 0x0::LibraAccount;
  use 0x0::GAS;
  use 0x0::Transaction;
  fun main() {
    Transaction::assert(LibraAccount::balance<GAS::T>({{alice}}) == 999999, 9);
    Transaction::assert(LibraAccount::balance<GAS::T>({{bob}}) == 1000001, 10);
  }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 6

//! new-transaction
//! sender: alice
script {
  // This is in block 5
  use 0x0::LibraAccount;
  use 0x0::GAS;
  use 0x0::Transaction;
  fun main() {
    Transaction::assert(LibraAccount::balance<GAS::T>({{alice}}) == 999998, 11);
    Transaction::assert(LibraAccount::balance<GAS::T>({{bob}}) == 1000002, 12);
  }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 7

//! new-transaction
//! sender: alice
script {
  // This is in block 6
  use 0x0::LibraAccount;
  use 0x0::GAS;
  use 0x0::Transaction;
  fun main() {
    Transaction::assert(LibraAccount::balance<GAS::T>({{alice}}) == 999998, 13);
    Transaction::assert(LibraAccount::balance<GAS::T>({{bob}}) == 1000002, 14);
  }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 8

//! new-transaction
//! sender: alice
script {
  // This is in block 7
  use 0x0::LibraAccount;
  use 0x0::GAS;
  use 0x0::Transaction;
  fun main() {
    Transaction::assert(LibraAccount::balance<GAS::T>({{alice}}) == 999998, 15);
    Transaction::assert(LibraAccount::balance<GAS::T>({{bob}}) == 1000002, 16);
  }
}
// check: EXECUTED