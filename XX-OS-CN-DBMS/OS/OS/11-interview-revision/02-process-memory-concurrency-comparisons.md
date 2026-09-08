# Process, Memory and Concurrency Comparisons

| Confusion | Correct distinction |
|---|---|
| Program vs process | Program is passive code; process is executing state + resources |
| Process vs thread | Process is isolation/resource container; thread is execution path |
| Mode switch vs context switch | Privilege transition vs changing executing task |
| Mutex vs semaphore | Ownership-based exclusion vs permit/counting/signaling primitive |
| Deadlock vs starvation | Cyclic no-progress dependency vs indefinite unfair waiting |
| Paging vs segmentation | Fixed-size memory units vs variable-size logical regions |
| Page fault vs TLB miss | Missing/invalid page condition vs translation-cache miss |
| Virtual vs physical memory | Process-visible address space vs actual RAM mappings |
| Internal vs external fragmentation | Waste inside allocated blocks vs scattered free holes |
| Blocking vs non-blocking | Caller waits vs operation returns without waiting for readiness |
| Interrupt vs syscall | External/asynchronous event vs deliberate kernel service request |
| Authentication vs authorization | Identity verification vs permission decision |
