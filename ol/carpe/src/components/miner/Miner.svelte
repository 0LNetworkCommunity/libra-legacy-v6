<script lang="ts">

  import ToggleMiner from "./ToggleMiner.svelte";
  import MinerProgres from "./MinerProgres.svelte";
  import TowerState from "./TowerState.svelte";
  import MinerDebug from "./MinerDebug.svelte";

  let debug: boolean;

  let info = true;

</script>

<main class="uk-height-viewport">

  <div class="uk-flex uk-flex-center">
    <h2 class="uk-text-light uk-text-muted uk-text-uppercase">Miner</h2>
  </div>

  <MinerProgres />

  <div class="uk-flex uk-flex-center">
    <ToggleMiner />
  <!-- <p>Lost time is never found again.</p> -->
    
  </div>

  {#if info}
    <TowerState />
  {/if}
  
  {#if debug} 
    <MinerDebug />
  {/if}

</main>
