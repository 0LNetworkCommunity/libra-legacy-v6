script {
    use 0x1::Wallet;
    fun set_wallet_type(sender: &signer, type_of: u8, unset: bool) {
      if (type_of == 0) {
        Wallet::set_slow(sender);
      };

      if (type_of == 1) {
        if (unset) {
          Wallet::remove_comm(sender);
        } else {
          Wallet::set_comm(sender);
        };
      };
    }
}
