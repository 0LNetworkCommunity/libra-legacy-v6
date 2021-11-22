// Transaction script for setting delegation settings. Both the leader of the delegation, and the followers.


address 0x1 {
module DelegationScripts {
    use 0x1::Delegation;

    public(script) fun create_team(
        sender: signer,
        team_name: vector<u8>,
        operator_pct_reward: u64,
    ) {
      Delegation::team_init(&sender, team_name, operator_pct_reward);
    }
}
}