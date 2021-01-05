use crate::{
    client_proxy::ClientProxy,
    commands::{subcommand_execute, Command},
};
/// Major command for query operations.
pub struct OracleCommand {}

impl Command for OracleCommand {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["oracle", "o"]
    }
    fn get_description(&self) -> &'static str {
        "Oracle related commands"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        let commands: Vec<Box<dyn Command>> = vec![
            Box::new(OracleCommandUpdate {}),
        ];

        subcommand_execute(&params[0], commands, client, &params[1..]);
    }
}

pub struct OracleCommandUpdate {}

impl Command for OracleCommandUpdate {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["upgrade", "u"]
    }

    fn get_params_help(&self) -> &'static str {
        "Usage: oracle upgrade <sender> <path_to_new_stdlib>"
    }

    fn get_description(&self) -> &'static str {
        "On-chain upgrade of stdlib"
    }

    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {

        match client.oracle_upgrade_stdlib(params, true) {
            Ok(_) => println!("Successfully finished execution"),
            Err(e) => println!("{}", e),
        }
    }
}

pub struct OracleQueryCommandUpdate {}

impl Command for OracleQueryCommandUpdate {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["query", "q"]
    }

    fn get_params_help(&self) -> &'static str {
        "Usage: oracle query"
    }

    fn get_description(&self) -> &'static str {
        "query on-chain upgrade "
    }

    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        match client.query_oracle_upgrade(params) {
            Ok(view) => {
                match view {
                    Some(o)=>println!("{:?}", o),
                    None=> println!("Nothing found")
                }
            },
            Err(e) => println!("{}", e),
        }
    }
}


