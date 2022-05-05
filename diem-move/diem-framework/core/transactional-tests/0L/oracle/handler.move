// run with language/move-lang/functional-tests> cargo test handler

//! account: alice, 1000000, 0, validator

//! new-transaction
//! sender: alice
script {
    use DiemFramework::Oracle;
    use DiemFramework::Vector;
    use DiemFramework::Upgrade;

    fun main(sender: signer){
        let id = 1;
        let data = b"hello";
        Oracle::handler(&sender, id, data);
        let vec = Oracle::test_helper_query_oracle_votes();

        let e = *Vector::borrow<address>(&vec, 0);
        assert!(e == @Alice, 7357123401011000);

        assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
    }
}
// check: EXECUTED
