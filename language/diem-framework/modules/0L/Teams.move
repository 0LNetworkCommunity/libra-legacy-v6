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
    use 0x1::Testnet;
    use 0x1::Errors;

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
      if (operator_pct_reward < 10 || operator_pct_reward > 100 ) {
        return
      };

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


    // a member states his team's preference.
    // the member only actually joins a team for the purposes of calculating rewards
    // when they do enough mining in a period
    public fun join_team(sender: &signer, new_captain: address) acquires Member, Team {
      let addr = Signer::address_of(sender);
      // needs to check if this is a slow wallet.
      // ask user to resubmit if not a slow wallet, so they are explicitly setting it, no surprises, no tears.

      assert(DiemAccount::is_slow(addr), ENOT_SLOW_WALLET);

      // bob wants to switch to a different Team.
      if (exists<Member>(addr)) {
        let member_state = borrow_global_mut<Member>(addr);
        let old_captain = member_state.captain_address;
        maybe_switch_team(&addr, &new_captain, &old_captain);

        // update the membership list of the former captain
        member_state.captain_address = new_captain;

        
    // TODO: Do we need to reset mining_above_threshold if they are switching?
      } else { // first time joining a Team.
        move_to<Member>(sender, Member {
          captain_address: new_captain,
          mining_above_threshold: false,
        });
      };
    }

    fun maybe_switch_team(miner_addr: &address, new_captain: &address, old_captain: &address) acquires Team {
      
      // search for member, and drop
      let old_team = borrow_global_mut<Team>(*old_captain);
      let (found, i) = Vector::index_of<address>(&old_team.members, miner_addr);
      if (found) {
        Vector::remove(&mut old_team.members, i);
      };

      // join new team
      let new_team = borrow_global_mut<Team>(*new_captain);
      let (found, _) = Vector::index_of<address>(&new_team.members, miner_addr);
      if (!found) {
        Vector::push_back<address>(&mut new_team.members, *miner_addr);
      };
    }

    // triggered on Epoch B each time the miner submits a new proof.
    // as the epoch progresses and a miner's epoch proof count is above the threshold
    // then assign the member to the team's list for payment at the end of the epoch.
    // assign members to teams, and return the threshold that they had to clear.
    public fun maybe_activate_member_to_team(miner_sig: &signer) acquires Member, Team, AllTeams {
      let miner_addr = Signer::address_of(miner_sig);

      // check if user has a team preference
      if (!exists<Member>(miner_addr)) { return };

      let member_state = borrow_global<Member>(miner_addr);

      // Find the user team preference.
      let all_teams = borrow_global<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS());
      let miner_height = TowerState::get_tower_height(miner_addr);
      if (miner_height > all_teams.member_threshold_epoch) {
        let team_state = borrow_global_mut<Team>(member_state.captain_address);

        let v = *&team_state.members;
        let already_there = Vector::contains<address>(&v, &miner_addr);

        if (!already_there) {
          Vector::push_back(&mut v, miner_addr);
          team_state.members = v;
        }
      }
    }

    public fun find_rms_of_towers(vm: &signer): u64 acquires AllTeams {
      CoreAddresses::assert_vm(vm);
      let miner_list = TowerState::get_miner_list();
      let len = Vector::length<address>(&miner_list);

      // 1. sum the squares
      let sum_squares = 0;

      let i = 0;
      while (i < len)  {
        let addr = Vector::borrow(&miner_list, i);
        let count = TowerState::get_tower_height(*addr);

        sum_squares = sum_squares + (count*count);
        i = i + 1;
      };

      // 2. divide by len
      let divided = sum_squares / len;

      // 3. take square root
      let d = Decimal::new(true, (divided as u128) , 0);
      let rms = Decimal::sqrt(&d);

      let trunc = Decimal::trunc(&rms);
      let (_, int, frac) = Decimal::unwrap(&trunc);

      // after truncation the fractional part should be 0
      if (frac > 0) { return 0 };

      if (int > 0) {
        // let rms = 10;
        let s = borrow_global_mut<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS());
        s.tower_height_rms = (int as u64);
        
        return *&s.tower_height_rms
      };

      0
    }

    // take a % of RMS and set the threshold
    public fun set_threshold_as_pct_rms(vm: &signer): u64 acquires AllTeams {
      
      CoreAddresses::assert_vm(vm);

      let s = borrow_global_mut<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS());
      // TODO: decide the final threshold. Using 25% of RMS for simplicity
      let thresh = s.tower_height_rms / 4;

      s.member_threshold_epoch = thresh;

      *&s.member_threshold_epoch
    }

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

    // Is this miner above the individual tower height threshold
    public fun is_member_above_thresh(miner: address):bool acquires AllTeams {
      let c = TowerState::get_tower_height(miner);
      (c > get_member_thresh())
    }

    // what is this epoch's threshold that needs to be met
    public fun get_member_thresh():u64 acquires AllTeams {
      if (exists<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS())) {
        let s = borrow_global_mut<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS());
        return *&s.member_threshold_epoch
      };
      0
    }

    public fun vm_is_init(): bool {
      exists<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS())
    }


    //////// TEST HELPERS ////////

    public fun test_helper_set_thresh(vm: &signer,  thresh: u64) acquires AllTeams {
      assert(Testnet::is_testnet(), Errors::invalid_state(130118));
      CoreAddresses::assert_vm(vm);
      
      let s = borrow_global_mut<AllTeams>(CoreAddresses::VM_RESERVED_ADDRESS());
      s.member_threshold_epoch = thresh;
    }
}
}

