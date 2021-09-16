///////////////////////////////////////////////////////////////////////////
// 0L Module
// Epoch Prologue
///////////////////////////////////////////////////////////////////////////
// The prologue for transitioning to next epoch after every n blocks.
// File Prefix for errors: 1800
///////////////////////////////////////////////////////////////////////////


address 0x1 {
module Reconfigure { // TODO: Rename to Boundary
    use 0x1::CoreAddresses;
    use 0x1::Subsidy;
    use 0x1::NodeWeight;
    use 0x1::DiemSystem;
    use 0x1::MinerState;
    use 0x1::Globals;
    use 0x1::Vector;
    use 0x1::Stats;
    use 0x1::ValidatorUniverse;
    use 0x1::AutoPay2;
    use 0x1::Epoch;
    use 0x1::FullnodeState;
    use 0x1::DiemConfig;
    use 0x1::Audit;
    use 0x1::DiemAccount;
    use 0x1::Burn;

    // use 0x1::Debug::print;

    // This function is called by block-prologue once after n blocks.
    // Function code: 01. Prefix: 180001
    public fun reconfigure(vm: &signer, height_now: u64) {
        CoreAddresses::assert_vm(vm);

        let height_start = Epoch::get_timer_height_start(vm);

        process_fullnodes(vm);

        process_validators(vm, height_start, height_now);

        let proposed_set = propose_new_set(vm, height_start, height_now);

        // Update all slow wallet limits
        if (DiemConfig::check_transfer_enabled()) {
            DiemAccount::slow_wallet_epoch_drip(vm, Globals::get_unlock());
            // update_validator_withdrawal_limit(vm);
        };
       
        reset_counters(vm, proposed_set, height_now)
    }

    // process fullnode subsidy
    fun process_fullnodes(vm: &signer) {
        // Fullnode subsidy
        // loop through validators and pay full node subsidies.
        // Should happen before transactionfees get distributed.
        // Note: need to check, there may be new validators which have not mined yet.
        // print(&03100);

        let miners = MinerState::get_miner_list();
        
        // Migration for miner list.
        if (Vector::length(&miners) == 0) { miners = ValidatorUniverse::get_eligible_validators(vm) };

        let global_proofs_count = 0;
        let k = 0;
        // print(&03200);

              // Distribute mining subsidy to fullnodes
        while (k < Vector::length(&miners)) {
            let addr = *Vector::borrow(&miners, k);
            // print(&03210);
          
            if (!FullnodeState::is_init(addr)) continue; // fail-safe

            let count = MinerState::get_count_in_epoch(addr);
            
            global_proofs_count = global_proofs_count + count;
            
            let value: u64;

            value = Subsidy::distribute_fullnode_subsidy(vm, addr, count);
            
            // print(&03230);
            FullnodeState::inc_payment_count(vm, addr, count);
            FullnodeState::inc_payment_value(vm, addr, value);
            FullnodeState::reconfig(vm, addr, count);

            k = k + 1;
        };

         // needs to be set before the auctioneer runs in Subsidy::fullnode_reconfig
        Subsidy::set_global_count(vm, global_proofs_count);
    }

    fun process_validators(vm: &signer, height_start: u64, height_now: u64) {
        // Process outgoing validators:
        // Distribute Transaction fees and subsidy payments to all outgoing validators
        

        // print(&03240);

        let (outgoing_set, fee_ratio) = DiemSystem::get_fee_ratio(vm, height_start, height_now);
        if (Vector::length<address>(&outgoing_set) > 0) {
            let subsidy_units = Subsidy::calculate_subsidy(vm, height_start, height_now);
            // print(&03241);

            if (subsidy_units > 0) {
                Subsidy::process_subsidy(vm, subsidy_units, &outgoing_set, &fee_ratio);
            };
            // print(&03241);

            Subsidy::process_fees(vm, &outgoing_set, &fee_ratio);
        };

    }

    fun propose_new_set(vm: &signer, height_start: u64, height_now: u64): vector<address> {
        // Propose upcoming validator set:
        // Step 1: Sort Top N eligible validators
        // Step 2: Jail non-performing validators
        // Step 3: Reset counters
        // Step 4: Bulk update validator set (reconfig)

        // save all the eligible list, before the jailing removes them.
        let proposed_set = Vector::empty();

        let top_accounts = NodeWeight::top_n_accounts(vm, Globals::get_max_validators_per_set());

        let jailed_set = DiemSystem::get_jailed_set(vm, height_start, height_now);

        Burn::reset_ratios(vm);
        // TODO: Make the burn value dynamic.
        // let incoming_count = Vector::length<address>(&top_accounts) - Vector::length<address>(&jailed_set);
        // let burn_value = Subsidy::subsidy_curve(
        //   Globals::get_subsidy_ceiling_gas(),
        //   incoming_count,
        //   Globals::get_max_node_density()
        // )/4;
        let burn_value = 1000000; // TODO: switch to a variable cost, as above.

        // print(&03250);

        let i = 0;
        while (i < Vector::length<address>(&top_accounts)) {
            // print(&03251);

            let addr = *Vector::borrow(&top_accounts, i);
            let mined_last_epoch = MinerState::node_above_thresh(vm, addr);
            // print(&mined_last_epoch);
            // TODO: temporary until jail-refactor merge.
            if (
              (!Vector::contains(&jailed_set, &addr)) && 
              mined_last_epoch &&
              Audit::val_audit_passing(addr)
            ) {
            //print(&03252);

                Vector::push_back(&mut proposed_set, addr);
                Burn::epoch_start_burn(vm, addr, burn_value);

            };
            i = i+ 1;
        };

        // If the cardinality of validator_set in the next epoch is less than 4, we keep the same validator set. 
        if (Vector::length<address>(&proposed_set)<= 3) proposed_set = *&top_accounts;
        // Usually an issue in staging network for QA only.
        // This is very rare and theoretically impossible for network with at least 6 nodes and 6 rounds. If we reach an epoch boundary with at least 6 rounds, we would have at least 2/3rd of the validator set with at least 66% liveliness. 
        // print(&03270);
        proposed_set
    }

    fun reset_counters(vm: &signer, proposed_set: vector<address>, height_now: u64) {
        // print(&03280);

        //Reset Counters
        Stats::reconfig(vm, &proposed_set);
        // print(&03290);

        // Migrate MinerState list from elegible: in case there is no minerlist struct, use eligible for migrate_eligible_validators
        let eligible = ValidatorUniverse::get_eligible_validators(vm);
        MinerState::reconfig(vm, &eligible);
        // print(&032100);

        // Reconfigure the network
        DiemSystem::bulk_update_validators(vm, proposed_set);
        // print(&032110);

        // reset clocks
        Subsidy::fullnode_reconfig(vm);
        // print(&032120);

        // process community wallets
        DiemAccount::process_community_wallets(vm, 
        DiemConfig::get_current_epoch());
        // print(&032130);

        AutoPay2::reconfig_reset_tick(vm);
        // print(&032140);

        Epoch::reset_timer(vm, height_now);
        // print(&032150);
    }
}
}