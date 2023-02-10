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
    use DiemFramework::DiemAccount;
    use DiemFramework::Debug::print;
    use DiemFramework::Vouch;

    const ENOT_AN_ACTIVE_VALIDATOR: u64 = 190001;
    const EBID_ABOVE_MAX_PCT: u64 = 190002;

    const GENESIS_BASELINE_REWARD: u64 = 1000000;
    // A struct on the validators account which indicates their
    // latest bid (and epoch)
    struct ProofOfFeeAuction has key {
      bid: u64,
      epoch_expiration: u64,
      // TODO: show past 5 bids
    }

    struct ConsensusReward has key {
      value: u64,
      clearing_price: u64,
      average_winning_bid: u64,
      avg_bid_history: vector<u64>,
    }
    public fun init_genesis_baseline_reward(vm: &signer) {
      if (Signer::address_of(vm) != @VMReserved) return;

      if (!exists<ConsensusReward>(@VMReserved)) {
        move_to<ConsensusReward>(
          vm,
          ConsensusReward {
            value: GENESIS_BASELINE_REWARD,
            clearing_price: 0,
            average_winning_bid: 0,
            avg_bid_history: Vector::empty<u64>(),
          }
        );
      }
    }

    public fun init(account_sig: &signer) {
      
      let acc = Signer::address_of(account_sig);

      assert!(ValidatorUniverse::is_in_universe(acc), Errors::requires_role(ENOT_AN_ACTIVE_VALIDATOR));

      if (!exists<ProofOfFeeAuction>(acc)) {
        move_to<ProofOfFeeAuction>(
        account_sig, 
          ProofOfFeeAuction {
            bid: 0,
            epoch_expiration: 0 
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
        let (bid, _) = current_bid(cur_address);
        Vector::push_back<u64>(&mut weights, bid);
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

    // The Validator must have these funds in their Unlocked account.

    // TODO: the paper does not specify what happens with the Jail reputation
    // of a validator. E.g. if a validator has a bid with no expiry
    // but has a bad jail reputation does this penalize in the ordering?
    
    public fun fill_seats_and_get_price(vm: &signer, set_size: u64, proven_nodes: &vector<address>): (vector<address>, u64) acquires ProofOfFeeAuction, ConsensusReward {
      if (Signer::address_of(vm) != @VMReserved) return (Vector::empty<address>(), 0);

      let baseline_reward = get_consensus_reward();

      let seats_to_fill = Vector::empty<address>();
      // print(&set_size);
      print(&8006010201);
      let max_unproven = set_size / 3;

      let num_unproven_added = 0;

      print(&8006010202);
      let sorted_vals_by_bid = get_sorted_vals();

      let i = 0u64;
      while (
        (i < set_size) && 
        (i < Vector::length(&sorted_vals_by_bid))
      ) {
        // print(&i);
        let val = Vector::borrow(&sorted_vals_by_bid, i);
        let (bid, expire) = current_bid(*val);
        // fail fast if the validator is jailed.
        // NOTE: epoch reconfigure needs to reset the jail
        // before calling the proof of fee.

        // NOTE: I know the multiple i = i+1 is ugly, but debugging
        // is much harder if we have all the checks in one 'if' statement.
        print(&8006010203);
        if (Jail::is_jailed(*val)) { 
          i = i + 1; 
          continue
        };
        print(&8006010204);
        if (!Vouch::unrelated_buddies_above_thresh(*val)) { 
          i = i + 1; 
          continue
        };

        print(&80060102041);
        // skip the user if they don't have sufficient UNLOCKED funds
        // or if the bid expired.

        // belt and suspenders, expiry
        if (DiemConfig::get_current_epoch() > expire) {
          i = i + 1; 
          continue
        };

        let coin_required = bid * baseline_reward;
        if (
          DiemAccount::unlocked_amount(*val) < coin_required
        ) { 
          i = i + 1; 
          continue
        };
        

        // check if a proven node
        if (Vector::contains(proven_nodes, val)) {
          print(&8006010205);
          // print(&01);
          Vector::push_back(&mut seats_to_fill, *val);
        } else {
          print(&8006010206);
          // print(&02);
          // for unproven nodes, push it to list if we haven't hit limit
          if (num_unproven_added < max_unproven ) {
            // print(&03);
            Vector::push_back(&mut seats_to_fill, *val);
          };
          // print(&04);
          print(&8006010207);
          num_unproven_added = num_unproven_added + 1;
        };
        i = i + 1;
      };
      // print(&05);
      print(&8006010208);
      print(&seats_to_fill);

      set_history(vm, &seats_to_fill);

      if (Vector::is_empty(&seats_to_fill)) {
        return (seats_to_fill, 0)
      };

      // Find the clearing price which all validators will pay
      let lowest_bidder = Vector::borrow(&seats_to_fill, Vector::length(&seats_to_fill) - 1);

      let (lowest_bid, _) = current_bid(*lowest_bidder);
      return (seats_to_fill, lowest_bid)
    }

    // Adjust the reward at the end of the epoch
    // as described in the paper, the epoch reward needs to be adjustable
    // given that the implicit bond needs to be sufficient, eg 5-10x the reward.
    public fun reward_thermostat(vm: &signer) acquires ConsensusReward {
      if (Signer::address_of(vm) != @VMReserved) {
        return
      };
      // check the bid history
      // if there are 5 days above 95% adjust the reward up by 5%
      // adjust by more if it has been 10 days then, 10%
      // if there are 5 days below 50% adjust the reward down.
      // adjust by more if it has been 10 days then 10%
      
      let bid_upper_bound = 0950;
      let bid_lower_bound = 0500;

      let short_window: u64 = 5;
      let long_window: u64 = 10;

      let cr = borrow_global_mut<ConsensusReward>(@VMReserved);

      let len = Vector::length<u64>(&cr.avg_bid_history);
      let i = 0;

      let epochs_above = 0;
      let epochs_below = 0;
      while (i < 10 || i < len) { // max ten days, but may have less in history, filling set should truncate the history at 10 epochs.
        let avg_bid = *Vector::borrow<u64>(&cr.avg_bid_history, i);
        if (avg_bid > bid_upper_bound) {
          epochs_above = epochs_above + 1;
        } else if (avg_bid < bid_lower_bound) {
          epochs_below = epochs_below + 1;
        };
  
        i = i + 1;
      };

      if (cr.value > 0) {
        // TODO: this is an initial implementation, we need to
        // decide if we want more granularity in the reward adjustment
        // Note: making this readable for now, but we can optimize later
        if (epochs_above > short_window) {
          // check for zeros.
          // TODO: put a better safety check here
          if ((cr.value / 10) > cr.value){
            return
          };
          // If the Validators are bidding near 100% that means
          // the reward is very generous, i.e. their opportunity
          // cost is met at small percentages. This means the
          // implicit bond is very high on validators. E.g.
          // at 1% median bid, the implicit bond is 100x the reward.
          // We need to DECREASE the reward

          if (epochs_above > short_window) {
            // decrease the reward by 10%
            cr.value = cr.value - (cr.value / 10);
            return // return early since we can't increase and decrease simultaneously
          } else if (epochs_above > long_window) {
            // decrease the reward by 5%
            cr.value = cr.value - (cr.value / 20);
            return // return early since we can't increase and decrease simultaneously
          };
            
          // if validators are bidding low percentages
          // it means the nominal reward is not high enough.
          // That is the validator's opportunity cost is not met within a
          // range where the bond is meaningful.
          // For example: if the bids for the epoch's reward is 50% of the  value, that means the potential profit, is the same as the potential loss.
          // At a 25% bid (potential loss), the profit is thus 75% of the value, which means the implicit bond is 25/75, or 1/3 of the bond, the risk favors the validator. This means among other things, that an attacker can pay for the cost of the attack with the profits. See paper, for more details.

          // we need to INCREASE the reward, so that the bond is more meaningful.
          if (epochs_below > short_window) {
            // decrease the reward by 5%
            cr.value = cr.value + (cr.value / 20);
          } else if (epochs_above > long_window) {
            // decrease the reward by 10%
            cr.value = cr.value + (cr.value / 10);
          };
        };
      };
    }

    /// find the median bid to push to history
    // this is needed for reward_thermostat
    public fun set_history(vm: &signer, seats_to_fill: &vector<address>) acquires ProofOfFeeAuction, ConsensusReward {
      if (Signer::address_of(vm) != @VMReserved) {
        return
      };

      let median_bid = get_median(seats_to_fill);
      // push to history
      let cr = borrow_global_mut<ConsensusReward>(@VMReserved);
      if (Vector::length(&cr.avg_bid_history) < 10) {
        Vector::push_back(&mut cr.avg_bid_history, median_bid);
      } else {
        Vector::remove(&mut cr.avg_bid_history, 0);
        Vector::push_back(&mut cr.avg_bid_history, median_bid);
      };
    }

    fun get_median(seats_to_fill: &vector<address>):u64 acquires ProofOfFeeAuction { 
      // TODO: the list is sorted above, so
      // we assume the median is the middle element
      let len = Vector::length(seats_to_fill);
      if (len == 0) {
        return 0
      };
      let median_bidder = if (len > 2) {
        Vector::borrow(seats_to_fill, len/2)
      } else {
        Vector::borrow(seats_to_fill, 0)
      };
      let (median_bid, _) = current_bid(*median_bidder);
      return median_bid
    }

    //////////////// GETTERS ////////////////
    // get the current bid for a validator


    // get the baseline reward from ConsensusReward 
    public fun get_consensus_reward(): u64 acquires ConsensusReward {
      let b = borrow_global<ConsensusReward>(@VMReserved );
      return b.value
    }

    // CONSENSUS CRITICAL 
    // ALL EYES ON THIS
    // Proof of Fee returns the current bid of the validator during the auction for upcoming epoch seats.
    // returns (current bid, expiration epoch)
    public fun current_bid(node_addr: address): (u64, u64) acquires ProofOfFeeAuction {
      if (exists<ProofOfFeeAuction>(node_addr)) {
        let pof = borrow_global<ProofOfFeeAuction>(node_addr);
        let e = DiemConfig::get_current_epoch();
        // check the expiration of the bid
        // the bid is zero if it expires.
        // The expiration epoch number is inclusive of the epoch.
        // i.e. the bid expires on e + 1.
        if (pof.epoch_expiration >= e || pof.epoch_expiration == 0) {
          return (pof.bid, pof.epoch_expiration)
        };
        return (0, pof.epoch_expiration)
      };
      return (0, 0)
    }

    ////////// SETTERS //////////
    // validator can set a bid. See transaction script below.
    // the validator can set an "expiry epoch:  for the bid.
    // Zero means never expires.
    // Bids are denomiated in percentages, with two decimal places..
    // i.e. 1234 = 12.34%
    // Provisionally 110% is the maximum bid. Which could be reviewed.
    public fun set_bid(account_sig: &signer, bid: u64, expiry_epoch: u64) acquires ProofOfFeeAuction {

      let acc = Signer::address_of(account_sig);
      if (!exists<ProofOfFeeAuction>(acc)) {
        init(account_sig);
      };

      assert!(bid <= 11000, Errors::ol_tx(EBID_ABOVE_MAX_PCT));

      let pof = borrow_global_mut<ProofOfFeeAuction>(acc);
      pof.epoch_expiration = expiry_epoch;
      pof.bid = bid;
    }


    ////////// TRANSACTION APIS //////////
    // manually init the struct, fallback in case of migration fail
    public(script) fun init_bidding(sender: signer) {
      init(&sender);
    }

    // update the bid for the sender
    public(script) fun update_pof_bid(sender: signer, bid: u64, epoch_expiry: u64) acquires ProofOfFeeAuction {
      // update the bid, initializes if not already.
      set_bid(&sender, bid, epoch_expiry);
    }
  }
}


