address DiemFramework {

  /// DonorDirected wallet governance. See documentation at DonorDirected.move


  /// For each DonorDirected account there are Donors.
  /// We establish who is a Donor through the Receipts module.
  /// The DonorDirected account also has a tracker for the Cumulative amount of funds that have been sent to this account.
  /// We will use the lifetime cumulative amounts sent as the total amount of votes that can be cast (voter enrollment).
  
  /// The voting on a veto of a transaction or an outright liquidation of the account is done by the Donors.
  /// The voting mechanism is a TurnoutTally. Such votes ajust the threshold for passing a vote based on the actual turnout. I.e. The fewer people that vote, the higher the threshold to reach consensus. But a vote is not scuttled if the turnout is low. See more details in the TurnoutTally.move module.
module DonorDirectedGovernance {
    friend DiemFramework::DonorDirected;

    use Std::Errors;
    use Std::Signer;
    use Std::GUID;
    use DiemFramework::Receipts;
    use DiemFramework::TurnoutTally::{Self, TurnoutTally};
    use DiemFramework::Ballot::{Self, BallotTracker};
    use DiemFramework::DiemAccount;

    /// Is not a donor to this account
    const ENOT_A_DONOR: u64 = 220000;
    /// No ballot found under that GUID
    const ENO_BALLOT_FOUND: u64 = 220001;

    /// Data struct to store all the governance Ballots for vetos
    /// allows for a generic type of Governance action, using the Participation Vote Poll type to keep track of ballots
    struct Governance<T> has key {
      tracker: BallotTracker<T>,
    }

    /// this is a GovAction type for veto
    struct Veto has drop, store {
      guid: u64,
    }

    /// this is a GovAction type for liquidation
    struct Liquidate has drop, store {}



    public fun init_donor_governance(directed_account: &signer) {

      // let t = TurnoutTally::new_tally_struct();
      let veto = Governance<TurnoutTally<Veto>> { 
          tracker: Ballot::new_tracker() 
      };

      move_to(directed_account, veto);

      let liquidate = Governance<TurnoutTally<Liquidate>> { 
          tracker: Ballot::new_tracker() 
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


    // //////// VETO FUNCTIONS ////////

    // /// a private function to propose a ballot for a veto. This is called by a verified donor.

    // fun propose_veto(cap: &GUID::CreateCapability, directed_account: address, proposal_guid: u64) acquires Governance {
    //   let gov_state = borrow_global_mut<Governance<Veto>>(directed_account);

    //   let v = Veto { guid: proposal_guid };
      
    //   TurnoutTally::propose_ballot(
    //     cap,
    //     &mut gov_state.poll,
    //     v,
    //     get_enrollment(directed_account),
    //     DiemConfig::get_current_epoch() + 7, // 7 epochs is about 1 week
    //     0, // TODO: remove this parameter from the TurnoutTally module
    //   );
    // }


    /// private function to vote on a ballot based on a Donor's voting power.
    fun vote_veto(user: &signer, ballot: &mut TurnoutTally<Veto>, multisig_address: address): bool {
      let user_votes = get_user_donations(multisig_address, Signer::address_of(user));

      let veto_tx = true; // True means  approve the ballot, meaning: "veto transaction". Rejecting the ballot would mean "approve transaction".

      TurnoutTally::vote<Veto>(ballot, user, veto_tx, user_votes)
    }

    // /// Public script transaction to propose a veto, or vote on it if it already exists.

    // /// should only be called by the DonorDirected.move so that the handlers can be called on "pass" conditions.

    public(friend) fun veto_by_id(user: &signer, proposal_guid: &GUID::ID): bool acquires Governance {
      let directed_account = GUID::id_creator_address(proposal_guid);
      assert_authorized(user, directed_account);

      let state = borrow_global_mut<Governance<TurnoutTally<Veto>>>(directed_account);

      let ballot = Ballot::get_ballot_by_id_mut(&mut state.tracker, proposal_guid);
      let tally_state = Ballot::get_type_struct_mut(ballot);

      // let ballot = get_pending_ballot<Veto>(vb, proposal_guid);

      vote_veto(user, tally_state, directed_account)
      // true
    }

    public(friend) fun sync_ballot_and_tx_expiration(user: &signer, proposal_guid: &GUID::ID, epoch_deadline: u64) acquires Governance {
      let directed_account = GUID::id_creator_address(proposal_guid);
      assert_authorized(user, directed_account);

      let state = borrow_global_mut<Governance<TurnoutTally<Veto>>>(directed_account);

      let ballot = Ballot::get_ballot_by_id_mut(&mut state.tracker, proposal_guid);
      let tally_state = Ballot::get_type_struct_mut(ballot);

      TurnoutTally::extend_deadline(tally_state, epoch_deadline);

    }


    //////// LIQUIDATION FUNCTIONS ////////

    // fun propose_gov<GovAction: copy + store>(cap: &GUID::CreateCapability, directed_account: address, data: GovAction) acquires Governance {
    //   let gov_state = borrow_global_mut<Governance<GovAction>>(directed_account);

    //   TurnoutTally::propose_ballot(
    //     cap,
    //     &mut gov_state.poll,
    //     data,
    //     get_enrollment(directed_account),
    //     DiemConfig::get_current_epoch() + 7, // 7 epochs is about 1 week
    //     0, // TODO: remove this parameter from the TurnoutTally module
    //   );
    // }



}
}