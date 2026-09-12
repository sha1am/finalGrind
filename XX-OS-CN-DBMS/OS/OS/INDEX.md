# Operating Systems — Interview Notes · INDEX

Master map + progress tracker. See `README.md` for conventions. Study in module order (M01 → M12).

**Status key:** ✅ complete · 🔨 in progress · ⏳ planned
**Note:** Module **MNN = Chapter N** (in-file "Ch.N" references map one-to-one).

---

## Roadmap (study order + prerequisites)

| Module | Topic | Prerequisites | Priority | Status |
|--------|-------|---------------|----------|--------|
| **M01** | **OS Fundamentals** — what/why, computer model, OS types, interrupts/traps, user vs kernel mode, kernel (mono/micro), system calls, OS structures | Basic CPU/RAM/disk idea | 🔥 | ✅ |
| **M02** | **Processes** — program vs process, address space, states, PCB, context switch, schedulers/queues, fork/exec/wait, zombie/orphan | M01 (kernel, mode switch, interrupts, syscalls) | 🔥 | ✅ |
| **M03** | **Threads** — threads, process vs thread, shared vs private, concurrency vs parallelism, multithreading models | M02 (process, PCB) | 🔥 | ✅ |
| **M04** | **CPU Scheduling** — metrics (TAT/WT/RT), FCFS, SJF, SRTF, Priority, Round Robin, MLFQ; worked Gantt calculations | M02–M03 (states, context switch, ready queue) | 🔥 | ✅ |
| **M05** | **Synchronization** — race condition, critical section (3 reqs), Peterson's, mutex, semaphore, producer-consumer, readers-writers, dining philosophers, monitors | M03 (threads, shared memory) | 🔥 | ✅ |
| **M06** | **Deadlocks** — 4 Coffman conditions, RAG, prevention/avoidance/detection/recovery, Banker's algorithm, deadlock vs starvation | M05 (locks, resources) | 🔥 | ✅ |
| **M07** | **Memory Management** — address binding, logical vs physical, MMU, contiguous alloc, first/best/worst fit, fragmentation, paging, segmentation | M02 (address space) | 🔥 | ✅ |
| **M08** | **Virtual Memory** — demand paging, page-fault handling, replacement (FIFO/Optimal/LRU/Clock), Belady's anomaly, thrashing, working set, TLB + EMAT | M07 (paging) | 🔥 | ✅ |
| **M09** | **File Systems** — file concept/attributes, access methods, directory structures, allocation (contiguous/linked/indexed), free-space mgmt, inodes | M07 (blocks) | ⭐ | ✅ |
| **M10** | **I/O & Disk Scheduling** — I/O methods (polling/interrupt/DMA), disk structure, FCFS/SSTF/SCAN/C-SCAN/LOOK/C-LOOK (worked) | M01 (I/O, interrupts) | ⭐ | ✅ |
| **M11** | **IPC** — shared memory vs message passing, pipes (named/unnamed), sockets, signals | M02–M03, M05 | ⭐ | ✅ |
| **M12** | **Last-Minute Revision** — must-know checklist, all comparison tables, all formulas, key diagrams, **Top 50 Q&A**, one-page cheat sheet | Everything | 🔥 | ✅ |

**Progress: 12 / 12 modules complete.**

---

## The three "spines" (how everything connects)

```
 EXECUTION                CONCURRENCY               MEMORY
 Program                  Threads share data        Virtual address
   -> Process               -> Race condition         -> Page no. + offset
   -> PCB                    -> Critical section       -> Page table
   -> Process states         -> Mutual exclusion        -> Physical frame
   -> Context switch         -> Mutex / Semaphore       -> Physical address
   -> CPU scheduling         -> Deadlock                 -> TLB / Page fault
   (M02, M03, M04)          (M03, M05, M06)            (M07, M08)
```

Most OS interview questions live on one of these chains.

---

## Concept → module

| If you're asked about… | Module |
|------------------------|--------|
| System call, user/kernel mode, kernel types | M01 |
| Process vs program, PCB, context switch, zombie/orphan, fork/exec | M02 |
| Process vs thread, concurrency vs parallelism, user vs kernel threads | M03 |
| Turnaround/waiting/response time, Round Robin, SJF, starvation, convoy effect | M04 |
| Race condition, critical section, mutex vs semaphore, producer-consumer | M05 |
| Deadlock conditions, Banker's algorithm, deadlock vs starvation | M06 |
| Paging, segmentation, fragmentation, logical vs physical address, MMU | M07 |
| Demand paging, page faults, LRU/FIFO/Optimal, thrashing, TLB, EMAT | M08 |
| inodes, file allocation methods, directory structures | M09 |
| DMA, SSTF/SCAN/C-SCAN, disk seek time | M10 |
| Pipes, shared memory, message passing, sockets | M11 |
| Rapid revision, formulas, top questions, cheat sheet | M12 |

---

## Cross-cutting "trap" questions (each answered in the linked module)

- Process vs Program (M02) · Process vs Thread (M03)
- Mode switch vs Context switch (M01) · Concurrency vs Parallelism (M03)
- Mutex vs Semaphore (M05) · Binary semaphore vs Mutex (M05) · Semaphore vs Monitor (M05)
- Deadlock vs Starvation (M06) · Deadlock prevention vs avoidance (M06)
- Paging vs Segmentation (M07) · Internal vs External fragmentation (M07)
- Logical vs Physical address (M07) · Page vs Frame (M07)
- Preemptive vs Non-preemptive scheduling (M04) · SJF vs SRTF (M04) · Zombie vs Orphan (M02)
- Thrashing vs normal paging (M08)
