use std::path::PathBuf;

use structopt::StructOpt;
use rustyline::error::ReadlineError;
use rustyline::Editor;
use libra_management::error::Error;

use crate::storage_helper::StorageHelper;

#[derive(Debug, StructOpt)]
pub struct Init {
    #[structopt(long, short)]
    pub namespace: String,
    #[structopt(long, short)]
    pub path: PathBuf,
}


impl Init {
    pub fn execute(self) -> Result<String, Error> {
        
        let mut rl = Editor::<()>::new();

        println!("Enter your 0L mnemonic");

        let readline = rl.readline(">> ");

        match readline {
            Ok(mnemonic_string) => {
                // let mnemonic_string_test = "average list time circle item couch resemble tool diamond spot winter pulse cloth laundry slice youth payment cage neutral bike armor balance way ice".to_string();
                // let user = self.path.join(format!("key_store.{}.json", &self.namespace));
                let helper = StorageHelper::new_with_path(self.path.into());
                helper.initialize_with_mnemonic(self.namespace.clone(), mnemonic_string);
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
