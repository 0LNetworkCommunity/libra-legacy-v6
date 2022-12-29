
# Upgrading the network

There are three upgrade cases on 0L:
1. `Hot Upgrades`to the Move bytecode at 0x1 (stdlib, framework, tx scripts), which include system policies (account creation, rewards, etc.). These are done by decentralized "hot upgrade" [link](./stdlib-hot-upgrade.md).
2. `Node Upgrades` upgrades to the diem-node not including MoveVM, this will be JSON-rpc, networking, consensus etc. but does not change the instructions in the MoveVm.
3. `VM Upgrades` upgrades to the diem-node which include MoveVm: when new language features are introduced or a new type of instruction is created.
4. `Kitchen Sink Upgrades`, with breaking changes which require a data migration, architectural change, or move language changes: this last kind is a halting migration. The network needs to do a coordinated halt, and use the ol/genesis-tools to "fork" by parsing a state backup, and applying writeset changes before restarting.


Non-halting Upgrades (1, 2, 3) must have universal compatibility following these rules:
1. All `diem-node` upgrades must be backwards compatible with the Move stdlib running on the network.
2. All Move bytecode upgrades must be backwards compatible with the `diem-node` code that most validators are running.


Typically most upgrades will be #1 `Hot Upgrades`, meant for policy upgrades. These upgrades do not halt the network (except for error), and happen in a coordinated "flashing" of the system bytecode at round 2 of an epoch. These upgrades must be carefully designed to be backwards compatible with the diem-node software running on the validators. It must also avoid any state migrations, but if there are such data changes, must do it on-the-fly on the Migration Tick (round 3).

#2 `Node Upgrades` are usually unrelated to any Move stdlib, framwork, or policy changes. For example a change in how JSON rpc is serving information. But it may be related to Move changes if for example a new Json RPC enpoint needs to be deployed because there is a new framework module.

#3 `VM Upgrades` happen when there are policy or module features that will be introduced, but the MoveVM needs to be updated before the Move bytecode is deployed. These upgrades are a two step operation, and as such they should be separate releases. E.g. release 1.0.1 makes changes to the diem-node code, all validators must do this on their own. Once the validators are on this new version (or at least 2/3rs), then Release 1.0.2 with Move language changes can be deployed.

#4 `Kitchen Sink Upgrades` are effectively network forks, where the previous network is abandoned. A state backup is created by each validator, and processed with the same tools to create a new genesis which preserve some or all of the previous account state. Diem-node then gets updated and all validators can do the genesis of the new network.

See: [what is the workflow for upgrading a network](./upgrade-workflow.md)

## When things go wrong

Said plainly: the policy of a network update that goes bad is to restore to the last known epoch which will not cause the same issue. For a Hot Upgrade for example: the network will use the state snapshot of the epoch in which an "abort sequence" can reasonably be issued.

Daily snapshots of the epoch are available on the repo: `github.com/0LNetworkCommunity/epoch-archive`