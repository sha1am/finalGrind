# OS Functions and Goals

## Core responsibilities

1. **Process management:** create, schedule, synchronize and terminate processes/threads.
2. **Memory management:** allocate address spaces, map virtual pages and reclaim memory.
3. **File/storage management:** organize persistent data and enforce permissions.
4. **I/O management:** provide common interfaces to devices and drivers.
5. **Protection/security:** isolate processes and control access.
6. **Networking:** expose communication primitives such as sockets.
7. **Accounting/monitoring:** track resource use and system health.

## Design goals

- **Correctness:** preserve invariants and isolation.
- **Efficiency:** maximize utilization and minimize overhead.
- **Fairness:** prevent indefinite starvation.
- **Reliability:** recover or fail predictably.
- **Security:** enforce least privilege and isolation.
- **Convenience:** provide useful abstractions.

## Interview follow-up

A good answer acknowledges trade-offs: a stronger isolation boundary may add overhead; aggressive caching improves latency but consumes memory; fairness may reduce peak throughput.
