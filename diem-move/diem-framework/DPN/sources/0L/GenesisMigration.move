///////////////////////////////////////////////////////////////////
// 0L Module
// Genesis Migration
///////////////////////////////////////////////////////////////////
// This module is used in hard upgrade where a new genesis takes place, and which requires migrations.
// on the rust side, vm_geneses/lib.rs is used to call migrate_user function here below.

address DiemFramework {

module GenesisMigration {
  use DiemFramework::DiemAccount;
  use DiemFramework::Diem;
  use DiemFramework::GAS::GAS;
  use DiemFramework::ValidatorUniverse;

    /// Called by root in genesis to initialize the GAS coin 
    public fun migrate_user(
        vm: &signer,
        user_addr: address,
        auth_key: vector<u8>,
        balance: u64,
    ) {
      // if not a validator, create a new account
      // previously validators were already created
      if (!ValidatorUniverse::is_in_universe(user_addr)) {
        DiemAccount::vm_create_account_migration(
          vm,
          user_addr,
          auth_key,
          // balance
        );
      };


      let minted_coins = Diem::mint<GAS>(vm, balance);
      DiemAccount::vm_deposit_with_metadata<GAS>(
        vm,
        user_addr,
        minted_coins,
        b"genesis migration",
        b""
      );
    }

}
}