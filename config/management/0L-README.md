TODO
1. Create Set Layout File (as association)
2. Create a mnemonic - ok
3. create a proof - ok
4. Initialize with mnemonic. Stores private keys to disk (json). - ok

5. Add proof data from mining to key_store.json - ok
6. Add operator key to remote storage. (and collect account address)
7. generate node.config file_name

5. Build genesis.
7. Node.config.toml needs output to json file.


# POW mining
Add the mining details to the local key_store.json.
cargo run mining --path-to-genesis-pow ./test_fixtures/miner_0/block_0.json --backend 'backend=disk;path=./bobs_stuff/key_store.json;namespace=bob'
# Operator key to remote storages

cargo run operator-key --local 'backend=disk;path=./bobs_stuff/key_store.json;namespace=bob' --remote 'backend=github;owner=OLSF;repository=test;token=./bobs_stuff/github_token;namespace=bob_shared'
## Get public key from response
9336f9ff1d9ea89f6872517b1919fea147693aa1c2ccb3e32c2d9fe224faf1fc
## creat address from derived.
402e9aaf54ca8c39bab641b0c9829070

# Generate Node config
cargo run validator-config --owner-address 402e9aaf54ca8c39bab641b0c9829070 --validator-address "/ip4/0.0.0.0/tcp/6180" --fullnode-address "/ip4/0.0.0.0/tcp/6180" --local 'backend=disk;path=./bobs_stuff/key_store.json;namespace=bob' --remote 'backend=github;owner=OLSF;repository=test;token=./bobs_stuff/github_token;namespace=bob_shared'

# Libra Config Manager

The Libra Config Manager provides a tool for end-to-end management of the Libra
blockchain from genesis to maintenance. The functionality of the tool is
dictated by the organization of nodes within the system:

* An association account that maintains the set of validator owners and validator
  operators.
* Validator owners (OW) that have accounts on the blockchain. These accounts contain
  a validator configuration and specify a validator operator.
* Validator operators (OP) that have accounts on the blockchain. These
  accounts have the ability to manipulate validator configuration.

## Generating Genesis

The process for starting organization of the planned and current functionality includes:

* Initialization ceremony
  * Association sets up a secure-backend for data uploads, `association drive`.
    The association then distributes credentials for each node owner and
    validator operator.
  * The association generates its `association key` and shares the public key
    to the association drive.
  * Each OW will generate a private `owner key` and share the public key to the
    association drive.
  * Each OP will generate a private `operator key` and share the public key to
    the association drive.
* Validator initialization
  * Each OW will select a OP and submit this as a transaction signed by their
    `owner key` and uploads it to the association drive..
  * For each validator supported by a OP, the OP will generate network and
    consensus keys as well as network addresses for full node and validator
    endpoints. The OP will generate a transaction containing this data signed
    by their `operator key` and uploads it to the association drive.
* Genesis
  * Each OP will download the accumulated data to produce a genesis.blob
  * Association will download the accumulated data to produce both a
    genesis.blob and genesis waypoint.
* Starting
  * Association publishes the data associated with genesis, the genesis.blob,
    and the genesis waypoint.
  * Each OP downloads the genesis waypoint provided by the association and
    inserts it into their Libra instance(s) and starts them.
  * Upon a quorum of validators coming online, the blockchain will begin
    processing transactions.

Notes:
* This describes a process for instantiating organization that has yet to be
  specified but extends from the current state of the Libra Testnet.
* The implementation as described has yet to be fully implemented in Move,
  hence, this tool maps to the current state.

## Requirements

Each individual instance, OW or OP, should have access to a secure storage
solution. Those leveraging Libra Secure Storage can directly use this tool,
those that do not will need to provide their own tooling.

## The Tools

While this is compiled as a single binary it provides several different facilities:

* A means for bootstrapping an identity mapped to a local configuration file.
  The identities are used to interact with local and remote secure storages.
* Retrieving and submitting validator operator, validator operator, and validator
  configuration -- this is from a local secure storage to a remote secure
  storage -- leveraging the identity tool.
* Converting a genesis configuration and a secure storage into a genesis.blob /
  genesis waypoint.

## The Process

The end-to-end process assumes that each participant has their own Vault
solution and a token stored locally on their disk in a file accessible to the
management tool.

In addition, the association will provide a GitHub repository (and owner) along
with a distinct namespace for each participant. GitHub namespaces equate to
directories within the repository.

