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
    use 0x1::TowerState;
    use 0x1::Vector;
    use 0x1::Signer;
    use 0x1::DiemAccount;
    use 0x1::ValidatorUniverse;
    use 0x1::Decimal;

    const ENOT_SLOW_WALLET: u64 = 1010;
    
    struct AllTeams has key, copy, drop, store {
      teams_list: vector<address>, // the team is identified by its captain.
      collective_threshold_epoch: u64,
      member_threshold_epoch: u64,
      tower_height_rms: u64,

    }

    struct Team has key, copy, drop, store {
      captain: address, // A validator account. TODO this is redundant, since it is stored in the validator account. But placed here for future-proofing.
      members: vector<address>,
      operator_pct_reward: u64, // the percentage of the rewards that the captain proposes to go to the validator operator.
      collective_tower_height_this_epoch: u64,

      // Informational fields
      team_name: vector<u8>, // A validator account.
      description: vector<u8>,
      count_all_members: u64, // count the miners who have expressed to me members of this team, but may be below threshold
      count_active: u64, // the count of players above threshold

      // Is team in validator set
    }

    // this struct is stored in the member's account
    struct Member has key, copy, drop, store {
      captain_address: address, // by address of captain
      mining_above_threshold: bool, // if the mining the user has done is above the system threshold to count toward delegation.

    }

    public fun vm_init(sender: &signer) {
      CoreAddresses::assert_vm(sender);
      if (!exists<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS())) {
        move_to<AllTeams>(
          sender, 
          AllTeams {
            teams_list: Vector::empty(),
            collective_threshold_epoch: 0,
            member_threshold_epoch: 0,
            tower_height_rms: 0,
          }
        );
      }
    }


    public fun team_init(sender: &signer, team_name: vector<u8>, operator_pct_reward: u64) {

      assert(ValidatorUniverse::is_in_universe(Signer::address_of(sender)), 201301001);
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
          members: Vector::empty<address>(),
          operator_pct_reward, // the percentage of the rewards that the captain proposes to go to the validator operator.
          collective_tower_height_this_epoch: 0,

          team_name, // A validator account.
          description: Vector::empty<u8>(), // TODO: Change this
          count_all_members: 0,
          count_active: 0,

        }
      );
    }

    public fun join_team(sender: &signer, captain_address: address) acquires Member, Team {
      let addr = Signer::address_of(sender);

      // needs to check if this is a slow wallet.
      // ask user to resubmit if not a slow wallet, so they are explicitly setting it, no surprises, no tears.

      assert(DiemAccount::is_slow(addr), ENOT_SLOW_WALLET);
        

      // bob wants to switch to a different Team.
      if (exists<Member>(addr)) {
        let member_state = borrow_global_mut<Member>(addr);
        // update the membership list of the former captain
        let former_captain_state = borrow_global_mut<Team>(member_state.captain_address);
        let (is_found, idx) = Vector::index_of(&former_captain_state.members, &addr);
        if (is_found) {
          Vector::remove(&mut former_captain_state.members, idx);
          member_state.captain_address = captain_address;
        };        
        // TODO: Do we need to reset mining_above_threshold if they are switching?
      } else { // first time joining a Team.
        move_to<Member>(sender, Member {
          captain_address,
          mining_above_threshold: false,
        });
      };
      let captain_state = borrow_global_mut<Team>(captain_address);
      Vector::push_back<address>(&mut captain_state.members, addr);
    }

    // triggered on Epoch B each time the miner submits a new proof.
    // as the epoch progresses and a miner's epoch proof count is above the threshold
    // then assign the member to the team's list for payment at the end of the epoch.
    // assign members to teams, and return the threshold that they had to clear.
    fun lazy_assign_member_to_teams(_miner: address): u64 {
      
      0
    }

    use 0x1::Debug::print;

    public fun find_rms_of_towers(vm: &signer): u64 acquires AllTeams {
      CoreAddresses::assert_vm(vm);
      let miner_list = TowerState::get_miner_list();
      let len = Vector::length<address>(&miner_list);

      // 1. sum the squares
      let sum_squares = 0;

      let i = 0;
      while (i < len)  {
        let addr = Vector::borrow(&miner_list, i);
        let count = TowerState::get_count_in_epoch(*addr);

        sum_squares = sum_squares + (count*count);
        i = i + 1;
      };

      // 2. divide by len
      let divided = sum_squares / len;

      // 3. take square root
      let d = Decimal::new(true, (divided as u128) , 0);
      let rms = Decimal::sqrt(&d);

      let trunc = Decimal::trunc(&rms);
      let (_, int, dec) = Decimal::unwrap(&trunc);

      print(&int);
      print(&dec);

      // let rms = 10;
      let s = borrow_global_mut<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS());
      s.tower_height_rms = (int as u64);
      0
    }



    // // During epoch A, calculate thresholds for epoch B
    // // lazily calculate the new threshold on each miner submission
    // // DANGER
    // // private module which accesses system state.
    // fun lazy_update_teams_member_threshold(): u64 acquires AllTeams {
    //   // minimum threshold should be 2 weeks of proofs
    //   let threshold = 50 * 14; // 50 proofs per day.

    //   // Get total tower height from TowerCounter
    //   let _c = TowerState::get_fullnode_proofs_in_epoch();

    //   // Get total number of miners
    //   let _m = Vector::length<address>(&TowerState::get_miner_list());

    //   let s = borrow_global_mut<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS());

    //   s.member_threshold_epoch = threshold;

    //   threshold
    // }

    // at the end of each epoch iterate through list of validator set
    // check what the average value of captain rewards is
    // increment by a ratchet if above range.
    // decrement if below range
    fun ratchet_collective_threshold(vm: &signer, current_epoch: u64): u64 acquires AllTeams {
      CoreAddresses::assert_vm(vm);

      let ratchet = 10; //todo
      
      let s = borrow_global_mut<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS());

      // safety mechanism, no single account should have enough tower height to be able to enter validator set.
      // the minimum threshold should be 1 + the maximum number of proofs able to be mined from start of network
      let min_thresh = current_epoch * 72;
      if (s.collective_threshold_epoch < min_thresh) {
        s.collective_threshold_epoch = min_thresh;
      };

      s.collective_threshold_epoch = s.collective_threshold_epoch + ratchet;

      *&s.collective_threshold_epoch

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

    public fun member_is_init(member: address): bool {
      exists<Member>(member)
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

    // A member who selected to be part of a captain_team, but has not mined above threshold.
    public fun is_member_above(member: address):bool acquires Member {
      if (member_is_init(member)) {
        let s = borrow_global_mut<Member>(member);
        return s.mining_above_threshold
      };
      false
    }

    public fun vm_is_init(): bool {
      exists<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS())
    }
}
}

