# M05 · Synchronization 🔥

> `💡 FRAMING` — The moment two threads share memory (M03) and either can be preempted mid-operation (M04), correctness breaks: an operation you *thought* was one step is actually several, and another thread can slip in between them. Synchronization is the discipline of **making the right pieces of code un-interruptible with respect to each other.** The whole chapter is one idea in escalating forms: *protect the shared region so only one thread is inside it at a time.*

Prereqs (M03, M04): threads share heap/globals; preemption can interleave them.

---

## 5.1 Race Condition 🔥

**What it is.** A **race condition** is when the *outcome* depends on the *non-deterministic timing/interleaving* of threads accessing shared data. Same code, same inputs → different results depending on who runs when.

**The canonical example — `count++` is not atomic.** It compiles to three steps:

```
   register = count      (LOAD)
   register = register+1 (INCREMENT)
   count = register      (STORE)
```

Two threads each doing `count++` on `count = 5`, expecting `7`:

```
 T1: LOAD (reg1=5)
 T2: LOAD (reg2=5)          <- T2 read the stale 5
 T1: INC  (reg1=6)
 T1: STORE (count=6)
 T2: INC  (reg2=6)
 T2: STORE (count=6)        <- lost update! answer is 6, not 7
```

One increment was **lost**. That's a race condition.

**Why it happens.** The three sub-steps of `count++` can be interleaved because a preemption (M04) can occur between any two machine instructions. The shared variable `count` lives in the shared data/heap segment (M03).

**Interview definition:**
> *A race condition occurs when multiple threads access shared data concurrently and the final result depends on the order of execution. It arises from unsynchronized access to a shared resource.*

---

## 5.2 The Critical Section Problem 🔥

A **critical section (CS)** is the part of code that accesses shared resources and must **not** be executed by more than one thread at a time. The problem: design an *entry* and *exit* protocol so that threads coordinate.

```
   do {
        [ entry section ]      <- acquire permission
            CRITICAL SECTION   <- touch shared data (only one thread here)
        [ exit section ]       <- release
            remainder section
   } while (true);
```

**Any correct solution must satisfy 3 requirements (memorize):**

| Requirement | Meaning |
|-------------|---------|
| **1. Mutual Exclusion** | At most **one** thread in the critical section at a time. |
| **2. Progress** | If no thread is in the CS and some want in, the selection of who enters can't be postponed indefinitely (only contenders decide, and they decide in finite time). No unnecessary blocking. |
| **3. Bounded Waiting** | There's a **limit** on how many times other threads can enter the CS before a waiting thread gets its turn. (No starvation.) |

> `⚠️ Trap:` "Mutual exclusion is enough." No — a lock that guarantees mutual exclusion but lets one thread hog the CS forever violates **bounded waiting**; one that can deadlock at the entry violates **progress**. All three matter.

---

## 5.3 Peterson's Solution ⭐ (classic software solution, 2 threads)

A pure-software solution for two threads using two shared variables:

```
   boolean flag[2] = {false,false};   // flag[i]=true : thread i wants in
   int turn;                          // whose turn it is

   // Thread i (j is the other):
   flag[i] = true;
   turn = j;                          // politely give the turn away
   while (flag[j] && turn == j);      // wait while j wants in AND it's j's turn
       CRITICAL SECTION
   flag[i] = false;
```

It satisfies all three requirements. **Its limitation:** it assumes atomic loads/stores and **breaks on modern CPUs** due to instruction reordering (needs memory barriers). So it's a teaching tool, not production code — real systems use hardware atomics.

> `⚠️ SUPPLEMENT:` Peterson's is a favorite theory question, but if asked "would you use it?", the senior answer is *no — modern out-of-order CPUs reorder memory operations, so it needs memory fences; use hardware-supported atomics (below) or OS primitives instead.*

---

## 5.4 Hardware support ○

Software solutions are clumsy; hardware provides **atomic instructions** the OS builds locks on:

- **Test-and-Set** — atomically read a lock's old value and set it to true. Spin until you read false.
- **Compare-and-Swap (CAS)** — atomically: *if memory == expected, set it to new*. The foundation of lock-free data structures.

These are **atomic** (uninterruptible) in hardware, solving the "the check and the set can be split" problem at the root.

---

## 5.5 Mutex (Lock) 🔥

**What it is.** A **mutex** ("mutual exclusion" lock) is the simplest synchronization primitive: a thread must `acquire()`/`lock()` it before the CS and `release()`/`unlock()` after. If it's already held, the acquirer waits.

**Key property — ownership:** the thread that locked a mutex is the one that must unlock it. This ownership enables features like **priority inheritance** (avoiding priority inversion).

