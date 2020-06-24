address 0x0 {
    module ValidatorUniverse {
        use 0x0::Vector;
        use 0x0::Transaction;
        use 0x0::Signer;
        use 0x0::LibraBlock;
        use 0x0::FixedPoint32;
        use 0x0::Stats;

        struct ValidatorEpochInfo {
            validator_address: address, 
            mining_epoch_count: u64,
            weight: u64
        }
    
        // resource for tracking the universe of accounts that have submitted a proof correctly, with the epoch number.
        resource struct ValidatorUniverse {
            validators: vector<ValidatorEpochInfo>
        }

        // function to initialize ValidatorUniverse in genesis.
        // This is triggered in new epoch by Configuration in Genesis.move
        public fun initialize(account: &signer){
            // Check for transactions sender is association
            let sender = Signer::address_of(account);
            Transaction::assert(sender == 0xA550C18, 8001);
    
            move_to<ValidatorUniverse>(account, ValidatorUniverse {
                validators: Vector::empty<ValidatorEpochInfo>()
            });
        }

        // This function is called to add validator to the validator universe.
        public fun add_validator(addr: address) acquires ValidatorUniverse {
            let sender = Transaction::sender();
            Transaction::assert(sender == 0x0 || sender == 0xA550C18, 401);
            
            let collection = borrow_global_mut<ValidatorUniverse>(0xA550C18);
            if(!validator_exists_in_universe(collection, addr))
            Vector::push_back<ValidatorEpochInfo>(&mut collection.validators,
                ValidatorEpochInfo{
                validator_address: addr,
                mining_epoch_count: 0,
                weight: 0
                });
        }
    
        // A simple public function to query the EligibleValidators.
        // Only association should be able to access this function
        public fun get_eligible_validators(account: &signer) : vector<address> acquires ValidatorUniverse {
            let sender = Signer::address_of(account);
            Transaction::assert(sender == 0x0 || sender == 0xA550C18, 401);
            
            let eligible_validators = Vector::empty<address>();
            // Create a vector with all eligible validator addresses
            let collection = borrow_global<ValidatorUniverse>(0xA550C18);
            let i = 0;
            let validator_list = &collection.validators;
            let len = Vector::length<ValidatorEpochInfo>(validator_list);
            while (i < len) {
                Vector::push_back(&mut eligible_validators, Vector::borrow<ValidatorEpochInfo>(validator_list, i).validator_address);
                i = i + 1;
            };
            
            eligible_validators
        }

        fun validator_exists_in_universe(validatorUniverse: &ValidatorUniverse, addr: address): bool {
            let i = 0;
            let validator_list = &validatorUniverse.validators;
            let len = Vector::length<ValidatorEpochInfo>(validator_list);
            while (i < len) {
            if (Vector::borrow<ValidatorEpochInfo>(validator_list, i).validator_address == addr) return true;
            i = i + 1;
            };
            false
        }
    
        public fun update_validator_epoch_count(addr: address) acquires ValidatorUniverse{
            let sender = Transaction::sender();
            Transaction::assert(sender == 0x0 || sender == 0xA550C18, 401);

            let collection = borrow_global_mut<ValidatorUniverse>(0xA550C18);
            let i = 0;
            let validator_list = &mut collection.validators;
            let len = Vector::length<ValidatorEpochInfo>(validator_list);
            while (i < len) {
            let validatorInfo = Vector::borrow_mut<ValidatorEpochInfo>(validator_list, i); 
            if (validatorInfo.validator_address == addr) {
                validatorInfo.mining_epoch_count = validatorInfo.mining_epoch_count + 1; 
                break 
            };
            i = i + 1;
            };
        }

        public fun update_validator_weight(addr: address, index: u64): u64 acquires ValidatorUniverse{
            let sender = Transaction::sender();
            Transaction::assert(sender == 0x0 || sender == 0xA550C18, 401);

            let collection = borrow_global_mut<ValidatorUniverse>(0xA550C18);
            let validator_list = &mut collection.validators;
            let validatorInfo = Vector::borrow_mut<ValidatorEpochInfo>(validator_list, index);
            Transaction::assert(validatorInfo.validator_address == addr, 8002);

            // We want miners that have been mining for longest amount of new_epoch_validator_universe_update
            // How many epochs has the validator submitted VDF proofs for.
            let weight = validatorInfo.mining_epoch_count;
            
            // TODO: OL: Confirm the current epoch length assuming it as 15 because of round check
            // Calculate start and end block height for the current epoch
            // What about empty blocks that get created after every epoch? 
            let epoch_length = 15;
            let end_block_height = LibraBlock::get_current_block_height();
            let start_block_height = end_block_height - epoch_length;
            let threshold_signing = FixedPoint32::divide_u64(90, FixedPoint32::create_from_rational(100, 1)) * epoch_length;

            let active_validator = Stats::node_heuristics({{validatorInfo.validator_address}}, start_block_height, end_block_height);
            if (active_validator < threshold_signing) {
                weight = 0;
            };
            validatorInfo.weight = weight;
            weight
        }

        public fun get_validator_weight(addr: address, index: u64): u64 acquires ValidatorUniverse{
            let sender = Transaction::sender();
            Transaction::assert(sender == 0x0 || sender == 0xA550C18, 401);

            let collection = borrow_global<ValidatorUniverse>(0xA550C18);
            let validator_list = &collection.validators;
            let validatorInfo = Vector::borrow<ValidatorEpochInfo>(validator_list, index);
            Transaction::assert(validatorInfo.validator_address == addr, 8002);
            validatorInfo.weight
        }
    }
}