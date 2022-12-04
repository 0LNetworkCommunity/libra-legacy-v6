<script>
  import { onMount } from "svelte";
  let foo;

  onMount(async () => {
    await fetch(`https://reqres.in/api/users?page=2`)
      .then((r) => r.json())
      .then((data) => {
        foo = data;
      });
  });
</script>

<main>
  {#if foo}
    {foo.per_page}
  {/if}
</main>
