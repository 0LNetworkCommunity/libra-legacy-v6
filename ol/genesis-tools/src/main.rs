use std::{path::PathBuf, process::exit};

use anyhow::Result;
use gumdrop::Options;
use ol_genesis_tools::read_archive::archive_into_writeset;

fn main() -> Result<()>{
    #[derive(Debug, Options)]
    struct Args {
      #[options(help = "what epoch to restore from archive")]
      epoch: Option<u64>,
      #[options(help = "path to snapshot files")]
      path: Option<PathBuf>,
      #[options(help = "swarm simulation mode")]
      swarm: bool,
      #[options(help = "live fork mode")]
      fork: bool,
      // #[options(help = "Url of the github repo with archive")]
      // epoch: Option<Url>,
    }

    let opts = Args::parse_args_default_or_exit();

    if opts.swarm {
      if let Some(archive_path) = opts.path {
        // TODO: block on this future
        archive_into_writeset(archive_path);
      }
      Ok(())

    } else if opts.fork {

      Ok(())

    } else if let Some(path) = opts.path {
      dbg!(&path);
      // genesis_from_path(path)
      Ok(())
    } else {
      println!("No options provided, exiting");
      exit(1)
    }
}

