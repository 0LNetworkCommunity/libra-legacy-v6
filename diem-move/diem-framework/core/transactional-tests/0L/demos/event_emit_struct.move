//# init --validators Alice

//# publish
module Alice::M {
    use Std::Event::{destroy_handle, emit_event, EventHandle, new_event_handle};
    use Std::Signer::address_of;

    struct MyEvent<phantom T: copy + drop + store> has key {
        e: EventHandle<T>
    }

    fun maybe_init_event<T: copy + drop + store>(sender: &signer) {
        if (exists<MyEvent<T>>(address_of(sender))) return;
        move_to(sender, MyEvent<T> { e: new_event_handle<T>(sender)})
    }

    public fun emit(sender: &signer) acquires MyEvent {
        maybe_init_event<bool>(sender);
        emit_event(&mut borrow_global_mut<MyEvent<bool>>(address_of(sender)).e, true);
        let MyEvent<bool> { e } = move_from<MyEvent<bool>>(address_of(sender));
        destroy_handle(e);
    }
}

//# run --admin-script --signers DiemRoot Alice --show-events
script {
    use Alice::M;

    fun main(sender: signer) {
        M::emit(&sender);
    }
}
// check: EXECUTED
// check: ContractEvent
// check: Bool