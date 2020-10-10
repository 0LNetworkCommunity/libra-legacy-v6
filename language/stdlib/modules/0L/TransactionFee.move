
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

module TransactionFee {
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
        Transaction::assert(Signer::address_of(vm_sig) == 0x0, 190103014010);
        let bal = LibraAccount::balance<GAS::T>(0xFEE);

        let (outgoing_set, fee_ratio) = LibraSystem::get_fee_ratio();
        let length = Vector::length<address>(&outgoing_set);

        // leave fees in tx_fee if there isn't at least 1 gas coin per validator.
        if (bal <= length) return;

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
}
}
