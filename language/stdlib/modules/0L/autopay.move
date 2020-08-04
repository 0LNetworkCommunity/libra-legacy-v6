address 0x0{
  module AutoPay{
    use 0x0::Vector;

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
      end: u64,
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
  }
}
