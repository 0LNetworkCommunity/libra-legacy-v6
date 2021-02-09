//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

//! new-transaction
script{
use 0x1::ZKP;
use 0x1::TestFixtures;    

fun main() {
  let proof_hex = TestFixtures::valid_proof_hex();
  let public_input_json = TestFixtures::invalid_public_input_json();
  let parameters_json = TestFixtures::parameters_json();
  let annotation_file_name = TestFixtures::annotation_file_name();

  assert(
    ZKP::verify(&proof_hex, 
                &public_input_json, 
                &parameters_json,
                &annotation_file_name
    ) == false, 1
  );
}
}