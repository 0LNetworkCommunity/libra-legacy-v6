//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! account: alice, 0GAS

//! new-transaction
// Minting from a privileged account should work
//! sender: association
script {
    use 0x0::GAS;
    use 0x0::Libra;
    use 0x0::LibraAccount;
    use 0x0::Transaction;
    fun main(account: &signer) {
        // mint 100 coins and check that the market cap increases appropriately
        let old_market_cap = Libra::market_cap<GAS::T>();
        let coin = Libra::mint<GAS::T>(account, 1000);
        Transaction::assert(Libra::value<GAS::T>(&coin) == 1000, 4);
        Transaction::assert(Libra::market_cap<GAS::T>() == old_market_cap + 1000, 5);
    
        // get rid of the coin
        LibraAccount::deposit(account, {{alice}}, coin);
    }
    }
    
    // check: MintEvent
    // check: EXECUTED
    