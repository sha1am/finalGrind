# Inverted Page Table

A conventional page table is organized around virtual pages for a process. An **inverted page table** has roughly one entry per physical frame and records which virtual page/process currently occupies it.

### Motivation

Reduce page-table memory for systems with very large virtual address spaces.

### Trade-off

Translation lookup becomes less direct; hashing or other lookup mechanisms are typically needed.

**Interview:** it is a memory-saving organization, not a replacement for virtual memory itself.
