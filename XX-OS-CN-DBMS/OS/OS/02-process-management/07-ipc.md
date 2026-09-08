# Inter-Process Communication (IPC)

## Why IPC?

Processes are isolated, so they need explicit mechanisms to exchange data or synchronize.

### Common mechanisms

- **Pipe:** byte stream, commonly parent/child or related processes.
- **Named pipe/FIFO:** pipe exposed through the filesystem namespace.
- **Message queue:** kernel/runtime-managed messages.
- **Shared memory:** processes map the same physical pages; very fast for large data but requires synchronization.
- **Socket:** communication endpoint; local or network-capable.
- **Signals:** small asynchronous notifications, not a general data channel.

## Shared memory vs message passing

Shared memory can avoid copying but shifts synchronization complexity to the application. Message passing provides stronger communication boundaries but may involve copying/queueing.

## Interview follow-up

For a high-throughput local producer/consumer system, shared memory can be attractive; for independent services, sockets/message protocols are more natural.
## Small example

A shell pipeline such as `producer | consumer` can use a pipe:

```text
producer process --write--> pipe buffer --read--> consumer process
```

The processes remain isolated, but the kernel provides a controlled communication channel.
