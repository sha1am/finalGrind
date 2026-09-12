# M02 · Processes 🔥

> `💡 FRAMING` — A process is the OS's answer to the question *"how do I run a program while keeping it isolated from every other running program?"* The whole chapter is about the **bookkeeping** (PCB) and **mechanism** (states + context switch) that let one CPU juggle many isolated programs and later resume each *exactly* where it left off.

Prereqs (from Ch.1): kernel, user/kernel mode, mode switch, interrupts, system calls.

---

## 2.1 Program vs Process 🔥

The most common warm-up question in the entire subject.

- A **program** is a **passive** entity: a file on disk containing instructions (e.g., `chrome.exe`, `a.out`). It just sits there.
- A **process** is a **program in execution** — an **active** entity with a current state: a program counter, registers, a stack, allocated memory, open files, etc.

**Analogy:** a **recipe** (program) vs actually **cooking the dish** (process). One recipe can be cooked many times simultaneously by different people → **one program can spawn many processes** (open Chrome twice → two processes running the same program).

| Program | Process |
|---------|---------|
| Passive | Active |
| On disk (static) | In memory (dynamic, executing) |
| No state | Has state (PC, registers, memory, stack) |
| One | Can have many instances |
| Exists until deleted | Exists until it terminates |

**Interview definition:**
> *A process is a program in execution, along with its current activity (program counter, registers) and the resources allocated to it (memory, open files). It is an active entity, whereas a program is a passive one.*

---

## 2.2 What a process looks like in memory (the address space) 🔥

When a program runs, the OS gives it a private **address space** with four main sections. Interviewers ask "what are the segments of a process's memory?" often.

```
   High address
   +---------------------+
   |       STACK         |  local variables, function-call frames,
   |         |           |  return addresses, parameters
   |         v           |  --> grows DOWNWARD
   |                     |
   |   (free space)      |
   |                     |
   |         ^           |
   |         |           |
   |       HEAP          |  dynamic memory: malloc / new
   +---------------------+  --> grows UPWARD
   |    DATA segment      |  global & static variables
   |  (initialized + BSS) |  (BSS = uninitialized globals, zero-filled)
   +---------------------+
   |   TEXT / CODE        |  the program instructions (read-only)
   +---------------------+
   Low address
```

| Segment | Holds | Notes |
|---------|-------|-------|
| **Text/Code** | Machine instructions | Read-only, often shared between processes running the same program |
| **Data** | Initialized globals/statics | Fixed size |
| **BSS** | Uninitialized globals/statics | Zero-initialized at load |
| **Heap** | Dynamically allocated memory | Grows up; managed by `malloc`/`free`; leaks live here |
| **Stack** | Function frames, locals | Grows down; **stack overflow** = stack collides with heap / exhausts limit |

**Connects to:** Ch.7 (each of these lives in pages of virtual memory) and Ch.3 (threads of one process **share** text/data/heap but each gets its **own stack**).

**Trap:** stack grows **down**, heap grows **up**, toward each other. "Stack overflow" (deep/infinite recursion) and "heap exhaustion" (leaks) are different failures.

---

## 2.3 Process States 🔥

A process moves through a lifecycle. The OS tracks which state each process is in.

**The 5 classic states:**

```
        admitted             dispatch (scheduler)        exit
 [NEW] ----------> [READY] --------------------> [RUNNING] ------> [TERMINATED]
                     ^                               |
        interrupt /  |                               |  issues I/O or
        time-slice   |                               |  waits for event
        expiry       |                               v
                     +---------- [WAITING] <---------+
                        I/O done /   (a.k.a. BLOCKED)
                        event occurs
```

| State | Meaning |
|-------|---------|
| **New** | Process is being created |
| **Ready** | Loaded in RAM, waiting to be assigned the CPU (all it needs is the CPU) |
| **Running** | Instructions are executing on the CPU |
| **Waiting/Blocked** | Waiting for an event (I/O completion, a signal, a lock) — **cannot use the CPU even if free** |
| **Terminated** | Finished execution; being removed |

**Critical transitions (know these cold):**

- **Ready → Running**: the scheduler **dispatches** it. (Only *one* process per CPU can be Running.)
- **Running → Ready**: **preemption** — its time slice expired or a higher-priority process arrived. *(It was not blocked; it can run, it just lost the CPU.)*
- **Running → Waiting**: it requested I/O or must wait for an event.
- **Waiting → Ready**: the event/I/O completed. **Note it goes back to Ready, NOT straight to Running** — it must be scheduled again.

