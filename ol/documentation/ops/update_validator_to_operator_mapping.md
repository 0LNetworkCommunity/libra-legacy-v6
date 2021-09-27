# Update Validator to Operator mapping

Validators nominate an Operator to execute transactions. Ordinarily this is carried out by the onboarding transaction, with the configuratiosn formatted by the miner validator wizard tool.

However sometimes this must be changed after the initialization, either to correct the parameters, or to change an operator.

# What you will need

- an account.json, default or with new settings.
- a cli connected to network.

# Create an account.json

If the `miner` has been used in the past, on the host, it likely has config files in place. So simply run the `miner account` subcommand.

If this is the first time using `miner` on the host, a new account.json can be created with `val-wizard` subcommand if the miner application has not been initialized.
`miner val-wizard`

# Updating Validator-Operator pair

Important: Many Validator run their own Operators. In that case, the 0th derivation of the mnemonic is the Owner/Validator key, and 1st derivation is the Operator key.

## 0. Start Cli

`make client` and enter the mnemonic.

Q: do Operators need to create their configuration on chain?

## 2. Validator nominates an operator.

libra% `account set_operator 0 full/path/to/account.json`

Note: the `0` refers to 0th address in the wallet, the owner/validator account.

## 2. Operators write their configs to the Validator's account

libra% `account update_val_config 1 full/path/to/account.json`

Note: the `1` refers to first address in the wallet, the operator account.