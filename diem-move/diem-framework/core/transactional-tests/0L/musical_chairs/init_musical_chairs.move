//# init --validators Alice Bob

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::MusicalChairs;
    fun main(_dr: signer, _sender: signer) {
        let a = MusicalChairs::get_current_seats();
        assert!(a == 0, 10001);
    }
}
//check: EXECUTED
