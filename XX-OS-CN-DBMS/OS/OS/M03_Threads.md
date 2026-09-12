# M03 · Threads 🔥

> `💡 FRAMING` — A process is expensive to create and switch, and its parts are isolated. But often you want *one* program to do several things at once (a browser rendering, downloading, and responding to clicks simultaneously). Threads are the answer: **multiple independent execution paths inside one process, sharing its memory.** The whole chapter is the trade-off *shared memory (cheap, fast, but dangerous)* — which is exactly what sets up synchronization in Ch.5.

Prereqs (from Ch.2): process, address space, PCB, context switch.

---

## 3.1 What is a thread? 🔥

**What it is.** A **thread** is the smallest unit of execution — a single sequential flow of control within a process. It has its **own** program counter, register set, and stack, but **shares** the process's code, data (globals/heap), and open files with the other threads of that process.

A traditional process has **one** thread ("single-threaded"). A **multithreaded** process has several threads running through the same address space.

```
   SINGLE-THREADED PROCESS         MULTITHREADED PROCESS
   +----------------------+        +-------------------------------+
   | code | data | files  |        | code | data | files (SHARED) |
   +----------------------+        +-------------------------------+
   | registers            |        | regs | regs | regs   (each)  |
   | stack                |        | stk  | stk  | stk     (each)  |
   +----------------------+        +-------------------------------+
   | one thread (PC)      |        | T1     T2     T3   (each PC)  |
   +----------------------+        +-------------------------------+
```

**Interview definition:**
> *A thread is the smallest schedulable unit of execution within a process. Threads of the same process share its code, data, and resources but each has its own stack, registers, and program counter.*

> `⚠️ SUPPLEMENT — "thread = lightweight process" is loose:` Videos often say this. It's *okay* as intuition (threads are cheaper to create/switch than processes), but the precise reason is that **threads share the address space**, so there's far less to allocate and — crucially — a thread switch within a process needs **no address-space change and no TLB flush**. Say *why* it's lightweight, don't just repeat the phrase.

---

## 3.2 Why threads? (benefits) ⭐

The problem threads solve: creating a whole new **process** for each concurrent task is expensive (new address space, PCB, COW pages) and processes are isolated (need IPC to talk). Threads give you concurrency **cheaply** and with **easy sharing**.

| Benefit | Explanation |
|---------|-------------|
| **Responsiveness** | One thread can keep serving the user while another blocks (UI stays alive while a download runs). |
| **Resource sharing** | Threads share memory by default — no IPC setup needed to exchange data. |
| **Economy** | Creating and context-switching threads is much cheaper than processes. |
| **Scalability (parallelism)** | On a multicore CPU, threads of one process can run on **different cores** at the same instant → real speedup. |

**Example.** A web server: one thread per request means thousands of clients are served concurrently, all sharing the same cache/config in memory, without spinning up a process per request.

---

## 3.3 Process vs Thread 🔥 (the table interviewers want)

| Aspect | **Process** | **Thread** |
|--------|-------------|------------|
| Definition | Program in execution | Unit of execution within a process |
| Address space | **Own, isolated** | **Shared** with other threads of the process |
| Memory/resources | Own code, data, heap, files | Shares code, data, heap, files |
| Owns privately | Everything | Only **stack, registers, PC** |
| Creation cost | High (new address space, PCB) | Low |
| Context-switch cost | High (**TLB flush**, cache pollution) | Low (**no TLB flush** — same address space) |
| Communication | IPC (shared memory / messages) — slower | Shared memory directly — fast |
| Isolation / fault | Crash of one process doesn't kill others | A crash (e.g., segfault) can **take down the whole process** (all its threads) |
| Blocking | One process blocking doesn't block others | (With user-level threads) one blocking thread can block the whole process — see 3.6 |

**One-liner to remember:** *processes are isolated (safe, expensive); threads are shared (fast, cheap, but you must synchronize).*

---

## 3.4 What threads share vs keep private 🔥

This exact split is a frequent question and the root of all synchronization problems.

