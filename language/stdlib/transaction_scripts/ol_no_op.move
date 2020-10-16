// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

script {
    use 0x1::Debug;
    fun ol_no_op () {
        Debug::print(&0x000000000000000011e110);
    }
}
