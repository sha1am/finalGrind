# Process

## Definition

A process is a running instance of a program together with its execution state and resources: virtual address space, registers, open files, credentials, threads and OS bookkeeping.

## Program vs process

A **program** is passive code/data stored somewhere. A **process** is an executing instance with state.

```text
program + address space + resources + execution state = process
```

## Process isolation

Each normal process sees its own virtual address space. Two processes can contain the same virtual address, such as `0x1000`, while the addresses map to different physical memory.

## Interview questions

- What is a process?
- Can two processes share memory? Yes, explicitly via shared memory/mmap or other mechanisms.
- Does one process necessarily mean one thread? No.
## Small example

Running the same executable twice creates two processes. They may execute the same instructions, but each has its own process state and virtual address space.

```text
program: server
   ├─ PID 1001 → virtual address 0x400000 → its mapping
   └─ PID 1002 → virtual address 0x400000 → different mapping
```
