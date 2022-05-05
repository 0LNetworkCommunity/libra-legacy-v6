//! account: alice, 1, 0, validator

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::TransactionFee;

    fun main(vm: signer) {
        assert!(TransactionFee::get_amount_to_distribute(&vm) == 0, 735701);
    }
}
