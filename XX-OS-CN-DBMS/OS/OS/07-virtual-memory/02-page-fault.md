# Page Fault

A page fault occurs when a process accesses a virtual page that cannot currently be used as a normal resident mapping.

Typical flow:

1. CPU references virtual address.
2. TLB/page-table check indicates not present or permission fault.
3. CPU traps into kernel.
4. Kernel validates the access.
5. If valid but non-resident, locate backing data and a frame.
6. Read page into memory; update page table/TLB.
7. Retry the instruction.

A page fault is much slower than a cache/TLB hit because it may involve storage I/O.
## Small example

If a page-table entry says a page is not resident and the CPU accesses it:

```text
load address → page fault → kernel handles it → page becomes resident → instruction retries
```

A page fault is a control-flow event; it is not synonymous with “read from disk,” because the required page may already be available from another source.

## Sharpen this concept

- [Linux memory-management concepts](https://docs.kernel.org/admin-guide/mm/concepts.html) — connects virtual memory, reclaim and physical-page behavior.
- [OSTEP](https://pages.cs.wisc.edu/~remzi/OSTEP/) — especially useful for demand paging and replacement intuition.
