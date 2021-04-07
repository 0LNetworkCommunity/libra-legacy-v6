<script lang="ts">
  import Historical from "./Historical.svelte";
  import InProgress from "./InProgress.svelte";

  // import { onMount } from "svelte";

  // let proposals = [];
  // let voters_count = 0;
  // let validator_count = 0;

  // onMount(async () => {
  //   var uri = "http://" + location.host + "/chain";
  //   var sse = new EventSource(uri);
  //   sse.onmessage = function (msg) {
  //     let chain = JSON.parse(msg.data);
  //     proposals = chain.upgrade.upgrade.vote_counts;
  //     voters_count = chain.upgrade.upgrade.validators_voted.length;
  //   };

  //   /// get validator count
  //   // TODO: don't need to keep reading stream. can close
  //   var val_url = "http://" + location.host + "/validators";
  //   var val_stream = new EventSource(val_url);
  //   val_stream.onmessage = function (msg) {
  //     let vals = JSON.parse(msg.data);
  //     validator_count = vals.length;
  //     val_stream.close();
  //   };
  // });
</script>

<main>
  <div class="uk-child-width-expand@s" uk-grid>
    <div class="uk-grid-item-match">
      <div class="uk-card uk-card-default uk-card-body">
        <!-- <div>No Proposals</div>
        <div>Expired Proposals</div>
        <div>Consensus Reached</div>
        <div>Autorized</div> -->
        <InProgress />
      </div>
    </div>
    <div>
      <Historical />
    </div>
  </div>
</main>
