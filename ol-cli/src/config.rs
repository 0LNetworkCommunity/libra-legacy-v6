//! OlCli Config
//!
//! See instructions in `commands.rs` to specify the path to your
//! application's configuration file and/or command-line options
//! for specifying it.
use std::{fs, io::Write, path::PathBuf};
use crate::commands::{CONFIG_FILE, home_path};
use reqwest::Url;
use serde::{de::Error, Deserialize, Deserializer, Serialize, Serializer};
use rustyline::Editor;
/// OlCli Configuration
#[derive(Clone, Debug, Deserialize, Serialize)]
// #[serde(deny_unknown_fields)]
pub struct OlCliConfig {
    /// Where cli configs will be stored
    pub home_path: PathBuf,
    /// The URL which the CLI connects to by default
    #[serde(serialize_with = "ser_url", deserialize_with = "de_url")]
    pub node_url: Url,
    /// An upstream node, used to compare state of default node
    #[serde(serialize_with = "ser_url", deserialize_with = "de_url")]
    pub upstream_node_url: Url,
}


fn ser_url<S>(url: &Url, serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    serializer.serialize_str(&url.to_owned().into_string())
}

fn de_url<'de, D>(deserializer: D) -> Result<Url, D::Error>
where
    D: Deserializer<'de>,
{
    let s: String = Deserialize::deserialize(deserializer)?;
    s.parse::<Url>().map_err(D::Error::custom)
}

/// Default configuration settings.
impl Default for OlCliConfig {
    fn default() -> Self {
        Self {
            home_path: home_path(),
            node_url: "https://localhost:8080".to_owned().parse::<Url>().unwrap(),
            upstream_node_url: "https://localhost:8080".to_owned().parse::<Url>().unwrap(),
        }
    }
}


/// Init the cli.toml file with defaults
pub fn init_configs(path: Option<PathBuf>) -> OlCliConfig {
    let home_path = home_path();

    // TODO: Check if configs exist and warn on overwrite.
    let mut miner_configs = OlCliConfig::default();

    if path.is_some() {
        miner_configs.home_path = path.unwrap()
    }

    fs::create_dir_all(&home_path).unwrap();
    // Set up github token
    let mut rl = Editor::<()>::new();

    // Get the ip address of node.
    let readline = rl.readline("IP address of your node: ").expect("Must enter an ip address, or 0.0.0.0 as localhost");
    miner_configs.node_url = format!("http://{}:8080", readline).parse::<Url>().expect("Could not parse IP");

    let toml = toml::to_string(&miner_configs).unwrap();
    let miner_toml_path = home_path.join(CONFIG_FILE);
    let file = fs::File::create(&miner_toml_path);
    file.unwrap().write(&toml.as_bytes())
        .expect("Could not write toml file");

    println!("\nol-cli app initialized, file saved to: {:?}", &miner_toml_path);
    miner_configs
}