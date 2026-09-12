# M12 · Last-Minute Revision 🔥

> The entire OS syllabus compressed for the night before / morning of an interview. Six sections: **① Must-know checklist · ② All comparison tables · ③ All formulas · ④ Key diagrams · ⑤ Top 50 Q&A · ⑥ One-page cheat sheet.**

---

## ① Must-Know Concepts — checklist

**Fundamentals (M01)**
- [ ] OS = resource manager + abstraction layer (OSTEP: virtualization / concurrency / persistence)
- [ ] User vs kernel mode; privileged instructions; the mode bit
- [ ] System call = trap into the kernel; the syscall mechanism
- [ ] Kernel types: monolithic (Linux) vs microkernel (QNX) vs hybrid
- [ ] Interrupt (async, HW) vs trap (sync, syscall) vs exception (sync, error)
- [ ] **Mode switch ≠ context switch**

**Processes & Threads (M02–M03)**
- [ ] Process vs program; the address space (text/data/heap/stack)
- [ ] Process states + transitions; **blocked ≠ ready**; Running→Ready = preemption
- [ ] PCB contents; context switch cost (TLB flush on process switch)
- [ ] `fork` (returns 0/child-PID/-1) vs `exec`; zombie vs orphan
- [ ] Process vs thread; what threads share vs keep private
- [ ] **Concurrency ≠ parallelism**

**Scheduling (M04)**
- [ ] TAT = CT−AT, WT = TAT−BT, RT = firstCPU−AT
- [ ] Preemptive vs non-preemptive
- [ ] FCFS (convoy), SJF/SRTF (optimal WT, starvation), RR (quantum), Priority (aging)

**Synchronization & Deadlock (M05–M06)**
- [ ] Race condition; critical section + 3 requirements (ME, progress, bounded wait)
- [ ] Mutex vs semaphore; binary semaphore vs mutex; monitors
- [ ] Producer-consumer / readers-writers / dining philosophers
- [ ] 4 deadlock conditions; prevention vs avoidance vs detection
- [ ] Banker's algorithm (safe state / safe sequence); deadlock vs starvation

**Memory & Virtual Memory (M07–M08)**
- [ ] Logical vs physical; MMU; address binding
- [ ] Internal vs external fragmentation
- [ ] Paging (address translation, page/frame); segmentation; paging vs segmentation
- [ ] Demand paging; page fault handling; valid/invalid bit
- [ ] Page replacement (FIFO/Optimal/LRU/Clock); Belady's anomaly
- [ ] Thrashing + working set; TLB + EMAT

**File / I/O / IPC (M09–M11)**
- [ ] Allocation: contiguous vs linked vs indexed; inodes; hard vs soft link
- [ ] I/O: polling vs interrupt vs DMA; seek time dominates
- [ ] Disk scheduling: FCFS/SSTF/SCAN/C-SCAN/LOOK
- [ ] IPC: shared memory vs message passing; pipes/sockets/signals

---

## ② Important Differences — all comparison tables

**Mode switch vs Context switch**

| Mode switch | Context switch |
|---|---|
| Same process, user↔kernel | Different process |
| Cheap | Expensive (TLB flush, cache) |

**Process vs Thread**

| Process | Thread |
|---|---|
| Own address space | Shares process memory |
| Expensive switch (TLB flush) | Cheap switch (no flush) |
| IPC to communicate | Shares memory directly |
| Isolated (crash contained) | Crash kills whole process |

**Concurrency vs Parallelism**

| Concurrency | Parallelism |
|---|---|
| Interleaving (1 core OK) | Simultaneous (needs ≥2 cores) |
| "Dealing with" many tasks | "Doing" many tasks |

**Preemptive vs Non-preemptive**

| Preemptive | Non-preemptive |
|---|---|
| CPU can be taken (timer) | Runs till block/exit |
| SRTF, RR, prio | FCFS, SJF |
| Better response; more switches | Convoy risk; less overhead |

**Mutex vs Semaphore**

| Mutex | Semaphore |
|---|---|
| Lock, has ownership | Counter, no ownership |
| Binary | Counting or binary |
| Mutual exclusion | Counting resources / signaling |

**Deadlock vs Starvation vs Livelock**

