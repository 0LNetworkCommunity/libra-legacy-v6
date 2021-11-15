# Creating User Accounts

I'm Alice, I want to create a new user account, to publish smart contracts, etc.

I will need Bob to help onboard me. He already has an account on chain, with GAS coins.

When Bob sends me money for the first time, my account is created.

Note: For the onboarding transaction the address will not suffice. Bob needs to send a transfer to Alice's `authentication key` which can be thought of as a long address.

## TL;DR

Alice:
```
# if you don't have a mnemonic
onboard keygen

# send your `auth key` to Bob so he can complete tx

```

Bob:

Needs to send a minimum of 1 GAS coin so that Alice's account gets created.
```
txs create-user -a <alice's auth key> -c <how many coins to send to alice>

# check that the account was created:
ol query --balance -a <alice's ACCOUNT>
```

## Alice: Create account configurations

If you don't have keys or mnemonic yet:

```
onboard keygen
```

If you already have a mnemonic, and misplaced your account `address` or `authentication key`, you can retrieve from mnemonic with:

```
# use keygen with --whoami, or -w

onboard keygen -whoami
```
## Alice: tell Bob your authkey

The `authkey` is safe to share. It is needed for your account creation. 
Subsequent transactions with your account only need the `address`
## Bob: send account creation tx

Send the onboarding transaction
```
txs create-user -a <alice's auth key> -c <how many coins to send to alice>
```


## Alice or Bob: Confirm the account was created

If the account creation was successful anyone should be able to see Alice's balance (of 1 GAS) with the following command.

```
ol query --balance -a <alice's ACCOUNT>
```

## Alice: Set Slow Wallet, or Community Wallet

Now that the account is created, Alice can change the wallet to a couple of special types: `community` or `slow`.


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

#### Tx Sequence number
If there is an issue with sequence_number being out of sync. It's like that an automated transaction (like `miner`), got a transaction sent concurrently. Retry the transaction.
