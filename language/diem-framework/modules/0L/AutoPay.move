  ///////////////////////////////////////////////////////////////////////////
  // 0L Module
  // Auto Pay - 
  // File Prefix for errors: 0100
  ///////////////////////////////////////////////////////////////////////////

address 0x1 {
  /// # Summary
  /// This module enables automatic payments from accounts to community wallets at epoch boundaries.
  module AutoPay { // renamed to preventhalting from state corruption
    use 0x1::Vector;
    use 0x1::Option::{Self,Option};
    use 0x1::Signer;
    use 0x1::DiemAccount;
    use 0x1::GAS::GAS;
    use 0x1::FixedPoint32;
    use 0x1::CoreAddresses;
    use 0x1::DiemConfig;
    use 0x1::Errors;
    use 0x1::Wallet;
    use 0x1::Roles;
    // use 0x1::DiemTimestamp;

    /// Attempted to send funds to an account that does not exist
    /// Maximum value for the Payment type selection
    const MAX_TYPE: u8 = 3;

    // types of Payments
    /// send percent of balance at end of epoch payment type
    const PERCENT_OF_BALANCE: u8 = 0;
    /// send percent of the change in balance since the last tick payment type
    const PERCENT_OF_CHANGE: u8 = 1;
    /// send a certain amount each tick until end_epoch is reached payment type
    const FIXED_RECURRING: u8 = 2;
    /// send a certain amount once at the next tick payment type
    const FIXED_ONCE: u8 = 3;

    const MAX_NUMBER_OF_INSTRUCTIONS: u64 = 30;

    // Can't give more than 100.00%
    const MAX_PERCENTAGE: u64 = 10000;

    const EPAYEE_DOES_NOT_EXIST: u64 = 010017;
    /// The account does not have autopay enabled.
    const EAUTOPAY_NOT_ENABLED: u64 = 010018;
    /// Attempting to query a non-existent autpay ID
    const AUTOPAY_ID_DOES_NOT_EXIST: u64 = 010019;
    /// Invalid payment type given
    const INVALID_PAYMENT_TYPE: u64 = 010020;
    /// Attempt to add instruction when too many already exist
    const TOO_MANY_INSTRUCTIONS: u64 = 010021;
    /// Attempt to give more than 100.00% to one payee
    const INVALID_PERCENTAGE: u64 = 010022;
    /// Attempt to use a UID that is already taken 
    const UID_TAKEN: u64 = 010023;
    /// Attempt to make a payment to a non-community-wallet 
    const PAYEE_NOT_COMMUNITY_WALLET: u64 = 010024;

    // triggered once per epoch
    struct Tick has key {
      triggered: bool,
    }

    // switch for enabling account limits, can only be changed by libra root (requires a stdlib upgrade)
    // made obsolete by slow wallets
    struct AccountLimitsEnable has key {
      enabled: bool,
    }

    // TODO: This will be deprecated.
    // List of payments. Each account will own their own copy of this struct
    struct Data has key { // DEPRECATED. HERE ONLY FOR MIGRATION
      payments: vector<Payment>,
    }


    struct UserAutoPay has key {
      payments: vector<Payment>,
      prev_bal: u64, 
    }



    // One copy of this struct will be created. It will be stored in 0x0.
    // It keeps track of all accounts that have autopay enabled and updates the 
    // list as accounts change their Status structs

    struct AccountList has key {
      accounts: vector<address>,
      // current_epoch: u64, // todo: unused, delete?
    }

    // This is the structure of each Payment struct which represents one automatic
    // payment held by an account
    // Possible types:
    // 0: amt% of current balance until end epoch
    // 1: amt% of inflow until end_epoch 
    // 2: amt gas until end_epoch
    // 3: amt gas, one time payment
    struct Payment has drop, store {
      uid: u64,
      in_type: u8,
      payee: address,
      end_epoch: u64,  // end epoch is inclusive, ignored for type 3
      prev_bal: u64, // only used for type 1
      amt: u64, // percentage for types 0 & 1, absolute value for 2 & 3
    }

    ///////////////////////////////
    // Public functions only OxO //
    //////////////////////////////
    // Function code: 01
    public fun tick(vm: &signer): bool acquires Tick {
      Roles::assert_diem_root(vm);
      if (exists<Tick>(CoreAddresses::DIEM_ROOT_ADDRESS())) {
        // The tick is triggered at the beginning of each epoch
        let tick_state = borrow_global_mut<Tick>(Signer::address_of(vm));
        if (!tick_state.triggered) {
          tick_state.triggered = true;
          return true
        };
      } else {
        // initialize is called here, in addition to genesis, in order to facilitate upgrades
        initialize(vm);
      };
      false
    }

    // called at the beginning of each epoch, to reset the tick and tricker the autopay
    public fun reconfig_reset_tick(vm: &signer) acquires Tick {
      Roles::assert_diem_root(vm);
      let tick_state = borrow_global_mut<Tick>(Signer::address_of(vm));
      tick_state.triggered = false;
    }

    // Initialize the entire autopay module by creating an empty AccountList object
    // Called in Genesis or upon the first tick
    // Function code 02
    public fun initialize(sender: &signer) {
      Roles::assert_diem_root(sender);

      // initialize resources for the module
      move_to<AccountList>(
        sender,
        AccountList {
          accounts: Vector::empty<address>(),
          // current_epoch: 0, // todo: unused, delete?
        }
      );
      move_to<Tick>(sender, Tick {triggered: false});
      move_to<AccountLimitsEnable>(sender, AccountLimitsEnable {enabled: false});

      // set this to enable escrow of funds. Not used unless account limits 
      // are enabled (i.e. AccoundLimitsEnable set to true)
      DiemAccount::initialize_escrow_root<GAS>(sender);
    }

    // Used to enable account limits. Can only be called by vm, so requires an upgrade 
    // Used mostly for testing
    public fun enable_account_limits(sender: &signer) acquires AccountLimitsEnable {
      Roles::assert_diem_root(sender);
      let limits_enable = borrow_global_mut<AccountLimitsEnable>(Signer::address_of(sender));
      limits_enable.enabled = true;
    }

    // This is the main function for this module. It is called once every epoch
    // by 0x0::DiemBlock in the block_prologue function.
    // This function iterates through all autopay-enabled accounts and processes
    // any payments they have due in the current epoch from their list of payments.
    // Note: payments from epoch n are processed at the beginning of the epoch
    // Function code 03
    public fun process_autopay(
      vm: &signer,
    ) acquires AccountList, UserAutoPay {
      // Only account 0x0 should be triggering this autopayment each block
      Roles::assert_diem_root(vm);

      // Go through all accounts in AccountList
      // This is the list of accounts which currently have autopay enabled
      let account_list = &borrow_global<AccountList>(
        CoreAddresses::DIEM_ROOT_ADDRESS()
      ).accounts;
      let accounts_length = Vector::length<address>(account_list);
      let account_idx = 0;
      while (account_idx < accounts_length) {
        let account_addr = Vector::borrow<address>(account_list, account_idx);
        process_autopay_account(vm, account_addr);
        account_idx = account_idx + 1;
      };
    }

    // Process all outstanding autopay pledges from the account
    fun process_autopay_account(
      vm: &signer,
      account_addr: &address,
    ) acquires UserAutoPay {
      Roles::assert_diem_root(vm);

      // Get the payment list from the account
      let my_autopay_state = borrow_global_mut<UserAutoPay>(*account_addr);
      let payments = &mut my_autopay_state.payments;
      let payments_len = Vector::length<Payment>(payments);
      let payments_idx = 0;
      let pre_run_bal = DiemAccount::balance<GAS>(*account_addr);

      let bal_change_since_last_run = if (pre_run_bal > my_autopay_state.prev_bal) {
        pre_run_bal - my_autopay_state.prev_bal
      } else { 0 };

      // go through the pledges 
      while (payments_idx < payments_len) {
        let payment = Vector::borrow_mut<Payment>(payments, payments_idx);
        // Make a payment if one is required/allowed
        let delete_payment = process_autopay_payment(vm, account_addr, payment, bal_change_since_last_run);
        // Delete any expired payments and increment idx (or decrement list size)
        if (delete_payment == true) {
          Vector::remove<Payment>(payments, payments_idx);
          payments_len = payments_len - 1;
        }
        else {
          payments_idx = payments_idx + 1;
        };
      };

      my_autopay_state.prev_bal = DiemAccount::balance<GAS>(*account_addr);

    }

    // Make any payment required by the autopay instruction given
    // Returns true if the instruction is completed and may be deleted
    fun process_autopay_payment(
      vm: &signer, 
      account_addr: &address,
      payment: &mut Payment,
      bal_change_since_last_run: u64,
    ): bool {
      // check payees are community wallets, only community wallets are allowed
      // to receive autopay (bypassing account limits)
      if (!Wallet::is_comm(payment.payee)) { return false }; // do nothing but don't delete instruction };

      Roles::assert_diem_root(vm);
      let epoch = DiemConfig::get_current_epoch();
      let account_bal = DiemAccount::balance<GAS>(*account_addr);

      // If payment end epoch is greater, it's not an active payment 
      // anymore, so delete it, does not apply to fixed once payment 
      // (it is deleted once it is sent)
      if (payment.end_epoch >= epoch || payment.in_type == FIXED_ONCE) {
        // A payment will happen now
        // Obtain the amount to pay 
        // IMPORTANT there are two digits for scaling representation.
        
        // an autopay instruction of 12.34% is scaled by two orders, 
        // and represented in AutoPay as `1234`.
        let amount = if (payment.in_type == PERCENT_OF_BALANCE) {
          FixedPoint32::multiply_u64(
            account_bal, 
            FixedPoint32::create_from_rational(payment.amt, 10000)
          )
        } else if (payment.in_type == PERCENT_OF_CHANGE) {
          if (bal_change_since_last_run > 0 ) {
            FixedPoint32::multiply_u64(
              bal_change_since_last_run, 
              FixedPoint32::create_from_rational(payment.amt, 10000)
            )
          } else {
            // if account balance hasn't gone up, no value is transferred
            0
          }
        } else {
          // in remaining cases, payment is simple amount given, not a percentage
          payment.amt
        };
        
        if (amount != 0 && amount <= account_bal) {
           DiemAccount::vm_make_payment_no_limit<GAS>(
                *account_addr, payment.payee, amount, b"autopay", b"", vm
              );
        };

        // TODO: this would be deprecated.
        payment.prev_bal = DiemAccount::balance<GAS>(*account_addr);
      };

      // if the payment expired or is one-time only, it may be deleted
      payment.in_type == FIXED_ONCE || payment.end_epoch <= epoch
    }

    /////////////////////////////////////////////////
    // Public functions only account owner         //
    // Enable, disable, create/delete instructions //
    /////////////////////////////////////////////////

    // Each account needs to initialize autopay on its account
    // Function code 010102
    public fun enable_autopay(acc: &signer) acquires AccountList{
      let addr = Signer::address_of(acc);
      // append to account list in system state 0x0
      let accounts = &mut borrow_global_mut<AccountList>(
        CoreAddresses::DIEM_ROOT_ADDRESS()
      ).accounts;
      if (!Vector::contains<address>(accounts, &addr)) {
        Vector::push_back<address>(accounts, *&addr);

      };

      if (!exists<UserAutoPay>(*&addr)) {
        // Initialize the instructions UserAutoPay on user account state 
        move_to<UserAutoPay>(acc, UserAutoPay { 
          payments: Vector::empty<Payment>(),
          prev_bal: DiemAccount::balance<GAS>(addr),
        });
      };

      // Initialize Escrow data
      DiemAccount::initialize_escrow<GAS>(acc);
    }

    // An account can disable autopay on it's account
    // Function code 010103
    public fun disable_autopay(acc: &signer) acquires AccountList, UserAutoPay {
      let addr = Signer::address_of(acc);
      if (!is_enabled(addr)) return;

      // We destroy the data resource for sender
      let sender_data = move_from<UserAutoPay>(addr);
      let UserAutoPay { payments: _ , prev_bal: _ } = sender_data;

      // pop that account from AccountList
      let accounts = &mut borrow_global_mut<AccountList>(
        CoreAddresses::DIEM_ROOT_ADDRESS()
      ).accounts;
      let (status, index) = Vector::index_of<address>(accounts, &addr);
      if (status) {
        Vector::remove<address>(accounts, index);
      }      
    }

    // Create a instruction from the sender's account
    // Function code 010104
    public fun create_instruction(
      sender: &signer, 
      uid: u64,
      in_type: u8,
      payee: address,
      end_epoch: u64,
      amt: u64
    ) acquires UserAutoPay, AccountLimitsEnable {
      let addr = Signer::address_of(sender);
      // Confirm that no payment exists with the same uid
      let index = find(addr, uid);
      assert(Option::is_none<u64>(&index), Errors::invalid_argument(UID_TAKEN));

      // TODO: This check already exists at the time of execution.
      if (borrow_global<AccountLimitsEnable>(CoreAddresses::DIEM_ROOT_ADDRESS()).enabled) {
        assert(Wallet::is_comm(payee), Errors::invalid_argument(PAYEE_NOT_COMMUNITY_WALLET));
      };

      let payments = &mut borrow_global_mut<UserAutoPay>(addr).payments;
      assert(
        Vector::length<Payment>(payments) < MAX_NUMBER_OF_INSTRUCTIONS,
        Errors::limit_exceeded(TOO_MANY_INSTRUCTIONS)
      );
      // This is not a necessary check at genesis.
      // TODO: the genesis timestamp is not correctly identifying transactions in genesis. 
      // if (!DiemTimestamp::is_genesis()) {
      if (DiemConfig::get_current_epoch() > 1) {
        assert(DiemAccount::exists_at(payee), Errors::not_published(EPAYEE_DOES_NOT_EXIST));
      };

      assert(in_type <= MAX_TYPE, Errors::invalid_argument(INVALID_PAYMENT_TYPE));

      if (in_type == PERCENT_OF_BALANCE || in_type == PERCENT_OF_CHANGE) {
        assert(amt <= MAX_PERCENTAGE, Errors::invalid_argument(INVALID_PERCENTAGE));
      };
      let account_bal = DiemAccount::balance<GAS>(addr);

      Vector::push_back<Payment>(payments, Payment {
        uid: uid,
        in_type: in_type,
        payee: payee,
        end_epoch: end_epoch,
        prev_bal: account_bal,
        amt: amt,
      });
    }

    // Deletes the instruction with uid from the sender's account
    // Function code 010105
    public fun delete_instruction(account: &signer, uid: u64) acquires UserAutoPay {
      let addr = Signer::address_of(account);
      let index = find(addr, uid);

      // Case when the payment to be deleted doesn't actually exist
      assert(Option::is_some<u64>(&index), Errors::invalid_argument(AUTOPAY_ID_DOES_NOT_EXIST));

      let payments = &mut borrow_global_mut<UserAutoPay>(addr).payments;
      Vector::remove<Payment>(payments, Option::extract<u64>(&mut index));
    }

    ///////////////////////////////
    // Public functions to Query //
    // Can be queried by anyone  //
    //////////////////////////////

    // Any account can check to see if any of the accounts has autopay enabled
    // by checking in 0x0's AccountList
    public fun is_enabled(account: address): bool acquires AccountList {
      let accounts = &borrow_global<AccountList>(
          CoreAddresses::DIEM_ROOT_ADDRESS()
        ).accounts;
      Vector::contains<address>(accounts, &account)
    }

    // Returns (sender address,  end_epoch, percentage)
    public fun query_instruction(account: address, uid: u64): (u8, address, u64, u64) acquires UserAutoPay {
      let index = find(account, uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment is not found
        return (0, @0x0, 0, 0)
      } else {
        let payments = &borrow_global<UserAutoPay>(account).payments;
        let payment = Vector::borrow(payments, Option::extract<u64>(&mut index));
        return (payment.in_type, payment.payee, payment.end_epoch, payment.amt)
      }
    }

    public fun get_enabled(): vector<address> acquires AccountList {
     *&borrow_global<AccountList>(CoreAddresses::VM_RESERVED_ADDRESS()).accounts
    }

    //////////////////////
    // Private function //
    //////////////////////

    // Retuns the index of the desired payment if it exists
    // This is used often as a helper function to check existence of payments
    fun find(account: address, uid: u64): Option<u64> acquires UserAutoPay {
      let payments = &borrow_global<UserAutoPay>(account).payments;
      let len = Vector::length(payments);
      let i = 0;
      while (i < len) {
        let payment = Vector::borrow<Payment>(payments, i);
        if (payment.uid == uid) {
          return Option::some<u64>(i)
        };
        i = i + 1;
      };
      Option::none<u64>()
    }
  }
}

