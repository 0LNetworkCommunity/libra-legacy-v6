//# init --validators Alice
//#      --addresses Dave=0xf42400810cda384c1966c472bfab11f7
//#                  Sally=0x03cb4a2ce2fcfa4eadcdc08e10cee07b
//#      --private-keys Dave=f51472493bac725c7284a12c56df41aa3475d731ec289015782b0b9c741b24b5
//#                     Sally=49fd8b5fa77fdb08ec2a8e1cab8d864ac353e4c013f191b3e6bb5e79d3e5a67d
    // todo: How to send Dave and Sally 10 GAS ?

//// Old syntax for reference, delete it after fixing this test
// ! account: alice, 1000000GAS, 0, validator
// ! account: bob, 10GAS,       // bob   -> Dave
// ! account: carol, 10GAS,     // carol -> Sally

// META: transfers between Dave and Sally (not slow wallets) works fine
//# run --admin-script --signers DiemRoot Sally
script {
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;

    fun main(dr: signer, account: signer) {
        assert!(DiemAccount::balance<GAS>(@Dave) == 10, 735701);
            // todo: VMStatus: status ABORTED of type Execution with sub status 120119            

        let with_cap = DiemAccount::extract_withdraw_capability(&account);
        DiemAccount::pay_from<GAS>(&with_cap, @Dave, 10, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
        assert!(DiemAccount::balance<GAS>(@Dave) == 20, 735701);
    }
}
// check: EXECUTED