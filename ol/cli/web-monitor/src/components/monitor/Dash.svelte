<script>
  import NodeHealth from "./health/NodeHealth.svelte";
  import Info from "./chain/Info.svelte";
  import Account from "./account/Account.svelte";

  export let data;
</script>

<main>
  <div class="uk-grid-match uk-grid-small" uk-grid>
    <div class="uk-width-1-3@m">
      <NodeHealth health_data={data.items}/>
    </div>
    <div class="uk-width-1-3@m">
      <Info chain={data.chain_view}/>
    </div>
    <div class="uk-width-1-3@m">
      <Account account={data.account_view}/>
    </div>
  </div>
</main>
