script {
  use 0x1::AutoPay;
  use 0x1::Signer;
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
    };

    AutoPay::create_instruction(
      sender, 
      uid,
      payee,
      end_epoch,
      percentage,
    );
    assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
  }
}