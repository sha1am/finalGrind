# Virtual Memory and Demand Paging

Virtual memory gives each process a private virtual address space that the OS maps onto physical memory. Not every virtual page must be resident in RAM immediately.

**Demand paging:** load a page when it is actually referenced.

Benefits:
- run programs whose total virtual footprint exceeds physical RAM;
- share pages efficiently;
- reduce startup work.

The trade-off is that a first access to a non-resident page can trigger a very expensive page fault.
## Small example

A process may have a large virtual address space even though only a fraction is resident in RAM. Pages that have not been needed yet do not have to occupy physical frames immediately.
