# mmap and Copy-on-Write

`mmap()` maps files or anonymous memory into a process's virtual address space.

Uses include:

- file-backed access
- shared memory
- large-memory data structures
- efficient sharing between processes

### Copy-on-write

After `fork()`, parent and child can initially share physical pages marked read-only. When one writes, the kernel creates a private copy for that process.

```text
before write: P ----> page <---- C
                         |
                    shared physical page

after C writes: P ----> page A    page B <---- C
```

This makes `fork()+exec()` practical without copying an entire process address space eagerly.
## Small example

After `fork()`, parent and child can initially share physical pages marked for copy-on-write:

```text
Parent virtual page ─┐
                     ├─> same physical frame
Child virtual page  ─┘

child writes → kernel creates a private copy
```

## Sharpen this concept

- [Linux `mmap(2)`](https://man7.org/linux/man-pages/man2/mmap.2.html) — precise mapping and protection semantics.
- [Linux `fork(2)`](https://man7.org/linux/man-pages/man2/fork.2.html) — precise parent/child memory behavior.
