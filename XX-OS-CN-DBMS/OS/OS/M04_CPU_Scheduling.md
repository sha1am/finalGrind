# M04 · CPU Scheduling 🔥

> `💡 FRAMING` — Many processes are Ready but there's one CPU. **CPU scheduling is the decision of *which* ready process runs next, and for how long.** Every algorithm is just a different answer optimizing a different metric — and those metrics (throughput, waiting time, response time, fairness) are in tension, so there is no single "best" scheduler. The other axis running through the whole chapter: **preemptive** (can yank the CPU away) vs **non-preemptive** (run to completion/block).

Prereqs (from M02–M03): process states (Ready/Running/Waiting), the ready queue, context switch (the cost paid every time we switch).

---

## 4.1 What & why: the CPU–I/O burst cycle

Processes alternate between **CPU bursts** (computing) and **I/O bursts** (waiting for I/O):

```
   ... CPU burst -> I/O burst -> CPU burst -> I/O burst -> CPU burst -> exit
```

While a process is in an I/O burst it can't use the CPU — so instead of idling, the OS gives the CPU to another ready process. Deciding **who** is the scheduler's job. This is what makes multiprogramming (M01) actually improve utilization.

**When does the scheduler run? (4 decision points)** A running process can go to:
1. **Running → Waiting** (issues I/O / `wait()`)
2. **Running → Ready** (interrupt / time-slice expiry) ← *preemption*
3. **Waiting → Ready** (I/O completes)
4. **Running → Terminated** (exits)

- **Non-preemptive** scheduling makes a decision only at **1 and 4** (the CPU is given up voluntarily). Once a process has the CPU, it keeps it until it blocks or finishes.
- **Preemptive** scheduling can also decide at **2 and 3** (forcibly take the CPU). Needs the **timer interrupt** (M01) to work.

**The dispatcher** — the component that actually hands the CPU to the process the scheduler chose: it does the **context switch**, switches to user mode, and jumps to the right instruction. The time this takes is **dispatch latency** (pure overhead).

---

## 4.2 Preemptive vs Non-preemptive 🔥

| | **Non-preemptive** | **Preemptive** |
|--|--------------------|----------------|
| CPU taken away? | No — process runs until it blocks/exits | Yes — can be forced off (timer, higher priority) |
| Decision points | Running→Waiting, Running→Terminated | All four (adds Running→Ready, Waiting→Ready) |
| Needs timer? | No | **Yes** |
| Responsiveness | Poor (a long job hogs the CPU) | Good (time-sharing possible) |
| Overhead | Low (fewer context switches) | Higher (more switches) |
| Risk | **Convoy effect**, poor response time | Race conditions on shared data (→ M05), starvation |
| Examples | FCFS, SJF, non-preemptive Priority | SRTF, Round Robin, preemptive Priority |

> `⚠️ Trap:` "Preemptive is always better." It gives better response time and fairness but costs more context switches and *introduces the need for synchronization* (a process can be interrupted mid-update of shared data → M05). Trade-off, not a free win.

---

## 4.3 Scheduling criteria & the formulas 🔥

You must be able to define and compute these. Let each process have **Arrival Time (AT)** and **Burst Time (BT)** (its CPU-burst length).

| Metric | Meaning | Goal |
|--------|---------|------|
| **CPU utilization** | % of time CPU is busy | maximize |
| **Throughput** | processes completed per unit time | maximize |
| **Turnaround Time (TAT)** | total time from arrival to completion | minimize |
| **Waiting Time (WT)** | time spent waiting in the ready queue | minimize |
| **Response Time (RT)** | arrival until the process **first** gets the CPU | minimize |

**Formulas (memorize):**

```
   Completion Time (CT) = the clock time the process finishes
   Turnaround Time (TAT) = CT − AT
   Waiting Time   (WT)  = TAT − BT        (= CT − AT − BT)
   Response Time  (RT)  = (time of FIRST CPU allocation) − AT
   Average X = (sum of X over all processes) / N
```

**Intuition:**
- **TAT** = how long the whole thing took, start (arrival) to finish.
- **WT** = of that total, how much was spent *just waiting* (not running, not doing I/O in these simplified problems).
- **RT** = how quickly the system *reacted* — matters for interactive systems (a 3-second-to-first-keystroke terminal feels broken even if TAT is fine).

