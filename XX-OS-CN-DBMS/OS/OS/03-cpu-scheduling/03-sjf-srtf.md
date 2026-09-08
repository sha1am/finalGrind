# SJF and SRTF

## SJF

**Shortest Job First** selects the process with the smallest predicted CPU burst. Non-preemptive SJF is optimal for minimizing average waiting time when burst lengths are known.

## SRTF

**Shortest Remaining Time First** is the preemptive form: a newly arrived job can preempt the current job if it has a shorter remaining time.

## Limitation

Future CPU burst length is not known exactly. Systems estimate it using history.

## Starvation

Long jobs can wait indefinitely when short jobs keep arriving. Aging or a different scheduling policy can reduce starvation.
## Small example

If P1 has 8 ms remaining and P2 arrives with 2 ms remaining, **SRTF** can preempt P1 and run P2 first. SJF would make the choice only when selecting the next job; SRTF is the preemptive version.
