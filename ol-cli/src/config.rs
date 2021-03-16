//! OlCli Config
//!
//! See instructions in `commands.rs` to specify the path to your
//! application's configuration file and/or command-line options
//! for specifying it.
use std::{fs, io::Write, path::PathBuf};
use crate::commands::{CONFIG_FILE, home_path};
use libra_types::waypoint::Waypoint;
use reqwest::Url;
use serde::{de::Error, Deserialize, Deserializer, Serialize, Serializer};
use rustyline::Editor;
use std::str::FromStr;
use libra_json_rpc_client::AccountAddress;

/// OlCli Configuration
#[derive(Clone, Debug, Deserialize, Serialize)]
// #[serde(deny_unknown_fields)]
pub struct OlCliConfig {
    /// Where cli configs will be stored
    pub home_path: PathBuf,

    /// The fallback waypoint
    pub base_waypoint: Waypoint,
    /// The URL which the CLI connects to by default
    #[serde(serialize_with = "ser_url", deserialize_with = "de_url")]
    pub node_url: Url,
    /// An upstream node, used to compare state of default node
    #[serde(serialize_with = "ser_url", deserialize_with = "de_url")]
    pub upstream_node_url: Url,
    /// The fallback waypoint
    pub address: AccountAddress,

    /// The fallback waypoint
    pub node_namespace: String,

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
            address: AccountAddress::from_hex_literal("0x4C613C2F4B1E67CA8D98A542EE3F59F5").expect("Address is not valid"),
            home_path: home_path(),
            base_waypoint: Waypoint::from_str("0:0000000000000000000000000000000000000000000000000000000000000000").unwrap(),
            node_url: "http://localhost:8080".to_owned().parse::<Url>().unwrap(),
            upstream_node_url: "http://167.172.248.37:8080".to_owned().parse::<Url>().unwrap(),
            node_namespace: "87515d94a244235a1433d7117bc0cb154c613c2f4b1e67ca8d98a542ee3f59f5-oper/safety_data".to_string(),
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