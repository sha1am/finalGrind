# 05 — Concurrency & the C++ Memory Model

The book barely covers this; interviews at SDE-2+ lean on it hard. Know the
primitives, the ownership of data, and enough of the memory model to reason
about correctness.

> **Take-home lesson.** Don't reason about "threads"; reason about *shared
> mutable state*. Concurrency bugs live exactly where two threads touch the same
> data and at least one writes. Eliminate the sharing (copy, or confine to one
> thread), make it immutable, or serialize access — those are the only three
> tools, and they're in that preference order.

---

## 1. Threads & the basic toolkit

- `std::thread` — you **must** `join()` or `detach()` before it's destroyed,
  else `std::terminate`. Prefer `std::jthread` (C++20): auto-joins in dtor and
  carries a `stop_token` for cooperative cancellation.

```cpp
// C++20 jthread: cooperative cancellation + automatic join (RAII for threads):
std::jthread worker([](std::stop_token st) {
    while (!st.stop_requested()) { /* do a unit of work */ }
});
// ...no explicit join needed; worker's destructor requests stop AND joins.
```
- `std::async` + `std::future` — launch a task, get the result later.
  `std::launch::async` forces a new thread; `deferred` runs on `get()`.
  Gotcha: the future returned by `std::async` **blocks in its destructor**
  until the task finishes (a common surprise).
- `std::promise`/`std::future` — one-shot channel for a value or exception
  across threads. `std::packaged_task` wraps a callable + future.

---

## 2. Data races vs race conditions

- **Data race** = two threads access the same memory, at least one writes, with
  no synchronization and not both atomic → **undefined behavior**. Not "maybe
  wrong" — UB.
- **Race condition** = a logic bug where correctness depends on timing (can
  exist even in race-free code).
- The fix for data races: mutual exclusion (mutex) or atomics.

---

## 3. Mutexes & locks

- `std::mutex`, `recursive_mutex`, `timed_mutex`, `shared_mutex` (C++17,
  reader/writer: many `shared_lock` readers OR one `unique_lock` writer).
- **Always lock via RAII wrappers**, never manual lock/unlock:
  - `std::lock_guard` — simplest, scope-bound.
  - `std::unique_lock` — movable, deferrable, works with condition variables,
    supports manual unlock/relock. Slightly heavier.
  - `std::scoped_lock` (C++17) — locks **multiple** mutexes deadlock-free.
- **Deadlock avoidance**: always acquire locks in a consistent global order,
  or use `std::scoped_lock`/`std::lock` to grab several atomically. Classic
  four Coffman conditions: mutual exclusion, hold-and-wait, no preemption,
  circular wait — break any one.

```cpp
std::scoped_lock lk(m1, m2);   // deadlock-free multi-lock
```

---

## 4. Condition variables

Wait for a condition without busy-spinning. **Always use the predicate
overload** to handle spurious wakeups.

```cpp
std::unique_lock lk(m);
cv.wait(lk, []{ return ready; });   // re-checks predicate; immune to spurious wakeup
// ... producer: { lock; ready=true; } cv.notify_one();
```
- `notify_one` vs `notify_all`. Modify the shared state **under the lock**
  before notifying, or you get lost wakeups.

---

## 5. Atomics & `std::atomic`

- `std::atomic<T>` — indivisible ops, no torn reads/writes; `is_lock_free()`
  tells you if it's truly lock-free (usually for pointer/integral sizes).
- `fetch_add`, `compare_exchange_weak/strong` (CAS — the foundation of
  lock-free algorithms). `weak` can fail spuriously (loop it); `strong` doesn't.
- `std::atomic_flag` — the only guaranteed-lock-free type; basis of spinlocks.
- **`shared_ptr` control-block ref counts are atomic**, but the pointee and
  the `shared_ptr` object itself are not thread-safe — use `atomic<shared_ptr>`
  (C++20) or external sync for the handle.

---

## 6. The memory model & ordering (the hard part)

The compiler and CPU **reorder** memory ops. Ordering args to atomic ops
constrain what other threads can observe.

| Order | Meaning | Use |
|---|---|---|
| `relaxed` | atomicity only, no ordering | counters where order doesn't matter |
| `acquire` | no reads/writes *after* can move before (on loads) | lock acquire, consume-side |
| `release` | no reads/writes *before* can move after (on stores) | lock release, publish-side |
| `acq_rel` | both (on RMW) | CAS in a lock |
| `seq_cst` | single total order across all seq_cst ops (default) | when in doubt |

- **acquire/release pairing** establishes a *happens-before*: everything before
  a release store in thread A is visible to thread B after it acquire-loads the
  same atomic. This is how you publish data cheaply without a full fence.
- `seq_cst` is the default and safest; it's also the slowest. Say "I'd start
  with `seq_cst` and relax only with a benchmark + a proof."

```cpp
// acquire/release publish pattern — the workhorse of lock-free publishing:
std::atomic<Data*> ptr{nullptr};
// producer:
Data* d = new Data(...);                 // (1) build fully
ptr.store(d, std::memory_order_release); // (2) publish — nothing above (1) reorders past here
// consumer:
if (Data* p = ptr.load(std::memory_order_acquire))  // pairs with the release
    use(*p);                              // guaranteed to see the fully-built Data
```

**Stop and think.** Why is `relaxed` enough for a shared counter but *not* for
the pointer publish above?
<details><summary>answer</summary>
A counter only needs atomicity — you don't care about ordering relative to other
memory, just that increments don't tear or get lost. The pointer publish needs
an *ordering guarantee*: the consumer must see the `Data` writes that happened
*before* the store. `relaxed` gives no such happens-before, so the consumer
could observe a non-null pointer to a half-constructed object. Release/acquire
creates the happens-before edge; relaxed does not.
</details>
- **`volatile` is NOT for threading** — it prevents *compiler* optimizations for
  memory-mapped I/O; it gives no atomicity and no cross-thread ordering. Naming
  this correctly is a common interview filter.

> **Take-home lesson.** `volatile` means "this memory can change behind the
> compiler's back" (hardware registers, signal handlers). `atomic` means "this
> access is indivisible and ordered across threads." They solve different
> problems; using `volatile` for thread communication is a classic C-holdover
> bug that gives you neither atomicity nor a memory fence.

---

## 7. Practical patterns & hazards

- **`std::call_once` / `std::once_flag`** — thread-safe one-time init (or just
  use a magic static).
- **False sharing** — two threads hammering different variables that share a
  cache line serialize on the coherency protocol. Fix: pad / align to
  `std::hardware_destructive_interference_size`.
- **Thread pool** — reuse N threads over a task queue (CV + mutex + queue).
  Know how to sketch one.
- **Lock-free is hard**: ABA problem (pointer reused, CAS wrongly succeeds),
  memory reclamation (hazard pointers / RCU). Mention these to show awareness;
  don't claim lock-free by default — it's often slower and buggier than a
  well-scoped mutex.

---

## Drill prompts
1. Define data race vs race condition; give one example of each.
2. Implement a thread-safe queue (mutex + condition_variable, predicate wait).
3. Why must you modify shared state under the lock before `notify_one`?
4. Explain acquire/release with a producer publishing a pointer to data.
5. Why is `volatile bool done` insufficient for stopping a worker thread?
6. Sketch a fixed-size thread pool; then add graceful shutdown.
7. Show an ABA scenario and how a tagged pointer / hazard pointer addresses it.
