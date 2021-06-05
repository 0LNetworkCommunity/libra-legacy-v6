//! get home path or set it
use anyhow::Error;
use dialoguer::{Confirm, Input};
use libra_global_constants::NODE_HOME;
use std::{net::Ipv4Addr, path::PathBuf};

/// interact with user to get the home path for files
pub fn what_home(swarm_path: Option<PathBuf>, swarm_persona: Option<String>) -> PathBuf {
    if let Some(path) = swarm_path {
        return swarm_home(path, swarm_persona);
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
    match Confirm::new()
        .with_prompt("Include path to source code in configs?")
        .interact()
        .unwrap()
    {
        true => {
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
        false => None,
    }
}

/// interact with user to get ip address
pub fn what_ip() -> Result<Ipv4Addr, Error> {
  let system_ip = match machine_ip::get() {
      Some(ip) => ip.to_string(),
      None => "127.0.0.1".to_string(),
  };

        let txt = &format!(
            "Will you use this host, and this IP address {:?}, for your node?",
            system_ip
        );
        let ip = match Confirm::new().with_prompt(txt).interact().unwrap() {
            true => system_ip
                .parse::<Ipv4Addr>()
                .expect("Could not parse IP address: {:?}"),
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

/// interact with user to get a statement
pub fn what_statement() -> String {
  Input::new()
        .with_prompt("Enter a (fun) statement to go into your first transaction")
        .interact_text()
        .expect("We need some text unique to you which will go into your the first proof of your tower")
}
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
