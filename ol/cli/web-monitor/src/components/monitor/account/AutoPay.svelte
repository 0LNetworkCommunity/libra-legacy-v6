<script lang="ts">
    import "../../layout/Style.svelte";
    
    export let account;
  </script>

<div class="uk-card uk-card-default uk-card-body uk-margin-bottom">
  <h3 class="uk-card-title uk-text-center uk-text-uppercase uk-text-muted uk-text-large">
    Auto Pay Setup
  </h3>
  
  {#if account}
    {#if account.auto_pay}
      <table class="uk-table">
        <thead>
          <tr>
            <th>uid</th>
            <th>type</th>
            <th>payee</th>
            <th>end epoch</th>
            <th>previous balance</th>
            <th>amount</th>
          </tr>
        </thead>
        <tbody>
          {#each account.auto_pay.payments as {uid, in_type, payee, end_epoch, prev_bal, amt}}
            <tr>
              <td>{uid}</td>
              <td>{in_type}</td>
              <td class="uk-visible@s uk-text-center">{payee}</td>
              <td class="uk-hidden@s uk-text-truncate">{payee}</td>
              <td>{end_epoch}</td>
              <td>{prev_bal.toLocaleString('en-ES')}</td>
              <td>{amt}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    {:else}
      <p class="uk-text-uppercase">account auto pay not set</p>
    {/if}
  {:else}
    <p>loading...</p>
  {/if}
</div>