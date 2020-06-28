//! account: bob, 0GAS
//! account: alice, 10GAS

//! new-transaction
//! sender: association
// //! max-gas: 1000 // THIS FAILS
// //! gas-price: 1 // THIS FAILS
//! gas-currency: GAS
script {
    use 0x0::LibraAccount;
    use 0x0::GAS;
    fun main(assoc: &signer) {
        LibraAccount::mint_to_address<GAS::T>(assoc, {{bob}}, 10000);
    }
}
// check: EXECUTED
