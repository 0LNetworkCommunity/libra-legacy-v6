# Teams

Teams is part of a policy goal of having a plural and distributed group of people be able to select the most appropriate validators to operate and steward the network.

The idea of teams is to scale up the forming of social groups. This is relevant in several domains:
- consensus
- labor
- governance

The outcome of a successful Teams implementation is that validator nodes in the network become Decentralized Autonomous Organizations (DAOs). 

For consensus purposes, Teams mean that end user desktop miners (using Carpe), are now included in the security model, with the pooling of delay tower heights. They also share in the rewards of the validator node (operated by a Captain). More below.

Teams would be rolled out in phases. [See the rollout plan](./teams_rollout.md)
## Goals

- Opt-in and permissionlesss
Teams are opt-in, self-assembled groups. People can move freely between teams. What team you are on signals a number of things, but importantly it shows support for a "team captain" and their activities: do they successfully operate nodes, do they participate in network governance, do they provide work and input actively to a network. 


- Market dynamics
The network will not enforce a percentage share between Captains and Members. This is a market, and we'll let the market decide what is appropriate.

- Bias to decentralization
The network will however bias toward decentralization, and ratchet-up the threshold for a collective tower height that a validator node is required to have to enter consensus.

- Don't penalize individuals
Proof of Work sybil resistance schemes, have known sybil attack scenarios. There is always a race between the individual miners (Human teams) and organizations with access to cheap computation (Synthetic teams). Usually well resourced organizations win. A design goal of Teams is to allow individual miners to join without penalty, but also slow down the rate a synthetic team can gain rewards. This is a problem that is not solvable, but workable within constraints. VDF proofs and delay have some favorable qualities, but does not solve all issues. The Teams design makes the race between Human and Synthetic teams explicit. With that algorithm will evolve as the game plays out.

## Definitions

Team: a list of addresses. These addresses map to individuals, institutions, or DAO. The address may be a standard account or a multisig.

Members: one address. This is any person or entity that opts-in to participating in a team. Members agree to the rules established by the Captain (e.g. the Operator Reward, below). Members can switch to another Team at any time. Members cannot be blocked from joining a Team. To prevent attacks, a Member's account must be of type "Slow Wallet".

Captain: one address. This is the address that is responsible for managing the Team. It is also the address of a Validator node which the Team uses to proxy consensus votes (more below). Captains cannot exclude Members.

Account Weight: an integer. This is the voting power of any address in the team. Initially this is done by Tower height (using 0L's Delay Tower sybil resistance technology)

Team Weight: an integer. This is the collective weight of the Team, once summed the Account Weight of all team members. This is the weight used in consensus by the validator nodes. The Team Captain's node inherits the weight of all the team member's Account Weights, this is the consensus voting power.

Captain Reward: an integer. This is the percentage fee that a Captain takes for the work they are doing. The operator reward is set by the Captain. Members do not explicitly choose an OPerator Reward, but they "vote with their feet", they can change to another Team if they think the reward is not correct. Some will choose to go to teams where the individual Member reward is highest, others switch to a team where an active and engaged Captain is deserving of a higher reward, or to Teams where Captains create other games besides sharing validator rewards.

## Consensus
BFT type consesus has an upper-bound on number of physical nodes on the network. Between propagating transaction to mempool, and subsequently blocks, and state synchronization, a BFT networks performance begins to drop off dramatically after a count of 100 nodes in the network. A "delegation" scheme is required for BFT networks if they want to have credible neutrality (censorship resistance, political decentralization).

a) Delegation in BFT always exists. Its preferable to make it explicit and  in-band, otherwise it becomes an opaque game.
b) You can choose between traditional proof of stake (which we don't think works), or something native to 0L's invention of permissionless Delay Towers.
c) There's an opportunity to rethink proof of stake for scale and plural participation. That's what the Teams experiment begins to do.

The Teams implementation facilitates "delegation" of consensus votes in BFT consensus. As in many proof-of-stake networks a single phisical consensus node ("validator"), may have many "delegators" which assign their voting power (stake) to an operator. While the security model is different, the economocs resemble "mining pools" on proof-of-work blockchains, where variable reward rates can be shared amongst many in order to smooth the economic rewards per user.

A Member once they have joined a Team, will be assigning their Account Weight to the Team. The account weight is an algorithm based on the height of an active Delay Tower [link](../delay_towers/delay_towers_0.md).

The tower must:
- be active, meaning it's above the minimum threshold per epoch. Initially 7 proofs or more need to be produced per epoch.
- be of certain minimum height, meaning it cannot have just been created. Initially towers of 7 days will be counted.

No double dipping. When a Member chooses to receive Team rewards, they do not receive the Identity Subsidy from the system pool for identity.
# Labor and other rewards
Teams also allow for other rewards to potentially be shared. 0L is not explicit about this. But it is possible for a Team to pool effort together in order to share in a bounty, or other reward.

- There is a transaction script: `pay_to_team`: which send a payment to all the team members and does the work of fractionally distributing the rewards according to NodeWeight.

# Governance
0L validator nodes are also the logical units which proxy votes for upgrading the system policies. System policies are Move Language code known as the `stdlib`. 0L has a decentralized upgrade technology, which allows for any validator to propose an upgrade to the `stdlib` and if 2/3rs of the validator set concur with subsequent votes, the upgrade happens within 2 epochs [link](../network-upgrades/stdlib_hot_upgrade.md)

The vote weight for upgrade vote counting is the same as consensus voting, i.e., the Team Weight will count toward upgrade votes.

## Proxying of votes
Only the Team Captain's vote is counted. Here's the thinking:

The core function of "delegation" is that you are proxying your votes to someone with better knowledge and more active participation.  The assumption here is that getting quorum on upgrades is difficult when you have plebiscite votes. And sometimes upgrades need to happen fast (like security upgrades). 

If you disagree about how your team captain votes you should switch teams, leave the team, write your congressmen, or start another team. These are low cost and low friction actions.

# Difficulty Ratchet

Difficulty adjustments of Delay Towers can either create centralization, or decentralization. To maximize credible neutrality of the platform, the difficulty adjustment should bias towards each Team (validator position) having thousands of Members. If there was no "difficulty adjustment" to the collective Tower Height, it would be possible for a single entity to have a Team of one, and not share any rewards. On the other extreme the difficulty adjustment may be too difficult, and very few Teams pass the threshold, and thus the network has fewer nodes, and less security (and less credible neutrality).

The Difficulty Ratchet, monotonically increases the difficulty to keep pace with the height of delay towers being built accross the network.

The ratcheting feature will be rolled out in phases.

The first "ratchet" is to increase the difficulty above the level which a single Tower (a single entity) could produce. This forces the hand of Validators needed to enable Teams on their validators.

The network will not enforce a percentage share between Captains and Members. This is a market, and we'll let the market decide what is appropriate.

The subsequent automated ratcheting, will nominally keep pace with tower creation but also bias towards more towers participating in a single validator. If all Captains in the network are on average able to keep a high share of the pool (e.g 90%) with few "members", then this is a sign that the difficulty needs to increase to bias toward more towers. Thus the ratchet increases most when the average share of the pool to Members is low. 

# Account Transactions

- Create Team
- Join Team
- Pay to team: pay_to_team
