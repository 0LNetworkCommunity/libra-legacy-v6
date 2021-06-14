<script>
  import NodeHealth from "./health/NodeHealth.svelte";
  import Info from "./chain/Info.svelte";
  import Account from "./account/Account.svelte";
</script>

<main>
  <div class="uk-grid-match uk-grid-small" uk-grid>
    <div class="uk-width-1-3@m">
      <NodeHealth/>
    </div>
    <div class="uk-width-1-3@m">
      <Info/>
    </div>
    <div class="uk-width-1-3@m">
      <Account/>
    </div>
  </div>
</main>
