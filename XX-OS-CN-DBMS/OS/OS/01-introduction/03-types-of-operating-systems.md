# Types of Operating Systems

## Major categories

| Type | Main idea | Typical goal |
|---|---|---|
| Batch | Jobs run with little interactive input | Throughput |
| Multiprogramming | Keep multiple jobs in memory | CPU utilization |
| Multitasking/time-sharing | Rapidly switch runnable tasks | Responsiveness |
| Real-time | Bounded timing requirements | Predictability |
| Distributed | Coordinate multiple machines | Resource sharing |
| Embedded | OS tailored to constrained hardware | Small footprint |
| Network OS | Network-aware resource/service management | Connectivity |

### Multiprogramming vs multitasking

Multiprogramming focuses on keeping the CPU busy by switching when a job waits. Multitasking emphasizes interactive responsiveness and preemption.

### Hard vs soft real-time

Hard real-time systems have deadlines that must be met. Soft real-time systems prefer deadlines to be met but tolerate occasional misses.

## Interview trap

Do not equate **parallelism** with multitasking. Multitasking can occur on one CPU through time slicing; parallelism requires multiple execution resources operating simultaneously.
