# Contiguous Allocation and Fragmentation

In contiguous allocation, a process receives one contiguous physical region.

### Internal fragmentation
Allocated block is larger than requested; unused space lies **inside** an allocated block.

### External fragmentation
Free memory exists but is split into small non-contiguous holes.

Compaction can reduce external fragmentation but is expensive and may require relocation.

## Interview shortcut

```text
Internal = waste inside allocated blocks
External = free space outside blocks, but scattered
```
