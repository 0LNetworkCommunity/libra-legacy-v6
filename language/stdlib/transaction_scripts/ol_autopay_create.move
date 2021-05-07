script {
  use 0x1::AutoPay2;
  use 0x1::Signer;
  use 0x1::Errors;

  const EAUTOPAY_NOT_ENABLED: u64 = 01001;

  fun autopay_create_instruction(
    sender: &signer,
    uid: u64,
    type: u8,
    payee: address,
    end_epoch: u64,
    percentage: u64,
  ) {
    let account = Signer::address_of(sender);

    if (!AutoPay2::is_enabled(account)) {
      AutoPay2::enable_autopay(sender);
      assert(AutoPay2::is_enabled(account), Errors::invalid_state(EAUTOPAY_NOT_ENABLED));
    };

    AutoPay2::create_instruction(
      sender, 
      uid,
      type,
      payee,
      end_epoch,
      percentage,
    );
  }
}