| Deadlock | Starvation | Livelock |
|---|---|---|
| Group mutually stuck | One waits forever, others run | Active but no progress |
| Break a condition | Aging | Randomized backoff |

**Paging vs Segmentation**

| Paging | Segmentation |
|---|---|
| Fixed-size pages | Variable-size segments |
| Internal fragmentation | External fragmentation |
| OS-defined | Logical (programmer) units |

**Internal vs External Fragmentation**

| Internal | External |
|---|---|
| Waste inside a block | Free space scattered in small holes |
| Fixed partitions, paging | Variable partitions, segmentation |
| Fix: smaller units | Fix: compaction / paging |

**FIFO vs LRU vs Optimal (page replacement)**

| FIFO | LRU | Optimal |
|---|---|---|
| Oldest loaded | Least recently used | Farthest future use |
| Belady's anomaly | No anomaly (stack) | No anomaly; unimplementable |

**File allocation: Contiguous / Linked / Indexed**

| | Random access | Ext. frag | Grow |
|---|---|---|---|
| Contiguous | ✅ | ❌ | ❌ |
| Linked | ❌ | ✅ | ✅ |
| Indexed | ✅ | ✅ | ✅ |

**Polling vs Interrupt vs DMA**

| Polling | Interrupt | DMA |
|---|---|---|
| CPU busy-waits | IRQ per unit | Whole block, 1 IRQ |
| Worst | Middle | Best |

**Shared memory vs Message passing**

| Shared memory | Message passing |
|---|---|
| Fast, manual sync | Slower, safe |
| Same machine | Can cross machines |

---

## ③ Important Formulas

**Scheduling**
```
 Completion Time (CT) = clock time process finishes
 Turnaround Time      = CT − Arrival
 Waiting Time         = Turnaround − Burst   (= CT − AT − BT)
 Response Time        = first CPU allocation − Arrival
 Average X            = ΣX / N
```

**Paging / Memory**
```
 page size = 2^d  ->  offset = d bits ; page number = (addr bits − d)
 #page-table entries = 2^(page number bits)
 physical addr = frame × page_size + offset
 Naive paging access = 2 × memory access (page table + data)
```

**Virtual memory**
```
 EMAT (with TLB) = h(TLB + mem) + (1−h)(TLB + 2·mem)     [page table in RAM]
 EAT (demand paging) = (1−p)·mem_access + p·page_fault_time
   p = page-fault rate
```

**Disk**
```
 Disk access = seek time + rotational latency + transfer time
 Disk scheduling metric = total head movement (∝ seek)
```

**Banker's**
```
 Need = Max − Allocation
 Available = Total − Σ Allocation
 Safe if: repeatedly ∃ process with Need ≤ Work; Work += its Allocation; all finish
```

**Belady quick fact:** more frames → more faults **only for FIFO**.

---

## ④ Key Diagrams to Remember

**Process states**
```
 NEW -> READY -> RUNNING -> TERMINATED
         ^          |
         | (I/O done)| (I/O wait)
         +-- WAITING <+
 RUNNING -> READY = preemption
```

**Address translation (paging)**
```
 logical = [ page # | offset ] --pagetable--> [ frame # | offset ] = physical
                                                (offset unchanged)
```

**Process memory layout**
```
 high | STACK  (down)|
      |    ...        |
      | HEAP   (up)   |
      | DATA / BSS    |
 low  | TEXT (code)   |
```

**Four deadlock conditions (all needed)**
```
 Mutual Exclusion + Hold & Wait + No Preemption + Circular Wait
```

**The three spines**
```
 Program->Process->PCB->States->Context switch->Scheduling
 Threads->Race->Critical section->Mutex/Semaphore->Deadlock
 Virtual addr->Page#+offset->Page table->Frame->Physical addr->(TLB/fault)
```

---

## ⑤ Top 50 OS Interview Questions

### Questions

