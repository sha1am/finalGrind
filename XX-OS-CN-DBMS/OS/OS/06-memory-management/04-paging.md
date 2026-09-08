# Paging

Paging divides virtual memory into fixed-size **pages** and physical memory into equal-size **frames**.

A virtual address is split into:

```text
| page number | offset |
```

The page number indexes a page table to obtain a frame number:

```text
virtual page -> page table -> physical frame
```

The offset stays unchanged.

## Why paging?

A process does not need one contiguous physical region. Pages can occupy different frames.

## Cost

Page tables consume memory and translation adds overhead; the TLB exists to make common translations fast.
## Small example

With page size 4 KiB, virtual address `0x12345` can be split into a virtual page number and a 12-bit offset. The page number indexes the page table; the offset is preserved when the physical frame is selected.
