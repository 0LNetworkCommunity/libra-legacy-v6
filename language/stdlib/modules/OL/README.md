# network-move-modules
Minimum viable modules to start and run 0L

## What

These are all Move code artifacts which are to be deployed on the 0L network.

The modules fall into four categories: consensus, economics, information, helpers.

- Consensus: includes algorithms for leader election, consensus, and data availability.
- Economics: covers the topics such as payment for compute, generation of tokens of compute, and subsidies.
- Information: includes statistics of the network, tools for social coordination, providing of off-chain data.
- Helpers: includes a module for onboarding new users.

### Economics
Gas Coin
Gas Table
Node Subsidy
Redeem
Verify
Slow Relay

### Consensus
Node Binding
Node Weight

### Information
Poll
Stats
Wallet Registry
Oracle Receiver

### Helpers
Onboarding

## Testing

Install `Move Runner` , [here's tutorials](https://github.com/ping-pub/move-runner/blob/master/docs/01_quick_start.md)

* Build project
```
> move build
```
* Or run a script.
```
> move run ./src/scripts/oracle_receiver/test_oracle_receiver.mvir
```
