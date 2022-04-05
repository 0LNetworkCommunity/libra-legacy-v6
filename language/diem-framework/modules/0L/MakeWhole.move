address 0x1 {
    module MakeWhole {
        use 0x1::CoreAddresses;
        use 0x1::Vector;
        use 0x1::Signer;

        struct Payments has key {
            payees: vector<address>,
            amounts: vector<u64>,
        }


        public fun make_whole_init(vm: &signer){
            CoreAddresses::assert_diem_root(vm);
            if (!exists<Payments>(CoreAddresses::DIEM_ROOT_ADDRESS())) {
                let payees: vector<address> = Vector::empty<address>();
                let amounts: vector<u64> = Vector::empty<u64>();

                // TODO: A new address and amount must be pushed back for each miner that needs to be repaid
                // This can be done more easily in more recent version of move, but it seems 0L currently does not support them. 
                Vector::push_back<address>(&mut payees, @0x01);
                Vector::push_back<u64>(&mut amounts, 10);

                Vector::push_back<address>(&mut payees, @0x02);
                Vector::push_back<u64>(&mut amounts, 20);

                move_to<Payments>(
                    vm, 
                    Payments{
                        payees: payees, 
                        amounts: amounts
                    }
                );
            };
        }

        // add a custom list for testing purposes only. Requires vm as signer
        public fun make_whole_test(vm: &signer, payees: vector<address>, amounts: vector<u64>){
            CoreAddresses::assert_diem_root(vm);
            if (!exists<Payments>(CoreAddresses::DIEM_ROOT_ADDRESS())) {
                move_to<Payments>(
                    vm, 
                    Payments{
                        payees: payees, 
                        amounts: amounts
                    }
                );
            };
        }


        public fun query_make_whole_payment(account: &signer): u64 acquires Payments {
            let addr = Signer::address_of(account);

            let payments = borrow_global<Payments>(
                CoreAddresses::DIEM_ROOT_ADDRESS()
            );

            let (found, i) = Vector::index_of<address>(&payments.payees, &addr);

            if (found) {
                return *Vector::borrow<u64>(&payments.amounts, i)
            }
            else {
                return 0
            }
        }


        public fun remove_make_whole_payment(account: &signer) acquires Payments {
            let addr = Signer::address_of(account);

            let payments = borrow_global_mut<Payments>(
                CoreAddresses::DIEM_ROOT_ADDRESS()
            );

            let (found, i) = Vector::index_of<address>(&payments.payees, &addr);

            if (found) {
                Vector::remove<address>(&mut payments.payees, i);
                Vector::remove<u64>(&mut payments.amounts, i);
            };
        }
    }
}