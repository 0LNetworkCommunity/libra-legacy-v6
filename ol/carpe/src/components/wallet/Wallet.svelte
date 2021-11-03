<script lang="ts">
  import {
    signingAccount,
    getAllAccounts,
    all_accounts,
    setAccount,
  } from "../../accounts";
  import type { AccountEntry } from "../../accounts";
  import { onMount } from "svelte";
  import { Link } from "svelte-navigator";
  import { get_balance } from "../../queries";
  import ReminderCreate from "./ReminderCreate.svelte";
  import UIkit from "uikit";
  import Icons from "uikit/dist/js/uikit-icons";
import Onboard from "../txs/Onboard.svelte";
  UIkit.use(Icons);

  let account_list: AccountEntry[];
  let my_account: AccountEntry;

  all_accounts.subscribe((a) => {
    account_list = a;
  });

  signingAccount.subscribe((a) => {
    my_account = a;
  });

  async function bal(i): Promise<number> {
    let n = await get_balance(account_list[i]);
    console.log(n);
    return n / 1000000; // NOTE: divide by scaling factor. 
    // TODO: Rust should have already returned the scaled value.
  }

  onMount(() => {
    getAllAccounts();
  });
</script>

<main class="uk-height-viewport">
  <div class="uk-flex uk-flex-center">
    <h2 class="uk-text-light uk-text-muted uk-text-uppercase">Wallet</h2>
  </div>

  <div />
  {#if !account_list}
    <Onboard />
  {:else if account_list.length > 0}
    <table class="uk-table uk-table-divider">
      <thead>
        <tr>
          <th />
          <th>Nickname</th>
          <th>Address</th>
          <th>Authkey</th>
          <th>Balance</th>
        </tr>
      </thead>
      <tbody>
        {#each account_list as a, i}
          <tr
            on:click={() => {
              setAccount(a.account);
            }}
          >
            <!-- <a href="#" on:click={() => { setAccount(acc.account); }}> {acc.nickname} </a > -->
            <td>
              {#if a.account == my_account.account}
                <span uk-icon="user" />
              {/if}
            </td>
            <td>{a.nickname}</td>
            <td>{a.account}</td>
            <td>{a.authkey.slice(0, 5)}...</td>

            {#await bal(i)}
              <td>...</td>
            {:then data}
              {#if data}
                <td>{data}</td>
              {:else}
                <td>
                  <button
                    class="uk-button uk-button-default"
                    uk-toggle="target: #modal-example"
                    onclick={() => {
                      setAccount(a.account);
                    }}>
                    Onboard
                  </button>
                </td>
              {/if}
            {:catch error}
              <td>...</td>
            {/await}
          </tr>
        {/each}
      </tbody>
    </table>
  {:else}
    <!-- <Onboard /> -->
  {/if}

  <div uk-grid class="uk-flex uk-flex-center">
    <Link to="keygen">
      <button class="uk-button uk-button-secondary"> New Account </button>
    </Link>
    <Link to="account-from-mnem">
      <button class="uk-button uk-button-default">Restore Account </button>
    </Link>
  </div>

  <!-- Modal -->
  <ReminderCreate />
</main>
