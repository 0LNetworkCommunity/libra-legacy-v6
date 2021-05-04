# Things you will need:


## Requirements 
- A unix host machine, e.g Linux Ubuntu 20.4
- A fixed IP address of the machine
- Recommended specs: 250G harddrive, 4 cores

### High-level Steps
1. Install binaries.
2. Generate a public mining/validator key and associated mneumonic.
3. Generate and share you `account.json` file with someone who has gas and can execute the onboarding transaction for you.

4. Get the latest snapshot state of the network by running `ol restore`. 
4. Start your node in *fullnode* mode. 
5. Allow your *fullnode* to sync up with the network. Depending on how old the snapshot obtained from `ol restore` is
   may take a while (1 hr or more). To check the state of the sync run `db-backup one-shot query node-state`.
6. Start the miner which will produce and submit VDF proofs to the chain. 
   **note** if your node is not fully synced and if you have not been onboarded yet, you will see errors from the miner 
   until your node has caught up to the current state and you have been onboarded.
5. Restart your node in *validator* mode. You will join in the next epoch if you have been on boarded by an active validator.
8. Run `ol explorer` to see the state of the network, you should see your validators public key in the list of validators. 

## 1. Set up a host (build binaries)

These instructions target Ubuntu.

1.1. Set up an Ubuntu host with `ssh` access, e.g. in a cloud service provider. 
1.2.  Associate a static IP  with your host, this will be tied to you account, and will be set in your `account.json` file.
1.3. You'll want to use `screen` (or `tmux`) to persist the terminal session for build (you'll use `screen` or `tmux` 
      for running the nodes / miner as well). 

screen
```
# start a new screen session
screen -S build

# to rejoin the session
screen -rd build 
```
tmux
```
# start a new tmux session
tmux new -s build

# to rejoin the session
tmux attach -t build
```
to detach from the `tmux` session `Ctrl-b d`

1.3. Clone this repo: 

`git clone https://github.com/OLSF/libra.git`

1.4. Config dependencies: 

using make or running the `utils/setup.sh` script directly

using make
```
sudo apt install make
make deps
```

or run the script directly
```
cd </path/to/libra/source/> && . util/setup.sh
```

After `rust` and `cargo` are installed you are prompted to set a `PATH` environment variable. 
Follow those instructions or reset your terminal.   

![rust config instructions](rust-config-output.png)  

To configure your current shell, run:
```
source $HOME/.cargo/env
```

or reset your terminal
```
reset
```

For more details: https://github.com/OLSF/libra/wiki/OS-Dependencies

1.5. Build the source and install binaries:
This takes a while, run inside `tmux` or `screen` in case your session gets disconnected 
```
cd </path/to/libra/source/> 
make bins
```

## 2. Generate an account

[In-depth guide](https://github.com/OLSF/libra/wiki/Account-creation-for-validators) 

Before you start: have the static IP address you wish to associate with your validator, and a fun personal statement 
to place in your first proof.

2.1. Generate new keys and account: `miner keygen`. Run as many times as you like, and choose a mnemonic. 
**Mnemonic and keys are not saved anywhere, write them down now**. 

2.2. Run the validator onboarding wizard inside a `screen` or `tmux` session, and answer questions: 

```
# start wizard
miner val-wizard
```

2.3. Send the generated `~/.0L/account.json` to someone that has GAS and can execute the account creation transaction for you.

**If you are onboaring someone and receive the `account.json` [see](#onboarder-instructions)**  

2.4. Backup your files: `cp -r ~/.0L/* ~/.0L/init-backup/`

## 3. Fast forward to the recent state 

Speed up the sync of your ledger by restoring a backup before starting a fullnode (next step). 
The following command will fetch the latest epoch archive, usually from within the last 24h.

```
ol restore
```

## 4. Start the node in `fullnode` mode:

4.1 To enable the node to run after you detach from your terminal session, start within a 
`screen` or `tmux` session.

**note**: temporarily: as of v4.2.8 you'll need to increase your host's file descriptors. Fix is in the works. For now:
run this before starting your `tmux` or `screen` session.
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
start your fullnode in a `screen` or `tmux` session.

```
screen -S fullnode 

## verify your file handlers have been increased
ulimit -n
100000
```
or 

```
tmux new -s fullnode

## verify your file handlers have been increased
ulimit -n
100000
```

inside the `screen` or `tmux` session start the node in fullnode mode. 
```
# create log directory 
mkdir ~/.0L/logs

#start node 
libra-node --config ~/.0L/fullnode.node.yaml  >> ~/.0L/logs/node.log 2>&1
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

## 5. Start producing delay proofs ("delay mining") 

Before you start: You will need your mnemonic.

5.1. Run the miner within its own `screen` or `tmux` session:
```
screen -S miner 
# to reconnect to the screen miner session
screen -rd miner
```
or
```
tmux new -s miner 
# to reconnect to the tmux miner session
tmux attach -t miner
```

5.2. From inside the `screen` or `tmux` session, start the miner and enter your mnemonic:  
```
miner start >> ~/.0L/logs/miner.log 2>&1
``` 

## 6. Restart node in `validator` mode

Once the network is in sync and sufficient mining has been done (20 proofs per epoch/day), you are eligible to enter the 
validator set.

Once in the validator set, the node can connect to other validators and sign blocks.

6.1. On the next epoch, start node in `validator` mode.

Restarting your node in validator mode inside a `screen` or `tmux` session.

Again, there may be an issue with file descriptors, increase with `ulimit -n 100000` before starting node

```
# stop libra-node daemon
make stop
# and just in case, stop all processes
killall libra-node
```
start a `screen` or `tmux` session

```
screen -S validator
```
or
```
tmux new -s validator
```
optionally increase file descriptors limit, temporary fix for v4.2.8
```
ulimit -n 100000
```
then restart node with
```
libra-node --config  ~/.0L/validator.node.yaml >> ~/.0L/logs/validator.log 2>&1
```

6.2 Restart the miner after your validator is running, refer to [Step 5](#5-start-producing-delay-proofs-delay-mining) - ctrl+ C and restart it. 

Once you have been on boarded you should see you public key in the list of validators. Run the explorer to view:
```
ol explorer
```
---

## Onboarder instructions
If you are onboarding someone and have received their `account.json` file
1. Copy the `account.json` to your local node.
2. Submit a tx with `txs` app:
   `txs create-validator <path/to/account.json>

Troubleshooting: If there is an issue with sequence_number out of sync. Retry the transaction.

