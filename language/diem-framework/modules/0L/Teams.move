///////////////////////////////////////////////////////////////////////////
// 0L Module
// Teams 
///////////////////////////////////////////////////////////////////////////
// Used for coordinating "Teams", equivalent to delegation
// Teams are groups which engage in work.
// some of that work is automated such as validation.
// A Team has a collective "consensus weight", which is used for voting in consensus
// but also for stdlib upgrades.
// Team members can share in a validator's rewards, but can also be used for coordinating
// other activity, like projects and bounties.
// File Prefix for errors: TBD
///////////////////////////////////////////////////////////////////////////

address 0x1 {
module Teams {
    use 0x1::CoreAddresses;
    use 0x1::Vector;
    use 0x1::Signer;
    use 0x1::DiemAccount;

    const ENOT_SLOW_WALLET: u64 = 1010;
    
    struct AllTeams has key, copy, drop, store {
      teams_list: vector<address>, // the team is identified by its captain.

    }

    struct Team has key, copy, drop, store {
      captain: address, // A validator account.
      team_name: vector<u8>, // A validator account.
      members: vector<address>,
      operator_pct_reward: u64, // the percentage of the rewards that the captain proposes to go to the validator operator.
      tribal_tower_height_this_epoch: u64,
    }

    // this struct is stored in the member's account
    struct Member has key, copy, drop, store {
      captain_address: address, // by address of captain
      mining_above_threshold: bool, // if the mining the user has done is above the system threshold to count toward delegation.

    }

    public fun vm_init(sender: &signer) {
      CoreAddresses::assert_vm(sender);
      move_to<AllTeams>(
        sender, 
        AllTeams {
          teams_list: Vector::empty()
        }
      );
    }


    public fun team_init(sender: &signer, team_name: vector<u8>, operator_pct_reward: u64) {
      // An "captain", who is already a validator account, stores the Team struct on their account.
      // the AllTeams struct is saved in the 0x0 account, and needs to be initialized before this is called.

      // check vm has initialized the struct, otherwise exit early.
      if (!exists<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS())) {
        return
    };

    move_to<Team>(
        sender, 
        Team {
          captain: Signer::address_of(sender), // A validator account.
          team_name, // A validator account.
          members: Vector::empty<address>(),
          operator_pct_reward, // the percentage of the rewards that the captain proposes to go to the validator operator.
          tribal_tower_height_this_epoch: 0,
        }
      );
    }

    public fun join_team(sender: &signer, captain_address: address) acquires Member {
      let addr = Signer::address_of(sender);

      // needs to check if this is a slow wallet.
      // ask user to resubmit if not a slow wallet, so they are explicitly setting it, no surprises, no tears.

     assert(DiemAccount::is_slow(addr), ENOT_SLOW_WALLET);
        

      // bob wants to switch to a different Team.
      if (exists<Member>(addr)) {
        let s = borrow_global_mut<Member>(addr);
        s.captain_address = captain_address;
        // TODO: Do we need to reset mining_above_threshold if they are switching?
      } else { // first time joining a Team.
        move_to<Member>(sender, Member {
          captain_address,
          mining_above_threshold: false,
        }) 
      }
    }


    //////// GETTERS ////////

    public fun get_all_teams(): vector<address> acquires AllTeams {
      if (exists<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS())) {
        let list = borrow_global<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS());
        return *&list.teams_list
      } else {
        Vector::empty<address>()
      }
    }

    public fun team_is_init(captain: address): bool {
      exists<Team>(captain)
    }

    // NOTE: Important! The EpochBoundary will call this. This function cannot abort, must not halt consensus.
    public fun get_operator_reward(captain: address):u64 acquires Team {
      if (team_is_init(captain)) {
        let s = borrow_global_mut<Team>(captain);
        return *&s.operator_pct_reward
      };
      0
    }
    // find the team members
    public fun get_team_members(captain: address):vector<address> acquires Team {
      if (team_is_init(captain)) {
        let s = borrow_global_mut<Team>(captain);
        return *&s.members
      };
      Vector::empty<address>()
    }

    public fun vm_is_init(): bool {
      exists<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS())
    }
}

// Module for initializing Teams on a hot upgrade of stdlib.
// since the system is likely operating and Teams are introduced as an upgrade, the structs need to be initalized.

module MigrateInitDelegation {
  use 0x1::Teams;
  use 0x1::Migrations;
  const UID: u64 = 101;
  public fun do_it(vm: &signer) {
    if (!Migrations::has_run(UID)) {
      Teams::vm_init(vm);
      Migrations::push(vm, UID, b"MigrateInitTeams");
    }
  }
}
}

