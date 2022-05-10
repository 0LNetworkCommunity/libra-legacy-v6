//# init --validators alices_app

//# run --admin-script --signers DiemRoot alices_app
script {
  use DiemFramework::Bonding;
  use Std::Signer;

  fun main(_dr: signer, sender: signer) {
    let coin = 10;
    let supply = 100;
    Bonding::initialize_curve(&sender, coin, supply);

    let addr = Signer::address_of(&sender);
    let (reserve, supply) = Bonding::get_curve_state(addr);
    assert!(reserve == 10, 735701);
    assert!(supply == 100, 735701);

    Bonding::test_bond_to_mint(&sender, addr, 100);

    let (reserve, supply) = Bonding::get_curve_state(addr);
    
    assert!(reserve == 110, 735701);
    assert!(supply == 331, 735701);
  }
}