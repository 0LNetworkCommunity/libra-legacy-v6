// Transaction script which miners use to submit proofs.
script {
use 0x1::MinerState;
use 0x1::Testnet;
use 0x1::Globals;
use 0x1::TestFixtures;

fun minerstate_helper(sender: &signer) {
    assert(Testnet::is_testnet(), 01);
    
    MinerState::test_helper(
      sender,
      Globals::get_difficulty(),
      TestFixtures::alice_0_easy_chal(),
      TestFixtures::alice_0_easy_sol()
    );

}
}
