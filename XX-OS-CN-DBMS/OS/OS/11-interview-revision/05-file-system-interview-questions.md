# File System Interview Questions

### Q: What is an inode?
Metadata object identifying a filesystem file object and its attributes/data-location information.

### Q: Filename vs inode?
A directory maps a filename to an inode/object identity.

### Q: Hard link vs symlink?
Hard link is another name for the same inode; symlink is a separate object containing a path.

### Q: Why can deleting a file not immediately free disk space?
A process may still have the file open; storage can be reclaimed after the final reference is gone.

### Q: Does `write()` guarantee persistence?
Not necessarily. Kernel/page-cache buffering may delay durable storage; applications needing stronger guarantees use appropriate synchronization such as `fsync()` and correct filesystem/storage semantics.
