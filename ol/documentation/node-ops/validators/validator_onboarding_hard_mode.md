# Validator Setup


## Requirements 
- TWO unix hosts, one for Validator Node, and one for the Private Fullnode ("VFN").
0L code targets Ubuntu 20.4
- Recommended specs: 
  - Validator: 250G harddrive, 8 core CPU, 16G RAM
  - VFN: 100G storage, 2 core CPU, 8G RAM
- Separate static IP addresses for the machines, or appropriate DNS mapping.


## Firewall settings

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
1. Setup linux node(s) and install the 0L binaries.
2. Generate a public mining/validator key and associated mneumonic.
3. Generate and share you `account.json` file with someone who has gas and can execute the onboarding transaction for you.

4. Get the latest snapshot state of the network by running `ol restore`. 
4. Start your node in *fullnode* mode. 
5. Allow your *fullnode* to sync up with the network. Depending on how old the snapshot obtained from `ol restore` is
   may take a while (1 hr or more). To check the state of the sync run `db-backup one-shot query node-state`.
6. Start the tower app which will produce and submit VDF proofs to the chain. 
   **note** if your node is not fully synced and if you have not been onboarded yet, you will see errors from the tower app 
   until your node has caught up to the current state and you have been onboarded.
5. Restart your node in *validator* mode. You will join in the next epoch if you have been on boarded by an active validator.
8. Run `ol explorer` to see the state of the network, you should see your validators public key in the list of validators. 

## 1. Set up a host

### 1.1. Install Ubuntu linux host machine
These instructions target Ubuntu 20.4 LTS (codename: Focal Fossa).

Set up an Ubuntu host with `ssh` and root access, e.g. in a cloud service provider. 

Associate a static IP  with your host, this will be tied to you account. This address will be shared on the chain, so that other nodes will be able to find you through the peer discovery mechanism.

### 1.2. Create linux service user

*Motivation*: 0L binaries should be run in a linux user that has very narrow permissions.

We will create a user called `node` which has no password (can only be accessed initially by sudo).
```
# create user with home directory /home/node
sudo useradd node -m -s /bin/bash
```

You can then access that account ...
* using `sudo su - node` (as root/sudo user)
* ssh as node user (requires you to put your ssh public keys in `/home/node/.ssh/authorized_keys`)

### 1.3. Choose build option

Tutorial provides two options:
* Build binaries inside a chroot sandbox environment
* Build binaries on host

Either way you will end up with the binaries installed in `/home/node/bin` directory:
```
ls /home/node/bin
# db-backup  db-backup-verify  db-restore  diem-node  ol  onboard  tower  txs
```

It is recommended to perform the build steps inside tmux.

Short tmux introduction:

```
# start a new tmux session
tmux

# to rejoin the session
tmux a
```
to detach from the `tmux` session use key stroke: `Ctrl-b` then `d`


### 1.4. Build binaries inside a chroot sandbox environment (Option 1)
Build the binaries in a sandbox environment on an Ubuntu host.

This will keep the host small, secure and maintainable and allows to upgrade Ubuntu packages for runtime and build independently!

When following this tutorial you **have to be aware** of the environments (host or sandbox) you are currently working in!

#### Requirements
You need root access to the Ubuntu host to work with `chroot`. You might want to read more about chroot here: https://help.ubuntu.com/lts/installation-guide/armhf/apds04.html.

Install `debootstrap` package using apt **[on host]**:
```
# as root
apt install debootstrap
```

Create empty directory which will become the root (`/`) of the sandbox system; needs at least 8 GB free disk space **[on host]**:
```
# feel free to choose a different directory
mkdir /opt/ubuntu-build-0L
```

Populate chroot directory **[on host]**:
```
# should take few minutes
debootstrap --arch amd64 focal /opt/ubuntu-build-0L
```

Enter (aka chroot) into the sandbox system **[on host]**:
```
LANG=C.UTF-8 chroot /opt/ubuntu-build-0L /bin/bash
```

(optional) Look around in the sandbox - you should see a blank linux environment **[in sandbox]**:
```
# mount should give an error
mount
# root directory is almost empty
ls /root
```

Configure source list for apt **[in sandbox]**:
```
cat <<EOT > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu focal main universe
deb http://security.ubuntu.com/ubuntu focal-security main universe
EOT
```

Update apt index **[in sandbox]**:
```
apt update
```

Mount `/proc` and populate `/dev` **[in sandbox]**:
```
# note: if you reboot the machine you will need to redo this
mount none /proc -t proc

apt install makedev
mount devpts /dev/pts -t devpts
```

Prepare build tooling **[in sandbox]**:
```
# this steps are slightly modified version of this: https://raw.githubusercontent.com/OLSF/libra/main/ol/util/setup.sh

apt install -y curl git tmux jq build-essential cmake clang llvm libgmp-dev pkg-config libssl-dev lld

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
source $HOME/.cargo/env

# should take few minutes
cargo install toml-cli sccache
export RUSTC_WRAPPER=sccache
```

Clone the source code from GitHub and execute build **[in sandbox]**:
```
# as root
cd /usr/local/src
git clone https://github.com/OLSF/libra.git
cd libra
# should take apprx 15 minutes
make bins

# copy binaries over to `/root/bin`
# binaries: db-backup, db-backup-verify, db-restore, diem-node, ol, onboard, tower, txs
make install
```

Done. Now exit the sandbox and grab the binaries **[in sandbox/on host]**:
```
# get out of sandbox back to the host
exit
# inspect binaries
ls -l /opt/ubuntu-build-0L/root/bin
# create tar archive
cd /opt/ubuntu-build-0L/root && tar cfz /tmp/binaries0L.tgz bin
```

We are **done**! The binaries are now build and ready and can be found in `/tmp/binaries0L.tgz`

Install the binaries in home directory of `node` user **[on host]**:
```
# become node use
su - node
# double-check
id

mkdir $HOME/bin
tar xfz /tmp/binaries0L.tgz --directory=$HOME
# inspect
ls /home/node/bin
```

(optional) Remove the build sandbox **[on host]**:
```
umount /opt/ubuntu-build-0L/proc
rm -rf /opt/ubuntu-build-0L
```


### 1.5. Build binaries directly on host  (Option 2)

Clone this repo: 

`git clone https://github.com/OLSF/libra.git`


For more details: (../devs/OS_dependencies.md)

Build the source and install binaries:
This takes a while, run inside `tmux` to avoid your session gets disconnected 

```
cd </path/to/libra-source/> 
make bins install
```

### 1.6. Fetch the web server files
```
ol serve --update
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

## 4. Start the node in `fullnode` mode:

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

## verify your file handlers have been increased
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

## 5. Start producing delay proofs ("delay mining") 

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

## 6. Restart node in `validator` mode

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
