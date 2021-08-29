address 0x1 {

/// The `DiemAccount` module manages accounts. It defines the `DiemAccount` resource and
/// numerous auxiliary data structures. It also defines the prolog and epilog that run
/// before and after every transaction.

/////// 0L /////////
// File Prefix for errors: 1201 used for OL errors

module Deposits {
    use 0x1::CoreAddresses;
    use 0x1::Signer;
    //////// 0L ////////
    /// Separate struct to track cumulative deposits
    struct CumulativeDeposits has key {
        /// Store the cumulative deposits made to this account.
        /// not all accounts will have this enabled.
        value: u64,
        index: u64, 
    }

    //////// 0L ////////
    // init struct for storing cumulative deposits, for community wallets
    public fun init_cumulative_deposits(sender: signer, starting_balance: u64) {
      let addr = Signer::address_of(&sender);

      if (!exists<CumulativeDeposits>(addr)) {
        move_to<CumulativeDeposits>(&sender, CumulativeDeposits {
          value: starting_balance,
          index: starting_balance,
        })
      };
    }

    public fun vm_maybe_update_deposit(vm: signer, payee: address, epoch: u64, deposit_value: u64) acquires CumulativeDeposits {
        CoreAddresses::assert_vm(&vm);
            // update cumulative deposits if the account has the struct.
        if (exists<CumulativeDeposits>(payee)) {
          // let epoch = LibraConfig::get_current_epoch();
          let index = deposit_index_curve(epoch, deposit_value);
          let cumu = borrow_global_mut<CumulativeDeposits>(payee);
          cumu.value = cumu.value + deposit_value;
          cumu.index = cumu.index + index;
        };
    }

    /// adjust the points of the deposits favoring more recent deposits.
    /// inflation by x% per day from the start of network.
    fun deposit_index_curve(
      epoch: u64,
      value: u64,
    ): u64 {
      
      // increment 1/2 percent per day, not compounded.
      (value * (1000 + (epoch * 5))) / 1000
    }



    public fun get_cumulative_deposits(addr: address): u64 acquires CumulativeDeposits {
      if (!exists<CumulativeDeposits>(addr)) return 0;

      borrow_global<CumulativeDeposits>(addr).value
    }

    public fun get_index_cumu_deposits(addr: address): u64 acquires CumulativeDeposits {
      if (!exists<CumulativeDeposits>(addr)) return 0;

      borrow_global<CumulativeDeposits>(addr).index
    }
}
}