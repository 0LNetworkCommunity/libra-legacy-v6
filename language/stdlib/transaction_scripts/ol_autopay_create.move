script {
  use 0x1::AutoPay;
  use 0x1::Signer;
  use 0x1::Errors;

  const EAUTOPAY_NOT_ENABLED: u64 = 111;

  fun autopay_create_instruction(
    sender: &signer,
    uid: u64,
    payee: address,
    end_epoch: u64,
    percentage: u64,
  ) {
    let account = Signer::address_of(sender);

    if (!AutoPay::is_enabled(account)) {
      AutoPay::enable_autopay(sender);
      assert(AutoPay::is_enabled(account), Errors::ol_tx(EAUTOPAY_NOT_ENABLED));
    };

    AutoPay::create_instruction(
      sender, 
      uid,
      payee,
      end_epoch,
      percentage,
    );
  }
}