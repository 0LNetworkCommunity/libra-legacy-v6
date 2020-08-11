use crate::{error::Error, storage_helper::StorageHelper};
use structopt::StructOpt;
use rustyline::error::ReadlineError;
use rustyline::Editor;

#[derive(Debug, StructOpt)]
pub struct Initialize {
    #[structopt(long, short)]
    pub namespace: String,
    #[structopt(long, short)]
    pub path: String,
}

impl Initialize {
    pub fn execute(self) -> Result<String, Error> {


        let mut rl = Editor::<()>::new();

        println!("Enter your 0L mnemonic");

        let readline = rl.readline(">> ");

        match readline {
            Ok(mnemonic_string) => {

                let helper = StorageHelper::new_with_path(self.path.into());
                helper.initialize_with_menmonic(self.namespace.clone(), mnemonic_string);
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
