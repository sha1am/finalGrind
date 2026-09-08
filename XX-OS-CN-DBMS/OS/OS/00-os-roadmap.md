# OS Roadmap

## Interview map

```text
OS
├── Kernel boundary
│   ├── user mode / kernel mode
│   ├── system calls
│   └── interrupts / traps
├── Processes & threads
│   ├── lifecycle / PCB
│   ├── context switch
│   ├── fork / exec / wait
│   └── IPC
├── CPU scheduling
│   ├── FCFS / SJF / SRTF
│   ├── Round Robin / Priority
│   └── MLFQ
├── Synchronization
│   ├── critical section / race
│   ├── mutex / semaphore / monitor
│   └── classic problems
├── Deadlocks
│   ├── four conditions
│   ├── prevention / avoidance
│   └── Banker / detection / recovery
├── Memory
│   ├── allocation / fragmentation
│   ├── paging / page tables / TLB
│   └── segmentation
├── Virtual memory
│   ├── demand paging
│   ├── page faults / replacement
│   └── thrashing / working set
├── File systems
│   ├── allocation / directories
│   ├── inode / links
│   └── durability / journaling
└── I/O + storage
    ├── interrupts / DMA
    ├── disk scheduling
    └── buffering / caching / async I/O
```

## Highest-yield questions

1. Process vs thread?
2. Process vs program?
3. What happens during a context switch?
4. What happens when a program makes a system call?
5. Mutex vs semaphore?
6. What is a race condition? How do you prevent it?
7. Deadlock vs starvation?
8. Explain the four deadlock conditions.
9. Paging vs segmentation?
10. What is a page fault?
11. Why is a TLB needed?
12. What is virtual memory?
13. What causes thrashing?
14. Hard link vs symbolic link?
15. What is an inode?
16. Interrupt vs system call?
17. Interrupt vs polling?
18. What is DMA?
19. Blocking vs non-blocking I/O?
20. Explain fork + exec.
21. Zombie vs orphan process?
22. What happens when `read()` reads a file?
23. Why are context switches expensive?
24. How does a mutex avoid simultaneous access?
25. What happens when memory is exhausted?

## Priority guide

**P0:** processes, threads, scheduling, synchronization, deadlocks, paging, virtual memory, system calls, file descriptors/inodes, interrupts/DMA.

**P1:** MLFQ, multilevel paging, inverted tables, working set, disk scheduling, journaling, IPC, signals, mmap, I/O multiplexing.

**P2:** detailed segmentation hardware, obscure allocation variants, deep filesystem implementation details.

## Concept-sharpening resources

- **OSTEP:** best first follow-up when a concept feels too abstract — https://pages.cs.wisc.edu/~remzi/OSTEP/
- **MIT xv6:** best for seeing how OS ideas fit together inside a small Unix-like kernel — https://pdos.csail.mit.edu/6.828/2025/overview.html
- **Linux man-pages:** best for exact Linux syscall/API behavior — https://man7.org/linux/man-pages/
- **Linux kernel docs:** best for production-kernel details, especially memory management — https://docs.kernel.org/
