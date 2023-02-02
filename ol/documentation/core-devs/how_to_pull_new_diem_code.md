
## How to pull new diem code

- [ ] Choose latest diem-core version (e.g. `diem-core-v1.3.0`): https://github.com/diem/diem/releases 
- [ ] From the chosen diem-core version, checkout a new 0L branch e.g. `v5-base-diem-1.3.0` - this will be the diem code without 0L changes.
- [ ] From the chosen diem-core version, checkout a new 0L branch e.g. `v5` - this will be the diem code with the 0L changes.
- [ ] Merge current 0L main dev. branch into the new 0L branch created in previous step (e.g. v5), resolve all conflicts
- [ ] `cargo clean`, `cargo b --all` and `cargo b --all-targets` - make sure no errors or warnings
```
// Some core paths and files to start fixing:
- config/ 
- language/tools/vm-genesis/
- Genesis.move
```

- [ ] Make sure all the coins patched as "GAS" in types/src/account_config/constants/coins.rs

E.g.
```
//////// 0L ////////
// other coins besides GAS are only used for tests, and come from upstream
pub const GAS_NAME: &str = "GAS";
pub const GAS_IDENTIFIER: &IdentStr = ident_str!(GAS_NAME);
pub const XUS_NAME: &str = "GAS";
pub const XUS_IDENTIFIER: &IdentStr = ident_str!(XUS_NAME);
pub const XDX_NAME: &str = "GAS";
pub const XDX_IDENTIFIER: &IdentStr = ident_str!(XDX_NAME);
```

- [ ] Note: `cargo c` can be used instead of `cargo b` for quick iteration
- [ ] Resolve all Move modules and transaction scripts build errors. Build with `ol\utils\build-stdlib.sh`
- [ ] Resolve all Rust build errors/warnings for all packages again ->  `cargo b --all` and `cargo b --all-targets`
- [ ] Get all move-lang-functional-tests build & pass -> `PRETTY=1 NODE_ENV="test" cargo test -p move-lang-functional-tests -- 0L/ > /opt/27.jul.21.txt 2>&1` (Hint: start w/ `chained_from_genesis` or `persistence`)
```
Hint: Tests should use 0L coin "GAS" 
```

- [ ] Get all e2e tests build & pass -> `PRETTY=1 NODE_ENV="test" cargo test -p language-e2e-testsuite -- --nocapture ol_`

- [ ] Make sure we have 0L patched SALT and test `val_config_ip_address` in `ol/types/src/account.rs` is passing

```
// types/src/network_address/encrypted.rs
/////// 0L /////////
pub const HKDF_SALT: [u8; 32] = [
    0xdf, 0xc8, 0xff, 0xcc, 0x7f, 0x62, 0xea, 0x4e, 0x5b, 0x9b, 0xc4, 0x1e, 0xe7, 0x96, 0x9b, 0x44,
    0x27, 0x54, 0x19, 0xeb, 0xaa, 0xd1, 0xdb, 0x27, 0xd2, 0xa1, 0x91, 0xb6, 0xd1, 0xdb, 0x6d, 0x13,
];
```

- [ ] Get swarm working
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
      // Note: 5th address is created randomly, it might change e.g. https://github.com/0LNetworkCommunity/libra/issues/645
```
- [ ] Get mining working
- [ ] Merge latest changes from main
- [ ] Get integrations tests pass https://github.com/0LNetworkCommunity/libra/tree/main/ol/integration-tests
- [ ] Final check - all 0L tests and swarm work
- [ ] Final cargo clean, cargo b --all and cargo b --all-targets

### Some more useful info might be found in these issues:  
https://github.com/0LNetworkCommunity/libra/issues/616  
https://github.com/0LNetworkCommunity/libra/issues/530 (this has the steps for manual patching instead of git auto-merge - due to name change "libra" to "diem")

