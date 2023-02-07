# Validator Onboarding Guide: Easy Mode

## Easy Mode

There are a lot of things to configure to set up an 0L validator. Easy Mode makes assumptions. 

You can optionally do [Hard Mode](validator_onboarding_hard_mode.md), and build from source, and write your own config files.

### Things you will need:

- A cloud virtual machine running Linux Ubuntu 20.4, with 16GB Ram, and 4 Cores.

Settings for the host:
- You need to set a *static* IP address for that host.
- You need to open ports 6179, 6180, 8080, 3030 on the host


# 1. Install binaries

Export the `~/bins` directory to be in search path, and download the binaries with a script.

```
export PATH=$PATH:~/bin && echo export PATH=\$PATH:~/bin >> ~/.bashrc

curl -sL https://raw.githubusercontent.com/0LNetworkCommunity/libra/main/ol/util/install.sh | bash
```
# 2. Start a persistent terminal session

Recommended multiplexer is `tmux`.

```
> tmux 

# or `tmux a` to reattach to a previous session
> tmux a
```

# 3. Make keys

#### Make new keys, and address:

From within your `tmux` instance:

```
onboard keygen
```

## STOP. WRITE THIS INFO DOWN *ON PEN AND PAPER*.  NOW.

# 4. Create config files

Preferably use a template from a url (usually on another node on the network). Something like: 

```
onboard val -u http://[their-ip-address]
```
NOTE: Don't forget `http://`

# 5. Wait

Your `tower` app will produce a proof which is needed to create an account. This will take 10-15 minutes.

# 6. Start 0L services

The `start` subcommand will run `pilot` app which continuously checks node and tower state and changes nodes. 

```
# Restore from the latest epoch snapshot instead of syncing the entire chain
> ol restore

# start all 0L services and restore chain from archive

> ol start

# press <ctrl+b> then <d> to detach from tmux without stopping the app. Reattach with `tmux a`
```

#### Check the web monitor

Go to: `http://[your-ip-address]:3030`

##### Troubleshooting: If no page loads here, you may not have port `3030` open to the public.

# 7. Create account on chain

Have someone (with GAS) submit the account creation on chain.  

```
txs create-validator -u http://[your-ip-address]
```

More details here: (create_account_on_chain.md)


