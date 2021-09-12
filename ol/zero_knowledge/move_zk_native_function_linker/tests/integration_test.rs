#[test]
fn test_basic_true() {
	let name = String::from("A");

	let (proof, proof_params, cairo_aux, task_meta_data, fact) = zero_knowledge::prove_and_verify::prove(name, 11);

    let success = zero_knowledge::prove_and_verify::verify(&proof, &proof_params, &cairo_aux, &task_meta_data, &fact);

	assert_eq!(success, true);
}