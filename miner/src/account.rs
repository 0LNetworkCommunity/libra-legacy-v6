//! Formatters for libra account creation
use crate::{block::Block, node_keys::KeyScheme};
use serde::{de::Error, Deserialize, Deserializer, Serialize, Serializer};
use hex::{decode, encode};
use std::{fs::File, io::Write, path::PathBuf};

#[derive(Serialize, Deserialize, Debug)]
/// Configuration data necessary to initialize a validator.
pub struct ValConfigs {
    /// Block zero of the onboarded miner
    pub block_zero: Block,
    /// Human readable name of Owner account
    pub ow_human_name: String,
    /// IP address of Operator
    pub op_address: String,
    /// Auth key prefix of Operator
    #[serde(serialize_with = "as_hex", deserialize_with = "from_hex")]
    pub op_auth_key_prefix: Vec<u8>,
    /// Key validator will use in consensus
    #[serde(serialize_with = "as_hex", deserialize_with = "from_hex")]
    pub op_consensus_pubkey: Vec<u8>,
    /// Key validator will use for network connections
    pub op_validator_network_addresses: String, //NetworkAddress network/network-address/src/lib.rs
    /// FullNode will use for network connections
    pub op_fullnode_network_addresses: String, //NetworkAddress
    /// Human readable name of account
    pub op_human_name: String,
}

#[derive(Serialize, Deserialize, Debug)]
/// Configuration data necessary to initialize an end user.
pub struct UserConfigs {
    /// Block zero of the onboarded miner
    pub block_zero: Block,
}
// TODO: Duplicated from block.rs
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
    let s: String = Deserialize::deserialize(deserializer)?;
    // do better hex decoding than this
    decode(s).map_err(D::Error::custom)
}

impl ValConfigs {
    /// New val config.
    pub fn new(
        block: Block,
        mnemonic_string: String,
        ip_address: String,
    ) -> ValConfigs {
        let keys = KeyScheme::new_from_mnemonic(mnemonic_string);
        let owner_address = keys.child_0_owner.get_address().to_string();
        // let op_authkey = keys.child_1_operator.get_address();
        ValConfigs {
            /// Block zero of the onboarded miner
            block_zero: block,
            ow_human_name: owner_address.clone(),
            op_address: format!("0x{}", keys.child_1_operator.get_address().to_string()),
            op_auth_key_prefix: keys.child_1_operator.get_authentication_key().prefix().to_vec(),
            op_consensus_pubkey: keys.child_4_consensus.get_public().to_bytes().into(),
            op_validator_network_addresses: ip_address.clone(),
            op_fullnode_network_addresses: ip_address,
            op_human_name: format!("{}-oper", owner_address),
        }
    }
    /// Creates the json file needed for onchain account creation - validator
    pub fn create_validator_manifest(
        &self,
        val_configs: ValConfigs,
        mut json_path: PathBuf,
    ){
        //where file will be saved
        json_path.push("account.json");
        let mut file = File::create(json_path.as_path()).unwrap();
        let buf = serde_json::to_string(&val_configs).expect("Config should be export to json");
        file.write(&buf.as_bytes() )
            .expect("Could not write account.json");
    }

    /// Extract the preimage and proof from a genesis proof block_0.json
    pub fn get_init_data(path: &PathBuf) -> Result<ValConfigs,std::io::Error> {
        let file = std::fs::File::open(path)?;
        let reader = std::io::BufReader::new(file);
        let configs: ValConfigs = serde_json::from_reader(reader).expect("init_configs.json should deserialize");
        return Ok(configs);
    }

}

impl UserConfigs {
    /// New user configs
    pub fn new(block: Block) -> UserConfigs{
        UserConfigs {
            /// Block zero of the onboarded miner
            block_zero: block,
        }
    }
        /// Creates the json file needed for onchain account creation - user
    pub fn create_user_manifest(
        &self,
        mut json_path: PathBuf,
    ){
        //where file will be saved
        json_path.push("account.json");

        let mut file = File::create(json_path.as_path()).unwrap();
        let buf = serde_json::to_string(&self ).expect("Manifest should export to json");
        file.write(&buf.as_bytes() )
            .expect("Could not write account.json");
    }
   /// Extract the preimage and proof from a genesis proof block_0.json
    pub fn get_init_data(path: &PathBuf) -> Result<UserConfigs,std::io::Error> {
        let file = std::fs::File::open(path)?;
        let reader = std::io::BufReader::new(file);
        let configs: UserConfigs = serde_json::from_reader(reader).expect("account.json should deserialize");
        return Ok(configs);
    }
}

#[test]
fn test_parse_init_file() {
    use crate::account::ValConfigs;
    let fixtures = PathBuf::from("../fixtures/eve_init_stage.json");
    let init_configs = ValConfigs::get_init_data(&fixtures).unwrap();
    assert_eq!(init_configs.op_fullnode_network_addresses, "134.122.115.12", "Could not parse network address");

    let consensus_key_vec = decode("cac7909e7941176e76c55ddcfae6a9c13e2be071593c82cac685e7c82d7ffe9d").unwrap();
    
    assert_eq!(init_configs.op_consensus_pubkey, consensus_key_vec, "Could not parse pubkey");

    assert_eq!(init_configs.op_consensus_pubkey, consensus_key_vec, "Human name must match");

}