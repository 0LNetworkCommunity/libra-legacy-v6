/////////////////////////////////////////////////////////////////////////
// 0L Module
// Audit Module
// Error code: 1905
/////////////////////////////////////////////////////////////////////////

address 0x1 {
  module Audit {
    use 0x1::ValidatorConfig;
    use 0x1::DiemAccount;
    use 0x1::AutoPay;
    use 0x1::TowerState;
    use 0x1::Testnet;
    use 0x1::Vouch;

    use 0x1::Debug::print;


    public fun val_audit_passing(val: address): bool {
      print(&11111);
      // has valid configs
      if (!ValidatorConfig::is_valid(val)) return false;
      // has operator account set to another address
      let oper = ValidatorConfig::get_operator(val);
      if (oper == val) return false;
      // operator account has balance
      // if (DiemAccount::balance<GAS>(oper) < 50000 && !Testnet::is_testnet()) return false;
      // has autopay enabled
      print(&111110001);

      // if (!AutoPay::is_enabled(val)) return false;

            print(&111110002);

      // has mining state
      if (!TowerState::is_init(val)) return false;
            print(&111110003);

      // is a slow wallet
      if (!DiemAccount::is_slow(val)) return false;
      print(&111110004);

      if (!Vouch::unrelated_buddies_above_thresh(val)) return false;
      print(&111110005);

      true
    }

    ////////// TEST HELPERS
    public fun test_helper_make_passing(account: &signer){
      assert(Testnet::is_testnet(), 1905001);
      AutoPay::enable_autopay(account);
    }
  }
}