<script>
  import Dash from "../monitor/Dash.svelte";
  import Nav from "./Nav.svelte";
</script>

<main class="uk-background-muted uk-height-viewport">
  <Nav/>
  <div class="uk-container uk-margin-large-top">
    <ul class="uk-switcher uk-margin switcher-container">
      <Dash/>
      <li>Hello!</li>
      <li>Hello again!</li>
    </ul>
  </div>
</main>
