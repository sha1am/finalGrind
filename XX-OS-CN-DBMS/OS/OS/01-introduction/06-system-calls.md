# System Calls

## What is a system call?

A system call is the controlled interface through which user-space code requests a kernel service.

Examples on Unix-like systems: `open`, `read`, `write`, `close`, `fork`, `execve`, `wait`, `mmap`, `socket`.

## Flow

```text
Application
   |
   | library wrapper
   v
system-call instruction/trap
   |
   v
kernel validates arguments + permissions
   |
   v
kernel performs service
   |
   v
return value / errno
```

## Important point

A C library function may not map 1:1 to a syscall. Libraries can perform user-space work, combine syscalls, cache state, or choose different kernel interfaces.

## Interview follow-ups

**Why validate arguments in kernel?** Because user memory and state cannot be trusted. The kernel must prevent invalid pointers, unauthorized access and malformed requests.

**Syscall vs API:** API is the programming interface exposed to a developer; a syscall is a kernel entry mechanism/service boundary.
## Small example

Calling `read()` looks like an ordinary function call from application code, but the actual OS service crosses the user/kernel boundary.

```text
application
   ↓ read(fd, buf, 100)
libc wrapper / syscall instruction
   ↓
kernel validates fd + permissions
   ↓
filesystem/device path
   ↓
bytes returned
```

## Sharpen this concept

- [Linux system calls overview](https://man7.org/linux/man-pages/man2/syscalls.2.html) — use this to distinguish a system call from a normal library function.
- [MIT xv6](https://pdos.csail.mit.edu/6.828/2025/overview.html) — see how system calls cross the user/kernel boundary in a small kernel.
