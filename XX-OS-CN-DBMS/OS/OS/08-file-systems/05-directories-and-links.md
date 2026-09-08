# Directories and Hard vs Soft Links

A directory is a mapping from names to filesystem objects.

### Hard link
Another directory entry pointing to the same underlying inode/file object.

- same underlying file data/metadata
- usually cannot cross filesystem boundaries
- usually cannot hard-link directories as an ordinary user operation

### Symbolic/soft link
A separate filesystem object containing a path to another object.

- can cross filesystem boundaries
- can become dangling
- follows path resolution

```text
hard links:  name A ----> inode <---- name B
symlink:     name A ----> symlink ----> path ----> target
```
## Small example

```text
original.txt ──┐
                ├─> inode 500
backup.txt   ───┘   (hard link)

latest.txt → "original.txt"  (symlink)
```

Deleting `original.txt` leaves `backup.txt` valid; `latest.txt` may become dangling.
