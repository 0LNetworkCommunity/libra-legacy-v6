
///////////////////////////////////////////////////////////////////
// 0L Module
// CommunityWallet
///////////////////////////////////////////////////////////////////


address DiemFramework {

/// This module is used to dynamically check if an account qualifies for the CommunityWallet flag.

/// Community Wallet is a flag that can be applied to an account.
/// These accounts are voluntarily creating a number of restrictions and guarantees for users that interact with it.
/// In essence, a group of people may set up a wallet with these characteristics to provide funding for a common program.

/// For example the matching donation game, which validators provide with burns from their account will check that a destination account has a Community Wallet Flag.

/// The CommunityWallets will have the following properties enabled by their owners.


/// 0. This wallet is initialized as a DonorDirected account. This means that it observes the policies of those accounts: namely, that the donors have Veto rights over the transactions which are proposed by the Owners of the account. Repeated rejections or an outright freeze poll, will prevent the Owners from transferring funds, and may ultimately revert the funds to a different community account (or burn).

/// !. They have instantiated a MultiSig controller, which means that actions on this wallet can only be done by an n-of-m consensus by the authorities of the account. Plus, the nominal credentials which created the account cannot be used, since the keys will no longer be valid.

/// 2. The Multisig account holders do not have common Ancestry. This is important to prevent an account holder from trivially creating sybil accounts to qualify as a community wallet. Sybils are possibly without common Ancestry, but it is much harder.

/// 3. The multisig account has a minimum of 5 Authorities, and a threshold of 3 signatures. If there are more authorities, a 3/5 ratio or more should be preserved.

/// 4. CommunityWallets have a high threshold for sybils: all multisig authorities must be unrelated in their permission trees, per Ancestry.

module CommunityWallet{

    use Std::Errors;
    use Std::Signer;
    use Std::FixedPoint32;
    use Std::Vector;
    use Std::Option;
    use DiemFramework::DonorDirected;
    use DiemFramework::MultiSig;
    use DiemFramework::Ancestry;
    
    const ENOT_AUTHORIZED: u64 = 023;

    const ENOT_QUALIFY_COMMUNITY_WALLET: u64 = 12000;

    /// This account needs to be donor directed.
    const ENOT_DONOR_DIRECTED: u64 = 120001;

    /// This account needs a multisig enabled
    const ENOT_MULTISIG: u64 = 120002;
    /// The multisig does not have minimum 5 signers and 3 approvals in config
    const ESIG_THRESHOLD: u64 = 120003;
    /// The multisig threshold does not equal 3/5
    const ESIG_THRESHOLD_RATIO: u64 = 120004;

    /// Signers may be sybil
    const ESIGNERS_SYBIL: u64 = 120005;

    /// Recipient does not have a slow wallet
    const EPAYEE_NOT_SLOW_WALLET: u64 = 120006;

    // A flag on the account that it wants to be considered a community walley
    struct CommunityWallet has key { }

    public fun is_init(addr: address):bool {
      exists<CommunityWallet>(addr)
    }
    public fun set_comm_wallet(sender: &signer) {
      let addr = Signer::address_of(sender);
      assert!(DonorDirected::is_donor_directed(addr), Errors::invalid_state(ENOT_DONOR_DIRECTED));
      
      if (is_init(addr)) {
        move_to(sender, CommunityWallet{});
      }
    }

    /// Dynamic check to see if CommunityWallet is qualifying.
    /// if it is not qualifying it wont be part of the burn funds matching.
    public fun is_comm(addr: address): bool {
      // The CommunityWallet flag is set
      is_init(addr) &&
      // has DonorDirected instantiated properly
      DonorDirected::is_donor_directed(addr) &&
      DonorDirected::liquidates_to_escrow(addr) &&
      // has MultiSig instantialized
      MultiSig::is_init(addr) &&
      // multisig has minimum requirement of 3 signatures, and minimum list of 5 signers, and a minimum of 3/5 threshold. I.e. OK to have 4/5 signatures.
      multisig_thresh(addr) &&
      // the multisig authorities are unrelated per Ancestry
      !multisig_common_ancestry(addr)
    }

    fun multisig_thresh(addr: address): bool{
      let (n, m) = MultiSig::get_n_of_m_cfg(addr);

      // can't have less than three signatures
      if (n < 3) return false;
      // can't have less than five authorities
      if (m < 5) return false;

      let r = FixedPoint32::create_from_rational(3, 5);
      let pct_baseline = FixedPoint32::multiply_u64(100, r);
      let r = FixedPoint32::create_from_rational(n, m);
      let pct = FixedPoint32::multiply_u64(100, r);

      pct > pct_baseline
    }

    fun multisig_common_ancestry(addr: address): bool {
      let list = MultiSig::get_authorities(addr);

      let (fam, _, _) = Ancestry::any_family_in_list(list);

      fam
    }

    //////// MULTISIG TX HELPERS ////////

    /// Helper to initialize the PaymentMultisig, but also while confirming that the signers are not related family
    /// These transactions can be sent directly to DonorDirected, but this is a helper to make it easier to initialize the multisig with the acestry requirements.

    // TODO: this version of Diem, does not allow vector<address> in the script arguments. So we are hard coding this to initialize with the minimum of 5 signers.

    public(script) fun init_community_multisig(
      sig: signer,
      signer_one: address,
      signer_two: address,
      signer_three: address,
      signer_four: address,
      signer_five: address,
    ) {
      let init_signers = Vector::singleton(signer_one);
      Vector::push_back(&mut init_signers, signer_two);
      Vector::push_back(&mut init_signers, signer_three);
      Vector::push_back(&mut init_signers, signer_four);
      Vector::push_back(&mut init_signers, signer_five);

      let (fam, _, _) = Ancestry::any_family_in_list(*&init_signers);

      assert!(!fam, Errors::invalid_argument(ESIGNERS_SYBIL));

      // set as donor directed with any liquidation going to infrastructure escrow
      let liquidate_to_infra_escrow = true;
      DonorDirected::set_donor_directed(&sig, liquidate_to_infra_escrow);
      DonorDirected::make_multisig(&sig, 3, init_signers);
    }

    /// add signer to multisig, and check if they may be related in Ancestry tree
    public(script) fun add_signer_community_multisig(sig: signer, multisig_address: address, new_signer: address, n_of_m: u64, vote_duration_epochs: u64) {
      let current_signers = MultiSig::get_authorities(multisig_address);
      let (fam, _, _) = Ancestry::is_family_one_in_list(new_signer, &current_signers);

      assert!(!fam, Errors::invalid_argument(ESIGNERS_SYBIL));

      MultiSig::propose_governance(
        &sig,
        multisig_address,
        Vector::singleton(new_signer),
        true, Option::some(n_of_m),
        Option::some(vote_duration_epochs)
      );

    }
  
}
}