<script lang="ts">

  import { onMount } from "svelte";

  let proposals = [];
  let voters_count = 0;
  let validator_count = 0;

  onMount(async () => {
    var uri = "http://" + location.host + "/chain";
    var sse = new EventSource(uri);
    sse.onmessage = function (msg) {
      let chain = JSON.parse(msg.data);
      proposals = chain.upgrade.upgrade.vote_counts;
      voters_count = chain.upgrade.upgrade.validators_voted.length;
    };

    /// get validator count
    // TODO: don't need to keep reading stream. can close
    var val_url = "http://" + location.host + "/validators";
    var val_stream = new EventSource(val_url);
    val_stream.onmessage = function (msg) {
      let vals = JSON.parse(msg.data);
      validator_count = vals.length;
      // val_stream.close();
    };
  });
</script>


<main>
  
  <div>
    <h3 class="uk-text-muted uk-text-center uk-text-uppercase">
      Voting In Progress
    </h3>
    <table class="uk-table">
      <tbody>
        <tr>
          <td class="uk-text-uppercase">VOTERS:</td>
          <td> {voters_count}/{validator_count} </td>
        </tr>
        <tr>
          <td class="uk-text-uppercase">EXPIRATION:</td>
          <td> 0000 </td>
        </tr>
      </tbody>
    </table>

    <hr />

    <div>
      <div class="uk-text-center">
        {#each proposals as prop, i}
          <h5
            class="uk-text-muted uk-text-center uk-text-uppercase uk-text-small"
          >
            proposal {i + 1} 
          </h5>
          <p class="uk-text-uppercase uk-text-small">{proposals.length} votes / {validator_count} validators</p>
          <p>{prop.validators}</p>
        {/each}
      </div>
    </div>
  </div>
</main>
