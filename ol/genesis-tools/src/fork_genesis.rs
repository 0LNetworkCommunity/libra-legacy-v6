//! genesis-wrapper

use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

use crate::read_archive::{archive_into_recovery, merge_writeset};
use crate::recover::{AccountRole, LegacyRecovery, RecoverConsensusAccounts, recover_consensus_accounts};
use anyhow::Error;
use libra_types::access_path::AccessPath;
use libra_types::account_address::AccountAddress;
use libra_types::account_config::BalanceResource;
use libra_types::transaction::{ChangeSet, Transaction, WriteSetPayload};
use libra_types::write_set::{WriteOp, WriteSetMut};
use move_core_types::move_resource::MoveResource;
use ol_types::community_wallet::{CommunityWalletsResource, SlowWalletResource};
use ol_types::fullnode_counter::FullnodeCounterResource;
use ol_types::miner_state::MinerStateResource;
use vm_genesis::encode_recovery_genesis_changeset;

/// Make a recovery genesis blob
pub async fn make_recovery_genesis(
  genesis_blob_path: PathBuf,
  archive_path: PathBuf,
  append: bool,
) -> Result<(), Error> {
  // get the legacy data from archive
  let legacy = archive_into_recovery(&archive_path).await?;
  // get consensus accounts
  let genesis_accounts = recover_consensus_accounts(&legacy)?;
  // create baseline genesis

  // TODO: for testing letting all validators be in genesis set.
  let validator_set: Vec<AccountAddress> = genesis_accounts.vals.clone()
      .into_iter()
      .map(|a|{
        return a.val_account
      })
      .collect();
  let cs = get_baseline_genesis_change_set(genesis_accounts, &validator_set)?;
  let gen_tx;
  if append {
    // append further writeset to genesis
    gen_tx = append_genesis(cs, legacy)?;
  } else {
    gen_tx = Transaction::GenesisTransaction(
      WriteSetPayload::Direct(cs)
    );

  }
  // save genesis
  // dbg!(&gen_tx);
  save_genesis(gen_tx, genesis_blob_path)
}

/// Get the minimal viable genesis from consensus accounts.
pub fn get_baseline_genesis_change_set(
    genesis_accounts: RecoverConsensusAccounts,
    validator_set: &[AccountAddress],
) -> Result<ChangeSet, Error> {
    encode_recovery_genesis_changeset(
        &genesis_accounts.vals,
        &genesis_accounts.opers,
        &validator_set,
        1, // mainnet
    )
}

/// make the recovery genesis transaction, and file
pub fn append_genesis(
    gen_cs: ChangeSet,
    legacy_vec: Vec<LegacyRecovery>,
) -> Result<Transaction, Error> {
    // merge writesets
    let mut all_writesets = gen_cs.write_set().to_owned().into_mut();
    for l in legacy_vec {
        let ws = migrate_account(l)?;
        all_writesets = merge_writeset(all_writesets, ws)?;
    }

    let all_changes = ChangeSet::new(all_writesets.freeze().unwrap(), gen_cs.events().to_owned());
    Ok(Transaction::GenesisTransaction(WriteSetPayload::Direct(
        all_changes,
    )))
}
/// make the recovery genesis transaction, and file
pub fn migrate_account(legacy: LegacyRecovery) -> Result<WriteSetMut, Error> {
    let mut write_set_mut = WriteSetMut::new(vec![]);

    // add writesets, for recovering e.g. user accounts, balance, miner state, or application state

    // TODO: Restore Balance and Total Supply
    // legacy.balance
    // TODO: Change legacy names
    // NOTE: this is only needed from Libra -> Diem renames
    if let Some(bal) = legacy.balance {
      let new = BalanceResource::new(bal.coin());
      write_set_mut.push((
          AccessPath::new(legacy.account, BalanceResource::resource_path()),
          WriteOp::Value(lcs::to_bytes(&new).unwrap()),
      ));
    }

    // Restore Miner State

    if let Some(m) = legacy.miner_state {
      let new = MinerStateResource {
        previous_proof_hash: m.previous_proof_hash,
        verified_tower_height: m.verified_tower_height,
        latest_epoch_mining: m.latest_epoch_mining,
        count_proofs_in_epoch: m.count_proofs_in_epoch,
        epochs_validating_and_mining: m.epochs_validating_and_mining,
        contiguous_epochs_validating_and_mining: m.contiguous_epochs_validating_and_mining,
        epochs_since_last_account_creation: m.epochs_since_last_account_creation,
    };
      write_set_mut.push((
          AccessPath::new(legacy.account, MinerStateResource::resource_path()),
          WriteOp::Value(lcs::to_bytes(&new).unwrap()),
      ));
    }

    // TODO: Restore WalletType
    if legacy.role != AccountRole::System {
        let new = SlowWalletResource {
            is_slow: true,
        };
        write_set_mut.push((
          AccessPath::new(legacy.account, SlowWalletResource::resource_path()),
          WriteOp::Value(lcs::to_bytes(&new).unwrap()),
      ));
    }

    // System state to recover.
    // Community Wallets
    if let Some(w) = legacy.comm_wallet {
      let new = CommunityWalletsResource {
        list: w.list,
    };
      write_set_mut.push((
          AccessPath::new(legacy.account, CommunityWalletsResource::resource_path()),
          WriteOp::Value(lcs::to_bytes(&new).unwrap()),
      ));
    }

    // fullnode counter
    if let Some(f) = legacy.fullnode_counter {
      let new = FullnodeCounterResource {
        proofs_submitted_in_epoch: f.proofs_submitted_in_epoch,
        proofs_paid_in_epoch: f.proofs_paid_in_epoch,
        subsidy_in_epoch: f.subsidy_in_epoch,
        cumulative_proofs_submitted: f.cumulative_proofs_submitted,
        cumulative_proofs_paid: f.cumulative_proofs_paid,
        cumulative_subsidy: f.cumulative_subsidy,
    };
      write_set_mut.push((
          AccessPath::new(legacy.account, FullnodeCounterResource::resource_path()),
          WriteOp::Value(lcs::to_bytes(&new).unwrap()),
      ));
    }

    // make the genesis transaction
    Ok(write_set_mut)
}

/// save the genesis blob
pub fn save_genesis(gen_tx: Transaction, output_path: PathBuf) -> Result<(), Error> {
    let mut file = File::create(output_path)?;
    let bytes = lcs::to_bytes(&gen_tx)?;
    file.write_all(&bytes)?;
    Ok(())
}
