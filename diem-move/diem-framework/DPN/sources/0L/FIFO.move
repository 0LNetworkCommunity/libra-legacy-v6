/////////////////////////////////////////////////////////////////////////
// 0L Module
// Efficient FIFO Implementation
// Error code for File: 0320
/////////////////////////////////////////////////////////////////////////

address DiemFramework {

/// # Summary
/// Implementation of a FIFO that utilizes two vectors
/// Achieves Amortized O(1) cost per operation 
/// CAUTION: In worst case this can result in O(n) cost, adjust gas allowance accordingly 
module FIFO {
    use Std::Vector;
    use Std::Errors;

    const ACCESSING_EMPTY_FIFO: u64 = 032001;

    /// FIFO implemented using two LIFO vectors 
    /// incoming accepts all pushes (added to the end)
    /// when pop is requested, if outgoing is non-empty, element is popped from the end
    /// if outgoing is empty, all elements are popped from the 
    /// end of incoming and pushed to outoing
    /// result is a FIFO
    struct FIFO<Element> has store, drop {
        incoming: vector<Element>,
        outgoing: vector<Element>
    }

    /// Create an empty FIFO of some type 
    public fun empty<Element>(): FIFO<Element>{
        let incoming = Vector::empty<Element>();
        let outgoing = Vector::empty<Element>();
        FIFO {
            incoming: incoming,
            outgoing: outgoing,
        }
    }

    /// push an element to the FIFO
    public fun push<Element>(v: &mut FIFO<Element>, new_item: Element){
        Vector::push_back<Element>(&mut v.incoming, new_item);
    }

    /// push an element to the end of the FIFO (so it will be popped first) 
    /// useful if you need to give priority to some element
    public fun push_LIFO<Element>(v: &mut FIFO<Element>, new_item: Element){
        Vector::push_back<Element>(&mut v.outgoing, new_item);
    }

    /// grab the next element from the queue, removing it
    public fun pop<Element>(v: &mut FIFO<Element>): Element{
        perform_swap<Element>(v);
        //now pop from the outgoing queue
        Vector::pop_back<Element>(&mut v.outgoing)
    }

    /// return a ref to the next element in the queue, without removing it 
    public fun peek<Element>(v: &mut FIFO<Element>): & Element{
        perform_swap<Element>(v);

        let len = Vector::length<Element>(& v.outgoing);
        Vector::borrow<Element>(& v.outgoing, len - 1)
    }

    /// return a mutable ref to the next element in the queue, without removing it 
    public fun peek_mut<Element>(v: &mut FIFO<Element>): &mut Element{
        perform_swap<Element>(v);

        let len = Vector::length<Element>(& v.outgoing);
        Vector::borrow_mut<Element>(&mut v.outgoing, len - 1)
    }

    /// get the number of elements in the queue
    public fun len<Element>(v: & FIFO<Element>): u64{
        Vector::length<Element>(& v.outgoing) + Vector::length<Element>(& v.incoming)
    }

    /// internal function, used when peeking and/or popping to move elements 
    /// from the incoming queue to the outgoing queue. Only performs this  
    /// action if the outgoing queue is empty. 
    fun perform_swap<Element>(v: &mut FIFO<Element>) {
        if (Vector::length<Element>(& v.outgoing) == 0) {
            let len = Vector::length<Element>(&v.incoming);
            assert!(len > 0, Errors::invalid_state(ACCESSING_EMPTY_FIFO));
            //If outgoing is empty, pop all of incoming into outgoing
            while (len > 0) {
                Vector::push_back<Element>(&mut v.outgoing, 
                    Vector::pop_back<Element>(&mut v.incoming));
                len = len - 1;
            }
        };
    }

}
}