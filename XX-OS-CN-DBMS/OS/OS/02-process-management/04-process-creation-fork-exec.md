# Process Creation: fork, exec, wait and exit

## Unix model

`fork()` creates a new process. The child initially resembles the parent. Modern systems commonly use **copy-on-write (COW)** so physical pages are shared until one side writes.

`exec*()` replaces the calling process's program image with another executable. It does not create another process.

`wait*()` lets a parent collect a child's termination status.

`exit()` terminates the calling process and records status for the parent to collect.

```text
parent
  |
 fork()
 /    P      C
       |
      exec()
       |
   new program image
```

## Interview traps

- `fork` creates a process; `exec` replaces an image.
- PID normally remains the same across `exec`.
- COW avoids eagerly copying every page.
## Small example

A shell commonly follows this idea when launching a command:

```text
shell
  │
  ├─ fork() → child
  │             │
  │             └─ exec("ls") → child now runs ls
  │
  └─ wait() → shell collects child's exit status
```

`fork()` creates the child; `exec()` changes what that child is running.

## Sharpen this concept

- [Linux `fork(2)`](https://man7.org/linux/man-pages/man2/fork.2.html) — precise behavior, inheritance and copy-on-write context.
- [MIT xv6](https://pdos.csail.mit.edu/6.828/2025/overview.html) — useful for understanding process creation and context switching at kernel level.
