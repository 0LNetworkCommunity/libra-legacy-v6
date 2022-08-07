//! get home path or set it
use anyhow::{bail, Error};
use dialoguer::{Confirm, Input};
use diem_crypto::HashValue;
use diem_global_constants::NODE_HOME;
use glob::glob;
use std::{fs, net::Ipv4Addr, path::PathBuf};

use crate::{block::VDFProof, config::IS_TEST};

/// interact with user to get the home path for files
pub fn what_home(swarm_path: Option<PathBuf>, swarm_persona: Option<String>) -> PathBuf {
    // For dev and CI setup
    if let Some(path) = swarm_path {
        return swarm_home(path, swarm_persona);
    } else {
        if *IS_TEST {
            return dirs::home_dir().unwrap().join(NODE_HOME);
        }
    }

    let mut default_home_dir = dirs::home_dir().unwrap();
    default_home_dir.push(NODE_HOME);

    let txt = &format!(
        "Will you use the default directory for node data and configs: {:?}?",
        default_home_dir
    );
    let dir = match Confirm::new().with_prompt(txt).interact().unwrap() {
        true => default_home_dir,
        false => {
            let input: String = Input::new()
                .with_prompt("Enter the full path to use (e.g. /home/name)")
                .interact_text()
                .unwrap();
            PathBuf::from(input)
        }
    };
    dir
}

/// interact with user to get the source path
pub fn what_source() -> Option<PathBuf> {
    let mut default_source_path = dirs::home_dir().unwrap();
    default_source_path.push("libra");

    let txt = &format!(
        "Is this the path to the source code? {:?}?",
        default_source_path
    );
    let dir = match Confirm::new().with_prompt(txt).interact().unwrap() {
        true => default_source_path,
        false => {
            let input: String = Input::new()
                .with_prompt("Enter the full path to use (e.g. /home/name)")
                .interact_text()
                .unwrap();
            PathBuf::from(input)
        }
    };
    Some(dir)
}

/// interact with user to get ip address
pub fn what_ip() -> Result<Ipv4Addr, Error> {
    // get from external source since many cloud providers show different interfaces for `machine_ip`
    let resp = reqwest::blocking::get("https://ifconfig.me")?;
    let ip_str = resp.text()?;

    let system_ip = ip_str
        .parse::<Ipv4Addr>()
        .unwrap_or_else(|_| match machine_ip::get() {
            Some(ip) => ip.to_string().parse().unwrap(),
            None => "127.0.0.1".parse().unwrap(),
        });

    if *IS_TEST {
        return Ok(system_ip);
    }

    let txt = &format!(
        "Will you use this host, and this IP address {:?}, for your node?",
        system_ip
    );
    let ip = match Confirm::new().with_prompt(txt).interact().unwrap() {
        true => system_ip,
        false => {
            let input: String = Input::new()
                .with_prompt("Enter the IP address of the node")
                .interact_text()
                .unwrap();
            input
                .parse::<Ipv4Addr>()
                .expect("Could not parse IP address")
        }
    };

    Ok(ip)
}

/// interact with user to get ip address
pub fn what_vfn_ip() -> Result<Ipv4Addr, Error> {
    if *IS_TEST {
        return Ok("0.0.0.0".parse::<Ipv4Addr>()?);
    }

    let txt = "Will you set up Fullnode configs now? If not that's ok but you'll need to submit a transaction later to update on-chain peer discovery info";
    let ip = match Confirm::new().with_prompt(txt).interact().unwrap() {
        true => {
            let input: String = Input::new()
                .with_prompt("Enter the IP address of the VFN node")
                .interact_text()?;

            input.parse::<Ipv4Addr>()?
        }
        false => "0.0.0.0".parse::<Ipv4Addr>()?,
    };

    Ok(ip)
}

/// interact with user to get a statement
pub fn what_statement() -> String {
    if *IS_TEST {
        return "test".to_owned();
    }
    Input::new()
        .with_prompt("Enter a (fun) statement to go into your first transaction. This also creates entropy for your first proof")
        .interact_text()
        .expect(
            "We need some text unique to you which will go into your the first proof of your tower",
        )
}

// deprecated

// interact with user to get a statement
// pub fn add_tower(config: &AppCfg) -> Option<String> {
//     let legacy_blocks_path = config.workspace.node_home.join("blocks");
//     let txt = "(optional) want to link to another tower's last hash?";
//     match Confirm::new().with_prompt(txt).interact().unwrap() {
//         false => None,
//         true => {
//             if let Some(block) = find_last_legacy_block(&legacy_blocks_path).ok() {
//                 let hash = hash_last_proof(&block.proof);
//                 let hash_string = encode(hash);
//                 let txt = format!("Use this hash as your tower link? {} ", &hash_string);
//                 match Confirm::new().with_prompt(txt).interact().unwrap() {
//                     true => Some(hash_string),
//                     false => Input::new()
//                         .with_prompt("Enter hash of last proof data")
//                         .interact_text()
//                         .ok(),
//                 }
//             } else {
//                 println!(
//                     "could not find any legacy proofs in usual location: {:?}",
//                     &legacy_blocks_path
//                 );
//                 Input::new()
//                     .with_prompt("Enter hash of last proof data")
//                     .interact_text()
//                     .ok()
//             }
//         }
//     }
// }

/// returns node_home
/// usually something like "/root/.0L"
/// in case of swarm like "....../swarm_temp/0" for alice
/// in case of swarm like "....../swarm_temp/1" for bob
fn swarm_home(mut swarm_path: PathBuf, swarm_persona: Option<String>) -> PathBuf {
    if let Some(persona) = swarm_persona {
        let all_personas = vec!["alice", "bob", "carol", "dave", "eve"];
        let index = all_personas.iter().position(|&r| r == persona).unwrap();
        swarm_path.push(index.to_string());
    } else {
        swarm_path.push("0"); // default
    }
    swarm_path
}

// helper to parse the existing blocks in the miner's path. This function receives any path. Note: the path is configured in miner.toml which abscissa Configurable parses, see commands.rs.
fn _find_last_legacy_block(blocks_dir: &PathBuf) -> Result<VDFProof, Error> {
    let mut max_block: Option<u64> = None;
    let mut max_block_path = None;
    // iterate through all json files in the directory.
    for entry in glob(&format!("{}/block_*.json", blocks_dir.display()))
        .expect("Failed to read glob pattern")
    {
        if let Ok(entry) = entry {
            let block_file =
                fs::read_to_string(&entry).expect("Could not read latest block file in path");

            let block: VDFProof = serde_json::from_str(&block_file)?;
            let blocknumber = block.height;
            if max_block.is_none() {
                max_block = Some(blocknumber);
                max_block_path = Some(entry);
            } else {
                if blocknumber > max_block.unwrap() {
                    max_block = Some(blocknumber);
                    max_block_path = Some(entry);
                }
            }
        }
    }

    if let Some(p) = max_block_path {
        let b = fs::read_to_string(p).expect("Could not read latest block file in path");
        match serde_json::from_str(&b) {
            Ok(v) => Ok(v),
            Err(e) => bail!(e),
        }
    } else {
        bail!("cannot find a legacy block in: {:?}", blocks_dir)
    }
}
fn _hash_last_proof(proof: &Vec<u8>) -> Vec<u8> {
    HashValue::sha3_256_of(proof).to_vec()
}
