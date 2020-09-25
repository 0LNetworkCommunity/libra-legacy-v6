// This test is to check if two epoch triggers succesfully happen.
// Here EPOCH-LENGTH = 15 Blocks.
// NOTE: This test will fail in test-net and Production, only for Debug - due to epoch length.

//! account: alice, 1000000, 0, validator
//! account: vivian, 1000000, 0, validator
//! account: shasha, 1000000, 0, validator
//! account: charles, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

//! block-prologue
//! proposer: vivian
//! block-time: 1
//! NewBlockEvent

//! block-prologue
//! proposer: vivian
//! block-time: 2

//! block-prologue
//! proposer: vivian
//! block-time: 3

//! block-prologue
//! proposer: vivian
//! block-time: 4

//! block-prologue
//! proposer: vivian
//! block-time: 5

//! block-prologue
//! proposer: vivian
//! block-time: 6

//! block-prologue
//! proposer: vivian
//! block-time: 7

//! block-prologue
//! proposer: vivian
//! block-time: 8

//! block-prologue
//! proposer: vivian
//! block-time: 9

//! block-prologue
//! proposer: vivian
//! block-time: 10

//! block-prologue
//! proposer: vivian
//! block-time: 11

//! block-prologue
//! proposer: vivian
//! block-time: 12

//! block-prologue
//! proposer: vivian
//! block-time: 13

//! block-prologue
//! proposer: vivian
//! block-time: 14

//! block-prologue
//! proposer: vivian
//! block-time: 15
//! round: 15

// check: NewEpochEvent

//! block-prologue
//! proposer: vivian
//! block-time: 16
//! NewBlockEvent

//! block-prologue
//! proposer: vivian
//! block-time: 17

//! block-prologue
//! proposer: vivian
//! block-time: 18

//! block-prologue
//! proposer: vivian
//! block-time: 19

//! block-prologue
//! proposer: vivian
//! block-time: 20

//! block-prologue
//! proposer: vivian
//! block-time: 21

//! block-prologue
//! proposer: vivian
//! block-time: 22

//! block-prologue
//! proposer: vivian
//! block-time: 23

//! block-prologue
//! proposer: vivian
//! block-time: 24

//! block-prologue
//! proposer: vivian
//! block-time: 25

//! block-prologue
//! proposer: vivian
//! block-time: 26

//! block-prologue
//! proposer: vivian
//! block-time: 27

//! block-prologue
//! proposer: vivian
//! block-time: 28

//! block-prologue
//! proposer: vivian
//! block-time: 29

//! block-prologue
//! proposer: vivian
//! block-time: 30
//! round: 15

// check: NewEpochEvent
