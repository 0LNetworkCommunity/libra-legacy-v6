<script lang="ts">
  import AutoPaySummary from "./AutoPaySummary.svelte";
  import AddressNoteTip from '../address/AddressNoteTip.svelte';
  import "/layout/Style.svelte";
  export let account;

  let payments;
  let has_notes = false;
  $: if (account && account.autopay) {
    payments = account.autopay.payments;
    has_notes = payments.some(e => e.note != "");
  }
</script>

<div>
  <h2 class="uk-text-center uk-text-uppercase uk-text-muted uk-text-light uk-margin-medium-bottom">
    Autopay Instructions {#if payments && payments.length > 0 && !has_notes}<AddressNoteTip />{/if}
  </h2>
  
  {#if payments}
    {#if payments.length > 0}
      <AutoPaySummary payments={payments}/>
      <div class="uk-overflow-auto">
        <table class="uk-table uk-table-hover">
          <thead>
            <tr>
              <th class="uk-text-center">uid</th>
              {#if has_notes}<th class="uk-text-center">note</th>{/if}
              <th class="uk-text-center">payee</th>
              <th class="uk-text-center">type</th>
              <th class="uk-text-center">end epoch</th>
              <th class="uk-text-center">amount</th>
            </tr>
          </thead>
          <tbody>
            {#each payments as {uid, note, type_desc, payee, end_epoch, amount}}
              <tr>
                <td class="uk-text-center">{uid}</td>
                {#if has_notes}<td class="uk-text-center">{note}</td>{/if}
                <td class="uk-visible@s uk-text-center">{payee}</td>
                <td class="uk-hidden@s uk-text-truncate">{payee}</td>
                <td class="uk-text-center">{type_desc}</td>
                <td class="uk-text-right">{end_epoch}</td>
                <td class="uk-text-right">{amount}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {:else}
      <p class="uk-text-center uk-text-warning">Your validator does not have autopay instructions.</p>
    {/if}
  {:else}
    <p>loading...</p>
  {/if}
</div>