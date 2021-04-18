<script lang="ts">
  let epoch: number = 0;
  let round: number = 0;
  let waypoint: string = undefined;
  import { chainInfo } from "../../../store.ts";

  chainInfo.subscribe((info_str) => {
    let chain = JSON.parse(info_str);
    if (chain.upgrade) {
      epoch = chain.epoch;
      round = chain.height;
      waypoint = chain.waypoint;
    }
  });
</script>

<div class="uk-card uk-card-default uk-card-body uk-height-1-1">
  <h3 class="uk-card-title uk-text-center uk-text-uppercase uk-text-muted">
    Chain
  </h3>

  <table class="uk-table">
    <tbody>
      <tr>
        <td class="uk-text-uppercase">Epoch</td>
        <td> {epoch} </td>
      </tr>
      <tr>
        <td class="uk-text-uppercase">Height</td>
        <td>{round.toLocaleString("en-ES")}</td>
      </tr>
      <tr>
        <td class="uk-text-uppercase">Waypoint</td>
        <td class="uk-text-break">{waypoint}</td>
      </tr>
    </tbody>
  </table>
</div>
