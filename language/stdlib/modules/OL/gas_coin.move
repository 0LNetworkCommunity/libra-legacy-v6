// In OL the unit of account for vm operations is called "gas", and the medium of exchange is a cryptographic token called "GAS".
// Gas_Coin is an OL move "type" which contains the methods which addresses (users) can call.


address 0x0{
  module Gas_Coin {
    // pub fun mint(caller, destination, quantity) {
      // permissions: this method can only be called by certain modules and addresses.
      // Generates a coin
    //}

    // pub fun spend(module address){
      // Note: Gas coin's purpose is to be spent on move modules.
      // Permnissions: anyone can call spend()
    //}

    // pub fun transfer(TBD){
      // - from Libra core. Need to disable this function.
      // In OL transfers are disabled, since GAS is not intended to be a general currency, but a private currency compute operations.
      // - This method is a no-op and exists for informational purposes. It generates a warning: "Gas is not transferable like FB Libra".
      // Note: there is an implementation issue, where subsidy may need to *transfer* funds to the consensus leader.
      // Permissions, only the subsidy module, exceptionally, can call the transfer function.
    //}

    // pub fun burn(coin){
      // - Removes units from circulation, by sending to a "burn wallet" a valid wallet that is verifiably inoperable (i.e. cannot sign transactions to resend funds from).
      // IMPORTANT: Burn_desitnations is a list of addresses. There may be multiple verifiably irretrievable burn wallets.
      // Permissions: Anyone burn their own coins.

      // let_burn_wallets = []
    //}
  }
}
