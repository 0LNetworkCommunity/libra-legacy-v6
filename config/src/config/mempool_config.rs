// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(default)]
pub struct MempoolConfig {
    pub capacity: usize,
    pub capacity_per_user: usize,
    // number of failovers to broadcast to when the primary network is alive
    pub default_failovers: usize,
    pub max_broadcasts_per_peer: usize,
    pub mempool_snapshot_interval_secs: u64,
    pub shared_mempool_ack_timeout_ms: u64,
    pub shared_mempool_backoff_interval_ms: u64,
    pub shared_mempool_batch_size: usize,
    pub shared_mempool_max_concurrent_inbound_syncs: usize,
    pub shared_mempool_tick_interval_ms: u64,
    pub system_transaction_timeout_secs: u64,
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
