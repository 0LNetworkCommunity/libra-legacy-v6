address DiemFramework {

/// Donor directed wallets is a service of the chain.
/// Any address can voluntarily turn their account into a donor directed account.

/// By creating a DonorDirected wallet you are providing certain restrictions and guarantees to the users that interact with this wallet.

/// 1. The wallet's contents is propoperty of the owner. The owner is free to issue transactions which change the state of the wallet, including transferring funds. There are however time, and veto policies.
/// 2. All transfers out of the account are timed. Meaning, they will execute automatically after a set period of time passes. The VM address triggers these events at each epoch boundary. The purpose of the delayed transfers is that the transaction can be paused for analysis, and eventually rejected by the donors of the wallet.
/// 3. Every pending transaction can be "vetoed". This adds one day/epoch to the transaction, extending the delay. If a sufficient number of Donors vote on the Veto, then the transaction will be rejected.

/// 4. After three consecutive transaction rejections, the account will become frozen. The funds remain in the account but no operations are available until the Donors, un-freeze the account.

/// 5. Voting for all purposes are done on a pro-rata basis according to the amounts donated. Voting using ParticipationVote method, which in short, biases the threshold based on the turnout of the vote. TL;DR a low turnout of 12.5% would require 100% of the voters to veto, and lower thresholds for higher turnouts until 51%.

/// 6. The donors can vote to liquidate a frozen DonorDirected account. The result will depend on the configuration of the DonorDirected account from when it was initialized: the funds by default return to the end user who was the donor. 

/// 7. Third party contracts can wrap the Donor Directed wallet. The outcomes of the votes can be returned to a handler in a third party contract For example, liquidiation of a frozen account is programmable: a handler can be coded to determine the outcome of the donor directed wallet. See in CommunityWallets the funds return to the InfrastructureEscrow side-account of the user.

module DonorDirected {
    use DiemFramework::CoreAddresses;
    use Std::Vector;
    use Std::Signer;
    use Std::Errors;
    use Std::GUID;
    use DiemFramework::DiemConfig;
    use Std::Option::{Self,Option};
    use DiemFramework::GAS::GAS;
    use DiemFramework::MultiSig;
    use DiemFramework::DiemAccount::{Self, WithdrawCapability};
    use DiemFramework::DonorDirectedGovernance;

    /// Not initialized as a donor directed account.
    const ENOT_INIT_DONOR_DIRECTED: u64 = 231001;
    /// User is not a donor and cannot vote on this account
    const ENOT_AUTHORIZED_TO_VOTE: u64 = 231010;

    // root registry for the donor directed accounts
    struct Registry has key {
      list: vector<address>
    }

    // Timed transfer submission
    struct DonorDirected has key {
      proposed: vector<TimedTransfer>,
      approved: vector<TimedTransfer>,
      rejected: vector<TimedTransfer>,
      guid_capability: GUID::CreateCapability,
    }

    struct TimedTransfer has drop, key, store {
      uid: GUID::GUID,
      expire_epoch: u64,
      payee: address,
      value: u64,
      description: vector<u8>,
      // veto: Veto,
    }


    /// each multisig auth will propose a transfer
    /// once it gets consensus a TimedTransfer is created
    /// the timed transfer will exevute unless the Donors veto the transaction.
    struct DonorDirectedProp has copy, drop, key, store {
      payee: address,
      value: u64,
      description: vector<u8>,
    }

    struct Freeze has key {
      is_frozen: bool,
      consecutive_rejections: u64,
      unfreeze_votes: vector<address>,
    }

    //////// INIT REGISRTY OF DONOR DIRECTED ACCOUNTS  ////////

    // Donor Directed Accounts are a root security service. So the root account needs to keep a registry of all donor directed accounts, using this service.

    // Utility used at genesis (and on upgrade) to initialize the system state.
    public fun init_root_registry(vm: &signer) {
      CoreAddresses::assert_diem_root(vm);
      if (!is_root_init()) {
        move_to<Registry>(vm, Registry {
          list: Vector::empty<address>()
        });
      };
    }

    public fun is_root_init():bool {
      exists<Registry>(@VMReserved)
    }


    //////// DONOR DIRECTED INITIALIZATION ////////
    // There are three steps in initializing an account. These steps can be combined in a single transaction, or done in separate transactions. The "bricking" of the sponsor key should be done in a separate transaction, in case there are any errors in the initialization.

    // 1. The basic structs for a donor directed account need to be initialized, and the account needs to be added to the Registry at root.

    // 2. A MultiSig action structs need to be initialized.

    // 3. Once the MultiSig is initialized, the account needs to be bricked, before the MultiSig can be used.

    public fun set_donor_directed(sig: &signer) acquires Registry {
      if (!exists<Registry>(@VMReserved)) return;

      let addr = Signer::address_of(sig);
      let list = get_root_registry();
      if (!Vector::contains<address>(&list, &addr)) {
        let s = borrow_global_mut<Registry>(@VMReserved);
        Vector::push_back(&mut s.list, addr);
      };

      move_to<Freeze>(
        sig, 
        Freeze {
          is_frozen: false,
          consecutive_rejections: 0,
          unfreeze_votes: Vector::empty<address>()
        }
      );

      let guid_capability = GUID::gen_create_capability(sig);
      move_to(sig, DonorDirected {
          proposed: Vector::empty(),
          approved: Vector::empty(),
          rejected: Vector::empty(),
          guid_capability,
        })

    }


    /// Like any MultiSig instance, a sponsor which is the original owner of the account, needs to initialize the account.
    /// The account must be "bricked" by the owner before MultiSig actions can be taken.
    /// Note, as with any multisig, the new_authorities cannot include the sponsor, since that account will no longer be able to sign transactions.
    public fun make_multisig(sponsor: &signer, cfg_default_n_sigs: u64, new_authorities: vector<address>) {
      MultiSig::init_gov(sponsor, cfg_default_n_sigs, &new_authorities);
      MultiSig::init_type<TimedTransfer>(sponsor, true); // "true": We make this multisig instance hold the WithdrawCapability. Even though we don't need it for any DiemAccount pay functions, we can use it to make sure the entire pipeline of private functions scheduling a payment are authorized. Belt and suspenders.
      MultiSig::finalize_and_brick(sponsor);
    }

    /// the sponsor must finalize the initialization, this is a separate step so that the user can optionally check everything is in order before bricking the account key.
    public(script) fun finalize_init(sponsor: signer) {
      let multisig_address = Signer::address_of(&sponsor);
      assert!(is_donor_directed(multisig_address), Errors::invalid_state(ENOT_INIT_DONOR_DIRECTED));
      MultiSig::finalize_and_brick(&sponsor);
    }

    /// Check if the account is a donor directed account, and initialized properly.
    public fun is_donor_directed(multisig_address: address):bool {
      MultiSig::is_init(multisig_address) && 
      MultiSig::has_action<DonorDirectedProp>(multisig_address) &&
      exists<Freeze>(multisig_address) &&
      exists<DonorDirected>(multisig_address)
    }

    // Getter for retrieving the list of DonorDirected wallets.
    public fun get_root_registry(): vector<address> acquires Registry{
      if (exists<Registry>(@VMReserved)) {
        let s = borrow_global<Registry>(@VMReserved);
        return *&s.list
      } else {
        return Vector::empty<address>()
      }
    }

    ///////// MULTISIG ACTIONS TO SCHEDULE A TIMED TRANSFER /////////
    /// As in any MultiSig instance, the transaction which proposes the action (the scheduled transfer) must be signed by an authority on the MultiSig.
    /// The same function is the handler for the approval case of the MultiSig action.
    /// Since Donor Directed accounts are involved with sensitive assets, we have moved the WithdrawCapability to the MultiSig instance. Even though we don't need it for any DiemAccount functions for paying, we use it to ensure no private functions related to assets can be called. Belt and suspenders.

    /// Returns the GUID of the transfer.
    public fun new_timed_transfer_multisig(
      sender: &signer, multisig_address: address, payee: address, value: u64, description: vector<u8>
    ): Option<GUID::ID> acquires DonorDirected {
      let p = DonorDirectedProp {
        payee,
        value,
        description: copy description,
      };

      let (passed, withdraw_cap_opt) = MultiSig::propose<DonorDirectedProp>(sender, multisig_address, p, Option::none());

      let id_opt = if (passed && Option::is_some(&withdraw_cap_opt)) {
        let id = schedule(Option::borrow(&withdraw_cap_opt), payee, value, description);
        Option::some(id)
      } else {
        Option::none()
      };

      MultiSig::maybe_restore_withdraw_cap(sender, multisig_address, withdraw_cap_opt);

      id_opt
      

    }

    /// Private function which handles the logic of adding a new timed transfer
    /// DANGER upstream functions need to check the sender is authorized.
    // TODO: perhaps require the WithdrawCapability

    // The DonorDirected wallet Signer can propose a timed transaction.
    // the timed transaction defaults to occurring in the 3rd following epoch.
    // TODO: Increase this time?
    // the transaction will automatically occur at the epoch boundary, 
    // unless a veto vote by the validator set is successful.
    // at that point the transaction leves the proposed queue, and is added 
    // the rejected list.

    fun schedule(
      withdraw_capability: &WithdrawCapability, payee: address, value: u64, description: vector<u8>
    ): GUID::ID acquires DonorDirected {
      
      let multisig_address = DiemAccount::get_withdraw_cap_address(withdraw_capability);
      let transfers = borrow_global_mut<DonorDirected>(multisig_address);
      let uid = GUID::create_with_capability(multisig_address, &transfers.guid_capability);
      
      // add current epoch + 1
      let current_epoch = DiemConfig::get_current_epoch();

      let t = TimedTransfer {
        uid,
        expire_epoch: current_epoch + 2, // pays at the end of second (start of third epoch),
        payee: payee,
        value: value,
        description: description,
      };

      let id = GUID::id(&t.uid);
      Vector::push_back<TimedTransfer>(&mut transfers.proposed, t);
      return id
    }

  ///////// PROCESS PAYMENTS /////////
    public fun process_donor_directed_accounts(
      vm: &signer,
    ) acquires Registry, DonorDirected, Freeze {

      let list = get_root_registry();

      let i = 0;
      while (i < Vector::length(&list)) {
        let multisig_address = Vector::borrow(&list, i);
        if (exists<DonorDirected>(*multisig_address)) {
          let state = borrow_global_mut<DonorDirected>(*multisig_address);
          maybe_pay_if_deadline_today(vm, state);
        };
        i = i + 1;
      }
    }

    fun maybe_pay_if_deadline_today(vm: &signer, state: &mut DonorDirected) acquires Freeze {
      let epoch = DiemConfig::get_current_epoch();
      let i = 0;
      while (i < Vector::length(&state.proposed)) {

        let this_exp = *&Vector::borrow(&state.proposed, i).expire_epoch;
        if (this_exp == epoch) {
          let t = Vector::remove<TimedTransfer>(&mut state.proposed, i);

          let multisig_address = GUID::creator_address(&t.uid);
          DiemAccount::vm_make_payment_no_limit<GAS>(multisig_address, t.payee, t.value, *&t.description, b"", vm);

          // update the records
          Vector::push_back(&mut state.approved, t);

          // if theres a single transaction that gets approved, then the freeze consecutive rejection counter is reset
          reset_rejection_counter(vm, multisig_address)
        };

        i = i + 1;
      };
  
    }


  //////// GOVERNANCE HANDLERS ////////

  // Governance logic is defined in DonorDirectedGovernance.move
  // Below are functions to handle the cases for rejecting and freezing accounts based on governance outcomes.

  // A validator casts a vote to veto a proposed/pending transaction 
  // by a DonorDirected wallet.
  // The validator identifies the transaction by a unique id.
  // Tallies are computed on the fly, such that if a veto happens, 
  // the community which is faster than waiting for epoch boundaries.
  public fun veto_handler(
    sender: &signer,
    uid: &GUID::ID,
  ) acquires DonorDirected, Freeze {
    // let id_from_guid = GUID::create_id(multisig_address, uid);
    let veto_approved = DonorDirectedGovernance::veto_by_id(sender, uid);

    if (veto_approved) {
      // if the veto passes, freeze the account
      reject(uid);
      let multisig_address = GUID::id_creator_address(uid);
      maybe_freeze(multisig_address);
    } else {
      // per the DonorDirected policy we need to slow
      // down the payments further if there are rejections.

      // check that the expiration of the payment 
      // is the same as the end of the veto ballot
      // This is because the ballot expiration can be
      // extended based on the threshold of votes.

    }
  }

  // private function. Once vetoed, the transaction is 
  // removed from proposed list.
  fun reject(uid: &GUID::ID)  acquires DonorDirected, Freeze {
    let multisig_address = GUID::id_creator_address(uid);
    let c = borrow_global_mut<DonorDirected>(multisig_address);

    let len = Vector::length(&c.proposed);
    let i = 0;
    while (i < len) {
      let t = Vector::borrow<TimedTransfer>(&c.proposed, i);
      if (&GUID::id(&t.uid) == uid) {
        // remove from proposed list
        let t = Vector::remove<TimedTransfer>(&mut c.proposed, i);
        Vector::push_back(&mut c.rejected, t);
        // increment consecutive rejections counter
        let f = borrow_global_mut<Freeze>(multisig_address);
        f.consecutive_rejections = f.consecutive_rejections + 1;
        
      };

      i = i + 1;
    };
    
  }



  public fun reset_rejection_counter(vm: &signer, wallet: address) acquires Freeze {
    CoreAddresses::assert_diem_root(vm);
    borrow_global_mut<Freeze>(wallet).consecutive_rejections = 0;
  }



    // Private function to freeze a DonorDirected wallet
    // DonorDirected wallets get frozen if 3 consecutive attempts to transfer are rejected.
    fun maybe_freeze(wallet: address) acquires Freeze {
      if (borrow_global<Freeze>(wallet).consecutive_rejections > 2) {
        let f = borrow_global_mut<Freeze>(wallet);
        f.is_frozen = true;
      }
    }

    //////// GETTERS ////////
    public fun get_tx_args(t: TimedTransfer): (address, u64, vector<u8>, u64) {
      (t.payee, t.value, *&t.description, t.expire_epoch)
    }

    // public fun get_tx_epoch(uid: u64, multisig_address: address): u64 {
    //   let (opt, _) = find(uid, PROPOSED, multisig_address);
    //   if (Option::is_some<TimedTransfer>(&opt)) {
    //     let t = Option::borrow<TimedTransfer>(&opt);
    //     return *&t.expire_epoch
    //   };
    //   0
    // }
    
    // public fun transfer_is_proposed(uid: u64, multisig_address: address): bool {
    //   // let (opt, _) = find(uid, PROPOSED, multisig_address);
    //   // Option::is_some<TimedTransfer>(&opt)
    //   false
    // }

    // public fun transfer_is_rejected(uid: u64, multisig_address: address): bool  {
    //   // let (opt, _) = find(uid, REJECTED, multisig_address);
    //   // Option::is_some<TimedTransfer>(&opt)
    //   false
    // }



    // getter to check if wallet is frozen
    // used in DiemAccount before attempting a transfer.
    public fun is_frozen(addr: address): bool acquires Freeze{
      let f = borrow_global<Freeze>(addr);
      f.is_frozen
    }



}
}