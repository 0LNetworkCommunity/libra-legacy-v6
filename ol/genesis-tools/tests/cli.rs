use diem_genesis_tool::genesis::Genesis;
use diem_secure_storage::{Storage, GitHubStorage};
use std::{thread, time};
use indicatif::{ProgressBar, ProgressIterator, ProgressStyle};
use core::time::Duration;

#[test]
fn progress() {

  // let bar = ProgressBar::new(1000);
  // for _ in 0..1000 {
  //   let ten_millis = time::Duration::from_millis(10);

  //     thread::sleep(ten_millis);
  //     bar.inc(1);
  //     // ...
  // }
  // bar.finish();
  let a = (0..1000);
  // for _ in a.progress() {
  //       // ...
  //       thread::sleep(Duration::from_millis(5));
  // }

  let pb = ProgressBar::new(1000);
  pb.set_style(
      ProgressStyle::with_template(
          "{spinner} [{elapsed_precise}] [{bar:100.green}] ({pos}/{len}, ETA {eta})",
      )
      .unwrap(),
  );

  a.progress_with(pb).for_each(|_|{
    let ten_millis = time::Duration::from_millis(10);
    thread::sleep(ten_millis);
  });

  // let v = [0..1000];
  // v.iter()
  // .progress()
  // .for_each(|_|{
  //   let ten_millis = time::Duration::from_millis(10);
  //   thread::sleep(ten_millis);
  // });
  // .progress();

}

#[test]
#[ignore]
fn parse_secure_backed() {
  // let s = "backend=github;repository_owner=0l-testnet;repository=dev-genesis;token=/Users/lucas/.0L/github_token.txt";

    let gh_config = GitHubStorage::new(
      "0l-testnet".to_string(),
      "dev-genesis".to_string(),
      "master".to_string(),
      "".to_string(),
    );
    let b = Storage::GitHubStorage(gh_config);
    // dbg!(&b);

  // let b =  diem_management::secure_backend::storage(&s).unwrap();
  // assert!(b.namespace() == Some("common"));

  let v = Genesis::just_the_vals(b).expect("could not get the validator set");
  dbg!(&v);
}

// fn make_backend() {
//   diem_management::secure_backend::SharedBackend
// }