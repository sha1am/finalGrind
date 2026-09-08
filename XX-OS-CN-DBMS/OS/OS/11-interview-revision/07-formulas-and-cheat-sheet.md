# OS Formula and Cheat Sheet

## Scheduling

`Turnaround = Completion - Arrival`

`Waiting = Turnaround - CPU burst` (simple single-burst model)

`Response = First run - Arrival`

## Paging

For page size `2^p`, the lower `p` address bits are the page offset. Remaining bits form the virtual page number.

For a simple single-level page table, number of entries is approximately:

`virtual address space size / page size`

Page-table memory is approximately:

`number of entries × bytes per entry`

## Deadlock

`Need = Max - Allocation`

A safe state has an ordering in which every process can obtain its remaining need and finish.

## Last-minute mental models

```text
syscall: user -> kernel -> user
context switch: task A -> task B
TLB: cache of address translations
page fault: required page not currently usable/resident
mutex: one owner at a time
semaphore: permits/signaling
inode: file object metadata identity
DMA: device <-> memory with reduced CPU copying
```
