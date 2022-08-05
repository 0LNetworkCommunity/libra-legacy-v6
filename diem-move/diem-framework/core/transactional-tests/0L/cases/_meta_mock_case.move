//# init --validators Alice

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Mock;

    fun main(vm: signer, _: signer) {
        let start_height = 0;
        let end_height = 100;
        Mock::mock_case_1(&vm, @Alice, start_height, end_height);
    }
}