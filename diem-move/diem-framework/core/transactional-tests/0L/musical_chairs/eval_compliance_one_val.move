//# init --validators Alice Bob Carol Dave Eve

// This tests consensus Case 1.
// ALICE is a validator, validated successfully
// put in the lowest bid, but there are enough seats to include her.

//# block --proposer Alice --time 1 --round 0

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Mock;
    use DiemFramework::MusicalChairs;
    // use DiemFramework::Debug::print;
    use Std::FixedPoint32;
    use Std::Vector;

    fun main(dr:signer, _sender: signer) {
      // all vals compliant
      Mock::mock_case_1(&dr, @Alice, 0, 15);

      let (good, bad, bad_ratio) = MusicalChairs::eval_compliance(&dr, 0, 15);
      assert!(Vector::length(&good) == 1, 1001);
      assert!(Vector::length(&bad) == 4, 1002);
      assert!(FixedPoint32::create_from_rational(4, 5) == bad_ratio, 1003);


      let (_outgoing_compliant_set, _new_set_size) = MusicalChairs::stop_the_music(&dr, 0, 15);

      //print(&outgoing_compliant_set);
      //print(&new_set_size);
      assert!(MusicalChairs::get_current_seats() == 1, 1004)
    }
}
