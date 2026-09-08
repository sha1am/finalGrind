# Dining Philosophers

The problem models multiple workers needing multiple shared resources.

If every philosopher picks up the left fork and waits for the right, each can hold one resource while waiting for another: deadlock.

Ways to break it:

- impose a global resource ordering;
- allow at most N−1 philosophers to compete;
- use a waiter/arbitrator;
- asymmetric acquisition.

**General lesson:** consistent lock ordering is one of the most practical deadlock-prevention techniques.
