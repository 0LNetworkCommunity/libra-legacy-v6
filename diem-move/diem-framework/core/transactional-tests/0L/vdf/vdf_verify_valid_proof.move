//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

//! new-transaction
script{
use DiemFramework::VDF;
use DiemFramework::TestFixtures;
fun main() {

  // this tests the happy case, that a proof is submitted with all three correct parameters.
  let challenge = TestFixtures::easy_chal();
    // Generate solutions with:
    // cd ./verfiable_delay/vdf-cli && cargo run --release -- -l=512 aa 100 -tpietrzak
    // NOTE: the -l=512 is important because this is the security paramater of 0L miner.
  let proof = TestFixtures::easy_sol();
  
  assert!(VDF::verify(&challenge, &proof, &TestFixtures::easy_difficulty(), &TestFixtures::security()) == true, 1);
}
}
