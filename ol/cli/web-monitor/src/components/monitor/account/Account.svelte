<script lang="ts">
  import { chainInfo } from "../../../store.ts";
import Alert from "../../demo/Alert.svelte";
  import "../../layout/Style.svelte";
  
  let accounts = [];
  chainInfo.subscribe((info_str) => {
    let data = JSON.parse(info_str);
    if (data.account_view) {
      accounts = [data.account_view];
    }
  });
</script>

<div class="uk-card uk-card-default uk-card-body uk-margin-bottom">
  <h3 class="uk-card-title uk-text-center uk-text-uppercase uk-text-muted uk-text-large">
    Accounts
  </h3>

  {#each accounts as {address, balance, is_in_validator_set }}
    <table class="uk-table">
      <tbody>
        <tr>
          <td class="uk-text-uppercase">owner</td>
          <td class="uk-text-truncate">{address}</td>
        </tr>
        <tr>
          <td class="uk-text-uppercase">balance</td>
          <td>{balance.toLocaleString('en-ES')}</td>
        </tr>
        <tr>
          <td class="uk-text-uppercase">In Set</td>
          <td class="uk-text-uppercase">{is_in_validator_set}</td>
        </tr>
      </tbody>
    </table>
  {:else}
    <p>loading...</p>
  {/each}
</div>
