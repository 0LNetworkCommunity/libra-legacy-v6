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
  use DiemFramework::ValidatorOperatorConfig;
  // use DiemFramework::Debug::print;


    /// Called by root in genesis to initialize the GAS coin 
    public fun migrate_user(
        vm: &signer,
        user_addr: address,
        auth_key: vector<u8>,
        balance: u64,
    ) {
      // if not a validator OR operator of a validator, create a new account
      // previously at genesis validator and oper accounts were already created
      if (!are_you_a_val_or_oper(user_addr)) {
        DiemAccount::vm_create_account_migration(
          vm,
          user_addr,
          auth_key,
        );
      };

      
      // mint coins again to migrate balance, and all
      // system tracking of balances
      if (balance < 1) {
        return
      };
      let minted_coins = Diem::mint<GAS>(vm, balance);
      let value_coin = Diem::value<GAS>(&minted_coins);
      DiemAccount::vm_deposit_with_metadata<GAS>(
        vm,
        user_addr,
        minted_coins,
        b"genesis migration",
        b""
      );

      let balance = DiemAccount::balance<GAS>(user_addr);
      assert!(balance == value_coin, 0);
    }

    fun are_you_a_val_or_oper(user_addr: address): bool {
      ValidatorUniverse::is_in_universe(user_addr) ||
      ValidatorOperatorConfig::has_validator_operator_config(user_addr)
    }

}
}