> `⚠️ Trap — WT vs RT vs TAT:` In **non-preemptive** schedules, a process runs in one uninterrupted block, so its **RT = WT** (first CPU = only CPU). In **preemptive** schedules they differ: RT is measured at the *first* dispatch, but WT accumulates across *all* the gaps it sat in the ready queue. Interviewers probe exactly this distinction.

---

## 4.4 The algorithms

### (a) FCFS — First-Come, First-Served ⭐ (non-preemptive)

**Idea:** run processes in arrival order — a simple FIFO queue. Fair in the "first-come" sense, trivial to implement.

**Worked example:**

| Process | AT | BT |
|---------|----|----|
| P1 | 0 | 4 |
| P2 | 1 | 3 |
| P3 | 2 | 2 |

```
 Gantt:  | P1 | P2 | P3 |
         0    4    7    9
```

| Process | CT | TAT=CT−AT | WT=TAT−BT | RT |
|---------|----|-----------|-----------|----|
| P1 | 4 | 4 | 0 | 0 |
| P2 | 7 | 6 | 3 | 3 |
| P3 | 9 | 7 | 5 | 5 |

**Avg TAT = 17/3 ≈ 5.67 · Avg WT = 8/3 ≈ 2.67**

**The problem — Convoy Effect:** if one long (CPU-bound) process arrives first, all the short processes queue behind it and their waiting time explodes. E.g., BT = [100, 1, 1] → the two tiny jobs each wait ~100. Like one loaded truck holding up a line of cars. FCFS's fatal flaw.

- **Pros:** simple, no starvation (everyone eventually runs).
- **Cons:** convoy effect; bad average waiting/response time; terrible for interactive systems.

---

### (b) SJF — Shortest Job First 🔥 (non-preemptive)

**Idea:** when the CPU is free, pick the ready process with the **smallest burst time**. Ties → FCFS (earlier arrival).

**Why it matters:** SJF is **provably optimal for average waiting time** among non-preemptive algorithms (short jobs first minimizes total waiting). This optimality result is a common interview fact.

**Worked example:**

| Process | AT | BT |
|---------|----|----|
| P1 | 0 | 7 |
| P2 | 2 | 4 |
| P3 | 4 | 1 |
| P4 | 5 | 4 |

At t=0 only P1 is present → it runs to completion (non-preemptive) [0–7]. At t=7, ready = {P2(4), P3(1), P4(4)} → shortest is P3 [7–8]. Then P2 & P4 tie at 4 → earlier arrival P2 [8–12]. Then P4 [12–16].

```
 Gantt:  | P1 | P3 | P2 | P4 |
         0    7   8    12   16
```

| Process | AT | BT | CT | TAT | WT |
|---------|----|----|----|-----|----|
| P1 | 0 | 7 | 7 | 7 | 0 |
| P2 | 2 | 4 | 12 | 10 | 6 |
| P3 | 4 | 1 | 8 | 4 | 3 |
| P4 | 5 | 4 | 16 | 11 | 7 |

**Avg TAT = 32/4 = 8.0 · Avg WT = 16/4 = 4.0**

- **Pros:** minimal average waiting time (optimal).
- **Cons:** (1) **Starvation** — long jobs may never run if short jobs keep arriving. (2) **You can't know the burst time in advance** — it must be *estimated*.

> `⚠️ SUPPLEMENT — how burst length is predicted:` Since future burst length is unknown, the OS estimates it with **exponential averaging** of past bursts:
> `τ(n+1) = α·t(n) + (1−α)·τ(n)` where `t(n)` = actual last burst, `τ(n)` = previous estimate, `α ∈ [0,1]` (commonly 0.5). This is why "pure SJF" is theoretical — real schedulers approximate it.

---

### (c) SRTF — Shortest Remaining Time First 🔥 (preemptive SJF)

**Idea:** the preemptive version of SJF. At **every arrival**, compare the new process's burst with the **remaining time** of the running process; if the newcomer is shorter, **preempt**.

**Worked example (classic):**

| Process | AT | BT |
|---------|----|----|
| P1 | 0 | 8 |
| P2 | 1 | 4 |
| P3 | 2 | 9 |
| P4 | 3 | 5 |

