**This document will guide in setting up a cron job on your validator node. The cron job will email you the status of node every day around 6:30pm ET.**

## We using below tools for this guide: 
1. Postfix email server
2. Tmux sessions for nodes
3. Script that takes a screenshot for tmux session
4. Cron job for sending email at regular intervals 

## Postfix email server

Get your ubuntu version using the following command ``lsb_release -a``

Find instructions specific to the ubuntu version to install postfix. 

Here is one for ``ubuntu 20.04`` : https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-on-ubuntu-20-04

Work through Step 2 in the above link.

After step 2, install mailutils using below command. 

``sudo apt install mailutils``

Time to test: 
echo "This email confirms that Postfix is working" | mail -s "Testing Posfix" test@utoronto.ca

In case you would like to send email to gmail. Instructions here:https://askubuntu.com/questions/1112772/send-system-mail-ubuntu-18-04

#### Note: These steps wont work for sending email to gmail. Additional steps might be needed. Request anyone able to set that up to update this document.  

## Tmux sessions for nodes

Setup Tmux session for all the commands ex: running miner, tailing logs and viewing explorer. 

Tmux should be installed in your linux machine already. 

Start session: ``tmux``

Split tab vertically: ``ctrl + b + %`` (3 tabs for each of the above tasks)

## Script for taking screenshot

Create a script file lets say ``status.sh``:
``` 
 #!/bin/bash
 tmux capture-pane -J -p -t 0 > node.txt
 tmux capture-pane -J -p -t 1 > miner.txt
 tmux capture-pane -J -p -t 2 > explorer.txt
 echo "Status today" | mail -s "Node Status" mail@utoronto.ca -A ~/node.txt -A ~/miner.txt -A ~/explorer.txt
```

Save and exit.

## Cron job for sending email

Enter crontab: ```sudo nano /etc/crontab```

Add the following link: ```30 22  * * *   root /usr/bin/sh ~/status.sh```

