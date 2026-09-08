# First Fit, Best Fit and Worst Fit

Given a request and free blocks:

- **First fit:** first block large enough.
- **Best fit:** smallest block large enough.
- **Worst fit:** largest block.

### Trade-offs

First fit is often fast. Best fit can create many tiny leftover holes. Worst fit tries to leave useful-sized leftovers but can waste large blocks.

No strategy universally minimizes fragmentation for every workload.
