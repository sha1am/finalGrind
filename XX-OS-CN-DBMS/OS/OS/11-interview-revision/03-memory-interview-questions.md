# Memory Interview Questions

### Q: Why do we need a TLB?
**A:** Page-table translation can require multiple memory accesses. A TLB caches recent translations so common accesses avoid a page-table walk.

### Q: What happens on a page fault?
**A:** CPU traps to kernel; kernel validates access, obtains a free/evicted frame, loads the page if needed, updates mappings, then retries the instruction.

### Q: Why is a page fault slow?
**A:** It can require kernel work and storage I/O, which is orders of magnitude slower than RAM/cache operations.

### Q: Why use virtual memory?
**A:** Isolation, relocation, sharing, sparse address spaces and demand paging.

### Q: What is thrashing?
**A:** Excessive paging activity that leaves little time for useful computation.

### Q: What is copy-on-write?
**A:** Multiple mappings initially share a page; a write triggers a private copy.
