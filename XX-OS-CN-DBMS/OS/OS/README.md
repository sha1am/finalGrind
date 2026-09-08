# Operating Systems — SDE Interview Notes

> Interview-focused OS notes for Software Engineering, Backend and SDE interviews.

## How this repository was designed

The curriculum is primarily aligned to the supplied **TakeUForward (TUF) OS interview sheet** and the supplied **Complete OS Course** YouTube playlist by Riti Kumari. TUF currently groups its OS interview sheet into Introduction, Process Management, Memory Management, File Systems, I/O Systems, and Storage/Data Protection, with 28 tracked items. The playlist describes itself as a complete OS course aimed at placements, semester exams and jobs.

Primary sources:
- TUF: https://takeuforward.org/operating-system/most-asked-operating-system-interview-questions
- YouTube playlist: https://www.youtube.com/playlist?list=PLrL_PSQ6q0606tibu0c9lFIzkFtshv7HI

The notes are **original synthesis**, not a transcription of either source. Standard OS concepts are added where they materially improve SDE interview readiness, especially synchronization, deadlocks, virtual memory, IPC, file descriptors, I/O models, Linux process behavior, and container isolation.

## Priority levels

- **P0 — Must know:** expected in most SDE/backend interviews.
- **P1 — Strongly recommended:** common follow-ups and useful for debugging/performance discussions.
- **P2 — Advanced:** know the mental model; detailed derivations are usually optional.

## Suggested study order

1. Read `00-os-roadmap.md`.
2. Finish Introduction → Processes/Threads → Scheduling → Synchronization → Deadlocks.
3. Finish Memory → Virtual Memory → File Systems → I/O/Storage.
4. Read the SDE/Linux extensions before backend interviews.
5. Use `11-interview-revision/` for final revision.

## Interview answer pattern

For almost every OS question, answer in this order:

**definition → problem solved → mechanism → example → trade-off → common confusion.**

## Directory map

- `01-introduction/` — OS role, kernel boundary, system calls and structures.
- `02-process-management/` — processes, PCB, context switches, fork/exec, threads and IPC.
- `03-cpu-scheduling/` — scheduling policies and metrics.
- `04-process-synchronization/` — races, locks, semaphores, monitors and classic problems.
- `05-deadlocks/` — conditions, graphs, prevention, avoidance, Banker’s algorithm and recovery.
- `06-memory-management/` — allocation, fragmentation, paging, page tables, TLB and segmentation.
- `07-virtual-memory/` — demand paging, page faults, replacement and thrashing.
- `08-file-systems/` — files, allocation, directories, inodes and links.
- `09-io-and-storage/` — interrupts, DMA, disks, scheduling and practical I/O.
- `10-security-and-protection/` — protection, access control and OS security.
- `11-interview-revision/` — rapid revision, comparisons and interview questions.
- `12-sde-linux-extensions/` — high-value Linux/backend topics not always explicit in basic OS syllabi.

## What to memorize vs understand

Memorize: definitions, scheduling formulas, four deadlock conditions, page-table/TLB flow, classic comparisons, and key system-call behavior.

Understand: why context switches cost time, why TLBs exist, why page faults are expensive, why locks need atomicity, why deadlocks form, and how a file read reaches storage.

## Resources to sharpen concepts

Use these **after reading the notes**, not instead of them. Each resource is chosen for a different learning mode.

### 1. OSTEP — best overall conceptual companion

[Operating Systems: Three Easy Pieces](https://pages.cs.wisc.edu/~remzi/OSTEP/) organizes OS around **virtualization, concurrency, and persistence** and explains concepts through problems and mechanisms. Use it when a note feels memorized rather than understood.

**Best for:** processes, scheduling, concurrency, locks, virtual memory, filesystems and storage.

### 2. MIT xv6 — best for making the kernel feel real

[MIT 6.1810 / xv6](https://pdos.csail.mit.edu/6.828/2025/overview.html) uses a small Unix-like teaching OS to connect virtual memory, threads, context switches, interrupts, system calls, IPC and filesystems.

**Best for:** answering “what actually happens inside the kernel?” questions.

### 3. Linux man-pages — best for Linux/SDE interview precision

[Linux man-pages](https://man7.org/linux/man-pages/) are the right place to verify exact behavior of APIs such as `fork`, `open`, `mmap`, `read`, `write`, `wait`, `exec`, and `epoll`.

**Best for:** backend/Linux interviews and avoiding technically incorrect statements.

### 4. Linux kernel documentation — best for production-system depth

[Linux kernel documentation](https://docs.kernel.org/) is useful once the basic model is clear. In particular, the [memory-management documentation](https://docs.kernel.org/admin-guide/mm/) helps connect virtual memory, page cache, reclaim and OOM behavior to a real production kernel.

**Best for:** senior SDE/backend and systems-oriented follow-ups.

### How to use the resources

```text
Read note
   ↓
Explain it without looking
   ↓
Solve the tiny example
   ↓
If unclear → read OSTEP
   ↓
If you want implementation intuition → read xv6
   ↓
If you need exact Linux behavior → check man7.org
```

Do not try to read all of OSTEP or the Linux kernel documentation before interviews. Use them selectively to fix weak concepts.
