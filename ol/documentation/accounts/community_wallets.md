# Wallet types

## Slow Wallets

Slow Wallets currently are simply an informational tag. All validator wallets and new accounts are set to "Slow". This means that the transfer limits are in effect on those wallets.

## Community Wallets

Different community programs may have an interest in increasing the transparency of their transfers, and donors may have an interest knowing their donations are going towards the stated purposes of a wallet they donated to.

"Community Wallets" are an opt-in setting a person or entity can add to an address they control. Community wallets have addtional benefits: they can receiving funds from the Autopay function, and can send unlimited amounts to Slow wallets.

To receive those benefits, a wallet enters a covenant which is enforced at the system level. It is: The community wallets transfers can be reviewed by the the validator set and slowed down, rejected, and ultimately frozen if repeated rejections occurr. Specifically:

- Transfers take a minimum of 3 epochs (days).
- A validator can "veto": vote to reject the transaction. This adds one epoch (24hrs) latency to the transaction. E.g. the first veto makes the transaction take 4 days, from time of submission, the second veto: 5 days.
- If 2/3rds validators veto the transaction, it gets "rejected". The payment is cancelled.
- When a Community Wallet has three consecutive transactions rejected, the wallet is "frozen"
- Frozen wallets cannot make transfers.
- A wallet can be "unfrozed" by 2/3rds of the validator set approving reinstatement. Otherwise, frozen funds cannot be recovered.

## Tagging a community wallet

####  How to include your wallet as a community wallet:

WARNING: This is a one-way operation. You're community wallet's funds will be permanently entering the covenant.

The Community Wallets tag can only  be unset only if the wallet is empty of funds.

```
txs --account <community_account_address> wallet --community

# E.g. moonshots program
txs --account 2057BCFB0189B7FD0ABA7244BA271661 wallet --community
```
#### Check if your wallet is included in community wallets:

```
ol --account 00000000000000000000000000000000 query --move-state --move-module Wallet --move-struct CommunityWallets --move-value list
```

## Mac OSX Instructions
This assumes you have no configuration files on your Mac, and you will pass all connection info from the command line.


1. Open Terminal app, and change directory to wherever you want to keep 0L executables. e.g. your Desktop folder.

```
cd ~/Desktop
```

2. Download the file, and make executable in one step.

```
curl -L -o txs-mac  https://github.com/0LNetworkCommunity/libra/releases/download/v4.3.3-rc.2/txs-mac && chmod +x txs-mac
```


3. Submit the transaction from the TXS app 

Replace your community wallet's account in the `<YOUR-ACCOUNT>` section.

For convenience adding here a waypoint and upstream node ip-address to send a transaction to.

NOTE: the ./ is necessary before the app name.


```
./txs-mac --account 2057BCFB0189B7FD0ABA7244BA271661 --waypoint 81100056:39d95372602fd15afa79cb7fe2f338179a55d8b70576c371b2dcdbb4b47aa41e --url http://167.172.248.37:8080 wallet --community
```

You will be prompted for your mnemonic next.

4. Check output

You should see: `Submitted from account: 2057BCFB0189B7FD0ABA7244BA271661 with sequence number: x`