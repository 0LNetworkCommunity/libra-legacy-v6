
<script lang="ts">
  let account: string = undefined;
  let balance: number = 0;
  let inValidatorSet: bool = false;

  let valSetText = "Jailed";
  
  if (inValidatorSet) { valSetTex = "In Validator Set"};

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
    <dt>{balance}</dt>
    <dd>balance</dd>

    <dt> {valSetText} </dt>
  </dl>
</div>
