//! `bal` subcommand

use cli::libra_client::LibraClient;
use libra_types::{account_address::AccountAddress, account_state::AccountState, transaction::Version};
use resource_viewer::{AnnotatedAccountStateBlob, MoveValueAnnotator, NullStateView};
use anyhow::Result;
use std::convert::TryFrom;

/// Return a full Move-annotated account resource struct
pub fn get_annotate_account_blob(
    mut client: LibraClient,
    address: AccountAddress,
) -> Result<(Option<AnnotatedAccountStateBlob>, Version)> {
    let (blob, ver) = client.get_account_state_blob(address)?;
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