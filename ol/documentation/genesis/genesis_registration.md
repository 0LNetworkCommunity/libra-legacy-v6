# Genesis

A network genesis ceremony has two steps: 

1. registration of interest by participants
2. genesis transaction creation independently offline.

After the ceremony completes, one or more genesis blocks will exist. The canonical chain will be the block that has the most consensus.

# TL;DR
You will need a few files in place before starting with genesis registration. 

- .0L/github_token.txt: the Github authentication token (required). [Link](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token)

- .0L/blocks/block_0.json of a prexisting Delay tower (optional - you can always use the tools to start a new tower)
- .0L/autopay_batch.json: autopay instructions to include in registration profile (optional)

If you don't already have a mnemonic and block_0.json, see instructions to generate are below.

Then using the makefile helpers you can register as such:

```
GITHUB_USER=<your_github_user> make ceremony register
```

## infrastructure

A central github repository will be provided for genesis (GENESIS_REPO). The repository is initialized in an empty state. All Pull Requests to this repository are to be accepted without review. The repository only aims to collect expressions of interest in participating in genesis.

Expression of interest is not a guarantee of being included in the genesis validator set.

For each candidate there will be a CANDIDATE_REPO, which will have the specific registration info of each prospective validator.

Tools are provided to a) fork the GENESIS_REPO b) write registration info ro CANDIDATE_REPO, and c) submit a pull-request of CANDIDATE_REPO to GENESIS_REPO.

The GENESIS_REPO coordinator then has the task of manually approving all PRs.

# Registration

Have these things ready:
- A github token
- A fun statement
- The static IP address of your node.

Assuming you have a github token, and the binaries installed, you should be able to complete registration with three steps:
```
onboard keygen // creates new keys, and initializes a miner.toml file
make register // registers your data to a shared github repo

```

## 0. Generate Github Token

NOTE: Check if you already have one from previous testnet genesis in `~/node_data/github.txt`

https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token

In the step `miner keygen` below you will be asked for this.

## 1.  Install OS dependencies and build project

Clone the project onto your machine. `cd` into the project directory. Checkout the correct tag. Install all dependencies and compile in one step, with the Makefile helper.

```
git clone https://github.com/OLSF/libra.git
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
* You may encounter errors related to Rust, version should be same as: https://github.com/OLSF/libra/blob/OLv4/rust-toolchain.
* You may encounter errors related to memory running out.
* Dependencies such as jq and rq are platform specific. The makefile targets Ubuntu.

## 2 (Optional) Generate new account and keys

Unless you have previously generated an 0L mnemonic (e.g. for experimental network), you should create new keys.

```
onboard keygen
```

You will be prompted to enter the Github token above, IP address of your node, and a (fun) personal statement.

IMMEDIATELY SAVE YOUR MNEMONIC TO A PASSWORD MANAGER


## 3. Initialize configs for node.
This creates the files your validator needs to run 0L tools. By default files will be created in `$HOME/.0L/`.

The following script does several steps:
- OL app configs: defaults to `$HOME/.0L/0L.toml` 
- keys init: creating credentials and configs
- fork: on github this forks the GENESIS_REPO into the CANDIDATE_REPO

```
GITHUB_USER=<your_github_user> make ceremony
```

## 4. Pause and check your work ##
Check all your configs are correct before registering is correct: `make check`. 

```
$ make check

account: 3F48012938129deadbeef
github_token: <secret>
ip: 5.5.5.5
node path: /root/.0L
github_org: OLSF
github_repo: experimental-genesis
env: prod
test mode:
```

If the data looks incorrect, you can doublecheck `$HOME/.0L/0L.toml`, and you may optionally edit those.

## 5. Mine your first proof (or bring first proof from elsewhere)

NOTE: if you already have a puzzle tower, and you are porting it to this chain. Then skip this step, and simply copy the block_0.json into your data path (e.g. ~/.0L/blocks/block_0.json).

```
make genesis-miner
```
This will mine the 0th proof of your tower, which is needed for genesis.

### (Optional) bring previous tower proof 0

If you are using a mnemonic and have previously generated a tower, then you can simply add the block_0.json to .0L/blocks/. You will eventually want to include all proofs of a previous tower.
## 6. Register for genesis

The following script does several steps:
- register: writing configs the CANDIDATE_REPO
- pull: submitting a pull request from CANDIDATE_REPO to GENESIS_REPO

```
GITHUB_USER=<your_github_user> make register
```

After this step check your data at `http://github.com/0LSF/experimental-genesis`

#### Troubleshooting:

-- If you get an HTTP 404 error. You need to have a `~/.0L/github_token.txt` with a valid github token.
