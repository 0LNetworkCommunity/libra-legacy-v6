//# init --parent-vasps Dummy Alice Dummy2 Bob Dummy3 Carol Dummy4 Dave
// Dummy, Dummy2:     validators with 10M GAS
// Alice, Bob:    non-validators with  1M GAS

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DonorDirected;
    use Std::Vector;

    fun main(_dr: signer, sender: signer) {
      DonorDirected::init_donor_directed(&sender, @Bob, @Carol, @Dave, 2);
      DonorDirected::finalize_init(&sender);
      let list = DonorDirected::get_root_registry();
      assert!(Vector::length(&list) == 1, 7357001);

      assert!(DonorDirected::is_donor_directed(@Alice), 7357002);
    }
}
// check: EXECUTED
