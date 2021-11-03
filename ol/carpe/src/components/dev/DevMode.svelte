<script lang="ts">
  import DebugCard from "./DebugCard.svelte";
  import DebugActions from "./DebugActions.svelte";
import { Link } from "svelte-navigator";
  // import Swarm from "./Swarm.svelte";

</script>

<main class="uk-height-viewport">
  <div class="uk-margin uk-container uk-dark">
      <div class="uk-margin">

        <DebugCard />
        <DebugActions />
        
        <div class="margin">
          <Link to="swarm"><button class="uk-button uk-button-default">Swarm Controls</button></Link>
         </div>
        

    </div>
  </div>
</main>
