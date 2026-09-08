# User Threads vs Kernel Threads

| User-level threads | Kernel threads |
|---|---|
| Managed primarily by user runtime/library | Managed by OS scheduler |
| Can be cheap | More kernel involvement |
| Blocking syscall may affect all threads in some models | Kernel can schedule threads independently |
| Scheduling flexibility in runtime | Better integration with multicore/preemption |

Modern runtimes often combine user-space scheduling with kernel threads (e.g. language runtimes, async executors).

## Interview point

Do not say “user threads cannot run in parallel” universally. It depends on the threading model and whether multiple kernel execution contexts are used.
