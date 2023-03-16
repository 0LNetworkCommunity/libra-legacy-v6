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
  use Std::Vector;
  use Std::Signer;
  use Std::Errors;
  use DiemFramework::DiemAccount;
  use DiemFramework::DiemConfig;
  use DiemFramework::Debug::print;
  use DiemFramework::GAS::GAS;
  use DiemFramework::VectorHelper;

  /// The owner of this account can't be an authority, since it will subsequently be bricked. The signer of this account is no longer useful. The account is now controlled by the MultiSig logic. 
  const ESIGNER_CANT_BE_AUTHORITY: u64 = 440001;

  /// Signer not authorized to approve a transaction.
  const ENOT_AUTHORIZED: u64 = 440002;

  /// There are no pending transactions to search
  const EPENDING_EMPTY: u64 = 440003;

  /// Not enough signers configured
  const ENO_SIGNERS: u64 = 440004;

  /// A MultiSig account is an account which requires multiple votes from Authorities to send a transaction.
  struct MultiSig has key {
    withdraw_capability: DiemAccount::WithdrawCapability,
    signers: vector<address>,
    n: u64,
    pending: vector<ProposedTransaction>,
    approved: vector<ProposedTransaction>,
    rejected:  vector<ProposedTransaction>,
    counter: u64, // the monotonically increasing id of proposal. Also equal to length of proposals. And the ID of the NEXT proposal to be submitted.
  }


  /// This is the data structure which tracks the authorities and the votes for a given transaction.

  struct ProposedTransaction has key, store {
    id: u64,
    // The transaction to be executed
    destination: address,
    // amount
    amount: u64,
    //
    note: vector<u8>,
    // The votes received
    votes: vector<address>,
    // The expiration time for the transaction
    expiration_epoch: u64,
  }

  /// Any governance changes are held in a separate structure.
  struct Governance has key {
    // n-of-m for changes to governance. Defaults to same as the multisig.
    cfg_n_sigs: u64,
    // expiration
    cfg_expire_epochs: u64,
    // propose new signer
    add: vector<PropSigners>,
    // remove signer
    remove: vector<PropSigners>,
    // change threshold
    threshold: vector<PropThreshold>,
    // check if the governance votes need to be reset
    reset_gov_votes: vector<address>,
  }

  struct PropSigners has key, store, drop {
    new_addrs: vector<address>,
    votes: vector<address>,
    approved: bool,
    expiration_epoch: u64,
  }

  struct PropThreshold has key, store, drop {
    n: u64,
    votes: vector<address>,
    approved: bool,
    expiration_epoch: u64,
  }




  /// An initial "sponsor" who is the signer of the initialization account calls this function.
  // This function creates the data structures, but also IMPORTANTLY it rotates the AuthKey of the account to a system-wide unusuable key (b"brick_all_your_base_are_belong_to_us").
  public fun init_and_brick(
    sig: &signer,
    m_seed_authorities: vector<address>,
    n_required_sigs: u64
  ) {
    assert!(n_required_sigs > 0, Errors::invalid_argument(ENO_SIGNERS));
    // make sure the signer's address is not in the list of authorities. 
    // This account's signer will now be useless.
    print(&10001);
    let sender_addr = Signer::address_of(sig);
    assert!(!Vector::contains(&m_seed_authorities, &sender_addr), Errors::invalid_argument(ESIGNER_CANT_BE_AUTHORITY));
    print(&10002);
    move_to(sig, MultiSig {
      withdraw_capability: DiemAccount::extract_withdraw_capability(sig),
      signers: copy m_seed_authorities,
      n: n_required_sigs,
      // m: Vector::length(&m_seed_authorities),
      pending: Vector::empty(),
      approved: Vector::empty(),
      rejected: Vector::empty(),
      counter: 0,
    });

    init_gov(sig, n_required_sigs);

    print(&10003);
    DiemAccount::brick_this(sig, b"yes I know what I'm doing");
    print(&10004);
  }

  fun init_gov(sig: &signer, cfg_n_sigs: u64) {
    // TODO: make this configurable
    let cfg_expire_epochs = 14;

    move_to(sig, Governance {
      cfg_n_sigs,
      cfg_expire_epochs,
      add: Vector::empty(),
      remove: Vector::empty(),
      threshold: Vector::empty(),
      reset_gov_votes: Vector::empty(),
    });
  }

  fun maybe_reset_gov(gov: &mut Governance) {
    let epoch = DiemConfig::get_current_epoch();

    let i = 0;
    while (i < Vector::length(&gov.add)) {
      let a = Vector::borrow(&gov.add, i);
      if (a.expiration_epoch < epoch) {
        Vector::remove(&mut gov.add, i);
      };
      i = i + 1;
    };

    let i = 0;
    while (i < Vector::length(&gov.remove)) {
      let a = Vector::borrow(&gov.remove, i);
      if (a.expiration_epoch < epoch) {
        Vector::remove(&mut gov.remove, i);
      };
      i = i + 1;
    };

    let i = 0;
    while (i < Vector::length(&gov.threshold)) {
      let a = Vector::borrow(&gov.threshold, i);
      if (a.expiration_epoch < epoch) {
        Vector::remove(&mut gov.threshold, i);
      };
      i = i + 1;
    };

  }

  // Propose a transaction 
  // Transactions should be easy, and have one obvious way to do it. There should be no other method for voting for a tx.
  // this function will catch a duplicate, and vote in its favor.
  // This causes a user interface issue, users need to know that you cannot have two open proposals for the same transaction.
  // It's optional to state how many epochs from today the transaction should expire. If the transaction is not approved by then, it will be rejected.
  // The default will be 14 days.
  // Only the first proposer can set the expiration time. It will be ignored when a duplicate is caught.
  public fun propose_tx(sig: &signer, multisig_address: address, recipient: address, amount: u64, opt_epochs_expire: u64, note: vector<u8>) acquires MultiSig, Governance {
    print(&20001);

    // check if the sender is an authority
    assert!(is_authority(multisig_address, Signer::address_of(sig)), Errors::invalid_argument(ENOT_AUTHORIZED));

    // check if there is a pending transaction for this recipient and amount
    let (found, idx) = find_pending_idx_by_param(multisig_address, recipient, amount);
    // if not found, create a new one
    let ms = borrow_global_mut<MultiSig>(multisig_address);

    let idx = if (found) {
      // If expired reject it
      if (maybe_expire(ms, idx)) {
        return
      };
      // if found, vote for it
      let prop = Vector::borrow_mut(&mut ms.pending, idx);
      vote_for_tx(sig, prop);
      // return the index of the proposal
      idx
    } else {
      
      // increment this at the end, so the first id is 0.
      let id = ms.counter;

      let expires = if (opt_epochs_expire > 0) {
        DiemConfig::get_current_epoch() + opt_epochs_expire
      } else {
        DiemConfig::get_current_epoch() + 14
      };

      let prop = ProposedTransaction {
        id,
        destination: recipient,
        amount: amount,
        note,
        votes: Vector::empty(),
        expiration_epoch: expires,
      };

      vote_for_tx(sig, &mut prop);
      
      Vector::push_back(&mut ms.pending, prop);
      // the len of proposals, and the next id.
      ms.counter = ms.counter + 1;
      // return the index of the proposal
      id
    };

    maybe_approve(ms, idx);

    // TODO: Also do a lazy cleaning of expired governence proposals.
    let g = borrow_global_mut<Governance>(multisig_address);
    maybe_reset_gov(g);
  }

  // this is a private internal function. There should only be one obvious way to vote for a transaction.
  fun vote_for_tx(sig: &signer, prop: &mut ProposedTransaction) {
    print(&30001);

    if (Vector::contains(&prop.votes, &Signer::address_of(sig))) {
      return
    };
    Vector::push_back(&mut prop.votes, Signer::address_of(sig));
  }

  fun maybe_approve(ms: &mut MultiSig, prop_id: u64) {
    print(&40001);
    let prop = Vector::borrow_mut(&mut ms.pending, prop_id);
    if (Vector::length(&prop.votes) >= ms.n) {
      print(&40002);
      // approve it and send payment
      // release payment needs the withdrawal capability token.
      release_payment(ms, prop_id);

      let p = Vector::swap_remove(&mut ms.pending, prop_id);
      Vector::push_back(&mut ms.approved, p);
    }
  }

  // Sending payment. Ordinarily an account can only transfer funds if the signer of that account is sending the transaction.
  // In Libra we have "withdrawal capability" tokens, which allow the holder of that token to authorize transactions. At the initilization of the multisig, the "withdrawal capability" was passed into the MultiSig datastructure.
  // Withdrawal capabilities are "hot potato" data. Meaning, they cannot ever be dropped and need to be moved to a final resting place, or returned to the struct that was housing it. That is what happens at the end of release_payment, it is only borrowed, and never leaves the data structure.
  fun release_payment(ms: &mut MultiSig, prop_id: u64) {
    let p = Vector::borrow(&mut ms.pending, prop_id);
    DiemAccount::pay_from<GAS>(
      &ms.withdraw_capability,
      p.destination,
      p.amount,
      *&p.note,
      b""
    );
  }

  fun maybe_expire(ms: &mut MultiSig, prop_id: u64): bool {
    let expires = *&Vector::borrow(&mut ms.pending, prop_id).expiration_epoch;
    if (DiemConfig::get_current_epoch() > expires) {
      // reject it
      let p = Vector::swap_remove(&mut ms.pending, prop_id);
      Vector::push_back(&mut ms.rejected, p);
      return true
    };
    false
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

  //////// GOVERNANCE ////////

  // propose new signer
  // TODO: Governance proposals have a problem with deadlines.
  // if a deadline goes too far into the future, there's no way to replace the proposal.
  public fun propose_add_authorities(sig: &signer, multisig_address: address, new_addresses: vector<address>) acquires MultiSig, Governance {

    assert!(exists<MultiSig>(multisig_address), Errors::invalid_argument(ENOT_AUTHORIZED));
    assert!(exists<Governance>(multisig_address), Errors::invalid_argument(ENOT_AUTHORIZED));
    let sender_addr = Signer::address_of(sig);
    // check if the sender is an authority
    assert!(is_authority(multisig_address, sender_addr), Errors::invalid_argument(ENOT_AUTHORIZED));

    let g = borrow_global_mut<Governance>(multisig_address);

    // reset everything beforehand.
    maybe_reset_gov(g);
    
    let len = Vector::length(&g.add);
    if (len > 0) {
      // check if there is already a proposal
      let i = 0;
      while (i < Vector::length(&g.add)) {
        let p = Vector::borrow_mut(&mut g.add, i);
        if (
          VectorHelper::compare(&p.new_addrs, &new_addresses) &&
          p.approved == false
        ) {
          Vector::push_back(&mut p.votes, sender_addr);

          if (Vector::length(&p.votes) >= g.cfg_n_sigs) {
            p.approved = true;
            // finally append the new signers
            let ms = borrow_global_mut<MultiSig>(multisig_address);
            Vector::append(&mut ms.signers, *&p.new_addrs);
          };

        };
        i = i + 1;
      };
    } else {
      let prop = PropSigners {
          new_addrs: new_addresses,
          votes: Vector::singleton(sender_addr),
          approved: false,
          expiration_epoch: DiemConfig::get_current_epoch() + g.cfg_expire_epochs,
        };
        g.add = Vector::singleton(prop);
      };
    }

    // remove a signer
    // TODO lots of code duplication here. Refactor.
    public fun propose_remove_authorities(sig: &signer, multisig_address: address, new_addresses: vector<address>) acquires MultiSig, Governance {

    assert!(exists<MultiSig>(multisig_address), Errors::invalid_argument(ENOT_AUTHORIZED));
    assert!(exists<Governance>(multisig_address), Errors::invalid_argument(ENOT_AUTHORIZED));
    let sender_addr = Signer::address_of(sig);
    // check if the sender is an authority
    assert!(is_authority(multisig_address, sender_addr), Errors::invalid_argument(ENOT_AUTHORIZED));

    let g = borrow_global_mut<Governance>(multisig_address);

    // reset everything beforehand.
    maybe_reset_gov(g);
    
    let len = Vector::length(&g.remove);
    if (len > 0) {
      // check if there is already a proposal
      let i = 0;
      while (i < Vector::length(&g.remove)) {
        let p = Vector::borrow_mut(&mut g.remove, i);
        if (
          VectorHelper::compare(&p.new_addrs, &new_addresses) &&
          p.approved == false
        ) {
          Vector::push_back(&mut p.votes, sender_addr);

          if (Vector::length(&p.votes) >= g.cfg_n_sigs) {
            p.approved = true;
            // finally remove the signers
            let ms = borrow_global_mut<MultiSig>(multisig_address);
            let k = 0;
            while (k < Vector::length(&p.new_addrs)) {
              let addr = Vector::borrow(&p.new_addrs, k);
              let (found, idx) = Vector::index_of(&ms.signers, addr);
              if (found) {
                Vector::remove(&mut ms.signers, idx);
              };
              
              k = k + 1;
            }
          };
        };
        i = i + 1;
      };
    } else {
      let prop = PropSigners {
          new_addrs: new_addresses,
          votes: Vector::singleton(sender_addr),
          approved: false,
          expiration_epoch: DiemConfig::get_current_epoch() + g.cfg_expire_epochs,
        };
        g.remove = Vector::singleton(prop);
      };
    }

  // change threshold
  // TODO

}
}