**Spinlock vs blocking mutex:**
- **Spinlock** — a busy-waiting lock: the waiter loops ("spins") checking the lock. Good only for *very short* CS (no context-switch cost, but burns CPU while waiting). Used inside kernels on multiprocessors.
- **Blocking mutex** — the waiter is put to sleep (blocked) and woken when the lock frees. Better for longer CS (doesn't waste CPU, but pays context-switch cost).

---

## 5.6 Semaphore 🔥

**What it is.** A **semaphore** is an integer counter accessed only through two atomic operations:

```
   wait(S)   // a.k.a. P() or down():   while (S <= 0) ; // wait
             S--;
   signal(S) // a.k.a. V() or up():     S++;
```

- **Binary semaphore** (S ∈ {0,1}) — acts like a lock (mutual exclusion).
- **Counting semaphore** (S ≥ 0) — counts available units of a resource. Initialize to the number of resources; `wait` to take one, `signal` to return one. Blocks when none are left (S=0).

**Busy-wait vs block:** the naive `while(S<=0);` **spins** (wastes CPU). Real semaphores maintain a **waiting queue**: `wait` on S≤0 **blocks** the thread and puts it in the queue; `signal` **wakes** one waiter. This is the standard implementation.

**Two distinct uses:**
1. **Mutual exclusion** — binary semaphore init 1, `wait` before CS, `signal` after.
2. **Signaling / ordering** — e.g., thread B must run after thread A: init 0; A calls `signal` when done; B calls `wait` before proceeding. (A mutex can't do this — no ownership-free signaling.)

---

## 5.7 Mutex vs Semaphore 🔥 (the #1 synchronization interview question)

| | **Mutex** | **Semaphore** |
|--|-----------|---------------|
| What it is | A **locking** mechanism | A **signaling** mechanism (a counter) |
| Value | Binary (locked/unlocked) | Counting (0..N) or binary |
| Ownership | **Yes** — only the locker can unlock | **No** — any thread can `signal` |
| Purpose | Mutual exclusion (one shared resource) | Manage **N** resources, or signal/order events |
| Can signal from another thread? | No | Yes (that's the point of signaling) |
| Analogy | One key to one toilet; you hold it, you return it | A tray of N keys; take one, return one |

**Binary semaphore vs mutex (the follow-up trap):** both allow only one thread in, but a **mutex has ownership** (and often priority inheritance); a **binary semaphore has no ownership** — any thread can signal it, which makes it usable for signaling between threads but unsafe as a plain lock (someone else can release it). *Use a mutex for locking; a semaphore for counting/signaling.*

---

## 5.8 Classic synchronization problems 🔥

### Producer–Consumer (Bounded Buffer)
Producers add items to a fixed-size buffer, consumers remove them. Must not add to a full buffer or remove from an empty one, and must not corrupt the buffer.

```
   semaphore mutex = 1;   // protect the buffer
   semaphore empty = N;   // # empty slots
   semaphore full  = 0;   // # filled slots

   Producer:                        Consumer:
     wait(empty);                     wait(full);
     wait(mutex);                     wait(mutex);
       add item to buffer;              remove item from buffer;
     signal(mutex);                   signal(mutex);
     signal(full);                    signal(empty);
```

> `⚠️ Trap:` the **order** matters. You must `wait(empty)`/`wait(full)` **before** `wait(mutex)`. If you take `mutex` first and then block on a full buffer, you're holding the lock while asleep → **deadlock**.

### Readers–Writers
Many readers may read simultaneously, but a writer needs exclusive access.

```
   semaphore rw_mutex = 1;  // held by writers, or the first reader
   semaphore mutex = 1;     // protects read_count
   int read_count = 0;

   Writer: wait(rw_mutex); ...write...; signal(rw_mutex);

   Reader: wait(mutex); read_count++;
           if (read_count==1) wait(rw_mutex);   // first reader locks out writers
           signal(mutex);
             ...read...
           wait(mutex); read_count--;
           if (read_count==0) signal(rw_mutex); // last reader lets writers in
           signal(mutex);
```

This version is **reader-preference** → writers can **starve**. Variants give writer-preference or fairness. (Interview point: know the starvation trade-off.)

### Dining Philosophers
5 philosophers around a table, 5 chopsticks between them; each needs **both** neighbors' chopsticks to eat. If all grab their left chopstick at once → everyone holds one and waits forever → **deadlock** (and a textbook illustration of the 4 deadlock conditions, M06).

**Fixes:**
- Allow at most **4** philosophers to sit at once (breaks circular wait).
- **Asymmetry:** odd philosophers pick left-then-right, even pick right-then-left.
- Pick up both chopsticks only if **both** are available (atomic acquisition / arbitrator).

---

## 5.9 Monitors & Condition Variables ⭐

**What it is.** A **monitor** is a higher-level construct: an abstract type whose methods are automatically **mutually exclusive** — only one thread can be *active inside the monitor* at a time. The compiler/runtime enforces the locking, so you don't manually pair `wait`/`signal` (which is error-prone).

**Condition variables** let a thread **wait** inside a monitor until some condition holds:
- `wait()` — release the monitor lock and block until signaled.
- `signal()` — wake one waiting thread.

**Why monitors over raw semaphores:** semaphores are powerful but unstructured — one misplaced or forgotten `signal`/`wait` causes deadlocks or races that are brutal to debug. Monitors bundle the lock with the data and are far safer. Java's `synchronized`/`wait`/`notify` and C#'s `lock` are monitor-based.

> `⚠️ Semaphore vs Monitor:` a semaphore is a low-level integer signal you manage manually; a monitor is a high-level construct that *automatically* provides mutual exclusion for its methods and uses condition variables for waiting. Monitors trade some flexibility for a lot of safety.

---

## Interview Questions — M05

**Basic**

1. **What is a race condition?** → When concurrent, unsynchronized access to shared data makes the result depend on execution order (e.g., lost update from non-atomic `count++`).
2. **What is a critical section, and what 3 properties must a solution have?** → Code touching shared data that only one thread may execute at a time; requires mutual exclusion, progress, bounded waiting.
3. **Mutex vs semaphore?** → Mutex = ownership-based lock for mutual exclusion (binary). Semaphore = ownerless counter for managing N resources or signaling (counting or binary).
4. **What are `wait()` and `signal()`?** → Atomic semaphore ops: `wait` decrements (blocks if ≤0), `signal` increments (wakes a waiter). (a.k.a. P/V, down/up.)

**Intermediate**

1. **Why must `wait(empty)` come before `wait(mutex)` in producer-consumer?** → Otherwise a producer could hold `mutex` and then block on a full buffer, sleeping with the lock held → deadlock.
2. **Binary semaphore vs mutex?** → Both allow one thread in, but a mutex has ownership (only the locker unlocks; enables priority inheritance); a binary semaphore is ownerless (any thread can signal), so it's for signaling, not safe as a plain lock.
3. **Spinlock vs blocking mutex — when to use which?** → Spinlock for very short critical sections on multiprocessors (busy-wait avoids context-switch cost); blocking mutex for longer waits (sleep instead of burning CPU).
4. **What problem do monitors solve over semaphores?** → They bundle the lock with the data and enforce mutual exclusion automatically, removing the error-prone manual `wait`/`signal` pairing.

**Advanced**

1. **Why doesn't Peterson's solution work reliably on modern hardware?** → CPUs reorder memory operations (out-of-order execution); without memory barriers the flag/turn writes can be observed out of order, breaking mutual exclusion. Use hardware atomics instead.
2. **How does the readers-writers solution starve writers, and how would you fix it?** → Readers keep `rw_mutex` held as long as any reader is active, so a steady stream of readers blocks writers forever. Fix: writer-preference or a fair queue (e.g., a turnstile semaphore).
3. **What hardware primitive underlies lock-free structures, and how?** → Compare-and-Swap (CAS): atomically update a value only if it still equals an expected value, enabling optimistic retry loops without locks.

---

## Quick Interview Definitions — M05

- **Race condition:** Result depends on unsynchronized thread interleaving over shared data.
- **Critical section:** Code accessing shared data that must run under mutual exclusion.
- **Mutual exclusion / Progress / Bounded waiting:** The three requirements of a correct CS solution.
- **Mutex:** Ownership-based lock providing mutual exclusion.
- **Semaphore:** Atomic counter (`wait`/`signal`); counting or binary; for resource counting or signaling.
- **Spinlock:** A busy-waiting lock (spins instead of sleeping).
- **Monitor:** High-level construct enforcing mutual exclusion over its methods, with condition variables.
- **Deadlock (preview):** Threads blocked forever waiting on each other (M06).

---

## ⚠️ Common Mistakes — M05

- **`count++` is atomic.** It's load-increment-store — interruptible.
- **Mutual exclusion = a correct solution.** Also need progress and bounded waiting.
- **Mutex = binary semaphore.** Mutex has ownership; binary semaphore doesn't.
- **Semaphore is only for locking.** It's equally for **signaling/ordering** and **counting N resources**.
- **Taking the mutex before the counting semaphore** in producer-consumer → deadlock.
- **Semaphores are "safe."** They're low-level and easy to misuse (a forgotten signal deadlocks); monitors are safer.
- **Spinlocks are always bad / always good.** Great for ultra-short CS, wasteful for long ones.

---

## 🧠 RECALL — M05 (cover the answers)

1. Three CS requirements? → *mutual exclusion, progress, bounded waiting*.
2. Why is `count++` unsafe? → *load-inc-store can interleave → lost update*.
3. Mutex has ___ that a semaphore lacks? → *ownership*.
4. Counting semaphore init value = ? → *number of available resource units*.
5. In producer-consumer, which `wait` comes first? → *`wait(empty)`/`wait(full)` before `wait(mutex)`*.
6. Readers-writers (reader-preference) starves whom? → *writers*.
7. High-level, auto-mutual-exclusion construct? → *monitor*.
8. Hardware atomic behind lock-free code? → *compare-and-swap*.

---

### → Next: **M06 · Deadlocks** — the dining-philosophers deadlock, formalized: the 4 conditions, prevention/avoidance/detection, and the Banker's algorithm.
