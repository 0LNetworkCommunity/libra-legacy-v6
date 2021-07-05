//! `account`

use crate::node::node::Node;
use anyhow::{Error, Result};
use libra_json_rpc_client::{views::{AccountView, EventView}, AccountAddress};
use libra_types::{account_state::AccountState, event::{EventHandle, EventKey}, transaction::Version};
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

    /// Get event handles associated with payments
    pub fn get_payment_event_handles(
        &mut self,
        account: AccountAddress,
    ) -> Result<Option<(EventHandle, EventHandle)>, Error> {
        match self.get_account_state(account) {
            Ok(account_state) => {
              let handles = account_state
              .get_account_resource()?
              .map(|resource| {
                (
                    resource.sent_events().clone(),
                    resource.received_events().clone(),
                )
              });
              Ok(handles)
            },
            Err(_) =>  Err(Error::msg("cannot get payment event handles"))
        }
    }

    /// Get events associated with an event handle's key
    pub fn get_events(
        &mut self,
        event_key: &EventKey,
        start: u64,
        limit: u64,
    ) -> Result<Vec<EventView>> {
        let key = hex::encode(event_key.as_bytes());
        
        self.client.get_events(key, start, limit)
    }

    /// get all events associated with an EventHandle
    // change this to async and do paging.
    pub fn get_handle_events(&mut self, event_handle: &EventHandle) -> Result<Vec<EventView>> {
        if event_handle.count() == 0 {
            return Ok(vec![]);
        }
        self.get_events(
          event_handle.key(), 
          0, 
          event_handle.count()
        )
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
