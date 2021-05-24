<script>
  import Nav from "./Nav.svelte";
  import Dash from "../monitor/Dash.svelte";
  import Vals from "../validators/Vals.svelte";
  import Upgrade from "../upgrade/Upgrade.svelte";
</script>

<main uk-height-viewport="expand: true" class="uk-background-muted uk-overflow-auto">
  <Nav />
  <div class="uk-container uk-margin-top">
    <ul class="uk-switcher uk-margin switcher-container uk-height-large">
      <Dash />
      <Vals />
      <Upgrade />
    </ul>
  </div>
</main>
