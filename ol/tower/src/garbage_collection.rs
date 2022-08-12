//! garbage collection

use crate::{next_proof, proof};
use anyhow::bail;
use cli::diem_client::DiemClient;
use diem_crypto::HashValue;
use ol::config::AppCfg;
use std::{fs, path::PathBuf, time::SystemTime};

/// Start the GC for a proof that is known bad
pub fn gc_failed_proof(cfg: &AppCfg, bad_proof_path: PathBuf) -> anyhow::Result<()> {
    println!(
        "bad proof found at {}. Will collect subsequent proofs and move to vdf proof archive",
        bad_proof_path.to_str().unwrap()
    );
    if let Some(v) = collect_subsequent_proofs(bad_proof_path, cfg.get_block_dir())? {
        put_in_trash(v, cfg)?;
    }
    Ok(())
}

/// collect all the proofs after a given height, inclusive of the given height
pub fn collect_subsequent_proofs(
    bad_proof_path: PathBuf,
    block_dir: PathBuf,
) -> anyhow::Result<Option<Vec<PathBuf>>> {
    let bad_proof = proof::parse_block_file(&bad_proof_path, true)?;

    let highest_local = proof::get_highest_block(&block_dir)?.0.height;

    // something is wrong with file list
    if highest_local < bad_proof.height {
        bail!("highest local proof is lower than bad proof, looks like a filename and height don't match for: {}", &bad_proof_path.to_str().unwrap())
    };
    // check if the next proof nonce that the chain expects has already been mined.
    let mut vec_trash: Vec<PathBuf> = vec![];
    let mut i = bad_proof.height;
    while i < highest_local {
        let (_, file) = proof::find_proof_number(i, &block_dir)?;
        vec_trash.push(file);
        i += 1;
    }
    Ok(Some(vec_trash))
}

/// take list of proofs and save in garbage file
pub fn put_in_trash(to_trash: Vec<PathBuf>, cfg: &AppCfg) -> anyhow::Result<()> {
    let vdf_path: PathBuf = cfg.workspace.block_dir.parse()?;
    let now = SystemTime::now().duration_since(SystemTime::UNIX_EPOCH)?;
    let new_dir = vdf_path.join(now.as_secs().to_string());
    fs::create_dir_all(&new_dir)?;

    println!(
        "placing {} files in trash at {}",
        to_trash.len(),
        new_dir.to_str().unwrap()
    );

    to_trash.into_iter().for_each(|f| {
        fs::copy(&f, &new_dir).unwrap();
        fs::remove_file(&f).unwrap();
    });

    Ok(())
}

/// check remaining proofs in backlog.
/// if they all fail, move the list to a trash file
pub fn find_first_discontinous_proof(
    cfg: AppCfg,
    client: DiemClient,
    swarm_path: Option<PathBuf>,
) -> anyhow::Result<Option<PathBuf>> {
    let block_dir = cfg.get_block_dir();
    let highest_local = proof::get_highest_block(&block_dir)?.0.height;
    // start from last known proof on chain.
    let p = next_proof::get_next_proof_from_chain(&mut cfg.clone(), client, swarm_path)?;

    if highest_local < p.next_height {
        return Ok(None);
    };
    // check if the next proof nonce that the chain expects has already been mined.

    let mut i = p.next_height;
    let mut preimage = p.preimage;
    while i < highest_local {
        let (proof, file) = proof::find_proof_number(i, &block_dir)?;
        let next_preimage = HashValue::sha3_256_of(&proof.proof).to_vec();
        if preimage != next_preimage {
            return Ok(Some(file));
        }
        preimage = next_preimage;

        i += 1;
    }

    Ok(None)
}
