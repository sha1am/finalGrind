# Round Robin

Round Robin assigns each runnable task a time quantum in cyclic order.

```text
P1 -> P2 -> P3 -> P1 -> ...
```

### Quantum trade-off

- Too small → many context switches and overhead.
- Too large → behavior approaches FCFS and response suffers.

Round Robin is a natural fit for interactive workloads because a runnable task gets regular opportunities to run.
## Small example

With quantum = 2 ms:

```text
P1 P2 P3 P1 P2 P3 ...
└2┘└2┘└2┘
```

A smaller quantum improves responsiveness but can increase context-switch overhead.
