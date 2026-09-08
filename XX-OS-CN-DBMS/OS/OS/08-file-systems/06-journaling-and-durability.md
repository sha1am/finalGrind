# Journaling and Durability

A filesystem may maintain a journal/log of metadata or data changes so that after a crash it can recover to a consistent filesystem state more efficiently than reconstructing everything from scratch.

### Durability vs visibility

A successful `write()` often means the kernel accepted/cached the data; it does not necessarily mean the bytes are safely on persistent media.

`fsync()` is used when an application needs stronger durability guarantees for file data/metadata, subject to filesystem and storage semantics.

**Interview:** caching improves latency, while durability requires explicit persistence semantics.
## Small example

A database may write critical data and then call `fsync()` because “the write call returned” is not the same guarantee as “the data is safely persistent across a crash.”
