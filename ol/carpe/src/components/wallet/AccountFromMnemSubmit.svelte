<script lang="ts">
  import { Link, navigate } from "svelte-navigator";
  import UIkit from "uikit";
  import { responses } from "../../debug";
  import { signingAccount, mnem } from "../../accounts";
  import type { AccountEntry } from "../../accounts";

  import { raise_error } from "../../carpeError";
  import { invoke } from "@tauri-apps/api/tauri";

  // let alice_mnem =
  //   "talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse";

  export let danger_temp_mnem: string;

  mnem.subscribe((m) => danger_temp_mnem = m);

  // let helpTitle = "Enter your 24 word recovery mnemonic";
  // let helpAddress = "";

  const re = /[0-9A-Fa-f]{32}/g;

  function handleAdd() {
    // submit
    invoke("init_from_mnem", { mnem: danger_temp_mnem })
      .then((res: AccountEntry) => {
        responses.set(JSON.stringify(res));
        signingAccount.set(res);

        UIkit.notification({
          message: `Account Added:  ${res.account}`,
          pos: "bottom-right",
          status: "success",
          timeout: 3000,
        });
        navigate("/");
      })
      .catch((error) => raise_error(error));

      
  }
</script>

<main>

  <button class="uk-button uk-button-default" on:click|preventDefault={handleAdd}>Submit</button>
  <!-- <h1>Add Account</h1>
  <form id="account-form">
    <fieldset class="uk-fieldset">
      <div class="uk-margin uk-inline-block uk-width-1-1">
        <input
          class="uk-input"
          type="text"
          placeholder="Recovery Mnemonic"
          bind:value={danger_temp_mnem}
        />
        <span
          class="uk-form-help-inline uk-text-small uk-text-danger uk-position-absolute"
          >{helpTitle}</span
        >
      </div>

      <div>
        <span
          on:click={handleAdd}
          class="uk-button uk-button-primary uk-align-right"
          id="add-btn">Add</span
        >
        <Link to="/">
          <span class="uk-button uk-button-default uk-align-right">Cancel</span>
        </Link>
      </div>
    </fieldset>
  </form> -->
</main>
