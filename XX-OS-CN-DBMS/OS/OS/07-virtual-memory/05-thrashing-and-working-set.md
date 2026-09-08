# Thrashing and Working Set

**Thrashing** occurs when the system spends excessive time handling page faults and moving pages instead of doing useful work.

A process's **working set** is an approximation of the set of pages it actively needs over a chosen recent time window.

If total working-set demand across active processes greatly exceeds available frames, fault rates can explode.

### Remedies

- reduce degree of multiprogramming;
- allocate more frames where possible;
- improve locality;
- avoid memory overcommit patterns that cause sustained pressure.
## Small example

If a workload actively touches 100 pages but the process has only 10 useful frames, the system can spend more time servicing page faults/reclaim than doing application work. That is the intuition behind thrashing.
