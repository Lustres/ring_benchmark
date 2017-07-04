# ring_benchmark
Ring benchmark for Erlang

## Build
	$ cd ring_benchmark && erlc ring_benchmark.erl

## Run
	$ erl
	$ ring_benchmark:start(1000, 100).
	
## Tips
You could use `erl +S 1` to start erl with disabled SMP and check the effect on benchmark result.

