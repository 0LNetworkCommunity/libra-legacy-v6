<script lang="ts">
    let mode: string = undefined;
    import { chainInfo } from "../../../store.ts";
  
    chainInfo.subscribe((info_str) => {
      let chain = JSON.parse(info_str);
      if (chain.host_state) {
        mode = chain.host_state.node_state;
      }
    });
  </script>
  
    <div class="uk-text-center uk-text-muted">
        Node is running in mode: {mode}
    </div>
  