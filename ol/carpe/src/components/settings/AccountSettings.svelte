<script lang="ts">
  import { invoke } from "@tauri-apps/api/tauri";
  import { raise_error } from "../../carpeError";
  import { responses } from "../../debug";
  const removeAccounts = async () => {
    invoke("remove_accounts", {})
      .then((res: any) => {
        responses.set(res);
      })
      .catch((e) => {
        raise_error(e);
      });
  };
</script>

<main class="uk-margin" >
  <h4 class="uk-text-light uk-text-uppercase uk-text-muted uk-text-thin">
    Account Settings
  </h4>

  <div class="uk-margin" uk-grid>
    <div>
      <button class="uk-button uk-button-danger" on:click={removeAccounts}>
        Remove Accounts
      </button>
    </div>
    <div>
      <span>
        This does not delete any accounts from the chain. It only removes the
        accounts from this device. If you do not have your recovery codes
        (mnemonic) stored somewhere, you may be locked out of this account
        permanently. NO ONE CAN HELP YOU RECOVER THE MNEMONIC.
      </span>
    </div>
  </div>
</main>
