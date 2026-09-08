# Process States and PCB

## Typical states

```text
        dispatch
Ready ----------> Running
  ^                 |
  |                 | I/O / wait
  |                 v
  +------------- Waiting

Running --exit--> Terminated
Running --preempt--> Ready
```

Exact state sets vary by OS.

## PCB

The **Process Control Block** is the OS bookkeeping structure for a process. It can contain:

- process identifier
- process state
- saved CPU registers/program counter
- scheduling information
- memory-management metadata
- accounting/credentials
- open-resource references

## Why the PCB matters

During a context switch, the OS needs somewhere to save the outgoing execution state and retrieve the incoming state.

## Common confusion

A PCB is **not** the process itself. It is kernel-managed metadata describing/managing it.
## Small example

Suppose a process calls `read()` on a socket and no data is available. It may move from **Running → Waiting**. When data arrives, the kernel makes it runnable again.

```text
Running --read() blocks--> Waiting --data arrives--> Ready --scheduled--> Running
```
