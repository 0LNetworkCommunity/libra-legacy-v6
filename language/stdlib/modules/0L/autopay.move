address 0x0{
  module AutoPay{
    use 0x0::Vector;
    use 0x0::LibraBlock;
    use 0x0::Transaction;
    use 0x0::Option;

    // Creating structs to be used
    resource struct Status {
      enabled: bool,
    }

    // List of payments
    resource struct Data {
      payments: vector<Payment>,
    }

    struct Payment {
      enabled: bool,
      // TODO: name should be a string to store a memo
      name: u64,
      uid: u64,
      frequency: u64,             // pay every frequency blocks
      start: u64,                 // start paying in this block
      end: u64,                   // start and end are inclusive
      fixed_fee: u64,
      variable_fee: u64,
      // TODO: assert that CoinType is a valid type of currency
      currency: u64,
      // TODO: cannot make from_earmaked_tansactions a reference-type to be &signer
      //  Also don't want this struct to have ownership of the signer object
      from_earmarked_transactions: bool,
    }

    // Each account should initialize for themselves
    public fun init_status(enabled: bool) {
      move_to_sender<Status>(Status{ enabled: enabled });
    }

    public fun init_data(payments: vector<Payment>) {
      move_to_sender<Data>(Data { payments: payments });
    }

    public fun is_enabled(account: address): bool acquires Status {
      let status = borrow_global<Status>(account);
      status.enabled
    }

    public fun make_dummy_payment_vec(): vector<Payment> {
      let ret = Vector::empty<Payment>();
      Vector::push_back(&mut ret, Payment {
          enabled: true,
          name: 0,
          uid: 0,
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
        frequency: frequency,
        start: start,
        end: end,
        fixed_fee: fixed_fee,
        variable_fee: variable_fee,
        currency: currency,
        from_earmarked_transactions: from_earmarked_transactions
      });
    }

    public fun enable(uid: u64) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for sender
        Transaction::assert(false, 12);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      let payment = Vector::borrow_mut<Payment>(payments, Option::extract<u64>(&mut index));
      payment.enabled = true;
    }

    public fun disable(uid: u64) acquires Data {
      let index = find(Transaction::sender(), uid);
      if (Option::is_none<u64>(&index)) {
        // Case where payment doesn't exist for sender
        Transaction::assert(false, 12);
      };
      let payments = &mut borrow_global_mut<Data>(Transaction::sender()).payments;
      let payment = Vector::borrow_mut<Payment>(payments, Option::extract<u64>(&mut index));
      payment.enabled = false;
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
  }
}
