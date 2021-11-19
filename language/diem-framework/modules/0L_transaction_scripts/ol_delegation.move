// Transaction script for setting delegation settings. Both the leader of the delegation, and the followers.


address 0x1 {
module DelegationScripts {
    use 0x1::Delegation;

    public(script) fun create_tribe(
        sender: signer,
        tribe_name: vector<u8>,
        operator_pct_bonus: u64,
    ) {
      Delegation::elder_init(&sender, tribe_name, operator_pct_bonus);
    }
}
}