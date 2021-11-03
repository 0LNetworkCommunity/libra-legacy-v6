<script lang="ts">
  import { backlog_in_progress, submitBacklog } from "../../miner";

  let inProgress;
  backlog_in_progress.subscribe((b) => (inProgress = b));
</script>

<main class="uk-margin" >
  <h4 class="uk-text-light uk-text-uppercase uk-text-muted uk-text-thin">
    Flush Miner Backlog
  </h4>
  <div class="uk-margin uk-grid">
    <div>
      {#if !inProgress}
        <button class="uk-button uk-button-default" on:click={submitBacklog}>
          Submit Backlog
        </button>
      {:else}
        <button class="uk-button" disabled>Backlog in Progress</button>
      {/if}
    </div>

    <div class="uk-margin">
      <span>
        If you suspect your miner proofs are not being committed to chain, you
        can attempt to resend any that have not been sent.
      </span>
    </div>
  </div>
</main>
