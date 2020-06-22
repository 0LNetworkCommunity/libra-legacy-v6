//! account: bob, 0GAS

//! new-transaction
//! sender: association
script {
    use 0x0::LibraAccount;
    use 0x0::GAS;
    fun main(assoc: &signe) {
        LibaAccount::mint_to_address<Gas::T>(assoc, {{bob}}, 1000);
    }
}

//! new-transaction
//! sender: bob
//! max-gas: 100
//! gas-price: 1
//! gas-currency: GAS
script {
    fun main() {while (true) {} }
}
// check: OUT_OF_GAS
