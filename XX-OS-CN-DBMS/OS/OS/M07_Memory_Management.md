# M07 · Memory Management 🔥

> `💡 FRAMING` — Every process thinks it owns a clean, contiguous memory starting at address 0 (M02's address space). Reality: physical RAM is one shared array, shared by many processes, smaller than what they collectively want. **Memory management is the illusion machine** that maps each process's private *logical* addresses onto scattered *physical* RAM — safely (no process reads another's memory) and efficiently (little waste). The chapter builds toward **paging**, the technique that makes this illusion practical.

Prereqs (M02): a process has an address space (text/data/heap/stack); multiprogramming keeps several in RAM.

---

## 7.1 Logical vs Physical Address & the MMU 🔥

- **Logical (virtual) address** — the address the CPU/program generates. Always from 0..max *as the program sees it*.
- **Physical address** — the actual address in RAM.
- **MMU (Memory Management Unit)** — hardware that translates logical → physical **at runtime**, on every memory access.

```
   CPU ---- logical addr ----> [ MMU ] ---- physical addr ----> RAM
                                  ^
                            translation (base+limit, or page table)
```

**Simplest scheme — base & limit registers:** physical = **base + logical**; the **limit** register bounds the logical address so a process can't step outside its region (protection). If logical ≥ limit → **trap** (segmentation fault).

**Address binding** (when logical names become physical) can happen at:
- **Compile time** — if load address is known (absolute code; rare).
- **Load time** — relocatable code fixed when loaded.
- **Execution time** — bound during execution by the MMU. **This is what modern systems use** (needed for swapping/paging; the process can move in RAM).

> `⚠️ Trap — logical vs physical:` the program **never** sees physical addresses; it only ever uses logical ones. The MMU does the mapping in hardware on every access. "Logical address space" is the set a process can name; "physical address space" is real RAM.

---

## 7.2 Contiguous allocation & partitioning ⭐

Early approach: give each process **one contiguous block** of RAM.

- **Fixed partitioning** — RAM divided into fixed-size partitions. Simple; wastes space when a process is smaller than its partition (**internal fragmentation**), and can't fit a process larger than the biggest partition.
- **Variable (dynamic) partitioning** — partitions created to fit each process. No internal fragmentation, but over time free memory breaks into small scattered holes (**external fragmentation**).

**Placement algorithms — where to put a new process among free holes:**

| Algorithm | Rule | Trade-off |
|-----------|------|-----------|
| **First Fit** | First hole big enough | Fast; decent |
| **Best Fit** | Smallest hole that fits | Minimizes leftover per-allocation, but creates many tiny unusable slivers; slower (scan all) |
| **Worst Fit** | Largest hole | Leaves a big usable remainder, but consumes big holes fast; generally poor |

**Quick example** — holes: [100, 500, 200, 300, 600] KB; process needs **212 KB**:
- First Fit → 500 (first that fits).
- Best Fit → 300 (smallest ≥212).
- Worst Fit → 600 (largest).

*(First Fit is usually the practical winner — nearly as good as Best Fit and faster.)*

---

## 7.3 Fragmentation: Internal vs External 🔥

| | **Internal Fragmentation** | **External Fragmentation** |
|--|----------------------------|----------------------------|
| What | Allocated block is **bigger than needed**; the unused part inside is wasted | Enough **total** free memory exists, but it's **split into scattered pieces** too small individually |
| Occurs in | Fixed partitioning; **paging** (last page partly used) | Variable partitioning; **segmentation** |
| Example | Need 18 KB, get a 20 KB frame → 2 KB wasted inside | 3 free holes of 10 KB each (30 KB free) but a 25 KB process won't fit any single hole |
| Fix | Smaller allocation units | **Compaction** (shuffle to coalesce holes) or **paging** (non-contiguous allocation) |

**Compaction** — relocate processes to squeeze all free memory into one contiguous block. Removes external fragmentation but is expensive (lots of copying) and needs execution-time binding.

> `⚠️ Trap:` **paging eliminates external fragmentation** (any free frame works) but introduces a little **internal** fragmentation (the last page of a process is usually not full). Segmentation is the opposite (no internal, but external). Know which technique causes which.

---

## 7.4 Paging 🔥 (the core technique)

**Intuition.** Stop demanding one big contiguous block. Instead, chop the process's logical memory into fixed-size **pages** and RAM into equal-size **frames**, then scatter the pages into **any** free frames. A **page table** remembers where each page landed. Because any frame fits any page, **external fragmentation vanishes**.

**Terms:**
- **Page** — fixed-size chunk of *logical* address space.
- **Frame** — same-size chunk of *physical* memory.
- **Page size = frame size** (a power of 2, e.g., 4 KB).
- **Page table** — per-process map: page number → frame number.

**Address translation.** A logical address splits into two parts:

```
   Logical address = [ page number (p) | offset (d) ]
                                |
                      page table[p] -> frame number (f)
                                |
   Physical address = [ frame number (f) | offset (d) ]   (offset unchanged)
```

If page size = 2^d bytes, the low **d** bits are the offset; the rest are the page number. The **offset is copied through unchanged** — only the page/frame number is translated.

### Worked example 1 (tiny numbers)
Page size = **4 bytes**. Logical address = **13**. Suppose page table maps **page 3 → frame 6**.
- page number p = 13 ÷ 4 = **3**, offset d = 13 mod 4 = **1**
- frame f = page_table[3] = **6**
- physical address = f × page_size + d = 6×4 + 1 = **25**

### Worked example 2 (bit splitting & page-table size)
Logical address = **32 bits**, page size = **4 KB = 2^12**.
- offset = **12 bits**; page number = 32 − 12 = **20 bits** → **2^20 ≈ 1 million** page-table entries per process.
- If each entry is 4 bytes → page table is **4 MB per process** — large! (This motivates multi-level/inverted page tables and the TLB in M08.)

**Cost of paging.** The page table lives in RAM, so a naive memory access needs **two** RAM accesses: one to read the page table, one for the actual data → ~2× slowdown. **The TLB (M08) fixes this** by caching recent translations.

> `⚠️ Trap — page vs frame:` a **page** is logical, a **frame** is physical; they're the same *size*. Paging causes **internal** fragmentation only (avg ½ page per process, in the last page) — not external.

---

## 7.5 Segmentation ⭐

**Intuition.** Paging splits memory by a fixed size, ignoring meaning. **Segmentation** splits by the program's *logical* units — a segment each for code, stack, heap, a large array, etc. — matching how programmers think. Each segment has a name/number and a **variable** length.

**Address translation** uses a **segment table** of (base, limit) pairs:

```
   Logical address = [ segment number (s) | offset (d) ]
   if d < limit[s]:  physical = base[s] + d      else -> trap (protection)
```

Segmentation gives natural **protection & sharing** at the segment level (e.g., mark the code segment read-only and share it). But because segments vary in size, it suffers **external fragmentation** (like variable partitioning).

### Paging vs Segmentation 🔥

| | **Paging** | **Segmentation** |
|--|-----------|------------------|
| Unit | Fixed-size **page** | Variable-size **segment** (logical unit) |
| Divided by | The OS (size), invisible to programmer | The program's logical structure |
| Address | page number + offset | segment number + offset |
| Table | Page table (frame numbers) | Segment table (base + limit) |
| Fragmentation | **Internal** (last page) | **External** |
| Fits programmer's view? | No | Yes |
| Protection/sharing | Per page (clumsier) | Per segment (natural) |

**Segmentation with paging** ○ — real systems (e.g., x86) combine them: segment the logical space, then page each segment — getting logical structure *and* no external fragmentation. Best of both.

---

## 7.6 Where this connects

Paging (7.4) sets up **M08 Virtual Memory**: once memory is in pages with a page table, you can leave some pages on disk and load them only when accessed (**demand paging**) — making a process's virtual space larger than physical RAM. The page table's **valid/invalid bit** becomes the trigger for a **page fault**.

---

## Interview Questions — M07

**Basic**

1. **Logical vs physical address?** → Logical = generated by the CPU/program (what the program sees); physical = actual RAM address. The MMU translates logical→physical at runtime.
2. **What is the MMU?** → Hardware that maps logical to physical addresses on every access (base+limit, or via the page table).
3. **Internal vs external fragmentation?** → Internal: wasted space *inside* an allocated block (block bigger than needed). External: enough total free memory but split into scattered too-small holes.
4. **What is paging?** → Splitting logical memory into fixed-size pages and RAM into equal frames, mapping pages to any free frames via a page table; eliminates external fragmentation.

**Intermediate**

1. **How does address translation work in paging?** → Split the logical address into page number + offset; look up the frame number in the page table; physical address = frame number + the same offset.
2. **Paging vs segmentation?** → Paging = fixed-size, OS-defined, internal fragmentation, per-page protection. Segmentation = variable-size logical units, external fragmentation, natural per-segment protection/sharing.
3. **First fit vs best fit vs worst fit?** → First: first hole that fits (fast). Best: smallest sufficient hole (least leftover, but tiny slivers, slower). Worst: largest hole (big remainder, but eats big holes).
4. **Why does a naive paging scheme double memory-access time, and what fixes it?** → The page table is in RAM, so each access needs one lookup + one data access. The **TLB** caches translations to avoid the extra access.

**Advanced**

1. **For a 32-bit address space with 4 KB pages, how big is a single-level page table?** → Offset = 12 bits, page number = 20 bits → 2^20 entries; at 4 bytes each ≈ 4 MB per process — which motivates multi-level or inverted page tables.
2. **Does paging cause internal or external fragmentation, and how much on average?** → Internal only, averaging about half a page per process (the partially used last page).
3. **How does segmentation provide better sharing/protection than paging?** → Segments align with logical units, so you can mark a whole segment (e.g., code) read-only or shared cleanly, versus tagging many arbitrary pages.

---

## Quick Interview Definitions — M07

- **Logical/Physical address:** Program-generated vs actual RAM address.
- **MMU:** Hardware doing runtime logical→physical translation.
- **Paging:** Fixed-size pages mapped to frames via a page table; no external fragmentation.
- **Page / Frame:** Logical chunk / physical chunk (same size).
- **Page table:** Per-process page→frame map.
- **Segmentation:** Variable-size, logically meaningful memory units via a (base, limit) segment table.
- **Internal fragmentation:** Waste inside an allocated block.
- **External fragmentation:** Free memory scattered into unusable pieces.
- **Compaction:** Relocating processes to coalesce free memory.

---

## ⚠️ Common Mistakes — M07

- **Program uses physical addresses.** No — only logical; the MMU maps them.
- **Page = frame with no distinction.** Same size, but page = logical, frame = physical.
- **Paging causes external fragmentation.** It removes it; it causes minor *internal* fragmentation.
- **Segmentation causes internal fragmentation.** No — external (variable sizes).
- **Best fit is best.** It often creates tiny useless slivers; first fit is usually better in practice.
- **Offset gets translated.** Only the page/segment number is translated; the offset passes through.

---

## 🧠 RECALL — M07 (cover the answers)

1. Who translates logical→physical, and when? → *the MMU, at runtime (execution-time binding)*.
2. Paging removes which fragmentation, adds which? → *removes external, adds internal*.
3. Logical address splits into? → *page number + offset*.
4. What passes through translation unchanged? → *the offset*.
5. 32-bit space, 4 KB pages → entries? → *2^20 (~1M)*.
6. Why is naive paging ~2× slower? → *page table is in RAM (extra access)* → fixed by the *TLB*.
7. Segmentation fragmentation type? → *external*.
8. First/Best/Worst fit for need 212 in [100,500,200,300,600]? → *500 / 300 / 600*.

---

### → Next: **M08 · Virtual Memory** — leave pages on disk and load on demand: page faults, replacement algorithms (FIFO/Optimal/LRU), Belady's anomaly, thrashing, and the TLB with EMAT.
