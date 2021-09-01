
- [x] Choose latest diem-core version (e.g. `diem-core-v1.3.0`): https://github.com/diem/diem/releases 
- [ ] From the chosen diem-core version, checkout a new 0L branch e.g. `v5-base-diem-1.3.0` - this will be the diem code without 0L changes.
- [ ] From the chosen diem-core version, checkout a new 0L branch e.g. `v5` - this will be the diem code with the 0L changes.
- [x] Merge current 0L main dev. branch into the new 0L branch created in previous step (e.g. v5), resolve all conflicts
- [x] `cargo clean`, `cargo b --all` and `cargo b --all-targets` - make sure no errors or warnings
- [x] Note: `cargo c` can be used instead of `cargo b` for quick iteration
- [x] Resolve all Move modules/transaction scripts build errors. Build with `ol\utils\build-stdlib.sh`
- [x] Resolve all Rust build errors/warnings for all packages again ->  `cargo b --all` and `cargo b --all-targets`
- [x] Get all move-lang-functional-tests build & pass -> `PRETTY=1 cargo test -p move-lang-functional-tests -- 0L/ > /opt/27.jul.21.txt 2>&1` (Hint: start w/ `chained_from_genesis` or `persistence`)
- [x] Get all e2e tests build & pass -> `PRETTY=1 cargo test -p language-e2e-testsuite -- --nocapture ol_`
- [x] Get swarm working
- [ ] Make sure all of the swarm account addresses are same as before:  
```
OK create_and_initialize_main_accounts =============== 
Initializing with env: test
0 ======== Create Owner Accounts
[language/tools/vm-genesis/src/lib.rs:413] owner_address = 4C613C2F4B1E67CA8D98A542EE3F59F5
[language/tools/vm-genesis/src/lib.rs:413] owner_address = 88E74DFED34420F2AD8032148280A84B
[language/tools/vm-genesis/src/lib.rs:413] owner_address = E660402D586AD220ED9BEFF47D662D54
[language/tools/vm-genesis/src/lib.rs:413] owner_address = 9E6BB3A75E9618FBA057E86E69338C94
[language/tools/vm-genesis/src/lib.rs:413] owner_address = 4E1F81F77024B56DBB853CE7ED8E1C7E
      // Note: 5th address is created randomly, it might change e.g. https://github.com/OLSF/libra/issues/645
```
- [x] Get mining working
- [x] Merge latest changes from main
- [x] Get integrations tests pass https://github.com/OLSF/libra/tree/main/ol/integration-tests
- [x] Final check - all 0L tests and swarm work
- [x] Final cargo clean, cargo b --all and cargo b --all-targets
