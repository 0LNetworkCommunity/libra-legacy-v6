/////// 0L /////////

use diem_transactional_test_harness::run_test;

datatest_stable::harness!(run_test, "core/transactional-tests/0L", r".*\.(mvir|move)$");