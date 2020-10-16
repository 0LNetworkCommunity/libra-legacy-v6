script {
    use 0x1::GAS::GAS;
    use 0x1::Libra;
    use 0x1::LibraAccount;
    
    fun main(sender: &signer, payee: address) {
        // mint a coin the association (tx sender)
        let coin = Libra::mint<GAS>(sender, 100000);

        // mint a coin the association (tx sender)
        let coin2 = Libra::mint<GAS>(sender, 2000000);
        LibraAccount::deposit_gas(sender, payee, coin2);

        // send coin to Fee collecting address
        LibraAccount::deposit_gas(sender, 0xFEE, coin);
    }
}