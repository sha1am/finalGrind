# What Is an Operating System?

## 1. What is it?

An operating system is privileged software that manages hardware resources and provides controlled abstractions to applications. It turns difficult hardware operations into reusable interfaces such as **processes, virtual memory, files and sockets**.

## 2. Why do we need it?

Without an OS, every application would need to understand CPU control, memory devices, disks, interrupts and device-specific protocols. The OS also isolates programs so one process cannot freely corrupt another.

## 3. Core concept

Think of the OS as two things at once:

- **Resource manager:** decides who gets CPU time, memory, storage and devices.
- **Abstraction provider:** exposes simpler objects such as a process, file descriptor or virtual address space.

## 4. Mental model

```text
Applications
     |
 libraries / runtime
     |
 system calls
     v
+------------------+
| Kernel           |
| CPU | Memory | IO|
+------------------+
     |
  Hardware
```

## 5. Example

A backend process calls `read(fd, buf, n)`. It does not directly program an SSD. The kernel validates the request, consults the filesystem/page cache, talks to the device when needed, and returns bytes.

## 6. Interview points

- OS is not merely a UI; Linux servers can run without a graphical desktop.
- Kernel is the privileged core; the OS is the broader software environment.
- The OS provides **isolation + sharing + abstraction**.

## 7. Common confusion

**OS vs kernel:** kernel is the privileged core. User-space utilities, libraries and services are part of the broader operating-system environment.

## 8. Interview questions

- What are the main responsibilities of an OS?
- Why is an OS called a resource manager?
- Why does an application need a kernel?
## Small example

If two programs both try to use the CPU, RAM, and disk, they should not directly fight over hardware. The OS gives each program an execution environment and arbitrates access to those resources.

```text
Program A ─┐
Program B ─┼─> Operating System ─> CPU / RAM / Disk / Network
Program C ─┘
```
