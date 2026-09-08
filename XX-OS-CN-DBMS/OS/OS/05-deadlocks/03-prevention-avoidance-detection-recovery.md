# Deadlock Handling Strategies

### Prevention
Design the system so at least one necessary condition cannot hold.

Example: require resources to be acquired in global order → prevents circular wait.

### Avoidance
Allow flexible allocation but grant a request only if the resulting state remains safe. Banker’s algorithm is the classic example.

### Detection
Let deadlocks occur, then periodically run a detection algorithm.

### Recovery
After detection, recover by terminating processes, preempting resources where possible, or rolling back work.

## Safe vs deadlocked

A **safe state** has at least one ordering in which all processes can complete. An unsafe state is not necessarily currently deadlocked; it means the system cannot guarantee completion under the model.