> `⚠️ Trap — the #1 mistake here:` **Blocked ≠ Ready.** A *ready* process needs only the CPU. A *blocked* process is waiting on I/O/an event and will not run even if the CPU is idle. And **Running → Ready is preemption, not blocking** — a preempted process isn't waiting for anything.

**Suspended states (with swapping)** ⭐ — when RAM is full, the OS may **swap** a process out to disk:

- **Ready → Suspend-Ready** (swapped out while ready)
- **Waiting → Suspend-Wait** (swapped out while blocked)
- Brought back via **swap-in**. This is the medium-term scheduler's job (2.6).

---

## 2.4 Process Control Block (PCB) 🔥

**What it is.** The **PCB** is the OS's data structure that stores *everything* it needs to know about a process — one PCB per process, kept in the kernel. It **is** the process, from the OS's point of view.

**Why we need it.** When the OS switches away from a process, it must save that process's entire execution context somewhere so it can resume perfectly later. That "somewhere" is the PCB.

**What's inside (memorize the big ones):**

| Field | What it stores |
|-------|----------------|
| **Process ID (PID)** | Unique identifier |
| **Process state** | New/Ready/Running/Waiting/Terminated |
| **Program counter** | Address of the next instruction to execute |
| **CPU registers** | Saved register contents (for resume) |
| **Scheduling info** | Priority, pointers to scheduling queues |
| **Memory-management info** | Base/limit registers, page tables |
| **Accounting info** | CPU time used, time limits, PID of parent |
| **I/O status info** | List of open files, allocated devices |

```
   +---------------------+
   |        PCB          |
   |---------------------|
   | PID                 |
   | State               |
   | Program Counter     | <-- saved on context switch, restored on resume
   | Registers           | <--/
   | Scheduling / priority|
   | Memory info (pages) |
   | Open files, I/O     |
   | Accounting          |
   +---------------------+
```

**Connects to:** context switching (2.5) *is* the act of saving one PCB and loading another. The PCB is why a resumed process continues as if never interrupted.

**Interview angle.** "What information does the OS store about a process?" → the PCB fields. "Where is the process state saved during a context switch?" → in the PCB.

---

## 2.5 Context Switching 🔥

**What it is.** A **context switch** is the procedure of saving the state (context) of the currently running process into its PCB and loading the saved state of the next process to run.

**Why we need it.** To share one CPU among many processes (multitasking), the OS must be able to pause a process and later resume it *exactly* where it stopped. Context switching makes that possible.

**How it works:**

```
 Process A running
      |
   trigger: timer interrupt / A blocks on I/O / higher-priority process ready
      |
 1. Switch to kernel mode (trap)
 2. SAVE A's context (PC, registers, state) into PCB_A
 3. Scheduler picks next process B (Ch.4)
 4. LOAD B's context from PCB_B (restore registers, PC)
 5. (If different address space) update memory maps, FLUSH the TLB
 6. Switch to user mode; B resumes
      |
 Process B running
```

**The cost (and why it matters):** a context switch is **pure overhead** — during it, the CPU does *no useful work*. Cost includes saving/restoring registers, updating the PCB, switching memory maps, and (on a **process** switch) **flushing the TLB** and polluting the CPU cache. This is a core reason threads exist (Ch.3): switching between threads of the *same* process is cheaper (shared address space → **no TLB flush**).

**When does a context switch happen?**
- Timer interrupt (time slice expired) — preemptive scheduling
- Process makes a blocking system call (I/O)
- A higher-priority process becomes ready (preemption)
- Process voluntarily yields or terminates

> `⚠️ Trap:` **Context switch ≠ mode switch** (see Ch.1). A mode switch (user↔kernel for a syscall) keeps the *same* process. A context switch changes *which* process runs. Also: a context switch does **no useful computation** — minimizing switches (bigger time quantum, fewer threads than you think) can improve throughput, at the cost of responsiveness.

---

## 2.6 Process scheduling: queues & the three schedulers ⭐

The OS organizes processes into **queues** and uses **schedulers** to move them between queues.

**Queues:**
- **Job queue** — all processes in the system.
- **Ready queue** — processes in RAM, ready and waiting for the CPU.
- **Device/Wait queue** — processes blocked waiting for a specific I/O device.

```
   [Job Queue] --admit--> [Ready Queue] --dispatch--> [CPU] --done--> exit
                              ^                          |
                              |                      I/O request
                              |                          v
                              +----- [Device Queue] <----+
                                     (wait for I/O)
```

