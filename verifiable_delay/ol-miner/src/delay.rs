//! OlMiner delay module
#![forbid(unsafe_code)]

pub mod Delay {
    use vdf::{VDFParams, WesolowskiVDFParams, PietrzakVDFParams, VDF};

    pub fn do_delay(preimage: &[u8], delay_length: u64) -> Vec<u8>{

        println!("Running the delay");

        let int_size_bits = 2048;
        let vdf = vdf::WesolowskiVDFParams(int_size_bits).new();
        let vdf:Box<dyn vdf::VDF> = Box::new(vdf::WesolowskiVDFParams(int_size_bits).new());

        // previously was:
        //  let config = app_config();
        //  vdf.solve(&config.gen_preimage(), config.chain_info.block_size)
        vdf.solve(preimage, delay_length)
        .expect("iterations should have been valiated earlier")
    }

}