Each participant must retrieve an appropriate GitHub
[token](https://github.com/settings/tokens) for their account that allows
access to the `repo` scope. This token must be stored locally on their disk in
a file accessible to the management tool.

Finally, each participant should initialize their respective key:
`association`, `owner`, or `operator` in a secure storage solution. How this is
done is outside the scope of this document.

The remainder of this section specifies distinct behaviors for each role.

### The Association

* The association will publish a layout containing the distinct names and roles
  of the participants, this is placed into a common namespace:
```
cargo run -p libra-management -- \
    set-layout \
    --path PATH_TO_LAYOUT \
    --backend 'backend=github;owner=OWNER;repository=REPOSITORY;token=PATH_TO_GITHUB_TOKEN;namespace=common'
```

cargo run set-layout --backend 'backend=github;owner=OLSF;repository=test;token=./bobs_stuff/github_token;namespace=common' --path ./test_fixtures/set_layout.toml

https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

3a5480b9ef196045b3ba6fbe3e3a7239f82f6e7b

* Each Member of the Association will upload their key to GitHub:
```
cargo run -p libra-management -- \
    association-key \
    --local 'backend=vault;server=URL;token=PATH_TO_VAULT_TOKEN' \
    --remote 'backend=github;owner=OWNER;repository=REPOSITORY;token=PATH_TO_GITHUB_TOKEN;namespace=NAME'
```

The layout is a toml configuration file of the following format:
```
[operator] = ["alice", "bob"]
[owner] = ["carol", "dave"]
[association] = ["erin"]
```
where each field maps to a role as described in this document.

### Validator Owners

* Each Validator Owner member will upload their key to GitHub:
```
cargo run -p libra-management -- \
    owner-key \
    --local 'backend=vault;server=URL;token=PATH_TO_VAULT_TOKEN' \
    --remote 'backend=github;owner=OWNER;repository=REPOSITORY;token=PATH_TO_GITHUB_TOKEN;namespace=NAME'
```

### Validator Operators

* Each Validator Operator member will upload their key to GitHub:
```
cargo run -p libra-management -- \
    operator-key \
    --local 'backend=vault;server=URL;token=PATH_TO_VAULT_TOKEN' \
    --remote 'backend=github;owner=OWNER;repository=REPOSITORY;token=PATH_TO_GITHUB_TOKEN;namespace=NAME'
```
* For each, validator managed by an operator, the operator will upload a signed
  validator-config. The namespace in GitHub correlates to the owner namespace
  (note: the owner address is irrelevant in this run):
```
cargo run -p libra-management -- \
    validator-config \
    --owner-address 00000000000000000000000000000000 \
    --validator-address '/dns/DNS/tcp/PORT' \
    --fullnode-address '/dns/DNS/tcp/PORT' \
    --local 'backend=vault;server=URL;token=PATH_TO_VAULT_TOKEN' \
    --remote 'backend=github;owner=OWNER;repository=REPOSITORY;token=PATH_TO_GITHUB_TOKEN;namespace=NAME'
```
* Upon receiving signal from the association, validator operators can now build
  genesis, this requires no namespace:
```
cargo run -p libra-management -- \
    genesis \
    --path PATH_TO_GENESIS \
    --backend 'backend=github;owner=OWNER;repository=REPOSITORY;token=PATH_TO_GITHUB_TOKEN'
```
* Upon receiving signal from the association, validator operators can now build
  a genesis waypoint, this requires no namespace.  In this command, the remote
  store is the destination where the waypoint will be saved. It is derived from
  data in the local backend:
```
cargo run -p libra-management -- \
    create-waypoint \
    --local 'backend=github;owner=OWNER;repository=REPOSITORY;token=PATH_TO_GITHUB_TOKEN' \
    --remote 'backend=vault;server=URL;token=PATH_TO_VAULT_TOKEN'
```
* Perform a verify that ensures the local store maps to Genesis and Genesis maps
  to the waypoint. (TBD)

### Important Notes

* A namespace in Vault is represented as a subdirectory for secrets and a
  prefix followed by `__` for transit, e.g., `namespace__`.
* A namespace in GitHub is represented by a subdirectory
* The GitHub owner repository translate into
  `https://github.org/OWNER/REPOSITORY`
* The owner-address is intentionally set as all 0s as it is unused at this
  point in time.
