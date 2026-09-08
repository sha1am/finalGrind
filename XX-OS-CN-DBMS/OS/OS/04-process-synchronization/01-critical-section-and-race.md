# Critical Section and Race Condition

## Critical section

A critical section is code that accesses shared mutable state and must obey a synchronization policy.

## Race condition

A race occurs when the result depends on the timing/interleaving of concurrent operations.

Example:

```text
counter = 10
T1 reads 10
T2 reads 10
T1 writes 11
T2 writes 11
```

Two increments happened, but the result is 11: a lost update.

## Requirements for a classic critical-section solution

- **Mutual exclusion:** at most one enters the protected region.
- **Progress:** if nobody is inside, a decision to enter should not be postponed forever.
- **Bounded waiting:** a thread should not wait forever after requesting entry.

## Important distinction

A race condition is a correctness problem. A data race is a specific class involving unsynchronized conflicting memory accesses under a language memory model.
## Small example

Suppose `counter = 0` and two threads execute `counter++`. Conceptually each increment is a read-modify-write sequence.

```text
T1: read 0 ───── write 1
T2:       read 0 ── write 1

Final = 1, but expected = 2
```

The bug is the interleaving, not the arithmetic.

## Sharpen this concept

- [OSTEP](https://pages.cs.wisc.edu/~remzi/OSTEP/) — read the concurrency/threads material when race conditions feel like definitions rather than interleavings.
- [Linux kernel core API](https://docs.kernel.org/core-api/index.html) — useful later for atomics, memory barriers and synchronization primitives.
