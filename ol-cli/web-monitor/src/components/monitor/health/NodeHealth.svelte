<script lang="ts">
  import Check from "./Check.svelte";
  import { onMount, onDestroy } from "svelte";
  import { map } from "lodash";

  let healthData;
  let uri = "http://" + location.host + "/check";
  let sse = new EventSource(uri);
  onMount(async () => {
    sse.onmessage = function (msg) {
      healthData = JSON.parse(msg.data);

      allChecks = map(allChecks, (i: CheckObj) => {
        if (i.id === "config") {
          i.is_true = healthData.configs_exist;
        }
        if (i.id === "account") {
          i.is_true = healthData.account_created;
        }
        if (i.id === "restore") {
          i.is_true = healthData.db_restored;
        }
        if (i.id === "node") {
          i.is_true = healthData.node_running;
        }
        if (i.id === "miner") {
          i.is_true = healthData.miner_running;
        }
        if (i.id === "sync") {
          i.is_true = healthData.is_synced;
        }
        if (i.id === "set") {
          i.is_true = healthData.validator_set;
        }
        return i;
      });
    };
  });

  onDestroy(() => {
    sse.close();
  });

  interface CheckObj {
    id: string;
    title: string;
    description: string;
    is_true: Boolean;
  }

  let allChecks: CheckObj[] = [
    {
      id: "config",
      title: "Node configured",
      description: "operator files created",
      is_true: false,
    },
    {
      id: "restore",
      title: "DB boostrapped",
      description: "db successfully initialized",
      is_true: false,
    },
    {
      id: "account",
      title: "Account exists",
      description: "owner account created on chain",
      is_true: false,
    },
    {
      id: "miner",
      title: "Miner is running",
      description: "process `miner` has started",
      is_true: false,
    },
    {
      id: "node",
      title: "Node is running",
      description: "process `libra-node` has started",
      is_true: false,
    },
    {
      id: "sync",
      title: "Node is synced",
      description: "node is up to date with upstream",
      is_true: false,
    },
    {
      id: "set",
      title: "In validator set",
      description: "owner account is in the validator set",
      is_true: false,
    },
  ];
</script>

<main>
  {#if healthData}
    <div class="uk-card uk-card-default uk-card-body">
      <h3 class="uk-card-title uk-text-center uk-text-uppercase uk-text-muted">
        Node Health
      </h3>
      <dl class="uk-description-list">
        {#each allChecks as c}
          <Check
            title={c.title}
            description={c.description}
            isTrue={c.is_true}
          />
        {/each}
      </dl>
    </div>
  {/if}
</main>
