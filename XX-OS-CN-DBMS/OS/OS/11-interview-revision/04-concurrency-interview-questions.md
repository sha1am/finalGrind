# Concurrency Interview Questions

### Q: How do you prevent a race?
Identify the shared invariant, then protect the relevant critical section with a mutex/atomic operation or redesign ownership/message passing.

### Q: Why is `counter++` unsafe concurrently?
It is conceptually read-modify-write, not necessarily one indivisible operation.

### Q: Mutex or semaphore for a connection pool?
A counting semaphore can model available permits; a mutex protects the pool's internal data structure.

### Q: How do you avoid deadlock in multiple-lock code?
Use a consistent global lock acquisition order, minimize lock scope, avoid holding locks across blocking operations where possible, and consider try-lock/timeouts where appropriate.

### Q: What is starvation?
A thread remains ready but repeatedly fails to obtain CPU/resource access.

### Q: What is lock contention?
Multiple threads frequently compete for the same lock, increasing waiting and reducing parallelism.
