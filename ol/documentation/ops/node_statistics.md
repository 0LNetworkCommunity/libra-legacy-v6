# Node Statistics

## TL;DR

From within node: `curl http://localhost:9101/metrics`
Filter with grep: `curl http://localhost:9101/metrics | grep epoch`

Or, enable port 9102 in your firewall if you want these to be public.


## Metrics APIs
There are three URLs on your node which can be used to gather metrics.

- Port 9101 - intended to be public facing. Access with http://<your-ip>:9101/metrics
- Port 9102 - intended to be private to operator. Access with http://<your-ip>:9102/metrics
- Port 6191 - intended to be private(?) related to admission control. Access with http://<your-ip>:6191/metrics or /events

### 9101/metrics

Produces a flat file, about 1000 lines very detailed metrics, including epoch and quorum information:

```
executor_duration_bucket{op="block_execute_time_s",le="0.005"} 0
executor_duration_bucket{op="block_execute_time_s",le="0.01"} 0
executor_duration_bucket{op="block_execute_time_s",le="0.025"} 3379
executor_duration_bucket{op="block_execute_time_s",le="0.05"} 3385
executor_duration_bucket{op="block_execute_time_s",le="0.1"} 3385
executor_duration_bucket{op="block_execute_time_s",le="0.25"} 3385
executor_duration_bucket{op="block_execute_time_s",le="0.5"} 3385
executor_duration_bucket{op="block_execute_time_s",le="1"} 3385
executor_duration_bucket{op="block_execute_time_s",le="2.5"} 3385
executor_duration_bucket{op="block_execute_time_s",le="5"} 3385
executor_duration_bucket{op="block_execute_time_s",le="10"} 3385
executor_duration_bucket{op="block_execute_time_s",le="+Inf"} 3385

```

## Port 9102/metrics
Produces only one line about how many peers are connected to that node:
`libra_network_peers{role_type="validator",state="connected"} 7`

## Port 6191/metrics
Produces what appears to be a  subset of the 9101 metrics, but structured as JSON.

## Port 6191/events
Produces about thousands lines of event logs related to admission control. e.g.
```
[{"name":"trace_event","timestamp":1597419122207,"json":{"duration":"523µs","node":"block::d8a98492","path":"executor","stage":"executor::process_vm_outputs::done"}},{"name":"trace_event","timestamp":1597419122207,"json":{"duration":"18ms","node":"block::d8a98492","path":"consensus::block_storage::block_store","stage":"block_store::execute_block::done"}},{"name":"trace_event","timestamp":1597419122207,"json":{"duration":null,"node":"block::d8a98492","path":"consensus::persistent_liveness_storage","stage":"consensusdb::save_tree"}},{"name":"trace_event","timestamp":1597419122212,"json":{"duration":"4ms","node":"block::d8a98492","path":"consensus::persistent_liveness_storage","stage":"consensusdb::save_tree::done"}},{"name":"trace_event","timestamp":1597419122215,"json":{"duration":"26ms","node":"block::d8a98492","path":"consensus::round_manager","stage":"round_manager::execute_and_vote::done"}},
```


# Configuration
In node.configs.toml the metrics ports are specified, as in this line:
```
[debug_interface]
admission_control_node_debug_port = 6191
metrics_server_port = 9101
public_metrics_server_port = 9102
address = "0.0.0.0"
```

# Query

There is a module NodeDebugClient in common/debug-interface/src/lib.rs, which allows for programmatically consuming node data. This is a thin wrapper making http requests to the above API.