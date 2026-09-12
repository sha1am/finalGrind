# M06 · Deadlocks 🔥

> `💡 FRAMING` — Locks (M05) solve races but create a new danger: two threads each holding a resource the other needs, each waiting forever. **Deadlock is the price of mutual exclusion.** The whole chapter is one question in four answers: given the four conditions that *together* cause deadlock, do you (a) design so one can never hold, (b) dynamically dodge unsafe states, (c) let it happen and clean up, or (d) ignore it?

Prereqs (M05): locks/semaphores, resources, the dining-philosophers deadlock.

---

## 6.1 What is a deadlock?

**What it is.** A **deadlock** is a state where a set of processes are each **blocked forever**, because each holds a resource the next one in the set is waiting for.

**Example (the two-lock deadlock):**

```
   Thread 1:                 Thread 2:
     lock(A)                   lock(B)
     lock(B)  <-- waits        lock(A)  <-- waits
   T1 holds A, wants B.  T2 holds B, wants A.  Neither can proceed. Forever.
```

Classic real analogy: a **narrow bridge** — two cars from opposite ends meet in the middle; neither will back up.

---

## 6.2 The 4 Necessary Conditions (Coffman conditions) 🔥

**All four must hold simultaneously** for deadlock. Break any one → no deadlock. (This is the key: they're necessary *together*.)

| # | Condition | Meaning |
|---|-----------|---------|
| 1 | **Mutual Exclusion** | At least one resource is non-shareable (only one process at a time). |
| 2 | **Hold and Wait** | A process holds ≥1 resource **while waiting** to acquire others. |
| 3 | **No Preemption** | A resource can't be forcibly taken; it's released only voluntarily. |
| 4 | **Circular Wait** | A cycle of processes exists, each waiting for a resource held by the next: P1→P2→…→Pn→P1. |

> `⚠️ Trap:` all four are **necessary but not, on their own, sufficient** *in general* — with multiple instances per resource type, a cycle (condition 4) doesn't *guarantee* deadlock; it only guarantees it when each resource type has a **single instance**. This nuance shows up with resource-allocation graphs (below).

---

## 6.3 Resource-Allocation Graph (RAG) ⭐

A directed graph modeling who holds/wants what:
- **Process** = circle, **Resource type** = box (dots inside = instances).
- **Request edge**: P → R (process wants resource).
- **Assignment edge**: R → P (resource assigned to process).

```
      P1 ---> R1 ---> P2 ---> R2 ---> P1     (a cycle P1->R1->P2->R2->P1)
      (request)  (assign) (request) (assign)
```

**Reading it:**
- **No cycle** ⇒ **no deadlock** (guaranteed).
- **Cycle** with **single-instance** resources ⇒ **deadlock**.
- **Cycle** with **multiple-instance** resources ⇒ **maybe** deadlock (need further checking — an instance held by a process outside the cycle might free up).

---

## 6.4 The four handling strategies (overview)

| Strategy | Idea | Used by |
|----------|------|---------|
| **Prevention** | Design so one of the 4 conditions can **never** hold | Static, conservative |
| **Avoidance** | Grant a request only if the system **stays in a safe state** (needs future-needs info) | Banker's algorithm |
| **Detection & Recovery** | Let deadlocks happen, **detect** cycles, then recover | Databases |
| **Ignorance ("Ostrich")** | Pretend it can't happen; reboot if it does | **Linux, Windows** (deadlocks are rare; handling is costly) |

---

## 6.5 Deadlock Prevention 🔥 (negate one of the 4)

Ensure at least one condition cannot hold:

| Break condition | How | Downside |
|-----------------|-----|----------|
| **Mutual exclusion** | Make resources shareable (e.g., read-only files); use spooling | Many resources are inherently non-shareable (printer, lock) — often impossible |
| **Hold and wait** | Require a process to request **all** resources up front (or hold none while requesting) | Low utilization; **starvation** (may never get everything at once) |
| **No preemption** | If a process requests a resource it can't get, it must **release** all it holds and retry | Only works for state that can be saved/restored (CPU, memory — not a printer mid-print) |
| **Circular wait** | Impose a **total ordering** on resource types; require requests in increasing order | Simple & widely used; but ordering can be awkward and reduce flexibility |

> `⚠️ SUPPLEMENT — the one used in real code:` **resource ordering** (break circular wait) is the practical prevention technique programmers actually apply — "always acquire lock A before lock B, everywhere." It's how you eliminate the two-lock deadlock in 6.1: make every thread lock in the same global order.

---

## 6.6 Deadlock Avoidance & the Banker's Algorithm 🔥

**Idea.** Instead of static restrictions, decide **dynamically**: before granting a resource request, check whether doing so leaves the system in a **safe state**. If not, make the process wait.

- **Safe state** = there exists a **safe sequence** — an ordering of all processes such that each can obtain its **maximum** needs (using currently free resources + resources freed by earlier processes in the sequence), run, and release. Safe ⇒ deadlock can be avoided.
- **Unsafe state** ≠ deadlock, but it's a state from which deadlock *becomes possible*. Avoidance refuses to enter unsafe states.

**Banker's Algorithm** (Dijkstra) — like a banker only granting a loan if it can still satisfy everyone eventually. Data structures for *n* processes, *m* resource types:
- **Available[m]** — free instances of each resource.
- **Max[n][m]** — each process's maximum demand.
- **Allocation[n][m]** — currently held.
- **Need[n][m] = Max − Allocation** — what each may still request.

### Worked example (safety check)

3 resource types **A=10, B=5, C=7**. Current snapshot:

| Process | Allocation (A B C) | Max (A B C) | Need = Max − Alloc |
|---------|:---:|:---:|:---:|
| P0 | 0 1 0 | 7 5 3 | 7 4 3 |
| P1 | 2 0 0 | 3 2 2 | 1 2 2 |
| P2 | 3 0 2 | 9 0 2 | 6 0 0 |
| P3 | 2 1 1 | 2 2 2 | 0 1 1 |
| P4 | 0 0 2 | 4 3 3 | 4 3 1 |

Total allocated = (7, 2, 5) → **Available = (10,5,7) − (7,2,5) = (3, 3, 2)**.

**Safety algorithm** — Work = Available = (3,3,2); Finish[i]=false for all. Repeatedly find a process whose Need ≤ Work, "run" it, and add its Allocation back to Work:

```
 Work=(3,3,2)
 P1: Need(1,2,2) ≤ (3,3,2)? YES → Work += Alloc(2,0,0) = (5,3,2)   [P1 done]
 P3: Need(0,1,1) ≤ (5,3,2)? YES → Work += (2,1,1)       = (7,4,3)   [P3 done]
 P4: Need(4,3,1) ≤ (7,4,3)? YES → Work += (0,0,2)       = (7,4,5)   [P4 done]
 P0: Need(7,4,3) ≤ (7,4,5)? YES → Work += (0,1,0)       = (7,5,5)   [P0 done]
 P2: Need(6,0,0) ≤ (7,5,5)? YES → Work += (3,0,2)       = (10,5,7)  [P2 done]
```

All finish → **SAFE**. A safe sequence is **⟨P1, P3, P4, P0, P2⟩**. (Others may exist.)

### Resource-request check

Now suppose **P1 requests (1, 0, 2)**. Steps:
1. **Request ≤ Need_P1?** (1,0,2) ≤ (1,2,2)? **Yes.**
2. **Request ≤ Available?** (1,0,2) ≤ (3,3,2)? **Yes.**
3. **Pretend to grant** and re-check safety:
   - Available → (3,3,2) − (1,0,2) = **(2,3,0)**
   - Alloc_P1 → (3,0,2); Need_P1 → (0,2,0)
   - Run safety from Work=(2,3,0): P1(0,2,0)✓→(5,3,2); P3(0,1,1)✓→(7,4,3); P4✓→(7,4,5); P0✓→(7,5,5); P2✓→(10,5,7). **Safe** (sequence ⟨P1,P3,P4,P0,P2⟩).

→ The request **can be granted**. If the safety check had failed, P1 would **wait** even though the resources are physically available.

> `⚠️ Trap — unsafe ≠ deadlocked:` an unsafe state has no *guaranteed* safe sequence but may not deadlock in practice. Banker's is **conservative** — it refuses some grants that wouldn't actually have deadlocked. That conservatism, plus needing each process's **max** in advance, is why real OSes rarely use it.

---

## 6.7 Deadlock Detection & Recovery ⭐

**Detection.** Let deadlocks happen; periodically run a **detection algorithm**:
- **Single instance per resource** → build a **wait-for graph** (collapse the RAG to process→process edges) and look for a **cycle**.
- **Multiple instances** → a Banker's-like algorithm (but using *current requests* instead of *max*) that finds whether all processes can finish.

**Recovery** (once detected):
- **Process termination** — abort all deadlocked processes, or abort one at a time until the cycle breaks (choosing a low-cost "victim").
- **Resource preemption** — forcibly take resources from some process and give them to others; may require **rollback** to a safe checkpoint. Risk: **starvation** if the same process is always the victim (mitigate by counting rollbacks).

---

## 6.8 Deadlock vs Starvation vs Livelock 🔥 (trap)

| | Deadlock | Starvation | Livelock |
|--|----------|------------|----------|
| What | A set of processes **all** blocked, waiting on each other | One process waits **indefinitely** while others proceed | Processes **actively change state** but make no progress |
| Progress in system? | **None** for the group | Yes (others run) | No, but nobody is "blocked" |
| Cause | 4 conditions hold | Priority/policy keeps deprioritizing one | Overly polite retry logic (both back off repeatedly in sync) |
| Fix | Prevent/avoid/detect | **Aging** | Add randomness/backoff |

**Mnemonic:** *Deadlock = stuck waiting; Livelock = stuck retrying; Starvation = stuck at the back of the line.*

---

## Interview Questions — M06

**Basic**

1. **What is a deadlock?** → A set of processes each blocked forever, holding a resource another needs.
2. **Name the four conditions for deadlock.** → Mutual exclusion, hold and wait, no preemption, circular wait (all must hold together).
3. **How can you prevent deadlock in your own code with two locks?** → Always acquire the locks in the same global order (break circular wait).
4. **Deadlock vs starvation?** → Deadlock: a group is mutually stuck, no progress. Starvation: one process waits forever while others progress; fixed by aging.

**Intermediate**

1. **Prevention vs avoidance?** → Prevention statically ensures one of the four conditions can never hold. Avoidance dynamically grants requests only if the system stays in a safe state (needs max-need info; e.g., Banker's).
2. **What is a safe state?** → One with a safe sequence: every process can obtain its max needs in some order using free + freed resources, run, and release. Safe ⇒ no deadlock.
3. **Does a cycle in a resource-allocation graph always mean deadlock?** → Only if every resource type has a single instance. With multiple instances, a cycle is necessary but not sufficient.
4. **Why don't Linux/Windows use the Banker's algorithm?** → It needs each process's maximum demand up front, is conservative (refuses safe-enough grants), and has overhead; deadlocks are rare, so they use the "ostrich" approach.

**Advanced**

1. **Walk through the Banker's safety check for a given snapshot.** → Compute Need = Max − Alloc and Available; set Work = Available; repeatedly find a process with Need ≤ Work, add its Allocation to Work, mark it finished; if all finish, it's safe (that order is a safe sequence).
2. **Unsafe state vs deadlock — are they the same?** → No. Unsafe means no guaranteed safe sequence, so deadlock is *possible*; the system may still avoid it. Deadlock is the actual stuck state.
3. **What is a livelock and how does it differ from deadlock?** → In livelock processes keep changing state (e.g., repeatedly yielding to each other) but make no progress; unlike deadlock they aren't blocked. Fix with randomized backoff.

---

## Quick Interview Definitions — M06

- **Deadlock:** Processes blocked forever, each holding a resource another needs.
- **Coffman conditions:** Mutual exclusion, hold-and-wait, no preemption, circular wait — all four needed.
- **Circular wait:** A cycle of processes each waiting on the next's resource.
- **Safe state:** A state with a safe sequence guaranteeing everyone can finish.
- **Banker's algorithm:** Avoidance method that grants a request only if the resulting state is safe.
- **Deadlock detection:** Finding deadlock after the fact (wait-for-graph cycle or a Banker-like check).
- **Starvation:** Indefinite waiting of one process while others proceed (fixed by aging).
- **Livelock:** Active but progress-free state.

---

## ⚠️ Common Mistakes — M06

- **Breaking one condition isn't enough.** Actually it **is** — since all four are needed together, negating any one prevents deadlock.
- **Cycle in RAG ⇒ deadlock, always.** Only with single-instance resources.
- **Unsafe state = deadlock.** Unsafe only means deadlock is possible.
- **Banker's runs the processes.** No — it's a *check*; it simulates to test safety before granting.
- **Deadlock = starvation.** Group-stuck vs one-process-waiting; different causes and fixes.
- **Prevention = avoidance.** Static structural guarantee vs dynamic safe-state checking.

---

## 🧠 RECALL — M06 (cover the answers)

1. Four deadlock conditions? → *mutual exclusion, hold & wait, no preemption, circular wait*.
2. Practical way to break circular wait in code? → *acquire locks in a fixed global order*.
3. Need = ? → *Max − Allocation*.
4. Safety check: run a process when? → *its Need ≤ Work (available)*.
5. Safe sequence for the worked example? → *⟨P1,P3,P4,P0,P2⟩*.
6. Cycle ⇒ deadlock only when? → *single instance per resource type*.
7. What do Linux/Windows do about deadlock? → *ignore it (ostrich)*.
8. Fix for starvation vs livelock? → *aging* vs *randomized backoff*.

---

### → Next: **M07 · Memory Management** — how the address space of a process (M02) is actually laid into physical RAM: binding, MMU, fragmentation, paging (with address translation), segmentation.
