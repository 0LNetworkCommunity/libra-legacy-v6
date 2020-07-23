// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

script {
    use 0x0::LibraBlock;
    fun main<Token>() {
        LibraBlock::get_current_block_height();
        LibraBlock::get_previous_voters();
    }
}
