// This test is just full of simple balance queries but the transactions
// keep getting discarded for some reason.
// I wanted to see if the GAS balance of a node was changing as they sent transactions

//! account: bob, 0GAS

//! new-transaction
//! sender: association
script {
    use 0x0::LibraAccount;
    use 0x0::GAS;
    fun main(assoc: &signer) {
        LibraAccount::mint_to_address<GAS::T>(assoc, {{bob}}, 1000);
    }
}

//! new-transaction
//! sender: bob
//! max-gas: 100
//! gas-price: 1
//! gas-currency: GAS
script {
    use 0x0::Debug;
    use 0x0::GAS;
    use 0x0::LibraAccount;
    fun main() {
        let a = LibraAccount::balance<GAS::T>({{bob}});
        Debug::print(&a);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: bob
//! max-gas: 100
//! gas-price: 1
//! gas-currency: GAS
script {
    use 0x0::Debug;
    use 0x0::GAS;
    use 0x0::LibraAccount;
    fun main() {
        let a = LibraAccount::balance<GAS::T>({{bob}});
        Debug::print(&a);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: bob
//! max-gas: 100
//! gas-price: 1
//! gas-currency: GAS
script {
    use 0x0::Debug;
    use 0x0::GAS;
    use 0x0::LibraAccount;
    fun main() {
        let a = LibraAccount::balance<GAS::T>({{bob}});
        Debug::print(&a);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: bob
//! max-gas: 100
//! gas-price: 1
//! gas-currency: GAS
script {
    use 0x0::Debug;
    use 0x0::GAS;
    use 0x0::LibraAccount;
    fun main() {
        let a = LibraAccount::balance<GAS::T>({{bob}});
        Debug::print(&a);
        a = 0;
        while (a < 10) {
            _ = LibraAccount::balance<GAS::T>({{bob}});
        };
    }
}
// check: EXECUTED

//! new-transaction
//! sender: bob
//! max-gas: 100
//! gas-price: 1
//! gas-currency: GAS
script {
    use 0x0::Debug;
    use 0x0::GAS;
    use 0x0::LibraAccount;
    fun main() {
        let a = LibraAccount::balance<GAS::T>({{bob}});
        Debug::print(&a);
    }
}
// check: EXECUTED
