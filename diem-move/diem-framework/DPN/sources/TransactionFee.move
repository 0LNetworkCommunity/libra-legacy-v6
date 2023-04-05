/////// 0L /////////
///////////////////////////////////////////////////////////////////////////
// Functions to initialize, accumulated, and burn transaction fees.
// File Prefix for errors: 2000
///////////////////////////////////////////////////////////////////////////
module DiemFramework::TransactionFee {
    friend DiemFramework::Burn;

    // use DiemFramework::XUS::XUS; /////// 0L /////////
    use DiemFramework::GAS::GAS; /////// 0L /////////
    use DiemFramework::CoreAddresses;    
    use DiemFramework::XDX;
    use DiemFramework::Diem::{Self, Diem, Preburn};
    use DiemFramework::Roles;
    use DiemFramework::DiemTimestamp;
    use Std::Errors;
    use Std::Signer;
    use Std::Vector;
    // use DiemFramework::Burn;

    /// The `TransactionFee` resource holds a preburn resource for each
    /// fiat `CoinType` that can be collected as a transaction fee.
    struct TransactionFee<phantom CoinType> has key {
        balance: Diem<CoinType>,
        preburn: Preburn<CoinType>,
    }

    /// A `TransactionFee` resource is not in the required state
    const ETRANSACTION_FEE: u64 = 20000; /////// 0L /////////

    /// Called in genesis. Sets up the needed resources to collect transaction fees from the
    /// `TransactionFee` resource with the TreasuryCompliance account.
    public fun initialize(
        dr_account: &signer, /////// 0L /////////
    ) {
        DiemTimestamp::assert_genesis();
        Roles::assert_diem_root(dr_account); /////// 0L /////////
        // accept fees in all the currencies
        add_txn_fee_currency<GAS>(dr_account); /////// 0L /////////
    }
    spec initialize {
        include DiemTimestamp::AbortsIfNotGenesis;
        include Roles::AbortsIfNotTreasuryCompliance{account: dr_account};
        include AddTxnFeeCurrencyAbortsIf<GAS>;
        ensures is_initialized();
        ensures spec_transaction_fee<GAS>().balance.value == 0;
    }
    spec schema AddTxnFeeCurrencyAbortsIf<CoinType> {
        include Diem::AbortsIfNoCurrency<CoinType>;
        aborts_if exists<TransactionFee<CoinType>>(@TreasuryCompliance)
            with Errors::ALREADY_PUBLISHED;
    }

    public fun is_coin_initialized<CoinType>(): bool {
        exists<TransactionFee<CoinType>>(@TreasuryCompliance)
    }

    fun is_initialized(): bool {
        is_coin_initialized<GAS>() //////// 0L ////////
    }

    /// Sets up the needed transaction fee state for a given `CoinType` currency by
    /// (1) configuring `dr_account` to accept `CoinType`
    /// (2) publishing a wrapper of the `Preburn<CoinType>` resource under `dr_account`
    public fun add_txn_fee_currency<CoinType>(dr_account: &signer) {
        Roles::assert_diem_root(dr_account); /////// 0L /////////
        Diem::assert_is_currency<CoinType>();
        assert!(
            !is_coin_initialized<CoinType>(),
            Errors::already_published(ETRANSACTION_FEE)
        );
        move_to(
            dr_account,
            TransactionFee<CoinType> {
                balance: Diem::zero(),
                preburn: Diem::create_preburn(dr_account)
            }
        )
    }

    /// Deposit `coin` into the transaction fees bucket
    public fun pay_fee<CoinType>(coin: Diem<CoinType>) acquires TransactionFee {
        DiemTimestamp::assert_operating();
        assert!(is_coin_initialized<CoinType>(), Errors::not_published(ETRANSACTION_FEE));
        let fees = borrow_global_mut<TransactionFee<CoinType>>(@TreasuryCompliance); // TODO: this is just the VM root actually
        Diem::deposit(&mut fees.balance, coin);
    }

