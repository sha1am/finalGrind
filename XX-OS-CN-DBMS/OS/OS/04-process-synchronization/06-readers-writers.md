# Readers–Writers Problem

Many readers may access shared data concurrently, but a writer needs exclusive access.

Possible policies:

- reader preference → writers may starve
- writer preference → readers may starve
- fair policy → bound waiting for both

The interview point is not memorizing one semaphore solution; explain the **trade-off between concurrency and fairness**.
