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

The main difference is that [multiprogramming](https://www.geeksforgeeks.org/operating-systems/difference-between-multiprogramming-and-multitasking/) focuses on keeping the CPU busy by switching programs only when one waits for input or output, while multitasking uses time-sharing to switch rapidly between tasks so a user can interact with multiple programs at once. [[1](https://www.geeksforgeeks.org/operating-systems/difference-between-multiprogramming-and-multitasking/), [2](https://www.guvi.in/blog/multiprogramming-and-multitasking/), [3](https://brainly.in/question/60523926)]

Core Differences

- **Primary Goal**: **Multiprogramming** aims to maximize CPU efficiency and throughput. **Multitasking** aims to minimize response time and enhance user interactivity. [[1](https://medium.com/@unstop/difference-between-multiprogramming-and-multitasking-explained-b6527569d9f4), [2](https://brainly.in/question/60523926), [3](https://www.guvi.in/blog/multiprogramming-and-multitasking/)]
- **Switching Method**: **Multiprogramming** switches tasks only when the current task pauses for an I/O operation (like reading a file or waiting for a printer). **Multitasking** switches tasks after a fixed, tiny slice of time (called a time quantum or time slice) ends. [[1](https://www.youtube.com/watch?v=3MqyDWDpZoI), [2](https://unstop.com/blog/difference-between-multiprogramming-and-multitasking), [3](https://brainly.in/question/60523926), [4](https://www.geeksforgeeks.org/operating-systems/difference-between-multiprogramming-and-multitasking/)]
- **System Type**: **Multiprogramming** is common in older batch systems. **Multitasking** is standard in modern, user-friendly operating systems. [[1](https://brainly.in/question/60523926)]

Examples

- **Multiprogramming Example**: A computer runs a large payroll calculation in the background. When that program pauses to fetch data from the hard drive, the CPU switches to process a separate inventory report, ensuring the processor rarely sits idle. [[1](https://www.geeksforgeeks.org/operating-systems/difference-between-multitasking-multithreading-and-multiprocessing/), [2](https://brainly.in/question/60523926)]
- **Multitasking Example**: A user types a document in a word processor while listening to music and downloading a file from the internet. The CPU jumps between these three tasks every few milliseconds, making it feel as if they all run at the exact same time. [[1](https://www.scaler.com/topics/difference-between-multiprogramming-and-multitasking/), [2](https://www.geeksforgeeks.org/operating-systems/difference-between-multiprogramming-and-multitasking/)]

### Hard vs soft real-time

Hard real-time systems have deadlines that must be met. Soft real-time systems prefer deadlines to be met but tolerate occasional misses.

## Interview trap

Do not equate **parallelism** with multitasking. Multitasking can occur on one CPU through time slicing; parallelism requires multiple execution resources operating simultaneously.
