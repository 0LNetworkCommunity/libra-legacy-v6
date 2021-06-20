# v4.3.2 Upgrade

WARNING: 0L Tools no longer depend on sudo/root access. As such some default install paths have changed. 

As of v4.3.2 the default location for executables is `$HOME/bin`. Previously they were in `/usr/local/bin` which required root/sudo


## backup your files

```
cd ~
rsync -av --exclude db/ ~/.0L ~/0L_backup_202106

```

## If you are using root/sudo: create a new user on host

Especially important for those running as root.

Make this a restricted user: do not give the user `sudo`. 

For a user with the name `val`:
```

sudo useradd -m val

```

##  Switch into new user

```
su val
```

## Add ~/bin to PATH

`~/bin` will be where your binaries will live. You need to add this to the "search path" to execute commands easily.

```
# add to ./bashrc
PATH=~/bin:$PATH
```

Do this: https://unix.stackexchange.com/questions/26047/how-to-correctly-add-a-path-to-path


TODO: dboreham, tell us what to do.


### Add your ssh pubkey to the new user

Include your public key in .ssh/authorized_key so you can access the user directly from ssh.

```
nano /home/val/.ssh/authorized_keys
```

alternatively copy the file from the /root/.ssh/authorized_keys

```
cp /root/.ssh/authorized_keys /home/val/.ssh/

```


## Fetch latest code

```
git clone https://github.com/OLSF/libra.git --branch main --depth 1 --single-branch
```

##  Build binaries
```
cd libra
make bins install
```

## Create Autopay File

For your autopay instructions to be preserved, an `autopay_batch.json` file should exist in your intended config folder (e.g. `~/.0L/autopay_batch.json`).

Here's a blank example: https://github.com/LOL-LLC/donations-record/blob/main/clean.autopay_batch.json

## Recreate config files

Follow these instructions to refresh your node's configurations. This way they will be up to date with the configuration format that other validators have.

Do this first: [Resetting Val Configs](resetting_val_configs.md)


## Restart your services as the new user

Stop your node, miner, monitor and restart

```
# in previous user
ol mgmt --stop all

# in new user
ol start
```
