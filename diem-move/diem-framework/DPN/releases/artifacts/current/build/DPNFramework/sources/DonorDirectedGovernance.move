address DiemFramework {

  /// DonorDirected wallet governance. See documentation at DonorDirected.move


  /// For each DonorDirected account there are Donors.
  /// We establish who is a Donor through the Receipts module.
  /// The DonorDirected account also has a tracker for the Cumulative amount of funds that have been sent to this account.
  /// We will use the lifetime cumulative amounts sent as the total amount of votes that can be cast (voter enrollment).
  
  /// The voting on a veto of a transaction or an outright liquidation of the account is done by the Donors.
  /// The voting mechanism is a ParticipationVote. Such votes ajust the threshold for passing a vote based on the actual turnout. I.e. The fewer people that vote, the higher the threshold to reach consensus. But a vote is not scuttled if the turnout is low. See more details in the ParticipationVote.move module.
module DonorDirectedGovernance {
    friend DiemFramework::DonorDirected;

    use Std::Errors;
    use Std::Signer;
    // use Std::Option::{Self, Option};
    use Std::GUID;
    use DiemFramework::Receipts;
    use DiemFramework::ParticipationVote::{Self, Poll, Ballot};
    use DiemFramework::DiemConfig;
    use DiemFramework::DiemAccount;

    /// Is not a donor to this account
    const ENOT_A_DONOR: u64 = 220000;
    /// No ballot found under that GUID
    const ENO_BALLOT_FOUND: u64 = 220001;

    /// Data struct to store all the governance Ballots for vetos
    /// allows for a generic type of Governance action, using the Participation Vote Poll type to keep track of ballots
    struct Governance<GovAction> has key {
      poll: Poll<GovAction>,
    }

    /// this is a GovAction type for veto
    struct Veto has copy, store {
      guid: u64,
    }

    /// this is a GovAction type for liquidation
    struct Liquidate has copy, store {}



    public fun init_donor_governance(directed_account: &signer) {
      let veto = Governance<Veto> { 
          poll: ParticipationVote::new_poll<Veto>() 
      };

      move_to(directed_account, veto);

      let liquidate = Governance<Liquidate> { 
          poll: ParticipationVote::new_poll<Liquidate>() 
      };
      move_to(directed_account, liquidate);
    }

    /// For a DonorDirected account get the total number of votes enrolled from reading the Cumulative tracker.
    fun get_enrollment(directed_account: address): u64 {
      DiemAccount::get_cumulative_deposits(directed_account)
    }

    /// public function to check that a user account is a Donor for a DonorDirected account.

    fun check_is_donor(directed_account: address, user: address): bool {
      get_user_donations(directed_account, user) > 0
    }

    fun assert_authorized(sig: &signer, directed_account: address) {
      let user = Signer::address_of(sig);
      assert!(check_is_donor(directed_account, user), Errors::requires_role(ENOT_A_DONOR));
    }

    /// For an individual donor, get the amount of votes that they can cast, based on their cumulative donations to the DonorDirected account.

    fun get_user_donations(directed_account: address, user: address): u64 {
      let (_, _, cumulative_donations) = Receipts::read_receipt(user, directed_account);

      cumulative_donations
    }


    //////// VETO FUNCTIONS ////////

    /// a private function to propose a ballot for a veto. This is called by a verified donor.

    fun propose_veto(cap: &GUID::CreateCapability, directed_account: address, proposal_guid: u64) acquires Governance {
      let gov_state = borrow_global_mut<Governance<Veto>>(directed_account);

      let v = Veto { guid: proposal_guid };
      
      ParticipationVote::propose_ballot(
        cap,
        &mut gov_state.poll,
        v,
        get_enrollment(directed_account),
        DiemConfig::get_current_epoch() + 7, // 7 epochs is about 1 week
        0, // TODO: remove this parameter from the ParticipationVote module
      );
    }


    /// private function to vote on a ballot based on a Donor's voting power.

    // Todo: the ballot data should contain the multisig address in GUID
    fun vote_veto(user: &signer, ballot: &mut Ballot<Veto>, multisig_address: address): bool {
      let user_votes = get_user_donations(multisig_address, Signer::address_of(user));

      let veto_tx = true; // True means  approve the ballot, meaning: "veto transaction". Rejecting the ballot would mean "approve transaction".

      ParticipationVote::vote<Veto>(ballot, user, veto_tx, user_votes)
    }
  

    /// private function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.
    fun get_pending_ballot<GovAction: copy + store> (gov_state: &mut Governance<GovAction>, proposal_guid: &GUID::ID): &mut ParticipationVote::Ballot<GovAction> {
      
      // let (found, idx) = find_index_of_ballot(gov_state, proposal_guid);
      // assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

      let ballot = ParticipationVote::get_ballot_mut(&mut gov_state.poll, proposal_guid, 0); // 0 enum of pending ballots
      ballot
    }

    // fun find_index_of_ballot<GovAction: copy + store>(gov_state: &mut Governance<GovAction>, proposal_guid: &GUID::ID): (bool, u64) {
    //   // let gov_state = borrow_global<Ballots>(directed_account);
    //   let i = 0;
    //   while (i < Vector::length(&gov_state.poll)) {
    //     let b = Vector::borrow(&gov_state.poll, i);
    //     if (&ParticipationVote::get_pending_ballot_id(b) == proposal_guid) {
    //       return (true, i)
    //     };
    //     i = i + 1;
    //   };

    //   (false, 0)
    // }

    /// Public script transaction to propose a veto, or vote on it if it already exists.

    /// should only be called by the DonorDirected.move so that the handlers can be called on "pass" conditions.

    public(friend) fun veto_by_id(user: &signer, proposal_guid: &GUID::ID): bool acquires Governance {
      let directed_account = GUID::id_creator_address(proposal_guid);
      assert_authorized(user, directed_account);

      let vb = borrow_global_mut<Governance<Veto>>(directed_account);
      let ballot = get_pending_ballot<Veto>(vb, proposal_guid);

      vote_veto(user, ballot, directed_account)
    }

    public(friend) fun sync_ballot_and_tx_expiration(user: &signer, proposal_guid: &GUID::ID, epoch_deadline: u64) acquires Governance {
      let directed_account = GUID::id_creator_address(proposal_guid);
      assert_authorized(user, directed_account);

      let vb = borrow_global_mut<Governance<Veto>>(directed_account);
      let ballot = get_pending_ballot(vb, proposal_guid);

      ParticipationVote::extend_deadline(ballot, epoch_deadline);

    }


    //////// LIQUIDATION FUNCTIONS ////////

    fun propose_gov<GovAction: copy + store>(cap: &GUID::CreateCapability, directed_account: address, data: GovAction) acquires Governance {
      let gov_state = borrow_global_mut<Governance<GovAction>>(directed_account);

      ParticipationVote::propose_ballot(
        cap,
        &mut gov_state.poll,
        data,
        get_enrollment(directed_account),
        DiemConfig::get_current_epoch() + 7, // 7 epochs is about 1 week
        0, // TODO: remove this parameter from the ParticipationVote module
      );
    }



}
}