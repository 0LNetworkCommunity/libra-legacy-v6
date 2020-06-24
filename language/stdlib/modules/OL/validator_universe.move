address 0x0 {
    module ValidatorUniverse {
        use 0x0::Vector;
        use 0x0::Transaction;
        use 0x0::Signer;

        struct ValidatorEpochInfo {
            validator_address: address, 
            mining_epoch_count: u64
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
                mining_epoch_count: 0
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
    
        public fun update_validator(addr: address) acquires ValidatorUniverse{
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
    }
}