//# init --validators Alice

//# publish
module Alice::M {
    use DiemFramework::ParticipationVote;
    use DiemFramework::Debug::print;

    
    struct Vote has key {
      ballot: ParticipationVote::Ballot,
    }

    public fun do_it(sig: &signer) {
        // initialize this data on the address of the election contract
        ParticipationVote::test();
        let ballot = ParticipationVote::new(sig, b"please vote");
        print(&ballot);
        move_to(sig, Vote { ballot });
    }
}

//# run --admin-script --signers DiemRoot Alice --show-events
script {
    use Alice::M;

    fun main(_dr: signer, sender: signer) {
        M::do_it(&sender);
    }
}
