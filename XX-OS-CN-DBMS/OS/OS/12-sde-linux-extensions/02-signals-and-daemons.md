# Signals and Daemons

Signals are asynchronous notifications delivered to a process/thread. Examples include termination requests, child-status notifications and user-defined signals.

Signal handling has constraints: handlers run asynchronously and should avoid unsafe operations; production applications often convert signals into a controlled event handled by normal application code.

A **daemon/service** is a long-running background process providing a service. Modern Linux systems commonly manage services with a supervisor such as systemd.

## Interview point

A signal is not the same as an IPC data channel. It communicates a small event, not arbitrary application payloads.
