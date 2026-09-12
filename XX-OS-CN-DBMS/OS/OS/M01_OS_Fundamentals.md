# M01 · OS Fundamentals 🔥

> `💡 FRAMING` — An OS exists to solve one problem: **hardware is a single, dumb, shared, dangerous resource, and many programs want to use it at once, safely and efficiently.** Every feature in this chapter (modes, kernel, system calls, interrupts) is a mechanism for *sharing hardware without letting programs corrupt each other or the machine.*

---

## 1.1 What is an Operating System? 🔥

**What it is.** An OS is the software layer that sits between application programs and hardware. It manages the hardware and provides programs a clean, safe interface to use it.

**Why we need it.** Imagine writing a "Hello World" if there were *no* OS: you'd have to write CPU instructions to drive the keyboard controller, manage RAM addresses by hand, talk to the disk controller in raw commands, and make sure no other program overwrites your memory. Impossible to do for every app. The OS does this once, for everyone.

Two ways interviewers want you to describe an OS — **know both framings**:

1. **Resource Manager (allocator).** The CPU, memory, disk, and I/O devices are limited and shared. The OS decides *who gets what, when, and for how long* (which process runs on the CPU, which page of RAM belongs to whom).
2. **Abstraction Layer / Extended Machine.** Raw hardware is painful. The OS hides ugly details behind clean abstractions: the messy disk becomes **files**, raw RAM becomes a per-process **address space**, the CPU becomes **processes/threads**.

> `⚠️ SUPPLEMENT (OSTEP framing — say this to sound senior):` OSTEP organizes the *entire* OS around three jobs, "the three easy pieces":
> - **Virtualization** — make one CPU look like many (processes), make limited physical RAM look like a huge private memory (virtual memory).
> - **Concurrency** — let many things run at once *correctly* (locks, synchronization).
> - **Persistence** — store data reliably despite crashes (file systems).
> If you can bucket any OS topic into virtualization / concurrency / persistence, you understand where it fits.

**Example.** You double-click Chrome. The OS: loads it from disk into RAM (memory mgmt), creates a process (process mgmt), schedules it onto the CPU (scheduling), lets it open a socket to the network (I/O + system calls), and stops it from reading Spotify's memory (protection).

**Interview definition.**
> *An operating system is system software that acts as an intermediary between the user/applications and computer hardware. It manages hardware resources (CPU, memory, I/O) and provides an abstraction layer that makes the hardware convenient and safe to use.*

---

## 1.2 How a computer actually runs (the foundation everything rests on) ⭐

You can't reason about processes, interrupts, or context switches without this base model.

**The players:**

- **CPU** — executes instructions. Has **registers** (tiny, ultra-fast storage): the **Program Counter (PC)** holds the address of the next instruction, plus general-purpose registers, stack pointer, and status registers.
- **Main memory (RAM)** — volatile; holds currently-running programs and their data. The CPU can only execute code that is in RAM.
- **Secondary storage (disk/SSD)** — non-volatile; holds programs and files when not running.
- **I/O devices** — keyboard, disk, network card, etc. Each has a **device controller** with a local buffer.
- **Bus** — the wiring connecting them all.

