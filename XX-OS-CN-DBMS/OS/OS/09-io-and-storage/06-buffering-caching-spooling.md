# Buffering, Caching and Spooling

**Buffering:** temporarily holds data to absorb speed/size mismatches between producer and consumer.

**Caching:** keeps likely-to-be-reused data closer to the consumer to reduce latency.

**Spooling:** queues work for a device/resource that processes jobs sequentially or asynchronously, classically printer jobs.

```text
buffering = smooth transfer
caching   = reuse data faster
spooling  = queue jobs for later device processing
```
## Small example

A video producer may generate data faster than a consumer can process it. A buffer absorbs short bursts. A cache is different: it keeps previously fetched data because it is likely to be reused.
