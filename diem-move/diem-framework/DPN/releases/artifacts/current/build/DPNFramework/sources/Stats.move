/////////////////////////////////////////////////////////////////////////
// 0L Module
// Stats Module
// Error code: 1900
/////////////////////////////////////////////////////////////////////////

address DiemFramework{
module Stats{
  use Std::Errors;
  use Std::FixedPoint32;
  use Std::Signer;
  use DiemFramework::Testnet;
  use Std::Vector;
  use DiemFramework::Globals;

  // TODO: yes we know this slows down block production. In "make it fast"
  // mode this will be moved to Rust, in the vm execution block prologue. TBD.
  
  struct SetData has copy, drop, store {
    addr: vector<address>,
    prop_count: vector<u64>,
    vote_count: vector<u64>,
    total_votes: u64,
    total_props: u64,
  }

  struct ValStats has copy, drop, key {
    history: vector<SetData>,
    current: SetData
  }

  //Permissions: Public, VM only.
  //Function: 01
  public fun initialize(vm: &signer) {
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190001));
    move_to<ValStats>(
      vm, 
      ValStats {
        history: Vector::empty(),
        current: blank()
      }
    );
  }
  
  fun blank():SetData {
    SetData {
      addr: Vector::empty(),
      prop_count: Vector::empty(),
      vote_count: Vector::empty(),
      total_votes: 0,
      total_props: 0,
    }
  }

  //Permissions: Public, VM only.
  //Function: 02
  public fun init_address(vm: &signer, node_addr: address) acquires ValStats {
    let sender = Signer::address_of(vm);

    assert!(sender == @DiemRoot, Errors::requires_role(190002));

    let stats = borrow_global<ValStats>(sender);
    let (is_init, _) = Vector::index_of<address>(&stats.current.addr, &node_addr);
    if (!is_init) {
      let stats = borrow_global_mut<ValStats>(sender);
      Vector::push_back(&mut stats.current.addr, node_addr);
      Vector::push_back(&mut stats.current.prop_count, 0);
      Vector::push_back(&mut stats.current.vote_count, 0);
    }
  }

  //Function: 03
  public fun init_set(vm: &signer, set: &vector<address>) acquires ValStats{
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190003));
    let length = Vector::length<address>(set);
    let k = 0;
    while (k < length) {
      let node_address = *(Vector::borrow<address>(set, k));
      init_address(vm, node_address);
      k = k + 1;
    }
  }

  //Function: 04
  public fun process_set_votes(vm: &signer, set: &vector<address>) acquires ValStats{
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190004));

    let length = Vector::length<address>(set);
    let k = 0;
    while (k < length) {
      let node_address = *(Vector::borrow<address>(set, k));
      inc_vote(vm, node_address);
      k = k + 1;
    }
  }

  //Permissions: Public, VM only.
  //Function: 05
  public fun node_current_votes(vm: &signer, node_addr: address): u64 acquires ValStats {
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190005));
    let stats = borrow_global_mut<ValStats>(sender);
    let (is_found, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
    if (is_found) return *Vector::borrow<u64>(&mut stats.current.vote_count, i)
    else 0
  }

  //Function: 06
  public fun node_above_thresh(
    vm: &signer, node_addr: address, height_start: u64, height_end: u64
  ): bool acquires ValStats{
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190006));
    let range = height_end-height_start;
    // TODO: Change to 5 percent
    let threshold_signing = FixedPoint32::multiply_u64(
      range, 
      FixedPoint32::create_from_rational(Globals::get_signing_threshold(), 100)
    );
    if (node_current_votes(vm, node_addr) >  threshold_signing) { return true };
    return false
  }

  //Function: 07
  public fun network_density(
    vm: &signer, height_start: u64, height_end: u64
  ): u64 acquires ValStats {
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190007));
    let density = 0u64;
    let nodes = *&(borrow_global_mut<ValStats>(sender).current.addr);
    let len = Vector::length(&nodes);
    let k = 0;
    while (k < len) {
      let addr = *(Vector::borrow<address>(&nodes, k));
      if (node_above_thresh(vm, addr, height_start, height_end)) {
        density = density + 1;
      };
      k = k + 1;
    };
    return density
  }

  //Permissions: Public, VM only.
  //Function: 08    
  public fun node_current_props(vm: &signer, node_addr: address): u64 acquires ValStats {
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190008));
    let stats = borrow_global_mut<ValStats>(sender);
    let (is_found, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
    if (is_found) return *Vector::borrow<u64>(&mut stats.current.prop_count, i)
    else 0
  }

  //Permissions: Public, VM only.
  //Function: 09
  public fun inc_prop(vm: &signer, node_addr: address) acquires ValStats {
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190009));
    let stats = borrow_global_mut<ValStats>(@DiemRoot);
    let (is_true, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
    // don't try to increment if no state. This has caused issues in the past
    // in emergency recovery.

    if (is_true) {
      let current_count = *Vector::borrow<u64>(&mut stats.current.prop_count, i);
      Vector::push_back(&mut stats.current.prop_count, current_count + 1);
      Vector::swap_remove(&mut stats.current.prop_count, i);
    };

    stats.current.total_props = stats.current.total_props + 1;
  }
  
  //TODO: Duplicate code.
  //Permissions: Public, VM only.
  //Function: 10
  fun inc_vote(vm: &signer, node_addr: address) acquires ValStats {
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190010));
    let stats = borrow_global_mut<ValStats>(sender);
    let (is_true, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
    if (is_true) {
      let test = *Vector::borrow<u64>(&mut stats.current.vote_count, i);
      Vector::push_back(&mut stats.current.vote_count, test + 1);
      Vector::swap_remove(&mut stats.current.vote_count, i);
    } else {
      // debugging rescue mission. Remove after network stabilizes Apr 2022.
      // something bad happened and we can't find this node in our list.
      // print(&666);
      // print(&node_addr);
    };
    // update total vote count anyways even if we can't find this person.
    stats.current.total_votes = stats.current.total_votes + 1;
    // print(&stats.current);
  }

  //Permissions: Public, VM only.
  //Function: 11
  public fun reconfig(vm: &signer, set: &vector<address>) acquires ValStats {
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190011));
    let stats = borrow_global_mut<ValStats>(sender);
    
    // Keep only the most recent epoch stats
    if (Vector::length(&stats.history) > 7) {
      Vector::pop_back<SetData>(&mut stats.history); // just drop last record
    };
    Vector::push_back(&mut stats.history, *&stats.current);
    stats.current = blank();
    init_set(vm, set);
  }

  //Function: 12
  public fun get_total_votes(vm: &signer): u64 acquires ValStats {
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190012));
    *&borrow_global<ValStats>(@DiemRoot).current.total_votes
  }

  //Function: 13
  public fun get_total_props(vm: &signer): u64 acquires ValStats {
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190013));
    *&borrow_global<ValStats>(@DiemRoot).current.total_props
  }

  //Function: 14
  public fun get_history(): vector<SetData> acquires ValStats {
    *&borrow_global<ValStats>(@DiemRoot).history
  }

  /// TEST HELPERS
  //Function: 15
  public fun test_helper_inc_vote_addr(vm: &signer, node_addr: address) acquires ValStats {
    let sender = Signer::address_of(vm);
    assert!(sender == @DiemRoot, Errors::requires_role(190015));
    assert!(Testnet::is_testnet(), Errors::invalid_state(190015));

    inc_vote(vm, node_addr);
  }

  // TODO: this code is duplicated with NodeWeight, opportunity to make sorting in to a module.
  public fun get_sorted_vals_by_props(account: &signer, n: u64): vector<address> acquires ValStats {
      assert!(Signer::address_of(account) == @DiemRoot, Errors::requires_role(140101));

      //Get all validators from Validator Universe and then find the eligible validators 
      let eligible_validators = 
      *&borrow_global<ValStats>(@DiemRoot).current.addr;

      let length = Vector::length<address>(&eligible_validators);

      // Scenario: The universe of validators is under the limit of the BFT consensus.
      // If n is greater than or equal to accounts vector length - return the vector.
      if(length <= n) return eligible_validators;

      // Vector to store each address's node_weight
      let weights = Vector::empty<u64>();
      let k = 0;
      while (k < length) {

        let cur_address = *Vector::borrow<address>(&eligible_validators, k);
        // Ensure that this address is an active validator
        Vector::push_back<u64>(&mut weights, node_current_props(account, cur_address));
        k = k + 1;
      };

      // Sorting the accounts vector based on value (weights).
      // Bubble sort algorithm
      let i = 0;
      while (i < length){
        let j = 0;
        while(j < length-i-1){
          let value_j = *(Vector::borrow<u64>(&weights, j));
          let value_jp1 = *(Vector::borrow<u64>(&weights, j+1));
          if(value_j > value_jp1){
            Vector::swap<u64>(&mut weights, j, j+1);
            Vector::swap<address>(&mut eligible_validators, j, j+1);
          };
          j = j + 1;
        };
        i = i + 1;
      };

      // Reverse to have sorted order - high to low.
      Vector::reverse<address>(&mut eligible_validators);

      let diff = length - n; 
      while(diff>0){
        Vector::pop_back(&mut eligible_validators);
        diff =  diff - 1;
      };

      return eligible_validators
    }
}
}