<script lang="ts">
  import {tower, getTowerChainView} from "../../miner";
  import { onMount } from "svelte";
  import { signingAccount } from "../../accounts";
  import type { AccountEntry } from "../../accounts";

  let towerState;
  let my_account; // Todo change to be a template Prop

  tower.subscribe((m) => {
    console.log(m);
    towerState = m;
  });

  signingAccount.subscribe((m) => {
    console.log(m);
    my_account = m;
    getTowerChainView();
  });

  onMount(() => {
    getTowerChainView();
  });

</script>

<main>

  {#if towerState.on_chain}
    <table class="uk-table uk-table-divider">
    <thead>
        <tr>
            <th></th>
            <th>Tower Height</th>
            <th>Last Epoch Mined</th>
            <th>Proofs This Epoch</th>
            <th>Hash</th>
            
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>{my_account.nickname}</td>
            <td>{towerState.on_chain.verified_tower_height}</td>
            <td>{towerState.on_chain.latest_epoch_mining}</td>
            <td>{towerState.on_chain.count_proofs_in_epoch}</td>
            <td>{towerState.on_chain.previous_proof_hash.slice(0,3)}</td>

            
            <!-- <td>Table Data</td> -->
        </tr>
    </tbody>
</table>

  {/if}

</main>