1. What is an operating system, and what are its two core roles?
2. User mode vs kernel mode — why do we need both?
3. What is a system call, and what happens when one executes?
4. Monolithic vs microkernel — trade-offs?
5. Interrupt vs trap vs exception?
6. Mode switch vs context switch?
7. Multiprogramming vs multitasking vs multiprocessing?
8. Process vs program?
9. What information is stored in a PCB?
10. Explain the process states and transitions.
11. What is a context switch and why is it expensive?
12. `fork()` vs `exec()`? What does `fork()` return?
13. Zombie vs orphan process?
14. Process vs thread?
15. What do threads share, and what is private to each?
16. Concurrency vs parallelism?
17. Define turnaround, waiting, and response time.
18. Preemptive vs non-preemptive scheduling?
19. What is the convoy effect (FCFS)?
20. SJF vs SRTF — and why is SJF "optimal"?
21. Round Robin — what does the time quantum control?
22. What is starvation, and how is it fixed?
23. Why can response time differ from waiting time?
24. What is a race condition?
25. What is a critical section, and what 3 properties must a solution have?
26. Mutex vs semaphore?
27. Binary semaphore vs mutex?
28. What is a counting semaphore used for?
29. In producer-consumer, why must `wait(empty)` precede `wait(mutex)`?
30. What is a monitor, and why prefer it over raw semaphores?
31. What are the four necessary conditions for deadlock?
32. Deadlock prevention vs avoidance?
33. What is a safe state?
34. What does the Banker's algorithm do?
35. Deadlock vs starvation vs livelock?
36. Does a cycle in a resource-allocation graph always mean deadlock?
37. How do you avoid deadlock between two locks in your own code?
38. Logical vs physical address, and what is the MMU?
39. Internal vs external fragmentation?
40. How does address translation work in paging?
41. Paging vs segmentation?
42. Page vs frame?
43. First fit vs best fit vs worst fit?
44. What is virtual memory / demand paging?
45. What is a page fault, and how is it handled?
46. FIFO vs LRU vs Optimal page replacement?
47. What is thrashing, and how is it prevented?
48. What is the TLB, and what is EMAT?
49. What is Belady's anomaly?
50. Contiguous vs linked vs indexed file allocation? (plus: SSTF vs SCAN, shared memory vs message passing)

### Answers

