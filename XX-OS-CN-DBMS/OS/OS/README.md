# Operating Systems — Interview Notes (README)

Dense, interview-optimized OS notes for **SDE / Backend interview prep (SDE-2 level)**, organized as numbered modules **M01, M02, …** (like a lecture playlist).

---

## What this is

A complete, teach-from-scratch OS course reorganized for interviews. Built from **CodeHelp's *Complete Operating Systems in 1 Shot*** (a ~16-hour placement course following the standard Silberschatz *OS Concepts* syllabus), then **taught and restructured** into a fundamentals → advanced progression. Every technical claim is cross-checked against **OSTEP** (*Operating Systems: Three Easy Pieces*).

This is **not** a video transcript — it's a rewritten reference optimized for conceptual clarity, connections, interview relevance, and fast revision.

## How to study

1. **Open `INDEX.md`** — the map: roadmap (with prerequisites), progress tracker, and concept → module lookup.
2. **Follow the module order** (M01 → M12). Don't skip prerequisites.
3. **First pass:** read a module fully; focus on the `💡 FRAMING` box and ASCII diagrams.
4. **Practice:** do each module's **Interview Questions** out loud, check against answers.
5. **Revise:** use each module's **`🧠 RECALL`** sheet, then **M12** (Top 50 Q&A + 1-page cheat sheet).
6. **Prioritize by marker:** 🔥 → ⭐ → ○.

> **Module MNN = Chapter N.** Inside the files you'll see "Ch.2", "Ch.4", etc.; these map one-to-one to M02, M04, and so on.

---

## Conventions

| Marker | Meaning |
|--------|---------|
| 🔥 | **VERY IMPORTANT** — asked constantly |
| ⭐ | **IMPORTANT** — should know cold |
| ○ | **LOW PRIORITY** — good to know |

| Box | Meaning |
|-----|---------|
| `💡 FRAMING` | The core tension a topic is really about |
| `⚠️ SUPPLEMENT` | Material **beyond** a typical one-shot video (senior depth / correction) |
| `🧠 RECALL` | 60-second self-test at chapter end |
| `⚠️ Trap` / `⚠️ Common Mistakes` | Look-alike concepts candidates confuse |

**Teaching spine** (applied organically): *What → Why → How → Example → Terms → Connects to → Interview angle → Trap.*

## Source & correctness policy

Primary source = the CodeHelp OS one-shot (coverage/ordering). Verification = OSTEP. Where a typical one-shot video is loose or outdated (e.g. "thread = lightweight process", mutex/semaphore conflation, "mode switch = context switch"), the notes **flag and correct** it.

---

## Files

| File | Contents | Status |
|------|----------|--------|
| `README.md` | This file | ✅ |
| `INDEX.md` | Roadmap + TOC + progress tracker + concept lookup | ✅ |
| `M01_OS_Fundamentals.md` | OS fundamentals, kernel, modes, system calls | ✅ |
| `M02_Processes.md` | Process, PCB, states, context switch, fork/exec, zombie/orphan | ✅ |
| `M03_Threads.md` | Threads, process vs thread, concurrency vs parallelism | ✅ |
| `M04_CPU_Scheduling.md` | Scheduling metrics + FCFS/SJF/SRTF/Priority/RR (worked) | ✅ |
| `M05_Synchronization.md` | Race condition, critical section, mutex, semaphore, classic problems, monitors | ✅ |
| `M06_Deadlocks.md` | 4 conditions, RAG, prevention/avoidance/detection, Banker's (worked) | ✅ |
| `M07_Memory_Management.md` | Binding, MMU, fragmentation, paging (translation), segmentation | ✅ |
| `M08_Virtual_Memory.md` | Demand paging, page replacement, Belady, thrashing, TLB/EMAT | ✅ |
| `M09_File_Systems.md` | Files, access, directories, allocation methods, inodes, links | ✅ |
| `M10_IO_and_Disk_Scheduling.md` | Polling/interrupt/DMA, disk structure, FCFS/SSTF/SCAN/LOOK (worked) | ✅ |
| `M11_IPC.md` | Shared memory vs message passing, pipes, sockets, signals | ✅ |
| `M12_Revision.md` | Checklist, all tables, all formulas, key diagrams, Top 50 Q&A, cheat sheet | ✅ |

**Start:** `INDEX.md` → `M01_OS_Fundamentals.md`.
