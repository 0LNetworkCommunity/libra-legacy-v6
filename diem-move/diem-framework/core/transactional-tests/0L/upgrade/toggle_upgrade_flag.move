//# init --validators Alice 
  // todo: Should we do this test without validators? See previous Move version of this file.

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Upgrade;

    fun main(dr: signer, _: signer) {
        assert!(Upgrade::has_upgrade() == false, 1);

        Upgrade::set_update(&dr, x"1234");
        assert!(Upgrade::has_upgrade() == true, 1);
        assert!(Upgrade::get_payload() == x"1234", 1);
    }
}
// check: EXECUTED