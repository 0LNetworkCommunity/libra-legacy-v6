//# init --validators Alice

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TransactionFee;

    fun main(vm: signer, _: signer) {
        assert!(TransactionFee::get_amount_to_distribute(&vm) == 0, 735701);
    }
}