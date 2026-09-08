# Memory Pressure and OOM

When memory demand exceeds available physical memory, the OS can reclaim caches, evict pages, swap where configured, or ultimately terminate processes under an out-of-memory policy.

### Important distinction

A process can have a large virtual address space without consuming the same amount of physical RAM. Physical residency depends on actual mappings, demand paging, shared pages, caches and other factors.

### Backend implication

A service can appear healthy while gradually increasing RSS. If reclaim cannot keep up, latency may spike from reclaim/swap activity before an OOM event occurs.
## Small example

A process reporting high RSS does not automatically mean a memory leak. Some memory may be file-backed cache or shared pages. When diagnosing memory pressure, distinguish private anonymous memory, shared mappings, and reclaimable page cache.
