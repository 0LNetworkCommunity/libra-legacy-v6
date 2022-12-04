AutoPay module is developed to enable donations on the 0L. 

Functions: 

### Enable AutoPay on your node

```
txs autopay --enable
```


### Create AutoPay Instruction

Autopay instructions are usually configured in autopay_batch.json file and are enabled by the following command:

```
txs autopay-batch -f ~/.0L/autopay_batch.json 
```

Example autopay_batch.json file (with test data for account, don't use it like this):

```
{
 "instructions": [
    {
      "note": "entry which donates 5% of validator reward each epoch 1000 times",
      "uid": 1,
      "destination": "ABC12312312312312312312312312312",
      "type_of": "PercentOfChange",
      "value": 5.00,
      "duration_epochs": 1000
    },
   {
     "note": "one time donation of a fixed amount",
     "uid": 2,
     "destination": "ABC12312312312312312312312312312",
     "type_of": "FixedOnce",
     "value": 100000,
     "duration_epochs": 1
   }
 ]
}
```



### Disable AutoPay on your node

Disabling autopay will disable Autopay and cancel all of the previous autopay transactions.   

```
txs autopay --disable
```
