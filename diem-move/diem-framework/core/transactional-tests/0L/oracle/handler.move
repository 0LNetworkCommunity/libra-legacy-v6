//# init --validators Alice

// run with language/move-lang/functional-tests> cargo test handler

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Oracle;
    use Std::Vector;
    use DiemFramework::Upgrade;

    fun main(_dr: signer, sender: signer){
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
