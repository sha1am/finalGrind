# Direct Memory Access (DMA)

DMA lets a device transfer data to/from memory with limited CPU involvement.

```text
CPU configures DMA
       |
       v
DMA/controller <----> device
       |
       v
    memory
       |
 completion interrupt
       v
      CPU
```

### Why DMA?

For large transfers, making the CPU copy every byte wastes CPU cycles. DMA lets the CPU configure a transfer and handle completion.

The CPU still participates in setup, protection, memory mapping and completion handling.
## Small example

For a large network receive:

```text
CPU: configure DMA buffer
NIC/DMA: transfer packet data → RAM
NIC: completion event
CPU: process received data
```

The CPU avoids copying every byte itself.

## Sharpen this concept

- [Linux kernel documentation](https://docs.kernel.org/) — use the driver/DMA documentation when you want to understand how device I/O is implemented beyond the interview model.
- [OSTEP](https://pages.cs.wisc.edu/~remzi/OSTEP/) — useful for the broader persistence and I/O mental model.
