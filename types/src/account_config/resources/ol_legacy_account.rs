// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account_config::{KeyRotationCapabilityResource, WithdrawCapabilityResource},
    event::EventHandle,
};
use move_core_types::{
    ident_str,
    identifier::IdentStr,
    move_resource::{MoveResource, MoveStructType},
};
#[cfg(any(test, feature = "fuzzing"))]
use proptest_derive::Arbitrary;
use serde::{Deserialize, Serialize};

/// A Rust representation of an Account resource.
/// This is not how the Account is represented in the VM but it's a convenient representation.
#[derive(Debug, Serialize, Deserialize)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct OLLegacyAccountResource {
    authentication_key: Vec<u8>,
    withdrawal_capability: Option<WithdrawCapabilityResource>,
    key_rotation_capability: Option<KeyRotationCapabilityResource>,
    received_events: EventHandle,
    sent_events: EventHandle,
    sequence_number: u64,
}

impl OLLegacyAccountResource {
    /// Constructs an Account resource.
    pub fn new(
        sequence_number: u64,
        authentication_key: Vec<u8>,
        withdrawal_capability: Option<WithdrawCapabilityResource>,
        key_rotation_capability: Option<KeyRotationCapabilityResource>,
        sent_events: EventHandle,
        received_events: EventHandle,
    ) -> Self {
        OLLegacyAccountResource {
            authentication_key,
            withdrawal_capability,
            key_rotation_capability,
            received_events,
            sent_events,
            sequence_number,
        }
    }

    /// Return the sequence_number field for the given OLLegacyAccountResource
    pub fn sequence_number(&self) -> u64 {
        self.sequence_number
    }

    /// Returns if this account has delegated its withdrawal capability
    pub fn has_delegated_withdrawal_capability(&self) -> bool {
        self.withdrawal_capability.is_none()
    }

    /// Returns if this account has delegated its key rotation capability
    pub fn has_delegated_key_rotation_capability(&self) -> bool {
        self.key_rotation_capability.is_none()
    }

    /// Return the authentication_key field for the given OLLegacyAccountResource
    pub fn authentication_key(&self) -> &[u8] {
        &self.authentication_key
    }

    /// Return the sent_events handle for the given OLLegacyAccountResource
    pub fn sent_events(&self) -> &EventHandle {
        &self.sent_events
    }

    /// Return the received_events handle for the given OLLegacyAccountResource
    pub fn received_events(&self) -> &EventHandle {
        &self.received_events
    }

    //////// 0L /////////
    /// Replace the authkey in place
    pub fn rotate_auth_key(mut self, new_key: Vec<u8>) -> Self {
        self.authentication_key = new_key;
        OLLegacyAccountResource {
            authentication_key: self.authentication_key,
            withdrawal_capability: self.withdrawal_capability,
            key_rotation_capability: self.key_rotation_capability,
            received_events: self.received_events,
            sent_events: self.sent_events,
            sequence_number: self.sequence_number,
        }
    }
}

impl MoveStructType for OLLegacyAccountResource {
    const MODULE_NAME: &'static IdentStr = ident_str!("LibraAccount");
    const STRUCT_NAME: &'static IdentStr = ident_str!("LibraAccount");
}

impl MoveResource for OLLegacyAccountResource {}
