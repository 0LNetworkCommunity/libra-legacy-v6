//# init --validators Alice Bob Carol Dave Eve Frank Gertie

// Testing if EVE a CASE 3 Validator gets dropped.

// ALICE is CASE 1
// BOB is CASE 1
// CAROL is CASE 1
// DAVE is CASE 1
// EVE is CASE 3
// FRANK is CASE 1
// GERTIE is CASE 1

//# block --proposer Alice --time 1 --round 0

// NewBlockEvent

//# run --admin-script --signers DiemRoot Eve
script {
    use DiemFramework::TowerState;
    use DiemFramework::Vouch;

    fun main(_: signer, sender: signer) {
        // Mock some mining so Eve can send rejoin tx
        TowerState::test_helper_mock_mining(&sender, 100);
        Vouch::init(&sender);
    }
}

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Vouch;

    fun main(_: signer, sender: signer) {
      Vouch::vouch_for(&sender, @Eve);
    }
}

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Jail;

    fun main(_: signer, vm: signer) {
      Jail::jail(&vm, @Eve);
      assert!(Jail::is_jailed(@Eve), 7357001);
      assert!(Jail::get_vouchee_jail(@Alice) > 0, 7357002);
    }
}
//check: EXECUTED


//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Jail;

    fun main(_: signer, sender: signer) {
      Jail::vouch_unjail(&sender, @Eve);
      assert!(!Jail::is_jailed(@Eve), 7357001);
    }
}