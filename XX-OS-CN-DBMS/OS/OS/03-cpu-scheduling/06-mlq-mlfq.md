# Multilevel Queue and Multilevel Feedback Queue

## Multilevel Queue (MLQ)

Separate ready queues are assigned to classes such as interactive and batch. A process generally stays in its assigned queue.

## Multilevel Feedback Queue (MLFQ)

Processes can move between queues based on observed behavior.

Typical intuition:

```text
high priority: short/interactive jobs
       |
       | CPU-heavy behavior
       v
lower priority queues
```

MLFQ tries to approximate SJF without knowing future burst lengths while maintaining responsiveness.

## Interview point

The key distinction is **feedback/mobility**. MLQ classifies; MLFQ adapts.
