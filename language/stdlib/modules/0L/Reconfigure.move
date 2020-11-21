///////////////////////////////////////////////////////////////////////////
// 0L Module
// Epoch Prologue
///////////////////////////////////////////////////////////////////////////
// The prologue for transitioning to next epoch after every n blocks.
// File Prefix for errors: 1801
///////////////////////////////////////////////////////////////////////////

address 0x1 {
module Reconfigure {
    use 0x1::Signer;
    use 0x1::CoreAddresses;
    use 0x1::Subsidy;
    use 0x1::NodeWeight;
    use 0x1::LibraSystem;
    // use 0x1::EpochTimer;
    use 0x1::MinerState;
    use 0x1::Globals;
    use 0x1::Vector;
    use 0x1::Stats;
    use 0x1::LibraTimestamp;
    use 0x1::LibraConfig;

    resource struct Timer { 
        epoch: u64,
        height_start: u64,
        seconds_start: u64
    }


    public fun initialize(vm: &signer) {
        let sender = Signer::address_of(vm);
        assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190201014010);
        move_to<Timer>(
        vm, 
        Timer {
            epoch: 0,
            height_start: 0,
            seconds_start: LibraTimestamp::now_seconds()
            }
        );
    }

    public fun epoch_finished(): bool acquires Timer {
        let epoch_secs = Globals::get_epoch_length();
        let time = borrow_global<Timer>(CoreAddresses::LIBRA_ROOT_ADDRESS());
        LibraTimestamp::now_seconds() > (epoch_secs + time.seconds_start)
    }

    public fun reset_timer(vm: &signer, height: u64) acquires Timer {
        let sender = Signer::address_of(vm);
        assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190201014010);
        let time = borrow_global_mut<Timer>(CoreAddresses::LIBRA_ROOT_ADDRESS());
        time.epoch = LibraConfig::get_current_epoch() + 1;
        time.height_start = height;
        time.seconds_start = LibraTimestamp::now_seconds();
    }

    // This function is called by block-prologue once after n blocks.
    // Function code: 01. Prefix: 180101
    public fun reconfigure(vm: &signer, height_now: u64) acquires Timer{
        assert(Signer::address_of(vm) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 180101014010);        
        let timer = borrow_global<Timer>(CoreAddresses::LIBRA_ROOT_ADDRESS());
        let height_start = timer.height_start;
        // Process outgoing validators:
        // Distribute Transaction fees and subsidy payments to all outgoing validators
        
        let subsidy_units = Subsidy::calculate_Subsidy(vm, height_start, height_now);
        let (outgoing_set, fee_ratio) = LibraSystem::get_fee_ratio(vm, height_start, height_now);
        Subsidy::process_subsidy(vm, subsidy_units, &outgoing_set,  &fee_ratio);
        Subsidy::process_fees(vm, &outgoing_set, &fee_ratio);
        
        // Propose upcoming validator set:
        // Step 1: Sort Top N Elegible validators
        // Step 2: Jail non-performing validators
        // Step 3: Reset counters
        // Step 4: Bulk update validator set (reconfig)

        // prepare_upcoming_validator_set(vm);
        let top_accounts = NodeWeight::top_n_accounts(
            vm, Globals::get_max_validator_per_epoch());
        let jailed_set = LibraSystem::get_jailed_set(vm, height_start, height_now);

        let proposed_set = Vector::empty();
        let i = 0;
        while (i < Vector::length(&top_accounts)) {
            let addr = *Vector::borrow(&top_accounts, i);
            if (!Vector::contains(&jailed_set, &addr)){
                Vector::push_back(&mut proposed_set, addr);
            };
            i = i+ 1;
        };

        // If the cardinality of validator_set in the next epoch is less than 4, we keep the same validator set. 
        if(Vector::length<address>(&proposed_set)<= 4) proposed_set = LibraSystem::get_val_set_addr();
        // Usually an issue in staging network for QA only.
        // This is very rare and theoretically impossible for network with at least 6 nodes and 6 rounds. If we reach an epoch boundary with at least 6 rounds, we would have at least 2/3rd of the validator set with at least 66% liveliness. 

        //Reset Counters
        Stats::reconfig(vm, &proposed_set);
        MinerState::reconfig(vm);
        
        // Reconfigure the network
        LibraSystem::bulk_update_validators(vm, proposed_set);
        reset_timer(vm, height_now);
    }
}
}