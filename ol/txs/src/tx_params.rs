//! Txs App submit_tx module
#![forbid(unsafe_code)]
use crate::config::AppCfg;
use anyhow::{bail, Error};

use diem_crypto::{
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey},
    test_utils::KeyPair,
};
use diem_global_constants::OPERATOR_KEY;

use diem_secure_storage::{CryptoStorage, Namespaced, OnDiskStorage, Storage};
use diem_types::{account_address::AccountAddress, chain_id::NamedChain, waypoint::Waypoint};
use diem_types::{chain_id::ChainId, transaction::authenticator::AuthenticationKey};
use ol::node::client::find_a_remote_jsonrpc;
use ol_keys::{scheme::KeyScheme, wallet};

use diem_wallet::WalletLibrary;
use ol_types::{
    self,
    config::{TxCost, TxType},
    fixtures,
};
use reqwest::Url;
use std::path::PathBuf;

/// All the parameters needed for a client transaction.
#[derive(Debug)]
pub struct TxParams {
    /// User's 0L authkey used in mining.
    pub auth_key: AuthenticationKey,
    /// Address of the signer of transaction, e.g. owner's operator
    pub signer_address: AccountAddress,
    /// Optional field for Miner, for operator to send owner
    // TODO: refactor so that this is not par of the TxParams type
    pub owner_address: AccountAddress,
    /// Url
    pub url: Url,
    /// waypoint
    pub waypoint: Waypoint,
    /// KeyPair
    pub keypair: KeyPair<Ed25519PrivateKey, Ed25519PublicKey>,
    /// tx cost and timeout info
    pub tx_cost: TxCost,
    // /// User's Maximum gas_units willing to run. Different than coin.
    // pub max_gas_unit_for_tx: u64,
    // /// User's GAS Coin price to submit transaction.
    // pub coin_price_per_unit: u64,
    // /// User's transaction timeout.
    // pub user_tx_timeout: u64, // for compatibility with UTC's timestamp.
    /// Chain id
    pub chain_id: ChainId,
    /// is using operator for signing
    pub is_operator: bool,
}

/// Find a url to use for connecting a client.
/// The default behavior is to search a randomized list of upsteam_peers in 0L.toml
/// can optionally be forced to use the first peer on that list.
pub fn what_url(config: &AppCfg, use_first_upstream: bool) -> Result<Url, Error> {
    // get the first in the list of upstreams
    if use_first_upstream {
        Ok(config.profile.upstream_nodes[0].to_owned())
    } else {
        if let Some(w) = config.chain_info.base_waypoint {
            Ok(find_a_remote_jsonrpc(&config, w)?.url()?)
        } else {
            bail!("no base_waypoint provided in 0L.toml")
        }
    }
}

impl TxParams {
    /// wrapper to initialize tx params in all cases
    pub fn new(
        config: AppCfg,
        url_opt: Option<Url>,
        waypoint: Option<Waypoint>,
        swarm_path: Option<PathBuf>,
        swarm_persona: Option<String>,
        tx_type: TxType,
        is_operator: bool,
        use_first_url: bool,
        wallet_opt: Option<&WalletLibrary>,
    ) -> Result<Self, Error> {
        // unless overriding with a URL, or explicitly selecting the first node from list
        // default behavior is to try all upstreams in upstream_nodes, and pick the first that can give metadata
        let mut tx_params: TxParams = match swarm_path {
            Some(s) => Self::get_tx_params_from_swarm(
                s,
                swarm_persona.expect("need a swarm 'persona' with credentials in fixtures."),
                is_operator,
            )?,
            _ => {
                let url = match url_opt {
                    Some(u) => u,
                    None => what_url(&config, use_first_url)?,
                };

                if is_operator {
                    Self::get_oper_params(&config, tx_type, url, waypoint)?
                } else {
                    // Get from 0L.toml e.g. ~/.0L/0L.toml, or use Profile::default()
                    Self::get_tx_params_from_toml(
                        config.clone(),
                        tx_type,
                        wallet_opt,
                        url,
                        waypoint,
                        swarm_path.as_ref().is_some(),
                    )?
                }
            }
        };

        if let Some(w) = waypoint {
            tx_params.waypoint = w
        }

        tx_params.is_operator = is_operator;

        Ok(tx_params)
    }

    /// Gets transaction params from the 0L project root.
    pub fn get_tx_params_from_toml(
        config: AppCfg,
        tx_type: TxType,
        wallet_opt: Option<&WalletLibrary>,
        url: Url,
        wp: Option<Waypoint>,
        is_swarm: bool,
    ) -> Result<Self, Error> {
        let (auth_key, address, wallet) = if let Some(wallet) = wallet_opt {
            wallet::get_account_from_wallet(wallet)?
        } else {
            wallet::get_account_from_prompt()
        };

        let waypoint = match wp {
            Some(w) => w,
            None => config.get_waypoint(None)?,
        };
        let keys = KeyScheme::new_from_mnemonic(wallet.mnemonic());
        let keypair = KeyPair::from(keys.child_0_owner.get_private_key());
        let tx_cost = config.tx_configs.get_cost(tx_type);

        let chain_id = if is_swarm {
            ChainId::new(NamedChain::TESTING.id())
        } else {
            // main net id
            ChainId::new(config.chain_info.chain_id.id())
        };

        let tx_params = TxParams {
            auth_key,
            signer_address: address,
            owner_address: address,
            url,
            waypoint,
            keypair,
            tx_cost: tx_cost.to_owned(),
            // max_gas_unit_for_tx: config.tx_configs.management_txs.max_gas_unit_for_tx,
            // coin_price_per_unit: config.tx_configs.management_txs.coin_price_per_unit, // in micro_gas
            // user_tx_timeout: config.tx_configs.management_txs.user_tx_timeout,
            chain_id,
            is_operator: false,
        };

        Ok(tx_params)
    }