1. System software mediating apps↔hardware; **resource manager** (allocates CPU/memory/IO) + **abstraction layer** (files, address spaces, processes).
2. **Protection.** Privileged instructions run only in kernel mode; apps run in user mode and use system calls, so a buggy app can't corrupt others or the machine.
3. A program's request for an OS service: it loads a syscall number + args, executes a **trap**, the CPU switches to kernel mode, the handler validates and runs the service, then returns to user mode.
4. Monolithic: all services in kernel space → fast but a bug can crash the kernel (Linux). Microkernel: minimal kernel + user-space servers → robust/modular but slower (message passing). **Performance vs isolation.**
5. Interrupt = async, hardware/device (timer, disk). Trap = sync, deliberate software (syscall). Exception = sync, program error (divide-by-zero, page fault).
6. Mode switch = same process toggles privilege (cheap); context switch = CPU moves to a different process (expensive — save/restore state, TLB flush).
7. Multiprogramming = many jobs in RAM, switch on I/O (1 CPU, maximize utilization). Multitasking = + time-slicing for interactivity. Multiprocessing = multiple CPUs, true parallelism.
8. Program = passive code on disk; process = program in execution with state/resources. One program → many processes.
9. PID, state, program counter, registers, scheduling info (priority), memory info (page tables), open files, accounting. Enables suspend/resume.
10. New→Ready→Running→Terminated; Running→Waiting on I/O, Waiting→Ready when done, Running→Ready on preemption. **Blocked ≠ Ready.**
11. Save the current process's context to its PCB and load the next's; costly because it's pure overhead — save/restore registers, switch memory maps, **flush the TLB**, cold cache.
12. `fork` duplicates the process (two processes); `exec` replaces the image with a new program (same PID). `fork` returns 0 to child, child PID to parent, −1 on failure.
13. Zombie: child terminated but parent hasn't `wait()`ed → stale table entry. Orphan: parent died first → child adopted by `init` (PID 1).
14. Process = isolated address space (expensive, safe). Thread = shares the process's memory (cheap, fast, needs synchronization); owns only stack/registers/PC.
15. Share: code, data/globals, heap, open files. Private: stack, registers, PC, thread ID.
16. Concurrency = interleaving tasks (possible on 1 core); parallelism = executing simultaneously (needs ≥2 cores). Structure vs execution.
17. TAT = Completion − Arrival; WT = TAT − Burst; RT = first-CPU-time − Arrival.
18. Non-preemptive: process keeps CPU until it blocks/exits (FCFS, SJF). Preemptive: CPU can be forced away (SRTF, RR); needs a timer.
19. In FCFS a long process makes all short ones wait behind it, inflating average waiting time.
20. SJF non-preemptive (shortest burst when CPU frees); SRTF preemptive (preempt if newcomer's burst < remaining). SJF minimizes average waiting time (short jobs first) — optimal among non-preemptive.
21. The max time a process runs before preemption. Too large → FCFS behavior; too small → excessive context-switch overhead.
22. A process waits indefinitely while others proceed; fixed by **aging** (raise priority the longer it waits).
23. Under preemption, RT is measured at the first dispatch, but WT sums every interval spent in the ready queue (including after preemptions).
24. When concurrent, unsynchronized access to shared data makes the result depend on execution order (e.g., lost update from non-atomic `count++`).
25. Code accessing shared data that only one thread may run at a time; needs **mutual exclusion, progress, bounded waiting**.
26. Mutex = ownership-based lock for mutual exclusion (binary). Semaphore = ownerless counter for managing N resources or signaling.
27. Both admit one thread, but a mutex has **ownership** (only the locker unlocks; enables priority inheritance); a binary semaphore is ownerless (any thread can signal) → good for signaling, not safe as a plain lock.
28. Managing a pool of **N identical resources** — initialize to N, `wait` to take one, `signal` to return one; blocks at 0.
29. Otherwise a producer could hold the mutex and then block on a full buffer, sleeping with the lock held → deadlock.
30. A construct enforcing mutual exclusion over its methods automatically (with condition variables); preferred because raw `wait`/`signal` is unstructured and easy to misuse (a forgotten signal deadlocks).
31. Mutual exclusion, hold and wait, no preemption, circular wait — **all four together**.
32. Prevention statically ensures one of the four conditions can never hold. Avoidance dynamically grants a request only if the resulting state is **safe** (needs max-need info; Banker's).
33. A state with a **safe sequence**: every process can obtain its max needs in some order (using free + freed resources), run, and release → deadlock avoidable.
34. Avoidance: on each request, simulate granting it and run the safety check; grant only if the state stays safe, else make the process wait.
35. Deadlock: a group mutually stuck (no progress). Starvation: one waits forever while others run (aging). Livelock: active but no progress (randomized backoff).
36. Only if every resource type has a **single instance**; with multiple instances a cycle is necessary but not sufficient.
37. **Acquire locks in a fixed global order everywhere** (breaks circular wait).
38. Logical = program-generated (what the program sees); physical = actual RAM. The **MMU** translates logical→physical at runtime on every access.
39. Internal: wasted space inside an allocated block (block bigger than needed). External: enough total free memory but scattered into too-small holes.
40. Split the logical address into page number + offset; look up the frame number in the page table; physical = frame number + the **same** offset.
41. Paging: fixed-size, OS-defined, internal fragmentation, per-page protection. Segmentation: variable-size logical units, external fragmentation, natural per-segment protection/sharing.
42. Page = logical chunk; frame = physical chunk; same size.
43. First: first hole that fits (fast). Best: smallest sufficient hole (least leftover but tiny slivers). Worst: largest hole (big remainder, eats big holes).
44. Running a process without it being fully in RAM — pages live in RAM or on disk, fetched on demand — allowing programs bigger than RAM and more processes resident.
45. A trap when a referenced page isn't in RAM. OS: verify legality → find/free a frame (replacement) → read the page from disk → update the PTE → restart the instruction. It's normal, not an error.
46. FIFO evicts the oldest-loaded page (can suffer Belady's anomaly). LRU evicts the least-recently-used (approximates Optimal via locality). Optimal evicts the page used farthest in the future (best, but needs the future).
47. Excessive paging where fault-servicing dominates and CPU utilization collapses; caused by too little memory per process (over-committed multiprogramming). Prevent by honoring **working sets** / reducing multiprogramming.
48. A fast associative cache of recent page→frame translations, avoiding the extra page-table RAM access. EMAT = h(TLB+mem) + (1−h)(TLB+2·mem).
49. For **FIFO**, adding frames can **increase** page faults. LRU and Optimal (stack algorithms) never do.
50. Contiguous: consecutive blocks (random access ✅, external frag ❌, grow ❌). Linked: chained blocks (random access ❌, frag ✅, grow ✅). Indexed: index block of pointers (random access ✅, frag ✅, grow ✅). — **SSTF vs SCAN:** SSTF serves the nearest request (least movement, can starve); SCAN sweeps to the end and reverses (no starvation). **Shared memory vs message passing:** shared memory is fast but needs manual sync; message passing is slower but safe and can cross machines.

---

## ⑥ One-Page Cheat Sheet

```
OS = resource manager + abstraction (virtualization / concurrency / persistence)
KERNEL: monolithic (Linux, fast) vs microkernel (QNX, isolated). User vs kernel mode via TRAP.
INTERRUPT (async HW) | TRAP (sync syscall) | EXCEPTION (sync error)
MODE switch = same process (cheap) ; CONTEXT switch = new process (TLB flush, costly)

PROCESS = program in execution. PCB = PID,state,PC,regs,mem,files.
STATES: New→Ready→Running→Terminated ; Waiting on I/O ; Running→Ready = preemption. Blocked≠Ready.
MEMORY: text | data/BSS | heap↑ | ↓stack.  fork→(0 child / pid parent) ; exec replaces image.
ZOMBIE=child dead unreaped | ORPHAN=parent dead (init adopts).
THREAD shares code/data/heap/files ; owns stack/regs/PC. Crash kills whole process.
CONCURRENCY=interleave(1 core) ; PARALLELISM=simultaneous(≥2 cores).

SCHEDULING: TAT=CT−AT ; WT=TAT−BT ; RT=firstCPU−AT.
 FCFS(convoy) | SJF/SRTF(min WT, starve) | RR(quantum: big→FCFS, small→overhead) | Priority(+aging).

SYNC: race = unsynced shared access. CS needs ME + progress + bounded wait.
 MUTEX=owned lock ; SEMAPHORE=counter(no owner), counting or signaling.
 Producer-consumer: wait(empty)→wait(mutex). MONITOR=auto mutual exclusion.

DEADLOCK (need all 4): Mutual excl + Hold&wait + No preempt + Circular wait.
 Prevent(break one) | Avoid(Banker: Need=Max−Alloc, grant if safe) | Detect+recover | Ignore(OS).
 Cycle⇒deadlock only if single-instance. Fix code deadlock: lock in fixed order.
 Deadlock(group stuck) vs Starvation(aging) vs Livelock(backoff).

MEMORY: logical→[MMU]→physical. Internal frag(paging) vs External frag(segmentation).
 PAGING: addr=[page#|offset]→pagetable→[frame#|offset]. page=frame size. No ext frag.
 SEGMENTATION: [seg#|offset], base+limit. Ext frag, natural sharing. Fits: first≈best>worst.

VIRTUAL MEM: demand paging + valid bit. PAGE FAULT→load from disk→restart instr (normal).
 Replace: FIFO(Belady!) | LRU(≈optimal) | OPTIMAL(future, ideal) | Clock(ref bit).
 THRASHING = paging > executing → working set / cut multiprogramming.
 TLB caches translations. EMAT=h(TLB+M)+(1−h)(TLB+2M). EAT=(1−p)M+p·faultTime.

FILES: contiguous(rand✅,extfrag❌,grow❌) | linked(rand❌) | indexed/inode(rand✅). Hardlink=inode, softlink=path.
I/O: polling<interrupt<DMA(whole block,1 IRQ). Disk time≈SEEK(dominant)+rotate+transfer.
 Disk sched: FCFS | SSTF(least move, starve) | SCAN/LOOK | C-SCAN/C-LOOK(uniform wait).
IPC: shared memory(fast, sync yourself) vs message passing(safe, cross-machine). Pipe/FIFO/socket/signal.
```

---

**That's the full 12-module OS course.** Work backwards from this sheet: if any line here isn't instantly clear, reopen that module. Good luck. 🎯
