use std::path::PathBuf;

use libra_global_constants::NODE_HOME;
use structopt::StructOpt;
use rustyline::error::ReadlineError;
use rustyline::Editor;
use libra_management::error::Error;

use crate::{keyscheme::KeyScheme, storage_helper::StorageHelper};
use dirs;
#[derive(Debug, StructOpt)]
pub struct Init {
    #[structopt(long, short)]
    pub namespace: String,
    #[structopt(long, short)]
    pub path: Option<PathBuf>,
}


impl Init {
    pub fn execute(self) -> Result<String, Error> {
        
        let mut rl = Editor::<()>::new();

        println!("Enter your 0L mnemonic");

        let readline = rl.readline(">> ");

        match readline {
            Ok(mnemonic_string) => {
                let path: PathBuf;
                if self.path.is_some() {
                    path = self.path.unwrap();
                } else { 
                    path = dirs::home_dir().unwrap().join(NODE_HOME);
                }
                let keys = KeyScheme::new_from_mnemonic(mnemonic_string);
                key_store_init(&path, self.namespace.clone(), keys)
                
                // let helper = StorageHelper::new_with_path(path.into());
                // helper.initialize_with_mnemonic(self.namespace.clone(), mnemonic_string);
            }
            Err(ReadlineError::Interrupted) => {
                println!("CTRL-C");
                std::process::exit(-1);

            }
            Err(ReadlineError::Eof) => {
                println!("CTRL-D");
                std::process::exit(-1);
            }
            Err(err) => {
                println!("Error: {:?}", err);
                std::process::exit(-1);

            }
        }

        Ok("Keys Generated".to_string())
    }
}

pub fn key_store_init(path: &PathBuf, name: String, keys: KeyScheme) {
    let helper = StorageHelper::new_with_path(path.to_owned().into());
    helper.initialize_with_mnemonic(name, keys);
    println!("Key file initialized, saved to: {:?}", path.join("key_store.json"));
}