address 0x0{
  module AutoPay{
    use 0x0::Vector;
    use 0x0::LibraBlock;
    use 0x0::Transaction;
    use 0x0::Option;
    use 0x0::Signer;

    // Creating structs to be used
    resource struct Status {
      enabled: bool,
    }

    // List of payments
    resource struct Data {
      payments: vector<Payment>,
    }

    resource struct AccountList {
      accounts: vector<address>,
    }

    struct Payment {
      enabled: bool,
      // TODO: name should be a string to store a memo
      name: u64,
      uid: u64,
      payee: address,
      frequency: u64,             // pay every frequency blocks
      start: u64,                 // start paying in this block
      end: u64,                   // start and end are inclusive
      fixed_fee: u64,
      variable_fee: u64,
      // TODO: assert that CoinType is a valid type of currency
      currency: u64,
      // TODO: cannot make from_earmaked_transactions a reference-type to be &signer
      //  Also don't want this struct to have ownership of the signer object
      from_earmarked_transactions: bool,
    }

    public fun initialize(sender: &signer) {
      Transaction::assert(Signer::address_of(sender) == 0x0, 8001);

      move_to<AccountList>(sender, AccountList { accounts: Vector::empty<address>(), });
    }


    public fun verify_initialized() acquires AccountList {
      // This will cause an error if it's not initiliazed because the data won't exist.
      borrow_global_mut<AccountList>(0x0);
    }
    

    // Each account should initialize for themselves
    public fun init_status(enabled: bool) acquires AccountList {
      move_to_sender<Status>(Status{ enabled: enabled });
      if (enabled) {
        let accounts = &mut borrow_global_mut<AccountList>(0x0).accounts;
        if (!Vector::contains<address>(accounts, &Transaction::sender())) {
          Vector::push_back<address>(accounts, Transaction::sender());
        }
      };
    }

    public fun init_data(payments: vector<Payment>) {
      move_to_sender<Data>(Data { payments: payments });
    }

    public fun is_enabled(account: address): bool acquires Status, AccountList {
      let status = borrow_global<Status>(account);
      if (status.enabled) {
        let accounts = &mut borrow_global_mut<AccountList>(0x0).accounts;
        if (Vector::contains<address>(accounts, &account)) {
          return true
        };
      };
      false
    }

    public fun enable_account() acquires Status, AccountList {
      let status = borrow_global_mut<Status>(Transaction::sender());
      status.enabled = true;
      let accounts = &mut borrow_global_mut<AccountList>(0x0).accounts;
      if (!Vector::contains<address>(accounts, &Transaction::sender())) {
        Vector::push_back<address>(accounts, Transaction::sender());
      }
    }

    public fun disable_account() acquires Status, AccountList {
      let status = borrow_global_mut<Status>(Transaction::sender());
      status.enabled = false;
      let accounts = &mut borrow_global_mut<AccountList>(0x0).accounts;
      let (status, index) = Vector::index_of<address>(accounts, &Transaction::sender());
      if (status) {
        Vector::remove<address>(accounts, index);
      }
    }

    public fun make_dummy_payment_vec(): vector<Payment> {
      let ret = Vector::empty<Payment>();
      Vector::push_back(&mut ret, Payment {
          enabled: true,
          name: 0,
          uid: 0,
          payee: Transaction::sender(),
          frequency: 1,
          start: 0,
          end: 5,
          fixed_fee: 0,
          variable_fee: 0,
          currency: 0,
          from_earmarked_transactions: true,
        } 
      );
      ret
    }

    public fun num_payments(account: address): u64 acquires Data{
      let payments = &borrow_global<Data>(account).payments;
      Vector::length(payments)
    }

    // Returns (number of historical payments, number of upcoming payments)
    public fun query(account: address, uid: u64): (u64, u64) acquires Data {
      // TODO: This can be made faster if Data.payments is stored as a
      // BST sorted by 
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment is not found
        return (0, 0)
      } else {
        let payments = &borrow_global_mut<Data>(account).payments;
        let payment = Vector::borrow(payments, Option::extract<u64>(&mut index));
        let block = LibraBlock::get_current_block_height();
        let num_payments = (payment.end - payment.start + 1) / payment.frequency;
        if (block <= payment.start) {
          // This will front end round the result since the return types
          // are integers. This gives the correct result. +1 because bounds
          // are inclusive
          return (0, num_payments)
        } else if (block > payment.end) {
          return (num_payments, 0)
        } else {
          // This accounts for one payment on at start (the payment is not considered
          // to have happened when block = start because the block is curently happneing).
          // The calculation is artificially rounding up the division of
          // '(block - payment.start)/payment.frequency' because there actually is a payment
          // that happens at payment.start
          let past_payments = ((block - payment.start + payment.frequency - 1) / payment.frequency);
          return (past_payments, num_payments - past_payments)
        }
      }
    }

    public fun exists(account: address, uid: u64): bool acquires Data {
      let index = find(account, uid);
      if (Option::is_some<u64>(&index)) {
        return true
      } else {
        return false
      }
    }

    public fun create(
      enabled: bool,
      name: u64,
      uid: u64,
      payee: address,
      frequency: u64,
      start: u64,
      end: u64,
      fixed_fee: u64,
      variable_fee: u64,
      currency: u64,
      from_earmarked_transactions: bool) acquires Data {
      // Confirm that no payment exists with the same uid
      let index = find(Transaction::sender(), uid);
      if (Option::is_some<u64>(&index)) {
        // This is the case where the payment uid already exists in the vector
        Transaction::assert(false, 5);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      Vector::push_back<Payment>(payments, Payment {
        enabled: enabled,
        name: name,
        uid: uid,
        payee: payee,
        frequency: frequency,
        start: start,
        end: end,
        fixed_fee: fixed_fee,
        variable_fee: variable_fee,
        currency: currency,
        from_earmarked_transactions: from_earmarked_transactions
      });
    }

    public fun delete(uid: u64) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case when the payment to be deleted doesn't actually exist
        Transaction::assert(false, 21);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      Vector::remove<Payment>(payments, Option::extract<u64>(&mut index));
    }

    // Retuns the index of the desired payment and an immutable reference to it
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

    public fun change_enabled(uid: u64, enabled: bool) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for sender
        Transaction::assert(false, 12);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      let payment = Vector::borrow_mut<Payment>(payments, Option::extract<u64>(&mut index));
      payment.enabled = enabled;
    }

    public fun get_enabled(account: address, uid: u64): bool acquires Data {
      let index = find(account, uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for chosen account
        Transaction::assert(false, 21);
      };
      let payments = &borrow_global<Data>(account).payments;
      let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
      payment.enabled
    }

    public fun change_name(uid: u64, name: u64) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for sender
        Transaction::assert(false, 14);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      let payment = Vector::borrow_mut<Payment>(payments, Option::extract<u64>(&mut index));
      payment.name = name;
    }

    public fun get_name(account: address, uid: u64): u64 acquires Data {
      let index = find(account, uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for chosen account
        Transaction::assert(false, 22);
      };
      let payments = &borrow_global<Data>(account).payments;
      let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
      payment.name
    }

    public fun change_payee(uid: u64, payee: address) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for sender
        Transaction::assert(false, 30);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      let payment = Vector::borrow_mut<Payment>(payments, Option::extract<u64>(&mut index));
      payment.payee = payee;
    }

    public fun get_payee(account: address, uid: u64): address acquires Data {
      let index = find(account, uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for chosen account
        Transaction::assert(false, 31);
      };
      let payments = & borrow_global<Data>(account).payments;
      let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
      payment.payee
    }

    public fun change_frequency(uid: u64, frequency: u64) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for sender
        Transaction::assert(false, 15);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      let payment = Vector::borrow_mut<Payment>(payments, Option::extract<u64>(&mut index));
      payment.frequency = frequency;
    }

    public fun get_frequency(account: address, uid: u64): u64 acquires Data {
      let index = find(account, uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for chosen account
        Transaction::assert(false, 23);
      };
      let payments = &borrow_global<Data>(account).payments;
      let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
      payment.frequency
    }

    public fun change_start(uid: u64, start: u64) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for sender
        Transaction::assert(false, 16);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      let payment = Vector::borrow_mut<Payment>(payments, Option::extract<u64>(&mut index));
      payment.start = start;
    }

    public fun get_start(account: address, uid: u64): u64 acquires Data {
      let index = find(account, uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for chosen account
        Transaction::assert(false, 24);
      };
      let payments = &borrow_global<Data>(account).payments;
      let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
      payment.start
    }

    public fun change_end(uid: u64, end: u64) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for sender
        Transaction::assert(false, 16);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      let payment = Vector::borrow_mut<Payment>(payments, Option::extract<u64>(&mut index));
      payment.end = end;
    }

    public fun get_end(account: address, uid: u64): u64 acquires Data {
      let index = find(account, uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for chosen account
        Transaction::assert(false, 25);
      };
      let payments = &borrow_global<Data>(account).payments;
      let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
      payment.end
    }

    public fun change_fixed_fee(uid: u64, fee: u64) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for sender
        Transaction::assert(false, 17);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      let payment = Vector::borrow_mut<Payment>(payments, Option::extract<u64>(&mut index));
      payment.fixed_fee = fee;
    }

    public fun get_fixed_fee(account: address, uid: u64): u64 acquires Data {
      let index = find(account, uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for chosen account
        Transaction::assert(false, 26);
      };
      let payments = &borrow_global<Data>(account).payments;
      let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
      payment.fixed_fee
    }

    public fun change_variable_fee(uid: u64, fee: u64) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for sender
        Transaction::assert(false, 18);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      let payment = Vector::borrow_mut<Payment>(payments, Option::extract<u64>(&mut index));
      payment.variable_fee = fee;
    }

    public fun get_variable_fee(account: address, uid: u64): u64 acquires Data {
      let index = find(account, uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for chosen account
        Transaction::assert(false, 27);
      };
      let payments = &borrow_global<Data>(account).payments;
      let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
      payment.variable_fee
    }

    public fun change_currency(uid: u64, currency: u64) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for sender
        Transaction::assert(false, 19);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      let payment = Vector::borrow_mut<Payment>(payments, Option::extract<u64>(&mut index));
      payment.currency = currency;
    }

    public fun get_currency(account: address, uid: u64): u64 acquires Data {
      let index = find(account, uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for chosen account
        Transaction::assert(false, 28);
      };
      let payments = &borrow_global<Data>(account).payments;
      let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
      payment.currency
    }

    public fun change_from_earmarked(uid: u64, from_earmarked: bool) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for sender
        Transaction::assert(false, 20);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      let payment = Vector::borrow_mut<Payment>(payments, Option::extract<u64>(&mut index));
      payment.from_earmarked_transactions = from_earmarked;
    }

    public fun get_from_earmarked(account: address, uid: u64): bool acquires Data {
      let index = find(account, uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for chosen account
        Transaction::assert(false, 29);
      };
      let payments = &borrow_global<Data>(account).payments;
      let payment = Vector::borrow<Payment>(payments, Option::extract<u64>(&mut index));
      payment.from_earmarked_transactions
    }
  }
}
