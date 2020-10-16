// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

script {
use 0x1::LibraBlock;
// use 0x0::Debug;

    fun ol_tx_fees_e2e_test_helper<Currency>() {
        let _round = LibraBlock::get_current_block_height();
        // Debug::print(&0x7E5700003);
        // Debug::print(&round);

        let _voters = LibraBlock::get_previous_voters();
        // Debug::print(&0x7E5700004);
        // Debug::print(&voters);
    }
}
