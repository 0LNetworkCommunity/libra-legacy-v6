<script lang="ts">
  import WatchList from "../watch-list/WatchList.svelte";
  import "/layout/Style.svelte";
  export let account;
</script>

<div class="uk-card uk-card-default uk-card-body uk-margin-bottom">
  <h3 class="uk-card-title uk-text-center uk-text-uppercase uk-text-muted uk-text-large">
    Autopay Instructions
  </h3>
  
  {#if account}
    {#if account.autopay && account.autopay.payments.length > 0}
      <table class="uk-table">
        <thead>
          <tr>
            <th class="uk-text-center">uid</th>
            <th class="uk-text-center">type</th>
            <th class="uk-text-center">payee</th>
            <th class="uk-text-center uk-visible@s">end epoch</th>
            <th class="uk-text-center">amount</th>
          </tr>
        </thead>
        <tbody>
          {#each account.autopay.payments as {uid, type_desc, payee, end_epoch, amount}}
            <tr>
              <td class="uk-text-center">{uid}</td>
              <td class="uk-text-center">{type_desc}</td>
              <td class="uk-visible@s uk-text-center">{payee}</td>
              <td class="uk-hidden@s uk-text-truncate">{payee}</td>
              <td class="uk-text-right uk-visible@s">{end_epoch}</td>
              <td class="uk-text-right">{amount}</td>
            </tr>
          {/each}
        </tbody>
      </table>
      <WatchList watch_list={account.watch_list} />
    {:else}
      <p class="uk-text-center uk-text-warning">Your validator does not have autopay instructions.</p>
    {/if}
  {:else}
    <p>loading...</p>
  {/if}
</div>