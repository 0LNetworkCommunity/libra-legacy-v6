///////////////////////////////////////////////////////////////////////////
// 0L Module
// MultiSig
// A payment tool for transfers which require n-of-m approvals
///////////////////////////////////////////////////////////////////////////


// The main design goals of this multisig implementation are:
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
module MultiSig {
  use Std::Option::Option;
  use Std::Vector;
  use Std::Signer;
  use Std::Errors;
  use DiemFramework::DiemAccount;

  /// The owner of this account can't be an authority, since it will subsequently be bricked. The signer of this account is no longer useful. The account is now controlled by the MultiSig logic. 
  const ESIGNER_CANT_BE_AUTHORITY: u64 = 440001;


  /// A MultiSig account is an account which requires multiple votes from Authorities to send a transaction.
  struct MultiSig has key {
    signers: vector<address>,
    n: u64,
    m: u64,
    pending: vector<ProposedTransaction>,
    approved: vector<ProposedTransaction>,
    rejected:  vector<ProposedTransaction>,
  }


  /// This is the data structure which tracks the authorities and the votes for a given transaction.

  struct ProposedTransaction has key, store {
    // The transaction to be executed
    destination: address,
    // The votes received
    votes: vector<address>,
    // The expiration time for the transaction
    expiration_epoch: u64,
    // approved
    approved: bool,
  }

  struct GovSigner {
    new_signers: vector<address>,
    votes: vector<address>,
    approved: bool,
  }

  struct GovThreshold {
    n: u64,
    m: u64,
    votes: vector<address>,
    approved: bool,
  }

  struct Governance {
    // propose new signer
    propose_signers: Option<GovSigner>,
    // remove signer
    remove_signers: Option<GovSigner>,
    // change threshold
    change_threshold: Option<GovThreshold>,
  }


  /// An initial "sponsor" who is the signer of the initialization account calls this function.
  // This function creates the data structures, but also IMPORTANTLY it rotates the AuthKey of the account to a system-wide unusuable key (b"brick_all_your_base_are_belong_to_us").
  public fun init_and_brick(
    sig: &signer,
    m_seed_authorities: vector<address>,
    n_required_sigs: u64
  ) {

    // make sure the signer's address is not in the list of authorities. 
    // This account's signer will now be useless.

    let sender_addr = Signer::address_of(sig);
    assert!(!Vector::contains(&m_seed_authorities, &sender_addr), Errors::invalid_argument(ESIGNER_CANT_BE_AUTHORITY));

    move_to(sig, MultiSig {
      signers: copy m_seed_authorities,
      n: n_required_sigs,
      m: Vector::length(&m_seed_authorities),
      pending: Vector::empty(),
      approved: Vector::empty(),
      rejected: Vector::empty(),
    });

    DiemAccount::brick_this(sig, true);


  }

}
}