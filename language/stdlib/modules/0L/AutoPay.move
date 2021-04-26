address 0x1{
  module AutoPay{
///////////////////////////////////////////////////////////////////////////
  // 0L Module
  // Auto Pay - 
  // File Prefix for errors: 0100
  ///////////////////////////////////////////////////////////////////////////
    use 0x1::Vector;
    use 0x1::Option::{Self,Option};
    use 0x1::Signer;
    use 0x1::LibraAccount;
    use 0x1::GAS::GAS;
    use 0x1::FixedPoint32;
    use 0x1::CoreAddresses;
    use 0x1::LibraConfig;
    use 0x1::LibraTimestamp;
    use 0x1::Epoch;
    use 0x1::Globals;
    use 0x1::Errors;

    /// Attempted to send funds to an account that does not exist
    const EPAYEE_DOES_NOT_EXIST: u64 = 010017;

    resource struct Tick {
      triggered: bool,
    }
    // List of payments. Each account will own their own copy of this struct
    resource struct Data {
      payments: vector<Payment>,
    }

    // One copy of this struct will be created. It will be stored in 0x0.
    // It keeps track of all accounts that have autopay enabled and updates the 
    // list as accounts change their Status structs

    // It also keeps track of the current epoch for efficiency (to prevent repeated
    // queries to LibraBlock)
    resource struct AccountList {
      accounts: vector<address>,
      current_epoch: u64,
    }

    // This is the structure of each Payment struct which represents one automatic
    // payment held by an account
    struct Payment {
      // TODO: name should be a string to store a memo
      // name: u64,
      uid: u64,
      payee: address,
      end_epoch: u64,  // end epoch is inclusive
      percentage: u64,
    }

    ///////////////////////////////
    // Public functions only OxO //
    //////////////////////////////
    // Function code: 01
    public fun tick(vm: &signer): bool acquires Tick {
      assert(Signer::address_of(vm) == CoreAddresses::LIBRA_ROOT_ADDRESS(), Errors::requires_role(010001));
      assert(exists<Tick>(CoreAddresses::LIBRA_ROOT_ADDRESS()), Errors::not_published(010001));
      
      let tick_state = borrow_global_mut<Tick>(Signer::address_of(vm));

      if (!tick_state.triggered) {
        let timer = LibraTimestamp::now_seconds() - Epoch::get_timer_seconds_start(vm);
        let tick_interval = Globals::get_epoch_length();
        if (timer > tick_interval/2) {
          tick_state.triggered = true;
          return true
        }
      };
      false
    }

    public fun reconfig_reset_tick(vm: &signer) acquires Tick{
      let tick_state = borrow_global_mut<Tick>(Signer::address_of(vm));
      tick_state.triggered = false;
    }
    // Initialize the entire autopay module by creating an empty AccountList object
    // Called in Genesis
    // Function code 02
    public fun initialize(sender: &signer) {
      assert(Signer::address_of(sender) == CoreAddresses::LIBRA_ROOT_ADDRESS(), Errors::requires_role(010002));
      move_to<AccountList>(sender, AccountList { accounts: Vector::empty<address>(), current_epoch: 0, });
      move_to<Tick>(sender, Tick {triggered: false})
    }

    // This is the main function for this module. It is called once every epoch
    // by 0x0::LibraBlock in the block_prologue function.
    // This function iterates through all autopay-enabled accounts and processes
    // any payments they have due in the current epoch from their list of payments.
    // Note: payments from epoch n are processed at the epoch_length/2
    // Function code 03
    public fun process_autopay(
      vm: &signer,
    ) acquires AccountList, Data {
      // Only account 0x0 should be triggering this autopayment each block
      assert(Signer::address_of(vm) == CoreAddresses::LIBRA_ROOT_ADDRESS(), Errors::requires_role(010003));

      let epoch = LibraConfig::get_current_epoch();

      // Go through all accounts in AccountList
      // This is the list of accounts which currently have autopay enabled
      let account_list = &borrow_global<AccountList>(CoreAddresses::LIBRA_ROOT_ADDRESS()).accounts;
      let accounts_length = Vector::length<address>(account_list);
      let account_idx = 0;

      while (account_idx < accounts_length) {
        let account_addr = Vector::borrow<address>(account_list, account_idx);
        // Obtain the account balance
        let account_bal = LibraAccount::balance<GAS>(*account_addr);
        // Go through all payments for this account and pay 
        let payments = &mut borrow_global_mut<Data>(*account_addr).payments;
        let payments_len = Vector::length<Payment>(payments);
        let payments_idx = 0;
        while (payments_idx < payments_len) {
          let payment = Vector::borrow_mut<Payment>(payments, payments_idx);          
          // no payments to self
          if (&payment.payee == account_addr) break;

          // If payment end epoch is greater, it's not an active payment anymore, so delete it
          if (payment.end_epoch >= epoch) {
            // A payment will happen now
            // Obtain the amount to pay from percentage and balance

            // IMPORTANT there are two digits for scaling representation.
            // an autopay instruction of 12.34% is scaled by two orders, and represented in AutoPay as `1234`.
            if (payment.percentage > 10000) break;
            let percent_scaled = FixedPoint32::create_from_rational(payment.percentage, 10000);
            
            let amount = FixedPoint32::multiply_u64(account_bal, percent_scaled);
            if (amount > account_bal) {
              // deplete the account if greater
              amount = amount - account_bal;
            };
            if (amount>0) {
              LibraAccount::vm_make_payment<GAS>(*account_addr, payment.payee, amount, x"", x"", vm);
            }

          };
          // TODO: might want to delete inactive instructions to save memory
          payments_idx = payments_idx + 1;
        };
        account_idx = account_idx + 1;
      };
    }

    ////////////////////////////////////////////
    // Public functions only account owner    //
    // Enable, disable, create/delete instructions //
    ////////////////////////////////////////////

    // Each account needs to initialize autopay on it's account
    // Function code 010102
    public fun enable_autopay(acc: &signer) acquires AccountList{
      let addr = Signer::address_of(acc);
      // append to account list in system state 0x0
      let accounts = &mut borrow_global_mut<AccountList>(CoreAddresses::LIBRA_ROOT_ADDRESS()).accounts;
      if (!Vector::contains<address>(accounts, &addr)) {
        Vector::push_back<address>(accounts, addr);
      };
      // Initialize the instructions Data on user account state 
      move_to<Data>(acc, Data { payments: Vector::empty<Payment>()});
    }

    // An account can disable autopay on it's account
    // Function code 010103
    public fun disable_autopay(acc: &signer) acquires AccountList, Data {
      
      let addr = Signer::address_of(acc);

      // We destroy the data resource for sender
      let sender_data = move_from<Data>(addr);
      let Data { payments: _ } = sender_data;

      // pop that account from AccountList
      let accounts = &mut borrow_global_mut<AccountList>(CoreAddresses::LIBRA_ROOT_ADDRESS()).accounts;
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
      payee: address,
      end_epoch: u64,
      percentage: u64
    ) acquires Data {
      let addr = Signer::address_of(sender);
      // Confirm that no payment exists with the same uid
      let index = find(addr, uid);
      if (Option::is_some<u64>(&index)) {
        // This is the case where the payment uid already exists in the vector
        assert(false, 010104011021);
      };
      let payments = &mut borrow_global_mut<Data>(addr).payments;

      assert(LibraAccount::exists_at(payee), Errors::not_published(EPAYEE_DOES_NOT_EXIST));

      Vector::push_back<Payment>(payments, Payment {
        // name: name,
        uid: uid,
        payee: payee,
        end_epoch: end_epoch,
        percentage: percentage,
      });
    }

    // Deletes the instruction with uid from the sender's account
    // Function code 010105
    public fun delete_instruction(account: &signer, uid: u64) acquires Data {
      let addr = Signer::address_of(account);
      let index = find(addr, uid);
      if (Option::is_none<u64>(&index)) {
        // Case when the payment to be deleted doesn't actually exist
        assert(false, 010105012040);
      };
      let payments = &mut borrow_global_mut<Data>(addr).payments;
      Vector::remove<Payment>(payments, Option::extract<u64>(&mut index));
    }

    ///////////////////////////////
    // Public functions to Query //
    // Can be queried by anyone  //
    //////////////////////////////

    // Any account can check to see if any of the accounts has autopay enabled
    // by checking in 0x0's AccountList
    public fun is_enabled(account: address): bool acquires AccountList {
      let accounts = &mut borrow_global_mut<AccountList>(CoreAddresses::LIBRA_ROOT_ADDRESS()).accounts;
      if (Vector::contains<address>(accounts, &account)) {
        return true
      };
      false
    }

    // Returns (sender address,  end_epoch, percentage)
    public fun query_instruction(account: address, uid: u64): (address, u64, u64) acquires Data {
      // TODO: This can be made faster if Data.payments is stored as a BST sorted by 
      let index = find(account, uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment is not found
        return (0x0, 0, 0)
      } else {
        let payments = &borrow_global_mut<Data>(account).payments;
        let payment = Vector::borrow(payments, Option::extract<u64>(&mut index));
        return (payment.payee, payment.end_epoch, payment.percentage)
      }
    }

    //////////////////////
    // Private function //
    //////////////////////

    // Retuns the index of the desired payment and an immutable reference to it
    // This is used often as a helper function to check existence of payments
    fun find(account: address, uid: u64): Option<u64> acquires Data {
      let payments = &borrow_global<Data>(account).payments;
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

  //   // This function is only called by LibraBlock anytime the block number is changed
  //   // This architecture avoids a cyclical dependency by using the Observer design pattern
  //   public fun update_block(height: u64) acquires AccountList {
  //     // If 0x0 is updating the block number, update it for the module in AccountList
  //     Transaction::assert(Transaction::sender() == 0x0, 8001);
  //     borrow_global_mut<AccountList>(0x0).current_block = height;
  //   }


  //   // // This is currently used only for testing purposes
  //   // // TODO: Remove this function eventually
  //   // public fun make_dummy_payment_vec(payee: address): vector<Payment> {
  //   //   let ret = Vector::empty<Payment>();
  //   //   Vector::push_back(&mut ret, Payment {
  //   //       enabled: true,
  //   //       name: 0,
  //   //       uid: 0,
  //   //       payee: payee,
  //   //       end: 5,
  //   //       amount: 1,
  //   //       currency_code: Libra::currency_code<GAS::T>(),
  //   //       from_earmarked_transactions: true,
  //   //       last_block_paid: 0,
  //   //     } 
  //   //   );
  //   //   ret
  //   // }

  //   // Any account can check for the existence of a payment for any other account.
  //   // Example use case: Landlord wants to confirm that a renter still has their autopay
  //   // payments enabled and wants to check details using the payment uid that the renter
  //   // provided
  //   public fun exists(account: address, uid: u64): bool acquires Data {
  //     let index = find(account, uid);
  //     if (Option::is_some<u64>(&index)) {
  //       return true
  //     } else {
  //       return false
  //     }
  //   }