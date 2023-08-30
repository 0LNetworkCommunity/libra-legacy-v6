//! functions for parsing ancestry file and updating a recovery file with new ancestry data
use std::path::PathBuf;
use ol_types::legacy_recovery::LegacyRecovery;
use ol_types::ancestry::AncestryResource;
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

// #[derive(Debug, Clone, Deserialize)]
// /// format of file for recovery
// pub struct JsonAncestry {
//   address: AccountAddress,
//   tree: JsonTree,
// }

// #[derive(Debug, Clone, Deserialize)]
// /// just the relevant fields from the exported file
// pub struct JsonTree {
//   #[serde(default = "default_addr")]
//   parent: AccountAddress,
// }

// fn default_addr() -> AccountAddress {
//   AccountAddress::from_hex_literal("0x666").unwrap()
// }

/// parse the ancestry json file
pub fn parse_ancestry_json(path: PathBuf) -> anyhow::Result<Vec<Ancestry>>{
  let json_str = std::fs::read_to_string(path)?;
  Ok(serde_json::from_str(&json_str)?)
}

// /// function for searching all ancestry data and compiling list.
// pub fn find_all_ancestors(my_account: AccountAddress, list: &Vec<Ancestry>) -> anyhow::Result<Vec<AccountAddress>>{
//   let mut my_ancestors: Vec<AccountAddress> = vec![];
//   let mut i = 0;

//   let mut parent_to_find_next = my_account;

//   while i < 100 {
//     let parent_struct = list.iter()
//     .find(|el|{
//       el.address == parent_to_find_next
//     });
//     if let Some(p) = parent_struct {
//       if p.tree.parent == AccountAddress::ZERO { break };
//       my_ancestors.push(p.tree.parent); // starts with my_address, which we do not include in list
//       parent_to_find_next = p.tree.parent;
//     } else {
//       break;
//     }
//     i+=1;
//   }
//   // need to reverse such that oldest is 0th.
//   my_ancestors.reverse();
//   Ok(my_ancestors)
// }


// /// maps json struct into the same format as the chain struct
// pub fn map_ancestry(list: &Vec<JsonAncestry>) -> anyhow::Result<Vec<Ancestry>>{
//   list.iter()
//     .map(|el| {
//       let tree = find_all_ancestors(el.address, list).unwrap_or(vec![]);
//       Ok(Ancestry {
//         address: el.address,
//         tree,
//       })
//     })
//   .collect()
// }

/// patch the recovery data structure with updated ancestry information
pub fn fix_legacy_recovery_data(legacy: &mut [LegacyRecovery], ancestry: &mut [Ancestry]) {
  let mut corrections_made = 0u64;
  ancestry.iter_mut().for_each(|a| {
    // for every record in ancestry, find the corresponding in
    // legacy data struct
    let legacy_data = legacy.iter_mut().find(|l| {
      if let Some(acc) = l.account {
        acc == a.account
      } else { false }
    });
    if let Some(l) = legacy_data {
      let resource_type = AncestryResource {
        tree: a.parent_tree.clone()
      };

      if let Some(anc) = &l.ancestry {
        a.parent_tree.retain(|el| {
          el != &AccountAddress::ZERO
        });
        if anc.tree != a.parent_tree {
          l.ancestry = Some(resource_type);
          corrections_made += 1;
        }
      }
    }
  });
  println!("corrections made: {corrections_made}");
}

#[test]
fn test_fix() {
    let a = Ancestry {
        account: "02A892A449874E2BE18B7EA814688B04".parse().unwrap(),
        parent_tree: vec![
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

    fix_legacy_recovery_data(&mut vec, &mut [a] );
    dbg!(&vec);
    assert!(&vec.iter().next().unwrap().ancestry.is_some());

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
    // let my_account = json_ancestry.iter().next().unwrap().address;
    // let all = find_all_ancestors(my_account, &json_ancestry).unwrap();
    // dbg!(&all);
    assert!(all.len() == 5);
    assert!(all[0] == AccountAddress::from_hex_literal("0x00000000000000000000000000000000").unwrap());
    assert!(all[4] == AccountAddress::from_hex_literal("64D54A14BA2F83C14DE003FAC6E8F6AD").unwrap());

}


#[test]
fn test_map() {
    let p = json_path();
    let json_ancestry = parse_ancestry_json(p).unwrap();
    dbg!(json_ancestry.len());
    dbg!(&json_ancestry.iter().next());

}
