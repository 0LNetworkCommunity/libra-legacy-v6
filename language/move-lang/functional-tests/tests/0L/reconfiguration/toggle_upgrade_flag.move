//! new-transaction
//! sender: association
script {
    use 0x0::Upgrade;
    use 0x0::Transaction;

    fun main(s: &signer) {
        Upgrade::initialize(s);
        spec {
            assert Upgrade::has_upgrade() == false;
        };
        Transaction::assert(Upgrade::has_upgrade() == false, 1);

        Upgrade::setUpdate(s, true);
        Transaction::assert(Upgrade::has_upgrade() == true, 1);

        Upgrade::setUpdate(s, false);
        Transaction::assert(Upgrade::has_upgrade() == false, 1);
    }
}
// check: EXECUTED
