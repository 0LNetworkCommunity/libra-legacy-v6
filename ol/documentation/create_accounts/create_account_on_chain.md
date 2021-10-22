# User Accounts
I'm Alice, I want to create a new user account, to publish smart contracts, etc.

I will need Bob to help onboard me. He needs to already have an account on chain, so he can submit my `account.json` file for me.

## TL;DR

Alice:
```
onboard keygen
onboard user
```
Wait for delay proof to finish, and send account.json to Bob.

Bob:
```
txs create-user -f <path/to/account.json>
```

## Alice: Create account configurations

If you don't have keys or mnemonic yet:

```
onboard keygen
```

If you have no previous files, you must run a delay proof, and create the account config file.
Run this in the directory you want the `account.json` to be placed. 

```
onboard user
```

If Alice already has a 0th proof mined for whatever reason:
```
onboard user --block-zero <path/to/proof_0.json>
```

IF you want the account.json to go into a different directory
```
onboard user --output-dir <path/to/account.json>
```

## Alice: send the account.json
Send the file to Bob, whatever way is preferred.

## Bob: send account creation tx

1. Copy Alice's `account.json` somewhere practical.
2. Send the onboarding transaction
```
txs create-account -f <path/to/account.json>
```

## Set Slow Wallet, or Community Wallet

If Alice wants to set an address as a `community wallet`, or `slow` then she needs to wait for Bob to confirm the account already exists on chain.

Then Alice should do:

For community:
```
txs wallet --community
```

For slow:
```
txs wallet --slow
```


### Troubleshooting:

#### Unreachable
If <their-ip> is unreachable it is likely that the server is not running, or that the 3030 port is not open to the public.

If it is not reachable, the `file` option below is possible.

#### Tx Sequence number
If there is an issue with sequence_number being out of sync. It's like that an automated transaction (like `miner`), got a transaction sent concurrently. Retry the transaction.
