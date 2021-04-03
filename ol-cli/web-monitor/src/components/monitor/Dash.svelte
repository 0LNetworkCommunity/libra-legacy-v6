<script>
  import NodeHealth from "./health/NodeHealth.svelte";
  import Info from "./chain/Info.svelte";
  import Account from "./account/Account.svelte";
</script>

<main>
  <div uk-grid>
    <div class="uk-width-1-3">
      <NodeHealth/>
    </div>
    <div class="uk-width-1-3">
      <Info/>
    </div>
    <div class="uk-width-1-3">
      <Account/>
    </div>
  </div>
</main>
