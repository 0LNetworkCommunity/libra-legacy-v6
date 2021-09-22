
# DiemAccount

# Definitions

- prospective account: an account not created on chain.
- user account: an end user, that holds balance.
- validator account: a special account that can run a consensus node.
- onboarder: a account that simply relays an account creation transaction.

# Spec

## Creating Accounts

0L has made a number of modifications on the account creation workflow.

Creating of accounts needs to be permissionless, and not depend on a Diem root account. This also needs to be rate-limited in different cases.

All accounts created need to run a VDF proof off-chain before submitting to the chain for account to be created. As with any account-based blockchain, someone with GAS needs to send a transaction on behalf of the new account to be created.

### create_user_account_with_proof

This function creates a regular end-user account. This account is not a "validator" account, which has many more complex functionalities.

A prospective account, needs to first produce a valid account creation payload. This includes some metadata like an authorization key. Also importantly it submits a VDF proof which was produced offline.

### create_validator_account_with_proof

This creates a validator account.

There's an extra level of rate-limiting, but this time on the side of the person sending the account creation. There's a significant attack that can be carried out if it were possible for a person to create many new validator accounts in any given time. So we use VDFs for the user onboarding as well. The onboarder needs to complete VDFs for 7 epochs before they can create a validator account. This is checked in: MinerState::can_create_val_account(sender_addr)

## Transfers

WIP