<script lang="ts">
  import { onMount } from "svelte";
  let account: string = undefined;
  let balance: Number = 0;
  let inValidatorSet: Boolean = false;

  // let valSetText = "Jailed";
  // if (inValidatorSet) { valSetText = "In Validator Set"};

  onMount(async () => {
    var uri = "http://" + location.host + "/account";
    var sse = new EventSource(uri);
    sse.onmessage = function (msg) {
      let json = JSON.parse(msg.data);
      account = json.address;
      balance = json.balance;
      inValidatorSet = json.is_in_validator_set;
    }
  });
</script>


<div class="uk-card uk-card-default uk-card-body uk-text-center uk-height-1-1">
  <h3
    class="uk-card-title uk-text-center uk-text-uppercase uk-text-muted uk-text-large"
  >
    Account
  </h3>
  <dl class="uk-description-list">
    <dt>{account}</dt>
    <dd>owner account</dd>
    
    <dt>{balance.toLocaleString('en-ES')}</dt>
    <dd>balance</dd>

    <dt> {inValidatorSet} </dt>
    <dd>status</dd>
  </dl>
</div>
