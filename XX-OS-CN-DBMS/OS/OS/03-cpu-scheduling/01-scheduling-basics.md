# CPU Scheduling Basics

## Goal

When several runnable threads compete for a CPU, the scheduler chooses which runs next.

### Metrics

- **Turnaround:** completion − arrival.
- **Waiting:** total time spent ready but not running.
- **Response:** first run − arrival.
- **Throughput:** completed jobs per unit time.
- **CPU utilization:** fraction of time doing useful CPU work.

### Preemptive vs non-preemptive

Preemptive scheduling can interrupt a running task. Non-preemptive scheduling lets it keep the CPU until it blocks/exits/yields.

## Interview insight

There is no universally best scheduler. Interactive systems care about response time; batch systems often emphasize throughput; real-time systems emphasize deadlines.
## Small example

If P1 needs 8 ms of CPU and P2 needs 2 ms, choosing P2 first can reduce average waiting time when both are ready at time 0. This is the intuition behind SJF.
