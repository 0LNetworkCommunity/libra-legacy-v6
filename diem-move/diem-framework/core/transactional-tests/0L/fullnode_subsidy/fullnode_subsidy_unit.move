//# init --parent-vasps Alice Frank
// Alice:     validators with 10M GAS
// Frank: non-validators with  1M GAS

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::FullnodeSubsidy;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;

    fun main(vm: signer, _: signer) {
        let old_account_bal = DiemAccount::balance<GAS>(@Frank);
        let value = FullnodeSubsidy::distribute_fullnode_subsidy(&vm, @Frank, 10);
        let new_account_bal = DiemAccount::balance<GAS>(@Frank);

        assert!(value == 10, 735701);
        assert!(new_account_bal == value + 1000000, 735702);
        assert!(new_account_bal>old_account_bal, 735703);
    }
}