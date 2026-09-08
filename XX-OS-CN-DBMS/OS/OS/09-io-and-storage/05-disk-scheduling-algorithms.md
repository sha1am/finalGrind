# Disk Scheduling: FCFS, SSTF, SCAN, C-SCAN, LOOK and C-LOOK

### FCFS
Serve requests in arrival order. Fair/simple, but poor seek optimization.

### SSTF
Serve the closest request next. Often reduces seek distance but can starve far-away requests.

### SCAN
Move the head in one direction servicing requests, then reverse: elevator behavior.

### C-SCAN
Service in one direction; when reaching the end, jump back without servicing on the return. More uniform waiting times.

### LOOK / C-LOOK
Like SCAN/C-SCAN but reverse/jump at the last pending request rather than the physical disk edge.

```text
SCAN:   -----> service -----> reverse <-----
C-SCAN: -----> service -----> jump ----->
```
## Small example

Suppose the disk head is at 50 and pending requests are 10, 20, 55, 90. SSTF picks 55 first because it is closest to 50. That can be efficient, but repeated nearby requests can delay a far-away request.
