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
    use Std::Signer;
    use DiemFramework::ValidatorUniverse;
    use Std::Vector;
    use DiemFramework::Jail;
    use DiemFramework::DiemAccount;
    use DiemFramework::Vouch;
    use Std::FixedPoint32;
    use DiemFramework::Testnet;
    use DiemFramework::ValidatorConfig;
    use DiemFramework::CoreAddresses;
    // use DiemFramework::Debug::print;

    const ENOT_AN_ACTIVE_VALIDATOR: u64 = 190001;
    const EBID_ABOVE_MAX_PCT: u64 = 190002;
    const EABOVE_RETRACT_LIMIT: u64 = 190003; // Potential update


    const GENESIS_BASELINE_REWARD: u64 = 1000000;

    
    // A struct on the validators account which indicates their
    // latest bid (and epoch)
    struct ProofOfFeeAuction has key {
      bid: u64,
      epoch_expiration: u64,
      last_epoch_retracted: u64,
      // TODO: show past 5 bids
    }

    struct ConsensusReward has key {
      value: u64,
      clearing_price: u64,
      median_win_bid: u64,
      median_history: vector<u64>,
    }
    public fun init_genesis_baseline_reward(vm: &signer) {
      if (Signer::address_of(vm) != @VMReserved) return;

      if (!exists<ConsensusReward>(@VMReserved)) {
        move_to<ConsensusReward>(
          vm,
          ConsensusReward {
            value: GENESIS_BASELINE_REWARD,
            clearing_price: 0,
            median_win_bid: 0,
            median_history: Vector::empty<u64>(),
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
            epoch_expiration: 0,
            last_epoch_retracted: 0,
          }
        );
      }
    }

    /// consolidates all the logic for the epoch boundary
    // includes getting the sorted bids
    // filling the seats (determined by MusicalChairs), and getting a price.
    // and finally charging the validators for their bid (everyone pays the lowest)
    public fun epoch_boundary(
      vm: &signer,
      outgoing_compliant_set: &vector<address>,
      n_musical_chairs: u64
    ): vector<address> acquires ProofOfFeeAuction, ConsensusReward {
        CoreAddresses::assert_vm(vm);
        let sorted_bids = get_sorted_vals(false);

        let (auction_winners, price) = fill_seats_and_get_price(vm, n_musical_chairs, &sorted_bids, outgoing_compliant_set);
        // print(&price);

        DiemAccount::vm_multi_pay_fee(vm, &auction_winners, price, &b"proof of fee");

        auction_winners
    }





    //////// CONSENSUS CRITICAL ////////
    // Get the validator universe sorted by bid
    // By default this will return a FILTERED list of validators
    // which excludes validators which cannot pass the audit.
    // Leaving the unfiltered option for testing purposes, and any future use.
    // TODO: there's a known issue when many validators have the exact same
    // bid, the preferred node  will be the one LAST included in the validator universe.
    public fun get_sorted_vals(unfiltered: bool): vector<address> acquires ProofOfFeeAuction, ConsensusReward {
      let eligible_validators = ValidatorUniverse::get_eligible_validators();
      let length = Vector::length<address>(&eligible_validators);
      // print(&length);
      // Vector to store each address's node_weight
      let weights = Vector::empty<u64>();
      let filtered_vals = Vector::empty<address>();
      let k = 0;
      while (k < length) {
        // TODO: Ensure that this address is an active validator

        let cur_address = *Vector::borrow<address>(&eligible_validators, k);
        let (bid, _expire) = current_bid(cur_address);
        // print(&bid);
        // print(&expire);
        if (!unfiltered && !audit_qualification(&cur_address)) { 
          k = k + 1;
          continue
        };
        Vector::push_back<u64>(&mut weights, bid);
        Vector::push_back<address>(&mut filtered_vals, cur_address);
        k = k + 1;
      };

      // print(&weights);

      // Sorting the accounts vector based on value (weights).
      // Bubble sort algorithm
      let len_filtered = Vector::length<address>(&filtered_vals);
      // print(&len_filtered);
      // print(&Vector::length(&weights));
      if (len_filtered < 2) return filtered_vals;
      let i = 0;
      while (i < len_filtered){
        let j = 0;
        while(j < len_filtered-i-1){
          // print(&8888801);

          let value_j = *(Vector::borrow<u64>(&weights, j));
          // print(&8888802);
          let value_jp1 = *(Vector::borrow<u64>(&weights, j+1));
          if(value_j > value_jp1){
            // print(&8888803);
            Vector::swap<u64>(&mut weights, j, j+1);
            // print(&8888804);
            Vector::swap<address>(&mut filtered_vals, j, j+1);
          };
          j = j + 1;
          // print(&8888805);
        };
        i = i + 1;
        // print(&8888806);
      };

      // print(&filtered_vals);
      // Reverse to have sorted order - high to low.
      Vector::reverse<address>(&mut filtered_vals);

      return filtered_vals
    }

    // Here we place the bidders into their seats.
    // The order of the bids will determine placement.
    // One important aspect of picking the next validator set:
    // it should have 2/3rds of known good ("proven") validators
    // from the previous epoch. Otherwise the unproven nodes, who
    // may not be ready for consensus, might be offline and cause a halt.
    // Validators can be inattentive and have bids that qualify, but their nodes
    // are not ready.
    // So the selection algorithm needs to stop filling seats with "unproven"
    // validators if the max unproven nodes limit is hit (1/3).

    // The paper does not specify what happens with the "Jail reputation"
    // of a validator. E.g. if a validator has a bid with no expiry
    // but has a bad jail reputation does this penalize in the ordering?
    // This is a potential issue again with inattentive validators who
    // have have a high bid, but again they fail repeatedly to finalize an epoch
    // successfully. Their bids should not penalize validators who don't have
    // a streak of jailed epochs. So of the 1/3 unproven nodes, we'll first seat the validators with Jail.consecutive_failure_to_rejoin < 2, and after that the remainder. 

    // There's some code implemented which is not enabled in the current form.
    // Unsealed auctions are tricky. The Proof Of Fee
    // paper states that since the bids are not private, we need some
    // constraint to minimize shill bids, "bid shading" or other strategies
    // which allow validators to drift from their private valuation. 
    // As such per epoch the validator is only allowed to revise their bids /
    // down once. To do this in practice they need to retract a bid (sit out
    // the auction), and then place a new bid.
    // A validator can always leave the auction, but if they rejoin a second time in the epoch, then they've committed a bid until the next epoch.
    // So retracting should be done with care.  The ergonomics are not great. 
    // The preference would be not to have this constraint if on the margins
    // the ergonomics brings more bidders than attackers.
    // After more experience in the wild, the network may decide to 
    // limit bid retracting.


    // The Validator must qualify on a number of metrics: have funds in their Unlocked account to cover bid, have miniumum viable vouches, and not have been jailed in the previous round.


    // This function assumes we have already filtered out ineligible validators.
    // but we will check again here.
    public fun fill_seats_and_get_price(
      vm: &signer,
      set_size: u64,
      sorted_vals_by_bid: &vector<address>,
      proven_nodes: &vector<address>
    ): (vector<address>, u64) acquires ProofOfFeeAuction, ConsensusReward {
      if (Signer::address_of(vm) != @VMReserved) return (Vector::empty<address>(), 0);

      let seats_to_fill = Vector::empty<address>();
      
      // check the max size of the validator set.
      // there may be too few "proven" validators to fill the set with 2/3rds proven nodes of the stated set_size.
      let proven_len = Vector::length(proven_nodes);

      // check if the proven len plus unproven quota will
      // be greater than the set size. Which is the expected.
      // Otherwise the set will need to be smaller than the
      // declared size, because we will have to fill with more unproven nodes.
      let one_third_of_max = proven_len/2;
      let safe_set_size = proven_len + one_third_of_max;

      let (set_size, max_unproven) = if (safe_set_size < set_size) {
        (safe_set_size, safe_set_size/3)
      } else {
        // happy case, unproven bidders are a smaller minority
        (set_size, set_size/3)
      };

      // Now we can seat the validators based on the algo above:
      // 1. seat the proven nodes of previous epoch
      // 2. seat validators who did not participate in the previous epoch:
      // 2a. seat the vals with jail reputation < 2
      // 2b. seat the remainder of the unproven vals with any jail reputation.

      let num_unproven_added = 0;
      let i = 0u64;
      while (
        (Vector::length(&seats_to_fill) < set_size) &&
        (i < Vector::length(sorted_vals_by_bid))
      ) {
        let val = Vector::borrow(sorted_vals_by_bid, i);
        // check if a proven node
        if (Vector::contains(proven_nodes, val)) {
          Vector::push_back(&mut seats_to_fill, *val);
        } else {
          // for unproven nodes, push it to list if we haven't hit limit
          if (num_unproven_added < max_unproven ) {
            // TODO: check jail reputation
            Vector::push_back(&mut seats_to_fill, *val);
            num_unproven_added = num_unproven_added + 1;
          };
        };
        i = i + 1;
      };

      // Set history
      set_history(vm, &seats_to_fill);

      // we failed to seat anyone.
      // let EpochBoundary deal with this.
      if (Vector::is_empty(&seats_to_fill)) {
        // print(&8006010209);

        return (seats_to_fill, 0)
      };

      // Find the clearing price which all validators will pay
      let lowest_bidder = Vector::borrow(&seats_to_fill, Vector::length(&seats_to_fill) - 1);

      let (lowest_bid_pct, _) = current_bid(*lowest_bidder);
      
      // print(&lowest_bid_pct);

      // update the clearing price
      let cr = borrow_global_mut<ConsensusReward>(@VMReserved);
      cr.clearing_price = lowest_bid_pct;

      return (seats_to_fill, lowest_bid_pct)
    }

    // consolidate all the checks for a validator to be seated
    public fun audit_qualification(val: &address): bool acquires ProofOfFeeAuction, ConsensusReward {
        
        // Safety check: node has valid configs
        if (!ValidatorConfig::is_valid(*val)) return false;
        // has operator account set to another address
        let oper = ValidatorConfig::get_operator(*val);
        if (oper == *val) return false;

        // is a slow wallet
        if (!DiemAccount::is_slow(*val)) return false;

        // print(&8006010203);
        // we can't seat validators that were just jailed
        // NOTE: epoch reconfigure needs to reset the jail
        // before calling the proof of fee.
        if (Jail::is_jailed(*val)) return false;
        // print(&8006010204);
        // we can't seat validators who don't have minimum viable vouches
        if (!Vouch::unrelated_buddies_above_thresh(*val)) return false;

        // print(&80060102041);

        let (bid, expire) = current_bid(*val);
        //print(val);
        // print(&bid);
        // print(&expire);

        // Skip if the bid expired. belt and suspenders, this should have been checked in the sorting above.
        // TODO: make this it's own function so it can be publicly callable, it's useful generally, and for debugging.
        // print(&DiemConfig::get_current_epoch());
        if (DiemConfig::get_current_epoch() > expire) return false;

        // skip the user if they don't have sufficient UNLOCKED funds
        // or if the bid expired.
        // print(&80060102042);
        let unlocked_coins = DiemAccount::unlocked_amount(*val);
        // print(&unlocked_coins);

        let (baseline_reward, _, _) = get_consensus_reward();
        let coin_required = FixedPoint32::multiply_u64(baseline_reward, FixedPoint32::create_from_rational(bid, 1000));

        // print(&coin_required);
        if (unlocked_coins < coin_required) return false;
        
        // print(&80060102043);
        true
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

      // print(&8006010551);
      let len = Vector::length<u64>(&cr.median_history);
      let i = 0;

      let epochs_above = 0;
      let epochs_below = 0;
      while (i < 16 && i < len) { // max ten days, but may have less in history, filling set should truncate the history at 15 epochs.
      // print(&8006010552);
        let avg_bid = *Vector::borrow<u64>(&cr.median_history, i);
        // print(&8006010553);
        if (avg_bid > bid_upper_bound) {
          epochs_above = epochs_above + 1;
        } else if (avg_bid < bid_lower_bound) {
          epochs_below = epochs_below + 1;
        };
  
        i = i + 1;
      };

      // print(&8006010554);
      if (cr.value > 0) {
        // print(&8006010555);
        // print(&epochs_above);
        // print(&epochs_below);


        // TODO: this is an initial implementation, we need to
        // decide if we want more granularity in the reward adjustment
        // Note: making this readable for now, but we can optimize later
        if (epochs_above > epochs_below) {

          // if (epochs_above > short_window) {
          // print(&8006010556);
          // check for zeros.
          // TODO: put a better safety check here

          // If the Validators are bidding near 100% that means
          // the reward is very generous, i.e. their opportunity
          // cost is met at small percentages. This means the
          // implicit bond is very high on validators. E.g.
          // at 1% median bid, the implicit bond is 100x the reward.
          // We need to DECREASE the reward
          // print(&8006010558);

          if (epochs_above > long_window) {

            // decrease the reward by 10%
            // print(&8006010559);
            

            cr.value = cr.value - (cr.value / 10);
            return // return early since we can't increase and decrease simultaneously
          } else if (epochs_above > short_window) {
            // decrease the reward by 5%
            // print(&80060105510);
            cr.value = cr.value - (cr.value / 20);
            

            return // return early since we can't increase and decrease simultaneously
          }
        };
        
            
          // if validators are bidding low percentages
          // it means the nominal reward is not high enough.
          // That is the validator's opportunity cost is not met within a
          // range where the bond is meaningful.
          // For example: if the bids for the epoch's reward is 50% of the  value, that means the potential profit, is the same as the potential loss.
          // At a 25% bid (potential loss), the profit is thus 75% of the value, which means the implicit bond is 25/75, or 1/3 of the bond, the risk favors the validator. This means among other things, that an attacker can pay for the cost of the attack with the profits. See paper, for more details.

          // we need to INCREASE the reward, so that the bond is more meaningful.
          // print(&80060105511);

          if (epochs_below > long_window) {
            // print(&80060105513);

            // increase the reward by 10%
            cr.value = cr.value + (cr.value / 10);
          } else if (epochs_below > short_window) {
            // print(&80060105512);

            // increase the reward by 5%
            cr.value = cr.value + (cr.value / 20);
          };
        // };
      };
    }

    /// find the median bid to push to history
    // this is needed for reward_thermostat
    public fun set_history(vm: &signer, seats_to_fill: &vector<address>) acquires ProofOfFeeAuction, ConsensusReward {
      if (Signer::address_of(vm) != @VMReserved) {
        return
      };

      // print(&99901);
      let median_bid = get_median(seats_to_fill);
      // push to history
      let cr = borrow_global_mut<ConsensusReward>(@VMReserved);
      cr.median_win_bid = median_bid;
      if (Vector::length(&cr.median_history) < 10) {
        // print(&99902);
        Vector::push_back(&mut cr.median_history, median_bid);
      } else {
        // print(&99903);
        Vector::remove(&mut cr.median_history, 0);
        Vector::push_back(&mut cr.median_history, median_bid);
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
    public fun get_consensus_reward(): (u64, u64, u64) acquires ConsensusReward {
      let b = borrow_global<ConsensusReward>(@VMReserved );
      return (b.value, b.clearing_price, b.median_win_bid)
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

    // which epoch did they last retract a bid?
    public fun is_already_retracted(node_addr: address): (bool, u64) acquires ProofOfFeeAuction {
      if (exists<ProofOfFeeAuction>(node_addr)) {
        let when_retract = *&borrow_global<ProofOfFeeAuction>(node_addr).last_epoch_retracted;
        return (DiemConfig::get_current_epoch() >= when_retract,  when_retract)
      };
      return (false, 0)
    }

    // Get the top N validators by bid, this is FILTERED by default
    public fun top_n_accounts(account: &signer, n: u64, unfiltered: bool): vector<address> acquires ProofOfFeeAuction, ConsensusReward {
        assert!(Signer::address_of(account) == @DiemRoot, Errors::requires_role(140101));

        let eligible_validators = get_sorted_vals(unfiltered);
        let len = Vector::length<address>(&eligible_validators);
        if(len <= n) return eligible_validators;

        let diff = len - n; 
        while(diff > 0){
          Vector::pop_back(&mut eligible_validators);
          diff = diff - 1;
        };

        eligible_validators
    }
    

    ////////// SETTERS //////////
    // validator can set a bid. See transaction script below.
    // the validator can set an "expiry epoch:  for the bid.
    // Zero means never expires.
    // Bids are denomiated in percentages, with ONE decimal place..
    // i.e. 0123 = 12.3%
    // Provisionally 110% is the maximum bid. Which could be reviewed.
    public fun set_bid(account_sig: &signer, bid: u64, expiry_epoch: u64) acquires ProofOfFeeAuction {

      let acc = Signer::address_of(account_sig);
      if (!exists<ProofOfFeeAuction>(acc)) {
        init(account_sig);
      };
      
      // bid must be below 110%
      assert!(bid <= 1100, Errors::ol_tx(EBID_ABOVE_MAX_PCT));

      let pof = borrow_global_mut<ProofOfFeeAuction>(acc);
      pof.epoch_expiration = expiry_epoch;
      pof.bid = bid;
    }


    /// Note that the validator will not be bidding on any future
    /// epochs if they retract their bid. The must set a new bid.
    public fun retract_bid(account_sig: &signer) acquires ProofOfFeeAuction {

      let acc = Signer::address_of(account_sig);
      if (!exists<ProofOfFeeAuction>(acc)) {
        init(account_sig);
      };


      let pof = borrow_global_mut<ProofOfFeeAuction>(acc);
      let this_epoch = DiemConfig::get_current_epoch();

      //////// LEAVE COMMENTED. Code for a potential upgrade. ////////
      // See above discussion for retracting of bids.
      // 
      // already retracted this epoch
      // assert!(this_epoch > pof.last_epoch_retracted, Errors::ol_tx(EABOVE_RETRACT_LIMIT));
      //////// LEAVE COMMENTED. Code for a potential upgrade. ////////


      pof.epoch_expiration = 0;
      pof.bid = 0;
      pof.last_epoch_retracted = this_epoch;
    }

    ////////// TRANSACTION APIS //////////
    // manually init the struct, fallback in case of migration fail
    public(script) fun init_bidding(sender: signer) {
      init(&sender);
    }

    // update the bid for the sender
    public(script) fun pof_update_bid(sender: signer, bid: u64, epoch_expiry: u64) acquires ProofOfFeeAuction {
      // update the bid, initializes if not already.
      set_bid(&sender, bid, epoch_expiry);
    }

    // retract bid
    public(script) fun pof_retract_bid(sender: signer) acquires ProofOfFeeAuction {
      // retract a bid
      retract_bid(&sender);
    }

    //////// TEST HELPERS ////////

    public fun test_set_val_bids(vm: &signer, vals: &vector<address>, bids: &vector<u64>, expiry: &vector<u64>) acquires ProofOfFeeAuction {
      Testnet::assert_testnet(vm);

      let len = Vector::length(vals);
      let i = 0;
      while (i < len) {
        let bid = Vector::borrow(bids, i);
        let exp = Vector::borrow(expiry, i);
        let addr = Vector::borrow(vals, i);
        test_set_one_bid(vm, addr, *bid, *exp);
        i = i + 1;
      };
    }

    public fun test_set_one_bid(vm: &signer, val: &address, bid:  u64, exp: u64) acquires ProofOfFeeAuction {
      Testnet::assert_testnet(vm);
      let pof = borrow_global_mut<ProofOfFeeAuction>(*val);
      pof.epoch_expiration = exp;
      pof.bid = bid;
    }

    public fun test_mock_reward(
      vm: &signer,
      value: u64,
      clearing_price: u64,
      median_win_bid: u64,
      median_history: vector<u64>,
    ) acquires ConsensusReward {
      Testnet::assert_testnet(vm);

      let cr = borrow_global_mut<ConsensusReward>(@VMReserved );
      cr.value = value;
      cr.clearing_price = clearing_price;
      cr.median_win_bid = median_win_bid;
      cr.median_history = median_history;

    }
  }
}


