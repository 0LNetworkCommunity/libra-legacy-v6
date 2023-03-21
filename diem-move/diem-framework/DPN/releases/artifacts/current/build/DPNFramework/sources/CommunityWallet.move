
///////////////////////////////////////////////////////////////////
// 0L Module
// CommunityWallet
///////////////////////////////////////////////////////////////////


address DiemFramework {

/// This module is used to dynamically check if an account qualifies for the CommunityWallet flag.

/// Community Wallet is a flag that can be applied to an account.
/// These accounts are voluntarily creating a number of restrictions and guarantees for users that interact with it.
/// In essence, a group of people may set up a wallet with these characteristics to provide funding for a common program.

/// For example the matching donation game, which validators provide with burns from their account will check that a destination account has a Community Wallet Flag.

/// The CommunityWallets will have the following properties enabled by their owners.


/// 0. This wallet is initialized as a DonorDirected account. This means that it observes the policies of those accounts: namely, that the donors have Veto rights over the transactions which are proposed by the Owners of the account. Repeated rejections or an outright freeze poll, will prevent the Owners from transferring funds, and may ultimately revert the funds to a different community account (or burn).

/// !. They have instantiated a MultiSig controller, which means that actions on this wallet can only be done by an n-of-m consensus by the authorities of the account. Plus, the nominal credentials which created the account cannot be used, since the keys will no longer be valid.

/// 2. The Multisig account holders do not have common Ancestry. This is important to prevent an account holder from trivially creating sybil accounts to qualify as a community wallet. Sybils are possibly without common Ancestry, but it is much harder.

/// 3. The multisig account has a minimum of 5 Authorities, and a threshold of 3 signatures. If there are more authorities, a 3/5 ratio or more should be preserved.

module CommunityWallet{
    use DiemFramework::CoreAddresses;
    use Std::Vector;
    use Std::Signer;
    use Std::Errors;
    // use DiemFramework::DiemConfig;
    // use Std::Option::{Self,Option};
    // use DiemFramework::DiemSystem;
    // use DiemFramework::NodeWeight;
    use DiemFramework::DonorDirected;

    const ENOT_AUTHORIZED: u64 = 023;

    struct CommunityWalletList has key {
      list: vector<address>
    }


  public fun is_community_wallet() {

    // has DonorDirected instantiated

    // has MultiSigPayment instantiated

    // multisig has 3/5 threshold, and minimum 3 and 5.

    // the multisig authorities are unrelated per Ancestry

  }

  public fun is_frozen() {

  }

  public fun is_pending_liquidation() {

  }


      // Getter for retrieving the list of DonorDirected wallets.
    public fun get_comm_list(): vector<address> acquires CommunityWalletList{
      if (exists<CommunityWalletList>(@0x0)) {
        let s = borrow_global<CommunityWalletList>(@0x0);
        return *&s.list
      } else {
        return Vector::empty<address>()
      }
    }

    // getter to check if is a CommunityWallet
    public fun is_comm(addr: address): bool acquires CommunityWalletList{
      let s = borrow_global<CommunityWalletList>(@0x0);
      Vector::contains<address>(&s.list, &addr)
    }


        public fun new_timed_transfer(
      sender: &signer, payee: address, value: u64, description: vector<u8>
    ): u64 acquires CommunityWalletList {
      // firstly check if payee is a slow wallet
      // TODO: This function should check if the account is a slow wallet before sending
      // but there's a circular dependency with DiemAccount which has the slow wallet struct.
      // curretly we move that check to the transaction script to initialize the payment.
      // assert!(DiemAccount::is_slow(payee), EIS_NOT_SLOW_WALLET);

      let sender_addr = Signer::address_of(sender);
      let list = get_comm_list();
      assert!(
        Vector::contains<address>(&list, &sender_addr),
        Errors::requires_role(ENOT_AUTHORIZED)
      );

      DonorDirected::new_timed_transfer(sender, payee, value, description)
    }

  //////// TESTS ////////

        // Utility for vm to remove the CommunityWallet tag from an address
    public fun vm_remove_comm(vm: &signer, addr: address) acquires CommunityWalletList {
      CoreAddresses::assert_diem_root(vm);
      if (!exists<CommunityWalletList>(@0x0)) return;
     
      let list = get_comm_list();
      let (yes, i) = Vector::index_of<address>(&list, &addr);
      if (yes) {
        let s = borrow_global_mut<CommunityWalletList>(@0x0);
        Vector::remove(&mut s.list, i);
      }
    }
  
  
}
}