//! OlCli Config
//!
//! See instructions in `commands.rs` to specify the path to your
//! application's configuration file and/or command-line options
//! for specifying it.
use reqwest::Url;
use serde::{de::Error, Deserialize, Deserializer, Serialize, Serializer};

/// OlCli Configuration
#[derive(Clone, Debug, Deserialize, Serialize)]
// #[serde(deny_unknown_fields)]
pub struct OlCliConfig {
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
            node_url: "https://localhost:8080".to_owned().parse::<Url>().unwrap(),
            upstream_node_url: "https://localhost:8080".to_owned().parse::<Url>().unwrap(),
        }
    }
}
