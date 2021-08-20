
  # E2E Testing of Upgrade
  The way we test if a new STdlib compile was successfully upgraded is by inserting a dummy (canary) function in an otherwise production stdlib. If the Upgrade::foo() function is not found, that means the upgrade did not take place.
  
  This requires using alternate Move files, and alternate builds. Which is very annoying to do.

  ## Building Fixtures

  TLDR; there is a makefile in `/ol/fixtures/upgrade/make-upgrade-fixtures.mk` which needs to be called whenever there are major architectural changes, or changes to the Upgrade contract.

  The e2e test located at `language/e2e-testsuite/src/tests/ol_upgrade_oracle.rs` tests if the current stack can take an alternate stdlib, which is exacly the same as in the dev tree, except for there being a canary API: Upgrade::foo() which will only be callable if the upgrade was successful.

  

  The fixtures for creating this test are complex. We need:
  1. A "proposed" stdlib compile
  2. The tx scripts to call the ::foo() function

  ## Making the proposed upgrade stdlib
  1. First there needs to be a "proposed" new Stdlib compile.
  To create the compile, the Upgrade.move file, needs to contain the ::foo() function.
  for convenience we keep an Upgrade.move.e2e file, which can be used in an alternate build of the stdlib.mv. This happens rarely, so the dev should just rename the files (removeing the .e2e), and build the stdlib.

  The Stdlib compile should be placed in ol/fixtures/upgrade
 
  ## Making the the tx script which calls the foo() function

  2. The tx scripts which are used by client or SDK are used only for testing purposes. These do not need to change, and can be found alongside other tx scripts.
  
  At the same time as using the Upgrade.move.e2e, the matchin transaction script needs to be renamed for inclusion in the compilation. That file is: 0L_transaction_scripts/ol_e2e_test_upgrade_foo_tx.move.e2e .

  As above, just remove the e2e ending on compile.

  ## Clean up
  3. Revert back to production code, and re run the Stdlib compiler
  After building the fixtures be sure to return the file names to their original names Upgrade.move.e2e, and 0L_transaction_scripts/ol_e2e_test_upgrade_foo_tx.move.e2e 
  Rerun the stdlib compile with production code.