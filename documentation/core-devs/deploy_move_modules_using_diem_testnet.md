### Clone git repo diem:

git clone https://github.com/diem/diem.git && cd diem

### Configuration of some files to get the publish function working:

```nano -l ~/diem/testsuite/cli/src/client_proxy.rs
sed -n '963,975p' ~/diem/testsuite/cli/src/client_proxy.rs
Line 972 delete the & at sender
 964     fn submit_program(
 965         &mut self,
 966         space_delim_strings: &[&str],
 967         program: TransactionPayload,
 968     ) -> Result<()> {
 969         let (sender_address, _) =
 970             self.get_account_address_from_parameter(space_delim_strings[1])?;
 971         let sender = self.get_account_data(&sender_address)?;
 972         let txn = self.create_txn_to_submit(program, &sender, None, None, None)?;
 973
 974         self.submit_and_wait(&txn, true)?;
 975         Ok(())
 976     }
```

### Comment the lines out:

```nano -l ~/diem/diem-move/diem-framework/DPN/sources/DiemAccount.move
sed -n '1554,1557p' ~/diem/diem-move/diem-framework/DPN/sources/DiemAccount.move
1551         assert(
1552             DiemTransactionPublishingOption::is_module_allowed(&sender),
1553             Errors::invalid_state(PROLOGUE_EMODULE_NOT_ALLOWED),
1554         );
```
### Build stdlib
```
cd ~/diem/language/diem-framework
cargo run
```

### Run testnet (~/diem):
```
cargo run -p diem-node -- --test
Example:
Entering test mode, this should never be used in production!
Completed generating configuration:
        Log file: "/tmp/0411129894e44130a3d2e66730ad44de/validator.log"
        Config path: "/tmp/0411129894e44130a3d2e66730ad44de/0/node.yaml"
        Diem root key path: "/tmp/0411129894e44130a3d2e66730ad44de/mint.key"
        Waypoint: 0:491a989706eb3eb952328cf22256ca449a6df27200cad401c1c722954b37b6a8
        JSON-RPC endpoint: 0.0.0.0:8080
        FullNode network: /ip4/0.0.0.0/tcp/7180
        ChainId: TESTING
Diem is running, press ctrl-c to exit
```

### Run Cli-Client (~/diem):
```
cd ~/diem
cargo run -p cli -- -c $CHAIN_ID -m $ROOT_KEY -u http://127.0.0.1:8080 --waypoint $WAYPOINT
```

### Create and load account with XUS
```
account create

account mintb 0 100 XUS
```

### Compile move module
```
dev c /src/modules/Coin.move <fullpath>/language/move-stdlib/modules

Successfully compiled a program at:
  /tmp/117a9d00388c0587d2b5363dc4bbafa9/modules/0_Coin.mv

```
### Publish module
```
dev p 0000000000000000000000000a550c18 /tmp/117a9d00388c0587d2b5363dc4bbafa9/modules/0_Coin.mv

Successfully published module
```
