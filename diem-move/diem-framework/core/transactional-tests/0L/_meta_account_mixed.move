//# init --validators Alice
//# --addresses Bob=0x2e3a0b7a741dae873bf0f203a82dfd52
//# --private-keys Bob=e1acb70a23dba96815db374b86c5ae96d6a9bc5fff072a7a8e55a1c27c1852d8

//# run --signers DiemRoot
//#     --args @Bob
//#     -- 0x1::DiemAccount::test_harness_create_user


//# run --signers DiemRoot Alice --admin-script
script { fun main() {} }

//# run --signers DiemRoot Bob --admin-script
script {
    // use DiemFramework::Wallet;
    // use Std::Vector;
    use DiemFramework::GAS::GAS;
    use Std::Signer;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, sender: signer) {
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      assert!(bal == 0, 7357001);
    }
}
