//# init --validators Bob

// Adding new validator epoch info

//# run --admin-script --signers DiemRoot DiemRoot
script{
    use DiemFramework::ValidatorUniverse;
    use Std::Vector;

    fun main(vm: signer, _: signer) {
        let len = Vector::length<address>(
            &ValidatorUniverse::get_eligible_validators(&vm)
        );
        assert!(len == 1, 73570);
        ValidatorUniverse::remove_validator_vm(&vm, @Bob);
    }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot DiemRoot
script{
    use DiemFramework::ValidatorUniverse;
    use Std::Vector;

    fun main(vm: signer, _: signer) {
        let len = Vector::length<address>(
            &ValidatorUniverse::get_eligible_validators(&vm)
        );
        assert!(len == 0, 73570);
    }
}
// check: EXECUTED