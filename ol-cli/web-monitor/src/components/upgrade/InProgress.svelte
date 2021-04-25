<script lang="ts">
  import { chainInfo } from "../../store.ts";
  import { onMount } from "svelte";

  let vote_counts = [];
  let validator_count = 0;
  let expiration_height = 0;
  let vote_window_expired: Boolean;
  let current_height = 0;

  chainInfo.subscribe((info_str) => {
    let data = JSON.parse(info_str);
    vote_counts = data.chain_view.upgrade.upgrade.vote_counts;
    expiration_height = data.chain_view.upgrade.upgrade.vote_window;
    vote_window_expired = expiration_height < current_height;
    current_height = data.chain_view.height;
  });

  onMount(async () => {
    let val_url = "http://" + location.host + "/vals";
    await fetch(val_url)
      .then((r) => r.json())
      .then((data) => {
        validator_count = data.length;
      });
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
          <td> {vote_counts.length}/{validator_count} </td>
        </tr>
        <tr>
          <td class="uk-text-uppercase">EXPIRATION:</td>
          <td> {expiration_height} </td>
        </tr>
      </tbody>
    </table>

    <hr />

    <div>
      <div class="uk-text-center">
        {#each vote_counts as prop, i}
          <h5
            class="uk-text-muted uk-text-center uk-text-uppercase uk-text-small"
          >
            proposal {i + 1}
          </h5>
          <p class="uk-text-uppercase uk-text-small">
            {vote_counts.length} votes / {validator_count} validators
          </p>
          <p>{prop.validators}</p>
        {/each}
      </div>
    </div>
  </div>
</main>
