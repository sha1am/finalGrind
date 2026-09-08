# Context Switch

## What is it?

A context switch changes the CPU from executing one thread/process to another by saving the outgoing execution context and restoring another.

## Typical flow

1. Enter kernel due to interrupt, syscall, exception or scheduler event.
2. Save registers/program counter/stack-related state.
3. Update task state and scheduler data structures.
4. Choose another runnable task.
5. Restore its saved state/address-space context.
6. Return to execution.

## Why it costs time

The CPU executes bookkeeping rather than application work. Changing address-space mappings can also disturb TLB/cache locality, although modern CPUs optimize parts of this heavily.

## Mode switch vs context switch

```text
syscall: user A -> kernel -> user A      = mode transition
scheduler: user A -> kernel -> user B    = mode transition + task switch
```

## Interview follow-up

Context switches are not inherently bad; they are necessary for multitasking. The engineering goal is to avoid excessive switching and preserve locality.
## Small example

With two runnable threads:

```text
CPU: T1 → scheduler → T2 → scheduler → T1
       save T1       restore T2
```

The scheduler is doing useful OS work, but those cycles are not executing the application's instructions.
