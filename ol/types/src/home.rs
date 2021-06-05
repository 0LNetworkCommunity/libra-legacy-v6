//! get home path or set it
use dialoguer::{Confirm, Input};
use libra_global_constants::NODE_HOME;
use std::path::PathBuf;

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
