use std::path::PathBuf;
use libra_global_constants::NODE_HOME;
use structopt::StructOpt;
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
        let mnemonic_str = keygen::account_from_prompt().2.mnemonic();
        let path: PathBuf;
        if self.path.is_some() {
            path = self.path.unwrap();
        } else { 
            path = dirs::home_dir().unwrap().join(NODE_HOME);
        }
        let keys = KeyScheme::new_from_mnemonic(mnemonic_str);
        key_store_init(&path, &self.namespace.clone(), keys, true);

        Ok("Keys Generated".to_string())
    }
}

pub fn key_store_init(path: &PathBuf, name: &str, keys: KeyScheme, is_genesis: bool) {
    let helper = StorageHelper::new_with_path(path.to_owned().into());
    helper.initialize_with_mnemonic(name.to_owned(), keys, is_genesis);
    println!("validator keys initialized, file saved to: {:?}", path.join("key_store.json"));
}