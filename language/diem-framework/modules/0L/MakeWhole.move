address 0x1 {
    module MakeWhole {
        use 0x1::CoreAddresses;
        use 0x1::Vector;
        use 0x1::Signer;
        use 0x1::Diem;
        use 0x1::GAS::GAS;
        use 0x1::DiemAccount;
        // use 0x1::Errors;

        struct Balance has key {
            credits: vector<Credit>,
        }

        struct Credit has key, store {
            incident_name: vector<u8>,
            claimed: bool,
            coins: Diem::Diem<GAS>,
        }

        const EPAYEE_NOT_DELETED: u64 = 22015;
        const EWRONG_PAYEE: u64 = 22016;
        const EALREADY_PAID: u64 = 22017;


        public fun vm_offer_credit(vm: &signer, account: &signer, value: u64, incident_name: vector<u8>) acquires Balance {
            CoreAddresses::assert_diem_root(vm);
            let addr = Signer::address_of(account);

            let cred = Credit {
              incident_name,
              claimed: false,
              coins: Diem::mint<GAS>(vm, value),
            };

            

            if (exists<Balance>(addr)) {
                move_to<Balance>(account, Balance {
                  credits: Vector::singleton(cred),
                })
            } else {
              let c = borrow_global_mut<Balance>(addr);
              Vector::push_back<Credit>(&mut c.credits, cred);
            }
        }


        /// claims the make whole payment and returns the amount paid out
        /// ensures that the caller is the one owed the payment at index i
        public fun claim_make_whole_payment(account: &signer): u64 acquires Balance {
            let addr = Signer::address_of(account);
            let b = borrow_global_mut<Balance>(addr);
            let amount = 0;
            let i = 0;
            while (i < Vector::length(&b.credits)){
              let cred = Vector::borrow_mut(&mut b.credits, i);
              amount = amount + Diem::value<GAS>(&cred.coins);
              if (amount > 0) {
                let to_pay = Diem::withdraw<GAS>(&mut cred.coins, amount);

                DiemAccount::deposit<GAS>(
                    CoreAddresses::DIEM_ROOT_ADDRESS(),
                    Signer::address_of(account),
                    to_pay,
                    b"make whole",
                    b""
                );
              };

              cred.claimed = true;
              
              i = i + 1;
            };
            amount
        }

        public fun claim_one(account: &signer, i: u64): u64 acquires Balance {
          let addr = Signer::address_of(account);
          let b = borrow_global_mut<Balance>(addr);
          let cred = Vector::borrow_mut(&mut b.credits, i);
          let value = Diem::value<GAS>(&cred.coins);
          
          if (value > 0) {
            let to_pay = Diem::withdraw<GAS>(&mut cred.coins, value);

            DiemAccount::deposit<GAS>(
                CoreAddresses::DIEM_ROOT_ADDRESS(),
                Signer::address_of(account),
                to_pay,
                b"make whole",
                b""
            );
        
          };

          value
        }

        /// queries whether or not a make whole payment is available for addr
        /// returns (amount, index) if a payment exists, else (0, 0)
        public fun query_make_whole_payment(addr: address): u64 acquires Balance {
          let b = borrow_global<Balance>(addr);
          let val = 0;
          let i = 0;
          while (i < Vector::length(&b.credits)){
            let cred = Vector::borrow(&b.credits, i);
            val = val + Diem::value<GAS>(&cred.coins);

            i = i + 1;
          };

          val
        }


        // /// marks the payment at index i as paid after confirming the signer is the one owed funds
        // fun mark_paid(account: &signer, i: u64) acquires Payments {
        //     let addr = Signer::address_of(account);

        //     let payments = borrow_global_mut<Payments>(
        //         CoreAddresses::DIEM_ROOT_ADDRESS()
        //     );

        //     assert (addr == *Vector::borrow<address>(&payments.payees, i), Errors::internal(EPAYEE_NOT_DELETED));

        //     let p = Vector::borrow_mut<bool>(&mut payments.paid, i);
        //     *p = true;
        // }

    }
}