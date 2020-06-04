//! OlMiner delay module



// #[derive(Command, Debug, Options)]
// pub struct StartCmd {
//     /// To whom are we saying hello?
//     #[options(free)]
//     recipient: Vec<String>,
// }

// use vdf::{InvalidProof, PietrzakVDFParams, VDFParams, WesolowskiVDFParams, VDF};


pub mod delay {
    //use crate::prelude::*;
    // use crate::config::OlMinerConfig;
    use abscissa_core::{config, Command, FrameworkError, Options, Runnable};
    use vdf::{VDFParams, WesolowskiVDFParams, PietrzakVDFParams, VDF};

    pub fn do_delay() -> Vec<u8>{

        println!("Running the delay");

        let int_size_bits = 2048;
        let vdf = vdf::WesolowskiVDFParams(int_size_bits).new();
        let vdf:Box<dyn vdf::VDF> = Box::new(vdf::WesolowskiVDFParams(int_size_bits).new());

        let proof = vdf
        .solve(b"\xaa", 1000)
        .expect("iterations should have been validated earlier");

        println!("weso proof:\n{}", hex::encode(&proof));

        return proof
    }

}
