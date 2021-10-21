/////////////////////////////////////////////////////////////////////////
// 0L Module
// Stats Module
// Error code: 1900
/////////////////////////////////////////////////////////////////////////

// THe module stores the last receipt of payment to an account (if the user chooses to document the receipt), in addition the running cumulative payments to an account. This can be used by smart contracts to prove payments interactively, event when a payment is not part of an atomic transaction involving the smart contract. E.g. when an autopay transaction happens a payment to a community wallet can have a receipt for later use in a smart contract.

address 0x1 {

module Receipts {
  use 0x1::Vector;
  use 0x1::DiemTimestamp;
  use 0x1::Signer;
  use 0x1::CoreAddresses;

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
    
  public fun write_receipt(vm: &signer, payer: address, destination: address, value: u64):(u64, u64, u64) acquires UserReceipts {
      CoreAddresses::assert_vm(vm);
      // let addr = Signer::address_of(account);
      let r = borrow_global_mut<UserReceipts>(payer);
      let (_, i) = Vector::index_of(&r.destination, &destination);
      
      let timestamp = DiemTimestamp::now_seconds();

      let cumu = *Vector::borrow<u64>(&r.cumulative, i);
      cumu = cumu + value;

      Vector::push_back(&mut r.last_payment_timestamp, *&timestamp);
      Vector::swap_remove(&mut r.last_payment_timestamp, i);

      Vector::push_back(&mut r.last_payment_value, *&value);
      Vector::swap_remove(&mut r.last_payment_value, i);

      Vector::push_back(&mut r.cumulative, *&cumu);
      Vector::swap_remove(&mut r.cumulative, i);
      (timestamp, value, cumu)
  }

    public fun read_receipt(account: address, destination: address):(u64, u64, u64) acquires UserReceipts {
      let r = borrow_global<UserReceipts>(account);
      let (_, i) = Vector::index_of(&r.destination, &destination);

      let time = Vector::borrow<u64>(&r.last_payment_timestamp, i);
      let value = Vector::borrow<u64>(&r.last_payment_value, i);
      let cumu = Vector::borrow<u64>(&r.cumulative, i);

      (*time, *value, *cumu)
    }
}
}