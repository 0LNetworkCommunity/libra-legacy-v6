address 0x1 {

module TransactionFee {
    use 0x1::CoreAddresses;
    use 0x1::Errors;
    use 0x1::GAS::GAS;
    use 0x1::Libra::{Self, Libra};
    use 0x1::Roles;
    use 0x1::LibraTimestamp;
    // use 0x1::Debug::print;
    // use 0x1::LibraAccount;
    // use 0x1::FixedPoint32;

    /// The `TransactionFee` resource holds a preburn resource for each
    /// fiat `CoinType` that can be collected as a transaction fee.
    resource struct TransactionFee<CoinType> {
        balance: Libra<CoinType>
    }

    spec module {
        invariant [global] LibraTimestamp::is_operating() ==> is_initialized();
    }

    /// A `TransactionFee` resource is not in the required state
    const ETRANSACTION_FEE: u64 = 0;

    /// Called in genesis. Sets up the needed resources to collect transaction fees from the
    /// `TransactionFee` resource with the TreasuryCompliance account.
    public fun initialize(
        lr_account: &signer
    ) {
        LibraTimestamp::assert_genesis();
        CoreAddresses::assert_libra_root(lr_account);
        Roles::assert_treasury_compliance(lr_account);
        // accept fees in all the currencies
        add_txn_fee_currency<GAS>(lr_account);
    }

    fun is_coin_initialized<CoinType>(): bool {
        exists<TransactionFee<CoinType>>(CoreAddresses::LIBRA_ROOT_ADDRESS())
    }

    fun is_initialized(): bool {
        is_coin_initialized<GAS>()
    }

    /// Sets ups the needed transaction fee state for a given `CoinType` currency by
    /// (1) configuring `lr_account` to accept `CoinType`
    /// (2) publishing a wrapper of the `Preburn<CoinType>` resource under `lr_account`
    fun add_txn_fee_currency<CoinType>(lr_account: &signer) {
        Libra::assert_is_currency<CoinType>();
        assert(
            !exists<TransactionFee<CoinType>>(CoreAddresses::LIBRA_ROOT_ADDRESS()),
            Errors::already_published(ETRANSACTION_FEE)
        );
        move_to(
            lr_account,
            TransactionFee<CoinType> {
                balance: Libra::zero()
            }
        )
    }

    public fun get_amount_to_distribute(lr_account: &signer): u64 acquires TransactionFee {
        // Can only be invoked by LibraVM privilege.
        // Allowed association to invoke for testing purposes.
        CoreAddresses::assert_libra_root(lr_account);
        // TODO: Return TransactionFee gracefully if there ino 0xFEE balance
        // LibraAccount::balance<Token>(0xFEE);
        let fees = borrow_global<TransactionFee<GAS>>(
            CoreAddresses::LIBRA_ROOT_ADDRESS()
        );

        let amount_collected = Libra::value<GAS>(&fees.balance);
        amount_collected
    }

    public fun get_transaction_fees_coins<Token>(lr_account: &signer): Libra<Token>  acquires TransactionFee {
        // Can only be invoked by LibraVM privilege.
        // Allowed association to invoke for testing purposes.
        CoreAddresses::assert_libra_root(lr_account);
        // TODO: Return TransactionFee gracefully if there ino 0xFEE balance
        // LibraAccount::balance<Token>(0xFEE);
        let fees = borrow_global_mut<TransactionFee<Token>>(
            CoreAddresses::LIBRA_ROOT_ADDRESS()
        );

        Libra::withdraw_all(&mut fees.balance)
    }

    public fun get_transaction_fees_coins_amount<Token>(lr_account: &signer, amount: u64): Libra<Token>  acquires TransactionFee {
        // Can only be invoked by LibraVM privilege.
        // Allowed association to invoke for testing purposes.
        CoreAddresses::assert_libra_root(lr_account);
        // TODO: Return TransactionFee gracefully if there ino 0xFEE balance
        // LibraAccount::balance<Token>(0xFEE);
        let fees = borrow_global_mut<TransactionFee<Token>>(
            CoreAddresses::LIBRA_ROOT_ADDRESS()
        );

        Libra::withdraw(&mut fees.balance, amount)
    }


    // public fun distribute(lr_account: &signer) acquires TransactionFee {
    //     // Can only be invoked by LibraVM privilege.
    //     // Allowed association to invoke for testing purposes.
    //     let cap = LibraAccount::extract_withdraw_capability(lr_account);
    //     CoreAddresses::assert_libra_root(lr_account);
    //     let coins = get_transaction_fees_coins<GAS>(lr_account);
    //     let fees = borrow_global_mut<TransactionFee<GAS>>(
    //         CoreAddresses::LIBRA_ROOT_ADDRESS()
    //     );
    //     // let coins = Libra::withdraw_all(&mut fees.balance);
    //     print(fees);
        

    //     let value = Libra::value<GAS>(&coins);
    //     print(&value);

    //     LibraAccount::pay_from<GAS>(&cap, 0x1, 1, x"", x"",);
    //     // coins
    //     // TODO: Return TransactionFee gracefully if there ino 0xFEE balance
    //     // LibraAccount::balance<Token>(0xFEE);
    //     // let fees = borrow_global_mut<TransactionFee<Token>>(
    //     //     CoreAddresses::LIBRA_ROOT_ADDRESS()
    //     // );

    //     // Libra::withdraw_all(&mut fees.balance)
    // }

    /// Deposit `coin` into the transaction fees bucket
    public fun pay_fee<CoinType>(coin: Libra<CoinType>) acquires TransactionFee {
        assert(is_coin_initialized<CoinType>(), Errors::not_published(ETRANSACTION_FEE));
        let fees = borrow_global_mut<TransactionFee<CoinType>>(
            CoreAddresses::LIBRA_ROOT_ADDRESS()
        );
        Libra::deposit(&mut fees.balance, coin)
    }

    spec fun pay_fee {
        include LibraTimestamp::AbortsIfNotOperating;
        aborts_if !is_coin_initialized<CoinType>() with Errors::NOT_PUBLISHED;
        let fees = transaction_fee<CoinType>().balance;
        include Libra::DepositAbortsIf<CoinType>{coin: fees, check: coin};
        ensures fees.value == old(fees.value) + coin.value;
    }


}
}
