<script>
  import Nav from "./Nav.svelte";
  import Mode from "../monitor/mode/Mode.svelte";
  import Dash from "../monitor/Dash.svelte";
  import Vals from "../validators/Vals.svelte";
  import Upgrade from "../upgrade/Upgrade.svelte";
</script>

<main class="uk-background-muted uk-height-viewport">
  <Nav />
  <!-- <div class="uk-height-max-small">
    <Mode />
  </div> -->
  <div class="uk-container uk-margin-top">
    <ul class="uk-switcher uk-margin switcher-container uk-height-large">
      <Dash />
      <Vals />
      <Upgrade />
    </ul>
  </div>
</main>
