// - The code below is a copy of: 
//   ol/fixtures/upgrade_payload/tx_scripts/ol_oracle_upgrade_foo_tx.move
// - Remove ".temp" extension to include it in build process
// -----------------------------------------------------

// TODO: Maybe move this somewhere else
// Note: this script is used for testing upgrade oracle, it is not included 
// in the staged scripts on purpose.
// The compiled .mv file can be found in upgrade_payload/tests/
//
// IMPORTANT: 
// Must update the compiled upgrade_payload/stdlib.mv file 
// everytime after an actual upgrade to include this script, or the e2e 
// test will fail
address DiemFramework {
module OracleUpgradeFooTx {
    use DiemFramework::Upgrade;
    use DiemFramework::Debug::print;

    public(script) fun ol_oracle_upgrade_foo_tx () {
        print(&0x0000000000000000000000000011e110); // Bello!
        Upgrade::foo();
    }
}
}