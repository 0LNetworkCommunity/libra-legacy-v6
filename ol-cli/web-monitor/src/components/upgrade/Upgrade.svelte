<script lang="ts">
  import { onMount } from "svelte";

  let voters = [];
  let versions = [{
    hash: "xyz",
    vote_count: 0
  }]
  onMount(async () => {
    var uri = "http://" + location.host + "/chain";
    var sse = new EventSource(uri);
    sse.onmessage = function (msg) {
      let chain = JSON.parse(msg.data);
      voters = chain.upgrade.validators_voted;
    }
  });
  
</script>

<main>
  <div class="uk-child-width-expand@s" uk-grid>
    <div class="uk-grid-item-match">
      <div class="uk-card uk-card-default uk-card-body">
        <h3 class="uk-text-muted uk-text-center uk-text-uppercase">
          Proposals
        </h3>
        <table class="uk-table">
          
          <tbody>
            <tr>
              <td>Hash</td>
              <td> x </td>
            </tr>
            <tr>
              <td>Votes</td>
              {#each voters as v, i}
              <td>{v}</td>
              {/each}
            </tr>
            <tr>
              <td>Expiry</td>
              <td> height </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div>
      <h3 class="uk-text-muted uk-text-center uk-text-uppercase uk-text-small">
        Historical
      </h3>
      <div class="uk-overflow-auto">
        <table
          class="uk-table uk-table-small uk-table-divider uk-table-responsive"
          uk-accordion
        >
          <thead>
            <tr>
              <th />
              <th>Hash</th>
              <th>Votes</th>
            </tr>
          </thead>
          <tbody>
            {#each versions as v, i}
              <tr>
                <td>{i + 1}</td>
                <td>{v.hash}</td>
                <td>{v.vote_count}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  </div>
</main>
