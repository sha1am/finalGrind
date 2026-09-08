# Translation Lookaside Buffer (TLB)

The TLB is a small, fast cache of recent virtual-page → physical-frame translations.

```text
CPU virtual address
      |
      v
     TLB --hit--> frame
      |
     miss
      v
 page table walk
      |
      v
 update TLB
```

A TLB hit avoids walking page tables in the common case.

### TLB vs cache

A CPU data cache stores data; a TLB caches address translations. Both exploit locality but cache different information.
## Small example

If a loop repeatedly accesses addresses in the same few pages, the TLB can keep those translations hot:

```text
virtual page 7 → frame 42
virtual page 8 → frame 11

loop accesses page 7, page 7, page 8, page 7...
→ mostly TLB hits
```

## Sharpen this concept

- [Linux memory-management documentation](https://docs.kernel.org/admin-guide/mm/) — useful after the basic page-table/TLB model is clear.
- [OSTEP](https://pages.cs.wisc.edu/~remzi/OSTEP/) — use the virtual-memory chapters for intuition before reading implementation details.
