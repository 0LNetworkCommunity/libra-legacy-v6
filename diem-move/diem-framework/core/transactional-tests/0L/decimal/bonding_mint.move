//# init --validators alices_app

//# run --admin-script --signers DiemRoot alices_app
script {
  use DiemFramework::DemoBonding;
  use Std::Signer;

  fun main(_dr: signer, sender: signer) {
    let coin = 10;
    let supply = 100;
    DemoBonding::initialize_curve(&sender, coin, supply);

    let addr = Signer::address_of(&sender);
    let (reserve, supply) = DemoBonding::get_curve_state(addr);
    assert!(reserve == 10, 735701);
    assert!(supply == 100, 735701);

    DemoBonding::test_bond_to_mint(&sender, addr, 100);

    let (reserve, supply) = DemoBonding::get_curve_state(addr);
    
    assert!(reserve == 110, 735701);
    assert!(supply == 331, 735701);
  }
}