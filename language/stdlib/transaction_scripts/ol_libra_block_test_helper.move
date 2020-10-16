// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

script {
    use 0x1::LibraBlock;
    fun ol_libra_block_test_helper<Currency>() {
        LibraBlock::get_current_block_height();
        LibraBlock::get_previous_voters();
    }
}
