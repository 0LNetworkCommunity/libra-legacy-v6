/////////////////////////////////////////////////////////////////////////
// 0L Module
// Audit Module
// Error code: 1905
/////////////////////////////////////////////////////////////////////////

address DiemFramework {
  module Audit {
    use DiemFramework::ValidatorConfig;
    use DiemFramework::DiemAccount;
    // use DiemFramework::GAS::GAS;
    use DiemFramework::AutoPay;
    use DiemFramework::TowerState;
    use DiemFramework::Testnet;
    use DiemFramework::Vouch;    

    public fun val_audit_passing(val: address): bool {
      // has valid configs
      if (!ValidatorConfig::is_valid(val)) return false;
      // has operator account set to another address
      let oper = ValidatorConfig::get_operator(val);
      if (oper == val) return false;
      // operator account has balance
      // if (DiemAccount::balance<GAS>(oper) < 50000 && !Testnet::is_testnet()) return false;
      // has autopay enabled
      // if (!AutoPay::is_enabled(val)) return false;
      // has mining state
      if (!TowerState::is_init(val)) return false;
      // is a slow wallet
      if (!DiemAccount::is_slow(val)) return false;

      if (!Vouch::unrelated_buddies_above_thresh(val)) return false;

      true
    }

    ////////// TEST HELPERS
    public fun test_helper_make_passing(account: &signer){
      assert!(Testnet::is_testnet(), 1905001);
      AutoPay::enable_autopay(account);
    }
  }
}