    //////// 0L ////////
    // Pay fee and track who it came from.
    public fun pay_fee_and_track<CoinType>(user: address, coin: Diem<CoinType>) acquires TransactionFee, FeeMaker, EpochFeeMakerRegistry {
        DiemTimestamp::assert_operating();
        assert!(is_coin_initialized<CoinType>(), Errors::not_published(ETRANSACTION_FEE));
        let amount = Diem::value(&coin);
        let fees = borrow_global_mut<TransactionFee<CoinType>>(@TreasuryCompliance); // TODO: this is just the VM root actually
        Diem::deposit(&mut fees.balance, coin);
        track_user_fee(user, amount);
    }

    spec pay_fee {
        include PayFeeAbortsIf<CoinType>;
        include PayFeeEnsures<CoinType>;
    }
    spec schema PayFeeAbortsIf<CoinType> {
        coin: Diem<CoinType>;
        let fees = spec_transaction_fee<CoinType>().balance;
        include DiemTimestamp::AbortsIfNotOperating;
        aborts_if !is_coin_initialized<CoinType>() with Errors::NOT_PUBLISHED;
        include Diem::DepositAbortsIf<CoinType>{coin: fees, check: coin};
    }
    spec schema PayFeeEnsures<CoinType> {
        coin: Diem<CoinType>;
        let fees = spec_transaction_fee<CoinType>().balance;
        let post post_fees = spec_transaction_fee<CoinType>().balance;
        ensures post_fees.value == fees.value + coin.value;
    }

    /// Preburns the transaction fees collected in the `CoinType` currency.
    /// If the `CoinType` is XDX, it unpacks the coin and preburns the
    /// underlying fiat.
    public fun burn_fees<CoinType>(
        dr_account: &signer,
    ) acquires TransactionFee {
        DiemTimestamp::assert_operating();
        Roles::assert_diem_root(dr_account); /////// 0L /////////
        assert!(is_coin_initialized<CoinType>(), Errors::not_published(ETRANSACTION_FEE));
        if (XDX::is_xdx<CoinType>()) {
            // TODO: Once the composition of XDX is determined fill this in to
            // unpack and burn the backing coins of the XDX coin.
            abort Errors::invalid_state(ETRANSACTION_FEE)
        } else {
            // extract fees
            let fees = borrow_global_mut<TransactionFee<CoinType>>(@TreasuryCompliance);
            let coin = Diem::withdraw_all(&mut fees.balance);
            let burn_cap = Diem::remove_burn_capability<CoinType>(dr_account);
            // burn
            Diem::burn_now(
                coin,
                &mut fees.preburn,
                @TreasuryCompliance,
                &burn_cap
            );
            Diem::publish_burn_capability(dr_account, burn_cap);
        }
    }
    spec burn_fees {
        pragma disable_invariants_in_body;
        /// Must abort if the account does not have the TreasuryCompliance role [[H3]][PERMISSION].
        include Roles::AbortsIfNotTreasuryCompliance{account: dr_account};

        include DiemTimestamp::AbortsIfNotOperating;
        aborts_if !is_coin_initialized<CoinType>() with Errors::NOT_PUBLISHED;
        include if (XDX::spec_is_xdx<CoinType>()) BurnFeesXDX else BurnFeesNotXDX<CoinType>;

        /// The correct amount of fees is burnt and subtracted from market cap.
        ensures Diem::spec_market_cap<CoinType>()
            == old(Diem::spec_market_cap<CoinType>()) - old(spec_transaction_fee<CoinType>().balance.value);
        /// All the fees is burnt so the balance becomes 0.
        ensures spec_transaction_fee<CoinType>().balance.value == 0;
    }

    //////// 0L ////////
    // modified the above function to burn fees
    // this is used to clear the Fee account of the VM after each epoch
    // in the event that there are more funds that necessary
    // to pay validators their agreed rate.

