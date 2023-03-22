address DiemFramework {

/// DonorDirected wallet governance. See documentation at DonorDirected.move


  /// For each DonorDirected account there are Donors.
  /// We establish who is a Donor through the Receipts module.
  /// The DonorDirected account also has a tracker for the Cumulative amount of funds that have been sent to this account.
  /// We will use the lifetime cumulative amounts sent as the total amount of votes that can be cast (voter enrollment).
  
  /// The voting on a veto of a transaction or an outright liquidation of the account is done by the Donors.
  /// The voting mechanism is a ParticipationVote. Such votes ajust the threshold for passing a vote based on the actual turnout. I.e. The fewer people that vote, the higher the threshold to reach consensus. But a vote is not scuttled if the turnout is low. See more details in the ParticipationVote.move module.
module DonorDirectedGovernance {

    use Std::Vector;
    use Std::Errors;
    use Std::Signer;
    use DiemFramework::Receipts;
    use DiemFramework::ParticipationVote;
    use DiemFramework::DiemConfig;
    use DiemFramework::DiemAccount;

    /// Is not a donor to this account
    const ENOT_A_DONOR: u64 = 220000;

    /// Data struct to store all the governance Ballots for vetos

    struct VetoBallots has key {
      ballots: vector<ParticipationVote::Ballot<Veto>>,
    }

    struct Veto has copy, store {
      guid: u64,
    }


    /// Data struct to store all governance Ballots for liquidation

    struct LiquidateBallots has key {
      ballots: vector<ParticipationVote::Ballot<Liquidate>>,
    }

    struct Liquidate has copy, store {}



    public fun init_donor_governance(directed_account: &signer) {
      let veto = VetoBallots { ballots: Vector::empty() };
      move_to(directed_account, veto);
      let liquidate = LiquidateBallots { ballots: Vector::empty() };
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

    /// a private function to propose a ballot for a veto. This is called by a verified donor.

    fun propose_veto(user: &signer, directed_account: address, proposal_guid: u64) acquires VetoBallots {
      let vetoballots = borrow_global_mut<VetoBallots>(directed_account);

      let v = Veto { guid: proposal_guid };
      
      let ballot = ParticipationVote::new<Veto>(
        user, 
        v, // data
        get_enrollment(directed_account),
        DiemConfig::get_current_epoch() + 3, // TODO: needs to adjust with each new vote.
        0
      );

      Vector::push_back(&mut vetoballots.ballots, ballot);
    }


    /// private function to vote on a ballot based on a Donor's voting power.


    /// Public script transaction to propose a veto, or vote on it if it already exists.


    /// private function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.


    /// private handler for calling liquidation() on the DonorDircted.move module.








}
}