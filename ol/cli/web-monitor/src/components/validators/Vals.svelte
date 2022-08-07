<script lang="ts">
  import AddressNoteTip from '../address/AddressNoteTip.svelte';
  import Network from './Network.svelte';
  import ValidatorModal from "./ValidatorModal.svelte";
  export let data;

  const modal_id = "vals-tab-val-modal";
  let view = "Chain";
  interface ValInfo {
    note: String;
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
    vote_count_in_epoch: Number;
    prop_count_in_epoch: Number;
    burn_to_community: boolean;
  }
  
  let set: ValInfo[] = [];
  let selectedVal: ValInfo = null;
  let sortableColumns = [
    { label: "voting power", sortKey: "voting_power" },
    { label: "proofs in epoch", sortKey: "count_proofs_in_epoch" },
    { label: "tower height", sortKey: "tower_height" },
    { label: "votes in epoch", sortKey: "vote_count_in_epoch" },
    { label: "props in epoch", sortKey: "prop_count_in_epoch" },
    { label: "burn to comm", sortKey: "burn_to_community" },
  ];
  let sortOption: string = "voting_power";
  let sortOrder = 1;

  let has_notes = false;
  $: if (data.chain_view && data.chain_view.validator_view) {
    set = data.chain_view.validator_view;
    has_notes = set.some(e => e.note != "");
    if (selectedVal == null) {
      // initial selection
      selectedVal = set[0];
    }
  }
  $: set = set.sort((a, b) => (a[sortOption] > b[sortOption]) ? sortOrder : -sortOrder);
  
  function thOnClick(key: string) {
    if (sortOption == key) {
      sortOrder = -sortOrder;
    }
    sortOption = key;
  }
</script>

<style>
  .owner {
    background: #E6E6E6;
  }
</style>

<main uk-height-viewport="expand: true">
  <h2 class="uk-text-center uk-text-uppercase uk-text-muted uk-text-light uk-margin-medium-bottom">
    <span>{set.length} Validators {#if !has_notes}<AddressNoteTip />{/if}</span>
  </h2>

  <div id="radio2" on:click={() => { view = document.querySelector('input[name="radio2"]:checked').value }} class="uk-margin uk-grid-small uk-child-width-auto uk-align-center uk-text-center" uk-grid>
    <label><input class="uk-radio" type="radio" name="radio2" value="Chain" checked> Chain</label>
    <label><input class="uk-radio" type="radio" name="radio2" value="Network"> Network</label>
  </div>
  
  {#if view == "Chain"}

    <div class="uk-overflow-auto">
      <table class="uk-table uk-table-hover uk-text-muted">
        <thead>
          <tr>
              {#if has_notes}
                <th class="uk-text-center">note</th>
              {/if}
              <th class="uk-text-center">account</th>
              {#each sortableColumns as col}
                <th class="uk-text-right" on:click={() => thOnClick(col.sortKey)}>
                  <span class="disable-select">{col.label}</span>
                  {#if sortOption == col.sortKey}
                    {#if sortOrder == 1}
                      <span uk-icon="icon: triangle-up"></span>
                    {:else}
                      <span uk-icon="icon: triangle-down"></span>
                    {/if}
                  {/if}
                </th>
              {/each}
              <th></th>
          </tr>
        </thead>
        <tbody>
          {#each set as val, i}
          <tr class="{val.account_address === data.account_view.address ? 'owner' : ''}" on:click={() => selectedVal = val}>        
              {#if has_notes}
                <td class="uk-text-center">{val.note}</td>
              {/if}
              <td class="uk-visible@s uk-text-center">{val.account_address}</td>
              <td class="uk-hidden@s uk-text-truncate">{val.account_address}</td>
              <td class="uk-text-right">{val.voting_power}</td>
              <td class="uk-text-right">{val.count_proofs_in_epoch}</td>
              <td class="uk-text-right">{val.tower_height}</td>
              <td class="uk-text-right">{val.vote_count_in_epoch}</td>
              <td class="uk-text-right">{val.prop_count_in_epoch}</td>
              <td class="uk-text-right">{val.burn_to_community}</td>
              <td>
                <span uk-icon="icon: info" uk-toggle="target: #{modal_id}"></span>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {:else} 
    <!--Network-->
    <Network {data}/>

  {/if}
  <ValidatorModal validator={selectedVal} id={modal_id}></ValidatorModal>
</main>
