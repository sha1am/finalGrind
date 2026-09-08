# FIFO, LRU and Optimal Page Replacement

### FIFO
Evict the oldest loaded page. Simple but can behave poorly and can exhibit **Belady’s anomaly** for some reference strings.

### LRU
Evict the page least recently used. It exploits temporal locality but exact implementation can be expensive.

### Optimal
Evict the page whose next use is farthest in the future. It is optimal for minimizing page faults but requires future knowledge, so it is mainly a theoretical benchmark.

## Interview comparison

```text
FIFO = age
LRU = recent history
Optimal = future knowledge
```
## Small example

For reference string `A B A C A B` with a small number of frames, LRU prefers evicting the page that has gone unused for the longest time. Optimal instead evicts the page whose next use is farthest in the future—useful as a theoretical lower bound because real systems do not know the future.
