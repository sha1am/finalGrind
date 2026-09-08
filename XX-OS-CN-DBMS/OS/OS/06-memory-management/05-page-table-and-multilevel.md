# Page Tables and Multilevel Paging

A page table maps virtual page numbers to physical frames plus metadata such as valid/present, permissions and access/dirty state.

### Why multilevel page tables?

A flat page table can be huge for a sparse address space. Multilevel tables allocate lower-level tables only for portions actually used.

```text
VPN
 |
 v
L1 -> L2 -> L3 -> PTE -> frame
```

Trade-off: fewer allocated table pages for sparse spaces, but more memory references on a TLB miss.
## Small example

A process with a huge 48-bit virtual address space may use only a small region. A flat page table would reserve entries for the whole space; multilevel paging lets unused lower-level tables remain unallocated.
