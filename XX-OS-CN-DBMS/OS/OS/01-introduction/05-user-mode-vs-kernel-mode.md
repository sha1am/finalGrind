# User Mode vs Kernel Mode

## Core idea

Modern CPUs provide privilege levels. Ordinary applications run with restricted permissions; the kernel runs with privileges needed to manage hardware and memory.

```text
User mode
  application
      |
      | syscall / trap
      v
Kernel mode
  kernel + drivers
      |
      v
Hardware
```

A system call causes a controlled transition to kernel mode. On return, execution resumes in user mode.

## Why it matters

If every program could execute privileged instructions or modify page tables, one buggy process could compromise the entire machine.

## Common confusion

- **Mode switch:** user ↔ kernel privilege transition.
- **Context switch:** switching execution from one process/thread to another. A mode switch does not necessarily mean a different process runs.

## Interview questions

- Why can't applications access hardware directly?
- Is every system call a context switch? **No.** It is a privilege transition; the scheduler may or may not switch tasks.
## Small example

A program cannot normally execute a privileged operation such as directly programming a device. It requests the kernel instead:

```text
write(fd, buf, n)
      ↓
user mode → syscall boundary → kernel mode
      ↓
device/filesystem work
      ↓
return to user mode
```
