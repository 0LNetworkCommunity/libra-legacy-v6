use diem_metrics::{
    register_histogram, register_int_counter, register_int_counter_vec, Histogram, IntCounter,
    IntCounterVec,
};
use once_cell::sync::Lazy;

pub static MOVE_VM_NATIVE_VERIFY_VDF_LATENCY: Lazy<Histogram> = Lazy::new(|| {
    register_histogram!(
        "diem_move_vm_native_verify_vdf_latency",
        "Latency to verify a VDF challenge"
    )
        .unwrap()
});
