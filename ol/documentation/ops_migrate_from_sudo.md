# Migrate node ops away from sudo/root users

WARNING: 0L Tools no longer depend on sudo/root access. As such some default install paths have changed. 

As of v4.3.2 the default location for executables is `$HOME/bin`. Previously they were in `/usr/local/bin` which required root/sudo

## Create a new user on host

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

`~/bin` will be where your 0L executables will live. You need to add this to the shell "search path" to execute commands easily.

Follow this if in doubt: https://unix.stackexchange.com/questions/26047/how-to-correctly-add-a-path-to-path

##### Add this to ./bashrc : `PATH=~/bin:$PATH`

or just execute this:

```
echo PATH=~/bin:$PATH >> ~/.bashrc
```

### Add your ssh pubkey to the new user

Include your ssh public key in .ssh/authorized_key so you can access the user directly from ssh.

```
nano /home/val/.ssh/authorized_keys
```

alternatively copy the file from the /root/.ssh/authorized_keys

```
cp /root/.ssh/authorized_keys /home/val/.ssh/
```