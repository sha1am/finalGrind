# FCFS Scheduling

**First-Come, First-Served** runs processes in arrival order and is usually non-preemptive.

### Advantage

Simple and predictable.

### Problem: convoy effect

A long CPU-bound job at the front can make many short jobs wait.

Example: P1=20 ms, P2=2 ms, P3=2 ms. If P1 arrives first, P2/P3 experience poor response even though they need little CPU time.

**Interview:** FCFS is easy but often poor for interactive workloads.
## Small example

```text
P1 = 8 ms, P2 = 2 ms, both arrive at 0

FCFS: P1 | P2
      0---8--10

Waiting: P1=0, P2=8 → average = 4 ms
```
