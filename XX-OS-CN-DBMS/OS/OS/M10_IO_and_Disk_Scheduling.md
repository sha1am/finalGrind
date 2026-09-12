# M10 · I/O & Disk Scheduling ⭐

> `💡 FRAMING` — Devices are slow, varied, and asynchronous; the CPU is fast. Two problems follow: *how does the CPU exchange data with a device without wasting cycles* (I/O methods), and *given many pending disk requests, in what order should the arm serve them to minimize the killer cost — seek time* (disk scheduling). Both are about **not letting slow I/O stall fast compute.**

Prereqs (M01): I/O structure, interrupts, device controllers.

---

## 10.1 I/O Methods 🔥 (how CPU ↔ device transfers happen)

| Method | How | CPU cost |
|--------|-----|----------|
| **Programmed I/O (polling)** | CPU repeatedly checks ("busy-waits" on) the device status register until ready, then transfers each word | **Terrible** — CPU spins doing nothing useful |
| **Interrupt-driven I/O** | CPU issues the request and continues other work; the device **interrupts** (M01) when ready; CPU transfers the data | Better — no busy-wait, but the CPU still handles **every word/byte** (one interrupt per unit) |
| **DMA (Direct Memory Access)** | A **DMA controller** transfers a whole block **directly** between device and RAM, interrupting the CPU only **once** when the whole block is done | **Best** — CPU is free during the transfer; used for disk/network |

```
 Polling:   CPU ---- check? check? check? ---- transfer (CPU busy throughout)
 Interrupt: CPU does other work ---- [IRQ] ---- CPU transfers one unit
 DMA:       CPU sets up DMA ---- (DMA moves whole block) ---- [1 IRQ] ---- done
```

> `⚠️ Trap — why DMA matters:` interrupt-driven I/O still interrupts the CPU **per byte/word**, which is expensive for a large transfer. **DMA offloads the whole block**, interrupting once — that's the point of DMA and a common interview distinction.

---

## 10.2 Disk structure & access time

A magnetic disk = stacked **platters**; each has concentric **tracks** divided into **sectors**; the same track across all platters = a **cylinder**. A **read/write head** on a moving arm accesses data.

**Disk access time = Seek + Rotational latency + Transfer:**

| Component | What | Typical |
|-----------|------|---------|
| **Seek time** | Move the arm to the target **cylinder** | ~a few ms — **the dominant, mechanical cost** |
| **Rotational latency** | Wait for the target **sector** to rotate under the head | ~half a rotation on average |
| **Transfer time** | Actually read/write the bits | small |

Because **seek time dominates**, disk scheduling tries to **minimize total head movement** across pending requests. (Note: SSDs have no seek/rotation — this whole section is about mechanical HDDs.)

---

## 10.3 Disk Scheduling Algorithms 🔥

**Setup for all examples:** disk cylinders **0–199**, head starts at **50**, request queue: **82, 170, 43, 140, 24, 16, 190**. We measure **total head movement** (proxy for seek time). Directional algorithms move **toward the high end (up) first**.

Sorted requests: `16 24 43 [50←head] 82 140 170 190`.

### FCFS — First-Come, First-Served
Serve in arrival order: 82→170→43→140→24→16→190.
```
 |50-82|+|82-170|+|170-43|+|43-140|+|140-24|+|24-16|+|16-190|
 = 32 + 88 + 127 + 97 + 116 + 8 + 174 = 642
```
**Total = 642.** Fair but lots of back-and-forth.

### SSTF — Shortest Seek Time First
Always serve the **nearest** pending request. From 50: →43→24→16→82→140→170→190.
```
 7 + 19 + 8 + 66 + 58 + 30 + 20 = 208
```
**Total = 208.** Much better, but can **starve** far-away requests (like SJF for the CPU).

### SCAN (Elevator)
Move in one direction to the **end of the disk**, then reverse. Up first: serve 82,140,170,190 → go to **199** → reverse → serve 43,24,16.
```
 (199 - 50)  +  (199 - 16)  = 149 + 183 = 332
```
**Total = 332.** No starvation; reaches the physical end (199) even with no request there.

### LOOK
Like SCAN but only go as far as the **last request** in each direction (never the physical end). Up first: to **190** → reverse → to **16**.
```
 (190 - 50)  +  (190 - 16)  = 140 + 174 = 314
```
**Total = 314.** SCAN without the wasted trip to the physical end.

### C-SCAN (Circular SCAN)
Go up to the end, **jump** back to the start, and continue in the **same** direction — giving more **uniform** wait times. Up to 199 → jump to 0 → up to 43.
```
 (199 - 50)  +  (199 - 0 jump)  +  (43 - 0) = 149 + 199 + 43 = 391
```
**Total = 391** (counting the return jump). The point isn't less movement — it's **fairness** (requests near either end wait equally, unlike SCAN where just-passed requests wait a full sweep).

