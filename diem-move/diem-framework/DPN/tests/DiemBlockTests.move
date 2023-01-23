#[test_only]
module DiemFramework::DiemBlockTests {
    use DiemFramework::Genesis;
    use DiemFramework::DiemBlock;

    // TODO: the error code doesn't seem correct, juding by the name of the test.
    #[test(dr = @DiemRoot, account = @0x100)]
    #[expected_failure(abort_code = 1)]
    fun invalid_initialization_address(account: signer, dr: signer) {
        Genesis::setup(&dr);
        DiemBlock::initialize_block_metadata(&account);
    }
}
