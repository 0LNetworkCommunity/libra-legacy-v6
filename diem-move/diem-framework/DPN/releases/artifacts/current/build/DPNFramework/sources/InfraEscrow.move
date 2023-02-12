///////////////////////////////////////////////////////////////////////////
// 0L Module
// Infra Escrow
///////////////////////////////////////////////////////////////////////////
// Controls funds that have been pledged to infrastructure subsidy
// Like other Pledged segregated accounts, the value lives on the 
// user's account. The funding is not pooled into a system account.
// According to the policy the funds may be drawn down from Pledged
// segregated accounts. 
///////////////////////////////////////////////////////////////////////////


address DiemFramework{
    module InfraEscrow{

    use DiemFramework::PledgeAccounts;
    use DiemFramework::CoreAddresses;

    /// for use on genesis, creates the infra escrow pledge policy struct
    public fun initialize_infra_pledge(vm: &signer) {
        CoreAddresses::assert_diem_root(vm);
        // TODO: perhaps this policy needs to be published to a different address?
        PledgeAccounts::publish_beneficiary_policy(
          vm, // only VM calls at genesis
          b"infra escrow",
          90,
          true
        );
    }

    /// VM can call down pledged funds.
    public fun infra_pledge_withdraw(vm: &signer, amount: u64) {
        CoreAddresses::assert_diem_root(vm);
        PledgeAccounts::withdraw_from_all_pledge_accounts(vm, amount);
    }

    /// for end users to pledge to the infra escrow
    public(script) fun user_pledge_tx(user_sig: signer, amount: u64) {
      PledgeAccounts::create_pledge_account(&user_sig, @VMReserved, amount);
   }

}
}

