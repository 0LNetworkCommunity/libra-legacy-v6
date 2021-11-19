///////////////////////////////////////////////////////////////////////////
// 0L Module
// Teams 
///////////////////////////////////////////////////////////////////////////
// Used for coordinating "tribes", equivalent to delegation 
// Tribes are teams which engage in work.
// some of that work is automated such as validation.
// Trive members can share in a validator's rewards, but can also be used for coordinating
// other activity, like projects and bounties
// File Prefix for errors: TBD
///////////////////////////////////////////////////////////////////////////

address 0x1 {
module Delegation {
    use 0x1::CoreAddresses;
    use 0x1::Vector;
    use 0x1::Signer;
    
    struct AllTribes has key, copy, drop, store {
      teams_by_elder: vector<address>, // the team is identified by its captain.

    }

    struct Tribe has key, copy, drop, store {
      elder: address, // A validator account.
      tribe_name: vector<u8>, // A validator account.
      members: vector<address>,
      operator_pct_bonus: u64, // the percentage of the rewards that the captain proposes to go to the validator operator.
      tribal_tower_height_this_epoch: u64,
    }

    // this struct is stored in the member's account
    struct Member has copy, drop, store {
      my_tribe_elder: address, // by address of elder
      mining_above_threshold: bool, // if the mining the user has done is above the system threshold to count toward delegation.

    }

    public fun vm_init(sender: &signer) {
      CoreAddresses::assert_vm(sender);
      move_to<AllTribes>(
        sender, 
        AllTribes {
          teams_by_elder: Vector::empty()
        }
      );
    }


    public fun elder_init(sender: &signer, tribe_name: vector<u8>, operator_pct_bonus: u64) {
      // An Elder, who is already a validator account, stores the Tribe struct on their account.
      // the AllTeams struct is saved in the 0x0 account, and needs to be initialized before this is called.

      // check vm has initialized the struct, otherwise exit early.
      if (!exists<AllTribes>(CoreAddresses::VM_RESERVED_ADDRESS())) {
        return
    };

    move_to<Tribe>(
        sender, 
        Tribe {
          elder: Signer::address_of(sender), // A validator account.
          tribe_name, // A validator account.
          members: Vector::empty<address>(),
          operator_pct_bonus, // the percentage of the rewards that the captain proposes to go to the validator operator.
          tribal_tower_height_this_epoch: 0,
        }
      );
    }
}
}