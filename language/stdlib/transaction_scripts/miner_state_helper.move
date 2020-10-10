// Transaction script which miners use to submit proofs.
script {
use 0x0::MinerState;
use 0x0::Testnet;
use 0x0::Transaction;
use 0x0::Globals;
use 0x0::TestFixtures;

fun main(sender: &signer) {
    Transaction::assert(Testnet::is_testnet(), 01);
    
    MinerState::test_helper(
      sender,
      Globals::get_difficulty(),
      TestFixtures::alice_0_easy_chal(),
      TestFixtures::alice_0_easy_sol()
    );

}
}
