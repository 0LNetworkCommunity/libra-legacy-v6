///////////////////////////////////////////////////////////////////////////
// 0L Module
// MultiSig
// A payment tool for transfers which require n-of-m approvals
///////////////////////////////////////////////////////////////////////////


// The main design goals of this multisig implementation are:
// 0 . Should allow arbitrary actions to be coded by a third party contract, and governed by the multisig. Payments one case, but other actions are possible.
// 1. should leverage the usual transaction flow and tools which users are familiar with to add funds to the account. The funds remain viewable by the usual tools for viewing account balances.
// 2. The authority over the address should not require collecting signatures offline: transactions should be submitted directly to the contract.
// 3. Funds are disbursed as usual: to a destination addresses, and not into any intermediate structures.
// 4. Does not pool funds into a custodian contract (like gnosis-type implementations)
// 5. Uses the shared security of the root address, and as such charge a fee for this benefit.

// Custody
// This multisig implementation does not custody funds in a central address (the MultiSig smart contract address does not pool funds).

// The multisig funds exist on a remote address, the address of the creator.
// This implies some safety features which need to be implemented to prevent the creator from having undue influence over the multisig after it has been created.

// No Segregation
// Once the account is created, and intantiated as a multisig, the funds remain in the ordinary data structure for coins. There is no intermediary data structure which holds the coins, neither on the account address, nor in the smart contract address.
// This means that all existing tools for sending transfers to this account will execute as usual. All tools and APIs which read balances will work as usual.

// Root Security
// A third party multisig app could not achieve the design goals above. Achieving it requires tight coupling to the DiemAccount tools, and VM authority. Third party multisig apps are possible, but either they will use a custodial model, use segrated structures on a sender account (where the signer may always have authority), or they will require the user to collect signatures offline. All of these options will require new tooling to fund, withdraw, and view coins.

// Fees
// As noted elsewhere there is value in "Root Security" and as such there would be a fee for this service. The fee is a percentage of the funds which are added to the multisig. The fee is paid to the root address, and is used to pay for the security from consensus (validator rewards). The fee is a percentage of the funds added to the multisig.


// Authorities
// What changes from a vanilla 0L Address that the "signer" for the account loses access to that account. And instead the funds are controlled by the Multisig logic. The implementation of this is that the account's AuthKey is rotated to a random number, and the signer for the account is removed, forcing the signer to lose control. As such the sender needs to THINK CAREFULLY about the initial set of authorities on this address.



