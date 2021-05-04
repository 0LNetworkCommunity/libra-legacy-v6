<script>
	import Alert from "./Alert.svelte";
	import Background from "./Background.svelte";

  let props = { 
    alertLevel: "uk-alert-primary",
    content: "yo",
  };

</script>

<main>
  <Background component={Alert} componentProperties={props} /> 
</main>