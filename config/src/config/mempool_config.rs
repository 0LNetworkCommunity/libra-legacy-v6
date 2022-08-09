// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(default)]
pub struct MempoolConfig {
    // What is the total size of the mempool queue, including invalid txs. 
    pub capacity: usize,
    // How many txs can each user have in the mempool at a given time.
    pub capacity_per_user: usize,
    // a threshold for fullnodes to determine which peers to broadcast to.
    // peers which are go over this threshold, will receive broadcasts.
    // number of failovers to broadcast to when the primary network is alive
    pub default_failovers: usize,
    // number of times a mempool broadcast gets re-sent to a peer if
    // the previous was unacknowledged.
    pub max_broadcasts_per_peer: usize,
    // how often to snapshot the mempool for analytics purposes.
    pub mempool_snapshot_interval_secs: u64,
    // how long to wait for a peer after a broadcast was submitted,
    // before we mark it as unacknowledged.
    pub shared_mempool_ack_timeout_ms: u64,
    // if peer_manager is in backoff mode mempool/src/shared_mempool/peer_manager.rs
    // this is the base interval for backing off.
    pub shared_mempool_backoff_interval_ms: u64,

    // size of batch from mempool timeline to broadcast to peers.
    pub shared_mempool_batch_size: usize,
    // Number of workers to be spawned to receive inbound shared mempool broadcasts.
    pub shared_mempool_max_concurrent_inbound_syncs: usize,
    // the default interval to execute shared mempool broadcasts to peers.
    // this is overriden when peer is in backoff mode.
    pub shared_mempool_tick_interval_ms: u64,
    // when a transaction gets automatically garbage collected by system.
    // Different than user tx expiry which has separate GC
    pub system_transaction_timeout_secs: u64,
    // tick interval for system GC.
    pub system_transaction_gc_interval_ms: u64,
}

impl Default for MempoolConfig {
    fn default() -> MempoolConfig {
        MempoolConfig {
            shared_mempool_tick_interval_ms: 5_000, //////// 0L //////// 
            shared_mempool_backoff_interval_ms: 3_000, //////// 0L ////////
            shared_mempool_batch_size: 100,
            shared_mempool_ack_timeout_ms: 2_000,
            shared_mempool_max_concurrent_inbound_syncs: 2,
            max_broadcasts_per_peer: 5, //////// 0L ////////
            mempool_snapshot_interval_secs: 180,
            capacity: 1_000, ///////// 0L //////// Reduce size of mempool due to VDF cost.
            capacity_per_user: 1, // no reason for a given user to be ablet to submit more than tree txs to mempool.
            default_failovers: 3,
            system_transaction_timeout_secs: 1000, //////// 0L //////// transacitons should timeout under this time
            system_transaction_gc_interval_ms: 1000, /////// 0L //////// increase rate of GC
        }
    }
}
