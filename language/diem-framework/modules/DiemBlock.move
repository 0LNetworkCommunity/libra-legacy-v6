address 0x1 {

//////// 0L /////////

/// This module defines a struct storing the metadata of the block and new block events.
/// it also contains all of the block prologue logic which is called from the Rust executor.

/// For 0L the following changes are applied to the block prologue

// Autopay gets processed when the Autopay Tick occurs. This occurs on round X (TODO)

// Round 2
// On the Rust side, every round 2, is an Upgrade Tick. That's when the VM checks if there are upgrade proposals that have reached consensus, and if so and there is an upgrade payload available (binary) then a writeset of that binary is executed and the 0x1 address is overwritten with the upgrade binary.

// Round 3
// In Move, we check if we are in a Migrate Tick, which is every round 3. (TODO: should this be 2?). That's when any data and state migrations that can happen on the fly will occur.

// Epoch Boundary
// In the prologue we finally check for a roughtime 24h period to have passed, and that is what triggers an epoch boundary, and the necessary reconfiguration and account updates.



module DiemBlock {
    use 0x1::CoreAddresses;
    use 0x1::Errors;
    use 0x1::Event;
    use 0x1::DiemSystem;
    use 0x1::DiemTimestamp;
    //////// 0L ////////
    use 0x1::EpochBoundary;
    use 0x1::Stats;
    use 0x1::AutoPay;
    use 0x1::Epoch;
    use 0x1::GAS::GAS;
    use 0x1::DiemAccount;
    use 0x1::Migrations;
    use 0x1::TowerState;
    use 0x1::MigrateJail;

    struct BlockMetadata has key {
        /// Height of the current block
        height: u64,
        /// Handle where events with the time of new blocks are emitted
        new_block_events: Event::EventHandle<Self::NewBlockEvent>,
    }

    struct NewBlockEvent has drop, store {
        round: u64,
        proposer: address,
        previous_block_votes: vector<address>,

        /// On-chain time during  he block at the given height
        time_microseconds: u64,
    }

    /// The `BlockMetadata` resource is in an invalid state
    const EBLOCK_METADATA: u64 = 0;
    /// An invalid signer was provided. Expected the signer to be the VM or a Validator.
    const EVM_OR_VALIDATOR: u64 = 1;

    /// This can only be invoked by the Association address, and only a single time.
    /// Currently, it is invoked in the genesis transaction
    public fun initialize_block_metadata(account: &signer) {
        DiemTimestamp::assert_genesis();
        // Operational constraint, only callable by the Association address
        CoreAddresses::assert_diem_root(account);

        assert(!is_initialized(), Errors::already_published(EBLOCK_METADATA));
        move_to<BlockMetadata>(
            account,
            BlockMetadata {
                height: 0,
                new_block_events: Event::new_event_handle<Self::NewBlockEvent>(account),
            }
        );
    }
    spec initialize_block_metadata {
        include DiemTimestamp::AbortsIfNotGenesis;
        include CoreAddresses::AbortsIfNotDiemRoot;
        aborts_if is_initialized() with Errors::ALREADY_PUBLISHED;
        ensures is_initialized();
        ensures get_current_block_height() == 0;
    }

    /// Helper function to determine whether this module has been initialized.
    fun is_initialized(): bool {
        exists<BlockMetadata>(CoreAddresses::DIEM_ROOT_ADDRESS())
    }
    /// Set the metadata for the current block.
    /// The runtime always runs this before executing the transactions in a block.
    fun block_prologue(
        vm: signer,
        round: u64,
        timestamp: u64,
        previous_block_votes: vector<address>,
        proposer: address
    ) acquires BlockMetadata {
        DiemTimestamp::assert_operating();
        // Operational constraint: can only be invoked by the VM.
        CoreAddresses::assert_vm(&vm);
        // Authorization
        assert(
            proposer == CoreAddresses::VM_RESERVED_ADDRESS() || DiemSystem::is_validator(proposer),
            Errors::requires_address(EVM_OR_VALIDATOR)
        );

        //////// 0L ////////
        // increment stats        
        Stats::process_set_votes(&vm, &previous_block_votes);
        Stats::inc_prop(&vm, *&proposer);    
        
        if (AutoPay::tick(&vm)){
            // triggers autopay at beginning of each epoch 
            // tick is reset at end of previous epoch
            DiemAccount::process_escrow<GAS>(&vm);
            AutoPay::process_autopay(&vm);
        };       

        // Do any pending migrations
        // TODO: should this be round 2 (when upgrade writeset happens). May be an off-by-one.
        if (round == 3){
          // safety. Maybe init Migration struct
          Migrations::init(&vm);
          TowerState::init_difficulty(&vm);
          MigrateJail::do_it(&vm);
        };    

        let block_metadata_ref = borrow_global_mut<BlockMetadata>(CoreAddresses::DIEM_ROOT_ADDRESS());
        DiemTimestamp::update_global_time(&vm, proposer, timestamp);

        block_metadata_ref.height = block_metadata_ref.height + 1;
        Event::emit_event<NewBlockEvent>(
            &mut block_metadata_ref.new_block_events,
            NewBlockEvent {
                round,
                proposer,
                previous_block_votes,
                time_microseconds: timestamp,
            }
        );

        //////// 0L ////////
        // EPOCH BOUNDARY
        let height = get_current_block_height();
        if (Epoch::epoch_finished(height)) {

          // TODO: We don't need to pass block height to EpochBoundaryOL. 
          // It should use the BlockMetadata. But there's a circular reference 
          // there when we try.
          EpochBoundary::reconfigure(&vm, height);
        };
    
    }
    spec block_prologue {
        include DiemTimestamp::AbortsIfNotOperating;
        include CoreAddresses::AbortsIfNotVM{account: vm};
        aborts_if proposer != CoreAddresses::VM_RESERVED_ADDRESS() && !DiemSystem::spec_is_validator(proposer)
            with Errors::REQUIRES_ADDRESS;
        ensures DiemTimestamp::spec_now_microseconds() == timestamp;
        ensures get_current_block_height() == old(get_current_block_height()) + 1;

        aborts_if get_current_block_height() + 1 > MAX_U64 with EXECUTION_FAILURE;
        include BlockPrologueEmits;
    }
    spec schema BlockPrologueEmits {
        round: u64;
        timestamp: u64;
        previous_block_votes: vector<address>;
        proposer: address;
        let handle = global<BlockMetadata>(CoreAddresses::DIEM_ROOT_ADDRESS()).new_block_events;
        let msg = NewBlockEvent {
            round,
            proposer,
            previous_block_votes,
            time_microseconds: timestamp,
        };
        emits msg to handle;
    }

    /// Get the current block height
    public fun get_current_block_height(): u64 acquires BlockMetadata {
        assert(is_initialized(), Errors::not_published(EBLOCK_METADATA));
        borrow_global<BlockMetadata>(CoreAddresses::DIEM_ROOT_ADDRESS()).height
    }


    spec module { } // Switch documentation context to module level.

    /// # Initialization
    /// This implies that `BlockMetadata` is published after initialization and stays published
    /// ever after
    spec module {
        invariant DiemTimestamp::is_operating() ==> is_initialized();
    }
}

}
