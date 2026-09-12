# M08 · Virtual Memory 🔥

> `💡 FRAMING` — Paging (M07) put every process's memory into pages with a page table. Virtual memory takes one more step: **most of a process's pages don't need to be in RAM at once** — keep only the actively-used ones, park the rest on disk, and fetch a page the instant it's touched. This lets programs be **bigger than physical RAM** and lets **more processes** fit. The whole chapter is the consequence of one gamble (**locality**): it works because programs touch a small set of pages at a time — until they don't, and you get **thrashing**.

Prereqs (M07): paging, page table, page/frame, the valid bit.

---

## 8.1 What is virtual memory?

**What it is.** A technique that lets a process execute even if it's **not fully in RAM**. The logical address space is separated from physical RAM; pages live in RAM **or** on disk (in the **swap space** / backing store), and the OS shuttles them as needed.

**Why:** (1) run programs larger than physical memory; (2) fit **more** processes in RAM → higher multiprogramming and CPU utilization; (3) faster startup (load only what's needed). It works because of **locality of reference** — programs tend to use a small, slowly-changing subset of their pages.

---

## 8.2 Demand Paging 🔥

**Idea.** Don't load a page until it's **demanded** (referenced). Start the process with (almost) nothing in RAM; bring pages in on first touch ("**lazy** loading").

**The valid/invalid bit.** Each page-table entry has a bit:
- **valid** → page is in RAM (translate normally).
- **invalid** → page is **on disk** (or illegal). Touching it triggers a **page fault**.

```
   PTE:  [ frame number | valid/invalid bit | protection bits ... ]
                                  |
                        v = in RAM     i = on disk (fault!)
```

---

## 8.3 Page Fault handling 🔥 (know the steps)

A **page fault** is the trap raised when a process accesses a page whose PTE is marked invalid (not in RAM). It is **not an error** — it's the normal demand-paging mechanism. Steps:

```
 1. CPU references a page; MMU sees the PTE is invalid -> TRAP to OS
 2. OS checks: is the reference legal? (else segfault/kill)
 3. Find a FREE FRAME (if none, run PAGE REPLACEMENT to evict one - 8.4)
 4. Schedule a DISK READ to load the page into that frame
    (the process is BLOCKED meanwhile; CPU may run another process - M04)
 5. Disk done -> update the PTE (valid, point to the frame)
 6. RESTART the instruction that faulted; now it succeeds
```

**Cost:** a page fault involves a **disk access** (~milliseconds) — ~10,000–100,000× slower than a RAM access (~100 ns). So the **page-fault rate must be tiny** for demand paging to perform (see 8.8).

---

## 8.4 Page Replacement Algorithms 🔥

When a page must come in but **no frame is free**, choose a **victim** page to evict. If the victim was modified, it must be written back to disk first (tracked by a **dirty/modify bit** — clean pages can be dropped for free). Goal: **minimize page faults**.

We compare algorithms on the reference string **7 0 1 2 0 3 0 4 2 3 0 3 2** with **3 frames**.

### FIFO — First-In, First-Out
Evict the page that has been in memory longest (a simple queue). Easy, but can evict a hot page.

```
 ref: 7  0  1  2  0  3  0  4  2  3  0  3  2
      -------------------------------------
 f1:  7  7  7  2  2  2  2  4  4  4  0  0  0
 f2:     0  0  0  0  3  3  3  3  3  3  3  3
 f3:        1  1  1  1  0  0  0  2  2  2  2
 flt: F  F  F  F  .  F  F  F  F  F  F  .  .
```
**FIFO faults = 10.**

### Optimal (OPT / MIN) — the theoretical best
Evict the page that **won't be used for the longest time in the future**. Gives the minimum possible faults — but requires knowing the future, so it's **unimplementable** (used only as a benchmark).

```
 ref: 7  0  1  2  0  3  0  4  2  3  0  3  2
 flt: F  F  F  F  .  F  .  F  .  .  F  .  .
```
**Optimal faults = 7.** (At each fault, evict whichever resident page is referenced farthest ahead / never again.)

### LRU — Least Recently Used
Evict the page **unused for the longest time in the past** — a practical approximation of Optimal, betting the recent past predicts the near future (locality).

```
 ref: 7  0  1  2  0  3  0  4  2  3  0  3  2
 flt: F  F  F  F  .  F  .  F  F  F  F  .  .
```
**LRU faults = 9.**

**Result: Optimal (7) < LRU (9) < FIFO (10)** — the usual ordering. LRU tracks well but is expensive to implement exactly (needs a timestamp/stack update on **every** access), so real systems **approximate** it:

- **Clock / Second-Chance** — FIFO plus a **reference bit**: on eviction, if a page's ref bit is 1, clear it and give a "second chance" (skip it) instead of evicting; evict the first page with ref bit 0. Cheap LRU approximation used in practice.
- **LFU / MFU** ○ — least/most frequently used (counter-based); rarely used alone.

---

## 8.5 Belady's Anomaly ⭐

**Normally, more frames → fewer page faults.** **Belady's anomaly** is the counter-intuitive case where, for **FIFO**, **adding frames can *increase* faults**.

Reference string **1 2 3 4 1 2 5 1 2 3 4 5** under FIFO:

| Frames | Page faults |
|:------:|:-----------:|
| **3** | **9** |
| **4** | **10** ← more frames, more faults! |

- **Why FIFO?** It ignores usage — a bigger queue can change eviction order badly.
- **LRU and Optimal never suffer Belady's anomaly** — they belong to the class of **stack algorithms** (the set of pages with *n* frames is always a subset of the set with *n+1* frames). This is a classic interview fact.

---

## 8.6 Thrashing 🔥

**What it is.** **Thrashing** is when a process (or the system) spends **more time paging (servicing page faults) than executing** — CPU utilization collapses because everyone is waiting on the disk.

**Why it happens.** Too high a degree of multiprogramming → each process gets **too few frames** to hold its active set → constant page faults. Vicious cycle:

```
 High multiprogramming -> each process has too few frames
   -> page-fault rate soars -> processes block on disk
   -> CPU utilization drops -> scheduler adds MORE processes (thinking CPU is idle!)
   -> even fewer frames each -> MORE faults ...  (collapse)
```

**The "working set" idea (fix).** The **working set** of a process is the set of pages it's actively using in a recent time window. If the OS ensures each process has enough frames to hold its **working set**, faults stay low. Two control mechanisms:
- **Working-Set Model** — track each process's working set; only admit a process if its working set fits; suspend/swap out processes when total working sets exceed RAM.
- **Page-Fault Frequency (PFF)** — monitor each process's fault rate: too high → give it more frames; too low → take some away. Directly targets the symptom.

> `⚠️ Trap — thrashing vs normal paging:` occasional page faults are healthy demand paging. **Thrashing** is the pathological regime where fault-servicing dominates and throughput craters. The cause is too little memory per process (over-committed multiprogramming), and the cure is reducing multiprogramming / honoring working sets — **not** a faster disk.

---

## 8.7 TLB — Translation Lookaside Buffer 🔥

**Problem (from M07).** With the page table in RAM, every logical access needs **two** RAM accesses (page table + data). **Solution:** the **TLB**, a small, fast, **associative cache** inside the MMU holding recent page→frame translations.

```
   logical addr -> [ TLB ]
                     hit  -> frame number immediately (fast)
                     miss -> read page table in RAM, then load TLB, then access
```

- **TLB hit** → translation is instant (no page-table RAM access).
- **TLB miss** → do the normal page-table lookup, then cache the result. (On a context switch to a different address space, the TLB is typically **flushed** — the cost we noted back in M02/M03.)

### Effective (Memory) Access Time — EMAT

```
   EMAT = hit_ratio × (TLB_time + mem_time)
        + miss_ratio × (TLB_time + 2 × mem_time)     [page table in RAM = 1 extra access]
```

**Worked example:** TLB access = **20 ns**, memory access = **100 ns**, hit ratio = **80%**.
- Hit path: 20 + 100 = **120 ns**
- Miss path: 20 + 100 (page table) + 100 (data) = **220 ns**
- **EMAT = 0.8×120 + 0.2×220 = 96 + 44 = 140 ns**

(Contrast a raw single access of 100 ns — the ~40% overhead is why a *high* TLB hit ratio matters. Real TLBs hit ~99%+.)

---

## 8.8 Demand-paging performance (EAT with fault rate)

Page faults hit disk, so even a tiny fault rate dominates access time. Let **p** = page-fault rate:

```
   EAT = (1 − p) × memory_access_time + p × page_fault_service_time
```

**Worked example:** memory access = **100 ns**, page-fault service = **8 ms = 8,000,000 ns**, p = **0.001** (1 fault per 1000 accesses):
- EAT = 0.999 × 100 + 0.001 × 8,000,000 = 99.9 + 8000 ≈ **8100 ns**

That's **~80× slower** than the 100 ns no-fault case — from just a 0.1% fault rate. Takeaway: demand paging only performs when the fault rate is **extremely** low (locality + enough frames).

---

## Interview Questions — M08

**Basic**

1. **What is virtual memory?** → A technique letting a process run without being fully in RAM; pages live in RAM or on disk and are fetched on demand, allowing programs bigger than physical memory and higher multiprogramming.
2. **What is demand paging / a page fault?** → Loading pages only when referenced; a page fault is the trap when a referenced page isn't in RAM, prompting the OS to load it from disk. It's normal, not an error.
3. **What does a page-replacement algorithm do?** → Chooses which resident page to evict when a new page must be loaded and no frame is free, aiming to minimize future faults.
4. **What is the TLB?** → A fast associative cache of recent page→frame translations that avoids the extra RAM access for the page table.

**Intermediate**

1. **FIFO vs LRU vs Optimal?** → FIFO evicts the oldest-loaded page (simple, can evict hot pages). LRU evicts the least-recently-used (approximates Optimal via locality). Optimal evicts the page used farthest in the future (best but unimplementable — needs the future).
2. **What is thrashing and what causes it?** → Excessive paging where servicing faults dominates execution and CPU utilization collapses; caused by too little memory per process (over-committed multiprogramming). Fix by honoring working sets / reducing multiprogramming.
3. **Compute EMAT** given TLB and memory times and a hit ratio. → EMAT = hit×(TLB+mem) + miss×(TLB+2·mem); e.g., 0.8×120 + 0.2×220 = 140 ns.
4. **What is the dirty bit for?** → Marks a page modified since load; a clean victim can be dropped without a disk write, a dirty one must be written back — saving I/O on eviction.

**Advanced**

1. **What is Belady's anomaly, and which algorithms avoid it?** → For FIFO, adding frames can increase faults. LRU and Optimal (stack algorithms) never do, because their resident set with n frames is a subset of that with n+1.
2. **How does the working-set model prevent thrashing?** → It estimates each process's actively-used page set over a recent window and ensures each process has enough frames for its working set (suspending processes if the sum exceeds RAM), keeping fault rates low.
3. **Why can even a 0.1% page-fault rate cripple performance?** → A fault costs a disk access (~ms), ~10⁴–10⁵× a RAM access; the EAT formula shows the rare fault term dominates (e.g., EAT ≈ 8100 ns vs 100 ns).
4. **How does Clock/second-chance approximate LRU cheaply?** → It uses a reference bit and a circular scan: a page with ref bit 1 gets it cleared and is skipped (second chance); the first page with ref bit 0 is evicted — approximating "recently used" without per-access timestamps.

---

## Quick Interview Definitions — M08

- **Virtual memory:** Running processes partly in RAM, rest on disk, fetched on demand.
- **Demand paging:** Loading pages only when first referenced.
- **Page fault:** Trap when a referenced page isn't resident; OS loads it from disk.
- **Page replacement:** Selecting a victim page to evict (FIFO/Optimal/LRU/Clock).
- **Belady's anomaly:** More frames → more faults (FIFO only).
- **Thrashing:** Paging dominates execution; CPU utilization collapses.
- **Working set:** The pages a process is actively using in a recent window.
- **TLB:** Cache of recent address translations.
- **EMAT / EAT:** Effective access time accounting for TLB hits/misses (or fault rate).
- **Dirty bit:** Marks a modified page needing write-back on eviction.

---

## ⚠️ Common Mistakes — M08

- **A page fault is an error.** It's the normal demand-paging mechanism (unless the reference is illegal).
- **More frames always means fewer faults.** Not for FIFO (Belady's anomaly).
- **LRU = Optimal.** LRU looks at the past; Optimal at the future (and is unimplementable).
- **Thrashing is fixed by a faster disk.** It's a memory-shortage problem; reduce multiprogramming / honor working sets.
- **TLB caches data.** No — it caches *translations* (page→frame), not memory contents.
- **Ignoring the dirty bit** — clean pages evict for free; only dirty ones need write-back.
- **Confusing page size with performance** — the fault *rate* and disk latency dominate EAT, not clever arithmetic.

---

## 🧠 RECALL — M08 (cover the answers)

1. Page fault = ? → *trap when a referenced page isn't in RAM → load from disk*.
2. Optimal evicts which page? → *the one used farthest in the future*.
3. LRU approximates Optimal using? → *locality (recent past predicts near future)*.
4. On the sample string (3 frames): FIFO/LRU/OPT faults? → *10 / 9 / 7*.
5. Belady's anomaly affects which algorithm? → *FIFO*; avoided by *LRU/Optimal (stack algorithms)*.
6. Thrashing cause & cure? → *too few frames per process* → *reduce multiprogramming / working set*.
7. TLB caches? → *translations (page→frame)*.
8. EMAT for hit 0.8, TLB 20, mem 100? → *140 ns*.
9. Why does a 0.1% fault rate hurt? → *disk access ~10⁴–10⁵× slower dominates EAT*.

---

### → Next: **M09 · File Systems** (files, directories, allocation methods, inodes) and **M10 · I/O & Disk Scheduling**. Then **M11 · IPC** and the **M12 · Last-Minute Revision** (Top 50 Q&A + cheat sheet). Say **"continue"**.