    // public fun ol_burn_fees(
    //     vm: &signer,
    // ) acquires TransactionFee, EpochFeeMakerRegistry, FeeMaker {
    //     if (Signer::address_of(vm) != @VMReserved) {
    //         return
    //     };
    //     // extract fees
    //     // let fees = borrow_global_mut<TransactionFee<GAS>>(@TreasuryCompliance); // TODO: this is same as VM address
    //     // let coin = Diem::withdraw_all(&mut fees.balance);

    //     // either the user is burning or recyling the coin
    //     // Burn::epoch_start_burn(vm, coin);

    //     // get the list of fee makers
    //     let state = borrow_global<EpochFeeMakerRegistry>(@VMReserved);
    //     let fee_makers = &state.fee_makers;
    //     let len = Vector::length(fee_makers);

    //     // for every user in the list burn their fees per Burn.move preferences
    //     let i = 0;
    //     while (i < len) {
    //         let user = Vector::borrow(fee_makers, i);
    //         let amount = borrow_global<FeeMaker>(*user).epoch;
    //         // Burn::epoch_start_burn(vm, user, amount);
    //         i = i + 1;
    //     }



    //     // Diem::vm_burn_this_coin(vm, coin);
    // }

    /// STUB: To be filled in at a later date once the makeup of the XDX has been determined.
    ///
    /// # Specification of the case where burn type is XDX.
    spec schema BurnFeesXDX {
        dr_account: signer;
        aborts_if true with Errors::INVALID_STATE;
    }
    /// # Specification of the case where burn type is not XDX.
    spec schema BurnFeesNotXDX<CoinType> {
        dr_account: signer;
        /// Must abort if the account does not have BurnCapability [[H3]][PERMISSION].
        include Diem::AbortsIfNoBurnCapability<CoinType>{account: dr_account};

        let fees = spec_transaction_fee<CoinType>();
        include Diem::BurnNowAbortsIf<CoinType>{coin: fees.balance, preburn: fees.preburn};

        /// dr_account retrieves BurnCapability [[H3]][PERMISSION].
        /// BurnCapability is not transferrable [[J3]][PERMISSION].
        ensures exists<Diem::BurnCapability<CoinType>>(Signer::address_of(dr_account));
    }

    spec module {} // Switch documentation context to module level.

    /// # Initialization

    spec module {
        /// If time has started ticking, then `TransactionFee` resources have been initialized.
        invariant [suspendable] DiemTimestamp::is_operating() ==> is_initialized();
    }

    /// # Helper Function

    spec fun spec_transaction_fee<CoinType>(): TransactionFee<CoinType> {
        borrow_global<TransactionFee<CoinType>>(@TreasuryCompliance)
    }

    /////// 0L /////////
    public fun get_amount_to_distribute(dr_account: &signer): u64 acquires TransactionFee {
        // Can only be invoked by DiemVM privilege.
        // Allowed association to invoke for testing purposes.
        CoreAddresses::assert_diem_root(dr_account);
        // TODO: Return TransactionFee gracefully if there ino 0xFEE balance
        // DiemAccount::balance<Token>(0xFEE);
        let fees = borrow_global<TransactionFee<GAS>>(
            @DiemRoot
        );

        let amount_collected = Diem::value<GAS>(&fees.balance);
        amount_collected
    }

    /////// 0L /////////
    /// only to be used by VM through the Burn.move module
    public(friend) fun vm_withdraw_all_coins<Token: store>(
        dr_account: &signer
    ): Diem<Token> acquires TransactionFee {
        // Can only be invoked by DiemVM privilege.
        // Allowed association to invoke for testing purposes.
        CoreAddresses::assert_diem_root(dr_account);
        // TODO: Return TransactionFee gracefully if there ino 0xFEE balance
        // DiemAccount::balance<Token>(0xFEE);
        let fees = borrow_global_mut<TransactionFee<Token>>(
            @DiemRoot
        );

        Diem::withdraw_all(&mut fees.balance)
    }

