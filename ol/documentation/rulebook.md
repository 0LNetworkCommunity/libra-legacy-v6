# The Rulebook - a brief overview of system policies

As you can see in our write ups elsewhere, we do things a little differently around here: we had no venture investors, there is no premine, no foundation with tokens, and anyone with a laptop can participate and earn coins.

Here's a quick reference to the policies implemented at genesis, with further discussion below.

## Rewards

- Rewards are paid at the end of each "Epoch" daily.

- The majority of the rewards will go to Validator Nodes, you'll need a cloud host to be successful at this (you can't do this with a laptop, and you need to be somewhat technical). Transaction fees are the principal source of rewards, but they can be augmented by Guaranteed Minimum subsidies.

- End Users (who are not Validator nodes), can receive an Identity Subsidy for creating durable identities through Delay Towers. This is a system "mining pool".


## Requirements

- We do not do Proof of Stake, instead preventing Sybil accounts is done through Delay Towers, a sybil resistance technique we invented.

- It uses Proofs of elapsed time which are done by the `tower` app on cloud machines, or the `carpe` desktop all for end users.
 
- Validators are required to build Delay Towers, they must produce 6 delay proofs per day in order to gain admission to the validator set, and also to remain.

- End Users can optionally build Delay Towers to establish a persistent identity (and perhaps later join as a validator), and there is a reward for that. 


## Validator Rewards

- Securing the network is done by a maximum of 100 delegations of "Validator Nodes". This is very valuable work to the network.

- At the start of the network each Validator Node has typically 1 entity or person behind it (a delegation of 1).

- To become a candidate for a Validator Node, all that is required is to run the configuration tool, and to have any existing Validator in a current validator set send an onboarding transaction. (it's not a vote by the validator set to include a new validator.)
While it doesn't take group permission to onboard a new validator, existing validators are rate-limited from creating endless accounts. They can only onboard a new prospective validator every 14 days/epochs.

- The budget for Validator subsidies is "thermostatic", it goes up or down depending on the total number of Validator Nodes doing work successfully. 

  - If the network is about to fail, with only 4 nodes on the network, the budget the network has for security, exactly 8,400,000 coins (the maximum). The 4 nodes share the 8,400,000 coins, 2,100,000 each.

  - On the other extreme, when the network is reaching its technical performance limit, there is no reason to subsidize Validators. At 100 Validator nodes, the total budget is 0, and the 100 validators will share the transaction fees the network produces.

- The validator subsidy only exists in the absence of sufficient transaction fees. It is a Guaranteed Minimum, which is net of transaction fees. So hypothetically if the network has 4 nodes, and hence the security budget is 8,400,000, however the total transaction fees are already above this number (e.g. 10,000,000), there is no need to subsidize the guaranteed minimum, there are no new Coins minted. This prevents unnecessary inflation.

## Validator burn

- Validators spend their credits to be candidates for validation. This is also known as a cost-to-exist. It can also be thought of a pre-paid "slashing" for lack of node liveness.

- The burn will apply to all validators: those successfully validating and those otherwise inactive.

- The validator burn amount is dynamic. To enter a validator set, all validators burn 50% of the previous epoch's subsidy.

- The validator has two options for the burn settings. 1) The validator can elect to have the burn be a pure burn, and the coins are removed from circulation. 2) the validator can have the burn recycled to the Community Wallet Index, which is updated every epoch based on how many donations are flowing to each community wallet.

## Validator Vouch
- Validators do not need permission from the entire validator set to be elegible to validate. They simply need 1 validator to create their account.
- To actually enter a validator set and perform work, there need to be 4 validators from the previous validator set which have vouched for that node. 
- There is a sybil resistance mechanism: each validator needs 4 vouches from separate "families" of accounts, using the Ancestry information (which validator invited the other).

## End Users Mining
- Anyone with a laptop and with an ordinary account (End Users) can receive coins for creating a Delay Tower (proofs of elapsed time), as a basis for durable identity.  We also call this mining. 

- At genesis the protocol provides a subsidy for end users building up their identity.
The reward pool for all miners is exactly the equivalent of one Validator Node's rewards in a given day. This can be thought of as a single system subsidized "mining pool".

- It is a smaller reward compared to Validator Nodes. So, end users are encouraged to run Validator Nodes or pool together to share rewards of validator nodes. Future mining pools are up to the community to design and create.

- While End User account receive relatively smaller amounts of coins for the Identity Subsidy, their accounts have no restrictions on transferability, 

## Transferability

- There are no restrictions on ordinary 0L accounts (end user accounts).

- There are voluntary restrictions people can place on their account: Slow Wallet and Community Wallet tags.

### Slow Wallets

- Early participants of a network may receive generous subsidies, but they are prevented from dumping on less sophisticated users, these are Slow Wallets. All validator node accounts, where a majority of rewards flow to must be Slow Wallets.

- Slow Wallets have 1,000 additional coins unlocked for transfer per epoch (day).

### Community Wallets

- Community wallets are optional settings which allow greater transparency, and also allow owners of the account to help prevent fraud. This designation of wallet is useful for anyone wishing to set up a program for the community benefit.
And it also appoints all addresses in the validator set to be observers of the wallet, and they can slow down transactions by vertoing. With sufficient Vetoes the transaction gets rejected. 

