address 0x1 {
  module Audit {
    use 0x1::ValidatorConfig;
    use 0x1::DiemAccount;
    use 0x1::GAS::GAS;
    use 0x1::AutoPay2;
    use 0x1::MinerState;
    // use 0x1::Testnet;

    public fun val_audit_passing(val: address): bool {
      // if (Testnet::is_testnet()){ return true };
      // has valid configs
      if (!ValidatorConfig::is_valid(val)) return false;

      // has operator account set to another address
      let oper = ValidatorConfig::get_operator(val);
      if (oper == val) return false;

      // operator account has balance
      if (DiemAccount::balance<GAS>(oper) < 50000) return false;

      // has autopay enabled
      if (!AutoPay2::is_enabled(val)) return false;

      // has mining state
      if (!MinerState::is_init(val)) return false;
      
      // TODO: has network settings for validator
      // TBD: is a SlowWallet

      true
    }
  }
}