    /// Extract params from a local running swarm
    pub fn get_tx_params_from_swarm(
        swarm_path: PathBuf,
        swarm_persona: String,
        is_operator: bool,
    ) -> Result<TxParams, Error> {
        let (url, waypoint) = ol_types::config::get_swarm_rpc_url(swarm_path);
        let mnem = fixtures::get_persona_mnem(&swarm_persona.as_str());
        let keys = KeyScheme::new_from_mnemonic(mnem);

        let keypair = if is_operator {
            KeyPair::from(keys.child_1_operator.get_private_key())
        } else {
            KeyPair::from(keys.child_0_owner.get_private_key())
        };

        let pubkey = keys.child_0_owner.get_public();
        let auth_key = AuthenticationKey::ed25519(&pubkey);
        let address = auth_key.derived_address();

        let tx_params = TxParams {
            auth_key,
            signer_address: address,
            owner_address: address,
            url,
            waypoint,
            keypair,
            tx_cost: TxCost {
                max_gas_unit_for_tx: 100_000,
                coin_price_per_unit: 1, // in micro_gas
                user_tx_timeout: 5_000,
            },

            chain_id: ChainId::new(NamedChain::TESTING.id()),
            is_operator,
        };

        println!("Info: Got tx params from swarm");
        Ok(tx_params)
    }

    /// Form tx parameters struct
    pub fn get_oper_params(
        config: &AppCfg,
        tx_type: TxType,
        url: Url,
        wp: Option<Waypoint>,
    ) -> Result<TxParams, Error> {
        let orig_storage = Storage::OnDiskStorage(OnDiskStorage::new(
            config.workspace.node_home.join("key_store.json").to_owned(),
        ));
        let storage = Storage::NamespacedStorage(Namespaced::new(
            format!("{}-oper", &config.profile.account.to_hex()),
            Box::new(orig_storage),
        ));
        // export_private_key_for_version
        let privkey = storage
            .export_private_key(OPERATOR_KEY)
            .expect("could not parse operator key in key_store.json");

        let keypair = KeyPair::from(privkey);
        let pubkey = &keypair.public_key; // keys.child_0_owner.get_public();
        let auth_key = AuthenticationKey::ed25519(pubkey);

        let waypoint = match wp {
            Some(w) => w,
            None => config.get_waypoint(None)?,
        };

        let tx_cost = config.tx_configs.get_cost(tx_type);
        Ok(TxParams {
            auth_key,
            signer_address: auth_key.derived_address(),
            owner_address: config.profile.account, // address of sender
            url,
            waypoint,
            keypair,
            tx_cost,
            chain_id: ChainId::new(1),
            is_operator: true,
        })
    }

    /// Gets transaction params from the 0L project root.
    pub fn get_tx_params_from_keypair(
        config: AppCfg,
        tx_type: TxType,
        keypair: KeyPair<Ed25519PrivateKey, Ed25519PublicKey>,
        wp: Option<Waypoint>,
        use_first_upstream: bool,
        is_swarm: bool,
    ) -> Result<TxParams, Error> {
        let waypoint = match wp {
            Some(w) => w,
            None => config.get_waypoint(None)?,
        };

        let chain_id = if is_swarm {
            ChainId::new(NamedChain::TESTING.id())
        } else {
            // main net id
            ChainId::new(config.chain_info.chain_id.id())
        };

        let tx_params = TxParams {
            auth_key: config.profile.auth_key,
            signer_address: config.profile.account,
            owner_address: config.profile.account,
            url: what_url(&config, use_first_upstream)?,
            waypoint,
            keypair,
            tx_cost: config.tx_configs.get_cost(tx_type),
            chain_id,
            is_operator: false,
        };

        Ok(tx_params)
    }

    /// creates params for unit tests
    pub fn test_fixtures() -> TxParams {
        // This mnemonic is hard coded into the swarm configs. see configs/config_builder
        // let mnem_path = format!("./fixtures/mnemonic/{}.mnem", persona);
        let mnemonic = "talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse".to_string();
        let keys = KeyScheme::new_from_mnemonic(mnemonic);
        let keypair = KeyPair::from(keys.child_0_owner.get_private_key());
        let pubkey = keys.child_0_owner.get_public();
        let signer_auth_key = AuthenticationKey::ed25519(&pubkey);
        let signer_address = signer_auth_key.derived_address();

        let url = Url::parse("http://localhost:8080").unwrap();
        let waypoint: Waypoint =
            "0:732ea2e1c3c5ee892da11abcd1211f22c06b5cf75fd6d47a9492c21dbfc32a46"
                .parse()
                .unwrap();

        TxParams {
            auth_key: signer_auth_key,
            signer_address,
            owner_address: signer_address,
            url,
            waypoint,
            keypair,
            tx_cost: TxCost::new(5_000),
            // max_gas_unit_for_tx: 5_000,
            // coin_price_per_unit: 1, // in micro_gas
            // user_tx_timeout: 5_000,
            chain_id: ChainId::new(4), // swarm/testnet
            is_operator: false,
        }
    }
}
