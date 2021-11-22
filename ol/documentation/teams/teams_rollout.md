# Teams Rollout

Teams is a highly technical upgrade, but also requires actions on behalf of many users before it is safe to use in steady state.

## Phase 1: Rewards
The first step is to get teams to self assemble, and to test the tooling without disruption to network.

Features:
- Teams can be initialized
- Members can opt-into teams
- Team Captain chooses the reward split (minimum 10% to pool)
- Members share in the Validator Rewards (transaction fees and subsidies) 

There are no changes to consensus weights, to maintain continuity of network while Teams are assembling.

Tools
- TXS: Cli tools for sending transactions to create team, join team
- Carpe App: Display teams metadata, user assign self to Team
- JSON RPC: Methods for requests

## Phase 2: Consensus Weight

Consensus weight was not adjusted in phase 1. The weight of the validator node, is the weight of the captain. 

In Phase 2 we adjust the consensus weight so that it is using the weight of the collective Delay Towers of Team Members

## Phase 3: Difficulty Cut Off

The Difficulty of the collective Delay Towers needs to adjust over time. If it were not adjusted it is possible that a validator node could be a Team of 1. The difficulty adjustment makes it infeasible for a single address to have a sufficient delay tower height,

## Phase 4: Difficulty Ratcheting

The Difficulty needs to increase progressively over time, otherwise it will still be possible for a validator to be a team of 1 (or few nodes). Increasing the difficulty over time increases decentralization, and distribution of power and rewards. The Difficulty Ratchet, increases most when the Share to Captain is highest, and stops ratcheting when the rewards to Captain are 0.


