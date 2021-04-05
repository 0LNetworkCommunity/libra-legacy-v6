<script>
  import Nav from "./Nav.svelte";
  import Dash from "../monitor/Dash.svelte";
  import Vals from "../validators/Vals.svelte";
  import Upgrade from "../upgrade/Upgrade.svelte";
</script>

<main class="uk-background-muted uk-height-viewport">
  <Nav />
  <div class="uk-container uk-margin-large-top">
    <ul class="uk-switcher uk-margin switcher-container">
      <Dash />
      <Vals />
      <Upgrade />
    </ul>
  </div>
</main>
