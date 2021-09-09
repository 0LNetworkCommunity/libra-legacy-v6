// ZK - Zero Knowldege
//TODO: Make Markdown Documentation
address 0x1 {
  module ZK {
      native public fun verify(
        name: vector<u8>,
        value: u128
      ): bool;
  }
}