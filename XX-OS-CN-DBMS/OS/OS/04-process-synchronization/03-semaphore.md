# Semaphore

A semaphore is an integer synchronization primitive manipulated through atomic wait/signal operations.

- **Binary semaphore:** often 0/1; can resemble a lock but does not necessarily have mutex ownership semantics.
- **Counting semaphore:** represents a number of available permits/resources.

Example: a pool has 10 database connections. Initialize a semaphore to 10; each worker acquires one permit and releases it when finished.

### Mutex vs semaphore

| Mutex | Semaphore |
|---|---|
| Protects a critical section | Controls permits/signaling |
| Ownership is typical | No ownership requirement |
| Usually 0/1 | 0/1 or larger |

**Interview tip:** saying “a semaphore is just a mutex” is incomplete and often wrong.
## Small example

A semaphore initialized to 3 can represent three available identical resources:

```text
semaphore = 3
T1 wait → 2
T2 wait → 1
T3 wait → 0
T4 wait → blocks
```
