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
    pub path: String,
}


impl Init {
    pub fn execute(self) -> Result<String, Error> {
        
        let mut rl = Editor::<()>::new();

        println!("Enter your 0L mnemonic");

        let readline = rl.readline(">> ");

        match readline {
            Ok(mnemonic_string) => {
                dbg!(&mnemonic_string);
                dbg!(&self.path);

                let mnemonic_string_test = "average list time circle item couch resemble tool diamond spot winter pulse cloth laundry slice youth payment cage neutral bike armor balance way ice".to_string();

                let dir_str = "/root/node_data/";
                // let path = PathBuf::from(dir_str);

                let helper = StorageHelper::new_with_path(dir_str.into());
                helper.initialize_with_mnemonic(self.namespace.clone(), mnemonic_string_test);

                // let dir_str = "./";
                // let mut storage_config = OnDiskStorageConfig::default();
                // storage_config.set_data_dir(PathBuf::from(dir_str));
                // let mut file = PathBuf::from(dir_str);
                // file.push("storage.json");
                // storage_config.path = file;
                // storage_config.namespace = Some("alice".to_string());
                // let test = SecureBackend::OnDiskStorage(storage_config);
                // dbg!(test);
                // secure_backend::storage(s);
                // secure_backend::ValidatorBackend::from(secure_backend::DISK);
                // dbg!(management_backend);
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
