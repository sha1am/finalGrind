# Priority Scheduling and Aging

Priority scheduling chooses the highest-priority runnable task. It can be preemptive or non-preemptive.

### Starvation

Low-priority tasks may never run if higher-priority work continuously arrives.

### Aging

Gradually increase a waiting task's priority so that it eventually gets service.

**Common confusion:** starvation is indefinite postponement due to scheduling/resource policy; deadlock means a set of tasks cannot make progress because of a cyclic resource dependency.
## Small example

If a low-priority job waits behind a continuous stream of high-priority jobs, it may starve. **Aging** gradually raises its effective priority so it eventually gets CPU time.
