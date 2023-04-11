//# init --validators Alice

// Test algebra 1 skills

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TurnoutTally;
    use DiemFramework::Debug::print;

    fun main(_root: signer, _sig: signer) {   
      
      // confirm upperbound
      let y = TurnoutTally::get_threshold_from_turnout(8750, 10000);
      assert!(y == 5100, 0);

      // confirm lowerbound
      let y = TurnoutTally::get_threshold_from_turnout(1250, 10000);
      print(&y);
      assert!(y == 10000, 0);

      let y = TurnoutTally::get_threshold_from_turnout(1500, 10000);
      print(&y);
      assert!(y == 9837, 0);

      let y = TurnoutTally::get_threshold_from_turnout(5000, 10000);
      print(&y);
      assert!(y == 7550, 0);    

      let y = TurnoutTally::get_threshold_from_turnout(7500, 10000);
      print(&y);
      assert!(y == 5917, 0); 

      // cannot be below the minimum treshold. I.e. more than 100%
      let y = TurnoutTally::get_threshold_from_turnout(500, 10000);
      print(&y);
      assert!(y == 10000, 0); 

      // same for maximum. More votes cannot go below 51% approval
      let y = TurnoutTally::get_threshold_from_turnout(9000, 10000);
      print(&y);
      assert!(y == 5100, 0); 
  }
}
// check: EXECUTED