**Three schedulers (classic comparison):**

| Scheduler | A.k.a. | Job | Frequency | Controls |
|-----------|--------|-----|-----------|----------|
| **Long-term** | Job scheduler | Which jobs are admitted into the ready queue (from disk → RAM) | Infrequent | **Degree of multiprogramming** (how many processes in memory) |
| **Short-term** | CPU scheduler | Which ready process gets the CPU next | Very frequent (ms) | Which process runs now (Ch.4 lives here) |
| **Medium-term** | Swapper | Swaps processes out to / in from disk to free RAM | Occasional | Relieves memory pressure; adjusts multiprogramming |

**Interview angle.** "Difference between long-term and short-term scheduler?" → long-term controls admission & the degree of multiprogramming and runs rarely; short-term picks the next process for the CPU and runs constantly. Medium-term does swapping.

---

## 2.7 Process creation: `fork`, `exec`, `wait`, `exit` 🔥

Processes form a **tree**: every process (except the first) has a **parent**. On Unix, PID 1 (`init`/`systemd`) is the root ancestor.

**The four system calls (POSIX):**

| Call | Does |
|------|------|
| `fork()` | Creates a **child** process that is a **copy** of the parent (same code, data, but its own PID and memory). |
| `exec()` | **Replaces** the current process's memory image with a **new program**. Same PID; old code gone. |
| `wait()` | Parent **blocks until a child terminates**, and **reaps** it (collects exit status). |
| `exit()` | Terminates the calling process, returning a status to the parent. |

**`fork()` — the famous return-value trick:**
```
 pid = fork();
 // In the PARENT: pid = child's PID  (> 0)
 // In the CHILD:  pid = 0
 // On FAILURE:    pid = -1
```
After `fork()`, **two** processes continue from the same line; you branch on the return value.

**The classic pattern — how a shell runs a command:**
```
 fork()  ->  child created (copy of shell)
   child: exec("ls")  ->  child's image replaced by `ls`
   parent: wait()     ->  shell waits for `ls` to finish, then continues
```

