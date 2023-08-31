//! functions for parsing ancestry file and updating a recovery file with new ancestry data
use std::path::PathBuf;
use ol_types::legacy_recovery::LegacyRecovery;
// use ol_types::ancestry::AncestryResource;
use diem_types::account_address::AccountAddress;
use serde::Deserialize;

#[derive(Debug, Clone, Deserialize)]
/// The ancestry stuct similar to Ancestry Resource
pub struct Ancestry {
  ///
  pub account: AccountAddress,
  ///
  pub parent_tree: Vec<AccountAddress>
}


/// parse the ancestry json file
pub fn parse_ancestry_json(path: PathBuf) -> anyhow::Result<Vec<Ancestry>>{
  let json_str = std::fs::read_to_string(path)?;
  Ok(serde_json::from_str(&json_str)?)
}

/// patch the recovery data structure with updated ancestry information
pub fn fix_legacy_recovery_data(legacy: &mut [LegacyRecovery], ancestry: &mut [Ancestry]) {
  let mut corrections_made = 0u64;
  ancestry.iter_mut().for_each(|correct| {
    // for every record in ancestry, find the corresponding in
    // legacy data struct
    let legacy_data = legacy.iter_mut().find(|l| {
        l.account == Some(correct.account)
    });

    if let Some(l) = legacy_data {

      correct.parent_tree.retain(|el| {
        el != &AccountAddress::ZERO
      });

      l.ancestry = Some(ol_types::ancestry::AncestryResource { tree: correct.parent_tree.clone() });
      corrections_made += 1;
    }
  });
  println!("ancestry corrections made: {corrections_made}");
}

#[test]
fn test_fix() {
    let a = Ancestry {
        account: "02A892A449874E2BE18B7EA814688B04".parse().unwrap(),
        parent_tree: vec![
            "00000000000000000000000000000000".parse().unwrap(),
            "C0A1F4D49658CF2FE5402E10F496BB80".parse().unwrap(),
            "B080A6E0464CCA28ED6C7E116FECB837".parse().unwrap(),
            "1EE5432BD3C6374E33798C4C9EDCD0CF".parse().unwrap(),
            "2FDADCAF46532DFB8DA1F6BB97A096C6".parse().unwrap(),
            "FBBF05F537D5D5103200317CDD961CDE".parse().unwrap(),
            "F85BB8A1C58EF920864A9BF555700BFC".parse().unwrap(),
        ],
    };
    let mut l = LegacyRecovery::default();
    l.account = Some(AccountAddress::from_hex_literal("0x02A892A449874E2BE18B7EA814688B04").unwrap());

    assert!(l.ancestry.is_none());
    let mut vec = vec![l];

    fix_legacy_recovery_data(&mut vec, &mut [a.clone()] );
    dbg!(&vec);
    let anc = vec.get(0).unwrap().ancestry.as_ref().expect("should have an ancestry struct here");
    // assert!(&anc.is_some());

    // check the 0x0 address is dropped
    assert!(anc.tree.len() == (a.parent_tree.len() - 1));


}



#[cfg(test)]
pub fn json_path() -> PathBuf {
    use std::path::Path;
    let path = env!("CARGO_MANIFEST_DIR");
    Path::new(path)
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("ol/fixtures/rescue/ancestry_v7.json")
}

#[test]
fn parse_ancestry_file() {
    let p = json_path();
    let json_ancestry = parse_ancestry_json(p).unwrap();
    dbg!(&json_ancestry.len());
}

#[test]
fn test_find() {
    let p = json_path();
    let json_ancestry = parse_ancestry_json(p).unwrap();
    let my_account = AccountAddress::from_hex_literal("0x242a49d3c5e141e9ca59b42ed45b917c").unwrap();
    let all = &json_ancestry.iter().find(|el|{el.account == my_account}).unwrap().parent_tree;

    assert!(all.len() == 5);
    assert!(all[0] == AccountAddress::ZERO);
    assert!(all[1] == AccountAddress::from_hex_literal("0xBDB8AD37341CEC0817FD8E2474E25031").unwrap());
    assert!(all[2] == AccountAddress::from_hex_literal("0xCD7C59C9D7CA50FE417E3083771FA7E8").unwrap());
    assert!(all[3] == AccountAddress::from_hex_literal("0x763A077E0EFA9A5CE86CD5C9FADDE32B").unwrap());
    assert!(all[4] == AccountAddress::from_hex_literal("0x64D54A14BA2F83C14DE003FAC6E8F6AD").unwrap());

}


#[test]
fn test_map() {
    let p = json_path();
    let json_ancestry = parse_ancestry_json(p).unwrap();
    dbg!(json_ancestry.len());
    dbg!(&json_ancestry.iter().next());

}
