//# init --validators Alice

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Diem;
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;

    fun main(vm: signer, _: signer) {
        let old_market_cap = Diem::market_cap<GAS>();
        let coin = Diem::mint<GAS>(&vm, 1000);
        assert!(Diem::value<GAS>(&coin) == 1000, 1);
        assert!(Diem::market_cap<GAS>() == old_market_cap + 1000, 2);
        DiemAccount::vm_deposit_with_metadata<GAS>(
            &vm,
            @Alice,
            coin,
            x"", x""
        );
    }
}