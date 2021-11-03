<script lang="ts">
  import { invoke } from "@tauri-apps/api/tauri";
  import { signingAccount, mnem } from "../../accounts";
  import type { AccountEntry } from "../../accounts";
  import { raise_error } from "../../carpeError";
  import { responses } from "../../debug";
  import AccountFromMnemSubmit from "./AccountFromMnemSubmit.svelte";

  interface NewKeygen {
    entry: AccountEntry;
    mnem: string;
  }

  let display_mnem: string;
  mnem.subscribe((m) => (display_mnem = m));

  let address: string;
  let authkey: string;

  signingAccount.subscribe((a) => {
    address = a.account;
    authkey = a.authkey;
  });

  const keygen = async () => {
    invoke("keygen", {})
      .then((res: NewKeygen) => {
        console.log(res);
        responses.set(JSON.stringify(res));
        signingAccount.set(res.entry);
        mnem.set(res.mnem);
      })
      .catch((e) => raise_error(e));
  };
</script>

<main class="uk-height-viewport">
  <div class="uk-flex">
    <h3>Create New Account</h3>
    <button class="uk-button uk-button-default uk-align-right" on:click={keygen}
      >Generate Keys</button
    >
  </div>

  {#if address}
    <div class="uk-margin uk-card uk-card-default uk-card-body uk-width-1-2@m">
      <h5>ACCOUNT ADDRESS: {address}</h5>
      <h5>AUTH KEY: {authkey}</h5>
      <p>You need this to be able to create the account on chain.</p>
      <h5>RECOVERY MNEMONIC:</h5>
      <p>
        This is your recovery key, if you lose it no one can help you. Write it
        down now.
      </p>
      <div class="uk-margin">
        <textarea class="uk-textarea" rows="3"> {display_mnem} </textarea>
      </div>
      <AccountFromMnemSubmit danger_temp_mnem={""}/>

    </div>
    <p>
      Your account does not exist yet on chain. You'll need someone to send
      funds to the Auth Key above the first time. From then on, people can just
      use the account address to transfer funds to you.
    </p>
  {/if}
</main>
