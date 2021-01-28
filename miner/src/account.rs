//! Formatters for libra account creation
use crate::block::Block;
use libra_crypto::x25519::PublicKey;
use libra_types::account_address::AccountAddress;
use serde::{de::Error, Deserialize, Deserializer, Serialize, Serializer};
use hex::{decode, encode};
use std::{fs::File, io::Write, path::PathBuf};
use libra_network_address::{NetworkAddress, encrypted::{TEST_SHARED_VAL_NETADDR_KEY, TEST_SHARED_VAL_NETADDR_KEY_VERSION}};
use libra_genesis_tool::keyscheme::KeyScheme;


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
    #[serde(serialize_with = "as_hex", deserialize_with = "from_hex")]
    pub op_validator_network_addresses: Vec<u8>,
    /// FullNode will use for network connections
    #[serde(serialize_with = "as_hex", deserialize_with = "from_hex")]
    pub op_fullnode_network_addresses: Vec<u8>,
    /// FullNode will use for network connections
    pub op_fullnode_network_addresses_string: NetworkAddress,
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
        keys: KeyScheme,
        ip_address: String,
    ) -> Self {
        // let keys = KeyScheme::new_from_mnemonic(mnemonic_string);
        let owner_address = keys.child_0_owner.get_address().to_string();
        // let op_authkey = keys.child_1_operator.get_address();
        // let net_addr: Ipv4Addr = ip_address.parse().expect("could not parse ip_address");
        let val_network_string = format!("/ip4/{}/tcp/6180", ip_address);
        let val_addr_obj: NetworkAddress = val_network_string.parse().expect("could not parse validator network address");
        let val_pubkey =  PublicKey::from_ed25519_public_bytes(
            &keys
            .child_2_val_network
            .get_public()
            .to_bytes()
        ).unwrap();
        let val_addr_obj = val_addr_obj.append_prod_protos(val_pubkey, 0);
        let encrypted_addr = vec![
            val_addr_obj.encrypt(
                &TEST_SHARED_VAL_NETADDR_KEY, //shared_val_netaddr_key: &Key,
                TEST_SHARED_VAL_NETADDR_KEY_VERSION,//key_version: KeyVersion,
                &owner_address.parse::<AccountAddress>().expect("unable to parse account address"), // account: &AccountAddress,
                0,
                0
            ).expect("unable to encrypt network address")
        ];
        // let serialized_addr = lcs::to_bytes(&encrypted_addr).unwrap();

        let fullnode_network_string = format!("/ip4/{}/tcp/6179", ip_address);
        let fn_addr_obj: NetworkAddress = fullnode_network_string.parse().expect("could not parse fullnode network address");
        let fn_pubkey =  PublicKey::from_ed25519_public_bytes(
            &keys
            .child_3_fullnode_network
            .get_public()
            .to_bytes()
        ).unwrap();
        let fn_addr_obj = fn_addr_obj.append_prod_protos(fn_pubkey, 0);

        Self {
            /// Block zero of the onboarded miner
            block_zero: block,
            ow_human_name: owner_address.clone(),
            op_address: keys.child_1_operator.get_address().to_string(),
            op_auth_key_prefix: keys.child_1_operator.get_authentication_key().prefix().to_vec(),
            op_consensus_pubkey: keys.child_4_consensus.get_public().to_bytes().to_vec(),
            op_validator_network_addresses: lcs::to_bytes(&encrypted_addr).unwrap(),
            op_fullnode_network_addresses: lcs::to_bytes(&fn_addr_obj).unwrap(),
            op_fullnode_network_addresses_string: fn_addr_obj.to_owned(),
            op_human_name: format!("{}-oper", owner_address),
        }
    }
    /// Creates the json file needed for onchain account creation - validator
    pub fn create_manifest(
        &self,
        mut json_path: PathBuf,
    ){
        //where file will be saved
        json_path.push("account.json");
        let mut file = File::create(json_path.as_path()).unwrap();
        let buf = serde_json::to_string(&self).expect("Config should be export to json");
        file.write(&buf.as_bytes() )
            .expect("Could not write account.json");
        println!("Account manifest saved to: {:?}", json_path);
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
    pub fn create_manifest(
        &self,
        mut json_path: PathBuf,
    ){
        //where file will be saved
        json_path.push("account.json");

        let mut file = File::create(json_path.as_path()).unwrap();
        let buf = serde_json::to_string(&self ).expect("Manifest should export to json");
        file.write(&buf.as_bytes() )
            .expect("Could not write account.json");
        println!("Account manifest saved to: {:?}", json_path);
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
    let fixtures = PathBuf::from("../fixtures/eve_init_test.json");
    let init_configs = ValConfigs::get_init_data(&fixtures).unwrap();
    assert_eq!(init_configs.op_fullnode_network_addresses, decode("2d0400a1230da90523180720151bcbc2adf48aefee3492a3c802ce35e347860f28dbcffe74068419f3b11812").unwrap(), "Could not parse network address");

    let consensus_key_vec = decode("cac7909e7941176e76c55ddcfae6a9c13e2be071593c82cac685e7c82d7ffe9d").unwrap();
    
    assert_eq!(init_configs.op_consensus_pubkey, consensus_key_vec, "Could not parse pubkey");

    assert_eq!(init_configs.op_consensus_pubkey, consensus_key_vec, "Human name must match");

}

#[test]
fn val_config_ip_address() {
    use libra_network_address::encrypted::EncNetworkAddress;

    let block =  Block {
        height: 0u64,
        elapsed_secs: 0u64,
        preimage: Vec::new(),
        proof: Vec::new(),
    };
    let eve_keys = KeyScheme::new_from_mnemonic("recall october regret kite undo choice outside season business wall quit arrest vacant arrow giggle vote ghost winter hawk soft cheap decide exhaust spare".to_string());
    let eve_account = eve_keys.derived_address();

    let val = ValConfigs::new(
        block,
        eve_keys,
        "161.35.13.169".to_string(),
    );
    
    let correct_fn_hex = "2d0400a1230da9052318072029fa0229ff55e1307caf3e32f3f4d0f2cb322cbb5e6d264c1df92e7740e1c06f0800".to_owned();
    assert_eq!(
        encode(&val.op_fullnode_network_addresses),
        correct_fn_hex
    );

    let correct_hex = "010000000000000000000000003e250c102074e46ce6160d0efb958f48e4ba3b5a5ac468080135881b885f9baef0da93a2a0b993823448da4d8bf0414d9acd8fea5b664688b864b54c8ec8ae".to_owned();
    assert_eq!(
        encode(&val.op_validator_network_addresses),
        correct_hex
    );

    let mut enc_addr: Vec<EncNetworkAddress> = lcs::from_bytes(&val.op_validator_network_addresses)
    .expect("couldn't deserialize encrypted network address");

    let dec_addrs = enc_addr.pop().unwrap().decrypt(
        &TEST_SHARED_VAL_NETADDR_KEY,
        &eve_account,
        0
    ).unwrap();

    assert_eq!(
        dec_addrs.to_string(),
        "/ip4/161.35.13.169/tcp/6180/ln-noise-ik/151bcbc2adf48aefee3492a3c802ce35e347860f28dbcffe74068419f3b11812/ln-handshake/0".to_string());
}