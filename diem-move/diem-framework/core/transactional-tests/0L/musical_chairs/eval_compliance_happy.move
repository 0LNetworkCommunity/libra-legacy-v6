//# init --validators Alice Bob Carol Dave Eve

// This tests consensus Case 1.
// ALICE is a validator, validated successfully
// put in the lowest bid, but there are enough seats to include her.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Mock;
    use DiemFramework::MusicalChairs;
    // use DiemFramework::Debug::print;
    use Std::FixedPoint32;
    use Std::Vector;

    fun main(dr:signer, _sender: signer) {
      // all vals compliant
      Mock::all_good_validators(&dr);

      let (good, bad, ratio) = MusicalChairs::eval_compliance(&dr, 0, 15);
      assert!(Vector::length(&good) == 5, 1001);
      assert!(Vector::length(&bad) == 0, 1002);
      assert!(FixedPoint32::is_zero(ratio), 1003);


      let (_outgoing_compliant_set, _new_set_size) = MusicalChairs::stop_the_music(&dr, 0, 15);

      //print(&outgoing_compliant_set);
      //print(&new_set_size);
      assert!(MusicalChairs::get_current_seats() == 11, 1004)
    }
}
