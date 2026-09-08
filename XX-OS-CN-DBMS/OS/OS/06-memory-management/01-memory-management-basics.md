# Memory Management Basics

The OS must allocate memory, isolate processes, translate addresses, reclaim unused pages and provide abstractions such as virtual memory.

### Logical/virtual vs physical address

A program generates a **virtual address**. Hardware plus OS-managed page tables translate it to a physical address.

```text
CPU virtual address
       |
       v
MMU + page tables + TLB
       |
       v
physical memory
```

## Why virtual memory?

- isolation
- relocation
- sharing
- sparse address spaces
- ability to use disk as backing storage when needed
