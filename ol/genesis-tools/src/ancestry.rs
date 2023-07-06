//! functions for parsing ancestry file and updating a recovery file with new ancestry data
use std::path::PathBuf;
use ol_types::legacy_recovery::LegacyRecovery;
use ol_types::ancestry::AncestryResource;
use diem_types::account_address::AccountAddress;
use serde::Deserialize;

#[derive(Debug, Clone)]
/// The ancestry stuct similar to Ancestry Resource
pub struct Ancestry {
  ///
  pub address: AccountAddress,
  ///
  pub tree: Vec<AccountAddress>
}

#[derive(Debug, Clone, Deserialize)]
/// format of file for recovery
pub struct JsonAncestry {
  address: AccountAddress,
  tree: JsonTree,
}

#[derive(Debug, Clone, Deserialize)]
/// just the relevant fields from the exported file
pub struct JsonTree {
  #[serde(default = "default_addr")]
  parent: AccountAddress,
}

fn default_addr() -> AccountAddress {
  AccountAddress::from_hex_literal("0x666").unwrap()
}

/// parse the ancestry json file
pub fn parse_ancestry_json(path: PathBuf) -> anyhow::Result<Vec<JsonAncestry>>{
  let json_str = std::fs::read_to_string(path)?;
  Ok(serde_json::from_str(&json_str)?)
}

/// function for searching all ancestry data and compiling list.
pub fn find_all_ancestors(my_account: AccountAddress, list: &Vec<JsonAncestry>) -> anyhow::Result<Vec<AccountAddress>>{
  let mut my_ancestors: Vec<AccountAddress> = vec![];
  let mut i = 0;

  let mut parent_to_find_next = my_account;

  while i < 100 {
    let parent_struct = list.iter()
    .find(|el|{
      el.address == parent_to_find_next
    });
    if let Some(p) = parent_struct {
      if p.tree.parent == AccountAddress::ZERO { break };
      my_ancestors.push(p.tree.parent); // starts with my_address, which we do not include in list
      parent_to_find_next = p.tree.parent;
    } else {
      break;
    }
    i+=1;
  }
  // need to reverse such that oldest is 0th.
  my_ancestors.reverse();
  Ok(my_ancestors)
}


/// maps json struct into the same format as the chain struct
pub fn map_ancestry(list: &Vec<JsonAncestry>) -> anyhow::Result<Vec<Ancestry>>{
  list.iter()
    .map(|el| {
      let tree = find_all_ancestors(el.address, list).unwrap_or(vec![]);
      Ok(Ancestry {
        address: el.address,
        tree,
      })
    })
  .collect()
}

/// patch the recovery data structure with updated ancestry information
pub fn fix_legacy_recovery_data(legacy: &mut [LegacyRecovery], ancestry: &[Ancestry]) {
  let mut corrections_made = 0u64;
  ancestry.iter().for_each(|a| {
    let legacy_data = legacy.iter_mut().find(|l| {
      if let Some(acc) = l.account {
        acc == a.address
      } else { false }
    });
    if let Some(l) = legacy_data {
      let resource_type = AncestryResource {
        tree: a.tree.clone()
      };

      if let Some(anc) = &l.ancestry {
        if anc.tree != a.tree {
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
        address: "02A892A449874E2BE18B7EA814688B04".parse().unwrap(),
        tree: vec![
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

    fix_legacy_recovery_data(&mut vec, &[a] );
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
    let my_account = AccountAddress::from_hex_literal("0x202EA105D76ECCD215BAEE626FA62788").unwrap();
    // let my_account = json_ancestry.iter().next().unwrap().address;
    let all = find_all_ancestors(my_account, &json_ancestry).unwrap();
    // dbg!(&all);
    assert!(all.len() == 4);
    assert!(all[0] == AccountAddress::from_hex_literal("0xBDB8AD37341CEC0817FD8E2474E25031").unwrap());
    assert!(all[1] == AccountAddress::from_hex_literal("0xCD7C59C9D7CA50FE417E3083771FA7E8").unwrap());
    assert!(all[2] == AccountAddress::from_hex_literal("0x88D2ED4905F65B8B841E1707069126E2").unwrap());
    assert!(all[3] == AccountAddress::from_hex_literal("0x7355E047E103E2BB5F31137D068AD68D").unwrap());
    
}


#[test]
fn test_map() {
    let p = json_path();
    let json_ancestry = parse_ancestry_json(p).unwrap();
    let res = map_ancestry(&json_ancestry).unwrap();
    dbg!(res.len());
    dbg!(&res.iter().next());
    
}
