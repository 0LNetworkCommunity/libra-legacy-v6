import { writable } from 'svelte/store'

export const chainInfo = writable('Chain');
chainInfo.set("{}");
let uri = "http://" + location.host + "/chain_live";
let sse = new EventSource(uri);

sse.onmessage = function (msg) {
  chainInfo.update(existing => msg.data)
}

