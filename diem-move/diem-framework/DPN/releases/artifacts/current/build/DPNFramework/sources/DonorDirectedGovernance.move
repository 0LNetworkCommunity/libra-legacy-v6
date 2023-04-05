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
    use Std::Option::Option;
    use DiemFramework::Receipts;
    use DiemFramework::TurnoutTally::{Self, TurnoutTally};
    use DiemFramework::Ballot::{Self, BallotTracker};
    use DiemFramework::DiemAccount;
    use DiemFramework::DiemConfig;

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
      guid: GUID::ID,
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

    public fun check_is_donor(directed_account: address, user: address): bool {
      get_user_donations(directed_account, user) > 0
    }

    public fun assert_authorized(sig: &signer, directed_account: address) {
      let user = Signer::address_of(sig);
      assert!(check_is_donor(directed_account, user), Errors::requires_role(ENOT_A_DONOR));
    }

    public fun is_authorized(user: address, directed_account: address):bool {
      check_is_donor(directed_account, user)
    }

    /// For an individual donor, get the amount of votes that they can cast, based on their cumulative donations to the DonorDirected account.

    fun get_user_donations(directed_account: address, user: address): u64 {
      let (_, _, cumulative_donations) = Receipts::read_receipt(user, directed_account);

      cumulative_donations
    }


    //////// VETO FUNCTIONS ////////


    /// private function to vote on a ballot based on a Donor's voting power.
    fun vote_veto(user: &signer, ballot: &mut TurnoutTally<Veto>, uid: &GUID::ID, multisig_address: address): Option<bool> {
      let user_votes = get_user_donations(multisig_address, Signer::address_of(user));

      let veto_tx = true; // True means  approve the ballot, meaning: "veto transaction". Rejecting the ballot would mean "approve transaction".

      TurnoutTally::vote<Veto>(user, ballot, uid, veto_tx, user_votes)
    }



    //////// API ////////

        /// Public script transaction to propose a veto, or vote on it if it already exists.

    /// should only be called by the DonorDirected.move so that the handlers can be called on "pass" conditions.

    public(friend) fun veto_by_id(user: &signer, proposal_guid: &GUID::ID): Option<bool> acquires Governance {
      let directed_account = GUID::id_creator_address(proposal_guid);
      assert_authorized(user, directed_account);

      let state = borrow_global_mut<Governance<TurnoutTally<Veto>>>(directed_account);

      let ballot = Ballot::get_ballot_by_id_mut(&mut state.tracker, proposal_guid);
      let tally_state = Ballot::get_type_struct_mut(ballot);

      vote_veto(user, tally_state, proposal_guid, directed_account)
    }

    public(friend) fun sync_ballot_and_tx_expiration(user: &signer, proposal_guid: &GUID::ID, epoch_deadline: u64) acquires Governance {
      let directed_account = GUID::id_creator_address(proposal_guid);
      assert_authorized(user, directed_account);

      let state = borrow_global_mut<Governance<TurnoutTally<Veto>>>(directed_account);

      let ballot = Ballot::get_ballot_by_id_mut(&mut state.tracker, proposal_guid);
      let tally_state = Ballot::get_type_struct_mut(ballot);

      TurnoutTally::extend_deadline(tally_state, epoch_deadline);

    }



    public(friend)  fun propose_veto(
      cap: &GUID::CreateCapability,
      guid: &GUID::ID, // Id of initiated transaction.
      epochs_duration: u64
    ) acquires Governance {
      let data = Veto { guid: *guid };
      propose_gov<Veto>(cap, data, epochs_duration);
    }

    public(friend)  fun propose_liquidate(
      cap: &GUID::CreateCapability,
      epochs_duration: u64
    ) acquires Governance {
      let data = Liquidate { };
      propose_gov<Liquidate>(cap, data, epochs_duration);
    }

    /// a private function to propose a ballot for a veto. This is called by a verified donor.

    fun propose_gov<GovAction: drop + store>(cap: &GUID::CreateCapability, data: GovAction, epochs_duration: u64) acquires Governance {
      let directed_account = GUID::get_capability_address(cap);
      let gov_state = borrow_global_mut<Governance<TurnoutTally<GovAction>>>(directed_account);
      
      // let data = Veto { guid: proposal_guid };
      // what's the maximum universe of valid votes.
      let max_votes_enrollment = get_enrollment(directed_account);
      if (epochs_duration < 7) {
        epochs_duration = 7;
      };

      let deadline = DiemConfig::get_current_epoch() + epochs_duration; // 7 epochs is about 1 week
      let max_extensions = 0; // infinite

      let t = TurnoutTally::new_tally_struct(
        // cap,
        data,
        max_votes_enrollment,
        deadline,
        max_extensions
      );
      
      Ballot::propose_ballot(&mut gov_state.tracker, cap, t);
    }



}
}