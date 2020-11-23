script {
  use 0x1::AutoPay;
  use 0x1::Signer;
  fun autopay_create_instruction_tx(sender: &signer) {
    let account = Signer::address_of(sender);
    let uid = 1;
    let payee = 0x02;
    let end_epoch = 14;
    let percentage = 1;
    assert(AutoPay::is_enabled(account), 0);
    AutoPay::create_instruction(
      sender, 
      uid,
      payee,
      end_epoch,
      percentage,
    );
  }
}