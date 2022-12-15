# 0L

A reference implementation of a neutral replicated state machine. Forked from the Libra/Diem technologies.
# TL;DR

#### Run *Carpe*  our desktop wallet and miner. [Anyone with a laptop can mine and make 0L Gas Coins. Download for Windows and Mac here.](https://github.com/OLSF/carpe)

#### Join a network with a [validator node](ol/documentation/node-ops/validators/validator_onboarding_easy_mode.md), to secure the state machine and earn transaction fees.

# Welcome

We live 24/7 on Discord [join us there](https://discord.gg/AzCp63pggW).

### Weekly community meetings on Discord video channel.

- WEDS 15:00 GMT / 8:00 US PT / Weds 11:00 US ET / 17:00 CET / 23:00 CST / 1:00 AEST (THURS)

# Documentation

Read our documentation [here](ol/documentation/README.md).

Skip straight to [troubleshooting onboarding a node to network.](ol/documentation/node-ops/validators/troubleshoting_onboarding.md)

Contribute to [issues](https://github.com/OLSF/libra/issues).


# 0L's Tech Stack

## What we are doing
0L's technology strategy is to stay as close as possible to the Libra/Diem code base. 

This is because fragmenting the technology products on offer will lead to confusion, and eventually to lack of maintenance and stagnation. This is best for the wider open source ecosystem these tools extend and depend upon. It's also much more efficient on resources. Libra/Diem is a massive project, and simply keeping up to date with the code updates requires a dedicated team. Let alone making additions. Separate from Libra/Diem, The 0L project on its own has contributed tens of thousands of lines of new code.

So the forking strategy is simple in concept: take the unmodified Diem code, and import it into the 0L project and add layers of features. Though it's not that simple in execution because of the nature of the code base. We have to insert many changes in strategic places of the diem-core code, in order for the 0L layers and side-cars  to work. In short, it's not a simple code merge, it takes about two weeks from start to finish to incorporate a new upstream Diem release into 0L.

## What we inherited

The Libra/Diem platform is a spaceship on all accounts. There are engineering breakthroughs throughout the project. The architecture is sensibly designed, and expertly assembled. This is the merit of the Facebook engineering team (who as individuals appear to true believers in the power of these technologies, and one should make no assumptions of their views on corporate strategy).

This is a non-exhaustive summary of the key features of the Diem architecture that are worth paying attention to. We'll take it from the top of the stack to the bottom.

### The Move Language
The smart-contract language of the platform is called Move. It is the most unique breakthrough of the team. This is a language that is designed to be extremely safe in adversarial environments, and for hurried, less experienced developers. It's a very ergonomic language, it's easy to approach it if you have even entry-level coding experience. In terms of safety it incorporates much from the Rust language concepts of "borrowing" memory. The compiler is pretty obnoxious, which is something you want when designing autonomous financial systems. One standout feature of the Move language is built-in Formal Verification. Adjacent to the code you can write specs for invariants which your code must preserve (i.e. this function should never be called by this type of account), and it can be checked during the development and build process. This is unique and powerful.

### Programming model
The execution of the smart contract and scripts has some subtle but important safety features. By design what are referred to in other platforms as smart contracts are in fact "modules" here. Users can publish modules, which any other module or transaction can import. This is important. The transactions are scripts. So compared to Ethereum, much of what happens in a smart contract, can actually be split into long-lived code in a module, and transaction-scripts which can import from the module (and other modules). This decoupling allows for powerful composability and reliability. The developer can evolve the application without necessarily needing to upgrade modules every time a new transaction use case emerges.

Modules can have "resources" bound to them. A resource can be thought of as an object in memory, but with restrictions: they can only be modified by the module that instantiated them, and are restricted in how they get created and transferred. Writing a non-fungible token is basically just instantiating one such structure, and something like a fungible token, can be done in a handful of lines of code.

### Standard Library
This is a minor and easily overlooked architectural decision that is quite powerful. There are many modules that are provided standard by the chain, published to the 0x1 address.  This standard library can be imported into user-defined modules and transaction scripts.

Importantly, much of the logic tangential to consensus (e.g. validator inclusion in validator set) which would ordinarily be done in the protocol layer (i.e in Rust) is actually written in Move and is stored in the application layer. That is, much of the system policies are just state in the chain database. This makes upgrades to many aspects of system management trivial. Notably in Diem's case, this is done by a centralized party (see below how we had to modify this).

### The Move VM
This is a purpose-built bytecode execution environment which isolates the Move Language from the state transition core. The unique feature of the Move VM is that it is easily extensible. It's very easy to include a new instruction to the virtual machine, a "native function". The native functions are written in Rust (which is the language of the entire code-base). Below we reference some of the changes we had to make for real-world use cases.

### Executor
This is another place where the Libra/Diem architecture shines, and still has opportunity to evolve over the long term. The most important feature of the Execution layer is "decoupled execution". This is an important breakthrough. Typically in blockchains all transactions are handled sequentially, there can be no parallelization. With decoupled execution, on the other hand, the executor service checks if a transaction can successfully be processed in parallel to other operations in the mempool. That is: if the transaction could be executed in isolation, and the state changes are atomic.

This places Libra/Diem in a rarified company, the transaction throughput is massively scaled because of this architectural choice, and skillful engineering. It also lays the groundwork for further optimizations possible, and likely coming down the path including the Narwhal DAG mempool management paper Facebook released recently.

### Mempool
The mempool management is different from typical blockchains where transactions within the mempool are propagated (e.g. with gossip protocol) without guarantees of inclusion by other parties. In Libra, a Validator node receiving a transaction has the task of making sure the transaction is included in all other validator's mempools. This change allows voting on proposals to happen faster, and more orderly than other methods.

### Consensus
There's a lot to be said about how consensus happens on blockchains, and we won't attempt to go into any depth here. The LibraBFT consensus is a variation on Hotstuff, itself a variation of classical consensus algorithm pBFT. LibraBFT borrows much from HotStuff leveraging consensus linearity wherein an agreement on a message is reached in a single round. Pipelining of blocks in HotStuff guarantees the finality of the proposed block by the third block following the proposed block.  Effectively block production is only gated by the network speed, the speed in which blocks can be propagated to other nodes.

### Storage
The database which stores the transactions is based on a Sparse Merkle Tree design called Jellyfish. This is an architecture shared by a number of blockchains. It has the benefit of being fast to search, and occupies less storage space (hashes) than a traditional merkle tree. The storage is backed by a RocksDB key-value store. This is a sensible design. There isn't much to remark here, except that there are still opportunities that can be leveraged from this storage architecture to allow for faster syncing of the blockchain.

### What had to Change

The technology we are inheriting is a spaceship. It is also purely infrastructural. There's very little in the way of tooling or smart contracts that are usable in the real world. We assume much of the remainder of the software stack is closed-sourced at Facebook.

But most importantly, the architecture is designed as a private, consortium chain. 

For system administration, there is an omnipresent Diem Association account. Yes, a private key that controls many functions including: Freezing accounts (!), selecting validators for inclusion, paying transaction fees to validators, upgrading the system code. This is obviously a non-starter. So a lot of work had to go into making system policies execute in a permissionless environment.

We also had to add Sybil resistance mechanisms. Typically communities have been choosing Proof-of-Stake as the Sybil resistance method for BFT networks. This is not the route we chose given community growth considerations (as well as regulatory). Elsewhere we've talked in detail about our Delay Towers complement to consensus.

Also there were a number of instructions we wanted to add to the MoveVM so that people could write the types of contract they wanted.

Lastly, there was nothing in Libra/Diem about economics. Meaning, there's nothing in the way of game theory, about how the network is supposed to perform in a permissionless environment. For example: the transactions are metered in USD stablecoins in LIbra/Diem architecture, and paid out by the administrator, and there's no word anywhere about subsidies that may be needed in the absence of meaningful transaction fees. As such there's no consideration to the performance of the validator nodes, all nodes are assumed to be monitored external to the protocol. So we had to rethink a number of things given some of the technical features of the network. The network has novel features, so economic mechanisms we see in other chains would not be drop-in replacements. This was a significant amount of research.


## Our Contributions

This is not an exhaustive summary of the changes. 0L contributed about 40k new lines of code to the code-base, not including changes and code removal. It's a summary of what we think makes 0L a compelling network.

### Removing the Root Account

This is an obvious decision. But the task propagated into many subprojects. The Root Account is pervasive in the codebase. So we had two things to accomplish: (1) replace all its functions with a system 0x0 account (2) Neuter the Root Account where impossible to remove (e.g. in much of the genesis logic).
Decentralized Genesis
Beginning with Genesis, the Libra/Diem architecture provides good tooling on creating genesis blocks, mainly for testing. For an actual network genesis, the tools assume that there is an administrator that is picking the participants and then setting a layout file.

In our changes we made it such that an online Github repo acted as a gathering place for anyone who wished to "register" to be part of a genesis. The owner of the repo, would have as a policy in the genesis ceremony, to accept all pull requests or people adding their genesis validator configurations. In our genesis, all candidates had to submit a Delay Tower "proof zero", an initial proof of work. All registrants are expected to provide their own layout file. This means that several genesis blocks (and hence networks) are possible with the initial genesis. After a few attempts and some social consensus a canonical chain will emerge. This may appear unpredictable, but it has the benefit of being a maximally decentralized genesis ceremony.

### Delay Towers

We've written about this extensively [in ol/documentation/delay_towers/](./ol/documentation/delay_towers/delay_towers_0.md). We needed a way to choose what validators were allowed to operate in a validator set. We did this without Proof of Stake. In short, Delay Towers prove sequential proofs of elapsed time. This can be considered a "heavy" identity, enough for the BFT requirements of there being a durable identity, which is not cheap. This was a significant amount of research and experimentation.

See the long form paper here: https://siasky.net/IAA8rbRgFQLQVnGVWLf5RP0j2MLV7KsxcThqeOlp1pn2_Q

###  Hot Upgrades
While there's a long discussion possible on how network upgrades should be selected (governance), there was no starting place for that conversation, when the system could only be updated by the root account (that we removed).  Read more about the Hot Upgrade procedure here: <link>

We invented an upgrade mechanism for BFT, which does not require hard forks, nor operator intervention at the time of upgrade.

Since all system rules are encoded in the application layer in Diem, the code is quite compact, and a proposed new binary could also be stored in the applications layer. Since that's possible it also opens up the binary to be voted on chain, and the code of the upgrade itself, stored on-chain, such that the upgrade can happen without operator intervention. New binaries for the system can be proposed and voted upon by the validators, and if there are ⅔ of validators choosing the binary (effectively what would be needed for a hard fork), the changes would be synchronously written by all validator nodes at a coordinated time in the blockchain.

### Validator Stats

We had to have on-chain information on the performance of validators. This is critical to designing any economic games around transaction fees and other rewards.

Fortunately in the upstream code, the block prologue is executed in the Move virtual machine, and allows us to add transaction metadata directly into the state machine on every block. So the 0x0 system address contains information on what validators have voted on a given block, and who the proposer was. We can use this for some naive metering within the state machine. It's a sufficient amount to be able to identify which validator nodes are not performing and apply certain sanctions. 

There is a performance penalty for this, and optimizations are possible. Since Move does not offer higher order data structures (hash tables) the data is stored in tables which are not ideal for traversing.

### Onboarding of accounts

In the upstream LibraDiem code, accounts are not created permissionlessly.  It starts with a Diem Association Account, which later add Virtual Asset Service Providers (such an exchange), which later create user accounts. So all of this had to be replaced (the code remains in our code base for reference, but is inactivated).
Instead, there are only two types of accounts on 0L: end-user accounts (the typical account), and Validator Accounts (who own and operate nodes).

End user accounts can be created by anyone that already has an account, as is typical with any account-based blockchain. Like in Ethereum, you can create keys for an account offline, but the account does not exist until someone already on-chain sends you at least one coin.

Similarly for Validator accounts, an account needs to be created by another pre-existing Validator account. There are some game theoretical considerations here which are discussed in the Rulebook. In short, unlike industry practice where the group of validators have to vote on admission of a new member, in 0L any validator can onboard another, but they are rate-limited from onboarded too many. One validator can onboard another every 14 epochs (days).

Tangentially, but relevant. Any accounts can optionally create different policies on them called Slow Wallets or Community Wallets. This is described in the rule book.

### MoveVM changes

We've made some additions to the MoveVM that were necessary for us to implement Delay towers and so that users could write useful financial apps.

- Decimal - we needed a number type that could be used for financial math that could lead into polynomial curves etc. So we added the Rust Decimal library and some initial APIs and their corresponding native instructions.

- VDF verification - to verify the Delay Towers proofs we added the ChiaVDF verifier to the VM. The prover is not needed in the VM. The VDF prover can accept a number of parameters (not hardcoded for 0L's use case). So application builders could leverage it in their own games.

### Auto Pay
The ability to create payments in the future, and regular payments as a percent of account balance or of new income. This was a feature requested early by the community. It powers a number of use cases important at the start of a network.
Namely it is useful for anyone that wants to run a community program. In this case an entity or a person is seeking to accomplish a goal or a project, and is asking for donations. Autopay allows for set-it-and-forget-it donations to programs. Most people in 0L use this to send a portion of their mining rewards to programs automatically.

Autopay can be programmed for:

- Sending a single payment in the future.
- Sending recurring flat fee payments every epoch (day).
- Sending a percent of the balance every epoch.
- Sending a percent of NEW balance every epoch (e.g. mining rewards).

Future types of autopay are possible. Autopay has a simple First In First Out Queue, to handle planned payments that go above the current balance or above current transfer restrictions.
CLI
Lots of tooling had to be written to successfully manage nodes and interact with accounts. Much of the tooling is in early stages given the ground that had to be covered given the complexity of the system.

### Web Monitor
a web interface for a Nodes Operator to see reports on the node.
Basic chain info: Epoch number, waypoint.
Includes Node Health, and account info
Performance reports on all validators in set.
JSON endpoints to query data, like the node's account profile, epoch.
Not to be confused with a fullnode json-rpc

### Terminal Explorer
Explorer - a terminal block explorer. This one is mostly for fun. This is a terminal interface for a block explorer to check some vitals of your fullnode or validator node.

### TXS
We needed a library for sending different types of transactions. So that it could be imported in other tools. TXS also include a CLI utility to send commands from terminal.

### Onboard
This is a library and CLI tool for creating packaging all of the necessary files for a new fullnode or validator account to join the network. Because 0L changed the account creation permissions and logic, there had to be purpose built tooling for it.

### Restore
Diem has one significant limitation which is a slower sync time. A fullnode joining an already mature network, will take a long period of time to catch up to consensus. So we had to create tools and a bit of infrastructure to leverage some of Diem's existing backup and restore tools.
At every new epoch there is a snapshot taken of the chain, and submitted to a Github repository. Multiple such repositories can exist. When a new validator is joining the network they must begin as fullnodes. The ol restore tool will fetch a snapshot from repository, check it, and deploy it so that the fullnode can begin syncing from an advanced epoch (i.e. waypoint).

### Carpe
Last but not least. We wanted all users to be able to participate meaningfully, and on equal footing with a protocol. Since there is a subsidy for creating heavy identities on the chain (Delay Tower), we needed to make this accessible to a diverse audience. The Carpe app, combines a Wallet with a Light Miner, which allows anyone with a desktop whether Windows, Ubuntu, or Mac, to "mine" coins for themselves.