- t0–1: P1 runs (rem 8→7).
- t1: P2 arrives (4) < P1 rem 7 → **preempt**, run P2. (t2: P3 arrives rem 9 > P2 rem 3 → keep P2. t3: P4 arrives rem 5 > P2 rem 2 → keep P2.) P2 finishes at t5.
- t5: ready = P1(7), P3(9), P4(5) → P4 shortest, run P4 [5–10].
- t10: ready = P1(7), P3(9) → P1, run P1 [10–17].
- t17: P3 [17–26].

```
 Gantt:  | P1 | P2 | P4 | P1  | P3  |
         0    1    5    10    17    26
```

| Process | AT | BT | CT | TAT=CT−AT | WT=TAT−BT | RT |
|---------|----|----|----|-----------|-----------|----|
| P1 | 0 | 8 | 17 | 17 | 9 | 0 |
| P2 | 1 | 4 | 5 | 4 | 0 | 0 |
| P3 | 2 | 9 | 26 | 24 | 15 | 15 |
| P4 | 3 | 5 | 10 | 7 | 2 | 2 |

**Avg TAT = 52/4 = 13.0 · Avg WT = 26/4 = 6.5**

Note P1: RT = 0 (first ran at t0) but WT = 9 (it was preempted and waited t1–t10). **This is the RT ≠ WT case.**

- **Pros:** even lower average waiting time than SJF (best possible for avg WT).
- **Cons:** more context switches; still needs burst prediction; **starvation** of long jobs.

---

### (d) Priority Scheduling 🔥 (preemptive OR non-preemptive)

**Idea:** each process has a **priority**; the CPU goes to the highest-priority ready process. (Convention here: **lower number = higher priority** — always confirm the convention in an interview!) SJF is a special case where priority = inverse of burst length.

**Worked example (non-preemptive, lower number = higher priority):**

| Process | AT | BT | Priority |
|---------|----|----|----------|
| P1 | 0 | 4 | 2 |
| P2 | 1 | 3 | 1 (highest) |
| P3 | 2 | 1 | 3 |
| P4 | 3 | 2 | 4 (lowest) |

At t0 only P1 present → P1 [0–4] (non-preemptive, runs fully). At t4 ready = {P2(1), P3(3), P4(4)} → highest priority P2 [4–7]. Then P3 [7–8], then P4 [8–10].

```
 Gantt:  | P1 | P2 | P3 | P4 |
         0    4    7    8    10
```

| Process | CT | TAT | WT |
|---------|----|-----|----|
| P1 | 4 | 4 | 0 |
| P2 | 7 | 6 | 3 |
| P3 | 8 | 6 | 5 |
| P4 | 10 | 7 | 5 |

**Avg TAT = 23/4 = 5.75 · Avg WT = 13/4 = 3.25**

**The problem — Starvation (indefinite blocking):** low-priority processes may never run if higher-priority ones keep arriving. **Solution: Aging** — gradually **increase** the priority of a process the longer it waits, so it eventually runs.

> `⚠️ Trap — Starvation vs Deadlock (previewing M06):` Starvation = a process waits *indefinitely* but the system as a whole is making progress (others run). Deadlock = a set of processes are *all* stuck waiting on each other; no one progresses. Aging fixes starvation; it does nothing for deadlock.

---

### (e) Round Robin (RR) 🔥 (preemptive) — the interactive-systems workhorse

**Idea:** FCFS + a fixed **time quantum (time slice)**. Each process runs for at most one quantum, then is preempted and sent to the **back** of the ready queue. Cyclic, fair, great **response time**.

**Worked example (quantum = 2):**

| Process | AT | BT |
|---------|----|----|
| P1 | 0 | 4 |
| P2 | 1 | 5 |
| P3 | 2 | 2 |
| P4 | 3 | 1 |

Simulating the ready queue (newly arrived processes are enqueued before a just-preempted one):

```
 Gantt:  | P1 | P2 | P3 | P1 | P4 | P2  |
         0    2    4    6    8    9    12
```

