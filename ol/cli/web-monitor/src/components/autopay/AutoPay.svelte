<script lang="ts">
    import "/layout/Style.svelte";
    
    export let account;

    // TODO: move logic to the server side
    let formatAmount = (value, type) => {
      if (type === 0 || type === 1) {
        return (value / 100).toFixed(2) + "%";
      }
      return value.toLocaleString('en-ES');
    }
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
            <th class="uk-text-center">uid</th>
            <th class="uk-text-center">type</th>
            <th class="uk-text-center">payee</th>
            <th class="uk-text-center uk-visible@s">end epoch</th>
            <th class="uk-text-center uk-visible@s">previous balance</th>
            <th class="uk-text-center">amount</th>
          </tr>
        </thead>
        <tbody>
          {#each account.auto_pay.payments as {uid, in_type, payee, end_epoch, prev_bal, amt}}
            <tr>
              <td class="uk-text-center">{uid}</td>
              <td class="uk-text-center">{in_type}</td>
              <td class="uk-visible@s uk-text-center">{payee}</td>
              <td class="uk-hidden@s uk-text-truncate">{payee}</td>
              <td class="uk-text-right uk-visible@s">{end_epoch}</td>
              <td class="uk-text-right uk-visible@s">{prev_bal.toLocaleString('en-ES')}</td>
              <td class="uk-text-right">{formatAmount(amt, in_type)}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    {:else}
      <p class="uk-text-uppercase">your validator does not have auto pay set</p>
      <p>Now to setup auto pay: <a href="#">x</a></p>
      <p>List : <a href="#">y</a></p>
    {/if}
  {:else}
    <p>loading...</p>
  {/if}
</div>