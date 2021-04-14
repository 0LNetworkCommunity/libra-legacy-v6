<script lang="ts">
  import { onMount, onDestroy } from "svelte";

  let epoch: number = 0;
  let round: number = 0;
  let waypoint: string = undefined;
  let uri = "http://" + location.host + "/chain_live";
  let sse = new EventSource(uri);

  onMount(async () => {
    // var uri = "http://" + location.host + "/chain";
    // await fetch(uri)
    //   .then((r) => r.json())
    //   .then((data) => {
    //     // let chain = JSON.parse(data);
    //     epoch = data.epoch;
    //     round = data.height;
    //     waypoint = data.waypoint;
    //   });

    sse.onmessage = function (msg) {
      let chain = JSON.parse(msg.data);
      epoch = chain.epoch;
      round = chain.height;
      waypoint = chain.waypoint;
    };
  });

  onDestroy(() => {
    sse.close();
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
        <td class="uk-text-uppercase">Round</td>
        <td>{round.toLocaleString("en-ES")}</td>
      </tr>
      <tr>
        <td class="uk-text-uppercase">Waypoint</td>
        <td class="uk-text-break">{waypoint}</td>
      </tr>
    </tbody>
  </table>
</div>