address DiemFramework {
module MultiSig {
  use Std::Vector;
  use Std::Option::{Self, Option};
  use Std::Signer;
  use Std::Errors;
  use DiemFramework::DiemAccount::{Self, WithdrawCapability};
  use DiemFramework::DiemConfig;
  use DiemFramework::Debug::print;


  const EGOV_NOT_INITIALIZED: u64 = 440000;
  /// The owner of this account can't be an authority, since it will subsequently be bricked. The signer of this account is no longer useful. The account is now controlled by the MultiSig logic. 
  const ESIGNER_CANT_BE_AUTHORITY: u64 = 440001;

  /// Signer not authorized to approve a transaction.
  const ENOT_AUTHORIZED: u64 = 440002;

  /// There are no pending transactions to search
  const EPENDING_EMPTY: u64 = 440003;

  /// Not enough signers configured
  const ENO_SIGNERS: u64 = 440004;
  /// The multisig setup  is not finalized, the sponsor needs to brick their authkey. The account setup sponsor needs to be verifiably locked out before operations can begin. 
  const ENOT_FINALIZED_NOT_BRICK: u64 = 440005; 

  const DEFAULT_EPOCHS_EXPIRE: u64 = 14; // default setting for a proposal to expire

  const EACTION_ALREADY_EXISTS: u64 = 440006;

  
  /// A MultiSig account is an account which requires multiple votes from Authorities to  send a transaction.
  /// A multisig can be used to get agreement on different types of Actions, such as a payment transaction where the handler code for the transaction is an a separate contract. See for example MultiSigPayment.
  /// MultiSig struct holds the metadata for all the instances of Actions on this account.
  /// Every action has the same set of authorities and governance.
  /// This is intentional, since privilege escalation can happen if each action has a different set of governance, but access to funds and other state.
  /// If the organization wishes to have Actions with different governance, then a separate Account is necessary.


  /// DANGER
  // MultiSig optionally holds a WithdrawCapability, which is used to withdraw funds from the account. All actions share the same WithdrawCapability.
  /// The WithdrawCapability can be used to withdraw funds from the account.
  /// Ordinarily only the signer/owner of this address can use it.
  /// We are bricking the signer, and as such the withdraw capability is now controlled by the MultiSig logic.
  /// Core Devs: This is a major attack vector. The WithdrawCapability should NEVER be returned to a public caller, UNLESS it is within the vote and approve flow.

  /// Note, the WithdrawCApability is moved to this shared structure, and as such the signer of the account is bricked. The signer who was the original owner of this account ("sponsor") can no longer issue transactions to this account, and as such the WithdrawCapability would be inaccessible. So on initialization we extract the WithdrawCapability into the MultiSig governance struct.

  struct MultiSig has key {
    cfg_expire_epochs: u64,
    cfg_default_n_sigs: u64,
    signers: vector<address>,
    withdraw_capability: Option<WithdrawCapability>,
    counter: u64, // TODO: Use GUID? the monotonically increasing id of proposal. Also equal to length of proposals. And the ID of the NEXT proposal to be submitted.
  }

  struct Action<ProposalData> has key, store {
    can_withdraw: bool,
    pending: vector<Proposal<ProposalData>>,
    approved: vector<Proposal<ProposalData>>,
    rejected:  vector<Proposal<ProposalData>>,
  }

  // all proposals share some common fields
  // and each proposal can add type-specific parameters
  // The handler for such specific parameters needs to included in code by an external contract.
  // MultiSig, will only say if it passed or not.
  struct Proposal<ProposalData> has key, store, copy, drop {
    id: u64,
    // The transaction to be executed
    proposal_data: ProposalData,
    // The votes received
    votes: vector<address>,
    // approved
    approved: bool,
    // The expiration time for the transaction
    expiration_epoch: u64,
  }



  fun assert_authorized(sig: &signer, multisig_address: address) acquires MultiSig {
        // cannot start manipulating contract until it is finalized
    assert!(is_finalized(multisig_address), Errors::invalid_argument(ENOT_FINALIZED_NOT_BRICK));

    assert!(exists<MultiSig>(multisig_address), Errors::invalid_argument(ENOT_AUTHORIZED));

    // check sender is authorized
    let sender_addr = Signer::address_of(sig);
    assert!(is_authority(multisig_address, sender_addr), Errors::invalid_argument(ENOT_AUTHORIZED));
  }


  // Initialize the governance structs for this account.
  // MultiSig contains the constraints for each Action that are checked on each vote (n_sigs, expiration, signers, etc)
  // Also, an initial Action of type PropGovSigners is created, which is used to govern the signers and threshold for this account.
  public fun init_gov(sig: &signer, cfg_default_n_sigs: u64, m_seed_authorities: &vector<address>) {
    assert!(cfg_default_n_sigs > 0, Errors::invalid_argument(ENO_SIGNERS));

    let multisig_address = Signer::address_of(sig);
    // User footgun. The Signer of this account is bricked, and as such the signer can no longer be an authority.
    assert!(!Vector::contains(m_seed_authorities, &multisig_address), Errors::invalid_argument(ESIGNER_CANT_BE_AUTHORITY));
    print(&10002);

    if (!exists<MultiSig>(multisig_address)) {
        move_to(sig, MultiSig {
        cfg_expire_epochs: DEFAULT_EPOCHS_EXPIRE,
        cfg_default_n_sigs,
        withdraw_capability: Option::none(),
        signers: *m_seed_authorities,
        counter: 0,
      });
    };

    if (!exists<Action<PropGovSigners>>(multisig_address)) {
      move_to(sig, Action<PropGovSigners> {
        can_withdraw: false,
        pending: Vector::empty(),
        approved: Vector::empty(),
        rejected: Vector::empty(),
      });
    }
  }

  fun is_init(multisig_address: address): bool {
    exists<MultiSig>(multisig_address) &&
    exists<Action<PropGovSigners>>(multisig_address)
  }


  /// An initial "sponsor" who is the signer of the initialization account calls this function.
  // This function creates the data structures, but also IMPORTANTLY it rotates the AuthKey of the account to a system-wide unusuable key (b"brick_all_your_base_are_belong_to_us").
  public fun init_type<ProposalData: key + store >(
    sig: &signer,
    can_withdraw: bool,
   ) acquires MultiSig {
    let multisig_address = Signer::address_of(sig);
    // TODO: there is no way of creating a new Action by multisig. The "signer" would need to be spoofed, which DiemAccount does only in specific and scary situations (e.g. vm_create_account_migration)

  
    
    assert!(is_init(multisig_address), Errors::invalid_argument(EGOV_NOT_INITIALIZED));

    assert!(!exists<Action<ProposalData>>(multisig_address), Errors::invalid_argument(EACTION_ALREADY_EXISTS));
    // make sure the signer's address is not in the list of authorities. 
    // This account's signer will now be useless.
    print(&10001);
    


    // maybe the withdraw cap was never extracted in previous set up.
    // but we won't extract it if none of the Actions require it.
    if (can_withdraw) {
      maybe_extract_withdraw_cap(sig);
    };

    move_to(sig, Action<ProposalData> {
        can_withdraw,
        pending: Vector::empty(),
        approved: Vector::empty(),
        rejected: Vector::empty(),
      });
  }



  fun maybe_extract_withdraw_cap(sig: &signer) acquires MultiSig {
    let multisig_address = Signer::address_of(sig);
    assert!(exists<MultiSig>(multisig_address), Errors::invalid_argument(ENOT_AUTHORIZED));

    let ms = borrow_global_mut<MultiSig>(multisig_address);
    if (Option::is_some(&ms.withdraw_capability)) {
      return
    } else {
      let cap = DiemAccount::extract_withdraw_capability(sig);
      Option::fill(&mut ms.withdraw_capability, cap);
    }
  }
  
  public fun maybe_restore_withdraw_cap(multisig_addr: address, w: Option<WithdrawCapability>) acquires MultiSig {
    assert!(exists<MultiSig>(multisig_addr), Errors::invalid_argument(ENOT_AUTHORIZED));
    if (Option::is_some(&w)) {
      let ms = borrow_global_mut<MultiSig>(multisig_addr);
      let cap = Option::extract(&mut w);
      Option::fill(&mut ms.withdraw_capability, cap);
    };
    Option::destroy_none(w);
    
  }

  /// Once the "sponsor" which is setting up the multisig has created all the multisig types (payment, generic, gov), they need to brick this account so that the signer for this address is rendered useless, and it is a true multisig.
  public fun finalize_and_brick(sig: &signer) {
    DiemAccount::brick_this(sig, b"yes I know what I'm doing");
    assert!(is_finalized(Signer::address_of(sig)), Errors::invalid_state(ENOT_FINALIZED_NOT_BRICK));
  }

  public fun is_finalized(addr: address): bool {
    DiemAccount::is_a_brick(addr)
  }


  // Propose an Action 
  // Transactions should be easy, and have one obvious way to do it. There should be no other method for voting for a tx.
  // this function will catch a duplicate, and vote in its favor.
  // This causes a user interface issue, users need to know that you cannot have two open proposals for the same transaction.
  // It's optional to state how many epochs from today the transaction should expire. If the transaction is not approved by then, it will be rejected.
  // The default will be 14 days.
  // Only the first proposer can set the expiration time. It will be ignored when a duplicate is caught.


  public fun propose<ProposalData: key + store + copy + drop>(sig: &signer, multisig_address: address, proposal_data: ProposalData):(bool, Option<WithdrawCapability>) acquires MultiSig, Action {
    print(&20001);
    assert_authorized(sig, multisig_address);

    let ms = borrow_global_mut<MultiSig>(multisig_address);
    let action = borrow_global_mut<Action<ProposalData>>(multisig_address);
    let n = *&ms.cfg_default_n_sigs;

    // check if we have this proposal already
    let (found, _) = find_index_of_proposal<ProposalData>(action, &proposal_data);

    let approved = if (found) {
      print(&20002);

      let prop = get_proposal(action, &proposal_data);
      vote(prop, Signer::address_of(sig), n)
    } else {
      print(&20003);
      Vector::push_back(&mut action.pending, Proposal<ProposalData> {
        id: ms.counter,
        proposal_data: proposal_data,
        votes: Vector::singleton(Signer::address_of(sig)),
        approved: false,
        expiration_epoch: DiemConfig::get_current_epoch() + ms.cfg_expire_epochs,
      });
      ms.counter = ms.counter + 1;
      false
    };

    print(&20004);
    // let w = borrow_global_mut<Withdraw>(multisig_address);

    if (approved &&
      Option::is_some(&ms.withdraw_capability) &&
      action.can_withdraw
    ) {
      print(&20005);
        let cap = Option::extract(&mut ms.withdraw_capability);
        print(&20006);

        return (approved, Option::some(cap))
    };
    (approved, Option::none())
  }


  // votes on a proposal, returns true if it passed
  fun vote<ProposalData: key + store + drop>(prop: &mut Proposal<ProposalData>, sender_addr: address, n: u64): bool {
    print(&30001);
    if (!Vector::contains(&prop.votes, &sender_addr)) {
      Vector::push_back(&mut prop.votes, sender_addr);
      print(&30002);

    };
    tally(prop, n)
  }

  fun tally<ProposalData: key + store + drop>(prop: &mut Proposal<ProposalData>, n: u64): bool {
    print(&40001);

    print(&prop.votes);

    if (Vector::length(&prop.votes) >= n) {
      prop.approved = true;
      print(&40002);

      return true
    };

    false
  }


  fun find_index_of_proposal<ProposalData: store + key>(a: &mut Action<ProposalData>, proposal_data: &ProposalData): (bool, u64) {

    // find and update existing proposal, or create a new one and add to "pending"
    let len = Vector::length(&a.pending);

    if (len > 0) {
      let i = 0;
      while (i < len) {
        // let prop = Vector::borrow_mut(&mut gov_prop.pending, i);
        let prop = Vector::borrow(&a.pending, i);
        if (
          &prop.proposal_data == proposal_data
        ) {
          return (true, i)
        };
        i = i + 1;
      };
    };

    (false, 0)
  }

  // TODO: Expand params
  fun get_proposal<ProposalData: store + key>(a: &mut Action<ProposalData>, handler: &ProposalData): &mut Proposal<ProposalData> {
    let (found, idx) = find_index_of_proposal<ProposalData>(a, handler);
    assert!(found, Errors::invalid_argument(EPENDING_EMPTY));
    Vector::borrow_mut(&mut a.pending, idx)
  }

  public fun is_authority(multisig_addr: address, addr: address): bool acquires MultiSig {
    let m = borrow_global<MultiSig>(multisig_addr);
    Vector::contains(&m.signers, &addr)
  }

  ////////  GOVERNANCE  ////////
  // Governance of the multisig happens through an instance of Action<PropGovSigners>. This action has no special privileges, and is just a normal proposal type.
  // The entry point and handler for governance exists on this contract for simplicity. However, there's no reason it couldn't be called from an external contract.


  /// Tis is a ProposalData type for governance. This Proposal adds or removes a list of addresses as authorities. The handlers are located in this contract.
  struct PropGovSigners has key, store, copy, drop {
    add_remove: bool, // true = add, false = remove
    addresses: vector<address>,
    n_of_m: Option<u64>, // Optionally change the n of m threshold. To only change the n_of_m threshold, an empty list of addresses is required.
  }


  public fun propose_governance(sig: &signer, multisig_address: address, addresses: vector<address>, add_remove: bool, n_of_m: Option<u64>)acquires MultiSig, Action {
    assert_authorized(sig, multisig_address); // Duplicated with propose(), belt and suspenders
    let prop = PropGovSigners {
      addresses,
      add_remove,
      n_of_m,
    };

    let (passed, withdraw_opt) = propose<PropGovSigners>(sig, multisig_address, copy prop);


    if (passed) {
      print(&80001);
      let ms = borrow_global_mut<MultiSig>(multisig_address);
       maybe_update_authorities(ms, prop.add_remove, *&prop.addresses);
       maybe_update_threshold(ms, &prop.n_of_m);
    };

    maybe_restore_withdraw_cap(multisig_address, withdraw_opt);
  }

fun maybe_update_authorities(ms: &mut MultiSig, add_remove: bool, addresses: vector<address>) {

      if (Vector::is_empty(&addresses)) {
        // The address field may be empty if the multisif is only changing the threshold
        return
      };

      if (add_remove) {
        Vector::append(&mut ms.signers, addresses);
      } else {

        // remove the signers
        let i = 0;
        while (i < Vector::length(&addresses)) {
          let addr = Vector::borrow(&addresses, i);
          let (found, idx) = Vector::index_of(&ms.signers, addr);
          if (found) {
            Vector::swap_remove(&mut ms.signers, idx);
          };
          i = i + 1;
        };
      };
  }

  fun maybe_update_threshold(ms: &mut MultiSig, n_of_m_opt: &Option<u64>) {
    if (Option::is_some(n_of_m_opt)) {
      ms.cfg_default_n_sigs = *Option::borrow(n_of_m_opt);
    };
  }

  //////// GETTERS ////////

  public fun get_authorities(multisig_address: address): vector<address> acquires MultiSig {
    let m = borrow_global<MultiSig>(multisig_address);
    *&m.signers
  }

  public fun get_n_sigs(multisig_address: address): u64 acquires MultiSig {
    let m = borrow_global<MultiSig>(multisig_address);
    *&m.cfg_default_n_sigs
  }


}
}