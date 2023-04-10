///////////////////////////////////////////////////////////////////////////
// 0L Module
// Epoch Boundary
///////////////////////////////////////////////////////////////////////////
// The prologue for transitioning to next epoch after every n blocks.
// File Prefix for errors: 1800
///////////////////////////////////////////////////////////////////////////


address DiemFramework {
module EpochBoundary {
    use DiemFramework::CoreAddresses;
    use DiemFramework::Subsidy;
    use DiemFramework::ProofOfFee;
    use DiemFramework::DiemSystem;
    use DiemFramework::TowerState;
    use DiemFramework::Globals;
    use Std::Vector;
    use DiemFramework::Stats;
    use DiemFramework::AutoPay;
    use DiemFramework::Epoch;
    use DiemFramework::DiemConfig;
    use DiemFramework::DiemAccount;
    use DiemFramework::Burn;
    use DiemFramework::FullnodeSubsidy; 
    use DiemFramework::RecoveryMode;
    use DiemFramework::Jail;
    use DiemFramework::TransactionFee;
    use DiemFramework::MultiSigPayment;
    use DiemFramework::DonorDirected;
    use DiemFramework::MusicalChairs;
    use DiemFramework::InfraEscrow;
    // use DiemFramework::Debug::print;


    //// V6 ////
    // THIS IS TEMPORARY
    // depends on the future "musical chairs" algo.
    const MOCK_VAL_SIZE: u64 = 21;

    // TODO: this will depend on an adjustment algo.
    // const MOCK_BASELINE_CONSENSUS_FEES: u64 = 1000000;

    // This function is called by block-prologue once after n blocks.
    // Function code: 01. Prefix: 180001
    public fun reconfigure(vm: &signer, height_now: u64) {
        CoreAddresses::assert_vm(vm);
        

        ///////// SETTLE ACCOUNTS OF PREVIOUS EPOCH /////////
        // Update all slow wallet limits
        DiemAccount::slow_wallet_epoch_drip(vm, Globals::get_unlock()); // todo
        // print(&800100);

        // Check compliance of nodes
        let height_start = Epoch::get_timer_height_start();
        // print(&800200);
        let (outgoing_compliant_set, new_set_size) = 
            MusicalChairs::stop_the_music(vm, height_start, height_now);
        
        // print(&800300);

        // get the total fees produced before we start spending them.
        let total_fees = TransactionFee::get_fees_collected();
        // Get the consensus reward established at the beginning of the epoch
        // so we know what to pay people
        let (reward, _, _) = ProofOfFee::get_consensus_reward();   

        // process the oracles first (previously the identiy reward)
        process_fullnodes(vm, reward);
        // print(&800400);
        
        // print(&800500);
        
        process_validators(vm, reward, &outgoing_compliant_set, total_fees);
        // print(&800600);

        // process the non performing nodes: jail
        process_jail(vm, &outgoing_compliant_set);
        // print(&800600);
        // EVERYONE SHOULD BE PAID UP AT THIS POINT
        // after everyone is paid from the chain's Fee account
        // we can burn the remainder.
        // Note we assume Oracle subsidy was paid prior to this.

        // TODO: implement what happens to the matching donation algo
        // depending on the validator's preferences.
        // TransactionFee::ol_burn_fees(vm);


        let proposed_set = propose_new_set(vm, &outgoing_compliant_set, new_set_size);

        // print(&800700);

        root_service_billing(vm);
        // print(&801000);

        // reset_counters(vm, proposed_set, outgoing_compliant_set, height_now);
        // print(&801100);
        ///////// PREPARE NEXT EPOCH /////////

        // let proposed_set = propose_new_set(vm, &outgoing_compliant_set, new_set_size);


        // print(&800800);

        // Now we need to collect coins from infrastructure escrow, to temporarily fund the network fee address for the next set.
        // Note in step 
        InfraEscrow::epoch_boundary_collection(vm, reward * Vector::length(&proposed_set));

        // let fees = TransactionFee::get_fees_collected();
        // print(&fees);

        // print(&800900);



        reset_counters(vm, &proposed_set, outgoing_compliant_set, height_now);
        // print(&8001000);

        // Reconfig should be the last event.
        // Reconfigure the network
        DiemSystem::bulk_update_validators(vm, proposed_set);

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

              // don't pay while we are in recovery mode, since that creates
              // a frontrunning opportunity
              // if (!RecoveryMode::is_recovery()){ 
                FullnodeSubsidy::distribute_fullnode_subsidy(vm, addr, miner_subsidy);
              // }
            };

            k = k + 1;
        };
    }

    fun process_validators(
        vm: &signer,
        subsidy_units: u64,
        outgoing_compliant_set: &vector<address>,
        fees_collected: u64,
    ) {
        // Process outgoing validators:
        // Distribute Transaction fees and subsidy payments to all outgoing validators

        if (Vector::is_empty<address>(outgoing_compliant_set)) return;

        // don't pay while we are in recovery mode, since that creates
        // a frontrunning opportunity
        if (subsidy_units > 0 && !RecoveryMode::is_recovery()) {
            Subsidy::process_fees(vm, outgoing_compliant_set);
        };

        // after everyone is paid from the chain's Fee account
        // we can burn the excess fees from the epoch
        Burn::reset_ratios(vm);

        Burn::epoch_burn_fees(vm, fees_collected);

    }

    fun process_jail(vm: &signer, outgoing_compliant_set: &vector<address>) {
        let all_previous_vals = DiemSystem::get_val_set_addr();
        let i = 0;
        while (i < Vector::length<address>(&all_previous_vals)) {
            let addr = *Vector::borrow(&all_previous_vals, i);

            if (
              
              // if they are compliant, remove the consecutive fail, otherwise jail
              // V6 Note: audit functions are now all contained in
              // ProofOfFee.move and exludes validators at auction time.

              Vector::contains(outgoing_compliant_set, &addr)
            ) {
              // print(&902);
                // also reset the jail counter for any successful unjails
                Jail::remove_consecutive_fail(vm, addr);
            } else {
              // print(&903);
              Jail::jail(vm, addr);
            };
            i = i+ 1;
        };
        // print(&904);
    }

    fun propose_new_set(vm: &signer, outgoing_compliant_set: &vector<address>, n_musical_chairs: u64): vector<address> 
    {
        let proposed_set = Vector::empty<address>();

        // If we are in recovery mode, we use the recovery set.
        if (RecoveryMode::is_recovery()) {
            let recovery_vals = RecoveryMode::get_debug_vals();
            if (Vector::length(&recovery_vals) > 0) {
              proposed_set = recovery_vals
            }
        } else { // Default case: Proof of Fee
            //// V6 ////
            // CONSENSUS CRITICAL
            // pick the validators based on proof of fee.
            // false because we want the default behavior of the function: filtered by audit
            // print(&60000);
            let sorted_bids = ProofOfFee::get_sorted_vals(false);
            let (auction_winners, price) = ProofOfFee::fill_seats_and_get_price(vm, n_musical_chairs, &sorted_bids, outgoing_compliant_set);
            // print(&800700);

            // charge the validators for the proof of fee in advance of the epoch
            DiemAccount::vm_multi_pay_fee(vm, &auction_winners, price, &b"proof of fee");

            // let fees = TransactionFee::get_fees_collected();
            // print(&fees);
            // print(&800800);

            proposed_set = auction_winners
        };

        //////// Failover Rules ////////
        // If the cardinality of validator_set in the next epoch is less than 4, 
        // if we are failing to qualify anyone. Pick top 1/2 of outgoing compliant validator set
        // by proposals. They are probably online.
        if (Vector::length<address>(&proposed_set) <= 3) 
            proposed_set = 
              Stats::get_sorted_vals_by_props(vm, Vector::length<address>(outgoing_compliant_set) / 2);

        // If still failing...in extreme case if we cannot qualify anyone.
        // Don't change the validator set. we keep the same validator set. 
        if (Vector::length<address>(&proposed_set) <= 3)
            proposed_set = DiemSystem::get_val_set_addr(); 
                // Patch for april incident. Make no changes to validator set.

        // Usually an issue in staging network for QA only.
        // This is very rare and theoretically impossible for network with 
        // at least 6 nodes and 6 rounds. If we reach an epoch boundary with 
        // at least 6 rounds, we would have at least 2/3rd of the validator 
        // set with at least 66% liveliness. 
        proposed_set
    }
    
    fun reset_counters(
        vm: &signer,
        proposed_set: &vector<address>,
        outgoing_compliant: vector<address>,
        height_now: u64
    ) {
        // print(&800900100);

        // Reset Stats
        Stats::reconfig(vm, proposed_set);
        // print(&800900101);

        // Migrate TowerState list from elegible.
        TowerState::reconfig(vm, &outgoing_compliant);
        // print(&800900102);

        // process community wallets
        DonorDirected::process_donor_directed_accounts(vm, DiemConfig::get_current_epoch());
        // print(&800900103);

        AutoPay::reconfig_reset_tick(vm);
        // print(&800900104);

        Epoch::reset_timer(vm, height_now);
        // print(&800900105);

        RecoveryMode::maybe_remove_debug_at_epoch(vm);
        // print(&800900106);

        TransactionFee::epoch_reset_fee_maker(vm);


        // trigger the thermostat if the reward needs to be adjusted
        ProofOfFee::reward_thermostat(vm);
        // print(&800900107);

        // print(&800900108);
    }

    fun root_service_billing(vm: &signer) {
      MultiSigPayment::root_security_fee_billing(vm);
    }


}
}