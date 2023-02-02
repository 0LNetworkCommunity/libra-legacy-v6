# Genesis v4 Registration

Have these things ready:
- A github token
- A fun statement
- The IP address of your node.

Assuming you have a github token, and the binaries installed, you should be able to complete registration with three steps:
```
miner keygen // creates new keys, and initializes a miner.toml file
miner genesis // creates your proof of work
make register // registers your data to a shared github repo

```

## 0. Generate Github Token

NOTE: Check if you already have one from previous testnet genesis in `~/node_data/github.txt`

https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token

In the step `miner keygen` below you will be asked for this.

## 1.  Build project

If you have an existing version of the Libra service running, make sure to stop it:
```
sudo service libra-node stop
```

Clone the project onto your machine. Cd into the project directory. Checkout the correct tag. Install all dependencies and compile in one step, with the Makefile helper.

```
git clone https://github.com/0LNetworkCommunity/libra.git
cd <project root>
git checkout v4.0rc8
sudo apt install make // install make (if needed)
make deps // installs ubuntu dependencies and rust. 
          // it's best to exit your terminal and log in again to automatically have Cargo's bin dir added to your path
make bins // builds the necessary binaries for registration
```


#### Troubleshooting
* You may encounter errors related to Rust, version should be same as: https://github.com/0LNetworkCommunity/libra/blob/OLv4/rust-toolchain.
* You may encounter errors related to memory running out.
* Dependencies such as jq and rq are platform specific. The makefile targets Ubuntu.

## 2. Generate new account and keys

You will have new accounts and keys. * Do not reuse previous mnemonic *
This step will:

- generate keys
- save your Github Token to ~/.0L/github_token.txt
- generate miner configs `~/.0L/miner.toml`
- mine the proof_0.json

```
make ceremony
```

You will be prompted to enter the Github token above, IP address of your node, and a (fun) personal statement.

IMMEDIATELY SAVE YOUR MNEMONIC TO A PASSWORD MANAGER


## 3. Pause and check your work ##
Check all your data in miner.toml is correct with `make check`. Otherwise edit it in `$HOME/.0L/miner.toml`
```
$ make check
account: 3F48012938129deadbeef
github_token: your0000000secret
ip: 5.5.5.5
node path: /root/.0L
github_org: 0LNetworkCommunity
github_repo: experimental-genesis
env: prod
test mode:
```


## 4. Register for genesis

```
make register
```

Check your data at github.com/0LSF/experimental-genesis

- Troubleshooting:
-- If you get an HTTP 404 error. You need to have a `~/.0L/github_token.txt` with a valid github token.
