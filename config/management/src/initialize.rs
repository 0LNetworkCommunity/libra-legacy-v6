use crate::{error::Error, storage_helper::StorageHelper};
use structopt::StructOpt;

#[derive(Debug, StructOpt)]
pub struct Initialize {
    #[structopt(long, short)]
    pub namespace: String,
    #[structopt(long, short)]
    pub mnemonic: String,
    #[structopt(long, short)]
    pub path: String,
}

impl Initialize {
    pub fn execute(self) -> Result<String, Error> {
        let helper = StorageHelper::new_with_path(self.path.into());
        helper.initialize_with_menmonic(self.namespace.clone(), self.mnemonic.clone());
        Ok("Keys Generated".to_string())
    }
}
