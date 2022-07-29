address DiemFramework {
module MakeWhole {
    use DiemFramework::CoreAddresses;
    use Std::Vector;
    use Std::Signer;
    use DiemFramework::Diem;
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    use Std::Errors;

    struct Payments has key {
        payees: vector<address>,
        amounts: vector<u64>,
        paid: vector<bool>,
        coins: Diem::Diem<GAS>,
    }

    const EPAYEE_NOT_DELETED: u64 = 22015;
    const EWRONG_PAYEE: u64 = 22016;
    const EALREADY_PAID: u64 = 22017;

    public fun make_whole_init(vm: &signer){
        CoreAddresses::assert_diem_root(vm);
        if (!exists<Payments>(@DiemRoot)) {
            let payees: vector<address> = Vector::empty<address>();
            let amounts: vector<u64> = Vector::empty<u64>();

            // TODO: A new address and amount must be pushed back for each miner 
            //       that needs to be repaid
            // // This can be done more easily in more recent version of move,
            // Vector::push_back<address>(&mut payees, @0x3f9fb9373492a3ec10714214ab53f071);
            // Vector::push_back<u64>(&mut amounts, 874041484);            
    
            Vector::push_back<address>(&mut payees, @0xb2e86a1bee0e63602920eaa90a37c91e);
            Vector::push_back<u64>(&mut amounts, 582694323);
    
            let i = 0;
            let total = 0;
            let paid = Vector::empty<bool>();

            while (i < Vector::length<u64>(&amounts)) {
                total = total + *Vector::borrow<u64>(&amounts, i);
                i = i + 1;
                Vector::push_back<bool>(&mut paid, false);
            };

            let coins = Diem::mint<GAS>(vm, total);

            move_to<Payments>(
                vm, 
                Payments{
                    payees: payees, 
                    amounts: amounts, 
                    paid: paid,
                    coins: coins
                }
            );
        };
    }

    // add a custom list for testing purposes only. Requires vm as signer
    public fun make_whole_test(vm: &signer, payees: vector<address>, amounts: vector<u64>){
        CoreAddresses::assert_diem_root(vm);
        if (!exists<Payments>(@DiemRoot)) {
            let i = 0;
            let total = 0;
            let paid = Vector::empty<bool>();

            while (i < Vector::length<u64>(&amounts)) {
                total = total + *Vector::borrow<u64>(&amounts, i);
                i = i + 1;
                Vector::push_back<bool>(&mut paid, false);
            };

            let coins = Diem::mint<GAS>(vm, total);

            move_to<Payments>(
                vm, 
                Payments{
                    payees: payees, 
                    amounts: amounts, 
                    paid: paid,
                    coins: coins
                }
            );
        };
    }

    /// claims the make whole payment and returns the amount paid out
    /// ensures that the caller is the one owed the payment at index i
    public fun claim_make_whole_payment(account: &signer, i: u64): u64 acquires Payments{
        // find amount
        let addr = Signer::address_of(account);
        let payments = borrow_global_mut<Payments>(
            @DiemRoot
        );

        // make sure sender is the one owed funds and that the funds have not been paid
        // if i is invalid (<0 or >length) vector will throw error
        assert!(*Vector::borrow<address>(&payments.payees, i) == addr, Errors::internal(EWRONG_PAYEE));
        assert!(*Vector::borrow<bool>(&payments.paid, i) == false, Errors::internal(EALREADY_PAID));

        let amount = *Vector::borrow<u64>(&payments.amounts, i);

        if (amount > 0) {
            //make the payment 
            let to_pay = Diem::withdraw<GAS>(&mut payments.coins, amount);
            
            DiemAccount::deposit<GAS>(
                @DiemRoot,
                Signer::address_of(account),
                to_pay,
                b"carpe miner make whole",
                b"",
                false
            );

            //clear the payment from the list
            mark_paid(account, i);
        };
        //return the amount paid out
        amount
    }

    /// queries whether or not a make whole payment is available for addr
    /// returns (amount, index) if a payment exists, else (0, 0)
    public fun query_make_whole_payment(addr: address): (u64, u64) acquires Payments {
        let payments = borrow_global<Payments>(
            @DiemRoot
        );

        let (found, i) = Vector::index_of<address>(&payments.payees, &addr);

        if (found && *Vector::borrow<bool>(&payments.paid, i) == false) {
            (*Vector::borrow<u64>(&payments.amounts, i), i)
        }
        else {
            (0, 0)
        }
    }

    /// marks the payment at index i as paid after confirming the signer is the one owed funds
    fun mark_paid(account: &signer, i: u64) acquires Payments {
        let addr = Signer::address_of(account);

        let payments = borrow_global_mut<Payments>(
            @DiemRoot
        );

        assert! (addr == *Vector::borrow<address>(&payments.payees, i), Errors::internal(EPAYEE_NOT_DELETED));

        let p = Vector::borrow_mut<bool>(&mut payments.paid, i);
        *p = true;
    }
}
}