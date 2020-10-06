//! account: alice, 1GAS,  0, validator

//! new-transaction
//! sender: association
script {
    use 0x0::LibraAccount;
    use 0x0::GAS;
    use 0x0::Debug::print;
    fun main(assoc: &signer) {
        LibraAccount::mint_to_address<GAS::T>(assoc, 0xFEE, 10000);
        let bal = LibraAccount::balance<GAS::T>(0xFEE);
        print(&bal);
    }
}
// check: EXECUTED
