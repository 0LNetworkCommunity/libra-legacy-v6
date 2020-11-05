fn submit_noop(mut config_path: PathBuf, height_to_submit: usize ) -> Result<String, Error> {

    config_path.push("../saved_logs/0/node.config.toml");

    let config = NodeConfig::load(&config_path)
        .unwrap_or_else(|_| panic!("Failed to load NodeConfig from file: {:?}", config_path));
    match &config.test {
        Some( conf) => {
            // println!("Swarm Keys : {:?}", conf);
        },
        None =>{
            // println!("test config does not set.");
        }
    }

    // Create a client object
    let mut client = LibraClient::new(
        Url::parse(format!("http://localhost:{}", config.rpc.address.port()).as_str()).unwrap(),
        config.base.waypoint.waypoint_from_config().unwrap().clone()
    ).unwrap();

    
    let mut private_key = config.test.unwrap().operator_keypair.unwrap();
    let auth_key = AuthenticationKey::ed25519(&private_key.public_key());

    let address = auth_key.derived_address();
    let account_state = client.get_account_state(address.clone(), true).unwrap();


    let mut sequence_number = 0u64;
    if account_state.0.is_some() {
        sequence_number = account_state.0.unwrap().sequence_number;
    }

    // Doing a no-op transaction here which will print
    // [debug] 000000000000000011e110  in the logs if successful.
    // NoOp => "ol_no_op.move",

    let script = Script::new(
        transaction_scripts::StdlibScript::NoOp.compiled_bytes().into_vec(),
        vec![],
        vec![
            // TransactionArgument::U8Vector(challenge),
            // TransactionArgument::U64(delay_difficulty()),
            // TransactionArgument::U8Vector(proof),
            // TransactionArgument::U64(tower_height as u64),
        ],
    );

    let keypair = KeyPair::from(private_key.take_private().clone().unwrap());

    let txn = create_user_txn(
        &keypair,
        TransactionPayload::Script(script),
        address,
        sequence_number,
        700_000,
        0,
        "GAS".parse()?,
        5_000_000, // for compatibility with UTC's timestamp.
    )?;

    // Plz Halp  (ZM):
    // get account_data struct
    let mut sender_account_data = AccountData {
        address,
        authentication_key: Some(auth_key.to_vec()),
        key_pair: Some(keypair),
        sequence_number,
        status: AccountStatus::Persisted,
    };

    // Submit the transaction with libra_client
    match client.submit_transaction(
        Some(&mut sender_account_data),
        txn
    ){
        Ok(_) => {
            ol_wait_for_tx(address, sequence_number, &mut client);
            Ok("Tx submitted".to_string())

        }
        Err(err) => Err(err)
    }

    // TODO (LG): Make synchronous to libra client.

    // Ok(())
    // Ok("Succcess".to_owned())
}
