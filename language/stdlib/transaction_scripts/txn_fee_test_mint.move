script {
    use 0x0::GAS;
    use 0x0::Libra;
    use 0x0::LibraAccount;
    
    fun main(sender: &signer, payee: address) {
        // mint a coin the association (tx sender)
        let coin = Libra::mint<GAS::T>(sender, 100000);

        // mint a coin the association (tx sender)
        let coin2 = Libra::mint<GAS::T>(sender, 2000000);
        LibraAccount::deposit(sender, payee, coin2);

        // send coin to Fee collecting address
        LibraAccount::deposit(sender, 0xFEE, coin);
    }
}