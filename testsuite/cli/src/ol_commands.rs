use crate::{
    client_proxy::ClientProxy,
    commands::{report_error, subcommand_execute, Command},
};

/// Major command for query operations.
pub struct OLCommand {}

impl Command for OLCommand {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["ol"]
    }
    fn get_description(&self) -> &'static str {
        "Open Libra operations"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        let commands: Vec<Box<dyn Command>> = vec![
            Box::new(OLCommandSentProof {}),
            // Box::new(QueryCommandGetSeqNum {}),
        ];

        subcommand_execute(&params[0], commands, client, &params[1..]);
    }
}

/// Sub commands to query balance for the account specified.
pub struct OLCommandSentProof {}

impl Command for OLCommandSentProof {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["send_proof", "s"]
    }
    fn get_params_help(&self) -> &'static str {
        "<preimage> <difficulty> <proof>"
    }
    fn get_description(&self) -> &'static str {
        "Send VDF proof transaction"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        // if params.len() != 4 {
        //     println!("Invalid number of arguments for balance query");
        //     return;
        // }
        match client.send_proof(&params, true) {
            Ok( _) => println!("succeed." ),
            Err(e) => report_error("Failed to send proof", e),
        }
    }
}
