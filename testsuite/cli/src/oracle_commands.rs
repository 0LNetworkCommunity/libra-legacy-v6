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
        vec!["update", "u"]
    }

    fn get_params_help(&self) -> &'static str {
        "Put the stdlib.mv into \"language\\stdlib\\oracle_payload before running this command."
    }

    fn get_description(&self) -> &'static str {
        "On-chain grade of stdlib"
    }

    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {

        match client.noop_demo(params, true) {
            Ok(_) => println!("Successfully finished execution"),
            Err(e) => println!("{}", e),
        }
    }
}

