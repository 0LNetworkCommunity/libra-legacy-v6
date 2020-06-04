//! Proof block datastructure
use hex::{decode, encode};
use serde::{de::Error, Deserialize, Deserializer, Serialize, Serializer};
// use serde_json;

///Proof Block Datastructure
#[derive(Serialize, Deserialize)]
pub struct Block {
    ///Block Height
    pub height: u64,
    /// VDF Output
    #[serde(serialize_with = "as_hex", deserialize_with = "from_hex")]
    pub data: Vec<u8>,
}

fn as_hex<S>(data: &[u8], serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    serializer.serialize_str(&encode(data))
}

fn from_hex<'de, D>(deserializer: D) -> Result<Vec<u8>, D::Error>
where
    D: Deserializer<'de>,
{
    let s: &str = Deserialize::deserialize(deserializer)?;
    // do better hex decoding than this
    decode(s).map_err(D::Error::custom)
}
