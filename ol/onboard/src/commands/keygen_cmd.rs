//! `keygen` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use ol_keys::wallet;
/// `keygen` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct KeygenCmd {
  #[options(short="w", help = "who am I?")]
  whoami: bool,
}


impl Runnable for KeygenCmd {
    fn run(&self) {
        if self.whoami {
          let (auth, addr, _) = wallet::get_account_from_prompt();
          println!("\n0L ACCOUNT\n");
          println!("address: {}", addr);
          println!("authentication key (for account creation): {}\n", auth);

        } else {
          wallet::keygen();
        }
        
    }
}
