# Move_ZK_Native_Function_Linker
A library that defines proving and verifying logic for a Move Module.
<br>For a detailed overview look at my [Medium post](https://medium.com/@patrick.adam.biel/zk-starks-cairo-and-open-libra-a5e5984c82b2).

## Verify
Given a proof, it sends it through the [Cairo Verifier](https://github.com/patrickbiel01/Cairo_Verifier) to make sure it's valid

## Prove
Given an amount, it verifies that the amount is sufficient by executing the Cairo Program, sending the trace to [SHARP](https://www.cairo-lang.org/docs/sharp.html) (Shared Prover), scraping the proof off of the Ropsten Testnet and returning it

## Adding your own functionality
- Fork
- [Download, install](https://www.cairo-lang.org/docs/quickstart.html) and [start developing](https://www.cairo-lang.org/docs/index.html) Cairo
- Add the Cairo Program written to the *assets* directory.
- Copy/Change *prove* in prove_and_verify.rs to reference the new Cairo program and change parameters accordingly

For more information about OL integration, reference the [guide](https://github.com/patrickbiel01/Move_ZK_Native_Function_Linker/blob/main/Cairo_ZKP_OL_Integration.md)
