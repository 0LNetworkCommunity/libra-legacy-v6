<script lang="ts">
  import { Link } from "svelte-navigator";
  import { onMount } from "svelte";
  import type { CarpeError } from "../../carpeError";
  import { raise_error } from "../../carpeError";
  import { Networks, network_profile, setNetwork } from "../../networks";
  import type { NetworkProfile} from "../../networks";
  import UIkit from "uikit";
  import { invoke } from "@tauri-apps/api/tauri";
  
  let upstream_url = "http://1.1.1.1:8080";
  let waypoint = "";
  let current_chain_id = "";

  network_profile.subscribe((n) => {
    upstream_url = n.url;
    waypoint = n.waypoint;
    current_chain_id = n.chain_id;
  });

  function updateNetwork() {
    // check input data
    // submit
    invoke("update_upstream", { url: upstream_url, wp: waypoint })
      .then((res: NetworkProfile) => {
        network_profile.set(res);
        UIkit.notification({
          message: "<span uk-icon='icon: check'></span> Network Settings Updated",
          pos: "bottom-center",
          status: "success",
          timeout: 3000,
        });
      })
      .catch((error) => {
        raise_error(error as CarpeError);
      });
  }

  function get() {
    // check input data
    // submit
    invoke("get_networks", {})
      .then((res: NetworkProfile) => network_profile.set(res))
      .catch((error) => raise_error(error));
  }

  function refreshWaypoint() {
    // check input data
    // submit
    invoke("refresh_waypoint", {})
      .then((res: NetworkProfile) => network_profile.set(res))
      .catch((error) => raise_error(error));
  }

  // function toggleNetwork(network: Networks) {
  //   invoke("toggle_network", {network: network})
  //     .then((res: NetworkProfile) => network_profile.set(res))
  //     .catch((error) => raise_error(error));
  // }
  // // TODO: is this the correct event?
  onMount(async () => {
    get();
  });


  function isChainId(chain: string): boolean {
    return current_chain_id == chain
  }

</script>

<main>
  <h4 class="uk-text-light uk-text-uppercase uk-text-muted uk-text-thin"> Network Connection</h4>
  <div class="uk-margin uk-grid-small uk-child-width-auto uk-grid">
      <label><input class="uk-radio" type="radio" name="radio2" checked={current_chain_id  == "Mainnet"} on:click={() => setNetwork(Networks.Mainnet)}> Mainnet </label>
      <label><input class="uk-radio" type="radio" name="radio2" checked={ current_chain_id == "Rex"} on:click={() => setNetwork(Networks.Rex)}> Rex (testnet) </label>
  </div>

  <h4 class="uk-text-light uk-text-uppercase uk-text-muted uk-text-thin"> Override Settings </h4>
  <form id="account-form">
    <fieldset class="uk-fieldset">
      <div class="uk-margin uk-inline-block uk-width-1-1">
        <span> URL of upstream node</span>
        <input
          class="uk-input"
          type="text"
          placeholder={upstream_url}
          bind:value={upstream_url}
        />
      </div>

      <div class="uk-margin uk-inline-block uk-width-1-1">
        <span> Waypoint </span>
        <input
          class="uk-input"
          type="text"
          placeholder={waypoint}
          bind:value={waypoint}
        />
      </div>

      <div>
        <span
          on:click={updateNetwork}
          class="uk-button uk-button-primary uk-align-right"
          id="add-btn">Add</span
        >
        <Link to="/">
          <span class="uk-button uk-button-default uk-align-right">Cancel</span>
        </Link>
      </div>
    </fieldset>
  </form>

  <button class="uk-button uk-button-default" on:click={refreshWaypoint}>Fetch Waypoint</button>
</main>