- Community wallets can only make transfers to Slow Wallets.

## Autopay Sponsoring Programs in the Community
- Autopay aims to make it trivially easy for early coin holders to send to development programs within the community. 
At this stage of the network Autopay can only send to wallets tagged CommunityWallets, this is a benefit of being a community wallet.

- At time of writing, there are approx 12 programs that have elected to use Community Wallets. 

# Background

- Like most smart contract platforms, the 0L System requires spending of credits (GAS Coins) for running smart contract computations on the system. These resources are allocated according to specific rules encoded in the core logic of the system.

# Earning Credits
Anyone can earn credits for themselves by performing computational work on the system. No permission is required.

The OL network is a marketplace: of sellers of computation (Validators), and buyers of computation (End Users). The marketplace does not receive a fee. Instead the Validators receive the entirety of the Coins earned for the services performed.

Since the transaction fees may not be sufficient inducement for a seller of computation to join as a Validator, the network has Guaranteed Minimum Transaction Fee, which is subsidized in certain network conditions.

# Guaranteed Minimum Transaction Fee
At times when the network is insecure (with very few validators), the transaction fees flowing through the marketplace may not be attractive enough for a prospective seller of compute power to join.


The Guaranteed Minimum provides a baseline earnings which the Validator can rely on. A network Subsidy makes up the difference between what actual transactions fees were paid, and what is justifiable as a minimum payment. If the Guaranteed Minimum is 10 Coins given a network condition, but the transaction fees amounted to 3 coins, then the network creates new credits amounting to 7 Coins, and thus pays the total of 10 to the validator. Supposing the minimum guaranteed calculated by the algorithm is instead 1 Coin per validator, and the same 3 coins were due from transaction feed, then the network does not create any new Coins, and pays the 3 coins to the validator (in excess of the 1 Coin the network considered a justifiable minimum).

The network's operating software encodes a schedule of the minimal accepted earnings given certain network conditions. The formula is intentionally simple. 

When there are four validators on the network (near failure) the guaranteed minimum is at its highest. When there are 100 validators on the network, (the transaction throughput is exponentially diminished beyond that amount in BFT networks) the network has excess compute power, and the minimum guaranteed is zero Coins. This means that at 100 validators the validators should expect to earn only the transaction fees flowing through the network.
For easy comprehension by prospective validators the schedule is a straight line from 4 to 100 validators.

This Auction aims to ensure the network always pays for security when it needs it, but does not overpay when it is not necessary to do so. It will appear generous at times, and miserly at others, but it should attract the necessary users.

Note, these allocation rules make some assumptions about BFT, that there is a super majority of honest actors and that the most committed validators are included in the validator set (proof of weight from Delay Towers).


# Identity Subsidy
0L's identity subsidysybil resistance mechanism relies on Validators creating Delay Towers (link) which provide a persistent, and non-forgeable identity.

It is important for the network to have as many users as possible creating durable identities, i.e producing Delay Towers. It has a number of benefits: allowing users not yet set up as validators to create identities, allows fullnodes to receive some compensation for providing replication services, and allows the VDF delay mechanism to be tested in a wide variety of hardware configurations so that the difficulty can be periodically adjusted.

While these activities are useful and deserve a meaningful subsidy, they are also low effort and cannot compete with the earnings to Validators (which are critical). This work is also less useful as the network matures, and has higher security (from Validator participation). Also the identity subsidy is highly gameable, and can lead to exploits by sophisticated users. The economics are designed such that those sophisticated users will be incentivized instead to run Validator nodes.

To balance the needs of validators, and exploits possible, miners thus share the equivalent of 1 Validator's Guaranteed Minimum in every epoch.  The identity subsidy is an example of a "mining pool", where the end users share the rewards of one validator node. At genesis the protocol is sponsoring this single mining pool. We expect future mining pools to be an emergent property of the network, as end users seek to receive more rewards, from naturally diminishing rewards to the single system mining pool.


# Transferring Credits
Transfers of credits are unlimited for End User accounts (plain accounts). If an End User is running  a "miner" and creating a tower, those credits are freely transferable.

There two categories of accounts that have opt-in rules for transfers:

## Community Wallets
These are wallets that have elected to have community oversight. If a person or entity would like to increase the credibility of that wallet (e.g to create a program), they may opt to have the transfers be slowed down or ultimately rejected. More details here:

Community wallets typically will receive funds from AutoPay, if anyone wishes to automatically donate a % of their credits.

Sending automatic payments is easy. It is also encouraged socially. On the current network Validator Nodes are voluntarily opting into donating on average more than 50% of their rewards.

## Slow Wallets

Since transferring credits by early users can cause undesirable effects (e.g. creating markets and dumping credits on lesser informed users), the earliest members, and the ones most likely to accumulate large amounts of credits are rate-limited in transferring funds. Transferability also interferes with the ability of the auction for security.

The exception is transferring credits to Community Wallets. Those transfers are unlimited. 

There are accounts that have elected to have restricted transferability. Those are designated Slow Wallets. To join a Validator Set a prospective user must have a Slow Wallet.
