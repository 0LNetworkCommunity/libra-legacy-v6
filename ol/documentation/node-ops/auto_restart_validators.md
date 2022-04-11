# Automatic restart of Validators

## Assumptions

- The command `killall` is installed
- The ol binaries are in ~/bin

## Instructions to start

To do so, you need to add a cronjob as:

1. Edit cron tab:

  `crontab -e`

You may need to choose your favorite text Editor. So choose *nano*, do yourself a favor ;)

2. Add these 2 lines at the very end of the file:

  `0 * * * * killall diem-node ol tower`
  
  `1 * * * * ~/bin/diem-node --config ~/.0L/validator.node.yaml  >> ~/.0L/logs/node.log 2>&1`

Save the file and let it do its magic.



## Instructions to stop


1. Edit cron tab:

  `crontab -e`
  
2. Delete the lines you added (supposedly the last ones) and save the file.  
