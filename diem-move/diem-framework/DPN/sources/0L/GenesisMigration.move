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
  use DiemFramework::Globals;
  use DiemFramework::InfraEscrow;
  use Std::Signer;


    /// Called by root in genesis to initialize the GAS coin 
    public fun fork_migrate_account(
        vm: &signer,
        user_sig: &signer,
        // user_addr: address,
        auth_key: vector<u8>,
        balance: u64,
    ) {
      let user_addr = Signer::address_of(user_sig);
      // if not a validator OR operator of a validator, create a new account
      // previously during genesis validator and oper accounts were already created
      if (!are_you_a_val_or_oper(user_addr)) {
        DiemAccount::vm_create_account_migration(
          vm,
          user_addr,
          auth_key,
        );
      };

      
      // mint coins again to migrate balance, and all
      // system tracking of balances
      if (balance == 0) {
        return
      };
      // scale up by the coin split factor
      let new_balance = Globals::get_coin_split_factor() * balance;

      let minted_coins = Diem::mint<GAS>(vm, new_balance);
      let value_coin = Diem::value<GAS>(&minted_coins);
      DiemAccount::vm_deposit_with_metadata<GAS>(
        vm,
        user_addr,
        user_addr,
        minted_coins,
        b"genesis migration",
        b""
      );

      let balance = DiemAccount::balance<GAS>(user_addr);
      assert!(balance == value_coin, 0);

      // establish the infrastructure escrow pledge
      if (ValidatorUniverse::is_in_universe(user_addr)) {
        // TODO: governance
        let pct = 1;
        let share = (balance * pct) / 100;
        InfraEscrow::user_pledge_infra(user_sig, share)
      };


    }

    fun are_you_a_val_or_oper(user_addr: address): bool {
      ValidatorUniverse::is_in_universe(user_addr) ||
      ValidatorOperatorConfig::has_validator_operator_config(user_addr)
    }
}
}