> `⚠️ SUPPLEMENT:` Real `fork()` uses **copy-on-write (COW)** — the child doesn't physically copy all of the parent's memory upfront. Parent and child **share** pages read-only; a page is copied only when one of them **writes** to it. This makes `fork()` cheap, which is why the fork-then-exec pattern is efficient (you'd throw away the copy on `exec` anyway).

**Interview angle.** "`fork` vs `exec`?" → `fork` **duplicates** (2 processes), `exec` **replaces** (same process, new program). "What does `fork` return?" → 0 to child, child PID to parent. "How many processes after N forks in a loop?" → 2^N (each fork doubles) — a favorite trick question.

---

## 2.8 Process termination + Zombie & Orphan 🔥 (very common)

A process ends via `exit()` (voluntary) or by being killed (e.g., `kill`, an unhandled exception, or the parent terminating it). When it exits, it releases resources, but its **exit status** lingers in the process table until the parent **reaps** it with `wait()`.

Two abnormal situations interviewers love:

| Term | Definition | What happens |
|------|-----------|--------------|
| **Zombie (defunct)** | A process that has **terminated** but whose parent **hasn't called `wait()`** yet | Its PCB entry stays in the process table (holding just the exit status). Uses no CPU/memory but occupies a table slot. Too many zombies → PID exhaustion. |
| **Orphan** | A process whose **parent terminated first** while the child is still running | The child is **re-parented to `init`/`systemd` (PID 1)**, which will `wait()` on it and clean it up. |

```
 ZOMBIE:  child exits ---> parent hasn't wait()ed ---> entry stuck (defunct)
 ORPHAN:  parent exits ---> child still alive ---> adopted by init (PID 1)
```

**Fix for zombies:** the parent must call `wait()`/`waitpid()` (often triggered by handling the `SIGCHLD` signal).

> `⚠️ Trap — zombie vs orphan (constantly confused):`
> - **Zombie** = **child dead**, parent alive but negligent (hasn't reaped). Problem = leaked table entries.
> - **Orphan** = **parent dead**, child alive. Not a leak — `init` adopts and reaps it.
> Mnemonic: **Z**ombie = child is dead (a "zombie" is a corpse); **O**rphan = parent is gone.

---

## 2.9 Interprocess Communication (preview) ⭐

Processes are isolated (separate address spaces), so they can't just read each other's variables. To cooperate they use **IPC**, primarily two models:
- **Shared memory** — a region both map; fast, but *you* must synchronize access (Ch.5).
- **Message passing** — `send`/`receive` via the kernel; simpler & safer, slower.

Full treatment in **Part 11**. (Threads, by contrast, share memory *by default* — Ch.3.)

---

## Interview Questions — Chapter 2

**Basic**

1. **Process vs program?** → Program = passive code on disk; process = program in execution with state/resources. One program → many processes.
2. **What are the states of a process?** → New, Ready, Running, Waiting/Blocked, Terminated (+ suspended variants with swapping).
3. **What is a PCB and what does it store?** → Per-process kernel structure holding PID, state, PC, registers, scheduling & memory info, open files. It's what lets a process be resumed.
4. **What is a context switch?** → Saving the current process's state to its PCB and loading the next process's state so the CPU can switch processes.

**Intermediate**

1. **Difference between Ready and Waiting states?** → Ready needs only the CPU; Waiting is blocked on I/O/an event and won't run even if the CPU is free.
2. **`fork()` vs `exec()`? What does `fork` return?** → `fork` duplicates the process (2 processes); `exec` replaces the image with a new program (same PID). `fork` returns 0 to the child, child PID to the parent, −1 on failure.
3. **Zombie vs orphan process?** → Zombie: child terminated, parent hasn't `wait()`ed → stale table entry. Orphan: parent died first → child adopted by `init` (PID 1).
4. **Long-term vs short-term vs medium-term scheduler?** → Admission (degree of multiprogramming, rare) / CPU dispatch (very frequent) / swapping (memory pressure).

**Advanced**

1. **Why is a context switch expensive, and how do threads help?** → It's pure overhead: save/restore registers, switch memory maps, flush TLB, pollute cache. Thread switches within one process share the address space → no TLB flush → cheaper.
2. **A process does `fork()` inside a loop that runs 3 times. How many processes total?** → 2³ = 8 (each fork doubles the count; 7 children + original).
3. **What is copy-on-write and why does `fork` use it?** → Parent/child share pages read-only after `fork`; a page is copied only on first write. Avoids copying memory that `exec` would discard — makes `fork` fast.
4. **A process moves Running → Ready. What caused it?** → Preemption (time-slice expiry or a higher-priority process arrived) — **not** blocking.

---

## Quick Interview Definitions — Chapter 2

- **Process:** A program in execution with its state (PC, registers) and resources.
- **PCB:** Kernel data structure storing all info about a process; enables suspend/resume.
- **Context switch:** Save current process's context to its PCB, load the next's — pure overhead.
- **Ready vs Blocked:** Ready = needs only CPU; Blocked = waiting on an event/I/O.
- **Preemption:** Forcibly taking the CPU from a running process (Running → Ready).
- **fork/exec:** `fork` duplicates a process; `exec` replaces its image with a new program.
- **Zombie:** Terminated child not yet reaped by its parent.
- **Orphan:** Still-running child whose parent has terminated (adopted by `init`).
- **Degree of multiprogramming:** Number of processes resident in memory (set by the long-term scheduler).

---

## ⚠️ Common Mistakes — Chapter 2

- **Process = program.** No — active vs passive; one program can back many processes.
- **Blocked = Ready.** Blocked won't run even with a free CPU; Ready just needs the CPU.
- **Running → Ready means it blocked.** No — that's **preemption**; blocking is Running → Waiting.
- **Waiting → Running directly.** No — after I/O completes it goes Waiting → **Ready**, then must be scheduled.
- **Context switch = mode switch.** Different process vs same process (see Ch.1).
- **Zombie = orphan.** Zombie: child dead/unreaped. Orphan: parent dead, child adopted.
- **`fork` copies all memory immediately.** No — copy-on-write.

---

## 🧠 RECALL — Chapter 2 (cover the answers)

1. Program vs process in one word each? → *passive* vs *active*.
2. Four memory segments of a process? → *text, data(+BSS), heap, stack*.
3. Stack grows ___, heap grows ___? → *down, up*.
4. After I/O completes, a blocked process goes to which state? → *Ready* (not Running).
5. Running → Ready is caused by? → *preemption*.
6. What structure is saved/loaded on a context switch? → the *PCB*.
7. `fork` returns what to the child? → *0*.
8. Zombie = which one is dead? → *the child* (unreaped).
9. Why are thread switches cheaper than process switches? → *shared address space → no TLB flush*.

---

### → Next: **Chapter 3 — Threads** (already in this batch below). Then Chapter 4 — CPU Scheduling.
