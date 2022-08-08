///////////////////////////////////////////////////////////////////
// 0L Module
// Globals
// Error code: 0710
///////////////////////////////////////////////////////////////////

address DiemFramework {

/// # Summary 
/// This module is used to record migrations from old versions of stdlib to new 
/// versions when a breaking change is introduced (e.g. a resource is altered)
/// The code for the actual migrations is instantiated in seperate modules. 
/// When running a migration, one must: 
/// 1. check it has not been run using the `has_run` function 
/// 2. run the migration 
/// 3. record that the migration has run using the `push` function
module Migrations {
  use Std::Vector;
  use DiemFramework::CoreAddresses;
  use Std::Option::{Self,Option};

  /// A list of Migrations that have been 
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
/// Initializes the Jail structs
module MigrateJail {
  use DiemFramework::ValidatorUniverse;
  use DiemFramework::Jail;
  use DiemFramework::DiemAccount;
  use DiemFramework::CoreAddresses;
  use Std::Vector;
  use DiemFramework::Migrations;

  const UID:u64 = 4;
  // Migration to migrate all wallets to be slow wallets
  public fun do_it(vm: &signer) {
    CoreAddresses::assert_diem_root(vm);
    if (!Migrations::has_run(UID)) {
      let enabled_accounts = ValidatorUniverse::get_eligible_validators();
      let i = 0;
      let len = Vector::length<address>(&enabled_accounts);
      while (i < len) {
        let addr = Vector::borrow(&enabled_accounts, i);
        let account_sig = DiemAccount::scary_create_signer_for_migrations(vm, *addr);
        Jail::init(&account_sig);
        i = i + 1;
      };


      Migrations::push(vm, UID, b"MigrateJail");
    };
  }
}
}

/////////////////////////////////////////////////////
// # LEAVE HERE FOR REFERENCE. Previous Migrations //
/////////////////////////////////////////////////////

// // # Summary 
// // Module to migrate the tower statistics from TowerState to TowerCounter
// module MigrateTowerCounter {
//   use 0x1::TowerState;
//   use 0x1::Migrations;
//   use 0x1::CoreAddresses;

//   const UID:u64 = 1;
//   // Migration to migrate all wallets to be slow wallets
//   public fun migrate_tower_counter(vm: &signer) {
//     CoreAddresses::assert_diem_root(vm);
//     if (!Migrations::has_run(UID)) {
//       let (global, val, fn) = TowerState::danger_migrate_get_lifetime_proof_count();
//       TowerState::init_tower_counter(vm, global, val, fn);
//       Migrations::push(vm, UID, b"MigrateTowerCounter");
//     };
//   }

// }

// Module to migrate the tower statistics from TowerState to TowerCounter
// module MigrateAutoPayBal {
//   use 0x1::AutoPay;
//   use 0x1::DiemAccount;
//   use 0x1::CoreAddresses;
//   use 0x1::Vector;
//   use 0x1::Migrations;

//   const UID:u64 = 2;
//   // Migration to migrate all wallets to be slow wallets
//   public fun do_it(vm: &signer) {
//     CoreAddresses::assert_diem_root(vm);
//     if (!Migrations::has_run(UID)) {
//       let enabled_accounts = AutoPay::get_enabled();
//       let i = 0;
//       let len = Vector::length<address>(&enabled_accounts);
//       while (i < len) {
//         let addr = Vector::borrow(&enabled_accounts, i);
//         let account_sig = DiemAccount::scary_create_signer_for_migrations(vm, *addr);
//         AutoPay::enable_autopay(&account_sig);
//         AutoPay::migrate_instructions(&account_sig);

//         i = i + 1;
//       };


//       Migrations::push(vm, UID, b"MigrateAutoPayBal");
//     };
//   }
// }


// // # Here for reference
// // Initializes the Vouch structs
// module MigrateVouch {
//   use 0x1::ValidatorUniverse;
//   use 0x1::Vouch;
//   use 0x1::DiemAccount;
//   use 0x1::CoreAddresses;
//   use 0x1::Vector;
//   use 0x1::Migrations;

//   const UID:u64 = 3;
//   // Migration to migrate all wallets to be slow wallets
//   public fun do_it(vm: &signer) {
//     CoreAddresses::assert_diem_root(vm);
//     if (!Migrations::has_run(UID)) {
//       let enabled_accounts = ValidatorUniverse::get_eligible_validators(vm);
//       let i = 0;
//       let len = Vector::length<address>(&enabled_accounts);
//       while (i < len) {
//         let addr = Vector::borrow(&enabled_accounts, i);
//         let account_sig = DiemAccount::scary_create_signer_for_migrations(vm, *addr);
//         Vouch::init(&account_sig);
//         i = i + 1;
//       };


//       Migrations::push(vm, UID, b"MigrateVouch");
//     };
//   }
// }