// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use std::fs;

use crate::{
    client_proxy::ClientProxy,
    commands::{blocking_cmd, report_error, subcommand_execute, Command},
};

/// Major command for account related operations.
pub struct AccountCommand {}

impl Command for AccountCommand {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["account", "a"]
    }
    fn get_description(&self) -> &'static str {
        "Account operations"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        let commands: Vec<Box<dyn Command>> = vec![
            Box::new(AccountCommandCreateLocal {}),
            Box::new(AccountCommandListAccounts {}),
            Box::new(AccountCommandRecoverWallet {}),
            Box::new(AccountCommandWriteRecovery {}),
            Box::new(AccountCommandMint {}),
            Box::new(AccountCommandAddCurrency {}),
            Box::new(AccountCommandCreateUser {}),
            Box::new(AccountCommandCreateVal {}),
            Box::new(AccountCommandAutopayEnable {}),
            Box::new(AccountCommandAutopayCreate {}),
            Box::new(AccountCommandAutopayBatch {}),
            Box::new(AccountCommandUpdateValConfig {}),
        ];

        subcommand_execute(&params[0], commands, client, &params[1..]);
    }
}

/// Sub command to create a random local keypair and account index. This does not have any on-chain effect.
pub struct AccountCommandCreateLocal {}

impl Command for AccountCommandCreateLocal {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["create", "c"]
    }
    fn get_description(&self) -> &'static str {
        "Create a local account--no on-chain effect. Returns reference ID to use in other operations"
    }
    fn execute(&self, client: &mut ClientProxy, _params: &[&str]) {
        println!(">> Creating/retrieving next local account from wallet");
        match client.create_next_account(true) {
            Ok(account_data) => println!(
                "Created/retrieved local account #{} address {}",
                account_data.index,
                hex::encode(account_data.address)
            ),
            Err(e) => report_error("Error creating local account", e),
        }
    }
}

/// Sub command to recover wallet from the file specified.
pub struct AccountCommandRecoverWallet {}

impl Command for AccountCommandRecoverWallet {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["recover", "r"]
    }
    fn get_params_help(&self) -> &'static str {
        "<file_path>"
    }
    fn get_description(&self) -> &'static str {
        "Recover Libra wallet from the file path"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        println!(">> Recovering Wallet");
        match client.recover_wallet_accounts(&params) {
            Ok(account_data) => {
                println!(
                    "Wallet recovered and the first {} child accounts were derived",
                    account_data.len()
                );
                for data in account_data {
                    println!("#{} address {}", data.index, hex::encode(data.address));
                }
            }
            Err(e) => report_error("Error recovering Libra wallet", e),
        }
    }
}

/// Sub command to backup wallet to the file specified.
pub struct AccountCommandWriteRecovery {}

impl Command for AccountCommandWriteRecovery {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["write", "w"]
    }
    fn get_params_help(&self) -> &'static str {
        "<file_path>"
    }
    fn get_description(&self) -> &'static str {
        "Save Libra wallet mnemonic recovery seed to disk"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        println!(">> Saving Libra wallet mnemonic recovery seed to disk");
        match client.write_recovery(&params) {
            Ok(_) => println!("Saved mnemonic seed to disk"),
            Err(e) => report_error("Error writing mnemonic recovery seed to file", e),
        }
    }
}

/// Sub command to list all accounts information.
pub struct AccountCommandListAccounts {}

impl Command for AccountCommandListAccounts {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["list", "la"]
    }
    fn get_description(&self) -> &'static str {
        "Print all accounts that were created or loaded"
    }
    fn execute(&self, client: &mut ClientProxy, _params: &[&str]) {
        client.print_all_accounts();
    }
}

/// Sub command to transfer coins from the faucet address to a recipient, creating an account at the recipient address if it does not already exist.
pub struct AccountCommandMint {}

impl Command for AccountCommandMint {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["mint", "mintb", "m", "mb"]
    }
    fn get_params_help(&self) -> &'static str {
        "<receiver_account_ref_id>|<receiver_account_address> <number_of_coins> <currency_code> [use_base_units (default=false)]"
    }
    fn get_description(&self) -> &'static str {
        "Send currency of the given type from the faucet address to the given recipient address. Creates an account at the recipient address if one does not already exist. Suffix 'b' is for blocking"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        if params.len() < 4 || params.len() > 5 {
            println!("Invalid number of arguments for mint");
            return;
        }
        let is_blocking = blocking_cmd(params[0]);
        match client.mint_coins(&params, is_blocking) {
            Ok(_) => {
                if is_blocking {
                    println!("Finished sending coins from faucet!");
                } else {
                    // If this value is updated, it must also be changed in
                    // setup_scripts/docker/mint/server.py
                    println!("Request submitted to faucet");
                }
            }
            Err(e) => report_error("Error transferring coins from faucet", e),
        }
    }
}

/// Sub command for adding a zero balance in a particular currency to an account.
pub struct AccountCommandAddCurrency {}

impl Command for AccountCommandAddCurrency {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["addc", "addcb", "ac", "acb"]
    }
    fn get_params_help(&self) -> &'static str {
        "<account_address> <currency_code>"
    }
    fn get_description(&self) -> &'static str {
        "Add specified currency to the account. Suffix 'b' is for blocking"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        if params.len() < 3 {
            println!("Invalid number of arguments for adding currency to account");
            return;
        }
        println!(">> Adding zero balance in currency to account");
        let is_blocking = blocking_cmd(params[0]);
        match client.add_currency(&params, is_blocking) {
            Ok(_) => {
                if is_blocking {
                    println!("Finished adding currency to account!");
                } else {
                    // If this value is updated, it must also be changed in
                    // setup_scripts/docker/mint/server.py
                    println!("Currency addition request submitted");
                }
            }
            Err(e) => report_error("Error adding zero balance in currency to account", e),
        }
    }
}

