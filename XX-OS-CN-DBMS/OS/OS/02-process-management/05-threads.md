# Threads

## What is a thread?

A thread is an independently schedulable execution path within a process. Threads in one process typically share the process's address space and many resources.

### Shared

- code/data/heap
- virtual address space
- open-file table references
- process-level resources

### Private

- registers
- program counter
- stack
- thread-local storage

## Why threads?

- concurrency within one address space
- lower creation/communication cost than separate processes in many systems
- parallelism on multicore CPUs

## Main risk

Shared memory makes coordination necessary: races, deadlocks and visibility bugs become possible.

## Process vs thread

A process is primarily an isolation/resource container; a thread is an execution unit inside it.
## Small example

A web server process might have several threads:

```text
Process: web-server
 ├─ Thread A → accepts connections
 ├─ Thread B → handles request 1
 └─ Thread C → handles request 2

All can access the same heap, so shared counters need synchronization.
```
