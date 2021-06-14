<script lang="ts">
  import "../../layout/Style.svelte";
  
  export let account;
</script>

<div class="uk-card uk-card-default uk-card-body uk-margin-bottom">
  <h3 class="uk-card-title uk-text-center uk-text-uppercase uk-text-muted uk-text-large">
    Accounts
  </h3>

  {#if account}
    <table class="uk-table">
      <tbody>
        <tr>
          <td class="uk-text-uppercase">owner</td>
          <td class="uk-text-truncate">{account.address}</td>
        </tr>
        <tr>
          <td class="uk-text-uppercase">balance</td>
          <td>{account.balance.toLocaleString('en-ES')}</td>
        </tr>
        <tr>
          <td class="uk-text-uppercase">In Set</td>
          <td class="uk-text-uppercase">{account.is_in_validator_set}</td>
        </tr>
      </tbody>
    </table>
  {:else}
    <p>loading...</p>
  {/if}
</div>
