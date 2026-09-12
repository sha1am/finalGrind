# M11 · Inter-Process Communication (IPC) ⭐

> `💡 FRAMING` — Processes are **isolated** by design (separate address spaces, M02) — that's what makes them safe. But cooperating processes need to exchange data, and they can't just read each other's variables (that's the whole point of the isolation). **IPC is the set of sanctioned channels the OS provides to cross process boundaries**, and the central trade-off is the same one from M05: **shared memory (fast, but you synchronize it yourself)** vs **message passing (safe and simple, but slower)**.

Prereqs (M02 processes/isolation, M03 threads, M05 synchronization).

---

## 11.1 Why IPC?

Two processes can't share variables (isolated address spaces). Reasons to communicate: **information sharing**, **modularity** (split work across processes), **speedup** (parallel subtasks), and **convenience**. Contrast with **threads**, which share memory *by default* (M03) — IPC is what you need *between processes*.

---

## 11.2 The two fundamental models 🔥

| | **Shared Memory** | **Message Passing** |
|--|-------------------|---------------------|
| How | OS maps a common memory region into both processes; they read/write it directly | Processes exchange discrete messages via `send()`/`receive()` through the kernel |
| Speed | **Fast** (only setup involves the kernel; then it's plain memory access) | **Slower** (every message is a system call / kernel copy) |
| Synchronization | **Your responsibility** — races are possible; use mutexes/semaphores (M05) | Handled by the mechanism (often implicitly synchronized) |
| Best for | Large data, high frequency | Small data, or communication across machines |
| Complexity | Harder to get right (manual sync) | Simpler and safer |

```
 SHARED MEMORY                         MESSAGE PASSING
 P1 ---\                               P1 --send()--> [ kernel ] --receive()--> P2
        [ shared region ] (both map)   (data copied through the kernel each time)
 P2 ---/   (fast, but must sync)
```

**Message-passing design choices** (interview depth): **direct vs indirect** (name the process vs use a mailbox/port), and **synchronous (blocking) vs asynchronous (non-blocking)** send/receive — e.g., a **blocking receive** waits until a message arrives; a **non-blocking receive** returns immediately (with a message or nothing).

---

## 11.3 Common IPC mechanisms

| Mechanism | Model | Notes |
|-----------|-------|-------|
| **Pipe (anonymous)** | Message (byte stream) | One-way; only between **related** processes (parent–child), e.g., shell `ls \| grep` |
| **Named pipe (FIFO)** | Message (byte stream) | Has a name in the filesystem → **unrelated** processes can use it |
| **Message queue** | Message | Kernel-maintained queue of discrete messages; persists until read |
| **Shared memory segment** | Shared memory | Fastest; needs external synchronization (semaphores) |
| **Socket** | Message | Endpoint for communication — **across machines** (network) or local; the basis of all networking |
| **Signal** | Async notification | A software interrupt to a process (e.g., `SIGINT` from Ctrl-C, `SIGKILL`); carries almost no data — just the event |

**Pipe example (the classic):** `ls | grep txt` — the shell creates a pipe, `fork`s (M02) two children, wires `ls`'s stdout to the pipe's write end and `grep`'s stdin to the read end. Data streams one way, `ls` → `grep`.

> `⚠️ Trap — anonymous vs named pipe:` an **anonymous pipe** only connects **related** processes (they inherit the pipe fd across `fork`); a **named pipe (FIFO)** has a filesystem name, so **unrelated** processes can open it. And a **socket** (unlike pipes) can span **different machines**.

---

## 11.4 Connection to synchronization

Shared-memory IPC re-introduces every hazard from M05 — two processes writing the shared region race exactly like two threads. So shared-memory IPC is almost always paired with **semaphores/mutexes** to coordinate access. Message passing largely sidesteps this (no shared state to corrupt), which is why it's considered safer and scales to distributed systems (where there's no shared memory at all).

---

## Interview Questions — M11

**Basic**

1. **Why is IPC needed?** → Processes have isolated address spaces and can't share variables directly; IPC provides OS-sanctioned channels for cooperating processes to exchange data.
2. **Shared memory vs message passing?** → Shared memory: a common region both processes access directly — fast but you must synchronize it. Message passing: `send`/`receive` through the kernel — slower but simpler and safe.
3. **What is a pipe?** → A unidirectional byte-stream channel; anonymous pipes connect related (parent–child) processes, named pipes (FIFOs) connect unrelated ones.
4. **What is a signal?** → An asynchronous software-interrupt notification to a process (e.g., `SIGINT`, `SIGKILL`) carrying the event but essentially no data.

**Intermediate**

1. **When would you choose shared memory over message passing?** → For large, high-frequency data transfer where the per-message kernel-copy cost of message passing would dominate — accepting the burden of manual synchronization.
2. **Anonymous pipe vs named pipe vs socket?** → Anonymous pipe: related processes only. Named pipe (FIFO): unrelated processes on the same machine. Socket: local or **across machines** (network).
3. **How does `ls | grep` work under the hood?** → The shell creates a pipe, forks both commands, connects `ls`'s stdout to the pipe write end and `grep`'s stdin to the read end; data flows one way.

**Advanced**

1. **Why does shared-memory IPC still need semaphores but message passing usually doesn't?** → Shared memory is concurrently mutable state → races (M05); semaphores enforce mutual exclusion. Message passing has no shared mutable state to corrupt, so it's inherently safer.
2. **Synchronous vs asynchronous message passing?** → Blocking (synchronous) send/receive waits for the counterpart (send waits until received, receive waits until a message arrives); non-blocking returns immediately, letting the process continue.

---

## Quick Interview Definitions — M11

- **IPC:** Mechanisms letting isolated processes exchange data.
- **Shared memory:** A region mapped into multiple processes; fast, needs manual sync.
- **Message passing:** `send`/`receive` of discrete messages via the kernel; slower, safe.
- **Pipe / FIFO:** One-way byte stream; anonymous (related procs) / named (unrelated).
- **Socket:** Communication endpoint, local or across machines.
- **Signal:** Asynchronous notification (software interrupt) to a process.

---

## ⚠️ Common Mistakes — M11

- **Message passing is faster than shared memory.** Usually the opposite — shared memory avoids per-message kernel copies.
- **All pipes work between any processes.** Anonymous pipes need a parent–child relationship; use a FIFO or socket otherwise.
- **Shared-memory IPC is automatically safe.** It races just like threads — synchronize it.
- **Sockets are only for networking.** They also work locally (Unix domain sockets), but unlike pipes they *can* cross machines.
- **Signals carry data.** They carry the event, not a payload.

---

## 🧠 RECALL — M11 (cover the answers)

1. Why can't processes share variables? → *isolated address spaces*.
2. Fast IPC that needs manual sync? → *shared memory*.
3. Safe IPC via the kernel? → *message passing*.
4. Anonymous pipe requires? → *a parent–child relationship*.
5. IPC that crosses machines? → *sockets*.
6. Threads vs processes for sharing? → *threads share memory by default; processes need IPC*.

---

### → Final: **M12 · Last-Minute Revision** — the whole subject compressed: checklist, all tables, all formulas, key diagrams, Top 50 Q&A, and a one-page cheat sheet.
