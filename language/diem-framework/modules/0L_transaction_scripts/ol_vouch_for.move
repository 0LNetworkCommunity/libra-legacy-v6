address 0x1 {
module VouchScripts {

    use 0x1::Vouch;

    // in case the epoch migration did not initialize the vouch struct.
    public(script) fun init_vouch(sender: signer) {
      Vouch::init(&sender);
    }

    public(script) fun vouch_for(sender: signer, val: address) {
      Vouch::vouch_for(&sender, val);
    }

    public(script) fun revoke_vouch(sender: signer, val: address) {
      Vouch::revoke(&sender, val);
    }
}
}