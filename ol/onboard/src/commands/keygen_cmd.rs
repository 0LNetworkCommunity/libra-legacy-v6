//! `keygen` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use ol_keys::{wallet, scheme::KeyScheme};
use diem_crypto::x25519;

/// `keygen` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct KeygenCmd {
  #[options(short="w", help = "who am I?")]
  whoami: bool,
}


impl Runnable for KeygenCmd {
    fn run(&self) {
        if self.whoami {
          let (auth, addr, wallet) = wallet::get_account_from_prompt();
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
        } else {
          wallet::keygen();
        }
        
    }
}
