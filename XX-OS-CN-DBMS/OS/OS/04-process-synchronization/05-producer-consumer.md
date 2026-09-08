# Producer–Consumer

A bounded buffer has producers adding items and consumers removing them.

Required invariants:

- Producer must not insert when buffer is full.
- Consumer must not remove when buffer is empty.
- Buffer metadata must be updated atomically.

A classic semaphore design uses `empty`, `full` and a mutex protecting the queue.

```text
producer -> [ bounded queue ] -> consumer
             ^            ^
          capacity      items
```

Modern production code often uses a blocking queue/condition variable rather than implementing raw semaphores.
## Small example

For a bounded queue of capacity 2:

```text
empty = 2, full = 0
producer → item A → full=1, empty=1
producer → item B → full=2, empty=0
producer → blocks until a consumer removes an item
```
