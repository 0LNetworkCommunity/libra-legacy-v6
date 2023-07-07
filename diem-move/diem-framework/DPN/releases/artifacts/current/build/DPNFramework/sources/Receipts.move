/////////////////////////////////////////////////////////////////////////
// 0L Module
// Stats Module
// Error code: 1900
/////////////////////////////////////////////////////////////////////////

// THe module stores the last receipt of payment to an account (if the user chooses to document the receipt), in addition the running cumulative payments to an account. This can be used by smart contracts to prove payments interactively, event when a payment is not part of an atomic transaction involving the smart contract. E.g. when an autopay transaction happens a payment to a community wallet can have a receipt for later use in a smart contract.

address DiemFramework {

module Receipts {
  friend DiemFramework::DiemAccount;

  use Std::Vector;
  use DiemFramework::DiemTimestamp;
  use Std::Signer;
  use DiemFramework::CoreAddresses;
  use DiemFramework::Globals;

    struct UserReceipts has key {
      destination: vector<address>,
      cumulative: vector<u64>,
      last_payment_timestamp: vector<u64>,
      last_payment_value: vector<u64>,
    }

    // Utility used at genesis (and on upgrade) to initialize the system state.
    public fun init(account: &signer) { 
      let addr = Signer::address_of(account);     
      if (!exists<UserReceipts>(addr)) {
        move_to<UserReceipts>(
          account,
          UserReceipts {
            destination: Vector::empty<address>(),
            last_payment_timestamp: Vector::empty<u64>(),
            last_payment_value: Vector::empty<u64>(),
            cumulative: Vector::empty<u64>(),
          }
        )
      }; 
    }

    // should only be called from the genesis script.
    fun fork_migrate(
      vm: &signer,
      account: &signer,
      destination: address,
      cumulative: u64,
      last_payment_timestamp: u64,
      last_payment_value: u64,
    ) acquires UserReceipts {
      
      CoreAddresses::assert_vm(vm);
      let addr = Signer::address_of(account);
      assert!(is_init(addr), 0);
      let state = borrow_global_mut<UserReceipts>(addr);
      Vector::push_back(&mut state.destination, destination);
      Vector::push_back(&mut state.cumulative, cumulative * Globals::get_coin_split_factor());
      Vector::push_back(&mut state.last_payment_timestamp, last_payment_timestamp);
      Vector::push_back(&mut state.last_payment_value, last_payment_value * Globals::get_coin_split_factor());
    }

    public fun is_init(addr: address):bool {
      exists<UserReceipts>(addr)
    }

  public fun write_receipt_vm(sender: &signer, payer: address, destination: address, value: u64):(u64, u64, u64) acquires UserReceipts {
      // TODO: make a function for user to write own receipt.
      CoreAddresses::assert_vm(sender);
      write_receipt(payer, destination, value)
  }
    
  /// Restricted to DiemAccount, we need to write receipts for certain users, like to DonorDirected Accounts.
  /// Core Devs: Danger: only DiemAccount can use this.
  public(friend) fun write_receipt(payer: address, destination: address, value: u64):(u64, u64, u64) acquires UserReceipts {
      // TODO: make a function for user to write own receipt.
      if (!exists<UserReceipts>(payer)) {
        return (0, 0, 0)
      };

      let r = borrow_global_mut<UserReceipts>(payer);
      let (found_it, i) = Vector::index_of(&r.destination, &destination);

      let cumu = 0;
      if (found_it) {
        cumu = *Vector::borrow<u64>(&r.cumulative, i);
      };
      cumu = cumu + value;
      Vector::push_back(&mut r.cumulative, *&cumu);

      let timestamp = DiemTimestamp::now_seconds();
      Vector::push_back(&mut r.last_payment_timestamp, *&timestamp);
      Vector::push_back(&mut r.last_payment_value, *&value);

      if (found_it) { // put in same index if the account was already there.
        Vector::swap_remove(&mut r.last_payment_timestamp, i);
        Vector::swap_remove(&mut r.last_payment_value, i);
        Vector::swap_remove(&mut r.cumulative, i);
      } else {
        Vector::push_back(&mut r.destination, destination);
      };
      
      (timestamp, value, cumu)
  }

    // Reads the last receipt for a given account, returns (timestamp of last payment, last value sent, cumulative)
    public fun read_receipt(account: address, destination: address):(u64, u64, u64) acquires UserReceipts {
      if (!exists<UserReceipts>(account)) {
        return (0, 0, 0)
      };

      let receipt = borrow_global<UserReceipts>(account);
      let (found_it, i) = Vector::index_of(&receipt.destination, &destination);
      if (!found_it) return (0, 0, 0);

      let time = Vector::borrow<u64>(&receipt.last_payment_timestamp, i);
      let value = Vector::borrow<u64>(&receipt.last_payment_value, i);
      let cumu = Vector::borrow<u64>(&receipt.cumulative, i);

      (*time, *value, *cumu)
    }
}
}