//! account: alice, 1000000, 0, validator

//! new-transaction
module {{default}}::M {
    use 0x1::Event::{destroy_handle, emit_event, EventHandle, new_event_handle};
    use 0x1::Signer::address_of;

    struct MyEvent<T: copy + drop + store> has key {
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

//! new-transaction
//! sender: alice
script {
    use {{default}}::M;

    fun main(sender: signer) {
        M::emit(&sender);
    }
}
// check: EXECUTED
// check: ContractEvent
// check: Bool
