///////////////////////////////////////////////////////////////////////////
// Upgrade payload
// File Prefix for errors: 2100
///////////////////////////////////////////////////////////////////////////
address DiemFramework {
module Upgrade {
    use Std::Errors;
    use Std::Signer;
    use Std::Vector;

    /// Structs for UpgradePayload resource
    struct UpgradePayload has key {
        payload: vector<u8>, 
    }

    /// Structs for UpgradeHistory resource
    struct UpgradeBlobs has store {
        upgraded_version: u64,
        upgraded_payload: vector<u8>,
        validators_signed: vector<address>,
        consensus_height: u64,
    }

    struct UpgradeHistory has key {
        records: vector<UpgradeBlobs>, 
    }

    // Function code: 01
    public fun initialize(account: &signer) {
        assert!(Signer::address_of(account) == @DiemRoot, Errors::requires_role(210001)); 
        move_to(account, UpgradePayload{payload: x""});
        move_to(account, UpgradeHistory{
            records: Vector::empty<UpgradeBlobs>()},
        );
    }

    // Function code: 02
    public fun set_update(account: &signer, payload: vector<u8>) acquires UpgradePayload {
        assert!(Signer::address_of(account) == @DiemRoot, Errors::requires_role(210002)); 
        assert!(exists<UpgradePayload>(@DiemRoot), Errors::not_published(210002)); 
        let temp = borrow_global_mut<UpgradePayload>(@DiemRoot);
        temp.payload = payload;
    }

    use DiemFramework::Epoch;
    use DiemFramework::DiemConfig;
    // Can only be called by the VM
    // making public so that we can use in admin scripts of writeset-transaction-generator.
    use DiemFramework::CoreAddresses;

    public fun upgrade_reconfig(vm: &signer) acquires UpgradePayload {
        CoreAddresses::assert_vm(vm);
        reset_payload(vm);
        // This is janky, but there's no other way to get the current block height,
        // unless the prologue gives it to us.
        // The upgrade reconfigure happens on round 2, so we'll increment the
        // new start by 2 from previous.        
        let new_epoch_height = Epoch::get_timer_height_start() + 2; 
        Epoch::reset_timer(vm, new_epoch_height);

        // TODO: check if this has any impact.
        // Update global time by 1 to escape the timestamps check (for deduplication) of DiemConfig::reconfig_
        // that check prevents offline writsets from being written during emergency offline recovery.
        // let timenow = DiemTimestamp::now_microseconds() + 100;
        // use any address except for 0x0 for updating.
        // DiemTimestamp::update_global_time(vm, @0x6, timenow);
        DiemConfig::upgrade_reconfig(vm);
    }    

    // Function code: 03
    public fun reset_payload(account: &signer) acquires UpgradePayload {
        assert!(Signer::address_of(account) == @DiemRoot, Errors::requires_role(210003)); 
        assert!(exists<UpgradePayload>(@DiemRoot), Errors::not_published(210003)); 
        let temp = borrow_global_mut<UpgradePayload>(@DiemRoot);
        temp.payload = Vector::empty<u8>();
    }

    // Function code: 04
    public fun record_history(
        account: &signer, 
        upgraded_version: u64, 
        upgraded_payload: vector<u8>, 
        validators_signed: vector<address>,
        consensus_height: u64,
    ) acquires UpgradeHistory {
        assert!(Signer::address_of(account) == @DiemRoot, Errors::requires_role(210004)); 
        let new_record = UpgradeBlobs {
            upgraded_version: upgraded_version,
            upgraded_payload: upgraded_payload,
            validators_signed: validators_signed,
            consensus_height: consensus_height,
        };
        let history = borrow_global_mut<UpgradeHistory>(@DiemRoot);
        Vector::push_back(&mut history.records, new_record);
    }

    // Function code: 05
    public fun retrieve_latest_history(): (u64, vector<u8>, vector<address>, u64) acquires UpgradeHistory {
        let history = borrow_global<UpgradeHistory>(@DiemRoot);
        let len = Vector::length<UpgradeBlobs>(&history.records);
        if (len == 0) {
            return (0, Vector::empty<u8>(), Vector::empty<address>(), 0)
        };
        let entry = Vector::borrow<UpgradeBlobs>(&history.records, len-1);
        (entry.upgraded_version, *&entry.upgraded_payload, *&entry.validators_signed, entry.consensus_height)
    }

    // Function code: 06
    public fun has_upgrade(): bool acquires UpgradePayload {
        assert!(exists<UpgradePayload>(@DiemRoot), Errors::requires_role(210005)); 
        !Vector::is_empty(&borrow_global<UpgradePayload>(@DiemRoot).payload)
    }

    // Function code: 07
    public fun get_payload(): vector<u8> acquires UpgradePayload {
        assert!(exists<UpgradePayload>(@DiemRoot), Errors::requires_role(210006));
        *&borrow_global<UpgradePayload>(@DiemRoot).payload
    }
}
}
    