# Resource Allocation Graph

A resource-allocation graph represents processes and resources.

```text
P1 -> R2   (P1 requests R2)
R1 -> P1   (R1 allocated to P1)
```

For a single-instance resource type, a cycle indicates deadlock. With multiple instances, a cycle alone is not always sufficient; more analysis is needed.

## Interview follow-up

Know the direction:

- process → resource = request
- resource → process = assignment
## Small example

```text
T1 ──requests──> R2
T1 <──holds───── R1
T2 ──requests──> R1
T2 <──holds───── R2
```

The resulting cycle is a strong deadlock warning when the resources are single-instance resources.
