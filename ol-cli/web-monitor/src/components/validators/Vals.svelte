<script lang="ts">
  import { onMount } from "svelte";
  import {sortBy, reverse} from "lodash";

  interface ValInfo {
    account_address: string;
    pub_key: string;
    voting_power: Number;
    full_node_ip: string;
    validator_ip: string;
    tower_height: Number;
    tower_epoch: Number;
    count_proofs_in_epoch: Number;
    epochs_validating_and_mining: Number;
    contiguous_epochs_validating_and_mining: Number;
    epochs_since_last_account_creation: Number;
  }
  let set: ValInfo[] = [];
  onMount(async () => {
    var uri = "http://" + location.host + "/validators";
    var sse = new EventSource(uri);
    sse.onmessage = function (msg) {
      set = JSON.parse(msg.data);
      set = sortBy(set, ['voting_power']).reverse();
    };
  });

  function can_create_account(info: ValInfo): Boolean {
    return info.epochs_since_last_account_creation > 7;
  }
</script>

<main>
  <h2 class="uk-heading-line uk-text-light uk-text-center uk-text-uppercase uk-text-muted"><span>{set.length} Validators</span></h2>

  <div class="uk-overflow-auto">
    <table
      class="uk-table uk-table-small uk-table-divider uk-table-responsive"
    >
      <thead>
        <tr>
          <th></th>
          <th>Account</th>
          <th>Voting Power</th>  
          <th>Proofs in Epoch</th>
          <th>Can Create Account</th>
        </tr>
      </thead>
      <tbody>
        {#each set as val, i}
          <tr>
            <td>{i + 1}</td>
            <td>{val.account_address}</td>
            <td>{val.voting_power}</td>
            <td>{val.count_proofs_in_epoch}</td>
            <td>{can_create_account(val)}</td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
</main>
