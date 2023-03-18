///////////////////////////////////////////////////////////////////////////
// 0L Module
// MultiSig
// A payment tool for transfers which require n-of-m approvals
///////////////////////////////////////////////////////////////////////////


// The main design goals of this multisig implementation are:
// 0 . Leverages MultiSig library which allows for arbitrary transaction types to be handled by the multisig. This is a payments implementation.
// 1. should leverage the usual transaction flow and tools which users are familiar with to add funds to the account. The funds remain viewable by the usual tools for viewing account balances.
// 2. The authority over the address should not require collecting signatures offline: transactions should be submitted directly to the contract.
// 3. Funds are disbursed as usual: to a destination addresses, and not into any intermediate structures.
// 4. Does not pool funds into a custodian contract (like gnosis-type implementations)
// 5. Uses the shared security of the root address, and as such charge a fee for this benefit.

// Custody
// This multisig implementation does not custody funds in a central address (the MultiSig smart contract address does not pool funds).

// The multisig funds exist on a remote address, the address of the creator.
// This implies some safety features which need to be implemented to prevent the creator from having undue influence over the multisig after it has been created.

// No Segregation
// Once the account is created, and intantiated as a multisig, the funds remain in the ordinary data structure for coins. There is no intermediary data structure which holds the coins, neither on the account address, nor in the smart contract address.
// This means that all existing tools for sending transfers to this account will execute as usual. All tools and APIs which read balances will work as usual.

// Root Security
// A third party multisig app could not achieve the design goals above. Achieving it requires tight coupling to the DiemAccount tools, and VM authority. Third party multisig apps are possible, but either they will use a custodial model, use segrated structures on a sender account (where the signer may always have authority), or they will require the user to collect signatures offline. All of these options will require new tooling to fund, withdraw, and view coins.

// Fees
// As noted elsewhere there is value in "Root Security" and as such there would be a fee for this service. The fee is a percentage of the funds which are added to the multisig. The fee is paid to the root address, and is used to pay for the security from consensus (validator rewards). The fee is a percentage of the funds added to the multisig.


// Authorities
// What changes from a vanilla 0L Address that the "signer" for the account loses access to that account. And instead the funds are controlled by the Multisig logic. The implementation of this is that the account's AuthKey is rotated to a random number, and the signer for the account is removed, forcing the signer to lose control. As such the sender needs to THINK CAREFULLY about the initial set of authorities on this address.



address DiemFramework {
module MultiSigPayment {
  // use Std::Vector;
  // use Std::Option;
  // use Std::Signer;
  // use Std::Errors;
  // use Std::FixedPoint32;
  // use DiemFramework::DiemAccount;
  // use DiemFramework::DiemConfig;
  // use DiemFramework::Debug::print;
  // use DiemFramework::GAS::GAS;
  // use DiemFramework::VectorHelper;
  use DiemFramework::MultiSig;


  /// Genesis starting fee for multisig service
  const STARTING_FEE: u64 = 00000027; // 1% per year, 0.0027% per epoch
  const PERCENT_SCALE: u64 = 1000000; // for 4 decimal precision percentages



  struct RootMultiSigRegistry has key {
    list: vector<address>,
    fee: u64, // percentage balance fee denomiated in 4 decimal precision 123456 = 12.3456%
  }
  
  /// A MultiSig account is an account which requires multiple votes from Authorities to send a transaction.
  /// A multisig can be used to get agreement on different types of transactions, such as:
  // A payment transaction
  // A multisig MultiSig<PropGovSigners> transaction
  // or a transaction type defined and handled by a third party smart contract.(this module will return if approved/rejected.
  // This contract only has handlers for the first two types of transactions.

  // this is one of the types that MultiSig will handle.
  // though this can be coded by a third party, this is the most common 
  // use case, that requires the most secrutiy (and should be provided by root)
  struct PaymentType has key, store, drop {
    // The transaction to be executed
    destination: address,
    // amount
    amount: u64,
    // note
    note: vector<u8>,
  }

  public fun new_payment(destination: address, amount: u64, note: vector<u8>): PaymentType {
    PaymentType {
      destination,
      amount,
      note,
    }
  }


  // Propose a transaction 
  // Transactions should be easy, and have one obvious way to do it. There should be no other method for voting for a tx.
  // this function will catch a duplicate, and vote in its favor.
  // This causes a user interface issue, users need to know that you cannot have two open proposals for the same transaction.
  // It's optional to state how many epochs from today the transaction should expire. If the transaction is not approved by then, it will be rejected.
  // The default will be 14 days.
  // Only the first proposer can set the expiration time. It will be ignored when a duplicate is caught.


  public fun propose_payment(sig: &signer, multisig_addr: address, recipient: address, amount: u64, note: vector<u8>) {
    let p = new_payment(recipient, amount, note);
    MultiSig::propose<PaymentType>(sig, multisig_addr, p);
  }



  // Sending payment. Ordinarily an account can only transfer funds if the signer of that account is sending the transaction.
  // In Libra we have "withdrawal capability" tokens, which allow the holder of that token to authorize transactions. At the initilization of the multisig, the "withdrawal capability" was passed into the MultiSig datastructure.
  // Withdrawal capabilities are "hot potato" data. Meaning, they cannot ever be dropped and need to be moved to a final resting place, or returned to the struct that was housing it. That is what happens at the end of release_payment, it is only borrowed, and never leaves the data structure.
  // fun release_payment(ms: &mut MultiSig::MultiSig<PaymentType>, prop_id: u64) {
  //   let p = Vector::borrow(&mut ms.pending, prop_id);
  //   if (Option::is_some(&ms.withdraw_capability)) {
  //     DiemAccount::pay_from<GAS>(
  //       Option::borrow(&mut ms.withdraw_capability),
  //       p.prop_type.destination,
  //       p.prop_type.amount,
  //       *&p.prop_type.note,
  //       b""
  //     );
  //   }

  // }



}
}