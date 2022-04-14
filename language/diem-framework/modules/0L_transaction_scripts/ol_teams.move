// Transaction script for setting delegation settings. Both the leader of the delegation, and the followers.


address 0x1 {
module TeamsScripts {
    use 0x1::Teams;

    public(script) fun create_team(
        sender: signer,
        team_name: vector<u8>,
        operator_pct_reward: u64,
    ) {
      Teams::team_init(&sender, team_name, operator_pct_reward);
    }

    public(script) fun join_team(
        sender: signer,
        captain: address,
    ) {
      Teams::join_team(&sender, captain);
    }
}
}