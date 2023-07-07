//# init --validators Alice

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TransactionFee;

    fun main(_vm: signer, _: signer) {
        assert!(TransactionFee::get_fees_collected() == 0, 735701);
    }
}