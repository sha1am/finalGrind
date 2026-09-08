# Interrupts

An interrupt is a hardware/software signal that causes the CPU to divert execution to a handler so the OS can respond to an event.

Examples: device completion, timer events, network packets.

### Why interrupts?

Without interrupts, the CPU would have to constantly poll devices for changes.

### Interrupt vs exception

An interrupt is generally asynchronous to the current instruction stream; an exception/trap is associated with executing an instruction or explicit software event. Terminology varies by architecture.

### System call

A system call is a deliberate software request into the kernel. It may use a trap/syscall instruction, but conceptually it is different from an external device interrupt.
## Small example

A network card can notify the CPU when packets arrive rather than forcing the CPU to ask repeatedly:

```text
polling:   CPU → "anything yet?" → CPU → "anything yet?" ...
interrupt: device → CPU: "event happened"
```
