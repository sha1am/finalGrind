# File System Basics

A filesystem maps a persistent byte-oriented storage device into named files/directories plus metadata.

A file usually has:

- content
- size
- type
- ownership/permissions
- timestamps
- storage-location metadata

Applications interact through system calls rather than directly manipulating disk sectors.

## File descriptor

A process typically receives a small integer **file descriptor** for an open file/pipe/socket. The descriptor refers to kernel-managed open-file state.
## Small example

When an application does `open("report.txt", ...)`, the kernel resolves the pathname and returns a small integer such as `3`. Later `read(3, ...)` uses that descriptor to refer to the opened file state.
