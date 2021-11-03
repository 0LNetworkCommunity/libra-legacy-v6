<script lang="ts">
  import { invoke } from "@tauri-apps/api/tauri";
  import { responses } from "../../debug";
  import DemoTx from "../txs/DemoTx.svelte";
  import { raise_error } from "../../carpeError";
  import { listen } from '@tauri-apps/api/event'
  import { onMount } from "svelte";
  import { getCurrent } from '@tauri-apps/api/window'

  const makeError = async () => {
    invoke("debug_error", {
      debugErr: false,
    })
    .then((res) => responses.set(res))
    .catch((e) => raise_error(e));
  };

  const triggerEventFromRustToJs = async () => {
    invoke("debug_emit_event", {})
    .then((res) => responses.set(res))
    .catch((e) => raise_error(e));
  };

  function emitEventFromHereToRust() {

    // emit an event that are only visible to the current window
    const current = getCurrent();
    current.emit('emit-from-window', 'Tauri is awesome!');
  };
  const debugStartListener = async () => {
    invoke("debug_start_listener", {})
      .then((res) => {
        responses.set(res);
      })
      .catch((e) => console.error(e));
  };


  

  const init = async () => {
    invoke("init_user", {
      authkey: authkey_string,
      account: account_string,
      // pathStr: home,
    })
      .then((res) => {
        responses.set(res);
      })
      .catch((e) => console.error(e));
  };


  const testAsync = async () => {
    invoke("delay_async", {})
      .then((res) => {
        responses.set(res);
      })
      .catch((e) => console.error(e));
  };


    const startForever = async () => {
    invoke("start_forever_task", {})
      .then((res) => {
        responses.set(res);
      })
      .catch((e) => console.error(e));
  };

  const killForever = async () => {
    const current = getCurrent();
    current.emit('kill_forever', 'Tauri is awesome!');
  };


  
  const startMockTowerListener = async () => {
    console.log("start tower listener")
    invoke("mock_build_tower", {success: true})
      .then((res) => {
        responses.set(res);
      })
      .catch((e) => console.error(e));
  };

  const mockTowerOnce = async () => {
    const current = getCurrent();
    current.emit('mock-tower-make-proof', 'Tauri is awesome!');
  };

  const mockTowerOnceFail = async () => {
    invoke("mock_build_tower", {success: false})
      .then((res) => {
        responses.set(res);
      })
      .catch((e) => console.error(e));
  };

  // let listener_handle;


  onMount(() => {
    let a = listen('event-name', event => {
      console.log(event);
      window.alert(event.payload.message);
    });
  })

</script>

<main>
  <div>
    <div class="margin">
      <button class="uk-button uk-button-default" on:click={makeError}>Make Error</button>

      <button class="uk-button uk-button-default" on:click={triggerEventFromRustToJs}>Receive Event</button>

      
      <button class="uk-button uk-button-default" on:click={debugStartListener}>Start Listener</button>

      <button class="uk-button uk-button-default" on:click={emitEventFromHereToRust}>Send Event</button>
    </div>

    <div class="margin">
      <h4> Tower </h4>
      
      <button class="uk-button uk-button-default" on:click={startMockTowerListener}>Start Mock Tower Listener </button>

      <button class="uk-button uk-button-default" on:click={mockTowerOnce}>Mock Tower Once</button>
      <button class="uk-button uk-button-default" on:click={mockTowerOnceFail}>Mock Tower Once Fail</button>

    </div>


    <div class="margin">

    <button class="uk-button uk-button-default" on:click={testAsync}>Async</button>
    <button class="uk-button uk-button-default" on:click={startForever}>Start Forever</button>
    <button class="uk-button uk-button-default" on:click={killForever}>Kill Forever</button>

    </div>



    <button class="uk-button uk-button-default" on:click={init}>Init</button>


    <DemoTx />
  </div>
</main>
