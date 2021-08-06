<script>
  export let content;
  export let alertLevel;
</script>

<div uk-alert class={alertLevel}>
  {content}

  <a class="uk-alert-close" uk-close />
</div>
