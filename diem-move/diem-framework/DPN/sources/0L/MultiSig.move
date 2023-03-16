///////////////////////////////////////////////////////////////////////////
// 0L Module
// MultiSig
// A payment tool for transfers which require n-of-m approvals
///////////////////////////////////////////////////////////////////////////


// The main design goals of this multisig implementation are:
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
  use Std::Option::Option;
  use Std::Vector;
  use Std::Signer;
  use Std::Errors;
  use DiemFramework::DiemAccount;
  use DiemFramework::DiemConfig;

  /// The owner of this account can't be an authority, since it will subsequently be bricked. The signer of this account is no longer useful. The account is now controlled by the MultiSig logic. 
  const ESIGNER_CANT_BE_AUTHORITY: u64 = 440001;

  /// Signer not authorized to approve a transaction.
  const ENOT_AUTHORIZED: u64 = 440002;

  /// There are no pending transactions to search
  const EPENDING_EMPTY: u64 = 440003;


  /// A MultiSig account is an account which requires multiple votes from Authorities to send a transaction.
  struct MultiSig has key {
    signers: vector<address>,
    n: u64,
    m: u64,
    pending: vector<ProposedTransaction>,
    approved: vector<ProposedTransaction>,
    rejected:  vector<ProposedTransaction>,
    counter: u64, // equals the most recent transaction id
  }


  /// This is the data structure which tracks the authorities and the votes for a given transaction.

  struct ProposedTransaction has key, store {
    id: u64,
    // The transaction to be executed
    destination: address,
    // amount
    amount: u64,
    // The votes received
    votes: vector<address>,
    // The expiration time for the transaction
    expiration_epoch: u64,
  }

  struct GovSigner {
    new_signers: vector<address>,
    votes: vector<address>,
    approved: bool,
  }

  struct GovThreshold {
    n: u64,
    m: u64,
    votes: vector<address>,
    approved: bool,
  }

  struct Governance {
    // propose new signer
    propose_signers: Option<GovSigner>,
    // remove signer
    remove_signers: Option<GovSigner>,
    // change threshold
    change_threshold: Option<GovThreshold>,
  }


  /// An initial "sponsor" who is the signer of the initialization account calls this function.
  // This function creates the data structures, but also IMPORTANTLY it rotates the AuthKey of the account to a system-wide unusuable key (b"brick_all_your_base_are_belong_to_us").
  public fun init_and_brick(
    sig: &signer,
    m_seed_authorities: vector<address>,
    n_required_sigs: u64
  ) {
    // make sure the signer's address is not in the list of authorities. 
    // This account's signer will now be useless.

    let sender_addr = Signer::address_of(sig);
    assert!(!Vector::contains(&m_seed_authorities, &sender_addr), Errors::invalid_argument(ESIGNER_CANT_BE_AUTHORITY));

    move_to(sig, MultiSig {
      signers: copy m_seed_authorities,
      n: n_required_sigs,
      m: Vector::length(&m_seed_authorities),
      pending: Vector::empty(),
      approved: Vector::empty(),
      rejected: Vector::empty(),
      counter: 0,
    });

    DiemAccount::brick_this(sig, b"yes I know what I'm doing");
  }


  // Propose a transaction 
  // Transactions should be easy, and have one obvious way to do it. There should be no other method for voting for a tx.
  // this function will catch a duplicate, and vote in its favor.
  // This causes a user interface issue, users need to know that you cannot have two open proposals for the same transaction.
  // It's optional to state how many epochs from today the transaction should expire. If the transaction is not approved by then, it will be rejected.
  // The default will be 14 days.
  // Only the first proposer can set the expiration time. It will be ignored when a duplicate is caught.
  public fun propose_tx(sig: &signer, multisig_address: address, recipient: address, amount: u64, opt_epochs_expire: u64) acquires MultiSig {
    // check if the sender is an authority
    assert!(is_authority(multisig_address, Signer::address_of(sig)), Errors::invalid_argument(ENOT_AUTHORIZED));

    // check if there is a pending transaction for this recipient and amount
    let (found, idx) = find_pending_idx_by_param(multisig_address, recipient, amount);
    // if not found, create a new one
    let m = borrow_global_mut<MultiSig>(multisig_address);

    if (found) {
      // if found, vote for it
      let prop = Vector::borrow_mut(&mut m.pending, idx);
      vote_for_tx(sig, prop);
    } else {
      
      m.counter = m.counter + 1;
      let id = m.counter;

      let expires = if (opt_epochs_expire > 0) {
        DiemConfig::get_current_epoch() + opt_epochs_expire
      } else {
        DiemConfig::get_current_epoch() + 14
      };

      let p = ProposedTransaction {
        id,
        destination: recipient,
        amount: amount,
        votes: Vector::empty(),
        expiration_epoch: expires,
      };
      
      vote_for_tx(sig, &mut p);

      Vector::push_back(&mut m.pending, p);
    }

  }

  // this is a private internal function. There should only be one obvious way to vote for a transaction.
  fun vote_for_tx(sig: &signer, prop: &mut ProposedTransaction) {
    if (Vector::contains(&prop.votes, &Signer::address_of(sig))) {
      return
    };
    Vector::push_back(&mut prop.votes, Signer::address_of(sig));
  }

  public fun is_authority(multisig_addr: address, addr: address): bool acquires MultiSig {
    let m = borrow_global<MultiSig>(multisig_addr);
    Vector::contains(&m.signers, &addr)
  }

  public fun find_pending_idx_by_param(multisig_addr: address, recipient: address, amount: u64): (bool, u64) acquires MultiSig {
    let m = borrow_global<MultiSig>(multisig_addr);
    if (Vector::is_empty(&m.pending)) {
      return (false, 0)
    };

    let i = 0;
    while (i < Vector::length(&m.pending)) {
      let p = Vector::borrow(&m.pending, i);
      if (p.destination == recipient && p.amount == amount) {
        return (true, i)
      };
      i = i + 1;
    };

    (false, 0)
  }

}
}