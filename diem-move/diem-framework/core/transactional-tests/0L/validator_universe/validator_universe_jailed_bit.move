//# init --validators Alice
//#      --addresses Eve=0x03cb4a2ce2fcfa4eadcdc08e10cee07b
//#      --private-keys Eve=49fd8b5fa77fdb08ec2a8e1cab8d864ac353e4c013f191b3e6bb5e79d3e5a67d

// Adding new validator epoch info

//# run --admin-script --signers DiemRoot Alice
script{
    use DiemFramework::ValidatorUniverse;
    use Std::Signer;

    fun main(_dr: signer, eve_sig: signer) {
        // Test from genesis if not jailed and in universe
        let addr = Signer::address_of(&eve_sig);
        assert!(!ValidatorUniverse::is_jailed(addr), 73570001);
        assert!(ValidatorUniverse::is_in_universe(addr), 73570002);
    }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot DiemRoot
script{
    use DiemFramework::ValidatorUniverse;
    // use Std::Signer;

    fun main(vm: signer, _: signer) {
        // Test from genesis if not jailed and in universe
        ValidatorUniverse::jail(&vm, @Alice);
        assert!(ValidatorUniverse::is_jailed(@Alice), 73570001);
        assert!(ValidatorUniverse::is_in_universe(@Alice), 73570002);
    }
}
// check: EXECUTED