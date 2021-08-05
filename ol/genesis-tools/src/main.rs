use std::{path::PathBuf, process::exit};

use anyhow::Result;
use gumdrop::Options;
use ol_genesis_tools::read_archive::archive_into_recovery;
// use ol_genesis_tools::read_archive::archive_into_writeset;

fn main() -> Result<()>{
    #[derive(Debug, Options)]
    struct Args {
      #[options(help = "what epoch to restore from archive")]
      epoch: Option<u64>,
      #[options(help = "path to snapshot files")]
      snaphot_path: Option<PathBuf>,
      #[options(help = "swarm simulation mode")]
      swarm: bool,
      #[options(help = "dump snapshot into recovery file")]
      recover_path: Option<PathBuf>,
      #[options(help = "live fork mode")]
      fork: bool,
      // #[options(help = "Url of the github repo with archive")]
      // epoch: Option<Url>,
    }

    let opts = Args::parse_args_default_or_exit();

    // Start a simulation swarm based on snapshot
    if opts.swarm {
      if let Some(_archive_path) = opts.snaphot_path {
        // TODO: block on this future
        // archive_into_writeset(archive_path);
      }
      Ok(())
    
    // start the live fork daemon
    } else if opts.fork {

      Ok(())
    
    // process recovery file only
    } else if let Some(r_path) = opts.recover_path {
       if let Some(a_path) = opts.snaphot_path {
          archive_into_recovery(&a_path, &r_path);
       };
      Ok(())
    } else {
      println!("No options provided, exiting");
      exit(1)
    }
}

