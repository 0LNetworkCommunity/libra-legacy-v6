<script lang="ts">
  import UIkit from "uikit";
  import Icons from "uikit/dist/js/uikit-icons";
  import Miner from "./miner/Miner.svelte";
  import Wallet from "./wallet/Wallet.svelte";
  import Settings from "./settings/Settings.svelte";
  import DevMode from "./dev/DevMode.svelte";
  UIkit.use(Icons);
</script>

<main>
  <div class="uk-container uk-container-expand uk-margin-top">
    <a uk-navbar-toggle-icon uk-toggle="target: #offcanvas-nav-primary" />

    <ul id="component-nav" class="uk-switcher">
      <li id="miner-panel">
        <Wallet />
      </li>
      <li id="miner-panel">
        <Miner />
      </li>
      <li id="miner-panel">
        <Settings />
      </li>
      <li id="dev-panel">
        <DevMode />
      </li>
    </ul>

    <div id="offcanvas-nav-primary" uk-offcanvas="mode: push">
      <div
        class="uk-offcanvas-bar uk-flex uk-flex-column uk-offcanvas-bar-override"
      >
        <span class="uk-align-center uk-text-large uk-text-bold uk-logo"
          >CARPE</span
        >
        <ul
          class="uk-nav uk-nav-primary uk-nav-left uk-margin-auto-vertical"
          uk-switcher="connect: #component-nav"
        >
          <li class="uk-margin">
            <a class="uk-flex uk-flex-column" href="/wallet">
              <span
                class="uk-text-light"
                uk-icon="icon: credit-card; ratio: 1"
              />
              <span class="uk-text-light uk-text-uppercase uk-text-default"
                >Wallet</span
              >
            </a>
          </li>
          <li class="uk-margin">
            <a class="uk-flex uk-flex-column" href="/miner">
              <span
                class="uk-text-light"
                uk-switcher="connect: #miner-panel"
                uk-icon="icon: play; ratio: 1"
              />
              <span class="uk-text-light uk-text-uppercase uk-text-default"
                >Miner</span
              >
            </a>
          </li>
          <li class="uk-margin">
            <a class="uk-flex uk-flex-column" href="/settings">
              <span class="uk-text-light" uk-icon="icon: settings; ratio: 1" />
              <span class="uk-text-light uk-text-uppercase uk-text-default"
                >Settings</span
              >
            </a>
          </li>
          <li class="uk-margin">
            <a class="uk-flex uk-flex-column" href="/dev">
              <span
                class="uk-text-light"
                uk-toggle="target: #dev-panel"
                uk-icon="icon: code; ratio: 1"
              />
              <span class="uk-text-light uk-text-uppercase uk-text-default"
                >Dev</span
              >
            </a>
          </li>
        </ul>
      </div>
    </div>
  </div>
</main>
