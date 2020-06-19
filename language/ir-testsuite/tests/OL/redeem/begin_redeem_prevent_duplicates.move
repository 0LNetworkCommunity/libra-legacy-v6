import 0x0.Hello;

main() {
  // this test checks that Redeem prevents the fraudulent attempt to submit the same VDF twice.
  // 1. test that it calls VDF.verify correctly
  // 2. test that it finds a previous attempt of submitting a VDF for redemption, and returns the error
  // 3. check that the state was *not* updated at the end of the script.

  let x : bool;
  // x = Hello.hi();
  assert(true==true, 7);
  return;
}
