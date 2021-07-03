address 0x1 {

/// Module providing debug functionality.
module MigrateWallets {
  // migrations should have own module, since imports can cause dependency cycling.
  use 0x1::AutoPay2;
  use 0x1::Wallet;
  use 0x1::Debug::print;
  use 0x1::Vector;

  fun migrate_community_wallets(vm: &signer) {
    // find autopay wallets
    let vec_addr = AutoPay2::get_all_payees();
    print(&vec_addr);
    // tag as 
    let len = Vector::length<address>(&vec_addr);
    let i = 0;
    while (i < len) {
      let addr = *Vector::borrow<address>(&vec_addr, i);
      Wallet::vm_set_comm(vm, addr);
      i = i + 1;
    }
  }

}
}