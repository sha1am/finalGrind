# CPU Scheduling Comparison

| Algorithm | Preemptive? | Strength | Main issue |
|---|---|---|---|
| FCFS | Usually no | Simple | Convoy effect |
| SJF | No | Low avg waiting if bursts known | Needs prediction; starvation |
| SRTF | Yes | Strong avg waiting | More preemption/starvation |
| RR | Yes | Fair/interactive | Quantum tuning |
| Priority | Either | Expresses importance | Starvation |
| MLQ | Usually policy-dependent | Clear classes | Rigid classification |
| MLFQ | Yes | Adapts to behavior | More complex |

## Interview formula set

`Turnaround = Completion - Arrival`

`Waiting = Turnaround - CPU burst` (for the simple single-burst model)

`Response = First CPU start - Arrival`
