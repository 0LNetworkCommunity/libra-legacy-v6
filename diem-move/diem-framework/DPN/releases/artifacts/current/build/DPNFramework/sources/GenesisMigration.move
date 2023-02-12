///////////////////////////////////////////////////////////////////
// 0L Module
// Genesis Migration
///////////////////////////////////////////////////////////////////
// This module is used in hard upgrade where a new genesis takes place, and which requires migrations.
// on the rust side, vm_geneses/lib.rs is used to call migrate_user function here below.

address DiemFramework {

module GenesisMigration {
  use DiemFramework::DiemAccount;

    /// Called by root in genesis to initialize the GAS coin 
    public fun migrate_user(
        vm: &signer,
        user_addr: address,
        auth_key: vector<u8>,
        balance: u64,
    ) {
      DiemAccount::create_user_account_with_coin(
        vm,
        user_addr,
        auth_key,
        balance
      );
    }
}
}