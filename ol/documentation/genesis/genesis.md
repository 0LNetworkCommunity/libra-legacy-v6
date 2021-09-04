# Genesis

A network genesis ceremony has two steps: 

1. registration of interest by participants
2. genesis transaction creation independently offline.

After the ceremony completes, one or more genesis blocks will exist. The canonical chain will be the block that has the most consensus.

## infrastructure

A central github repository will be provided for genesis (GENESIS_REPO). The repository is initialized in an empty state. All Pull Requests to this repository are to be accepted without review. The repository only aims to collect expressions of interest in participating in genesis.

Expression of interest is not a guarantee of being included in the genesis validator set.

For each candidate there will be a CANDIDATE_REPO, which will have the specific registration info of each prospective validator.

Tools are provided to a) fork the GENESIS_REPO b) write registration info ro CANDIDATE_REPO, and c) submit a pull-request of CANDIDATE_REPO to GENESIS_REPO.

The GENESIS_REPO coordinator then has the task of manually approving all PRs.

Read Next: 

1. [genesis registration](./genesis_registration.md])
1. [create genesis block](./genesis_transaction.md])