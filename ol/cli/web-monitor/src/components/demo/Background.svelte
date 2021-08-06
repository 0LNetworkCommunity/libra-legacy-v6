<script>
  export let content = "default content";
  export let type = "uk-background-default ";
  export let component = undefined;
  // export let props = {
  //   alertLevel: "uk-alert-primary",
  // };
  export let componentProperties;

  let finalType = type + "uk-padding uk-panel";

</script>

<div>
  <div class={finalType}>
    <svelte:component this={component} {...componentProperties}/>
  </div>
</div>