- t0–2: P1 (rem 4→2). Queue builds: P2(t1), P3(t2) arrive → [P2,P3], then P1 requeues → [P2,P3,P1].
- t2–4: P2 (rem 5→3). P4(t3) arrives → queue [P3,P1,P4], then P2 requeues → [P3,P1,P4,P2].
- t4–6: P3 (rem 2→0) **done**. Queue [P1,P4,P2].
- t6–8: P1 (rem 2→0) **done**. Queue [P4,P2].
- t8–9: P4 (rem 1→0) **done** (used < full quantum). Queue [P2].
- t9–12: P2 (rem 3→0) **done** (runs out its final bursts; queue empty so uninterrupted).

| Process | AT | BT | CT | TAT | WT | RT |
|---------|----|----|----|-----|----|----|
| P1 | 0 | 4 | 8 | 8 | 4 | 0 |
| P2 | 1 | 5 | 12 | 11 | 6 | 1 |
| P3 | 2 | 2 | 6 | 4 | 2 | 2 |
| P4 | 3 | 1 | 9 | 6 | 5 | 5 |

**Avg TAT = 29/4 = 7.25 · Avg WT = 17/4 = 4.25**

**The quantum trade-off (key insight):**

```
 Quantum too LARGE  ->  RR degenerates into FCFS (each process finishes in one slice)
 Quantum too SMALL  ->  too many context switches -> overhead dominates, throughput drops
 Rule of thumb: quantum should be slightly larger than a typical CPU burst
                (~80% of bursts should finish within one quantum)
```

- **Pros:** fair, no starvation (everyone gets a slice), excellent response time → ideal for **time-sharing / interactive** systems.
- **Cons:** higher average turnaround than SJF; performance is very sensitive to quantum size; context-switch overhead.

---

### (f) Multilevel Queue & Multilevel Feedback Queue (MLFQ) ⭐

**Multilevel Queue:** partition the ready queue into several separate queues by process type (e.g., **system > interactive > batch**), each with its own scheduling algorithm. A process stays in **one** queue permanently. Downside: inflexible; lower queues can starve.

**Multilevel Feedback Queue (MLFQ):** like above, but processes can **move between queues** based on behavior. Typical rules: new processes start high; a process that uses its whole quantum (CPU-bound) is **demoted**; a process that yields for I/O (interactive) stays high; **aging** periodically boosts long-waiting processes to prevent starvation.

> `⚠️ SUPPLEMENT — this is what real OSes actually use:` MLFQ is the practical scheme behind real schedulers because it **approximates SJF without needing to know burst times** (it *learns* them from behavior: short/interactive jobs float up, long CPU-bound jobs sink down) while using aging to avoid starvation. Modern Linux uses **CFS (Completely Fair Scheduler)** — a related but different, fairness-based design using a red-black tree of "virtual runtime" rather than fixed priority queues. Naming CFS is a strong senior signal.

---

## 4.5 Algorithm comparison (which optimizes what)

| Algorithm | Preemptive? | Optimizes | Main weakness |
|-----------|-------------|-----------|----------------|
| **FCFS** | No | Simplicity, fairness by arrival | Convoy effect; bad avg WT |
| **SJF** | No | **Min avg waiting time** (optimal) | Starvation; needs burst prediction |
| **SRTF** | Yes | Even lower avg WT | Starvation; more switches |
| **Priority** | Either | Importance-based ordering | Starvation → needs aging |
| **Round Robin** | Yes | **Response time / fairness** | High TAT; quantum-sensitive |
| **MLFQ** | Yes | Balances response + throughput; approximates SJF | Complex to tune |

**Rules of thumb:** batch systems → SJF/SRTF (throughput). Interactive systems → RR/MLFQ (response time). Real-time → priority-based with deadline awareness.

---

## Interview Questions — M04

**Basic**

1. **Define turnaround, waiting, and response time.** → TAT = CT − AT (arrival to completion); WT = TAT − BT (time in ready queue); RT = first-CPU-time − AT (arrival to first response).
2. **Preemptive vs non-preemptive scheduling?** → Non-preemptive: a process keeps the CPU until it blocks/exits (FCFS, SJF). Preemptive: the CPU can be forcibly taken (SRTF, RR, preemptive priority); needs a timer.
3. **What is the convoy effect?** → In FCFS, one long process forces all short ones to wait behind it, inflating average waiting time.
4. **What is the time quantum in Round Robin, and what happens at extremes?** → The max time a process runs before preemption. Too large → behaves like FCFS; too small → excessive context-switch overhead.

**Intermediate**

