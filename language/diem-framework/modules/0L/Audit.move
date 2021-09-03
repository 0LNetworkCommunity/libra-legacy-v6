address 0x1 {
  module Audit {
    use 0x1::ValidatorConfig;
    use 0x1::DiemAccount;
    use 0x1::GAS::GAS;
    use 0x1::AutoPay2;
    use 0x1::MinerState;
    use 0x1::Debug::print;
    use 0x1::Testnet;

    public fun val_audit_passing(val: address): bool {
      // if (Testnet::is_testnet()){ return true };
      // has valid configs
      print(&20000);

      if (!ValidatorConfig::is_valid(val)) return false;
      print(&20001);
      // has operator account set to another address
      let oper = ValidatorConfig::get_operator(val);
      if (oper == val) return false;
print(&20002);
        // operator account has balance
      if (DiemAccount::balance<GAS>(oper) < 50000 && !Testnet::is_testnet()) return false;
print(&20003);
      // has autopay enabled
      if (!AutoPay2::is_enabled(val)) return false;

print(&20004);
      // has mining state
      if (!MinerState::is_init(val)) return false;
      
      // TODO: has network settings for validator
      // TBD: is a SlowWallet

      true
    }

    ////////// TEST HELPERS
    public fun make_passing(val: &signer){
      AutoPay2::enable_autopay(val);
    }
  }
}