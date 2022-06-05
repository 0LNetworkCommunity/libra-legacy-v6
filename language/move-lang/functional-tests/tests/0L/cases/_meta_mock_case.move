
//! account: alice, 1000000, 0, validator

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Mock;

    fun main(vm: signer) {
      let start_height = 0;
      let end_height = 100;
      Mock::mock_case_1(&vm, @{{alice}}, start_height, end_height);

    }
}
// check: EXECUTED
