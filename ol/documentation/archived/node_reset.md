# Best-Practices Configuration

WARNING: 0L Tools no longer depend on sudo/root access. As such some default install paths have changed. 

As of v4.3.2 the default location for executables is `$HOME/bin`. Previously they were in `/usr/local/bin` which required root/sudo

## If you are using root/sudo: create a new user on host

This is unsafe, and the tools do not depend on sudo.

[Migrate host configs away from sudo](ops_migrate_from_sudo.md)

## backup your files

```
cd ~
rsync -av --exclude db/ ~/.0L ~/0L_backup_202106
```

## Stop your services
```
ol mgmt --stop all
```
## Confirm executables are in $HOME/bin

Find out where the executables are.

```
which ol

# If this is the output, you need to migrate.
/usr/local/bin/ol
```

If you haven't yet migrated the locations do this:

```
mkdir ~/bin

# add /bin to the search PATH
echo PATH=~/bin:$PATH >> ~/.bashrc

sudo cp /usr/local/bin/* ~/bin
```

## Fetch latest code

```
git clone https://github.com/0LNetworkCommunity/libra.git --branch main --depth 1 --single-branch
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

Recommended way is to use the service orchestration with:

```
ol start
```
