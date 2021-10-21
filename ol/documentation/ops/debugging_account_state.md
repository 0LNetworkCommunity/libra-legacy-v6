# Debugging Account state and balances

Use libra client with

```
cargo run --bin cli -- -u http://localhost:<port> --waypoint <waypoint>
```

Note the `auth_key` of the tower app in question.
Then in the libra shell:
```
query account_state <auth_key>
```

and you will see a result like this:

```
Latest account state is: 
 Account: (
    5942d356f114089d4a46f2f3b0b15b52,
    Some(
        AuthenticationKey(
            [
                23,
                150,
                130,
                76,
                220,
                195,
                171,
                32,
                92,
                37,
                242,
                96,
                225,
                93,
                198,
                112,
                89,
                66,
                211,
                86,
                241,
                20,
                8,
                157,
                74,
                70,
                242,
                243,
                176,
                177,
                91,
                82,
            ],
        ),
    ),
)
 State: Some(
    AccountView {
        balances: [
            AmountView {
                amount: 74,
                currency: "GAS",
            },
        ],
        sequence_number: 0,
        authentication_key: BytesView(
            "1796824cdcc3ab205c25f260e15dc6705942d356f114089d4a46f2f3b0b15b52",
        ),
        sent_events_key: BytesView(
            "01000000000000005942d356f114089d4a46f2f3b0b15b52",
        ),
        received_events_key: BytesView(
            "00000000000000005942d356f114089d4a46f2f3b0b15b52",
        ),
        delegated_key_rotation_capability: false,
        delegated_withdrawal_capability: false,
        role: Empty,
    },
)
 Blockchain Version: 11

```
