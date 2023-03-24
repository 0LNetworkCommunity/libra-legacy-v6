address DiemFramework {
module OracleScripts {
    use DiemFramework::Oracle;

    public(script) fun ol_oracle_tx(sender: signer, id: u64, data: vector<u8>) {
        Oracle::handler(&sender, id, data);
    }

    public(script) fun ol_revoke_vote(sender: signer) {
        Oracle::revoke_my_votes(&sender);
    }    

    /// A validator (Alice) can delegate the authority for the operation of
    /// an upgrade to another validator (Bob). When Oracle delegation happens,
    /// effectively the consensus voting power of Alice, is added to Bob only
    ///for the effect of calculating the preference on electing a stdlib binary.
    /// Whatever binary Bob proposes, Alice will also propose without needing
    /// to be submitting transactions.

    public(script) fun ol_delegate_vote(sender: signer, dest: address) {
        // if for some reason not delegated
        Oracle::enable_delegation(&sender);

        Oracle::delegate_vote(&sender, dest);
    }

    /// First Bob must have delegation enabled, which can be done with:

    public(script) fun ol_enable_delegation(sender: signer) {
        Oracle::enable_delegation(&sender);
    }
    /// Alice can remove Bob as the delegate with this function.
    public(script) fun ol_remove_delegation(sender: signer) {
        Oracle::remove_delegate_vote(&sender);
    }

}
}