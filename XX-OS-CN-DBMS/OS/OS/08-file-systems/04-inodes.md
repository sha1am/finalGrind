# Inodes

An inode is filesystem metadata describing a file object, typically including ownership, permissions, size, timestamps and references to data blocks/extent structures.

A filename is generally stored in a directory entry that maps a name to an inode number.

```text
"report.txt"
     |
 directory entry
     |
 inode number
     |
 inode -> data blocks/extents
```

### Key interview point

The inode is not the filename. The directory maps names to inode identities.
## Small example

```text
/tmp/a.txt ─┐
            ├─ directory entries → inode 8123 → file data
/tmp/b.txt ─┘
```

If both names are hard links, removing one name does not remove the inode while another link still exists.

## Sharpen this concept

- [OSTEP](https://pages.cs.wisc.edu/~remzi/OSTEP/) — use the persistence/filesystem material for the conceptual model.
- [Linux man-pages](https://man7.org/linux/man-pages/) — verify exact behavior of `open`, `stat`, `link`, `unlink` and related APIs.
