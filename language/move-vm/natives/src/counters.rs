use diem_metrics::{
    register_histogram, register_int_counter, Histogram, IntCounter
};
use once_cell::sync::Lazy;

pub static MOVE_VM_NATIVE_VERIFY_VDF_LATENCY: Lazy<Histogram> = Lazy::new(|| {
    register_histogram!(
        "diem_move_vm_native_verify_vdf_latency",
        "Latency to verify a VDF challenge"
    )
        .unwrap()
});

pub static MOVE_VM_NATIVE_VERIFY_VDF_PROOF_COUNT: Lazy<IntCounter> = Lazy::new(|| {
    register_int_counter!("diem_move_vm_native_verify_vdf_proof_count", "Cumulative number of verified proofs").unwrap()
});

pub static MOVE_VM_NATIVE_VERIFY_VDF_PROOF_ERROR_COUNT: Lazy<IntCounter> = Lazy::new(|| {
    register_int_counter!("diem_move_vm_native_verify_vdf_proof_error_count", "Cumulative number of errors while verifying proofs").unwrap()
});
