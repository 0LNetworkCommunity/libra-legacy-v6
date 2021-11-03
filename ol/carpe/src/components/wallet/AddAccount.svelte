<script>
  import { Link } from "svelte-navigator";
  import UIkit from "uikit";
  import { raise_error } from "../../carpeError";
  import { invoke } from "@tauri-apps/api/tauri";

  let authkey = "";
  let address = "";
  let helpTitle = "";
  let helpAddress = "";

  const re = /[0-9A-Fa-f]{32}/g;

  function handleAdd() {
    // check input data
    helpTitle = authkey.trim().length > 0 ? "" : "Account must include authkey";
    helpAddress =
      address.length == 32 && re.test(address)
        ? ""
        : "The address must have 32 valid characters";
    if (helpTitle.length > 0 || helpAddress.length > 0) {
      return;
    }

    // submit
    invoke("add_account", { authkey: authkey, address: address })
      .then((_) => {
        UIkit.notification({
          message: "<span uk-icon='icon: check'></span> Account added",
          pos: "bottom-right",
          status: "success",
          timeout: 3000,
        });
      })
      .catch((error) => raise_error(error));
  }
</script>

<main>
  <h1>Add Account</h1>
  <form id="account-form">
    <fieldset class="uk-fieldset">
      <span> Address</span>
      <div class="uk-margin uk-inline-block uk-width-1-1">
        <input
          class="uk-input"
          type="text"
          placeholder="Address"
          bind:value={address}
        />
        <span
          class="uk-form-help-inline uk-text-small uk-text-danger uk-position-absolute"
          >{helpAddress}</span
        >
      </div>
      <div class="uk-margin uk-inline-block uk-width-1-1">
        <span> AuthKey</span>
        <input
          class="uk-input"
          type="text"
          placeholder="Authkey"
          bind:value={authkey}
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
  </form>
</main>
