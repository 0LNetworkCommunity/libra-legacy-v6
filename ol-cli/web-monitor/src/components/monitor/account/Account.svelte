<script lang="ts">
  import { onMount, onDestroy } from "svelte";
  let account: string = undefined;
  let balance: Number = 0;
  let inValidatorSet: Boolean = false;
  let uri = "http://" + location.host + "/account";
  let sse = new EventSource(uri);
  onMount(async () => {
    sse.onmessage = function (msg) {
      let json = JSON.parse(msg.data);
      account = json.address;
      balance = json.balance;
      inValidatorSet = json.is_in_validator_set;
    }
  });

  onDestroy(() => {
    sse.close();
  });
</script>


<div class="uk-card uk-card-default uk-card-body uk-height-1-1">
  <h3
    class="uk-card-title uk-text-center uk-text-uppercase uk-text-muted uk-text-large"
  >
    Accounts
  </h3>

    <table class="uk-table">
    <tbody>
      <tr>
        <td class="uk-text-uppercase">owner</td>
        <td class="uk-text-truncate"> {account} </td>
      </tr>
      <tr>
        <td class="uk-text-uppercase">balance</td>
        <td>{balance.toLocaleString('en-ES')}</td>
      </tr>
      <tr>
        <td class="uk-text-uppercase">In Set</td>
        <td class="uk-text-uppercase">{inValidatorSet}</td>
      </tr>
    </tbody>
  </table>

  <!-- <dl class="uk-description-list">
    <dt>{account}</dt>
    <dd>owner account</dd>
    
    <dt>{balance.toLocaleString('en-ES')}</dt>
    <dd>balance</dd>

    <dt> {inValidatorSet} </dt>
    <dd>in validator set</dd>
  </dl> -->
</div>
