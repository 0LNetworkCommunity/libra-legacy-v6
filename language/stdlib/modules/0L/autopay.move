address 0x0{
  module AutoPay{
///////////////////////////////////////////////////////////////////////////
  // OpenLibra Module
  // Auto Pay - 
  // File Prefix for errors: 0101
  ///////////////////////////////////////////////////////////////////////////
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::Option;
    use 0x0::Signer;
    use 0x0::LibraAccount;
    use 0x0::GAS;
    use 0x0::FixedPoint32;

    // List of payments. Each account will own their own copy of this struct
    resource struct Data {
      payments: vector<Payment>,
    }

    // One copy of this struct will be created. It will be stored in 0x0.
    // It keeps track of all accounts that have autopay enabled and updates the 
    // list as accounts change their Status structs
    //
    // It also keeps track of the current epoch fo efficiency (to prevent repeated
    // queries to LibraBlock)
    resource struct AccountList {
      accounts: vector<address>,
      current_epoch: u64,
    }

    // This is the structure of each Payment struct which represents one automatic
    // payment held by an account
    struct Payment {
      // TODO: name should be a string to store a memo
      name: u64,
      uid: u64,
      payee: address,
      end_epoch: u64,  // end epoch is inclusive
      percentage: u64,
    }


    // Initialize the entire autopay module by creating an empty AccountList object
    // Called in Genesis
    // Function code 010101
    public fun initialize(sender: &signer) {
      Transaction::assert(Signer::address_of(sender) == 0x0, 0101014010);
      move_to<AccountList>(sender, AccountList { accounts: Vector::empty<address>(), current_epoch: 0, });
    }

    // Each account needs to initialize autopay on it's account
    // Function code 010102
    public fun enable_autopay() acquires AccountList{
      // append to account list
      let accounts = &mut borrow_global_mut<AccountList>(0x0).accounts;
      if (!Vector::contains<address>(accounts, &Transaction::sender())) {
        Vector::push_back<address>(accounts, Transaction::sender());
      };
      // Initialize the pledges Data
      move_to_sender<Data>(Data { payments: Vector::empty<Payment>()});
    }

    // An account can disable autopay on it's account
    // Function code 010103
    public fun disable_autopay() acquires AccountList, Data {
      // We destroy the data resource for sender
      let sender_data = move_from<Data>(Transaction::sender());
      let Data { payments: _ } = sender_data;

      // pop that account from AccountList
      let accounts = &mut borrow_global_mut<AccountList>(0x0).accounts;
      let (status, index) = Vector::index_of<address>(accounts, &Transaction::sender());
      if (status) {
        Vector::remove<address>(accounts, index);
      }      
    }

    // Create a pledge from the sender's account
    // Function code 010104
    public fun create_pledge(
      name: u64,
      uid: u64,
      payee: address,
      end_epoch: u64,
      percentage: u64) acquires Data {
      
      // Confirm that no payment exists with the same uid
      let index = find(Transaction::sender(), uid);
      if (Option::is_some<u64>(&index)) {
        // This is the case where the payment uid already exists in the vector
        Transaction::assert(false, 010104011021);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      Vector::push_back<Payment>(payments, Payment {
        name: name,
        uid: uid,
        payee: payee,
        end_epoch: end_epoch,
        percentage: percentage,
      });
    }

    // Deletes the pledge with uid from the sender's account
    // Function code 010105
    public fun delete_pledge(uid: u64) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case when the payment to be deleted doesn't actually exist
        Transaction::assert(false, 010105012040);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      Vector::remove<Payment>(payments, Option::extract<u64>(&mut index));
    }

    // This is the main function for this module. It is called once every epoch
    // by 0x0::LibraBlock in the block_prologue function.
    // This function iterates through all autopay-enabled accounts and processes
    // any payments they have due in the current epoch from their list of payments.
    // Note: payments from epoch n are processed at the epoch_length/2
    // Function code 010106
    public fun process_autopay(
      signer: &signer,
      epoch: u64
    ) acquires AccountList, Data {
      // Only account 0x0 should be triggering this autopayment each block
      Transaction::assert(Signer::address_of(signer) == 0x0, 0101064010);

      // Go through all accounts in AccountList
      // This is the list of accounts which currently have autopay enabled
      let account_list = &borrow_global<AccountList>(0x0).accounts;
      let accounts_length = Vector::length<address>(account_list);
      let account_idx = 0;

      while (account_idx < accounts_length) {

        let account_addr = Vector::borrow<address>(account_list, account_idx);
        
        // Obtain the account balance
        let account_bal = LibraAccount::balance<GAS::T>(*account_addr);
        
        // Go through all payments for this account and pay 
        let payments = &mut borrow_global_mut<Data>(*account_addr).payments;
        let payments_len = Vector::length<Payment>(payments);
        let payments_idx = 0;
        
        while (payments_idx < payments_len) {
          let payment = Vector::borrow_mut<Payment>(payments, payments_idx);
          // If payment end epoch is greater, it's not an active payment anymore, so delete it
          if (payment.end_epoch >= epoch) {
            // A payment will happen now
            // Obtain the amount to pay from percentage and balance
            let amount = FixedPoint32::divide_u64(payment.percentage , FixedPoint32::create_from_rational(100, 1)) * account_bal;
            LibraAccount::make_payment<GAS::T>(signer, *account_addr, payment.payee, amount);
          };
          // ToDo: might want to delete inactive pledges to save memory
          payments_idx = payments_idx + 1;
        };
        account_idx = account_idx + 1;
      };
    }

    //////////////////////
    // Private function //
    //////////////////////

    // Retuns the index of the desired payment and an immutable reference to it
    // This is used often as a helper function to check existence of payments
    fun find(account: address, uid: u64): Option::T<u64> acquires Data {
      let payments = &borrow_global<Data>(account).payments;
      let len = Vector::length(payments);
      let i = 0;
      while (i < len) {
        let payment = Vector::borrow<Payment>(payments, i);
        if (payment.uid == uid) {
          return Option::some<u64>(i)
        };
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


  //   // Any account can check to see if any othe account has autopay enabled
  //   // by checking their Status enabled and also membership in 0x0's AccountList
  //   public fun is_enabled(account: address): bool acquires Status, AccountList {
  //     let status = borrow_global<Status>(account);
  //     if (status.enabled) {
  //       let accounts = &mut borrow_global_mut<AccountList>(0x0).accounts;
  //       if (Vector::contains<address>(accounts, &account)) {
  //         return true
  //       };
  //     };
  //     false
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


  //   // Any account can check to see details about other accounts' autopay status and/or
  //   // details. This function queries an account's number of payments
  //   public fun num_payments(account: address): u64 acquires Data{
  //     let payments = &borrow_global<Data>(account).payments;
  //     Vector::length(payments)
  //   }


  //   // Returns (number of past payments made, number of upcoming payments)
  //   // based on calculation using the current block_height
  //   public fun query(account: address, uid: u64): (u64, u64) acquires Data, AccountList {
  //     // TODO: This can be made faster if Data.payments is stored as a
  //     // BST sorted by 
  //     let index = find(Transaction::sender(), uid);
  //     if (Option::is_none<u64>(&index)) {
  //       // Case where payment is not found
  //       return (0, 0)
  //     } else {
  //       let payments = &borrow_global_mut<Data>(account).payments;
  //       let payment = Vector::borrow(payments, Option::extract<u64>(&mut index));
  //       let block = borrow_global<AccountList>(0x0).current_block;
  //       let num_payments = (payment.end - payment.start + 1) / payment.frequency;
  //       if (block <= payment.start) {
  //         // This will front end round the result since the return types
  //         // are integers. This gives the correct result. +1 because bounds
  //         // are inclusive
  //         return (0, num_payments)
  //       } else if (block > payment.end) {
  //         return (num_payments, 0)
  //       } else {
  //         // This accounts for one payment on at start (the payment is not considered
  //         // to have happened when block = start because the block is curently happneing).
  //         // The calculation is artificially rounding up the division of
  //         // '(block - payment.start)/payment.frequency' because there actually is a payment
  //         // that happens at payment.start
  //         let past_payments = ((block - payment.start + payment.frequency - 1) / payment.frequency);
  //         return (past_payments, num_payments - past_payments)
  //       }
  //     }
  //   }


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


  //   


  

  //   // This is the main function for this module. It is called once every block
  //   // by 0x0::LibraBlock in the block_prologue function.
  //   //
  //   // This function iterates through all autopay-enabled accounts and processes
  //   // any payments they have due in the current block from their list of payments.
  //   //
  //   // Note: payments from block n are processed at the end of block n
  //   public fun autopay(
  //     signer: &signer,
  //     block: u64
  //   ) acquires AccountList, Data {
  //     // Only account 0x0 should be triggering this autopayment each block
  //     Transaction::assert(Signer::address_of(signer) == 0x0, 8001);
  //     // Go through all accounts in AccountList
  //     // This is the list of accounts which currently have autopay enabled
  //     let account_list = &borrow_global<AccountList>(0x0).accounts;
  //     let num_accounts = Vector::length<address>(account_list);
  //     let account_idx = 0;
  //     while (account_idx < num_accounts) {
  //       let account_addr = Vector::borrow<address>(account_list, account_idx);
  //       let payments = &mut borrow_global_mut<Data>(*account_addr).payments;
  //       let payments_len = Vector::length<Payment>(payments);
  //       let payments_idx = 0;
  //       // Go through all payments for this account and pay the ones which are due
  //       while (payments_idx < payments_len) {
  //         let payment = Vector::borrow_mut<Payment>(payments, payments_idx);
  //         if (!payment.enabled) {
  //           // If payment is disabled, move on
  //           payments_idx = payments_idx + 1;
  //           continue
  //         };
  //         // If payment is due this block, pay
  //         // Check if payment is starting this block
  //         if (payment.end < block) {
  //           // This is the case where the payment isn't in the payment period
  //           payments_idx = payments_idx + 1;
  //           continue
  //         } else {
  //           // A payment might need to happen now and it's not the fist payment
  //           if (payment.last_block_paid + payment.frequency != block) {
  //             // No payment this block
  //             payments_idx = payments_idx + 1;
  //             continue
  //           } else {
  //             // Payment is happening this block
  //             payment.last_block_paid = block;
  //           };
  //         };
  //         // Actually pay. If payment is not due, a 'continue' statement would have
  //         // moved on to the next iteration already and this statement is not reached
          
  //         // Make sure that the desired currency is actually one of the allowed ones
  //         // Also, do not process the payment if the account doesn't have enough money
  //         let currency = *&payment.currency_code;
  //         // Check GAS
  //         if (Vector::compare<u8>(&Libra::currency_code<GAS::T>(), &currency)) {
  //           if (LibraAccount::balance<GAS::T>(*account_addr) < payment.amount) {
  //             continue
  //           };
  //           LibraAccount::make_payment<GAS::T>(signer, *account_addr, payment.payee, payment.amount);
  //         // TODO: To implement other currencies, use code similar to the below commented 
  //         // code. This will check for other currencies enabled. Replace LBR with the currency
  //         // module name.

  //         // } else if (Vector::compare<u8>(&Libra::currency_code<LBR::T>(), &currency)) {
  //         //   // Check LBR
  //         //   if (LibraAccount::balance<LBR::T>(*account_addr) < payment.amount) {
  //         //     continue
  //         //   };
  //         //   LibraAccount::make_payment<LBR::T>(signer, *account_addr, payment.payee, payment.amount);
  //         };
  //         // Add similar code for any new currencies to add.
  //         payments_idx = payments_idx + 1;
  //       };
  //       account_idx = account_idx + 1;
  //     };
  //   }


  //   // Any account can check on details for payments of other accounts given the uid
  //   public fun get_name(account: address, uid: u64): u64 acquires Data {
  //     let index = find(account, uid);
  //     if (Option::is_none<u64>(&index)) {
  //       // Case where payment doesn't exist for chosen account
  //       Transaction::assert(false, 22);
  //     };
  //     let payments = &borrow_global<Data>(account).payments;
  //     let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
  //     payment.name
  //   }

  //   // Any account can check on details for payments of other accounts given the uid
  //   public fun get_payee(account: address, uid: u64): address acquires Data {
  //     let index = find(account, uid);
  //     if (Option::is_none<u64>(&index)) {
  //       // Case where payment doesn't exist for chosen account
  //       Transaction::assert(false, 31);
  //     };
  //     let payments = & borrow_global<Data>(account).payments;
  //     let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
  //     payment.payee
  //   }

  //   // Any account can check on details for payments of other accounts given the uid
  //   public fun get_end(account: address, uid: u64): u64 acquires Data {
  //     let index = find(account, uid);
  //     if (Option::is_none<u64>(&index)) {
  //       // Case where payment doesn't exist for chosen account
  //       Transaction::assert(false, 25);
  //     };
  //     let payments = &borrow_global<Data>(account).payments;
  //     let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
  //     payment.end
  //   }

  //   // Any account can check on details for payments of other accounts given the uid
  //   public fun get_amount(account: address, uid: u64): u64 acquires Data {
  //     let index = find(account, uid);
  //     if (Option::is_none<u64>(&index)) {
  //       // Case where payment doesn't exist for chosen account
  //       Transaction::assert(false, 26);
  //     };
  //     let payments = &borrow_global<Data>(account).payments;
  //     let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
  //     payment.amount
  //   }
  // }
//}