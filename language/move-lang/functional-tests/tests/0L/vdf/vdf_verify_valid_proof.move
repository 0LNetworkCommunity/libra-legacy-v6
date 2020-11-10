//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

//! new-transaction
script{
use 0x1::VDF;
use 0x1::TestFixtures;
fun main() {

  // this tests the happy case, that a proof is submitted with all three correct parameters.

  let challenge: vector<u8>;
  let difficulty: u64;
  let solution: vector<u8>;
  let re: bool;

  difficulty = 100;
  challenge = TestFixtures::easy_chal();
  // Generate solutions with cd ./verfiable_delay/vdf-cli && cargo run -- -l=4096 aa 100
  // the -l=4096 is important because this is the security paramater of 0L miner.
  solution = TestFixtures::easy_sol();

  re = VDF::verify(&challenge, &difficulty, &solution);
  // Debug::print<bool>(&re);
  assert(move re == true, 1);
}
}
