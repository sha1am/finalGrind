# Mutex

A mutex is a mutual-exclusion lock with ownership semantics: a thread locks it before entering a protected region and unlocks it afterward.

```text
lock(m)
  shared state
unlock(m)
```

### Why atomicity matters

The operation “check whether unlocked and acquire it” must be indivisible with respect to other contenders. Hardware atomic primitives such as compare-and-swap help implement locks.

### Spinlock vs blocking mutex

- **Spinlock:** waiting thread repeatedly checks; useful for very short waits where sleeping would cost more.
- **Blocking mutex:** waiting thread sleeps/parks, freeing the CPU.

## Interview trap

A mutex is for mutual exclusion, not for counting available resources. A semaphore is the more natural primitive for resource counting.
## Small example

```text
lock(m)
  counter++
unlock(m)
```

If two threads use the same mutex, only one enters the protected region at a time.