**The fetch–decode–execute cycle** (the CPU's entire life):

```
   +--------- CPU ---------+
   |  1. FETCH instruction |  <- reads instruction at address in PC (from RAM)
   |  2. DECODE it         |
   |  3. EXECUTE it        |  -> may read/write RAM or registers
   |  4. PC advances       |
   +----------- loop ------+
```

**Storage hierarchy** (speed ↑, size ↓, cost ↑ as you go up) — a classic warm-up question:

```
   Registers      <- fastest, smallest, in CPU
   Cache (L1/L2/L3)
   Main memory (RAM)
   SSD / Disk
   Tape / cloud    <- slowest, largest, cheapest
```

**Key terms:** *volatile* (loses data on power off → RAM), *non-volatile* (keeps data → disk). *Latency* grows by orders of magnitude at each step down (register ~1ns, RAM ~100ns, SSD ~100µs, disk ~10ms).

**Why interviewers care:** everything else is a consequence of this model. "Why is a context switch expensive?" → because you must save/restore all those registers and often flush caches/TLB. "Why demand paging?" → because RAM is small and disk is huge but slow.

---

## 1.3 Goals & functions of an OS ○

**Two goals in tension:**
- **Convenience** (good for the user — easy to use) vs **Efficiency** (good for the system — high hardware utilization). Desktop OSes lean convenience; servers/mainframes lean efficiency.

**Core functions** (each is a later chapter): Process management, Memory management, File & storage management, I/O management, Protection & security, Networking, and providing the user interface (CLI/GUI).

Don't memorize this as a list — recognize that **each function = "managing one shared resource."**

---

## 1.4 Types of Operating Systems ⭐

Interviewers rarely ask deep questions here, but they *love* "difference between multiprogramming, multitasking, and multiprocessing" — candidates mix these up constantly.

| Type | Core idea | Key point |
|------|-----------|-----------|
| **Batch OS** | Jobs with similar needs are batched; no user interaction during run | Old mainframes; punch cards. Poor CPU utilization when a job does I/O. |
| **Multiprogramming** | Keep **several jobs in RAM**; when one waits for I/O, CPU switches to another | Goal: **maximize CPU utilization**. One CPU, but never idle if work exists. |
| **Multitasking / Time-sharing** | Multiprogramming + rapid **time-slicing** so each user/process feels interactive | Adds a **timer** + **context switching**. Goal: fast **response time**. |
| **Multiprocessing** | **Multiple CPUs/cores** in one machine execute in parallel | True parallelism. More throughput, fault tolerance. |
| **Real-Time OS (RTOS)** | Correctness depends on meeting **deadlines** | **Hard RTOS** (missing deadline = failure: pacemaker, airbag) vs **Soft RTOS** (deadline is best-effort: video streaming). |
| **Distributed OS** | Many networked machines appear as one system | Resource sharing across nodes; no shared clock/memory. |
| **Embedded OS** | Runs on dedicated hardware with tight constraints | Washing machines, routers. Often an RTOS. |

> `⚠️ SUPPLEMENT — the exact distinction interviewers probe:`
> - **Multiprogramming** = *concurrency* on **one** CPU (interleaving; overlap CPU with I/O). Goal = CPU never idle.
> - **Multitasking** = multiprogramming **with time slicing** for interactivity (a superset in practice). Goal = responsiveness.
> - **Multiprocessing** = *parallelism* on **multiple** CPUs (things literally run at the same instant). Goal = throughput.
>
> Mnemonic: **multiprogramMING = many jobs in memory; multiprocessING = many processors.**

---

## 1.5 Interrupts, Traps & Exceptions 🔥

This is the single most under-appreciated fundamental. **Interrupts are how the OS ever gets control of the CPU back.** Without them, a running program would own the CPU forever.

**What it is.** An **interrupt** is a signal that makes the CPU pause what it's doing, save its state, and jump to a special OS routine (the **Interrupt Service Routine / handler**), then resume.

**Why we need it.** The CPU is busy running a user program. How does the OS know a key was pressed, a disk finished, a timer expired, or a program divided by zero? The hardware/software *interrupts* the CPU to signal the event.

**How it works (step by step):**

```
 CPU running Process A
        |
   [interrupt fires]  (e.g., timer, disk done, illegal op)
        |
 1. CPU finishes current instruction
 2. CPU saves context (PC, registers) of A
 3. CPU switches to KERNEL MODE
 4. Look up handler in the INTERRUPT VECTOR (table of handler addresses)
 5. Run the OS handler (service the event)
 6. Restore context (of A, or of a different process if OS decides to switch)
        |
 CPU resumes
```

**Three flavors — know the vocabulary precisely (candidates blur these):**

| Term | Source | Synchronous? | Example |
|------|--------|--------------|---------|
| **Interrupt** (hardware) | External device | Asynchronous (any time) | Keyboard, disk-complete, **timer** |
| **Trap** (software interrupt) | Program, *intentionally* | Synchronous | Executing a **system call**; breakpoint |
| **Exception / Fault** | Program, *by error* | Synchronous | Divide-by-zero, invalid memory access, **page fault** |

**Interview angle.** "How does the OS regain control from a running process?" → **the timer interrupt.** The OS sets a hardware timer before handing the CPU to a process; when it fires, control returns to the kernel, which can then schedule someone else. This is the mechanism that makes preemptive scheduling and time-sharing possible.

> `⚠️ Trap ≠ Interrupt (common confusion):` Many videos use "interrupt" loosely. Precise version: a **trap** is a *software-generated, synchronous* interrupt (deliberate, e.g., a syscall or an exception), while a **hardware interrupt** is *asynchronous* and device-driven. Both use the same "save state → vector → handler" machinery, but the cause differs.

---

## 1.6 User Mode vs Kernel Mode (Dual-Mode Operation) 🔥

**What it is.** The CPU runs in one of (at least) two privilege levels: **user mode** (restricted) and **kernel mode** (a.k.a. supervisor/privileged mode — full power). A single **mode bit** in a CPU register records which one you're in.

**Why we need it.** **Protection.** If any program could run *any* instruction, a buggy or malicious app could halt the CPU, wipe another process's memory, or reprogram the disk. So dangerous instructions (I/O, halt, changing memory-protection registers, setting the timer) are **privileged** — they only work in kernel mode. User apps run in user mode and must *ask* the OS to do privileged things.

**How it works.**
- App runs in **user mode**.
- It needs something privileged (read a file, allocate memory) → it executes a **system call**, which is a **trap** that flips the CPU into **kernel mode** and jumps into OS code.
- The OS (in kernel mode) validates the request, does the privileged operation, then switches back to **user mode** and returns.

```
   USER MODE                          KERNEL MODE
   (restricted)                       (full privilege)
   ---------                          ------------
   your app runs                      OS code runs
        |                                  ^
        |  system call (trap) ------------>|  validate + execute privileged op
        |                                  |
        |<------------ return -------------|  switch back to user mode
```

**If a user program tries a privileged instruction directly** → the CPU raises an **exception (trap)**, and the OS typically kills the offending process. (This is why you can't just `halt` the machine from your code.)

| Aspect | **User Mode** | **Kernel Mode** |
|--------|---------------|-----------------|
| Privilege | Restricted | Full |
| Mode bit | 1 (typically) | 0 (typically) |
| Can run privileged instrs? | ❌ No | ✅ Yes |
| Access to hardware/all memory | ❌ Indirect (via syscalls) | ✅ Direct |
| Who runs here | Application code | OS kernel, interrupt handlers |
| Crash blast radius | Kills that process | Can crash the whole system (kernel panic / BSOD) |
| Entered via | (start) | trap / interrupt / syscall |

**Interview angle.** "What happens on a system call?" → user→kernel **mode switch** via a trap. "Why two modes?" → protection & isolation. Bonus: modern x86 has 4 "rings" (0–3); Linux uses only ring 0 (kernel) and ring 3 (user).

> `⚠️ Mode switch ≠ context switch (VERY common trap):`
> - **Mode switch** = same process changes CPU privilege level (user↔kernel) for a syscall/interrupt. **Cheap**; the *same* process continues afterward.
> - **Context switch** = the CPU is handed from **one process/thread to another** (save A's state, load B's). **Expensive.**
> Every context switch involves mode switches, but a mode switch alone is **not** a context switch. Interviewers set this trap deliberately.

---

## 1.7 The Kernel 🔥

**What it is.** The **kernel** is the core of the OS — the part that is always resident in memory and runs in kernel mode. It directly manages CPU scheduling, memory, device drivers, system calls, and interrupts.

**Kernel vs OS:** the OS = kernel + surrounding utilities/user-space tools (shell, GUI, libraries, system programs). The kernel is the privileged nucleus; "OS" is the whole product.

**Kernel architectures — the flagship comparison here:**

| Type | Idea | Pros | Cons | Examples |
|------|------|------|------|----------|
| **Monolithic** | *All* OS services (scheduler, FS, drivers, memory) run **together in kernel space** | Fast (everything is a direct function call, no crossing boundaries) | Large; a driver bug can crash the whole kernel; harder to maintain | **Linux**, traditional Unix |
| **Microkernel** | Kernel keeps only the **bare minimum** (IPC, scheduling, low-level memory); FS, drivers, etc. run as **user-space servers** | Stable & secure (a crashing driver doesn't kill the kernel); modular | Slower — lots of **message passing / mode switches** between servers | **QNX**, L4, Minix |
| **Hybrid** | Mostly monolithic, but some services modularized; pragmatic middle | Balance of speed + modularity | Complex | **Windows NT**, **macOS (XNU)** |
| **Exokernel** ○ | Kernel just securely multiplexes hardware; apps manage their own resources via libOS | Max flexibility/performance | Very complex; research | MIT exokernel |

```
   MONOLITHIC                         MICROKERNEL
   ----------                         -----------
   +----------------------+           user | FS  Driver  App  (servers in user space)
   | App (user space)     |           space|  \    |    /
   +----------------------+           -----------[IPC]----------
   | KERNEL:              |           kernel| microkernel:
   |  scheduler, memory,  |           space |  IPC + scheduling + basic memory
   |  file system,        |
   |  device drivers      |           (drivers/FS OUTSIDE the kernel)
   +----------------------+
```

**Interview angle.** "Is Linux monolithic or microkernel?" → **monolithic** (though modular — it supports loadable kernel modules, so it's sometimes called a *modular monolithic* kernel). "Monolithic vs microkernel trade-off?" → **performance vs isolation/reliability.** Monolithic = fast but fragile; micro = robust but message-passing overhead.

> `⚠️ SUPPLEMENT:` "Modular monolithic" (Linux) confuses people. Linux is monolithic (drivers run in kernel space) but *modular* because you can load/unload drivers at runtime (**LKMs**) without recompiling. Modularity ≠ microkernel — the modules still run in kernel space.

---

## 1.8 System Calls 🔥

**What it is.** A **system call** is the programmatic way an application requests a service from the OS kernel — the *only* legitimate doorway from user mode into kernel mode.

**Why we need it.** User programs can't touch hardware directly (Section 1.6). To read a file, create a process, or send on a socket, the app must ask the OS. The system call is that controlled, checked request. It gives you **protection** (the OS validates every request) and **abstraction** (you say "read this file," not "seek disk head to cylinder 4032").

**How it works:**

```
 1. App calls a library wrapper, e.g. read()          [user mode]
 2. Wrapper puts the SYSCALL NUMBER + arguments in registers
 3. Executes a TRAP instruction (e.g. `syscall` on x86-64)
 4. CPU switches to KERNEL MODE, jumps via the trap vector to the syscall handler
 5. Handler uses the number to index the SYSTEM CALL TABLE -> runs sys_read()  [kernel mode]
 6. Kernel validates args, does the work, puts result in a register
 7. Returns to USER MODE; wrapper returns the value to the app
```

**API vs system call (a favorite trap):** you rarely call a syscall directly. You call an **API** function (e.g., `printf`, `fopen`, or POSIX `read`) provided by a library (glibc); the library packages arguments and issues the actual syscall. So: **API = the interface you code against; system call = the actual kernel entry underneath.** One API call may issue zero, one, or many syscalls (`printf` buffers, so several `printf`s → one `write`).

**Categories of system calls** (know examples in each):

| Category | Purpose | Examples (POSIX / Windows) |
|----------|---------|----------------------------|
| **Process control** | Create/terminate/wait | `fork`, `exec`, `wait`, `exit` / `CreateProcess` |
| **File management** | Files & directories | `open`, `read`, `write`, `close`, `lseek` |
| **Device management** | Request/release/use devices | `ioctl`, `read`, `write` |
| **Information / maintenance** | Get/set system data | `getpid`, `time`, `gettimeofday` |
| **Communication (IPC)** | Talk between processes | `pipe`, `shmget`, `socket`, `send`, `recv` |
| **Protection** | Permissions | `chmod`, `umask`, `chown` |

**Interview angle.** "What is a system call / user vs kernel mode transition?" (constant). "`fork` vs `exec`?" (see Ch.2). "Difference between a system call and a function call?" → a function call stays in user space; a system call **traps into the kernel** (mode switch, far more expensive).

> `⚠️ Trap:` "System call = function call" is wrong. A normal function call is a jump within your process in user mode. A system call executes a **trap**, switches privilege level, and runs kernel code — orders of magnitude costlier, which is why performance-sensitive code tries to **minimize syscalls** (e.g., buffering, batching).

---

## 1.9 OS Structures ⭐

How the OS's own code is organized (related to but distinct from kernel *type*):

| Structure | Idea | Trade-off |
|-----------|------|-----------|
| **Monolithic / Simple** | One big program, little separation (early MS-DOS, classic Unix) | Fast, but tangled and fragile |
| **Layered** | OS split into layers; layer *N* only uses layer *N−1* (bottom = hardware, top = UI) | Easy to debug/verify; but strict layering is slow and rigid |
| **Microkernel** | Minimal kernel + user-space servers communicating by message passing | Modular, secure; slower (IPC overhead) |
| **Modular** | Core kernel + dynamically **loadable modules** (modern Linux) | Flexible; modules load on demand — best of layered + micro in practice |

**Interview angle.** Usually folded into the monolithic-vs-microkernel discussion. The one extra point worth having: **layered** systems are clean but suffer because a request may traverse many layers (overhead), and deciding layer boundaries is hard.

---

## 1.10 Boot process ○

Low priority, but a clean 5-step story if asked:

```
 Power on
   -> BIOS/UEFI firmware runs POST (Power-On Self-Test), checks hardware
   -> Firmware loads the BOOTLOADER (e.g., GRUB) from disk (MBR/EFI partition)
   -> Bootloader loads the KERNEL into RAM and hands off control
   -> Kernel initializes (drivers, memory, scheduler), mounts root FS
   -> Starts the first user process (init / systemd), which starts everything else
```

**Terms:** *bootstrapping*, *firmware (BIOS/UEFI)*, *bootloader (GRUB)*, *POST*, *init/systemd* (PID 1).

---

## Interview Questions — Chapter 1

**Basic**

1. **What is an operating system and what are its main functions?**
   *Intermediary between apps and hardware; manages CPU, memory, I/O, files; provides protection and a user interface. Two views: resource manager + abstraction layer.*
2. **User mode vs kernel mode — why do we need two?**
   *Protection. Privileged instructions (I/O, halt, memory-protection changes) run only in kernel mode; apps run in user mode and use system calls to request privileged operations. Prevents one buggy app from crashing the machine or corrupting others.*
3. **What is a kernel?**
   *The always-resident core of the OS running in privileged mode; manages scheduling, memory, drivers, syscalls, interrupts.*
4. **What is a system call? Give examples.**
   *A program's request for an OS service — the controlled gateway from user to kernel mode via a trap. E.g., `fork`, `read`, `write`, `open`, `exit`.*

**Intermediate**

1. **Explain what happens, step by step, when a program makes a system call.**
   *App → library wrapper loads syscall number + args into registers → trap instruction → CPU switches to kernel mode → handler indexes the syscall table → kernel validates and executes → returns result → switch back to user mode.*
2. **Difference between multiprogramming, multitasking, and multiprocessing?**
   *Multiprogramming = many jobs in RAM, CPU switches on I/O (maximize CPU util, 1 CPU). Multitasking = multiprogramming + time-slicing for interactivity. Multiprocessing = multiple CPUs running truly in parallel.*
3. **Monolithic vs microkernel — trade-offs?**
   *Monolithic: all services in kernel space → fast but a bug can crash the kernel (Linux). Microkernel: minimal kernel + user-space servers → robust/modular but slower due to message passing (QNX). Trade-off = performance vs isolation.*
4. **How does the OS regain control of the CPU from a running process?**
   *Via the timer interrupt — the OS arms a hardware timer before dispatching a process; when it fires, control traps back to the kernel, enabling preemption.*

**Advanced**

1. **Difference between a mode switch and a context switch.**
   *Mode switch = same process toggles privilege (user↔kernel) for a syscall/interrupt — cheap, same process resumes. Context switch = CPU moves from one process/thread to another (save/restore full state, possibly flush TLB) — expensive.*
2. **Trap vs interrupt vs exception?**
   *Interrupt = asynchronous, hardware/device-generated (timer, disk). Trap = synchronous, software-generated on purpose (system call). Exception/fault = synchronous, caused by a program error (divide-by-zero, page fault). All share the save→vector→handler mechanism.*
3. **Is Linux a monolithic or microkernel? Justify.**
   *Monolithic (drivers/FS run in kernel space) but modular — supports loadable kernel modules at runtime, so it's "modular monolithic." Modularity ≠ microkernel because modules still execute in kernel space.*

---

## Quick Interview Definitions — Chapter 1

- **Operating System:** System software mediating between applications and hardware; manages resources and abstracts hardware.
- **Kernel:** The privileged, always-resident core of the OS.
- **User mode / Kernel mode:** CPU privilege levels; user mode is restricted, kernel mode can run privileged instructions. Tracked by a mode bit.
- **System call:** A program's controlled request for an OS service, trapping from user to kernel mode.
- **Interrupt:** An asynchronous hardware signal that diverts the CPU to an OS handler.
- **Trap:** A synchronous, intentionally-generated software interrupt (e.g., a syscall).
- **Exception/Fault:** A synchronous interrupt caused by a program error (e.g., page fault).
- **Multiprogramming:** Keeping several jobs in memory so the CPU switches to another when one waits (maximize CPU use).
- **Monolithic kernel:** All OS services run in kernel space (fast, less isolated).
- **Microkernel:** Only essentials in the kernel; other services run as user-space servers (isolated, slower).

---

## ⚠️ Common Mistakes — Chapter 1

- **"OS = kernel."** The kernel is the core; the OS also includes shells, libraries, GUI, and system programs.
- **Mode switch vs context switch** — the #1 trap. Mode switch keeps the same process; context switch changes process. (See 1.6.)
- **Trap vs interrupt** — trap = synchronous/deliberate (syscall); hardware interrupt = asynchronous/device. Don't use them interchangeably.
- **"Modular = microkernel."** Linux is modular *and* monolithic. Modules run in kernel space.
- **System call = function call.** A syscall traps into the kernel (privilege change); a function call doesn't.
- **Multiprogramming vs multiprocessing** — "programming" = many jobs in memory (1 CPU, concurrency); "processing" = many CPUs (parallelism).
- **Concurrency vs parallelism** (previewed here, detailed in Ch.3) — concurrency = *dealing with* many things (interleaving, possibly 1 core); parallelism = *doing* many things at the literal same instant (needs ≥2 cores).

---

## 🧠 RECALL — Chapter 1 (cover the answers)

1. Two one-line definitions of an OS? → *resource manager* + *abstraction layer*.
2. What flips the CPU user→kernel? → a **trap** (system call / interrupt).
3. What single mechanism lets the OS preempt a process? → the **timer interrupt**.
4. Monolithic vs microkernel in three words? → *performance vs isolation*.
5. Mode switch vs context switch? → *same process (cheap)* vs *different process (expensive)*.
6. OSTEP's three pieces? → *virtualization, concurrency, persistence*.
7. Multiprogramming goal / multiprocessing meaning? → *CPU never idle* / *multiple CPUs*.

---

### → Next: **Chapter 2 — Processes** (process concept, states, PCB, context switch, `fork`/`exec`). Prereqs you now have: kernel, mode switch, interrupts, system calls.

*Say "continue" and I'll produce Chapter 2.*
