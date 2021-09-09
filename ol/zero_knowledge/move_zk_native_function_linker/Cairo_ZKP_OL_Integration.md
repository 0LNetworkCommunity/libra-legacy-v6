
## Writing and Using ZK-Mechanisms in Move
Zero-Knowledge Proofs are an emerging technology in Blockchains that have lots of potential. We can leverage ZK-STARKs to generate and verify proofs use and use the Cairo programming language to define what to check when verifying.


### Step 1: Write the Cairo Program
The Cairo Language is used to define the logic the programmer wishes to prove. For more information, see [Documentation](https://www.cairo-lang.org/docs/index.html)

### Step 2: Write the native functions
In order to be able to call the appropriate prove and verify functions in Move, you need to define the verify and prove functions written in Rust: [Writing and using native functions](https://github.com/OLSF/libra/wiki/Writing-and-using-native-functions).
<br>Once you have your methods ready, you can use https://github.com/patrickbiel01/Move_Native_Function_Linker and add the new functionality including your cairo file in *assets* and the code in *prove* will send your program the Shared Prover [(SHARP)](https://www.cairo-lang.org/docs/sharp.html#).

## Step 3: Test the Move functions
To ensure all the previous steps were performed correctly, perform functional tests on the Move module written:
https://github.com/OLSF/libra/wiki/Testing-0L

### Resources

#### Move_ZK_Native_Function_Linker
Define main verify, prove function for hiding transactions. Called in Move Native Function 
https://github.com/patrickbiel01/Move_ZK_Native_Function_Linker
 
#### Cairo ZK-STARK Verifier
https://github.com/patrickbiel01/Cairo_Verifier - based off of implementation at: https://github.com/starkware-libs/starkex-contracts/tree/master/evm-verifier

#### Cairo ZKP Branch - integrates Cairo ZK Mechanisms into 0L
Coming soon
