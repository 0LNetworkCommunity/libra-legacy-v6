<script lang="ts">
  export let chain;
</script>

<div class="uk-card uk-card-default uk-card-body uk-margin-bottom">
  <h3 class="uk-card-title uk-text-center uk-text-uppercase uk-text-muted">
    Chain
  </h3>
  {#if chain}
    <table class="uk-table">
      <tbody>
        <tr>
          <td class="uk-text-uppercase">Epoch</td>
          <td> {chain.epoch} </td>
        </tr>
        <tr>
          <td class="uk-text-uppercase">Height</td>
          <td>{chain.height.toLocaleString("en-ES")}</td>
        </tr>
        <tr>
          <td class="uk-text-uppercase">Waypoint</td>
          <td class="uk-text-break">{chain.waypoint}</td>
        </tr>
      </tbody>
    </table>
  {:else}
    <p>loading...</p>
  {/if}
</div>
