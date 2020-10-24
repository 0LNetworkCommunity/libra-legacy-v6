//! new-transaction
//! sender: libraroot
script {
    use 0x1::Upgrade;

    fun main(s: &signer) {
        Upgrade::initialize(s);
        spec {
            assert Upgrade::has_upgrade() == false;
        };
        assert(Upgrade::has_upgrade() == false, 1);

        Upgrade::setUpdate(s, true);
        assert(Upgrade::has_upgrade() == true, 1);

        Upgrade::setUpdate(s, false);
        assert(Upgrade::has_upgrade() == false, 1);
    }
}
// check: EXECUTED
