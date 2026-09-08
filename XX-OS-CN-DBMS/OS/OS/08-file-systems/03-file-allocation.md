# File Allocation Methods

### Contiguous
File occupies consecutive blocks. Excellent sequential/random locality but growth and fragmentation can be difficult.

### Linked
Each block points to the next. Easy growth, but random access is poor and pointer overhead exists.

### Indexed
An index structure contains pointers to file blocks. Supports non-contiguous placement and efficient direct access; index metadata consumes space.

Modern filesystems use richer structures rather than these textbook schemes literally, but the trade-offs remain foundational.
