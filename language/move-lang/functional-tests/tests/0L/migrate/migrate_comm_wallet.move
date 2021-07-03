//! account: alice, 1000000
//! account: bob, 1000000
//! account: carol, 1000000

// We test creation of autopay, retrieving it using same and different accounts
// Finally, we also test deleting of autopay

//! new-transaction
//! sender: alice
script {
  use 0x1::AutoPay2;
  use 0x1::Signer;
  fun main(sender: &signer) {
    AutoPay2::enable_autopay(sender);
    assert(AutoPay2::is_enabled(Signer::address_of(sender)), 73570001);
    AutoPay2::create_instruction(sender, 1, 0, {{bob}}, 2, 5);
    let (type, payee, end_epoch, percentage) = AutoPay2::query_instruction(Signer::address_of(sender), 1);
    assert(payee == {{bob}}, 73570002);
    assert(end_epoch == 2, 73570003);
    assert(percentage == 5, 73570004);
    assert(type == 0, 7357005);
    assert(!Wallet::is_comm({{bob}}), 7357006);
  }
}
// check: EXECUTED


//! new-transaction
//! sender: libraroot
script {
    use 0x1::MigrateWallets;
    use 0x1::Wallet;
    fun main(vm: &signer) { // alice's signer type added in tx.
      MigrateWallets::migrate_community_wallets(vm);
      assert(Wallet::is_comm({{bob}}), 7357007);
    }
}
