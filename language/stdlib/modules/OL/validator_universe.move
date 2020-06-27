address 0x0 {
    module ValidatorUniverse {
        use 0x0::Vector;
        use 0x0::Transaction;
        use 0x0::Signer;
        use 0x0::FixedPoint32;
        use 0x0::Stats;
        use 0x0::Option;

        struct ValidatorEpochInfo {
            validator_address: address,
            mining_epoch_count: u64,
            weight: u64
        }

        // resource for tracking the universe of accounts that have submitted a mined proof correctly, with the epoch number.
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
            let collection = borrow_global_mut<ValidatorUniverse>(0xA550C18);
            if(!validator_exists_in_universe(collection, addr))
            Vector::push_back<ValidatorEpochInfo>(&mut collection.validators,
                ValidatorEpochInfo{
                validator_address: addr,
                mining_epoch_count: 0,
                weight: 0
                });
        }

        // OL A simple public function to query the EligibleValidators.
        // Only system addresses should be able to access this function
        // Eligible validators are all those nodes who have mined a VDF proof at any time.
        // TODO (nelaturuk): Wonder if this helper is necessary since it is just stripping the Validator Universe vector of other fields.
        public fun get_eligible_validators(account: &signer) : vector<address> acquires ValidatorUniverse {
            let sender = Signer::address_of(account);
            Transaction::assert(sender == 0x0 || sender == 0xA550C18, 401);

            let eligible_validators = Vector::empty<address>();
            // Create a vector with all eligible validator addresses
            // Get all the data from the ValidatorUniverse resource stored in the association/system address.
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

        // Simple convenience function to lookup if a validator exists in ValidatorUniverse structure.
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

        //increment the number of epochs the validator has beeing mining
        //vdf proofs for. updates resource ValidatorEpochInfo in system address.
        public fun update_validator_epoch_count(addr: address) acquires ValidatorUniverse{
            let sender = Transaction::sender();
            Transaction::assert(sender == 0x0 || sender == 0xA550C18, 401);
            let collection = borrow_global_mut<ValidatorUniverse>(0xA550C18);

            // Getting index of the validator
            let index_vec = get_validator_index_(&collection.validators, addr);

            // TODO: Do we need error handling for this assert?
            Transaction::assert(Option::is_some(&index_vec), 8002);
            let index = *Option::borrow(&index_vec);

            let validator_list = &mut collection.validators;
            let validatorInfo = Vector::borrow_mut<ValidatorEpochInfo>(validator_list, index);

            // update the Resource with +1 epoch increment. This is enforced by
            // Redeem::end_redeem() to check that the miner has been doing
            // validation AND that there are mining proofs presented in the last/current epoch.
            validatorInfo.mining_epoch_count = validatorInfo.mining_epoch_count + 1;
        }

        // This function is the Proof of Weight. This is what calculates the values
        // for the consensus vote power, which will be used by Reconfiguration to call LibraSystem::bulk_update_validators.
        public fun proposed_upcoming_validator_set_weights(addr: address, epoch_length:u64, current_block_height: u64): u64 acquires ValidatorUniverse{
            let sender = Transaction::sender();
            Transaction::assert(sender == 0x0 || sender == 0xA550C18, 401);

            // borrow the state/resource of ValidatorUniverse
            let collection = borrow_global_mut<ValidatorUniverse>(0xA550C18);

            // Getting index of the validator
            let index_vec = get_validator_index_(&collection.validators, addr);
            Transaction::assert(Option::is_some(&index_vec), 8002);
            let index = *Option::borrow(&index_vec);

            let validator_list = &mut collection.validators;
            let validatorInfo = Vector::borrow_mut<ValidatorEpochInfo>(validator_list, index);
            // We want miners that have been mining for longest continuous amount of epochs
            // mining_epoch_count is many continuous epochs has the validator submitted VDF proofs for.
            let weight = validatorInfo.mining_epoch_count;
            if (!check_if_active_validator({{validatorInfo.validator_address}}, epoch_length, current_block_height))
            {
                weight = 0
            };
            validatorInfo.weight = weight;
            weight
        }

        // Get the index of the validator by address in the `validators` vector
        fun get_validator_index_(validators: &vector<ValidatorEpochInfo>, addr: address): Option::T<u64>{
            let size = Vector::length(validators);
            if (size == 0) {
                return Option::none()
            };

            let i = 0;
            while (i < size) {
                let validator_info_ref = Vector::borrow(validators, i);
                if (validator_info_ref.validator_address == addr) {
                    return Option::some(i)
                };
                i = i + 1;
            };

            return Option::none()
        }

        public fun check_if_active_validator(addr: address, epoch_length: u64, current_block_height: u64): bool {
            // Calculate start and end block height for the current epoch
            // What about empty blocks that get created after every epoch? 
            let epoch_length = epoch_length;
            let end_block_height = current_block_height;
            
            // Abort if epoch_length is greater than current block height
            Transaction::assert(end_block_height >= epoch_length, 010008003);
            
            let start_block_height = end_block_height - epoch_length;
            
            // Calculating threshold which is 90% of the blocks.
            let threshold_signing = FixedPoint32::divide_u64(90, FixedPoint32::create_from_rational(100, 1)) * epoch_length;

            let active_validator = Stats::node_heuristics(addr, start_block_height, end_block_height);
            if (active_validator < threshold_signing) {
                return false
            };
            true
        }

        public fun get_validator_weight(addr: address): Option::T<u64> acquires ValidatorUniverse{
            let sender = Transaction::sender();
            Transaction::assert(sender == 0x0 || sender == 0xA550C18, 401);
            let collection = borrow_global<ValidatorUniverse>(0xA550C18);

            // Getting index of the validator
            let index_vec = get_validator_index_(&collection.validators, addr);
            if (!Option::is_some(&index_vec)){
                return Option::none()
            };
            let index = *Option::borrow(&index_vec);
            let validator_list = &collection.validators;
            let validatorInfo = Vector::borrow<ValidatorEpochInfo>(validator_list, index);
            return Option::some(validatorInfo.weight)
        }

        // TODO: Can we remove if this is deprecated?
        public fun get_total_voting_power(): u64 acquires ValidatorUniverse {
            let sender = Transaction::sender();
            Transaction::assert(sender == 0x0 || sender == 0xA550C18, 401);

            let collection = borrow_global<ValidatorUniverse>(0xA550C18);
            let validator_list = &collection.validators;
            let i = 0;
            let total_voting_power = 0;
            let len = Vector::length<ValidatorEpochInfo>(validator_list);
            while (i < len) {
            let validatorInfo = Vector::borrow<ValidatorEpochInfo>(validator_list, i);
            total_voting_power = total_voting_power + validatorInfo.weight;
            i = i + 1;
            };
            total_voting_power
        }
    }
}
