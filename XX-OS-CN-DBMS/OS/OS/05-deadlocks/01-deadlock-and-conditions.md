# Deadlock and the Four Necessary Conditions

## Deadlock

A set of processes is deadlocked when each is waiting for something that another member of the set must release or cause, so none can progress.

Four conditions must hold simultaneously:

1. **Mutual exclusion:** a resource is non-shareable.
2. **Hold and wait:** a process holds resources while waiting for more.
3. **No preemption:** resources cannot be forcibly taken away.
4. **Circular wait:** a cycle of waiting exists.

Break any one condition and classic deadlock cannot occur.

## Deadlock vs starvation

- Deadlock: a group is stuck in a dependency cycle.
- Starvation: a task waits indefinitely because policy keeps denying service.
## Small example

```text
T1 holds Lock A → waits for Lock B
T2 holds Lock B → waits for Lock A
```

Neither can proceed. This is the classic circular-wait shape.