//////// 0L ////////
/// 0L Sub command to create a user account on-chain using a vdf proof.
pub struct AccountCommandCreateUser {}

impl Command for AccountCommandCreateUser {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["create_user", "cu"]
    }
    fn get_description(&self) -> &'static str {
        "Create on-chain user account from proof"
    }
    fn get_params_help(&self) -> &'static str {
        "<sending_account> <path_to_proof_file>"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        match client.create_user(params, true) {
            Ok(()) => println!("Created account"),
            Err(e) => report_error("Error creating user account", e),
        }
    }
}


//////// 0L ////////
/// 0L Sub command to create a validator account.
pub struct AccountCommandCreateVal {}

impl Command for AccountCommandCreateVal {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["create_val", "cv"]
    }
    fn get_description(&self) -> &'static str {
        "Create on-chain user account and configure validator"
    }
    fn get_params_help(&self) -> &'static str {
        "<sending_account> <path_to_proof_file>"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        match client.create_val(params, true) {
            Ok(()) => println!("Created account"),
            Err(e) => report_error("Error creating user account", e),
        }
    }
}

//////// 0L ////////
/// 0L Sub command for the operator to include a validator.
pub struct AccountCommandUpdateValConfig {}

impl Command for AccountCommandUpdateValConfig {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["update_val_config", "uvc"]
    }
    fn get_description(&self) -> &'static str {
        "Operator updates a val config"
    }
    fn get_params_help(&self) -> &'static str {
        "<sending_account> <path_to_account_file>"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        match client.update_val_configs(params, true) {
            Ok(()) => println!("Val configs updated"),
            Err(e) => report_error("Error updating val configs", e),
        }
    }
}

/// 0L Sub command to create a validator account.
pub struct AccountCommandSetOperator {}

impl Command for AccountCommandSetOperator {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["set_operator", "so"]
    }
    fn get_description(&self) -> &'static str {
        "Validator picks a new operator"
    }
    fn get_params_help(&self) -> &'static str {
        "<sending_account> <path_to_account_file>"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        match client.set_operator(params, true) {
            Ok(()) => println!("Operator updated"),
            Err(e) => report_error("Error updating operator", e),
        }
    }
}

//////// 0L ////////
/// 0L Sub command to enable autopay state on system and user account.
pub struct AccountCommandAutopayEnable {}

impl Command for AccountCommandAutopayEnable {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["autopay_enable", "ae"]
    }
    fn get_description(&self) -> &'static str {
        "Enables Autopay functionality on an account"
    }
    fn get_params_help(&self) -> &'static str {
        "<sending_account>"
    }
    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        assert!(
            params.len() == 2,
            "Invalid number of arguments to enable autopay. Did you pass your account address?"
        );

        match client.autopay_enable(params[1]) {
            Ok(()) => println!("Enabled Autopay"),
            Err(e) => report_error("Error creating local account", e),
        }
    }
}

//////// 0L ////////
/// 0L Sub command to create a new autopay instruction.
pub struct AccountCommandAutopayCreate {}

impl Command for AccountCommandAutopayCreate {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["autopay_instruction", "ai"]
    }
    fn get_description(&self) -> &'static str {
        "Creates Autopay instruction"
    }
    fn get_params_help(&self) -> &'static str {
        "<sending_account> <instruction_id> <payee_account> <end_epoch> <percent_integer>"
    }

    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        match client.autopay_create(params, true) {
            Ok(()) => println!("Created autopay instruction"),
            Err(e) => report_error("Error on autopay instruction tx", e),
        }
    }
}

//////// 0L ////////
/// 0L Sub command to create a new autopay instruction.
pub struct AccountCommandAutopayBatch {}

impl Command for AccountCommandAutopayBatch {
    fn get_aliases(&self) -> Vec<&'static str> {
        vec!["autopay_batch", "ab"]
    }
    fn get_description(&self) -> &'static str {
        "Batches Autopay instructions from file."
    }
    fn get_params_help(&self) -> &'static str {
        "<file path>"
    }

    fn execute(&self, client: &mut ClientProxy, params: &[&str]) {
        // do loop in here
        let file = fs::File::open(params[1])
            .expect("file should open read only");
        let json: serde_json::Value = serde_json::from_reader(file)
            .expect("file should be proper JSON");
        let inst = json.get("instructions")
            .expect("file should have array of instructions");
        let batch = inst.as_array().unwrap().into_iter();
        // TODO: query instructions on-chain to get highest id number.
        struct Instruction {
            uid: u64,
            destination: String,
            percent: u64,
            end_epoch: u64,
        }
        let list: Vec<Instruction> = batch.map(|value|{
            let inst = value.as_object().expect("expected json object");
            Instruction {
                uid: inst["uid"].as_u64().unwrap(),
                destination: inst["destination"].as_str().unwrap().to_owned(),
                percent: inst["percent_int"].as_u64().unwrap(),
                end_epoch: inst["end_epoch"].as_u64().unwrap(),
            }
        }).collect();

        match client.autopay_enable("0") {
            Ok(()) => println!("Autopay enabled"),
            Err(e) => report_error("error creating local account", e),
        }

        for inst in list {
            match client.autopay_batch(
                inst.uid,
                inst.destination.parse().unwrap(),
                inst.end_epoch,
                inst.percent
            ){
                Ok(()) => println!("Submitted autopay batch instruction, uid: {}", inst.uid),
                Err(e) => report_error("Error submitting batch autopay", e),
            }
        }
    }
}