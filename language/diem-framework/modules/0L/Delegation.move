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
    use 0x1::DiemAccount;

    const ENOT_SLOW_WALLET: u64 = 1010;
    
    struct AllTribes has key, copy, drop, store {
      tribes_by_elder: vector<address>, // the team is identified by its captain.

    }

    struct Tribe has key, copy, drop, store {
      elder: address, // A validator account.
      tribe_name: vector<u8>, // A validator account.
      members: vector<address>,
      operator_pct_bonus: u64, // the percentage of the rewards that the captain proposes to go to the validator operator.
      tribal_tower_height_this_epoch: u64,
    }

    // this struct is stored in the member's account
    struct Member has key, copy, drop, store {
      my_tribe_elder: address, // by address of elder
      mining_above_threshold: bool, // if the mining the user has done is above the system threshold to count toward delegation.

    }

    public fun vm_init(sender: &signer) {
      CoreAddresses::assert_vm(sender);
      move_to<AllTribes>(
        sender, 
        AllTribes {
          tribes_by_elder: Vector::empty()
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

    public fun join_tribe(sender: &signer, my_tribe_elder: address) acquires Member {
      let addr = Signer::address_of(sender);

      // needs to check if this is a slow wallet.
      // ask user to resubmit if not a slow wallet, so they are explicitly setting it, no surprises, no tears.

     assert(DiemAccount::is_slow(addr), ENOT_SLOW_WALLET);
        

      // bob wants to switch to a different tribe.
      if (exists<Member>(addr)) {
        let s = borrow_global_mut<Member>(addr);
        s.my_tribe_elder = my_tribe_elder;
        // TODO: Do we need to reset mining_above_threshold if they are switching?
      } else { // first time joining a tribe.
        move_to<Member>(sender, Member {
          my_tribe_elder,
          mining_above_threshold: false,
        }) 
      }
    }


    //////// GETTERS ////////
    public fun get_all_tribes(): vector<address> acquires AllTribes {
      if (exists<AllTribes>(CoreAddresses::VM_RESERVED_ADDRESS())) {
        let list = borrow_global<AllTribes>(CoreAddresses::VM_RESERVED_ADDRESS());
        return *&list.tribes_by_elder
      } else {
        Vector::empty<address>()
      }
    }

    public fun elder_is_init(elder: address): bool {
      exists<Tribe>(elder)
    }

    // NOTE: This cannot halt, the EpochBoundary will call this.
    public fun get_operator_bonus(elder: address):u64 acquires Tribe {
      if (elder_is_init(elder)) {
        let s = borrow_global_mut<Tribe>(elder);
        return *&s.operator_pct_bonus
      } else {
        0
      }
    }

    public fun vm_is_init(): bool {
      exists<AllTribes>(CoreAddresses::VM_RESERVED_ADDRESS())
    }
}
}