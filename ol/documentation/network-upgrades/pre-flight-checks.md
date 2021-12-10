Each Network upgrade is previously tested in Devnet (aka Rex net). The following features are the minimal pre-flight check that need to pass (in addition to the existing integration and upgrade tests in CI).

- [ ] ol: web monitor starts
- [ ] tower: miner tx submit
- [ ] ol: user account creation
- [ ] txs: set community wallet
- [ ] confirm autopay values
- [ ] txs: create end user account "eve"
- [ ] txs: eve submits miner proof
- [ ] epoch change
- [ ] txs: send stdlib upgrade tx
- [ ] second epoch change after upgrade vote
- [ ] stdlib upgrade
- [ ] txs: validator onboarding