1. **Why is SJF optimal, and why isn't it used directly?** → It minimizes average waiting time (short jobs first). Not directly usable because burst times aren't known in advance (must be estimated via exponential averaging) and it can starve long jobs.
2. **SJF vs SRTF?** → SJF is non-preemptive (pick shortest when CPU frees). SRTF is preemptive (on each arrival, preempt if the newcomer's burst < running process's remaining time). SRTF gives lower avg WT but more context switches.
3. **How do you prevent starvation in priority scheduling?** → Aging: increase a waiting process's priority over time so it eventually runs.
4. **In a preemptive schedule, why can RT ≠ WT?** → RT is measured only at the first dispatch; WT sums every interval spent waiting in the ready queue, including after preemptions.

**Advanced**

1. **How does MLFQ approximate SJF without knowing burst times?** → It infers behavior: I/O-bound/interactive jobs (short bursts) stay in high-priority queues; CPU-bound jobs that consume full quanta are demoted. Aging prevents starvation. Effectively "short jobs first," learned dynamically.
2. **Which scheduler for an interactive OS vs a batch system, and why?** → Interactive: RR/MLFQ (low response time, fairness). Batch: SJF/SRTF (maximize throughput / minimize avg waiting; response time doesn't matter).
3. **What does Linux's CFS do differently?** → Instead of fixed priorities/quanta, it tracks each task's **virtual runtime** and always runs the task with the least, aiming for proportional fairness — approximating an ideal "each task gets 1/N of the CPU."

*(Practice drill: recompute the SRTF and RR examples above from scratch and check your Gantt charts and averages against the tables.)*

---

## Quick Interview Definitions — M04

- **CPU scheduling:** Choosing which ready process the CPU runs next.
- **Dispatcher:** The module that gives the CPU to the chosen process (does the context switch); its delay is dispatch latency.
- **Turnaround time:** Completion − Arrival.
- **Waiting time:** Turnaround − Burst (time spent in the ready queue).
- **Response time:** First CPU allocation − Arrival.
- **FCFS:** Run in arrival order (FIFO); suffers the convoy effect.
- **SJF/SRTF:** Shortest (remaining) burst first; optimal average waiting time; risks starvation.
- **Priority scheduling:** Highest-priority ready process runs; aging prevents starvation.
- **Round Robin:** Fixed time quantum, cyclic preemption; best response time.
- **Starvation:** A process waits indefinitely; fixed by aging.
- **Convoy effect:** Short processes stuck behind a long one under FCFS.

---

## ⚠️ Common Mistakes — M04

- **WT = TAT.** No — WT = TAT − BT.
- **RT = WT always.** Only for non-preemptive schedules; they differ under preemption.
- **SJF = SRTF.** SJF non-preemptive; SRTF preemptive.
- **"Preemptive is strictly better."** It improves responsiveness but adds context-switch overhead and *creates the need for synchronization* (M05).
- **Confusing priority direction.** Some conventions use higher number = higher priority. Always state your assumption.
- **Starvation = deadlock.** Starvation: one process waits forever while others progress (aging fixes it). Deadlock: a group is mutually stuck (M06).
- **RR quantum has no effect.** It's decisive: too big → FCFS, too small → overhead.
- **Forgetting arrival times** when building a Gantt chart (a process can't run before it arrives; the CPU may sit idle).

---

## 🧠 RECALL — M04 (cover the answers)

1. TAT, WT, RT formulas? → *CT−AT · TAT−BT · firstCPU−AT*.
2. Which algorithm minimizes average waiting time? → *SJF/SRTF*.
3. Which gives the best response time? → *Round Robin*.
4. FCFS's fatal flaw? → *convoy effect*.
5. Fix for starvation in priority scheduling? → *aging*.
6. Quantum too large → behaves like ___? → *FCFS*.
7. RT ≠ WT happens under which kind of scheduling? → *preemptive*.
8. SRTF is the preemptive version of ___? → *SJF*.
9. What real Linux scheduler replaces fixed-priority queues? → *CFS (virtual runtime)*.

---

### → Next: **M05 · Synchronization** (race conditions → critical section → mutex → semaphore → producer-consumer / readers-writers / dining philosophers). This is where preemption + shared memory (M03, M04) create the need for locks. Say **"continue"** for M05.
