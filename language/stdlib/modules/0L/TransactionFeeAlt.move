
///////////////////////////////////////////////////////////////////
// 0L Module
// Transaction Fee Distribution
///////////////////////////////////////////////////////////////////
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


address 0x0 {

    module TransactionFeeAlt {
        // use 0x0::Association;
        use 0x0::LibraAccount;
        use 0x0::LibraSystem;
        use 0x0::Signer;
        use 0x0::Transaction;
        use 0x0::Vector;
        use 0x0::GAS;
        use 0x0::FixedPoint32;

        resource struct TransactionFees {
            fee_withdrawal_capability: LibraAccount::WithdrawCapability,
        }

        // Initialize the transaction fee distribution module in genesis. We keep track of the last paid block
        // height in order to ensure that we don't try to pay more than once per-block. We also
        // encapsulate the withdrawal capability to the transaction fee account so that we can withdraw
        // the fees from this account from block metadata transactions.
        public fun initialize(fee_account: &signer) {
            Transaction::assert(Signer::address_of(fee_account) == 0xFEE, 200101014010);
            move_to(fee_account, TransactionFees {
                fee_withdrawal_capability: LibraAccount::extract_withdraw_capability(fee_account),
            });
        }

    public fun process_fees(vm_sig: &signer) acquires TransactionFees {
      // // Need to check for association or vm account
      // let sender = Signer::address_of(vm_sig);
      Transaction::assert(Signer::address_of(vm_sig) == 0x0, 190103014010);
      let bal = LibraAccount::balance<GAS::T>(0xFEE);
      let (outgoing_set, fee_ratio) = LibraSystem::get_fee_ratio();
      let length = Vector::length<address>(&outgoing_set);
      //TODO: assert the lengths of vectors are the same.
      let i = 0;
      while (i < length) {

        let node_address = *(Vector::borrow<address>(&outgoing_set, i));
        let node_ratio = *(Vector::borrow<FixedPoint32::T>(&fee_ratio, i));
        let fees = FixedPoint32::multiply_u64(bal, node_ratio);

        let distribution_resource = borrow_global<TransactionFees>(0xFEE);
        LibraAccount::pay_from_capability<GAS::T>(
            node_address,
            &distribution_resource.fee_withdrawal_capability,
            fees,
            Vector::empty<u8>(),
            Vector::empty<u8>(),
        );
        i = i + 1;
      };

    }

        // public fun distribute_transaction_fees<Token>() acquires TransactionFees {
        //   // Can only be invoked by LibraVM privilege.
        //   // Allowed association to invoke for testing purposes.
        //   Transaction::assert(Transaction::sender() == 0x0
        //     || Association::addr_is_association(Transaction::sender()), 33);
        //   // TODO: Return TransactionFee gracefully if there ino 0xFEE balance
        //   // LibraAccount::balance<Token>(0xFEE);
        //   let amount_collected = LibraAccount::balance<Token>(0xFEE);
        //   // If amount_collected == 0, this will also return early
        //   if (amount_collected == 0) { return };

        //   let i = 0;
        //   let total_weight = 0;
        //   let num_validators = LibraSystem::validator_set_size();

        //   while (i < num_validators) {
        //     total_weight = total_weight + LibraSystem::get_ith_validator_weight(i);
        //     i = i + 1;
        //   };

          
        //   if (amount_collected < total_weight) { return };

        //   // TODO: Currently, this will give no gas if the sum of validator
        //   // weights is too high. This may be a problem since we cannot give
        //   // fractional gas amounts. For example:
        //   // Alice has 1000 voting power. Bob has 1 voting power.
        //   // amount_collected is 500 GAS to distribute.
        //   // In the above scenario, no GAS will be distibuted.

        //   // Iterate through the validators distributing fees according to weight
        //   distribute_transaction_fees_internal<Token>(amount_collected);
        // }

        // // After the book keeping has been performed, this then distributes the
        // // transaction fees equally to all validators with the exception that
        // // any remainder (in the case that the number of validators does not
        // // evenly divide the transaction fee pot) is distributed to the first
        // // validator.
        // fun distribute_transaction_fees_internal<Token>(amount_collected: u64) acquires TransactionFees {
        //     let distribution_resource = borrow_global<TransactionFees>(0xFEE);
        //     let index = 0;
        //     let num_validators = LibraSystem::validator_set_size();

        //     while (index < num_validators) {
        //         let addr = LibraSystem::get_ith_validator_address(index);
        //         let weight = LibraSystem::get_ith_validator_weight(index);

        //         // Increment the index into the validator set.
        //         index = index + 1;

        //         LibraAccount::pay_from_capability<Token>(
        //             addr,
        //             &distribution_resource.fee_withdrawal_capability,
        //             amount_to_distribute_per_weight * weight,
        //             Vector::empty<u8>(),
        //             Vector::empty<u8>(),
        //         );
        //     };
        // }
    }
}
