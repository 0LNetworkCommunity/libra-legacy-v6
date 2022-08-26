//# init --validators Alice Bob Carol Dave Eve Frank Gertie

// Testing if EVE a CASE 3 Validator gets dropped.

// ALICE is CASE 1
// BOB is CASE 1
// CAROL is CASE 1
// DAVE is CASE 1
// EVE is CASE 3
// FRANK is CASE 1
// GERTIE is CASE 1

//# block --proposer Alice --time 1 --round 0

// NewBlockEvent

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use Std::Vector;
    use DiemFramework::NodeWeight;
    use DiemFramework::Jail;
    use DiemFramework::Debug::print;

    fun main(_: signer, vm: signer) {
      let sorted_val_universe = NodeWeight::get_sorted_vals();
      print(&sorted_val_universe);
      let (_is_found, idx) = Vector::index_of(&sorted_val_universe, &@Eve);
      

      print(&idx);

      assert!(idx == 2, 735701);

      let jail_sort = Jail::sort_by_jail(*&sorted_val_universe);
      let (_is_found, idx) = Vector::index_of(&jail_sort, &@Eve);
      print(&idx);

      Jail::jail(&vm, @Eve);
      assert!(Jail::is_jailed(@Eve), 7357003);

      let jail_sort = Jail::sort_by_jail(*&sorted_val_universe);
      print(&jail_sort);
      print(&@Eve);

      let (_is_found, idx) = Vector::index_of(&jail_sort, &@Eve);
      print(&idx);
      assert!(idx == 6, 735705);

      // jail Alice 2x and she will fall to bottom of list
      Jail::jail(&vm, @Alice);
      Jail::jail(&vm, @Alice);

      let jail_sort = Jail::sort_by_jail(*&sorted_val_universe);
      let (_is_found, idx) = Vector::index_of(&jail_sort, &@Eve);
      print(&idx);
      assert!(idx == 5, 735706);
      let (_is_found, idx) = Vector::index_of(&jail_sort, &@Alice);
      print(&idx);
      assert!(idx == 6, 735707);

      Jail::remove_consecutive_fail(&vm, @Eve);
      Jail::remove_consecutive_fail(&vm, @Alice);

      // back to previous sort
      let jail_sort = Jail::sort_by_jail(*&sorted_val_universe);
      print(&jail_sort);
      let (_is_found, idx) = Vector::index_of(&jail_sort, &@Eve);
      print(&idx);
      assert!(idx == 2, 735708);
    }
}