<script lang="ts">
  export let isTrue: bool = true;
  export let title: string = undefined;
  export let description: string = undefined;
</script>

<div>
  <dt>
    {#if isTrue}
      <span
        class="uk-margin-small-right uk-text-success"
        uk-icon="icon: check; ratio: 1"
      />
    {:else}
      <span
        class="uk-margin-small-right uk-text-warning"
        uk-icon="icon: warning; ratio: 1"
      />
    {/if}
    <span class="uk-text-uppercase"> {title} </span>
  </dt>
  <dd>{description}</dd>
</div>
