//! `whoami` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use ol_keys::{wallet, scheme::KeyScheme};
use diem_crypto::x25519;
use ol_types::account::ValConfigs;

use crate::prelude::app_config;

/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct WhoamiCmd {}

impl Runnable for WhoamiCmd {
    /// Print version message
    fn run(&self) {
          let app_cfg = app_config().to_owned();

          let (auth, addr, wallet) = wallet::get_account_from_prompt();

          let val_cfg = ValConfigs::new(
            None, 
            KeyScheme::new(&wallet), 
            app_cfg.profile.ip, 
            app_cfg.profile.vfn_ip,
            None, 
            None
          );

          println!("\n0L ACCOUNT\n");
          println!("address: {}", addr);
          println!("authentication key (for account creation): {}\n", auth);

          let scheme = KeyScheme::new(&wallet);
          println!("----- pub ed25519 keys -----\n");
          println!("key 0: {}\n", scheme.child_0_owner.get_public());
          println!("key 1: {}\n", scheme.child_1_operator.get_public());
          println!("key 2: {}\n", scheme.child_2_val_network.get_public());
          println!("key 3: {}\n", scheme.child_3_fullnode_network.get_public());
          println!("key 4: {}\n", scheme.child_4_consensus.get_public());
          println!("key 5: {}\n", scheme.child_5_executor.get_public());

          println!("----- pub x25519 network keys -----\n");
          // println!("0 key: {}\n", hex::encode());

          let val_net_priv = scheme.child_2_val_network.get_private_key().to_bytes();

          let key = x25519::PrivateKey::from_ed25519_private_bytes(&val_net_priv)
                    .expect("Unable to convert key");
          println!("key 3 - validator network key: {:?}\n", key.public_key().to_string());

          let fn_net_priv = scheme.child_3_fullnode_network.get_private_key().to_bytes();

          let key = x25519::PrivateKey::from_ed25519_private_bytes(&fn_net_priv)
                    .expect("Unable to convert key");
          println!("key 3 - fullnode network key: {:?}\n", &key.public_key().to_string());
          
          
          println!("----- noise protocol addresses -----\n");
          
          println!("Validator (encrypted) address on VALIDATOR network\n");
          println!("{}\n", val_cfg.op_val_net_addr_for_vals);

          println!("Validator address on PRIVATE VFN Network\n");
          println!("{}\n", val_cfg.op_val_net_addr_for_vfn);


          println!("VFN address on PUBLIC fullnode network\n");
          println!("{}\n", val_cfg.op_vfn_net_addr_for_public);
  }
}
