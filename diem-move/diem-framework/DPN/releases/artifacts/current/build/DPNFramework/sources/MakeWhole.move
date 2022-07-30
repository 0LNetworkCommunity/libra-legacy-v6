address DiemFramework {
    module MakeWhole {
        use DiemFramework::CoreAddresses;
        use Std::Vector;
        use Std::Signer;
        use DiemFramework::Diem;
        use DiemFramework::GAS::GAS;
        use DiemFramework::DiemAccount;
        use DiemFramework::Testnet;

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


        // THIS IS A PRIVATE FUNCTION, which can only be called by testnet, or by the VM.
        // The intended use is to apply a writeset from a database at rest
        // during a maintenance halt.
        fun vm_offer_credit(
          vm: &signer,
          account: &signer,
          value: u64,
          incident_name: vector<u8>
        ) acquires Balance {
            CoreAddresses::assert_diem_root(vm);
            let addr = Signer::address_of(account);
            let cred = Credit {
              incident_name,
              claimed: false,
              coins: Diem::mint<GAS>(vm, value),
            };

            if (!exists<Balance>(addr)) {
                move_to<Balance>(account, Balance {
                  credits: Vector::singleton(cred),
                });
            } else {
              let c = borrow_global_mut<Balance>(addr);
              Vector::push_back<Credit>(&mut c.credits, cred);
            }
        }


        /// claims the make whole payment and returns the amount paid out
        /// ensures that the caller is the one owed the payment at index i
        public fun claim_make_whole_payment(account: &signer): u64 acquires Balance {
            let addr = Signer::address_of(account);
            if (!exists<Balance>(addr)) return 0;

            let total_amount = 0;
            let b = borrow_global_mut<Balance>(addr);
            let i = 0;
            while (i < Vector::length(&b.credits)){
              let cred = Vector::borrow_mut(&mut b.credits, i);

              let amount = Diem::value<GAS>(&cred.coins);
              total_amount = total_amount + amount;
              if (amount > 0 && !cred.claimed) {
                let to_pay = Diem::withdraw<GAS>(&mut cred.coins, amount);

                DiemAccount::deposit<GAS>(
                    @DiemRoot,
                    Signer::address_of(account),
                    to_pay,
                    b"make whole",
                    b"",
                    false
                );
              };

              cred.claimed = true;
              
              i = i + 1;
            };
            total_amount
        }

        public fun claim_one(account: &signer, i: u64): u64 acquires Balance {
          let addr = Signer::address_of(account);
          if (!exists<Balance>(addr)) return 0;

          let b = borrow_global_mut<Balance>(addr);
          let cred = Vector::borrow_mut(&mut b.credits, i);
          let value = Diem::value<GAS>(&cred.coins);
          
          if (value > 0 && !cred.claimed) {
            let to_pay = Diem::withdraw<GAS>(&mut cred.coins, value);

            DiemAccount::deposit<GAS>(
                @DiemRoot,
                Signer::address_of(account),
                to_pay,
                b"make whole",
                b"",
                false
            );
        
          };

          value
        }

        /// queries whether or not a make whole payment is available for addr
        /// returns (amount, index) if a payment exists, else (0, 0)
        public fun query_make_whole_payment(addr: address): u64 acquires Balance {
          if (!exists<Balance>(addr)) return 0;

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

        ///////////////////// TEST HELPERS ///////////////////

        public fun test_helper_vm_offer(
          vm: &signer,
          account: &signer,
          value: u64,
          incident_name: vector<u8>
        ) acquires Balance {
          assert!(Testnet::is_testnet(), 7357000);
          vm_offer_credit(vm, account, value, incident_name);
        }
    }
}