//# init
//# --validators Alice Dave Community
//# --addresses Bob=0x2e3a0b7a741dae873bf0f203a82dfd52
//# --private-keys Bob=e1acb70a23dba96815db374b86c5ae96d6a9bc5fff072a7a8e55a1c27c1852d8

// Community wallets cannot send to a wallet that is not set to SLOW (bob)

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
// We are trying to send to bob, which is a plain account without the "slow" flag

//# run --signers Alice --args @Community @Bob 1 b"thanks.for.your.service"
//#     -- 0x1::TransferScripts::community_transfer
