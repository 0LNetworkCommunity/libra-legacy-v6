# Validator Setup
## Requirements 
- TWO unix hosts, one for Validator Node, and one for the Private Fullnode ("VFN").
0L code targets Ubuntu 20.4
- Recommended specs: 
  - Validator: 250G harddrive, 8 core CPU, 16G RaM
  - VFN: 100G storage, 8 core CPU, 16G RAM
- Separate static IP addresses for the machines, or appropriate DNS mapping.


## Firewall

Validator:
You need to open ports 6179, 6180, 3030

- 6180 should be open on all interfacess `0.0.0.0/0`, it's for consensus and uses noise encryption.
- 6179 is for the private validator fullnode network ("VFN"), the firewall should only allow the IP of the fullnode to access this port.
- 3030 is for your `web-monitor` dashboard, so could just be your home IP if it's fixed.

VFN:
Note: this node does not serve transactions, and does not participate in consensus, it relays data out of the validator node, and transactions into the validator.

You will need port 6178, and 6179 open 
- 6179 is for the private validator fullnode network ("VFN"), it should only ollow traffic from the Validator node IP address above.
- 6178 is for the the PUBLIC fullnode network. This is how the public nodes that will be serving JSON-RPC on the network will receive data and submit transactions to the network.
## High-level steps
1. Set up a host - Install binaries.
2. Generate a public mining/validator key and associated mneumonic.
2.1 Generate and share you `account.json` file with someone who has gas and can execute the onboarding transaction for you.

3. Get the latest snapshot state of the network by running `ol restore`. 
4. Start your node in *fullnode* mode. 
4.1. Allow your validator in the *fullnode* mode to sync up with the network. Depending on how old the snapshot obtained from `ol restore` is
   may take a while (1 hr or more). To check the state of the sync run `db-backup one-shot query node-state`.
5. Start the tower app which will produce and submit VDF proofs to the chain. 
   **note** if your node is not fully synced and if you have not been onboarded yet, you will see errors from the tower app 
   until your node has caught up to the current state and you have been onboarded.
