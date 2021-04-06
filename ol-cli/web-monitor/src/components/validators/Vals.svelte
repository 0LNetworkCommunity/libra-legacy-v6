
<script lang="ts">
  import { onMount } from "svelte";

  let headers = ["a", "b", "c"]
  interface ValSet {
    account_address: String,
    pub_key: String,
    voting_power: Number,
    full_node_ip: String,
    validator_ip: String,
    tower_height: Number,
    tower_epoch: Number,
    count_proofs_in_epoch: Number,
    epochs_validating_and_mining: Number,
    contiguous_epochs_validating_and_mining: Number,
    epochs_since_last_account_creation: Number,
  }
  let set: ValSet[] = [];
  onMount(async () => {
    var uri = "http://" + location.host + "/validators";
    var sse = new EventSource(uri);
    sse.onmessage = function (msg) {
      set = JSON.parse(msg.data);
      console.log(json)
    };
  });

</script>
<main>
  validators

  <div class="uk-overflow-auto">
    <table
      class="uk-table uk-table-small uk-table-divider uk-table-responsive "
    >
      <thead>
        <tr>
          {#each headers as head}
            <th>{head}</th>
          {/each}
        </tr>
      </thead>
      <tbody>
        {#each set as val}
          <tr>
            <td>{val.account_address}</td>
            <td>{val.voting_power}</td>
            <td>{val.epochs_since_last_account_creation}</td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
</main>
