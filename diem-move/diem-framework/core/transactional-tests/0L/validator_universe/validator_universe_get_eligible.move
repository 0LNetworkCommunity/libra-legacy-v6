//# init --validators Alice

// Adding new validator epoch info

//# run --admin-script --signers DiemRoot DiemRoot
script{
    use DiemFramework::ValidatorUniverse;
    use Std::Vector;

    fun main() {
        // NOTE: in functional and e2e tests the genesis block includes 3 validators.
        // this is set here anguage/tools/vm-genesis/src/lib.rs
        // ValidatorUniverse::add_validator(@0xDEADBEEF);
        // let validators_in_genesis = 4;
        let len = Vector::length<address>(
            &ValidatorUniverse::get_eligible_validators()
        );
        assert!(len == 1, 100001);
    }
}
// check: EXECUTED