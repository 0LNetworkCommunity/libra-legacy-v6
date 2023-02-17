address DiemFramework {

module MusicalChairs {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemTimestamp;
    use DiemFramework::CoreAddresses;
    use DiemFramework::Cases;
    use DiemFramework::Globals;
    use Std::FixedPoint32;
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
            current_seats: Globals::get_val_set_at_genesis(),
            history: Vector::empty<u64>(),
        });
    }

    // get the number of seats in the game
    public fun stop_the_music( // sorry, had to.
      vm: &signer,
      height_start: u64,
      height_end: u64
    ): (vector<address>, u64) acquires Chairs {
        CoreAddresses::assert_diem_root(vm);
        let (compliant, _non, ratio) = eval_compliance(vm, height_start, height_end);

        let chairs = borrow_global_mut<Chairs>(@VMReserved);
        if (FixedPoint32::is_zero(*&ratio)) {
          chairs.current_seats = chairs.current_seats + 1;
        } else if (FixedPoint32::multiply_u64(100, *&ratio) > 5) {
          // remove chairs
          // reduce the validator set to the size of the compliant set.
          chairs.current_seats = Vector::length(&compliant);
        };
        // otherwise do nothing, the validator set is within a tolerable range.

        (compliant, chairs.current_seats)
    }

    // use the Case statistic to determine what proportion of the network is compliant.
    public fun eval_compliance(
      vm: &signer,
      height_start: u64,
      height_end: u64
    ) : (vector<address>, vector<address>, FixedPoint32::FixedPoint32) {
        let validators = DiemSystem::get_val_set_addr();
        let val_set_len = Vector::length(&validators);

        let compliant_nodes = Vector::empty<address>();
        let non_compliant_nodes = Vector::empty<address>();
        
        let i = 0;
        while (i < val_set_len) {
            let addr = Vector::borrow(&validators, i);
            let case = Cases::get_case(vm, *addr, height_start, height_end);
            if (case == 1) {
                Vector::push_back(&mut compliant_nodes, *addr);
            } else {
                Vector::push_back(&mut non_compliant_nodes, *addr);
            };
            i = i + 1;
        };

        let good_len = Vector::length(&compliant_nodes) ;
        let bad_len = Vector::length(&non_compliant_nodes);

        // Note: sorry for repetition but necessary for writing tests and debugging.
        let null = FixedPoint32::create_from_raw_value(0);
        if (good_len > val_set_len) { // safety
          return (Vector::empty(), Vector::empty(), null)
        };

        if (bad_len > val_set_len) { // safety
          return (Vector::empty(), Vector::empty(), null)
        };

        if ((good_len + bad_len) != val_set_len) { // safety
          return (Vector::empty(), Vector::empty(), null)
        };


        let ratio = if (bad_len > 0) {
          FixedPoint32::create_from_rational(bad_len, val_set_len)
        } else {
          null
        };

        (compliant_nodes, non_compliant_nodes, ratio)
    }

    //////// GETTERS ////////

    public fun get_current_seats(): u64 acquires Chairs {
        borrow_global<Chairs>(@VMReserved).current_seats
    }

}
}