<script lang="ts">
  import { onMount, onDestroy, getContext } from "svelte";

  let proposals = [];
  let voters_count = 0;
  let validator_count = 0;
  let expiration_height = 0;
  let vote_window_expired: Boolean;
  let current_height = 0;

  // let someObject = getContext('chainInfo')
  // let uri = "http://" + location.host + "/chain_liv";
  // let sse = new EventSource(uri);
  import { chainInfo } from "../../store.ts";
  onMount(async () => {
    chainInfo.subscribe((info_str) => {
      // console.log(info_str);
      let chain = JSON.parse(info_str);
      proposals = chain.upgrade.upgrade.vote_counts;
      voters_count = chain.upgrade.upgrade.validators_voted.length;
      expiration_height = chain.upgrade.upgrade.vote_window;
      vote_window_expired = expiration_height < current_height;
      current_height = chain.height;
    });
  });

  // onMount(async () => {
  //   // sse.onmessage = function (msg) {
  //   //   let chain = JSON.parse(msg.data);
  //   //   proposals = chain.upgrade.upgrade.vote_counts;
  //   //   voters_count = chain.upgrade.upgrade.validators_voted.length;
  //   //   expiration_height = chain.upgrade.upgrade.vote_window;
  //   //   vote_window_expired = expiration_height < current_height;
  //   //   current_height = chain.height;

  //   // };

  //   /// get validator count
  //   // TODO: don't need to keep reading stream. can close
  //   let val_url = "http://" + location.host + "/validators";
  //   await fetch(val_url)
  //   .then((r) => r.json())
  //   .then((data) => {
  //           validator_count = data.length;
  //   });
  // });
  // onDestroy(() => {
  //   console.log("closed");
  //   sse.close();
  // });
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
          <td> {expiration_height} </td>
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
          <p class="uk-text-uppercase uk-text-small">
            {proposals.length} votes / {validator_count} validators
          </p>
          <p>{prop.validators}</p>
        {/each}
      </div>
    </div>
  </div>
</main>
