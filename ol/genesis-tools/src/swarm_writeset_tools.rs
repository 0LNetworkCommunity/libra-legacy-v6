//! collection of writeset tools


/// take an archive file path and parse into a writeset
pub async fn archive_into_swarm_writeset(archive_path: PathBuf) -> Result<WriteSetMut, Error> {
    let backup = read_snapshot::read_from_json(&archive_path)?;
    let account_blobs = accounts_from_snapshot_backup(backup, &archive_path).await?;
    accounts_into_writeset_swarm(&account_blobs)
}

/// make the writeset for the genesis case. Starts with an unmodified account state and make into a writeset.
fn accounts_into_writeset_swarm(
    account_state_blobs: &Vec<AccountStateBlob>,
) -> Result<WriteSetMut, Error> {
    let mut write_set_mut = WriteSetMut::new(vec![]);
    for blob in account_state_blobs {
        let account_state = AccountState::try_from(blob)?;
        // TODO: borrow
        let clean = get_unmodified_writeset(&account_state)?;
        let auth = authkey_rotate_change_item(&account_state, get_alice_authkey_for_swarm())?;
        let merge_clean = merge_writeset(write_set_mut, clean)?;
        write_set_mut = merge_writeset(merge_clean, auth)?;
    }
    println!("Total accounts read: {}", &account_state_blobs.len());

    Ok(write_set_mut)
}

/// Without modifying the data convert an AccountState struct, into a WriteSet Item which can be included in a genesis transaction. This should take all of the resources in the account.
fn get_unmodified_writeset(account_state: &AccountState) -> Result<WriteSetMut, Error> {
    let mut ws = WriteSetMut::new(vec![]);
    if let Some(address) = account_state.get_account_address()? {
        // iterate over all the account's resources\
        for (k, v) in account_state.iter() {
            let item_tuple = (
                AccessPath::new(address, k.clone()),
                WriteOp::Value(v.clone()),
            );
            // push into the writeset
            ws.push(item_tuple);
        }
        println!("processed account: {:?}", address);

        return Ok(ws);
    }

    bail!("ERROR: No address for AccountState: {:?}", account_state);
}


/// Returns the writeset item for replaceing an authkey on an account. This is only to be used in testing and simulation.
fn authkey_rotate_change_item(
    account_state: &AccountState,
    authentication_key: Vec<u8>,
) -> Result<WriteSetMut, Error> {
    let mut ws = WriteSetMut::new(vec![]);

    if let Some(address) = account_state.get_account_address()? {
        // iterate over all the account's resources
        for (k, _v) in account_state.iter() {
            // if we find an AccountResource struc, which is where authkeys are kept
            if k.clone() == AccountResource::resource_path() {
                // let account_resource_option = account_state.get_account_resource()?;
                if let Some(account_resource) = account_state.get_account_resource()? {
                    let ar = account_resource.rotate_auth_key(authentication_key.clone());

                    ws.push((
                        AccessPath::new(address, k.clone()),
                        WriteOp::Value(bcs::to_bytes(&ar).unwrap()),
                    ));
                }
            }
        }
        println!("rotate authkey for account: {:?}", address);
    }
    bail!(
        "ERROR: No address found at AccountState: {:?}",
        account_state
    );
}


fn get_alice_authkey_for_swarm() -> Vec<u8> {
    let mnemonic_string = fixtures::get_persona_mnem("alice");
    let account_details = get_account_from_mnem(mnemonic_string).unwrap();
    account_details.0.to_vec()
}

