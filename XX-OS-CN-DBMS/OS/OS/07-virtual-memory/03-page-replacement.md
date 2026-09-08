# Page Replacement

When memory is full and a new page must be loaded, the OS may need to evict a resident page.

Good replacement policies try to evict pages unlikely to be needed soon.

Important metadata includes reference/use and dirty state. A dirty page generally needs write-back before its frame can be safely reused if the backing copy is stale.
## Small example

If all frames are occupied and a new page must be loaded, the OS needs a victim:

```text
frames: [A][B][C]
need: D
choose victim → replace it with D
```

The replacement policy tries to choose a page whose eviction is least harmful.
