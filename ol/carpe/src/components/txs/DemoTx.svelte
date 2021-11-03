<script>
  import { invoke } from "@tauri-apps/api/tauri";
  import { signingAccount } from "../../accounts";
  import { raise_error } from "../../carpeError";
  import { responses } from "../../debug";

  let account_string = "";
  signingAccount.subscribe((n) => {
    account_string = n.account;
  });

  const demoTx = async () => {
    invoke("demo_tx", {})
      .then((res) => {
        responses.set(res);
      })
      .catch((e) => {
        raise_error(e);
      });
  };
</script>

<button class="uk-button uk-button-default" on:click={demoTx}>Demo Tx</button>
