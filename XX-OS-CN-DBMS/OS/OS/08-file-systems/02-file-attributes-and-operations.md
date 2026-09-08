# File Attributes and Operations

Common operations: `open`, `read`, `write`, `lseek`, `close`, `stat`, `rename`, `unlink`, `fsync`.

Common metadata: size, owner, group, permission bits, timestamps, type and filesystem-specific identifiers.

### `unlink` insight

On Unix-like filesystems, unlinking a name removes a directory entry. The underlying inode/data may remain until no directory entries and no open file references keep it alive.

This explains why a deleted file can still consume disk space while a process has it open.
## Small example

A process can unlink `app.log` while another process still has it open. The pathname disappears, but the open reference can keep the underlying file alive until the last reference is closed.
