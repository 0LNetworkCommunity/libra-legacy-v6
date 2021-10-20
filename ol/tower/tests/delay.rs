//! Functional test for delay module

#![forbid(unsafe_code)]
use tower::delay;

#[test]
fn test_do_delay() {
    // use a test pre image and a 100 difficulty
    let proof = delay::do_delay(b"test preimage", 100, 512).unwrap();

    // print to copy/paste the correct_proof string below.
    println!("proof:\n{:?}", hex::encode(&proof));

    let correct_proof = hex::decode("002f63432872f9b339dd11d99ca2daf0ba821e74518e5acb28e10b12e8b407b9100003f82bd810b783506506ebc356032f9049d709f64433bb583980becde172ef39").unwrap();

    assert_eq!(proof, correct_proof, "proof is incorrect");
}
