<script lang="ts">
  import { killTowerListener, startTowerListener, towerOnce } from "../../miner";
</script>

<main class="uk-margin" >
  <div class="uk-card uk-card-body">
    <div class="margin">
      <button class="uk-button uk-button-default" on:click={towerOnce}>Start Tower</button>
    </div>

    <div class="margin">
      <button class="uk-button uk-button-default" on:click={startTowerListener}>Start Listener</button>
    </div>

    <div class="margin">
      <button class="uk-button uk-button-default" on:click={killTowerListener}>Kill Listener</button>
    </div>


  </div>
</main>
