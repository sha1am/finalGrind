# Banker’s Algorithm

Banker’s algorithm models each process's maximum resource demand and grants requests only when the resulting allocation remains safe.

Key matrices/vectors:

- `Available`: currently free resources.
- `Max`: maximum demand.
- `Allocation`: currently allocated resources.
- `Need = Max - Allocation`.

Safety check concept:

1. Start with `Work = Available`.
2. Find a process whose `Need <= Work`.
3. Pretend it finishes; add its allocation to `Work`.
4. Repeat.
5. If every process can finish, the state is safe.

**Interview point:** Banker’s algorithm needs advance maximum-demand information, which limits its use in general-purpose systems.
## Small example

If a process may still need `[1 CPU, 2 MB]` and the currently available resources are `[2 CPU, 3 MB]`, granting its remaining need would leave `[1 CPU, 1 MB]`. Banker-style reasoning asks whether completing that process can lead to a safe sequence for all processes.
