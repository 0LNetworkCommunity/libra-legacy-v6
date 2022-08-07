//! TxsApp Subcommands
//!
//! This is where you specify the subcommands of your application.
//!
//! The default application comes with two subcommands:
//!
//! - `start`: launches the application
//! - `version`: print application version
//!
//! See the `impl Configurable` below for how to specify the path to the
//! application's configuration file.

pub mod autopay_batch_cmd;
pub mod burn_pref_cmd;
pub mod community_pay_cmd;
pub mod create_account_cmd;
pub mod demo_cmd;
pub mod transfer_cmd;
pub mod val_config_cmd;
pub mod wallet_cmd;

mod authkey_cmd;
mod autopay_cmd;
mod create_validator_cmd;
mod oracle_upgrade_cmd;
mod relay_cmd;
mod valset_cmd;
mod version_cmd;
mod vouch_cmd;

use self::{
    authkey_cmd::AuthkeyCmd, autopay_batch_cmd::AutopayBatchCmd, autopay_cmd::AutopayCmd,
    burn_pref_cmd::BurnPrefCmd, community_pay_cmd::CommunityPayCmd,
    create_account_cmd::CreateAccountCmd, create_validator_cmd::CreateValidatorCmd,
    demo_cmd::DemoCmd, oracle_upgrade_cmd::OracleUpgradeCmd, relay_cmd::RelayCmd,
    transfer_cmd::TransferCmd, val_config_cmd::ValConfigCmd, valset_cmd::ValSetCmd,
    version_cmd::VersionCmd, vouch_cmd::VouchCmd, wallet_cmd::WalletCmd,
};
use crate::config::AppCfg;
use crate::entrypoint;
use abscissa_core::{Command, Configurable, Help, Options, Runnable};
use ol::commands::CONFIG_FILE;
use std::path::PathBuf;

/// TxsApp Subcommands
#[derive(Command, Debug, Options, Runnable)]
pub enum TxsCmd {
    /// The `create-account` subcommand
    #[options(help = "submit tx to create a user account from account.json file")]
    CreateAccount(CreateAccountCmd),

    /// The `create-validator` subcommand
    #[options(help = "submit tx to create a validator from account.json file")]
    CreateValidator(CreateValidatorCmd),

    /// Transfer balance between accounts
    #[options(help = "transfer funds between accounts")]
    Transfer(TransferCmd),

    /// Community payment proposal tx
    #[options(help = "create a community wallet payment proposal")]
    CommunityPay(CommunityPayCmd),

    /// The `oracle-upgrade` subcommand
    #[options(help = "submit an oracle transaction to upgrade stdlib")]
    OracleUpgrade(OracleUpgradeCmd),

    /// The `autopay` subcommand
    #[options(help = "enable or disable autopay")]
    Autopay(AutopayCmd),

    /// The `autopay-batch` subcommand
    #[options(help = "batch autopay transactions from json file")]
    AutopayBatch(AutopayBatchCmd),

    // --- End of STDLIB SCRIPT COMMANDS ---
    /// The `help` subcommand
    #[options(help = "get usage information")]
    Help(Help<Self>),

    /// The `version` subcommand
    #[options(help = "display version information")]
    Version(VersionCmd),

    /// The `demo` subcommand
    #[options(help = "noop demo transaction, prints `hello world` in move")]
    Demo(DemoCmd),

    /// The `relay` subcommand
    #[options(help = "submit a saved transaction from file")]
    Relay(RelayCmd),

    /// The `valset` subcommand
    #[options(help = "join or leave the validator universe, i.e. candidate for validator set")]
    ValSet(ValSetCmd),

    /// The `wallet` subcommand
    #[options(help = "set a wallet type to the address")]
    Wallet(WalletCmd),

    /// The `authkey` subcommand to rotate an auth key (change mnemonic that controls address)
    #[options(help = "rotate an account's authorization key")]
    Authkey(AuthkeyCmd),

    /// The `val-config` subcommand updates validator configuration on chain.
    #[options(help = "update the validator and operators on-chain configs (e.g. discovery)")]
    ValConfig(ValConfigCmd),

    /// The `burn-pref` subcommand sets the burn preferences for an account.
    #[options(
        help = "set burn preferences for an account, optionall send to community wallet index"
    )]
    BurnPref(BurnPrefCmd),

    /// The `vouch` subcommand for validators to pick trusted peers
    #[options(
        help = "send a vouch_for tx for an account, which you'll include in your trusted list"
    )]
    Vouch(VouchCmd),
}

/// This trait allows you to define how application configuration is loaded.
impl Configurable<AppCfg> for TxsCmd {
    /// Location of the configuration file
    fn config_path(&self) -> Option<PathBuf> {
        // Check if the config file exists, and if it does not, ignore it.
        // If you'd like for a missing configuration file to be a hard error
        // instead, always return `Some(CONFIG_FILE)` here.

        let mut config_path = entrypoint::get_node_home();

        config_path.push(CONFIG_FILE);
        if config_path.exists() {
            // println!("initializing from config file: {:?}", config_path);
            Some(config_path)
        } else {
            // println!("config file not yet existing: {:?}", config_path);
            None
        }
    }
}
