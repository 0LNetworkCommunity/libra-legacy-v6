address DiemFramework {

module MusicalChairs {
    // use DiemFramework::DiemSystem;
    use DiemFramework::DiemTimestamp;
    use DiemFramework::CoreAddresses;
    use Std::Vector;

    struct Chairs has key {
        // The number of chairs in the game
        current_seats: u64,
        // A small history, for future use.
        history: vector<u64>,
    }

    // With musical chairs we are trying to estimate
    // the number of nodes which the network can support
    // BFT has upperbounds in the low hundreds, but we
    // don't need to hard code it.
    // There also needs to be an upper bound so that there is some 
    // competition among validators.
    // Instead of hard coding a number, and needing to reach social
    // consensus to change it:  we'll determine the size based on 
    // the network's performance as a whole.
    // There are many metrics that can be used. For now we'll use
    // a simple heuristic that is already on chain: compliant node cardinality.
    // Other heuristics may be explored, so long as the information
    // reliably committed to the chain.

    // The rules:
    // Validators who perform, are not guaranteed entry into the 
    // next epoch of the chain. All we are establishing is the ceiling
    // for validators.
    // When the 100% of the validators are performing well
    // the network can safely increase the threshold by 1 node.
    // We can also say if less that 5% fail, no change happens.
    // When the network is performing poorly, greater than 5%, 
    // the threshold is reduced not by a predetermined unit, but
    // to the number of compliant and performant nodes.
    
    /// Called by root in genesis to initialize the GAS coin 
    public fun initialize(
        vm: &signer,
    ) {
        CoreAddresses::assert_diem_root(vm);

        DiemTimestamp::assert_genesis();
        if (exists<Chairs>(@VMReserved)) {
            return
        };

        move_to(vm, Chairs {
            current_seats: 0,
            history: Vector::empty<u64>(),
        });
    }
}
}