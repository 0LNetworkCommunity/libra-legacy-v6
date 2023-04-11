//# init --validators Alice Bob Dave Community

// Community, the community wallet
// Dave, the slow wallet

// Community wallets have specific tx script to send to slow wallet

//# run --admin-script --signers DiemRoot Dave
script {
  use DiemFramework::DiemAccount;
  use Std::Vector;

  fun main(_dr: signer, sender: signer) {
    DiemAccount::set_slow(&sender);
    let list = DiemAccount::get_slow_list();
    assert!(Vector::length<address>(&list) == 4, 735701);
  }
}

//# run --admin-script --signers DiemRoot Community
script {
  use DiemFramework::DonorDirected;
  use Std::Vector;

  fun main(_dr: signer, sponsor: signer) {
    // initialize the community wallet, @Community cannot be one of the signers
    DonorDirected::init_donor_directed(&sponsor, @Alice, @Bob, @Dave, 2);
    DonorDirected::finalize_init(&sponsor);
    let list = DonorDirected::get_root_registry();
    assert!(Vector::length(&list) == 1, 7357001);
  }
}

// TESTING THE TRANSACTION SCRIPT

//# run --signers Bob --args @Community @Alice 1 b"thanks.for.your.service"
//#     -- 0x1::TransferScripts::community_transfer


    // public(script) fun community_transfer(
    //     sender: signer,
    //     multisig_address: address,
    //     destination: address,
    //     unscaled_value: u64,
    //     memo: vector<u8>,
    // ) {