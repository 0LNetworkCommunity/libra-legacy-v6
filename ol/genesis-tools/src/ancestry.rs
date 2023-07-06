use std::path::PathBuf;
use ol_types::legacy_recovery::LegacyRecovery;
use ol_types::ancestry::AncestryResource;
use diem_types::account_address::AccountAddress;
use serde::Deserialize;

#[derive(Debug, Clone)]
pub struct Ancestry {
  pub address: AccountAddress,
  pub tree: Vec<AccountAddress>
}

#[derive(Debug, Clone, Deserialize)]
pub struct JsonAncestry {
  address: AccountAddress,
  tree: JsonTree,
}

#[derive(Debug, Clone, Deserialize)]

pub struct JsonTree {
  #[serde(default = "default_addr")]
  parent: AccountAddress,
}

fn default_addr() -> AccountAddress {
  AccountAddress::from_hex_literal("0x666").unwrap()
}


pub fn parse_ancestry_json(path: PathBuf) -> anyhow::Result<Vec<JsonAncestry>>{
  let json_str = std::fs::read_to_string(path)?;
  Ok(serde_json::from_str(&json_str)?)
}

pub fn find_all_ancestors(my_account: &JsonAncestry, list: &Vec<JsonAncestry>) -> anyhow::Result<Vec<AccountAddress>>{
  let mut my_ancestors: Vec<AccountAddress> = vec![];
  let mut i = 0;

  let mut parent_to_find_next = my_account.tree.parent;

  while i < 100 {
    let parent_struct = list.iter()
    .find(|el|{
      el.address == parent_to_find_next
    });
    if let Some(p) = parent_struct {
      my_ancestors.push(p.address);
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

pub fn map_ancestry(list: &Vec<JsonAncestry>) -> anyhow::Result<Vec<Ancestry>>{
  list.iter()
    .map(|el| {
      let tree = find_all_ancestors(el, list).unwrap_or(vec![]);
      Ok(Ancestry {
        address: el.address,
        tree,
      })
    })
  .collect()
}

pub fn fix_legacy_recovery_data(legacy: &mut [LegacyRecovery], ancestry: &[Ancestry]) {
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
      l.ancestry = Some(resource_type);
    }
  })

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



#[test]
fn parse_file() {
    let p = json_path().parent().unwrap().join("ancestry_v7.json");
    let json_ancestry = parse_ancestry_json(p).unwrap();
    dbg!(&json_ancestry.len());
}

#[test]
fn test_find() {
    let p = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures/ancestry.json");
    let json_ancestry = parse_ancestry_json(p).unwrap();
    let all = find_all_ancestors(json_ancestry.iter().next().unwrap(), &json_ancestry).unwrap();
    // dbg!(&all);
    assert!(all.len() == 6);
    
}


#[test]
fn test_map() {
    let p = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures/ancestry.json");
    let json_ancestry = parse_ancestry_json(p).unwrap();
    let res = map_ancestry(&json_ancestry).unwrap();
    dbg!(res.len());
    dbg!(&res.iter().next());
    
}