```
   SHARED across threads of a process   |   PRIVATE to each thread
   ----------------------------------   |   ----------------------
   Code / Text segment                  |   Stack (local variables)
   Data segment (globals, statics)      |   Registers
   Heap (malloc'd memory)               |   Program counter
   Open files & file descriptors        |   Thread ID
   Signals & signal handlers (process)  |   (its own scheduling state)
```

**Why this matters:** because the **heap and globals are shared**, two threads writing the same variable can interleave and corrupt it → a **race condition** (Ch.5). Because the **stack is private**, local variables are naturally thread-safe.

**Connects to:** Ch.5 (synchronization) exists *entirely* because of the "shared" column here.

---

## 3.5 Concurrency vs Parallelism 🔥 (a top trap)

Candidates use these interchangeably. They're different.

- **Concurrency** = *dealing with* many tasks at once by **interleaving** them. Tasks make progress in overlapping time periods. Can happen on a **single core** (the CPU rapidly switches between tasks — they're not literally simultaneous).
- **Parallelism** = *doing* many tasks at the **same literal instant**. Requires **multiple cores/CPUs**.

```
 CONCURRENCY (1 core, time-sliced):     PARALLELISM (2 cores):
   Core: A B A B A B  (interleaved)      Core1: A A A A
                                          Core2: B B B B   (simultaneous)
```

- Concurrency is about **structure** (managing multiple tasks); parallelism is about **execution** (running them at once).
- You can have concurrency **without** parallelism (one core, time-sharing) and parallelism is a **way to implement** concurrency when you have multiple cores.

**Interview one-liner (Rob Pike):** *Concurrency is dealing with lots of things at once; parallelism is doing lots of things at once.*

> `⚠️ Trap:` "Multithreading always means parallelism." **False.** On a single-core machine, multiple threads run **concurrently** (interleaved), not in parallel. You only get parallelism with ≥2 cores.

---

## 3.6 User-level vs Kernel-level threads & multithreading models ⭐

Threads can be managed in **user space** (by a library, kernel unaware) or by the **kernel** (kernel schedules them).

| | **User-level threads (ULT)** | **Kernel-level threads (KLT)** |
|--|------------------------------|--------------------------------|
| Managed by | A thread library in user space | The OS kernel |
| Kernel aware? | No — sees one process | Yes — schedules each thread |
| Context switch | Fast (no kernel trap) | Slower (kernel involved) |
| Blocking problem | If **one** thread makes a blocking syscall, the **whole process blocks** (kernel doesn't know other threads exist) | Other threads keep running |
| True multicore parallelism? | ❌ No (kernel sees one entity) | ✅ Yes |

**Mapping models (how ULTs map to KLTs):**

```
 MANY-TO-ONE            ONE-TO-ONE             MANY-TO-MANY
 many ULT -> 1 KLT      each ULT -> 1 KLT      M ULT -> N KLT (N<=M)
   U U U                  U   U   U              U U U U
    \|/                   |   |   |               \ | | /
     K                    K   K   K                K   K
 (no parallelism;      (true parallelism;      (flexible: parallelism
  one block =           but many kernel          without 1:1 kernel-
  all block)            threads, costlier)       thread cost)
```

- **Many-to-one:** all user threads map to one kernel thread. Simple but no parallelism and one blocking call blocks all. (Old "green threads.")
- **One-to-one:** each user thread = one kernel thread. Real parallelism, one thread blocking doesn't block others; cost is many kernel threads. **Used by Linux and Windows.**
- **Many-to-many:** multiplex M user threads over N kernel threads. Best flexibility; complex to implement.

> `⚠️ SUPPLEMENT:` Modern Linux/Windows use **one-to-one** (each thread is a kernel-schedulable entity). "Green threads"/user-space schedulers have returned in language runtimes (Go **goroutines**, Java **virtual threads**) — these are essentially **many-to-many** user-space scheduling on top of a few OS threads, chosen to make millions of concurrent tasks cheap. Good senior talking point.

---

## 3.7 Thread context switch vs process context switch ⭐

- **Thread switch (same process):** save/restore registers + PC + stack pointer. **Address space unchanged → no TLB flush**, cache stays mostly warm. Cheap.
- **Process switch:** all of the above **plus** switch page tables/memory maps and **flush the TLB**, cold cache. Expensive.

This cost difference (from Ch.2's context-switch mechanism) is the concrete reason "threads are lightweight."

---

## Interview Questions — Chapter 3

**Basic**

1. **What is a thread?** → Smallest unit of execution within a process; has its own stack/registers/PC but shares the process's code, data, heap, and files.
2. **Process vs thread?** → Process = isolated address space (expensive, safe). Thread = shares the process's memory (cheap, fast, but needs synchronization). Threads own only stack/registers/PC.
3. **What do threads of a process share, and what is private?** → Share: code, data/globals, heap, open files. Private: stack, registers, PC, thread ID.
4. **Benefits of multithreading?** → Responsiveness, resource sharing, economy, scalability on multicore.

**Intermediate**

1. **Concurrency vs parallelism?** → Concurrency = interleaving multiple tasks (possible on 1 core); parallelism = executing simultaneously (needs ≥2 cores). Concurrency is structure; parallelism is execution.
2. **Why is a thread context switch cheaper than a process one?** → Same address space → no page-table switch and **no TLB flush**, warmer cache.
3. **User-level vs kernel-level threads?** → ULT: managed by a library, kernel unaware, fast switch, but one blocking call blocks all and no true parallelism. KLT: kernel-scheduled, real parallelism, one blocking thread doesn't stall others, costlier switches.
4. **If one thread crashes (segfault), what happens?** → It typically takes down the **whole process** and all its threads, because they share the address space (contrast: a process crash doesn't kill other processes).

**Advanced**

1. **Explain the three multithreading models.** → Many-to-one (no parallelism, one block blocks all), one-to-one (real parallelism, many kernel threads — Linux/Windows), many-to-many (M user over N kernel — flexible).
2. **How do Go goroutines / Java virtual threads relate to OS threads?** → They're user-space-scheduled lightweight tasks multiplexed over a small pool of OS (kernel) threads — effectively many-to-many — making millions of concurrent tasks cheap without one kernel thread each.
3. **Can a single-core machine benefit from multithreading?** → Yes, via concurrency: while one thread blocks on I/O, another runs — better responsiveness and CPU utilization — but no true parallel speedup.

---

## Quick Interview Definitions — Chapter 3

- **Thread:** Smallest unit of execution within a process; shares process memory, owns stack/registers/PC.
- **Multithreading:** Multiple threads executing within one process's address space.
- **Concurrency:** Managing multiple tasks by interleaving (possible on one core).
- **Parallelism:** Executing multiple tasks at the same instant (needs multiple cores).
- **User-level thread:** Thread managed by a user-space library, invisible to the kernel.
- **Kernel-level thread:** Thread scheduled directly by the OS kernel.
- **Lightweight process:** Informal name for a thread — cheap because it shares the address space.

---

## ⚠️ Common Mistakes — Chapter 3

- **"Thread = lightweight process" with no reason.** Know *why*: shared address space → no TLB flush on switch, less to allocate.
- **Concurrency = parallelism.** Interleaving vs simultaneous execution; concurrency works on one core.
- **Multithreading ⇒ parallelism.** Only with ≥2 cores; otherwise it's concurrency.
- **Threads are fully isolated.** No — they share heap/globals, which is why race conditions exist.
- **A crashing thread only affects itself.** Usually it kills the whole process (shared memory).
- **ULT gives multicore parallelism.** No — the kernel sees one entity; only KLT (or 1:1/M:N) gives true parallelism.

---

## 🧠 RECALL — Chapter 3 (cover the answers)

1. Threads own privately: ___? → *stack, registers, PC*.
2. Threads share: ___? → *code, data/globals, heap, files*.
3. Concurrency needs multiple cores — T/F? → *False* (parallelism does).
4. Why is a thread switch cheaper? → *no address-space change → no TLB flush*.
5. Which model do Linux/Windows use? → *one-to-one*.
6. One thread segfaults → what dies? → *the whole process*.
7. Goroutines/virtual threads ≈ which model? → *many-to-many* (user-space scheduling over OS threads).

---

### → Next: **Chapter 4 — CPU Scheduling** (criteria, FCFS/SJF/SRTF/RR/Priority, with full Gantt-chart calculations). This is where processes, states, and context switches turn into actual algorithms. Say **"continue"** for Part 4.
