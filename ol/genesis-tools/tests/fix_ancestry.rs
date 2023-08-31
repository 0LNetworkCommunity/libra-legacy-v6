mod support;

use ol_genesis_tools::{
    ancestry,
    process_snapshot::db_backup_into_recovery_struct,
};
use ol_types::legacy_recovery::save_recovery_file;
use support::path_utils::snapshot_path;
use crate::support::path_utils::json_path;
use diem_types::account_address::AccountAddress;
// The expected arguments of cli for exporting a V5 JSON recovery file from a db backup is:
// cargo r -p ol-genesis-tools -- --recover /opt/rec.json --snapshot-path /opt/state_ver*

#[tokio::test]
async fn fix_ancestry() {
    let backup = snapshot_path().parent().unwrap().join("state_ver_119757649.17a8");
    assert!(backup.exists());

    let mut recovery = db_backup_into_recovery_struct(&backup)
        .await
        .expect("could not export backup into json file");

    // This specific account is an example of the 4,000
    // accounts which do not have ancestry metadata.
    let record = recovery.iter().find(|a| {
      a.account == AccountAddress::from_hex_literal("0x242a49d3c5e141e9ca59b42ed45b917c").ok()
    }).unwrap();

    // MISSING DATA!
    assert!(record.ancestry.is_none());


    let output_pre = backup.parent().unwrap().parent().unwrap().join("test_ancestry_recovery_pre.json");
    save_recovery_file(&recovery, &output_pre)
        .expect("ERROR: failed to create recovery from snapshot,");

    let p = json_path().parent().unwrap().join("ancestry_v7.json");
    let mut proper_ancestry = ancestry::parse_ancestry_json(p).unwrap();

    ancestry::fix_legacy_recovery_data(&mut recovery, &mut proper_ancestry);

    let output_post = backup.parent().unwrap().parent().unwrap().join("test_ancestry_recovery_post.json");

    let record = recovery.iter().find(|a| {
      a.account == AccountAddress::from_hex_literal("0x242a49d3c5e141e9ca59b42ed45b917c").ok()
    }).unwrap();
    let tree = &record.ancestry.as_ref().expect("should definitly have fixed ancestry").tree;

    assert!(tree.len() == 4);
    assert!(tree[0] != AccountAddress::ZERO); // should not have the 0x0 address
    assert!(tree[0] == AccountAddress::from_hex_literal("0xBDB8AD37341CEC0817FD8E2474E25031").unwrap());
    assert!(tree[1] == AccountAddress::from_hex_literal("0xCD7C59C9D7CA50FE417E3083771FA7E8").unwrap());
    assert!(tree[2] == AccountAddress::from_hex_literal("0x763A077E0EFA9A5CE86CD5C9FADDE32B").unwrap());
    assert!(tree[3] == AccountAddress::from_hex_literal("0x64D54A14BA2F83C14DE003FAC6E8F6AD").unwrap());

    save_recovery_file(&recovery, &output_post)
        .expect("ERROR: failed to create recovery from snapshot,");
    // fs::remove_file(output_pre).unwrap();
    // fs::remove_file(output_post).unwrap();
}

