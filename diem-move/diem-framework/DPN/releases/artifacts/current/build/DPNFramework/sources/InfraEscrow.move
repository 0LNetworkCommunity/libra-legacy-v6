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
    use Std::Option;
    use DiemFramework::PledgeAccounts;
    use DiemFramework::CoreAddresses;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Diem;
    use DiemFramework::TransactionFee;
    // use DiemFramework::Debug::print;

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
    public fun infra_pledge_withdraw(vm: &signer, amount: u64): Option::Option<Diem::Diem<GAS>> {
        CoreAddresses::assert_diem_root(vm);
        PledgeAccounts::withdraw_from_all_pledge_accounts(vm, amount)
    }

    /// Helper for epoch boundaries.
    /// Collects funds from pledge and places temporarily in network account (TransactionFee account)
    public fun epoch_boundary_collection(vm: &signer, amount: u64) {
        CoreAddresses::assert_diem_root(vm);
        let opt = PledgeAccounts::withdraw_from_all_pledge_accounts(vm, amount);
        // print(&opt);
        if (Option::is_none(&opt)) {
          Option::destroy_none(opt);
          return
        };
        let c = Option::extract(&mut opt);
        Option::destroy_none(opt);

        TransactionFee::pay_fee<GAS>(c);
    }

    // Transaction script for user to pledge to infra escrow.
    public fun user_pledge_infra(user_sig: &signer, amount: u64){

      PledgeAccounts::user_pledge(user_sig, @VMReserved, amount);
    }

}
}

