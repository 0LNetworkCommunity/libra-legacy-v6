# Teams Rollout

Teams is a highly technical upgrade, but also requires actions on behalf of many users before it is safe to use in steady state.
## Phase 1: Rewards
The first step is to get teams to self-assemble, and to test the tooling without disruption to the network.

Features:
- Any validatdor ("Team Captain") can start a Team
- Carpe users ("Members") can opt-into joining a team
- Team Captain chooses the reward split (minimum 10% to pool)
- Members share in the Validator Rewards (transaction fees and subsidies) 

NOTE: there in Phase 1 there are no changes to consensus weights, to maintain continuity of network while Teams are assembling.

Tools
- TXS: Cli tools for sending transactions to create team, join team
- Carpe App: Display teams metadata, user assign self to Team
- JSON RPC: Methods for requests

## Phase 2: Consensus Weight

Consensus weight was not adjusted in Phase 1. This means the Tower height of the validator node (team captain), was still the weight of the node for Consensus purposes.

In Phase 2 we adjust the consensus weight so that it is using the weight of the collective Delay Towers of Team Members

Phase 2 implements a threshold "collective height") which Teams must achieve to enter consensus.

The Difficulty of the collective Delay Towers will adjust over time.

If it were not adjusted it is possible that a validator node could be a Team of one member. The difficulty adjustment makes it infeasible for a single address to have a sufficient delay tower height,

The Difficulty Ratchet is an algorithic policy. The policy may change over time. The initial settings of the algorithm is implemented in Phase 2. [As described in About Teams](./about_teams.md) the (first experimental) ratchet increases most when the Share to Captain is highest, and stops ratcheting when the rewards to Captain are 0.

Changes:
- Proof of Weight needs to be adjusted.
- Qualification to enter a consensus round is based on overcoming the collective tower height threshold.
- The Ratchet algorithm is implemented.
