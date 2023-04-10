//# init --validators Alice

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TransactionFee;
    use DiemFramework::Diem;
    use DiemFramework::GAS::GAS;
    // use DiemFramework::Debug::print;
    use Std::Vector;

    fun main(vm: signer, _: signer) {
        assert!(TransactionFee::get_fees_collected()==0, 735701);
        let coin = Diem::mint<GAS>(&vm, 1);
        TransactionFee::pay_fee_and_track(@Alice, coin);

        let fee_makers = TransactionFee::get_fee_makers();
        // print(&fee_makers);
        assert!(Vector::length(&fee_makers)==1, 735702);
        assert!(TransactionFee::get_fees_collected()==1, 735703);
    }
}