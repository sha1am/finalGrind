# Blocking, Non-blocking and Asynchronous I/O

**Blocking I/O:** the calling thread waits until the operation can make progress/complete according to the API semantics.

**Non-blocking I/O:** the operation returns promptly instead of waiting for data/readiness; the caller decides what to do next.

**Asynchronous I/O:** the application submits work and receives completion later through a completion mechanism.

These terms are often mixed together. A common event-loop design uses non-blocking sockets + readiness notification, which is not identical to kernel asynchronous completion I/O.
## Small example

For a socket:

```text
blocking read     → thread may sleep until data is available
non-blocking read → returns immediately if it cannot proceed
async I/O         → application submits work and is notified/completes later
```

These are different dimensions; “non-blocking” does not automatically mean “asynchronous.”
