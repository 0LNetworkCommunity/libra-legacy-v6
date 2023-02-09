/////////////////////////////////////////////////////////////////////////
// 0L Module
// Proof of Fee
/////////////////////////////////////////////////////////////////////////
// NOTE: this module replaces NodeWeight.move, which becomes redundant since
// all validators have equal weight in consensus. 
// TODO: the bubble sort functions were lifted directly from NodeWeight, needs checking.
///////////////////////////////////////////////////////////////////////////

//// V6 ////
address DiemFramework {
  module ProofOfFee {
    use Std::Errors;
    use DiemFramework::DiemConfig;
    // use DiemFramework::ValidatorConfig;
    use Std::Signer;
    use DiemFramework::ValidatorUniverse;
    use Std::Vector;
    use DiemFramework::Jail;
    // use DiemFramework::DiemAccount;
    use DiemFramework::Debug::print;
    use DiemFramework::Vouch;

    const ENOT_AN_ACTIVE_VALIDATOR: u64 = 190022;
    // A struct on the validators account which indicates their
    // latest bid (and epoch)
    struct ProofOfFeeAuction has key {
      bid: u64,
      epoch: u64
    }

    // CONSENSUS CRITICAL 
    // ALL EYES ON THIS
    // Proof of Fee returns the current bid of the validator during the auction for upcoming epoch seats.
    public fun current_bid(node_addr: address): u64 acquires ProofOfFeeAuction {
      if (exists<ProofOfFeeAuction>(node_addr)) {
        let pof = borrow_global<ProofOfFeeAuction>(node_addr);
        let e = DiemConfig::get_current_epoch();
        if (pof.epoch == e) {
          return pof.bid
        };
      };
      return 0
    }

    // validator can set a bid. See transaction script below.
    public fun set_bid(account_sig: &signer, bid: u64) acquires ProofOfFeeAuction {
      let acc = Signer::address_of(account_sig);
      if (!exists<ProofOfFeeAuction>(acc)) {
        init(account_sig);
      };
      let pof = borrow_global_mut<ProofOfFeeAuction>(acc);
      pof.epoch = DiemConfig::get_current_epoch();
      pof.bid = bid;
    }

    public fun init(account_sig: &signer) {
      // TODO: check if this is a validator.
      
      let acc = Signer::address_of(account_sig);
      assert!(ValidatorUniverse::is_in_universe(addr), Errors::requires_role(ENOT_AN_ACTIVE_VALIDATOR));

      if (!exists<ProofOfFeeAuction>(acc)) {
        move_to<ProofOfFeeAuction>(
        account_sig, 
          ProofOfFeeAuction {
            bid: 0,
            epoch: 0 
          }
        );
      }
    }



    // Get the top N validators for the next round.
    // TODO: there's a known issue when many validators have the exact same
    // bid, the preferred node  will be the one LAST included in the validator universe.
    public fun top_n_accounts(account: &signer, n: u64): vector<address> acquires ProofOfFeeAuction {
        assert!(Signer::address_of(account) == @DiemRoot, Errors::requires_role(140101));

        let eligible_validators = get_sorted_vals();
        let len = Vector::length<address>(&eligible_validators);
        if(len <= n) return eligible_validators;

        let diff = len - n; 
        while(diff > 0){
          Vector::pop_back(&mut eligible_validators);
          diff = diff - 1;
        };

        eligible_validators
    }
    
    // get the validator universe sorted by bid
    // Function code: 01 Prefix: 140101
    // Permissions: Public, VM Only
    public fun get_sorted_vals(): vector<address> acquires ProofOfFeeAuction {
      let eligible_validators = ValidatorUniverse::get_eligible_validators();
      let length = Vector::length<address>(&eligible_validators);
      // Vector to store each address's node_weight
      let weights = Vector::empty<u64>();
      let k = 0;
      while (k < length) {

        let cur_address = *Vector::borrow<address>(&eligible_validators, k);
        // Ensure that this address is an active validator
        Vector::push_back<u64>(&mut weights, current_bid(cur_address));
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

      return eligible_validators
    }

    // here we place the bidders into their seats
    // the order of the bids will determine placement.
    // one important aspect of picking the next validator set:
    // it should have 2/3rds of known good ("proven") validators
    // from the previous epoch. Otherwise the unproven nodes, who
    // may not be ready for consensus may be offline and cause a halt.
    // So the selection algorithm needs to stop filling seats with unproven
    // validators if the max unproven nodes limit is hit (1/3).

    // TODO: the paper does not specify what happens with the Jail reputation
    // of a validator. E.g. if a validator has a bid with no expiry
    // but has a bad jail reputation does this penalize in the ordering?
    
    // TODO: need to filter by Vouches
    public fun fill_seats_and_get_price(set_size: u64, proven_nodes: &vector<address>): (vector<address>, u64) acquires ProofOfFeeAuction {
      let seats_to_fill = Vector::empty<address>();
      // print(&set_size);
      let max_unproven = set_size / 3;

      let num_unproven_added = 0;

      let sorted_vals_by_bid = get_sorted_vals();

      // print(&sorted_vals_by_bid);

      let i = 0u64;
      while (
        (i < set_size) && 
        (i < Vector::length(&sorted_vals_by_bid))
      ) {
        // print(&i);
        let val = Vector::borrow(&sorted_vals_by_bid, i);
        // fail fast if the validator is jailed.
        // NOTE: epoch reconfigure needs to reset the jail
        // before calling the proof of fee.
        if (Jail::is_jailed(*val)) continue;

        if (!Vouch::unrelated_buddies_above_thresh(*val)) continue;

        // check if a proven node
        if (Vector::contains(proven_nodes, val)) {
          // print(&01);
          Vector::push_back(&mut seats_to_fill, *val);
        } else {
          // print(&02);
          // for unproven nodes, push it to list if we haven't hit limit
          if (num_unproven_added < max_unproven ) {
            // print(&03);
            Vector::push_back(&mut seats_to_fill, *val);
          };
          // print(&04);
          num_unproven_added = num_unproven_added + 1;
        };
        i = i + 1;
      };
      // print(&05);
      print(&seats_to_fill);

      let lowest_bidder = Vector::borrow(&seats_to_fill, Vector::length(&seats_to_fill) - 1);

      let lowest_bid = current_bid(*lowest_bidder);
      return (seats_to_fill, lowest_bid)
    }




    ////////// TRANSACTION APIS //////////
    // manually init the struct, fallback in case of migration fail
    public(script) fun init_bidding(sender: signer) {
      init(&sender);
    }

    // update the bid for the sender
    public(script) fun update_pof_bid(sender: signer, bid: u64) acquires ProofOfFeeAuction {
      // init just for safety
      init(&sender);
      // update the bid
      set_bid(&sender, bid);
    }
  }
}


