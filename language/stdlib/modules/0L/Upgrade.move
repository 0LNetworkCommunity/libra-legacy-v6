address 0x1 {

    module Upgrade {
        use 0x1::Signer;
        use 0x1::Vector;
        use 0x1::CoreAddresses;
        /// Structs for UpgradePayload resource
        resource struct UpgradePayload {
            payload: vector<u8>, 
        }
    
        /// Structs for UpgradeHistory resource
        struct UpgradeBlobs {
            upgraded_version: u64,
            upgraded_payload: vector<u8>,
            validators_signed: vector<address>,
            consensus_height: u64,
        }
    
        resource struct UpgradeHistory {
            records: vector<UpgradeBlobs>, 
        }
    
        public fun initialize(account: &signer) {
            assert(Signer::address_of(account) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 11111); // TODO: error code
            move_to(account, UpgradePayload{payload: x""});
            move_to(account, UpgradeHistory{
                records: Vector::empty<UpgradeBlobs>()},
            );
        }
    
        public fun set_update(account: &signer, payload: vector<u8>) acquires UpgradePayload {
            assert(Signer::address_of(account) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 11111); // TODO: error code
            assert(exists<UpgradePayload>(CoreAddresses::LIBRA_ROOT_ADDRESS()), 11111); // TODO: error code
            let temp = borrow_global_mut<UpgradePayload>(CoreAddresses::LIBRA_ROOT_ADDRESS());
            temp.payload = payload;
        }
    
        public fun reset_payload(account: &signer) acquires UpgradePayload {
            assert(Signer::address_of(account) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 11111); // TODO: error code
            assert(exists<UpgradePayload>(CoreAddresses::LIBRA_ROOT_ADDRESS()), 11111); // TODO: error code
            let temp = borrow_global_mut<UpgradePayload>(CoreAddresses::LIBRA_ROOT_ADDRESS());
            temp.payload = Vector::empty<u8>();
        }
    
        public fun record_history(
            account: &signer, 
            upgraded_version: u64, 
            upgraded_payload: vector<u8>, 
            validators_signed: vector<address>,
            consensus_height: u64,
        ) acquires UpgradeHistory {
            assert(Signer::address_of(account) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 11111); // TODO: error code
            let new_record = UpgradeBlobs {
                upgraded_version: upgraded_version,
                upgraded_payload: upgraded_payload,
                validators_signed: validators_signed,
                consensus_height: consensus_height,
            };
            let history = borrow_global_mut<UpgradeHistory>(CoreAddresses::LIBRA_ROOT_ADDRESS());
            Vector::push_back(&mut history.records, new_record);
        }
    
        public fun retrieve_latest_history(): (u64, vector<u8>, vector<address>, u64) acquires UpgradeHistory {
            let history = borrow_global<UpgradeHistory>(CoreAddresses::LIBRA_ROOT_ADDRESS());
            let len = Vector::length<UpgradeBlobs>(&history.records);
            if (len == 0) {
                return (0, Vector::empty<u8>(), Vector::empty<address>(), 0)
            };
            let entry = Vector::borrow<UpgradeBlobs>(&history.records, len-1);
            (entry.upgraded_version, *&entry.upgraded_payload, *&entry.validators_signed, entry.consensus_height)
        }
    
        public fun has_upgrade(): bool acquires UpgradePayload {
            assert(exists<UpgradePayload>(CoreAddresses::LIBRA_ROOT_ADDRESS()), 11111); // TODO: error code
            !Vector::is_empty(&borrow_global<UpgradePayload>(CoreAddresses::LIBRA_ROOT_ADDRESS()).payload)
        }
    
        public fun get_payload(): vector<u8> acquires UpgradePayload {
            assert(exists<UpgradePayload>(CoreAddresses::LIBRA_ROOT_ADDRESS()), 11111); // TODO: error code
            *&borrow_global<UpgradePayload>(CoreAddresses::LIBRA_ROOT_ADDRESS()).payload
        }

        //////// FOR E2E Testing ////////
        // Do not delete these lines. Uncomment when needed to generate e2e test fixtures.
        // 
        // use 0x1::Debug::print;
        // public fun foo() {
        //     print(&0x050D1AC);
        // }
    }
}
    