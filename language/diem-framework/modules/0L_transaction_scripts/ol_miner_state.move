// Transaction script which miners use to submit proofs.
address 0x1 {
module TowerScripts {

use 0x1::Globals;
use 0x1::Tower;
use 0x1::TestFixtures;
use 0x1::Testnet;

    public(script) fun Tower_commit_by_operator(
        operator_sig: signer, owner_address: address, 
        challenge: vector<u8>, 
        solution: vector<u8>
    ) {
        let proof = Tower::create_proof_blob(
            challenge,
            Globals::get_difficulty(),
            solution
        );
        
        Tower::commit_state_by_operator(&operator_sig, owner_address, proof);
    }

    public(script) fun Tower_commit(
        sender: signer, challenge: vector<u8>, 
        solution: vector<u8>
    ) {
        let proof = Tower::create_proof_blob(
            challenge,
            Globals::get_difficulty(),
            solution
        );

        Tower::commit_state(&sender, proof);
    }

    public(script) fun Tower_helper(sender: signer) {
        assert(Testnet::is_testnet(), 01);
        
        Tower::test_helper_init_miner(
            &sender,
            Globals::get_difficulty(),
            TestFixtures::alice_0_easy_chal(),
            TestFixtures::alice_0_easy_sol()
        );
    }

}
}