//! `account`

use crate::node::node::Node;
use anyhow::{Error, Result};
use libra_json_rpc_client::{views::AccountView, AccountAddress};
use libra_types::{account_state::AccountState, transaction::Version};
use resource_viewer::{AnnotatedAccountStateBlob, MoveValueAnnotator, NullStateView};
use serde::{Deserialize, Serialize};
use std::convert::TryFrom;
use ol_types::autopay::{AutoPayResource, AutoPayView};

#[derive(Clone, Debug, Deserialize, Serialize)]
/// information on the owner account of this node.
pub struct OwnerAccountView {
    /// account address of this node
    address: AccountAddress,
    /// balance of this node
    balance: u64,
    /// if is jailed
    is_in_validator_set: bool,
    /// auto pay
    auto_pay: Option<AutoPayView>,
}

impl OwnerAccountView {
    /// create AccountCli
    pub fn new(address: AccountAddress) -> Self {
        OwnerAccountView {
            address,
            balance: 0,
            is_in_validator_set: false,
            auto_pay: None,
        }
    }

    /// query if account has auto pay settings, and not empty
    pub fn has_auto_pay_not_empty(&self) -> bool {
        match &self.auto_pay {
            Some(auto_pay) => auto_pay.payments.len() > 0,
            None => false
        }
    }
}

impl Node {
    /// fetch new account info
    pub fn refresh_account_info(&mut self) -> Option<&OwnerAccountView>{
        match self.get_account_view() {
            Some(av) => {
                self.vitals.account_view.balance = get_balance(av);
                self.vitals.account_view.is_in_validator_set = self.is_in_validator_set();
                self.vitals.account_view.auto_pay = self.get_auto_pay_view(self.vitals.account_view.address);
                Some(&self.vitals.account_view)
            }
            None => None
        }
    }

    /// Get the account view struct
    pub fn get_account_view(&mut self) -> Option<AccountView> {
        let account = self.app_conf.profile.account;
        match self.client.get_account(account, true) {
            Ok((account_view, _)) => account_view,
            Err(_) => None
        }
    }

    /// Get account auto pay resource
    pub fn get_auto_pay_view(&mut self, account: AccountAddress) -> Option<AutoPayView> {
        let state = self.get_account_state(account);
        match state {
            Ok(state) => match state.get_resource::<AutoPayResource>(
                AutoPayResource::resource_path().as_slice()
            ) {
                Ok(Some(res)) => Some(res.get_view()),
                Ok(None) => None,
                Err(_) => None
            }
            Err(_) => None
        }
    }

    /// Return a full Move-annotated account resource struct
    pub fn get_annotate_account_blob(
        &mut self,
        account: AccountAddress,
    ) -> Result<(Option<AnnotatedAccountStateBlob>, Version)> {
        let (blob, ver) = self.client.get_account_state_blob(account)?;
        if let Some(account_blob) = blob {
            let state_view = NullStateView::default();
            let annotator = MoveValueAnnotator::new(&state_view);
            let annotate_blob =
                annotator.view_account_state(&AccountState::try_from(&account_blob)?)?;
            Ok((Some(annotate_blob), ver))
        } else {
            Ok((None, ver))
        }
    }
    /// get any account state with client
    pub fn get_account_state(&mut self, address: AccountAddress) -> Result<AccountState, Error> {
        let (blob, _ver) = self.client.get_account_state_blob(address)?;
        if let Some(account_blob) = blob {
            Ok(AccountState::try_from(&account_blob).unwrap())
        } else {
            Err(Error::msg("connection to client"))
        }
    }
}

/// get balance from AccountView
pub fn get_balance(account_view: AccountView) -> u64 {
    for av in account_view.balances.iter() {
        if av.currency == "GAS" {
            return av.amount / 1_000_000; // with scaling factor for display
        }
    }
    0
}
