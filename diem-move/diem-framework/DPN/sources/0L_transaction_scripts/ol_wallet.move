address DiemFramework {
module WalletScripts {

    use DiemFramework::Wallet;
    use DiemFramework::DiemAccount;

    public(script) fun set_wallet_type(sender: signer, type_of: u8) {
      if (type_of == 0) {
        DiemAccount::set_slow(&sender);
      };

      if (type_of == 1) {
          Wallet::set_comm(&sender);
      };
    }
}
}