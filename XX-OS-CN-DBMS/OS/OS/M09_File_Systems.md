# M09 · File Systems ⭐

> `💡 FRAMING` — The disk is a flat array of numbered blocks with no notion of "a file." The file system is the abstraction (M01's "persistence") that turns that array into named, growable, protected files organized in directories — and the central design question is **allocation**: *given a file that grows over time, which disk blocks hold it, and how do you find them fast without wasting space?*

Prereqs (M07): blocks, allocation, fragmentation ideas.

---

## 9.1 File concept, attributes, operations

**A file** is a named collection of related information stored on secondary storage — the logical unit the OS presents to users (who never see raw blocks).

**Attributes (metadata):** name, unique identifier (inode number), type, size, location (pointers to blocks), protection (permissions), timestamps (created/modified/accessed), owner.

**Operations (map to system calls, M01):** create, open, read, write, seek (reposition), close, delete, truncate. The OS keeps an **open-file table** so an open file is referenced by a small descriptor (fd) instead of re-resolving the path each time.

---

## 9.2 File Access Methods ⭐

| Method | How | Use case |
|--------|-----|----------|
| **Sequential** | Read/write in order, front to back (like a tape) | Logs, streaming — most common |
| **Direct / Random** | Jump to any block number directly | Databases, indexes |
| **Indexed** | An index maps keys → block locations; look up the index, then the block | Large searchable files (built on direct access) |

---

## 9.3 Directory Structure ⭐

A **directory** maps file names → their metadata/location. Evolution:

| Structure | Idea | Limitation |
|-----------|------|------------|
| **Single-level** | One directory for all files | Name collisions; no organization |
| **Two-level** | One directory per user | No grouping within a user |
| **Tree** | Directories nest arbitrarily (today's norm) | No sharing of a file in two places |
| **Acyclic graph** | Allow shared subdirs/files via **links** | Must prevent cycles; deletion/ref-counting gets tricky |

---

## 9.4 File Allocation Methods 🔥 (the core comparison)

How a file's data blocks are laid out on disk and tracked.

### Contiguous allocation
File occupies **consecutive** blocks. Directory stores **start block + length**.

```
   File A: [12][13][14][15]      (blocks 12-15, contiguous)
```
- ✅ Excellent sequential **and** direct access (block *i* = start + *i*); simple.
- ❌ **External fragmentation**; hard to grow a file (neighbor blocks may be taken); must know size up front.

### Linked allocation
File is a **linked list** of blocks scattered anywhere; each block stores a pointer to the next. Directory stores **first (and last) block**.

```
   start -> [9|→17] -> [17|→3] -> [3|→NULL]
```
- ✅ **No external fragmentation**; files grow easily.
- ❌ **No efficient direct access** (must traverse from the start to reach block *i*); pointer space overhead; one broken pointer loses the rest. **FAT** (File Allocation Table) is a linked variant that keeps all the pointers in a table in memory → makes traversal/direct access far faster.

### Indexed allocation
Each file has an **index block** holding an array of all its data-block pointers. Directory points to the index block.

```
   index block -> [ 9, 17, 3, 25, ... ]   (data blocks anywhere)
```
- ✅ Direct access (index[i] → block); no external fragmentation.
- ❌ Index-block **space overhead** (even for small files); **max file size** limited by how many pointers fit in one index block — solved by **linked index blocks** or **multi-level index**.

| | Contiguous | Linked | Indexed |
|--|-----------|--------|---------|
| Direct access | ✅ fast | ❌ slow (traverse) | ✅ fast |
| External fragmentation | ❌ yes | ✅ none | ✅ none |
| Grow file | ❌ hard | ✅ easy | ✅ easy |
| Overhead | start+len only | 1 pointer/block | index block/file |
| Reliability | good | poor (broken link) | good |

> `⚠️ Trap:` "Linked allocation supports fast random access." **No** — it's the one method that doesn't (you must walk the chain). Contiguous and indexed do.

---

## 9.5 inodes ⭐ (the Unix realization of indexed allocation)

An **inode** ("index node") is the on-disk structure holding a file's **metadata + block pointers** — everything about a file **except its name** (names live in directory entries that point to an inode number).

Classic inode uses a **multi-level index** to handle both tiny and huge files efficiently:

```
   inode:
     metadata (perms, owner, size, timestamps)
     12 DIRECT pointers ----------------> data blocks       (small files)
     1  SINGLE-INDIRECT pointer --------> index block -> data
     1  DOUBLE-INDIRECT pointer --------> index -> index -> data
     1  TRIPLE-INDIRECT pointer --------> index -> index -> index -> data  (huge files)
```

Small files need only direct pointers (fast, low overhead); large files transparently gain capacity through indirection. **Path resolution** (`/home/user/a.txt`): read root inode → find `home` → its inode → find `user` → its inode → find `a.txt` → its inode → its data blocks.

**Hard link vs soft (symbolic) link** (frequent question):

| | **Hard link** | **Soft / Symbolic link** |
|--|---------------|--------------------------|
| What | Another directory entry pointing to the **same inode** | A file that **stores a path** to another file |
| Cross filesystems? | ❌ No (inodes are per-FS) | ✅ Yes |
| If original deleted? | File survives (inode ref-count > 0) | Link **dangles** (broken) |
| Points to | The inode (the data) | The name/path |

---

## 9.6 Free-Space Management ⭐

The FS must track which blocks are free:

| Method | Idea | Trade-off |
|--------|------|-----------|
| **Bit vector (bitmap)** | 1 bit per block (1=free, 0=used) | Simple; easy to find runs of free blocks; bitmap must be in memory for speed |
| **Linked list** | Free blocks chained together | No wasted space, but slow to traverse; can't easily find contiguous runs |
| **Grouping / Counting** | Store addresses of many free blocks in one, or (start, count) runs | Compact for clustered free space |

---

## Interview Questions — M09

**Basic**

1. **What is a file system?** → The OS layer that organizes disk blocks into named, protected, growable files and directories, and tracks their metadata and free space.
2. **Contiguous vs linked vs indexed allocation?** → Contiguous: consecutive blocks (fast access, external fragmentation, hard to grow). Linked: scattered blocks chained (no fragmentation, easy grow, no random access). Indexed: an index block of pointers (random access, no fragmentation, index overhead).
3. **What is an inode?** → A structure holding a file's metadata and data-block pointers — everything but the name; the name lives in a directory entry pointing to the inode.
4. **Hard link vs soft link?** → Hard link: another name for the same inode (same FS, survives original deletion). Soft link: a file containing a path (can cross FS, dangles if the target is deleted).

**Intermediate**

1. **Why can't linked allocation do efficient random access?** → Block *i* is reachable only by following pointers from the start; there's no formula from block number to location. (FAT mitigates this by caching all pointers in a table.)
2. **How do inodes support both small and huge files efficiently?** → Direct pointers serve small files cheaply; single/double/triple indirect pointers add capacity for large files only when needed.
3. **Bitmap vs linked list for free space?** → Bitmap: one bit per block, easy to find contiguous free runs, needs to be in memory. Linked list: chains free blocks, no extra space but slow and poor for finding runs.

**Advanced**

1. **What limits maximum file size in simple indexed allocation, and how is it solved?** → The number of pointers that fit in one index block; solved by linked index blocks or multi-level (indirect) indexing as in inodes.
2. **Trace a pathname lookup for `/a/b/c`.** → Read root inode → directory entry for `a` → a's inode → entry for `b` → b's inode → entry for `c` → c's inode → data blocks.

---

## Quick Interview Definitions — M09

- **File:** Named collection of related data on secondary storage.
- **Directory:** Maps file names → metadata/inode.
- **Contiguous/Linked/Indexed allocation:** Consecutive blocks / chained blocks / index block of pointers.
- **inode:** Per-file metadata + block pointers (no name).
- **Hard link / Soft link:** Same-inode alias / path-containing file.
- **Bitmap (free-space):** One bit per block marking free/used.

---

## ⚠️ Common Mistakes — M09

- **Linked allocation supports random access.** It doesn't (traverse-only).
- **inode stores the file name.** No — the name is in the directory entry; the inode has everything else.
- **Deleting a file with a hard link deletes the data.** Only when the inode's link count hits 0.
- **Soft link = hard link.** Soft link stores a path (can dangle, cross FS); hard link shares the inode.
- **Contiguous allocation has no downside.** External fragmentation + hard to grow.

---

## 🧠 RECALL — M09 (cover the answers)

1. Which allocation lacks random access? → *linked*.
2. Which allocation suffers external fragmentation? → *contiguous*.
3. inode holds everything except? → *the file name*.
4. Hard link survives original deletion? → *yes* (ref count); soft link → *dangles*.
5. Free-space method good at finding contiguous runs? → *bitmap*.
6. How do inodes fit huge files? → *single/double/triple indirect blocks*.

---

### → Next: **M10 · I/O & Disk Scheduling.**
