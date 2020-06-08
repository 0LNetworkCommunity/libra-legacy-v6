//! OlMiner delay module
#![forbid(unsafe_code)]

pub mod delay {
    //! Functions for running the VDF.

    use vdf::{VDFParams, WesolowskiVDFParams, VDF};
    use crate::application::SECURITY_PARAM;

    pub fn do_delay(preimage: &[u8], delay_length: u64) -> Vec<u8>{
        //! Functions for running the VDF.


        println!("Running the delay");

        let vdf: vdf::WesolowskiVDF= WesolowskiVDFParams(SECURITY_PARAM).new();

        // previously was:
        //  let config = app_config();
        //  vdf.solve(&config.gen_preimage(), config.chain_info.block_size)
        vdf.solve(preimage, delay_length)
        .expect("iterations should have been valiated earlier")
    }

}
