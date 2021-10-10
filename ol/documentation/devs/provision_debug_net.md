
# Provision a debug net

# Debug-net genesis instructions

These instructions are for provisioning a debug-network. 

- You should target 16gb ram and 50GB storage. Target CPU depending on how long you want to wait for builds, that's the heavy lifting.
- If you see a `cc linker error` this is usually an out of ram or storage error.


You will be using `make` to automate steps for genesis, and node startup. and `git` to fetch the project. So your OS should minimally have those installed. These instructions target ubuntu.

### Testing only: 
Provision your machines with hostnames with the pattern `ol-alice`, `ol-bob`, `ol-carol`,  `ol-dave`.

# Github Token
For genesis, each node needs their own Github token, so they can submit their genesis block and metadata to the common github backend.

1. Get a GitHub token https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

### Testing Only
You only need one github key for simulating all nodes in a debug-net. 

# Configure servers

2. Build. Checkout `debug-net` branch, and working directory will be /libra/my_configs. There are sample files in there.

- Build all dependencies on each machine with `make install`.

This will take some time.

TODO: there are issues with installing rust and exporting the rust binaries to path.

# (Testing only) Set up genesis remote backend (Github)

Skip this step in genesis, only one person will do this.

Github is used to coordinate the shared state of genesis. Configuring this is the role of the "genesis coordinator" persona.
For the debug-net simulation, the github token (when saved to `github_token.txt`), will allow you to create a temporary github repo under your PERSONAL github account. e.g. lpgeiger/debug-genesis-ceremony.

3. Initialize the Github repo as the "genesis coordinator" with `make github`
- Replace the template file `github_token.txt` with your token from step 0.
- Edit the my_configs/Makefile with REPO_OWNER as your username, REPO_NAME, the desired name for the repo.

# Generate Keys
(For Testing: skip this step, this file block_0.json will be set later)

The 0L miner creates your initial keys, and produces a first proof of your vdf tower. You need both the proof output (block_0.json) and the mnemonic to be able to participate in genesis.

4. Create keys with `make keygen`. A mnemonic will be printed on the screen.

DO NOT SAVE THE MNEMONIC TO A FILE. Write it down. Use a password manager. This will be the last time you will see the mnemonic. 

The 0L auth key (public key) and account will be printed as well. The auth_key will be included in your miner.toml config file.

If you type the mnemonic in the shell for any reason, clear your shell history thoroughly. (See commands in `make wipe`)

# Mine first proof

5. The first proof can be created with `make miner`. It will subsequently ask you for your mnemonic (from previous step).

Check the data in `../miner/miner.toml`. This includes a `statement` field which is an optional and free statement, anyone can add to their genesis proof. This will be included in the VDF preimage, which will be submitted to genesis block. It is hex-encoded but not encrypted and readable for all eternity.

This is the proof-of-work which is submitted for inclusion in genesis. 

This step can take 10-30 minutes to complete. The output is a block_0.json. This file should be copied to your my_config/ folder. Confirm it is there.


# Register to genesis
6. Update `my_configs/Makefile` with your account hash in ACC plus the IP address from the previous step

Do it here:
```
ifndef TEST
####################################
## GENESIS: UPDATE YOUR DATA HERE ##
# The permanent IP address of your validator.
IP = 192.241.147.210 # EXAMPLE
# The 0L account, which will be your namespace for all data
# Also is last 16 digits of auth_key hex.
ACC = 402e9aaf54ca8c39bab641b0c9829070 # EXAMPLE
NAMESPACE = $(ACC)
# Don't put the MNEM here for production, add that by command line only.
else
NAMESPACE = $(TEST)
endif
```

7. Run `make register" The CLI will ask for the mnemonic, copy and paste from a password manager.

NOTE: DO NOT APPEND A COMMAND LINE ARG like MNEM=<string>. THIS HAS NO EFFECT. ITS UNSAFE SINCE IT WILL BE SAVED IN YOUR BASH HISTORY. If you did so, do `make wipe`, to clear history.

### Testing Only

Use test constants with `ENV=test`, and set it to test mode with `TEST=y`.

`make register ENV=test TEST=y`. This assumes each machine's hostname is with the patter `ol-alice`, `ol-bob`, and will use the name `alice` and `bob` as personas for purpose of setting fixtures. To configure a machine with that persona. You can see the 4 options in my_config/Makefile.

register each/all nodes to participate in a mock genesis with `make register ENV=test TEST=y`
- this uses the github repo created above. It will fail if that repo has not been created with `make github`.
- If there are other errors delete the repo and start over.
- IMPORTANT, Genesis should not be run locally until EVERY node has registered and concluded this step.

# (Testing only) Layout File
Skip this production genesis, only one person must do this.

In genesis, only one person is needed to submit the layout file to Github remote backend, after all validators have registered.

8. Do this with `make set_layout`.


# Genesis
After EVERY validator has registered, each validator can build genesis locally.

9. Pull the tag version for genesis (v3.0.1), and rebuild with `make compile`.

10. Run all genesis steps `make genesis`
- for testing run with `make genesis ENV=test TEST=y`, etc.

11. Start the network with `make start`.
- After you confirm the network starts. Stop diem-node (ctrl+c), and proceed to start a daemon, to keep the diem-node running and restarting in background.

(For testing: do this on each machine for each persona).

# Make diem-node run in background

12. Install and start the systemd daemon configs with `make daemon`.
- NOTE: These instructions are for systemd targeted at debian/ubuntu.


This will pause for a couple of seconds and then show the status of daemon, and then tail the logs of diem-node.
You can exit the logs with `ctrl+c`, it will not affect the running node.


## connecting the client
See instructions:
(../ops/connect_client_to_network.md)

## Possible errors

### Problem

thread 'main' panicked at 'called Result::unwrap() on an Err value: RemoteStorageUnavailable("Internal error: Http error: HTTP/1.1 401 Unauthorized")', config/management/src/lib.rs:136:35
note: run with RUST_BACKTRACE=1 environment variable to display a backtrace
Makefile:148: recipe for target 'add-proofs' failed
make: *** [add-proofs] Error 101

Solution: check github token in myconfig/

### Problem

error: Invalid value for '--fullnode-address <fullnode-address>': error parsing ip4/ip6 address: invalid IP address syntax
Makefile:158: recipe for target 'register' failed
make: *** [register] Error 1

Solution: Make sure there is no extra spaces in IP address in myconfig/Makefile