//# init --parent-vasps Dummy Alice Dummy2 Bob Dummy3 Carol Dummy4 Dave
// Dummy, Dummy2:     validators with 10M GAS
// Alice, Bob:    non-validators with  1M GAS

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DonorDirected;
    use Std::Vector;

    fun main(_dr: signer, sender: signer) {
      // This will fail because Alice is the Sender, the sponosor, and cannot be a signer.
      DonorDirected::init_donor_directed(&sender, @Alice, @Carol, @Dave, 2);

    }
}
// check: ABORTED
