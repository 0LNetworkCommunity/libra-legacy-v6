//# init --validators Alice

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TransactionFee;
    use DiemFramework::Diem;
    use DiemFramework::GAS::GAS;

    fun main(vm: signer, _: signer) {
        assert!(TransactionFee::get_amount_to_distribute(&vm)==0, 735701);
        let coin = Diem::mint<GAS>(&vm, 1);
        TransactionFee::pay_fee(coin);
        assert!(TransactionFee::get_amount_to_distribute(&vm)==1, 735701);
    }
}