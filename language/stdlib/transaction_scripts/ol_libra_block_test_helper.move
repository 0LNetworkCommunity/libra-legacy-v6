// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

script {
use 0x0::LibraBlock;
use 0x0::Debug;

    fun main<Token>() {
        let round = LibraBlock::get_current_block_height();
        Debug::print(&0x7E5700003);
        Debug::print(&round);

        let voters = LibraBlock::get_previous_voters();
        Debug::print(&0x7E5700004);
        Debug::print(&voters);
    }
}
