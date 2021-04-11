<script lang="ts">
  import { onMount } from "svelte";
  import { sortBy } from "lodash";

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
      set = sortBy(set, ["voting_power"]).reverse();
    };
  });

  function can_create_account(info: ValInfo): Boolean {
    return info.epochs_since_last_account_creation > 7;
  }
</script>
<style>
  /* TODO: get styles to work. svelte or uikit are overriding these. */
  .like-accordion-title {
    display: block;
    font-size: 1.25rem;
    line-height: 1.4;
    color: #333;
    overflow: hidden;
    margin-left: 10px;
  }
</style>


<main>
  <h2
    class=" uk-text-center uk-text-uppercase uk-text-muted uk-text-light uk-margin-medium-bottom"
  >
    <span>{set.length} Validators</span>
  </h2>

  <div class="uk-text-muted">
    <div class="uk-column-1-4 uk-child-width-expand@s uk-text-center uk-text-uppercase uk-text-light uk-text-small">
      <div>account</div>
      <div>voting power</div>
      <div>proofs in epoch</div>
      <div>tower height</div>
    </div>
  </div>

  <ul uk-accordion>
    {#each set as val, i}
      <li>
        <div class="uk-accordion-title">
          <div class="uk-column-1-4 uk-child-width-expand@s uk-text-center">
            <div>{val.account_address}</div>
            <div>{val.voting_power}</div>
            <div>{val.count_proofs_in_epoch}</div>
            <div>{val.tower_height}</div>
          </div>
        </div>
        <div class="uk-accordion-content">
          <table class="uk-table">
            <tbody>
              <tr>
                <td>fullnode network address</td>
                <td class="uk-text-break"> {val.full_node_ip} </td>
              </tr>
              <tr>
                <td>validator network address</td>
                <td class="uk-text-break">{val.validator_ip}</td>
              </tr>
              <tr>
                <td>epochs validating and mining</td>
                <td>{val.epochs_validating_and_mining}</td>
              </tr>
              <tr>
                <td>can create account</td>
                <td>{can_create_account(val)}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </li>
    {/each}
  </ul>
</main>
