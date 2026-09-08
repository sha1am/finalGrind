# Monitor and Condition Variables

A monitor is a higher-level synchronization abstraction combining shared state, operations and mutual exclusion. Condition variables let threads sleep until a state predicate becomes true.

Typical pattern:

```text
lock
while (!condition)
    wait(condition_variable)
// condition is true; use state
unlock
```

Use `while`, not `if`, because wakeups can be spurious and another thread may consume the condition before the awakened thread reacquires the lock.

## Interview distinction

A condition variable is not the condition itself. It is a mechanism for sleeping/waking around a predicate over shared state.
## Small example

A consumer should sleep while a queue is empty rather than repeatedly polling:

```text
lock
while queue.empty():
    not_empty.wait()
item = queue.pop()
unlock
```

The `while` matters because waking up does not itself guarantee that the condition is still true.
