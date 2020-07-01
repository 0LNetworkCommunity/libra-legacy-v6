address 0x0 {

    module TransactionFee {
        use 0x0::Association;
        use 0x0::LibraAccount;
        use 0x0::LibraSystem;
        use 0x0::Signer;
        use 0x0::Transaction;
        // use 0x0::Debug;
        use 0x0::Vector;

        ///////////////////////////////////////////////////////////////////////////
        // Transaction Fee Distribution
        ///////////////////////////////////////////////////////////////////////////
        // Implements a basic transaction fee distribution logic.
        //
        // We have made a couple design decisions here that are worth noting:
        //  * We pay out once per-block for now.
        //    TODO: Once we have a better on-chain representation of
        //          epochs this should be changed over to be once per-epoch.
        //  * Sometimes the number of validators does not evenly divide the transaction fees to be
        //    distributed. In such cases the remainder ("dust") is left in the transaction fees pot and
        //    these remaining fees will be included in the calculations for the transaction fee
        //    distribution in the next epoch. This distribution strategy is meant to in part minimize the
        //    benefit of being the first validator in the validator set.

        resource struct TransactionFees {
            fee_withdrawal_capability: LibraAccount::WithdrawCapability,
        }

        // Initialize the transaction fee distribution module in genesis. We keep track of the last paid block
        // height in order to ensure that we don't try to pay more than once per-block. We also
        // encapsulate the withdrawal capability to the transaction fee account so that we can withdraw
        // the fees from this account from block metadata transactions.
        public fun initialize(fee_account: &signer) {
            Transaction::assert(Signer::address_of(fee_account) == 0xFEE, 0);
            move_to(fee_account, TransactionFees {
                fee_withdrawal_capability: LibraAccount::extract_withdraw_capability(fee_account),
            });
        }

        public fun distribute_transaction_fees<Token>() acquires TransactionFees {
          // Can only be invoked by LibraVM privilege.
          // Allowed association to invoke for testing purposes.
          Transaction::assert(Transaction::sender() == 0x0
            || Association::addr_is_association(Transaction::sender()), 33);
          // TODO: Return TransactionFee gracefully if there ino 0xFEE balance
          // LibraAccount::balance<Token>(0xFEE);
          let amount_collected = LibraAccount::balance<Token>(0xFEE);
          // If amount_collected == 0, this will also return early
          if (amount_collected == 0) { return };

          let i = 0;
          let total_weight = 0;
          let num_validators = LibraSystem::validator_set_size();

          while (i < num_validators) {
            total_weight = total_weight + LibraSystem::get_ith_validator_weight(i);
            i = i + 1;
          };

          // let amount_collected = LibraAccount::balance<Token>(0xFEE);
          // If amount_collected == 0, this will also return early
          if (amount_collected < total_weight) { return };

          // TODO: Currently, this will give no gas if the sum of validator
          // weights is too high. This may be a problem since we cannot give
          // fractional gas amounts. For example:
          // Lucas has 1000 voting power. Dev has 1 voting power.
          // amount_collected is 500 GAS to distribute.
          // In the above scenario, no GAS will be distibuted.

          // Calculate the amount of money to be dispursed, along with the remainder.
          let amount_to_distribute_per_weight = per_weight_distribution_amount(
              amount_collected,
              total_weight
          );

          // Iterate through the validators distributing fees according to weight
          distribute_transaction_fees_internal<Token>(
              amount_to_distribute_per_weight
          );
        }

        // After the book keeping has been performed, this then distributes the
        // transaction fees equally to all validators with the exception that
        // any remainder (in the case that the number of validators does not
        // evenly divide the transaction fee pot) is distributed to the first
        // validator.
        fun distribute_transaction_fees_internal<Token>(
            amount_to_distribute_per_weight: u64
        ) acquires TransactionFees {
            let distribution_resource = borrow_global<TransactionFees>(0xFEE);
            let index = 0;
            let num_validators = LibraSystem::validator_set_size();

            while (index < num_validators) {
                let addr = LibraSystem::get_ith_validator_address(index);
                let weight = LibraSystem::get_ith_validator_weight(index);

                // Increment the index into the validator set.
                index = index + 1;

                LibraAccount::pay_from_capability<Token>(
                    addr,
                    &distribution_resource.fee_withdrawal_capability,
                    amount_to_distribute_per_weight * weight,
                    Vector::empty<u8>(),
                    Vector::empty<u8>(),
                );
            };
        }

        // This calculates the amount to be distributed to each validator equally. We do this by calculating
        // the integer division of the transaction fees collected by the number of validators. In
        // particular, this means that if the number of validators does not evenly divide the
        // transaction fees collected, then there will be a remainder that is left in the transaction
        // fees pot to be distributed later.
        fun per_weight_distribution_amount(amount_collected: u64, total_weight: u64): u64 {
            Transaction::assert(total_weight != 0, 0);
            let validator_payout = amount_collected / total_weight;
            Transaction::assert(validator_payout * total_weight <= amount_collected, 1);
            validator_payout
        }
    }
    }

    //     /// The `TransactionFeeCollection` resource holds the
    //     /// `LibraAccount::withdraw_with_capability` for the `0xFEE` account.
    //     /// This is used for the collection of the transaction fees since it
    //     /// must be sent from the account at the `0xB1E55ED` address.
    //     resource struct TransactionFeeCollection {
    //         cap: LibraAccount::WithdrawCapability,
    //     }

    //     /// The `TransactionFeePreburn` holds a preburn resource for each
    //     /// fiat `CoinType` that can be collected as a transaction fee.
    //     resource struct TransactionFeePreburn<CoinType> {
    //         preburn: Preburn<CoinType>
    //     }

    //     /// We need to be able to determine if `CoinType` is LBR or not in
    //     /// order to unpack it properly before burning it. This resource is
    //     /// instantiated with `LBR` and published in `TransactionFee::initialize`.
    //     /// We then use this to determine if the / `CoinType` is LBR in `TransactionFee::is_lbr`.
    //     resource struct LBRIdent<CoinType> { }

    //     /// Called in genesis. Sets up the needed resources to collect
    //     /// transaction fees by the `0xB1E55ED` account.
    //     public fun initialize(blessed_account: &signer, fee_account: &signer) {
    //         Transaction::assert(Signer::address_of(blessed_account) == 0xB1E55ED, 0);
    //         let cap = LibraAccount::extract_withdraw_capability(fee_account);
    //         move_to(blessed_account, TransactionFeeCollection { cap });
    //         move_to(blessed_account, LBRIdent<LBR>{})
    //     }

    //     /// Sets ups the needed transaction fee state for a given `CoinType`
    //     /// currency.

    // NOTE: Do we need this?
    // public fun add_txn_fee_currency<CoinType>(fee_account: &signer) {
    //     Transaction::assert(Signer::address_of(fee_account) == 0xFEE, 0);
    //     LibraAccount::add_currency<CoinType>(fee_account);
    //     // move_to(fee_account, TransactionFeePreburn<CoinType>{
    //     //     preburn: Libra::new_preburn_with_capability(burn_cap)
    //     // })
    // }

    //     /// Returns whether `CoinType` is LBR or not. This is needed since we
    //     /// will need to unpack LBR before burning it when collecting the
    //     /// transaction fees.
    //     public fun is_lbr<CoinType>(): bool {
    //         exists<LBRIdent<CoinType>>(0xB1E55ED)
    //     }

    //     /// Preburns the transaction fees collected in the `CoinType` currency.
    //     /// If the `CoinType` is LBR, it unpacks the coin and preburns the
    //     /// underlying fiat.
    //     public fun preburn_fees<CoinType>(blessed_sender: &signer)
    //     acquires TransactionFeeCollection, TransactionFeePreburn {
    //         if (is_lbr<CoinType>()) {
    //             let amount = LibraAccount::balance<LBR>(0xFEE);
    //             let coins = LibraAccount::withdraw_with_capability<LBR>(
    //                 &borrow_global<TransactionFeeCollection>(Signer::address_of(blessed_sender)).cap,
    //                 amount
    //             );
    //             let (coin1, coin2) = LBR::unpack(blessed_sender, coins);
    //             preburn_coin<Coin1>(coin1);
    //             preburn_coin<Coin2>(coin2)
    //         } else {
    //             let amount = LibraAccount::balance<CoinType>(0xFEE);
    //             let coins = LibraAccount::withdraw_with_capability<CoinType>(
    //                 &borrow_global<TransactionFeeCollection>(Signer::address_of(blessed_sender)).cap,
    //                 amount
    //             );
    //             preburn_coin(coins)
    //         }
    //     }

    //     /// Burns the already preburned fees from a previous call to `preburn_fees`.
    //     public fun burn_fees<CoinType>(blessed_account: &signer, burn_cap: &BurnCapability<CoinType>)
    //     acquires TransactionFeePreburn {
    //         Transaction::assert(Signer::address_of(blessed_account) == 0xB1E55ED, 0);
    //         let preburn = &mut borrow_global_mut<TransactionFeePreburn<CoinType>>(0xFEE).preburn;
    //         Libra::burn_with_resource_cap(
    //             preburn,
    //             0xFEE,
    //             burn_cap
    //         )
    //     }

    //     fun preburn_coin<CoinType>(coin: Libra<CoinType>)
    //     acquires TransactionFeePreburn {
    //         let preburn = &mut borrow_global_mut<TransactionFeePreburn<CoinType>>(0xFEE).preburn;
    //         Libra::preburn_with_resource(
    //             coin,
    //             preburn,
    //             0xFEE
    //         );
    //     }
    // }
    // }
