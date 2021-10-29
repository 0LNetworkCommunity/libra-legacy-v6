Error codes in 0L has two components:
-  The error reason
-  The error category

## Error Reason

The error reason has three components:
- The file prefix (the first character and a counter). e.g `1801` in `Reconfig`module. Refer to table below
- index of function (found in file). e.g. `06` for `process_outgoing`
- index of `Assert` in that function e.g. `02` for the second `Transaction::Assert`

For instance: `Reconfig` there could be a file prefix number e.g `1801` appended by an index for the function like e.g `06` for `process_outgoing`,  then an index of all errors within that function, e.g. on the second assert `02`.
The corresponding error reason is `1801` & `06` & `02` === `18010602`

## File Prefix
The file prefix is based on first character and counter. Alphabet to number conversion: a=01, b=02, ... z=26. The next two digits form the counter, which starts at 0 and is incremented if two files have same first character.

The mapping of prefix is available in this table. 

| Code        | Filename           | 
| ------------- |:-------------:| 
| 0100     | Autopay |
| 0300     | Cases |
| 0400     | Demos |
| 0500     | Epoch |
| 0600     | FullNodeState |
| 0700     | Globals |
| 1200     | LibraSystem |
| 1201     | LibraAccount |
| 1301     | MinerState |
| 1401     | NodeWeight |
| 1500     | Oracle |
| 1800     | Reconfigure |
| 1900     | Stats |
| 1901     | Subsidy |
| 1903     | Stagingnet |
| 2000     | TransactionFee |
| 2001     | TrustedAccounts |
| 2002     | Testnet |
| 2100     | Upgrade |
| 2200     | ValidatorConfig |
| 2201     | ValidatorUniverse |



## Error Categories 
- INVALID_STATE - checks if testnet or mainnet
- REQUIRES_ADDRESS 
- REQUIRES_ROLE - authorization required
- REQUIRES_CAPABILITY
- NOT_PUBLISHED - resource is not present
- ALREADY_PUBLISHED
- INVALID_ARGUMENT
- LIMIT_EXCEEDED
- INTERNAL
- CUSTOM