# select, poll and epoll — Interview View

I/O multiplexing lets one thread monitor many descriptors for readiness.

- `select`: portable concept, historically limited descriptor sets and repeated scanning.
- `poll`: avoids fixed bitset limits but still scans descriptor lists in common implementations.
- `epoll`: Linux-specific readiness facility designed for large descriptor sets with an event-driven model.

Typical backend architecture:

```text
many sockets
    |
 non-blocking
    |
 epoll/event loop
    |
ready callbacks/tasks
```

The key interview idea is that the application does not need one blocking thread per idle socket.
## Small example

A server handling 10,000 sockets does not need 10,000 threads that all sit blocked in `read()`. An event mechanism such as `epoll` can report which descriptors are ready, allowing a smaller number of workers to process them.

## Sharpen this concept

- [Linux `epoll(7)`](https://man7.org/linux/man-pages/man7/epoll.7.html) — exact readiness semantics and edge-triggered pitfalls.
- [Linux `open(2)`](https://man7.org/linux/man-pages/man2/open.2.html) — useful for understanding file-descriptor and non-blocking semantics.
