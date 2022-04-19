///////////////////////////////////////////////////////////////////////////
// 0L Module
// Epoch Prologue
///////////////////////////////////////////////////////////////////////////
// The prologue for transitioning to next epoch after every n blocks.
// File Prefix for errors: 1800
///////////////////////////////////////////////////////////////////////////


address 0x1 {
module EpochBoundary {
    use 0x1::CoreAddresses;
    use 0x1::Subsidy;
    use 0x1::NodeWeight;
    use 0x1::DiemSystem;
    use 0x1::TowerState;
    use 0x1::Globals;
    use 0x1::Vector;
    use 0x1::Stats;
    use 0x1::AutoPay;
    use 0x1::Epoch;
    use 0x1::DiemConfig;
    use 0x1::Audit;
    use 0x1::DiemAccount;
    use 0x1::Burn;
    use 0x1::FullnodeSubsidy;

    // This function is called by block-prologue once after n blocks.
    // Function code: 01. Prefix: 180001
    public fun reconfigure(vm: &signer, height_now: u64) {
        CoreAddresses::assert_vm(vm);

        let height_start = Epoch::get_timer_height_start(vm);
        
        let (outgoing_compliant_set, _) = 
            DiemSystem::get_fee_ratio(vm, height_start, height_now);

        // NOTE: This is "nominal" because it doesn't check
        let compliant_nodes_count = Vector::length(&outgoing_compliant_set);
        let (subsidy_units, nominal_subsidy_per) = 
            Subsidy::calculate_subsidy(vm, compliant_nodes_count);
        
        process_fullnodes(vm, nominal_subsidy_per);
        
        process_validators(vm, subsidy_units, *&outgoing_compliant_set);
        
        let proposed_set = propose_new_set(vm, height_start, height_now);
        
        // Update all slow wallet limits
        if (DiemConfig::check_transfer_enabled()) {
            DiemAccount::slow_wallet_epoch_drip(vm, Globals::get_unlock());
            // update_validator_withdrawal_limit(vm);
        };
        reset_counters(vm, proposed_set, outgoing_compliant_set, height_now)
    }

    // process fullnode subsidy
    fun process_fullnodes(vm: &signer, nominal_subsidy_per_node: u64) {
        // Fullnode subsidy
        // loop through validators and pay full node subsidies.
        // Should happen before transactionfees get distributed.
        // Note: need to check, there may be new validators which have not mined yet.
        let miners = TowerState::get_miner_list();
        // fullnode subsidy is a fraction of the total subsidy available to validators.
        let proof_price = FullnodeSubsidy::get_proof_price(nominal_subsidy_per_node);

        let k = 0;
        // Distribute mining subsidy to fullnodes
        while (k < Vector::length(&miners)) {
            let addr = *Vector::borrow(&miners, k);
            if (DiemSystem::is_validator(addr)) { // skip validators
              k = k + 1;
              continue
            };
            
            // TODO: this call is repeated in propose_new_set. 
            // Not sure if the performance hit at epoch boundary is worth the refactor. 
            if (TowerState::node_above_thresh(addr)) {
              let count = TowerState::get_count_above_thresh_in_epoch(addr);

              let miner_subsidy = count * proof_price;
              FullnodeSubsidy::distribute_fullnode_subsidy(vm, addr, miner_subsidy);
            };

            k = k + 1;
        };
    }

    fun process_validators(
        vm: &signer, subsidy_units: u64, outgoing_compliant_set: vector<address>
    ) {
        // Process outgoing validators:
        // Distribute Transaction fees and subsidy payments to all outgoing validators
        
        if (Vector::is_empty<address>(&outgoing_compliant_set)) return;

        if (subsidy_units > 0) {
            Subsidy::process_subsidy(vm, subsidy_units, &outgoing_compliant_set);
        };

        Subsidy::process_fees(vm, &outgoing_compliant_set);
    }

    fun propose_new_set(vm: &signer, height_start: u64, height_now: u64): vector<address> {
        // Propose upcoming validator set:
        // Step 1: Sort Top N eligible validators
        // Step 2: Jail non-performing validators
        // Step 3: Reset counters
        // Step 4: Bulk update validator set (reconfig)

        // save all the eligible list, before the jailing removes them.
        let proposed_set = Vector::empty();

        let top_accounts = NodeWeight::top_n_accounts(
            vm, Globals::get_max_validators_per_set()
        );

        let jailed_set = DiemSystem::get_jailed_set(vm, height_start, height_now);

        Burn::reset_ratios(vm);
        // LEAVE THIS CODE COMMENTED for future use
        // TODO: Make the burn value dynamic.
        let incoming_count = Vector::length<address>(&top_accounts) - Vector::length<address>(&jailed_set);
        let burn_value = Subsidy::subsidy_curve(
          Globals::get_subsidy_ceiling_gas(),
          incoming_count,
          Globals::get_max_validators_per_set()
        )/2;

        // let burn_value = 1000000; // TODO: switch to a variable cost, as above.

        let i = 0;
        while (i < Vector::length<address>(&top_accounts)) {
            let addr = *Vector::borrow(&top_accounts, i);
            let mined_last_epoch = TowerState::node_above_thresh(addr);
            // TODO: temporary until jailing is enabled.
            if (
                !Vector::contains(&jailed_set, &addr) && 
                mined_last_epoch &&
                Audit::val_audit_passing(addr)
            ) {
                Vector::push_back(&mut proposed_set, addr);
                Burn::epoch_start_burn(vm, addr, burn_value);
            };
            i = i+ 1;
        };

        // If the cardinality of validator_set in the next epoch is less than 4, 
        // we keep the same validator set. 
        if (Vector::length<address>(&proposed_set) <= 3) proposed_set = *&top_accounts;
        // Usually an issue in staging network for QA only.
        // This is very rare and theoretically impossible for network with 
        // at least 6 nodes and 6 rounds. If we reach an epoch boundary with 
        // at least 6 rounds, we would have at least 2/3rd of the validator 
        // set with at least 66% liveliness. 
        proposed_set
    }

    fun reset_counters(vm: &signer, proposed_set: vector<address>, outgoing_compliant: vector<address>, height_now: u64) {

        // Reset Stats
        Stats::reconfig(vm, &proposed_set);
        TowerState::reconfig(vm, &outgoing_compliant);

        // Reconfigure the network
        DiemSystem::bulk_update_validators(vm, proposed_set);

        // process community wallets
        DiemAccount::process_community_wallets(vm, DiemConfig::get_current_epoch());
        
        // reset counters
        AutoPay::reconfig_reset_tick(vm);
        Epoch::reset_timer(vm, height_now);
    }
}
}