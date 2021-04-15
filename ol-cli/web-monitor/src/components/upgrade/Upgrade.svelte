<script lang="ts">
  import Historical from "./Historical.svelte";
  import InProgress from "./InProgress.svelte";
  import { chainInfo } from "../../store.ts";

  let uri = "http://" + location.host + "/chain";
  let vote_in_progress = false;
  let vote_window_expired = false;

  let current_height = 100;

  chainInfo.subscribe((info_str) => {
    let chain = JSON.parse(info_str);
    if (chain.upgrade) {
      vote_in_progress = chain.upgrade.upgrade.validators_voted.length > 0;
    }
  });
  // onMount(async () => {
  //   await fetch(uri)
  //     .then((r) => r.json())
  //     .then((data) => {
  //       vote_in_progress = data.upgrade.upgrade.validators_voted.length > 0;
  //     });
  // });
</script>

<main>
  <div class="uk-child-width-expand@s" uk-grid>
    <div class="uk-grid-item-match">
      <div class="uk-card uk-card-default uk-card-body">
        {#if vote_in_progress}
          <InProgress />
        {:else}
          <div class="uk-text-center">
            <h4 class="uk-text-uppercase uk-text-muted">
              No Current Upgrade Proposals
            </h4>
          </div>
        {/if}

        {#if vote_window_expired}
          <div>
            <h3>Expired Proposals</h3>
            <InProgress />
          </div>
        {/if}
      </div>
    </div>
    <div>
      <Historical />
    </div>
  </div>
</main>
