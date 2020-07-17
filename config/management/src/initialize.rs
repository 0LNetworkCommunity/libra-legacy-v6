use crate::{storage_helper::StorageHelper,error::Error};
use structopt::StructOpt;


#[derive(Debug, StructOpt)]
pub struct Initialize {
    #[structopt(long, short)]
    pub namespace: Option<String>,
    #[structopt(long, short)]
    pub mnemonic: Option<String>,
}

impl Initialize {
    pub fn execute(self) -> Result<String, Error> {
        let helper = StorageHelper::new();
        helper.initialize_with_menmonic(self.namespace.unwrap().clone(), self.mnemonic.unwrap().clone());


        Ok("Keys Generated".to_string())
    }
}