### C-LOOK
Circular LOOK: up to the last request, jump to the lowest request, continue up. To 190 → jump to 16 → up to 43.
```
 (190 - 50)  +  (190 - 16 jump)  +  (43 - 16) = 140 + 174 + 27 = 341
```
**Total = 341.**

**Summary for this workload:**

| Algorithm | Total head movement | Note |
|-----------|:-------------------:|------|
| FCFS | 642 | fair, inefficient |
| SSTF | **208** | greedy-best distance, can starve |
| SCAN | 332 | to physical end, then reverse |
| LOOK | 314 | to last request, then reverse |
| C-SCAN | 391* | uniform wait (up + wrap) |
| C-LOOK | 341* | uniform wait, no physical-end trip |

*counting the wrap-around jump; conventions vary (some count only servicing movement).

> `⚠️ Trap:` SSTF usually has the **least** head movement but is **not** used blindly because it **starves** distant requests. SCAN/LOOK families trade a bit of movement for **no starvation** and are what real systems favor. Also: **direction assumption matters** — always state whether you move up or down first, since totals change.

---

## Interview Questions — M10

**Basic**

1. **Polling vs interrupt-driven vs DMA?** → Polling: CPU busy-waits on device status (wasteful). Interrupt-driven: device interrupts when ready, but CPU handles each unit. DMA: a controller moves a whole block to/from RAM directly, interrupting the CPU once.
2. **What are the components of disk access time?** → Seek time (move arm to cylinder — dominant), rotational latency (wait for sector), transfer time.
3. **What does disk scheduling optimize, and why?** → Total head movement / seek time, because seek is the dominant mechanical cost on an HDD.
4. **FCFS vs SSTF for the disk?** → FCFS serves in arrival order (fair, inefficient); SSTF serves the nearest request (efficient, can starve far requests).

**Intermediate**

1. **SCAN vs C-SCAN?** → SCAN sweeps to an end and reverses (just-passed requests wait a full round trip). C-SCAN sweeps one way, jumps back to the start, and repeats — giving more uniform waiting times.
2. **SCAN vs LOOK?** → SCAN goes to the physical end of the disk before reversing; LOOK only goes to the last pending request in that direction (saves the wasted trip).
3. **Why is DMA better than interrupt-driven I/O for large transfers?** → Interrupt-driven interrupts per unit; DMA transfers the whole block autonomously and interrupts once, freeing the CPU during the transfer.

**Advanced**

1. **Compute total head movement for SSTF** given head 50 and the queue above. → 50→43→24→16→82→140→170→190 = 7+19+8+66+58+30+20 = 208.
2. **Why isn't SSTF used despite the lowest movement?** → It can indefinitely starve requests far from the current head position; SCAN/LOOK avoid that.
3. **Do these algorithms matter for SSDs?** → No — SSDs have no moving head (no seek/rotational latency), so seek-minimizing schedules are irrelevant; SSD I/O scheduling optimizes other things (parallelism, wear).

---

## Quick Interview Definitions — M10

- **Polling / Programmed I/O:** CPU busy-waits checking device status.
- **Interrupt-driven I/O:** Device interrupts the CPU when ready.
- **DMA:** Controller transfers a whole block between device and RAM directly; one interrupt.
- **Seek time:** Time to move the arm to the target cylinder (dominant cost).
- **Rotational latency:** Wait for the sector to rotate under the head.
- **SSTF:** Serve the nearest pending request (can starve).
- **SCAN/LOOK:** Sweep to end/last-request then reverse.
- **C-SCAN/C-LOOK:** Sweep one way, wrap around — uniform waiting.

---

## ⚠️ Common Mistakes — M10

- **Interrupt-driven I/O and DMA are the same.** DMA offloads the whole block; interrupt-driven still involves the CPU per unit.
- **Transfer time dominates disk access.** Seek time dominates.
- **SSTF is always best.** Lowest movement, but starves distant requests.
- **Forgetting the direction assumption** in SCAN/LOOK/C-SCAN — totals depend on up vs down first.
- **Applying disk scheduling to SSDs.** No moving parts → no seek to optimize.

---

## 🧠 RECALL — M10 (cover the answers)

1. Dominant disk cost? → *seek time*.
2. I/O method that frees the CPU during a block transfer? → *DMA*.
3. SSTF risk? → *starvation of far requests*.
4. SCAN vs LOOK difference? → *SCAN goes to physical end; LOOK to last request*.
5. C-SCAN's benefit over SCAN? → *uniform waiting time*.
6. SSTF total for the sample (head 50)? → *208*.
7. Do these matter for SSDs? → *no (no seek)*.

---

### → Next: **M11 · IPC**, then the **M12 · Last-Minute Revision** capstone.