6. Create VFN configs, and deploy the VFN.
6.. Check and update your on-chain configuration
8. Restart your node in *validator* mode. You will join in the next epoch if you have been on boarded by an active validator.
9. View [ol explorer](https://0lexplorer.io/) to see the state of the network, you should see your validators public key in the list of validators. 

## 1. Set up a host

These instructions target Ubuntu.

1.1. Set up an Ubuntu host with `ssh` access, e.g. in a cloud service provider. 

1.2.  Associate a static IP  with your host, this will be tied to you account. This address will be shared on the chain, so that other nodes will be able to find you through the peer discovery mechanism.

1.3. 0L binaries should be run in a linux user that has very narrow permissions. Before you can create binaries you'll need some tools installed blobally by `sudo` and likely in root.
A helpful script to install dependencies exists here: github.com/OLSF/libra/main/ol/util/setup.sh 

You can run it with a curl bash:
```
curl -sL https://raw.githubusercontent.com/OLSF/libra/main/ol/util/setup.sh | bash
```

1.4. You'll want to use `tmux` to persist the terminal session for build, as well as for running the nodes and tower app. Also this setup requires `git` and `make`, which might be installed already on your host. If not, perform the following steps now:

```
sudo apt install -y git vim zip unzip jq build-essential cmake clang llvm libgmp-dev secure-delete pkg-config libssl-dev lld

```

1.5. Create the linux user that will run the 0L services.

We will create a user called `node` which has no password (can only be accessed initially by sudo).
```
sudo useradd node -m -s /bin/bash
```

You can then access that account via `sudo su node`. Or setup ssh keys under `/home/node/.ssh/authorized_keys`.

1.6. Install Rust on the `node` user
```
sudo su node

# you are now in the node user
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y

# restart your bash instance to pickup the cargo paths
. ~/.bashrc

# install some command-line tools
cargo install toml-cli
```

### Create Binaries
It is recommended to perform the steps from 1.4 onwards inside tmux. Short tmux intruction:

```
# start a new tmux session
tmux

# to rejoin the session
tmux a
```
to detach from the `tmux` session use key stroke: `Ctrl-b` then `d`

1.6. Clone this repo: 

`git clone https://github.com/OLSF/libra.git`


For more details: (../devs/OS_dependencies.md)

1.7. Build the source and install binaries:
This takes a while, run inside `tmux` to avoid your session gets disconnected 

```
cd </path/to/libra-source/> 
make bins install
```

1.7. Fetch the web server files
```
ol serve --update

# alternatively
make web-files
```
## 2. Generate account keys

Before you start: have the static IP address you wish to associate with your validator, and a fun personal statement 
to place in your first proof.

2.1. Generate new keys and account: `onboard keygen`. Run as many times as you like, and choose a mnemonic. 
**Mnemonic and keys are not saved anywhere, write them down now**. 

2.2. Run the validator onboarding wizard inside a `tmux` session, and answer questions: 

```
# start wizard with template
onboard val -u http://<ip-address-of-the-one-who-onboards-you>:3030

# note, this person needs to be already running a validator, ask in the discord for their ip address. If you navigate to <ip-address>:3030, you should be able to see their validator node's health.

OR

# start wizard without template, note: assumes an autopay_batch.json is in the project root.
onboard val
```

2.3. Send the generated `~/.0L/account.json` to someone that has GAS (the one who wants to onboard you) and can execute the account creation transaction for you.

**If you are onboaring someone and receive the `account.json` [see](#onboarder-instructions)**  

2.4. Backup your files: `cp -r ~/.0L/* ~/.0L/init-backup/`

## 3. Fast forward to the most recent state snapshot 

Speed up the sync of your ledger by restoring a backup before starting a fullnode (next step). 
The following command will fetch the latest epoch archive, usually from within the last 24h.

```
ol restore
```

## 4. Start the validator in `fullnode` mode:

4.1 To enable the node to run after you detach from your terminal session, start within a 
`tmux` session.

**note**: temporarily: as of v4.2.8 you'll need to increase your host's file descriptors. Fix is in the works. For now:
run this before starting your `tmux` session.
```
# increase file descriptors
ulimit -n 100000
# check that they have been increased
ulimit -n
100000
```
or edit the `/etc/security/limits.conf` file to make this change persistent across sessions:  
```
sudo vim /etc/security/limits.conf`
```
append to the end of the `limits.conf`. replace `yourusername` with the output from `whoami`.
``` 
yourusername soft    nproc          100000 
yourusername soft    nproc          100000
yourusername hard    nproc          100000
yourusername soft    nofile         100000
```
start your fullnode in a `tmux` session.

```
tmux new -s fullnode

# verify your file handlers have been increased
ulimit -n
100000
```

inside the `tmux` session start the node in fullnode mode. 
```
# create log directory 
mkdir ~/.0L/logs

#start node 
diem-node --config ~/.0L/fullnode.node.yaml  >> ~/.0L/logs/node.log 2>&1
```

4.2. Check your logs. `tail -f ~/.0L/logs/node.log`

When the sync is ongoing, you'd see something like this:

```
======================================  round is 17897
======================================  round is 17898
======================================  round is 17899
```
You might see some network errors due to drops, but should again see round numbers. 

This command will tell you the sync state of a RUNNING local node: `db-backup one-shot query node-state`

While waiting for the sync to complete, it is a good opportunity, to set up the web monitor (but you can also do it any time later). Please follow the instructions here:

[Set up web monitor](web_monitor.md) 


## 5. Start producing delay proofs on validator ("delay mining") 

Before you start: You will need your mnemonic.

5.1. Run the tower app within its own `tmux` session:
```
tmux new -s tower 
# to reconnect to the tmux tower session
tmux attach -t tower
```

5.2. From inside the `tmux` session, start the tower app:  
```
tower -o start >> ~/.0L/logs/tower.log 2>&1
``` 


## 6. Create VFN config and deploy the VFN.

6.1 Follow [step 1](#1.-Set-up-a-host) to set up a new host and install binaries

6.2 Fast Forward to the latest snapshot by following [step 3](#3.-Fast-forward-to-the-most-recent-state-snapshot)

### Return to validator machine 

6.2 Update validator 0L.toml file

Under `profile` include a `vfn_ip` field, with the IP address. This will simplify and correctly display networking addresses for the info helpers.

```
[profile]
account = "foo"
auth_key = "bar"
statement = "baz"
ip = "127.0.0.1"
# NEW FIELD HERE:
vfn_ip = "x.y.z.0"
```

6.3 Create your VFN configs on validator, and deploy on VFN.

```
# On your validator (or wherever your key_store.json lives)
# create settings for the VFN, private fullnode
ol init --vfn

# now copy the vfn.node.yaml file to your VFN machine
```

6.4 Check and update your on-chain configuration on validator node

More details here:
[Check and change your on-chain config](../documentation/node-ops/validators/changing_onchain_ip_address.md)

```

# what are your keys
ol whoami

# do your keys match what your node is using
ol whoami --check-yaml <path/to/node.yaml>

# what are your current on-chain configs
ol query --val-config

# Update your configs based on what your mnemonic uses
# Note the `-o` which means you are sending this from the "operator" account.
txs -o val-config --val-ip <IP> --vfn-ip <OTHER IP>


# check if those changes persisted and if they are able to be read.
ol query --val-config
4.1 To enable the node to run after you detach from your terminal session, start within a 
`tmux` session.

**note**: temporarily: as of v4.2.8 you'll need to increase your host's file descriptors. Fix is in the works. For now:
run this before starting your `tmux` session.
```

### Return to VFN 

6.5 Configure and start VFN 
```
# increase file d
escriptors
ulimit -n 100000
#### check that they have been increased
ulimit -n
100000
```
or edit the `/etc/security/limits.conf` file to make this change persistent across sessions:  
```
sudo vim /etc/security/limits.conf`
```
append to the end of the `limits.conf`. replace `yourusername` with the output from `whoami`.
``` 
yourusername soft    nproc          100000 
yourusername soft    nproc          100000
yourusername hard    nproc          100000
yourusername soft    nofile         100000
```
start your VFN in a `tmux` session.

```
tmux new -s vfn

# verify your file handlers have been increased
ulimit -n
100000
```

inside the `tmux` session start the VFN in VFN mode. 
```
# create log directory 
mkdir ~/.0L/logs

# start node 
diem-node --config ~/.0L/vfn.node.yaml  >> ~/.0L/logs/node.log 2>&1
```

6.6 Check your logs. `tail -f ~/.0L/logs/node.log`

When the sync is ongoing, you'd see something like this:

```
======================================  round is 17897
======================================  round is 17898
======================================  round is 17899
```
You might see some network errors due to drops, but should again see round numbers. 

This command will tell you the sync state of a RUNNING local node: `db-backup one-shot query node-state`


> :bangbang: **You must be onboarded by an existing validator to continue**
>
> To become a validator a user must display an intention to contribute to the ecosystem. 
> This can be done by many different ways like building tools, helping out the ecosystem and more.
>  If you would like to contribute reach out the the Hustle Karma channel in [Discord](https://discord.gg/cfXd9Ngk). When a validator is ready to 
> onboard you they can do it by the following command:
>
> ```txs create-validator -u http://[your-ip-address]```



## 7. Restart validator node in `validator` mode

Once the network is in sync and sufficient mining has been done (20 proofs per epoch/day), you are eligible to enter the 
validator set.

Once in the validator set, the node can connect to other validators and sign blocks.

6.1. On the next epoch, start node in `validator` mode.

Restarting your node in validator mode inside a `tmux` session.

Again, there may be an issue with file descriptors, increase with `ulimit -n 100000` before starting node

```
# stop diem node daemon
make stop
# and just in case, stop all processes
killall diem-node
```

start a `tmux` session
```
tmux new -s validator
```
optionally increase file descriptors limit, temporary fix for v4.2.8
```
ulimit -n 100000
```
then restart node with
```
diem-node --config  ~/.0L/validator.node.yaml >> ~/.0L/logs/validator.log 2>&1
```

6.2 Restart the tower app after your validator is running, refer to [Step 5](#5-start-producing-delay-proofs-delay-mining) - ctrl+ C and restart it. 

Once you have been on boarded you should see you public key in the list of validators. Run the web monitor to view:
```
ol serve -c
```
---

## Onboarder Troubleshooting
If you are having troubles onboarding, please see whether they match any of the issues here:
[troubleshooting onboarding](../../node-ops/validators/troubleshoting_onboarding.md)



## Onboarder instructions
If you are onboarding someone and have received their `account.json` file
1. Copy the `account.json` to your local node.
2. Submit a tx with `txs` app:
   `txs create-validator --account-file <path/to/account.json>

Troubleshooting: If there is an issue with sequence_number out of sync. Retry the transaction.


### Troubleshooting

#### cargo or rust are not installed

After `rust` and `cargo` are installed you are prompted to set a `PATH` environment variable. 
Follow those instructions or reset your terminal.   

![rust config instructions](rust-config-output.png)  

To configure your current shell, run:
```
source $HOME/.cargo/env
```