    /////// 0L /////////
    // TODO deprecate this
    public fun get_transaction_fees_coins_amount<Token: store>(
        dr_account: &signer, amount: u64
    ): Diem<Token>  acquires TransactionFee {
        // Can only be invoked by DiemVM privilege.
        // Allowed association to invoke for testing purposes.
        CoreAddresses::assert_diem_root(dr_account);
        // TODO: Return TransactionFee gracefully if there ino 0xFEE balance
        // DiemAccount::balance<Token>(0xFEE);
        let fees = borrow_global_mut<TransactionFee<Token>>(
            @DiemRoot
        );

        Diem::withdraw(&mut fees.balance, amount)
    }

    /// FeeMaker struct lives on an individual's account
    /// We check how many fees the user has paid.
    /// This will interact with Burn preferences when there is a remainder of fees in the TransactionFee account
    struct FeeMaker has key {
      epoch: u64,
      lifetime: u64,
    }

    /// We need a list of who is producing fees this epoch. 
    /// This lives on the VM address
    struct EpochFeeMakerRegistry has key {
      fee_makers: vector<address>,
    }

    /// Initialize the registry at the VM address.
    public fun initialize_epoch_fee_maker_registry(vm: &signer) {
      CoreAddresses::assert_vm(vm);
      let registry = EpochFeeMakerRegistry {
        fee_makers: Vector::empty(),
      };
      move_to(vm, registry);
    }

    /// FeeMaker is initialized when the account is created
    public fun initialize_fee_maker(account: &signer) {
      let fee_maker = FeeMaker {
        epoch: 0,
        lifetime: 0,
      };
      move_to(account, fee_maker);
    }

    public fun epoch_reset_fee_maker(vm: &signer) acquires EpochFeeMakerRegistry, FeeMaker {
      CoreAddresses::assert_vm(vm);
      let registry = borrow_global_mut<EpochFeeMakerRegistry>(@VMReserved);
      let fee_makers = &registry.fee_makers;

      let i = 0;
      while (i < Vector::length(fee_makers)) {
        let account = *Vector::borrow(fee_makers, i);
        reset_one_fee_maker(vm, account);
        i = i + 1;
      };
      registry.fee_makers = Vector::empty();
    }

    /// FeeMaker is reset at the epoch boundary, and the lifetime is updated.
    fun reset_one_fee_maker(vm: &signer, account: address) acquires FeeMaker {
      CoreAddresses::assert_vm(vm);
      let fee_maker = borrow_global_mut<FeeMaker>(account);
        fee_maker.lifetime = fee_maker.lifetime + fee_maker.epoch;
        fee_maker.epoch = 0;
    }

    /// add a fee to the account fee maker for an epoch
    /// PRIVATE function
    fun track_user_fee(account: address, amount: u64) acquires FeeMaker, EpochFeeMakerRegistry {
      if (!exists<FeeMaker>(account)) {
        return
      };

      let fee_maker = borrow_global_mut<FeeMaker>(account);
      fee_maker.epoch = fee_maker.epoch + amount;

      // update the registry
      let registry = borrow_global_mut<EpochFeeMakerRegistry>(@VMReserved);
      if (!Vector::contains(&registry.fee_makers, &account)) {
        Vector::push_back(&mut registry.fee_makers, account);
      }
    }

    //////// GETTERS ///////
    
    // get list of fee makers
    public fun get_fee_makers(): vector<address> acquires EpochFeeMakerRegistry {
      let registry = borrow_global<EpochFeeMakerRegistry>(@VMReserved);
      *&registry.fee_makers
    }

    // get the fees made by the user in the epoch
    public fun get_epoch_fees_made(account: address): u64 acquires FeeMaker {
      if (!exists<FeeMaker>(account)) {
        return 0
      };
      let fee_maker = borrow_global<FeeMaker>(account);
      fee_maker.epoch
    }

}
