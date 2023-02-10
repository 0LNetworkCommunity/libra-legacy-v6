# Genesis Registration

A network genesis ceremony has two steps: 

1. registration of interest by participants
2. genesis transaction creation independently offline.

After the ceremony completes, one or more genesis blocks will exist. The canonical chain will be the block that has the most consensus.

# TL;DR
You will need a few files in place before starting with genesis registration. 

- .0L/github_token.txt: the Github authentication token (required). [Link](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token)

- .0L/vdf_proofs/proof_0.json of a prexisting Delay tower (optional - you can always use the tools to start a new tower)
- .0L/autopay_batch.json: autopay instructions to include in registration profile (optional)

If you don't already have a mnemonic and proof_0.json, see instructions to generate are below.

Then using the makefile helpers you can register as such:

```
# fork the genesis registration repo
GITHUB_USER=<your_github_user> make gen-fork-repo

# mine your first proof, and config your environment.
GITHUB_USER=<your_github_user> make gen-onboard

# submit registration information to your branch
GITHUB_USER=<your_github_user> make gen-register

# make a pull request to main branch.
GITHUB_USER=<your_github_user> make gen-make-pull
```

If you hit any errors in your config, but don't want to mine a new proof do this:
```
GITHUB_USER=<your_github_user> make gen-reset
```

## infrastructure

A central github repository will be provided for genesis (GENESIS_REPO). The repository is initialized in an empty state. All Pull Requests to this repository are to be accepted without review. The repository only aims to collect expressions of interest in participating in genesis.

Expression of interest is not a guarantee of being included in the genesis validator set.

For each candidate there will be a CANDIDATE_REPO, which will have the specific registration info of each prospective validator.

Tools are provided to a) fork the GENESIS_REPO b) write registration info ro CANDIDATE_REPO, and c) submit a pull-request of CANDIDATE_REPO to GENESIS_REPO.

The GENESIS_REPO coordinator then has the task of manually approving all PRs.

# Warning - Don't lose your old Tower

If you have a Delay Tower on a node: you should back up the proofs. You will want these for your identity on a new chain.

```
tar -zcvf my-tower.tar.gz ~/.0L/blocks/
```

# Start from a clean slate.
You'll want a fresh ~/.0L/ folder with only your old blocks .0L/blocks, github_token.txt, and your autopay_batch.json.

Make sure you have all your ~/.0L/files backed up.

In your ~/.0L/ folder you will want to see:
- /blocks/ (your legacy proofs from another tower)
- /github_token.txt
- /autopay_batch.json

There are some makefiles which can help 1) backup the files, 2) wipe ~/.0L and 3) sync your blocks and token back. You will be prompted for Y/N at each step.
```
make backup
# if you your backup is called /0L_backup/, then you can restore with:
make danger-restore
```
# Registration

Have these things ready:
- A github token
- A fun statement
- The static IP address of your node.

## 0. Generate Github Token

NOTE: Check if you already have one from previous testnet genesis in `~/node_data/github.txt`

https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token

In the step `miner keygen` below you will be asked for this.

## 1.  Install OS dependencies and build project

Clone the project onto your machine. `cd` into the project directory. Checkout the correct tag. Install all dependencies and compile in one step, with the Makefile helper.


```
git clone https://github.com/0LNetworkCommunity/libra.git
cd <project root>
git checkout <version> -f

// (optional) install `make`
sudo apt install make 

// installs ubuntu dependencies and rust. 
make deps 
// it's best to exit your terminal and log in again to automatically have Cargo's bin dir added to your path

// builds the necessary binaries for registration (and node operations) and installs them
make bins install 
```


#### Troubleshooting
* You may encounter errors related to Rust, version should be same as: https://github.com/0LNetworkCommunity/libra/blob/OLv4/rust-toolchain.
* You may encounter errors related to memory running out.
* Dependencies such as jq and rq are platform specific. The makefile targets Ubuntu.
* `toml` may not be installed, you can install with `cargo install toml-cli`

## 2. (Optional) Generate new account and keys

Unless you have previously generated an 0L mnemonic (e.g. for experimental network), you should create new keys.

```
onboard keygen
```

You will be prompted to enter the Github token above, IP address of your node, and a (fun) personal statement.

IMMEDIATELY SAVE YOUR MNEMONIC TO A PASSWORD MANAGER


## 3. Initialize configs for node.

There's a specific "onboarding" flow for genesis.

This creates the files your validator needs to run 0L tools. By default files will be created in `$HOME/.0L/`.

The following script does several steps:
- Mine's the first proof. Expect this to take 30mins.
- OL app configs: defaults to `$HOME/.0L/0L.toml` 
- keys init: creating credentials and configs
- fork: on github this forks the GENESIS_REPO into the CANDIDATE_REPO

```
GITHUB_USER=<your_github_user> make gen-onboard

# the equivalent command is:
cargo run -p onboard --release -- val --genesis-ceremony
```

If you hit any errors in your config, but don't want to mine a new proof do this:
```
GITHUB_USER=<your_github_user> make gen-reset

# the equivalent command is:
cargo run -p onboard --release -- val --genesis-ceremony --skip-mining
```
## 4. Pause and check your work ##
Check all your configs are correct before registering is correct: `make check`. 

```
$ make check

account: 3F48012938129deadbeef
github_token: <secret>
ip: 5.5.5.5
node path: /root/.0L
github_org: 0LNetworkCommunity
github_repo: genesis-registration
env: prod
test mode:
```

If the data looks incorrect, you can doublecheck `$HOME/.0L/0L.toml`, and you may optionally edit those.


### (Optional) link your previous tower to new genesis proof.

The onboard tool will scan the files in `.0L/vdf_proofs/` for legacy files with the format block_x.json. 
It will then take the highest block, and hash the proof of it. And interactively, the onboard tool will ask if you want to include that information in your genesis block.
## 6. Register for genesis

The following script does several steps:
- register: writing configs the CANDIDATE_REPO
- pull: submitting a pull request from CANDIDATE_REPO to GENESIS_REPO

```
GITHUB_USER=<your_github_user> make gen-register
```

## 6. Submit the pull request of the changes

Until now all the changes were made on your fork of the genesis registration. To make a pull request to the main branch do:

```
GITHUB_USER=<your_github_user> make gen-make-pull
```

After this step check your data at `http://github.com/0LSF/genesis-registration`

#### Troubleshooting:

-- If you get an HTTP 404 error. You need to have a `~/.0L/github_token.txt` with a valid github token.
