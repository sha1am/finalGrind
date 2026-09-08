# File Descriptors and Process Lifecycle

On Unix-like systems, many resources are exposed through file descriptors: files, pipes, sockets, terminals and more.

A process has a descriptor table. An entry refers to kernel-managed open-file state.

### Why this matters in backend interviews

- sockets are file descriptors;
- pipes are file descriptors;
- `fork()` duplicates descriptor references into the child;
- forgetting to close descriptors can cause leaks or prevent EOF from being observed.

### Zombie
A terminated child whose exit status has not yet been collected by the parent.

### Orphan
A child whose parent exits first; it is reparented to another supervisor/init-like process depending on the OS.
## Small example

```text
open("a.txt") → fd 3
dup(3)        → fd 4

fd 3 and fd 4 can refer to the same open file description.
```

This distinction becomes important when reasoning about shared file offsets after `fork()` or `dup()`.
