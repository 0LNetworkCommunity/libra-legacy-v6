// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

pub mod error_explain;
pub mod stdlib;

// /////// 0L /////////
// #[cfg(target_family = "unix")]
// pub mod stdlib;
// #[cfg(target_family = "windows")]
// pub mod ol_stdlib_win;

// #[cfg(target_family = "windows")]
// pub use ol_stdlib_win as stdlib;