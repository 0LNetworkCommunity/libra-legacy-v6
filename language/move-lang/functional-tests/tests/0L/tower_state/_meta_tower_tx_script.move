//! account: alice, 1, 0, validator



    // public(script) fun minerstate_commit(
    //     sender: signer,
    //     challenge: vector<u8>, 
    //     solution: vector<u8>,
    //     difficulty: u64,
    //     security: u64,

// continue from genesis with proof_1

//! new-transaction
//! sender: alice
//! args: x"19b7be4956ca7cb08a981ce38c30afd5a3f9699d716b606e447c32daa06d9074", x"002b1970e1ccc00707639ad5bd5228e61567074043a0c897563c10249580abd776ffdc2e76b8d49d2d639ef5544bdb713abab00d74490e7759788d0c6bf6df6be59d", 100, 512
stdlib_script::TowerStateScripts::minerstate_commit
// check: "Keep(EXECUTED)"
