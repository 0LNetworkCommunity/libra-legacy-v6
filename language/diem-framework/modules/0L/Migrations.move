///////////////////////////////////////////////////////////////////
// 0L Module
// Globals
// Error code: 0710
///////////////////////////////////////////////////////////////////

address 0x1 {

/// # Summary 
/// This module is used to record migrations from old versions of stdlib to new 
/// versions when a breaking change is introduced (e.g. a resource is altered)
/// The code for the actual migrations is instantiated in seperate modules. 
/// When running a migration, one must: 
/// 1. check it has not been run using the `has_run` function 
/// 2. run the migration 
/// 3. record that the migration has run using the `push` function
module Migrations {
  use 0x1::Vector;
  use 0x1::CoreAddresses;
  use 0x1::Option::{Self,Option};

  /// A list of Migrations that have been 
  /// Note: Used ids are (add to this list when needed): 1, 10, 11, ...
  struct Migrations has key {
    list: vector<Job>
  }

  /// A specific Migration (e.g. altering a struct)
  /// `uid` is a unique identifier for the migration, selected by the vm 
  /// `name` is for reference purposes only and is not used by the module 
  /// to distinguish between migrations
  struct Job has copy, drop, store {
    uid: u64,
    name: vector<u8>, // experiment with using text labels
  }

  /// initialize the Migrations structure
  public fun init(vm: &signer){
    CoreAddresses::assert_diem_root(vm);
    if (!exists<Migrations>(@0x0)) {
      move_to<Migrations>(vm, Migrations {
        list: Vector::empty<Job>(),
      })
    }
  }

  /// Returns true if a migration has been added to the Migrations list
  public fun has_run(uid: u64): bool acquires Migrations {
    let opt_job = find(uid);
    if (Option::is_some<Job>(&opt_job)) {
      true
    }
    else {
      false
    }
  }

  /// Adds a job to the migrations list if it has not been added already
  /// Only the vm can add a job to this list in order to prevent others from 
  /// preventing a migration by inserting the migration's UID to this list 
  /// before it occurs
  public fun push(vm: &signer, uid: u64, text: vector<u8>) acquires Migrations {   
    CoreAddresses::assert_diem_root(vm);
    if (has_run(uid)) return;
    let s = borrow_global_mut<Migrations>(@0x0);
    let j = Job {
      uid: uid,
      name: text,
    };

    Vector::push_back<Job>(&mut s.list, j);
  }

  /// Searches for a job within the Migrations list, returns `some` if 
  /// is found, returns `none` otherwise
  fun find(uid: u64): Option<Job> acquires Migrations {
    let job_list = &borrow_global<Migrations>(@0x0).list;
    let len = Vector::length(job_list);
    let i = 0;
    while (i < len) {
      let j = *Vector::borrow<Job>(job_list, i);
      if (j.uid == uid) {
        return Option::some<Job>(j)
      };
      i = i + 1;
    };
    Option::none<Job>()
  }
}

/// # Summary 
/// Module to make whole underpaid Carpe users
module MigrateMakeWhole{
  use 0x1::Migrations;
  use 0x1::DiemAccount;
  use 0x1::Vector;
  use 0x1::CoreAddresses;
  use 0x1::GAS::GAS;
  use 0x1::Diem;

  const UID:u64 = 11;
  

  // I've split this into two pieces to ease testing. 
  public fun migrate_make_whole(vm: &signer){
    CoreAddresses::assert_diem_root(vm);
    if (!Migrations::has_run(UID)) {
      let payees: vector<address> = Vector::empty<address>();
      let amounts: vector<u64> = Vector::empty<u64>();

      // TODO: A new address and amount must be pushed back for each miner that needs to be repaid
      // This can be done more easily in more recent version of move, but it seems 0L currently does not support them. 
      Vector::push_back<address>(&mut payees, @0x01);
      Vector::push_back<u64>(&mut amounts, 10);

      Vector::push_back<address>(&mut payees, @0x02);
      Vector::push_back<u64>(&mut amounts, 20);

      make_whole(vm, &payees, &amounts);
    };
  }
  
  /// Pays payees[i] amounts[i] GAS in order to make whole carpe users
  public fun make_whole(vm: &signer, payees: &vector<address>, amounts: &vector<u64>) {
    CoreAddresses::assert_diem_root(vm);
    if (!Migrations::has_run(UID)) {
      let size = Vector::length<address>(payees);
      if (size != Vector::length<u64>(amounts)) {
        // something has been implemented wrong, don't complete the payout 
        // don't abort either though as that would halt the network
        return
      };

      // mint the coins and deposit after ensuring miner can accept GAS
      let i = 0;
      while (i < size) {
        if (DiemAccount::accepts_currency<GAS>(*Vector::borrow<address>(payees, i))){ 
          let minted_coins = Diem::mint<GAS>(vm, *Vector::borrow<u64>(amounts, i));
          DiemAccount::vm_deposit_with_metadata<GAS>(
            vm,
            *Vector::borrow<address>(payees, i),
            minted_coins,
            b"carpe miner make whole",
            b""
          );
        };

        i = i + 1;
      };

      //record that the migration has completed so as to not run it twice
      Migrations::push(vm, UID, b"MigrateMakeWhole");
    };
  }

}


}