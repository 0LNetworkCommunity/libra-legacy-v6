use diem_genesis_tool::genesis::Genesis;
use diem_secure_storage::{Storage, GitHubStorage};


#[test]

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