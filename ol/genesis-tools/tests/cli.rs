
#[test]

fn parse_secure_backed() {
  let s = "backend=github;repository_owner=0l-testnet;repository=dev-genesis;token=/root/.0L/github_token.txt;namespace=4c613c2f4b1e67ca8d98a542ee3f59f5";

  let b =  diem_management::secure_backend::storage(&s).unwrap();
  assert!(b.namespace() == Some("4c613c2f4b1e67ca8d98a542ee3f59f5"));
}