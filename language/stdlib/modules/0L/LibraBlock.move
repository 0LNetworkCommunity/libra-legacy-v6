address 0x1 {

module LibraBlock {
    use 0x1::CoreAddresses;
    use 0x1::Errors;
    use 0x1::Event;
    use 0x1::LibraSystem;
    use 0x1::LibraTimestamp;
    use 0x1::Stats;
    use 0x1::Reconfigure;
    use 0x1::Globals;
    use 0x1::Vector;

    resource struct BlockMetadata {
        /// Height of the current block
        height: u64,
        // TODO 0L: prefer not modifying this struct. Need to find a way to read from new_block_events.
        voters: vector<address>,
        /// Handle where events with the time of new blocks are emitted
        new_block_events: Event::EventHandle<Self::NewBlockEvent>,
    }

    spec module {
        invariant [global] LibraTimestamp::is_operating() ==> is_initialized();
    }

    struct NewBlockEvent {
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
        LibraTimestamp::assert_genesis();
        // Operational constraint, only callable by the Association address
        CoreAddresses::assert_libra_root(account);

        assert(!is_initialized(), Errors::already_published(EBLOCK_METADATA));
        move_to<BlockMetadata>(
            account,
            BlockMetadata {
                height: 0,
                voters: Vector::singleton(0x0), // 0L Change TODO: 0L: (Nelaturuk) Remove this. It's a placeholder.
                new_block_events: Event::new_event_handle<Self::NewBlockEvent>(account),
            }
        );
    }
    spec fun initialize_block_metadata {
        include LibraTimestamp::AbortsIfNotGenesis;
        include CoreAddresses::AbortsIfNotLibraRoot;
        aborts_if is_initialized() with Errors::ALREADY_PUBLISHED;
        ensures is_initialized();
        ensures get_current_block_height() == 0;
    }

    /// Helper function to determine whether this module has been initialized.
    fun is_initialized(): bool {
        exists<BlockMetadata>(CoreAddresses::LIBRA_ROOT_ADDRESS())
    }

    /// Set the metadata for the current block.
    /// The runtime always runs this before executing the transactions in a block.
    fun block_prologue(
        vm: &signer,
        round: u64,
        timestamp: u64,
        previous_block_votes: vector<address>,
        proposer: address
    ) acquires BlockMetadata {
        LibraTimestamp::assert_operating();
        // Operational constraint: can only be invoked by the VM.
        CoreAddresses::assert_vm(vm);

        // Authorization
        assert(
            proposer == CoreAddresses::VM_RESERVED_ADDRESS() || LibraSystem::is_validator(proposer),
            Errors::requires_address(EVM_OR_VALIDATOR)
        );


/////////////// TODO: WIP OUT FOR MERGE PROCESSS //////// 
        Stats::process_set_votes(vm, &previous_block_votes);
        Stats::inc_prop(vm, *&proposer);

        let block_metadata_ref = borrow_global_mut<BlockMetadata>(CoreAddresses::LIBRA_ROOT_ADDRESS());
        LibraTimestamp::update_global_time(vm, proposer, timestamp);
        block_metadata_ref.height = block_metadata_ref.height + 1;
        block_metadata_ref.voters = *&previous_block_votes;
        Event::emit_event<NewBlockEvent>(
            &mut block_metadata_ref.new_block_events,
            NewBlockEvent {
                round,
                proposer,
                previous_block_votes,
                time_microseconds: timestamp,
            }
        );

        // 0L implementation of reconfiguration.
        if ((get_current_block_height() % Globals::get_epoch_length()) == 0 ) {
          // TODO: We don't need to pass block height to ReconfigureOL. It should use the BlockMetadata. But there's a circular reference there when we try.
          Reconfigure::reconfigure(vm);
        }
    }
    spec fun block_prologue {
        include LibraTimestamp::AbortsIfNotOperating;
        include CoreAddresses::AbortsIfNotVM{account: vm};
        aborts_if proposer != CoreAddresses::VM_RESERVED_ADDRESS() && !LibraSystem::spec_is_validator(proposer)
            with Errors::REQUIRES_ADDRESS;
        ensures LibraTimestamp::spec_now_microseconds() == timestamp;
        ensures get_current_block_height() == old(get_current_block_height()) + 1;

        /// The below counter overflow is assumed to be excluded from verification of callers.
        aborts_if [assume] get_current_block_height() + 1 > MAX_U64 with EXECUTION_FAILURE;
    }

    /// Get the current block height
    public fun get_current_block_height(): u64 acquires BlockMetadata {
        borrow_global<BlockMetadata>(CoreAddresses::LIBRA_ROOT_ADDRESS()).height
    }

    // Get the previous block voters
    public fun get_previous_voters(): vector<address> acquires BlockMetadata {
       let voters = *&borrow_global<BlockMetadata>(CoreAddresses::LIBRA_ROOT_ADDRESS()).voters;
       return voters
    }

    // **************** FUNCTION SPECIFICATIONS ****************

    spec module {
        pragma verify;
    }
}

}
