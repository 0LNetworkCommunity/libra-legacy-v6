import { invoke } from '@tauri-apps/api/tauri';
import { get, readable, writable } from 'svelte/store';
import { raise_error } from './carpeError';
import { responses } from './debug';
import { getCurrent } from '@tauri-apps/api/window'

const current_window = getCurrent();
export interface VDFProof {
  height: number,
  elapsed_secs: number,
  preimage: string,
  proof: string,
  difficulty: number,
  security: number
}

export interface TowerStateView {
  previous_proof_hash: string,
  verified_tower_height: number, // user's latest verified_tower_height
  latest_epoch_mining: number,
  count_proofs_in_epoch: number,
  epochs_validating_and_mining: number,
  contiguous_epochs_validating_and_mining: number,
  epochs_since_last_account_creation: number
}

export interface ClientTowerStatus {
  latest_proof: VDFProof,
  on_chain: TowerStateView,
  count_proofs_this_session: number,
}

export const tower = writable<ClientTowerStatus>({});
export const backlog_in_progress = writable(false);


export const towerOnce = async () => {
  console.log("mine tower once")

  // let previous_duration = 30 * 60 * 1000;
  let previous_duration = 5 * 1000; // for test net
  let t = get(tower);
  if (t.latest_proof && t.latest_proof.elapsed_secs) {
    previous_duration = t.latest_proof.elapsed_secs * 1000
  }

  let progress: ProofProgress = {
    time_start: Date.now(),
    previous_duration,
    complete: false,
    error: false,
  }
  proofState.set(progress);
  current_window.emit('tower-make-proof', 'Tauri is awesome!');

};

export const submitBacklog = async () => {
  backlog_in_progress.set(true);
  invoke("submit_backlog", {})
    .then((res) => {
      console.log("backlog response");
      console.log(res);
      responses.set(res as string);
      backlog_in_progress.set(false);
      return res
    })
    .catch((e) => {
      raise_error(e);
      backlog_in_progress.set(false);
    });
}

export const startTowerListener = async () => {
  await invoke("start_tower_listener", {})
    .then((res) => {
      console.log("tower listener response");
      console.log(res);
      responses.set(res as string);
      return res
    })
    .catch((e) => raise_error(e));
}


export const killTowerListener = async () => {
  console.log("kill listener");
  return current_window.emit("kill-listener")
}


function incrementMinerStatus(new_proof: VDFProof): ClientTowerStatus {
  let m = get(tower);
  m.latest_proof = new_proof;
  m.count_proofs_this_session = m.count_proofs_this_session + 1;
  tower.set(m);
  return m;
}

function refreshOnChainData(on_chain: TowerStateView): ClientTowerStatus {
  let m = get(tower);
  m.on_chain = on_chain;
  tower.set(m);
  return m;
}


export const getTowerChainView = async () => {
  invoke("get_onchain_tower_state", {})
    .then((res: TowerStateView) => {
      console.log(res);
      refreshOnChainData(res);
      responses.set(res);

    })
    .catch((e) => raise_error(e));
};


export const miner_loop_enabled = writable(false);

export async function enableMining(): Promise<boolean> {
  // careful to not start the miner twice.
  // the miner may be turned off, but a proof may still be running in the background.
  // if (isInProgress()) return false;

  // start the event listener on the rust side.
  // wait for it to be ready
  let started = await startTowerListener()
    .then((r) => {
      towerOnce()
      miner_loop_enabled.set(true);
      return true;
    })
    .catch(e => { return false })
  return started;
}

export async function disableMining(): Promise<boolean> {
  // stop the envent listener.

  await killTowerListener()
    .catch(e => {
      raise_error(e);
      return false
    });
  // set mining to disabled
  miner_loop_enabled.set(false);
  return true;
}

export function toggleMining() {
  let enabled = get(miner_loop_enabled)
  console.log("miner enabled?")
  console.log(get(miner_loop_enabled));
  if (enabled) {
    disableMining();
  } else {
    enableMining();
  };
  console.log("miner enabled?")
  console.log(get(miner_loop_enabled));
}

function isInProgress(): boolean {
  let ps = get(proofState);
  if (
    ps.time_start &&
    ps.time_start > 0 &&
    !ps.complete &&
    !ps.error
  ) {
    return true
  }
  return false;
}

export function proofError() {
  let ps = get(proofState);
  ps.error = true;
  proofState.set(ps);
}

export function proofComplete() {
  let ps = get(proofState);
  ps.complete = true;
  proofState.set(ps);
}
export interface ProofProgress {
  time_start: number,
  previous_duration: number,
  complete: boolean,
  error: boolean
}

export const proofState = writable<ProofProgress>({});

