# M03 — Divide & Conquer and Recurrences

**Sources:** CLRS Ch. 4 (Divide-and-Conquer: matrix multiplication, Strassen, substitution, recursion trees, master method, Akra–Bazzi) · Skiena Ch. 5 (Divide and Conquer: binary search, recurrences, Karatsuba, largest subrange, closest pair, parallelism, convolution)

---

## Big Idea

Divide and conquer is three steps — **Divide** into smaller instances of the same problem, **Conquer** them recursively, **Combine** the results — plus a base case. Its power is that the analysis is mechanical: the three steps translate directly into a recurrence `T(n) = aT(n/b) + f(n)`, and the recurrence is solved by comparing the **driving function** `f(n)` against the **watershed function** `n^{log_b a}`. Whichever is bigger wins: if the watershed wins, the cost lives in the leaves (`Θ(n^{log_b a})`); if they tie, every level costs the same and you pay a `log n` factor; if the driving function wins, the root dominates (`Θ(f(n))`). That comparison *is* the master theorem, and once you see the recursion tree behind it, the three cases stop being something to memorize. The strategic insight — the one that produced Strassen and Karatsuba — is that **reducing `a` (the branching factor) beats reducing `f(n)`**: trading one recursive multiplication for a handful of extra additions changes the exponent, and nothing else in the recurrence can do that. Remember: *bushiness of the recursion tree decides the exponent.*

---

## What You Should Be Able To Do After This Chapter

- Turn any recursive algorithm into its recurrence, correctly identifying `a`, `b`, and `f(n)`.
- Apply the master theorem's three cases, including checking the **polynomial** separation and the **regularity condition**, and recognize the two gaps where it does not apply.
- Solve a recurrence by **substitution**, including the "subtract a lower-order term" trick, and avoid the two classic fallacies (asymptotic notation in the hypothesis; proving `O(n)` instead of `≤ cn`).
- Draw a **recursion tree**, compute per-level costs and the number of leaves, and read off whether the root, the levels, or the leaves dominate.
- Explain *why* `T(n) = 8T(n/2) + Θ(1)` is `Θ(n³)` while `T(n) = 2T(n/2) + Θ(n)` is `Θ(n log n)` — in terms of bushiness.
- Derive Karatsuba and Strassen from the "trade a multiplication for additions" idea, and state their recurrences and exponents.
- Write correct binary search (and its lower-bound/upper-bound variants) in C++, first try, with the overflow-safe midpoint.
- Solve the largest-subrange and closest-pair problems by the "left, right, or straddling the middle" template.
- Use Akra–Bazzi when subproblem sizes differ, and know the polynomial-growth condition that lets you ignore floors and ceilings.

---

## 1. The method, and what a recurrence is

### Unified Understanding

**The three steps** [CLRS Ch. 4, p.76]:

- **Divide** the problem into one or more subproblems that are smaller instances of the same problem.
- **Conquer** the subproblems by solving them recursively.
- **Combine** the subproblem solutions to form a solution to the original problem.
- **Base case:** if the problem is small enough, solve it directly without recursing.

Skiena's framing of *when it pays*:

> Whenever the merging takes less time than solving the two subproblems, we get an efficient algorithm. [Skiena Ch. 5, p.147]

And his contrast with the other decomposition paradigm:

> **Dynamic programming** typically removes *one* element from the problem, solves the smaller problem, and then adds back the element to the solution of this smaller problem in the proper way. **Divide and conquer** instead splits the problem into (say) halves, solves each half, then stitches the pieces back together.

**Skiena's honest caveat**, which is worth taking seriously:

> Beyond binary search and its many variants, I find it to be a **difficult design technique to apply in practice**.

That is why this module spends more time on *analyzing* divide and conquer than on inventing it — and why the interview-relevant skill here is recurrence-solving, not D&C invention.

### Recurrences [CLRS Ch. 4, p.76]

> A **recurrence** is an equation that describes a function in terms of its value on other, typically smaller, arguments.

Formally: an equation or inequality describing a function over the integers or reals **using the function itself**, containing two or more cases. A case that invokes the function recursively is a **recursive case**; one that doesn't is a **base case**. The recurrence is **well defined** if at least one function satisfies it.

Skiena's point that recurrences are a general notation, not a D&C-only tool [§5.3, p.152]:

```
aₙ = aₙ₋₁ + 1,   a₁ = 1  →  aₙ = n           (linear)
aₙ = 2aₙ₋₁,      a₁ = 1  →  aₙ = 2ⁿ⁻¹        (exponential)
aₙ = n·aₙ₋₁,     a₁ = 1  →  aₙ = n!          (factorial)
Fₙ = Fₙ₋₁ + Fₙ₋₂                              (Fibonacci)
```

> Recurrence relations provide a way to analyze recursive structures, such as algorithms.

### Algorithmic recurrences — CLRS's convention, and why it's safe

A recurrence `T(n)` is **algorithmic** if, for every sufficiently large threshold constant `n₀ > 0`:

1. For all `n < n₀`, `T(n) = Θ(1)`.
2. For all `n ≥ n₀`, every recursion path terminates in a defined base case within finitely many invocations.

> **Whenever a recurrence is stated without an explicit base case, we assume that the recurrence is algorithmic.**

Why this is legitimate: property 1 holds because there are finitely many inputs below `n₀`, and calling and returning from a procedure costs at least some positive constant. Property 2 must hold or **the algorithm isn't correct** — it would loop forever. So any correct D&C algorithm's worst-case recurrence is automatically algorithmic. [CLRS p.77]

**Three conventions that follow**, all of which you should adopt:

| Convention | Justification |
|---|---|
| Omit the base case | It is always `Θ(1)`; the asymptotic solution doesn't depend on the threshold. |
| Drop floors and ceilings | `T(n) = 2T(n/2) + Θ(n)` instead of `T(⌈n/2⌉) + T(⌊n/2⌋) + Θ(n)`. §4.7 gives sufficient conditions (below). |
| Inequality → one-sided bound | `T(n) ≤ 2T(n/2) + Θ(n)` gives an `O`-solution; `≥` gives an `Ω`-solution. |

### Subproblem-size taxonomy

| Recurrence | Shape | Solution |
|---|---|---|
| `T(n) = 2T(n/2) + Θ(n)` | equal halves, linear combine | `Θ(n log n)` — merge sort |
| `T(n) = 8T(n/2) + Θ(1)` | equal halves, 8-way, O(1) combine | `Θ(n³)` — naive recursive matrix multiply |
| `T(n) = 7T(n/2) + Θ(n²)` | equal halves, 7-way | `Θ(n^{lg 7}) = O(n^{2.81})` — Strassen |
| `T(n) = T(n/3) + T(2n/3) + Θ(n)` | **unequal** split | `Θ(n log n)` |
| `T(n) = T(n/5) + T(7n/10) + Θ(n)` | unequal, shrinking total | `Θ(n)` — median-of-medians selection (M05) |
| `T(n) = T(n−1) + Θ(1)` | constant shrinkage | `Θ(n)` — recursive linear search |

> The vast majority of efficient divide-and-conquer algorithms solve subproblems that are **a constant fraction** of the size of the original. [CLRS p.79]

---

## 2. Algorithm: Binary Search — "the mother of all divide-and-conquer algorithms"

### Problem

Find key `q` in a **sorted** array `S[0..n−1]`; report its index or that it is absent.

### Core intuition

Compare `q` to the middle element. One comparison eliminates **half** the remaining candidates. Repeat.

### Mental model

**Twenty questions.** Skiena's framing [§5.1, p.148]: a printed dictionary holds 50,000–200,000 words, so `lg(200000) ≈ 18` — the second player in twenty questions always wins by binary search.

### Pseudocode

```
BinarySearch(S, q, lo, hi)
    if lo > hi:  return NOT_FOUND
    mid = (lo + hi) / 2
    if S[mid] == q:  return mid
    if S[mid] >  q:  return BinarySearch(S, q, lo, mid − 1)
    else:            return BinarySearch(S, q, mid + 1, hi)
```

### Why it works — loop invariant

*If `q` is present in the original array, it lies within `S[lo..hi]`.*
**Initialization:** `lo = 0, hi = n−1` — the whole array. **Maintenance:** the array is sorted, so `S[mid] > q` implies `q` cannot be at `mid` or to its right; symmetrically for `<`. **Termination:** either `S[mid] == q` (found), or `lo > hi` — an empty range, so by the invariant `q` was never present. ∎

### Complexity

```
T(n) = T(n/2) + Θ(1)   →   Θ(log n)
```

Master theorem case 2: `a = 1, b = 2`, watershed `n^{log₂1} = n⁰ = 1`, driving `f(n) = Θ(1) = Θ(n⁰ lg⁰ n)`, so `T(n) = Θ(lg n)`. [CLRS Ex. 4.5-3]

Space: `Θ(1)` iterative; `Θ(log n)` stack if recursive.

### C++ Implementation

```cpp
#include <vector>

// Classic binary search. Returns index of key, or -1 if absent.
template <typename T>
int binarySearch(const std::vector<T>& v, const T& key) {
    int lo = 0, hi = static_cast<int>(v.size()) - 1;
    while (lo <= hi) {
        const int mid = lo + (hi - lo) / 2;   // overflow-safe
        if (v[mid] == key)      return mid;
        else if (v[mid] < key)  lo = mid + 1;
        else                    hi = mid - 1;
    }
    return -1;
}

// First index i with v[i] >= key  (== std::lower_bound). Returns v.size() if none.
template <typename T>
int lowerBound(const std::vector<T>& v, const T& key) {
    int lo = 0, hi = static_cast<int>(v.size());   // NOTE: half-open [lo, hi)
    while (lo < hi) {
        const int mid = lo + (hi - lo) / 2;
        if (v[mid] < key) lo = mid + 1;
        else              hi = mid;
    }
    return lo;
}

// First index i with v[i] > key  (== std::upper_bound).
template <typename T>
int upperBound(const std::vector<T>& v, const T& key) {
    int lo = 0, hi = static_cast<int>(v.size());
    while (lo < hi) {
        const int mid = lo + (hi - lo) / 2;
        if (!(key < v[mid])) lo = mid + 1;         // v[mid] <= key
        else                 hi = mid;
    }
    return lo;
}

// Number of occurrences of key in a sorted vector, in O(log n)
// regardless of how many copies there are.
template <typename T>
int countOccurrences(const std::vector<T>& v, const T& key) {
    return upperBound(v, key) - lowerBound(v, key);
}
```

### Implementation notes

- **`lo + (hi − lo)/2`, never `(lo + hi)/2`.** The latter overflows `int` for arrays over ~2³⁰ elements. This exact bug shipped in `java.util.Arrays.binarySearch` and in the JDK's merge sort for nine years.
- **Half-open `[lo, hi)` for the bound variants, closed `[lo, hi]` for the classic search.** Mixing the two conventions is the single biggest source of binary-search bugs. Pick one per function and never deviate.
- `lowerBound`/`upperBound` **always terminate** because `hi − lo` strictly decreases: when `lo = mid + 1`, `mid ≥ lo` so `lo` grows; when `hi = mid`, `mid < hi` so `hi` shrinks.
- `upperBound` uses `!(key < v[mid])` so only `operator<` is required — matching STL conventions.
- In practice use `std::lower_bound` / `std::upper_bound` / `std::equal_range`. Write them by hand only in interviews or when the predicate isn't a simple comparison.

### Common bugs

- `(lo + hi)/2` overflow.
- Mixing `[lo, hi]` and `[lo, hi)` inside one function → infinite loop or off-by-one.
- `while (lo < hi)` with `hi = mid − 1` → skips the answer.
- `while (lo <= hi)` with `hi = mid` → infinite loop when `lo == hi`.
- Assuming the array is sorted when it isn't. Binary search on unsorted data silently returns garbage.

### Three variants worth knowing [Skiena §5.1]

**1. Counting occurrences in `O(log n)`.** Naively you find one occurrence in `O(lg n)` then scan outward — `O(lg n + s)`, which degrades to `Θ(n)` when the whole array is one key. Instead, **delete the equality test** so every search "fails", and it terminates at a block boundary. Reverse the comparison direction to find the other boundary. Two `O(lg n)` searches, done. (Equivalently: `upperBound − lowerBound`, as above.)

Skiena's other trick for the same problem: search for `k − ε` and `k + ε` with a modified routine that returns the insertion position — both searches fail with no intervening keys, and their positions bracket the block.

**2. One-sided (galloping / exponential) binary search.** Array of `0`s followed by an unbounded run of `1`s; find the transition, with **no known bound `n`**. Probe `A[1], A[2], A[4], A[8], A[16], …` until you hit a `1`, then binary search inside that window. Finds the transition point `p` in at most **`2⌈lg p⌉`** comparisons, regardless of the array's actual size.

> One-sided binary search is useful whenever we are **looking for a key that lies close to our current position**.

```cpp
// Finds the smallest index p >= 1 with pred(p) true, given pred is monotone
// (false...false true...true) and unbounded. O(log p) evaluations of pred.
template <typename Pred>
long long exponentialSearch(Pred pred) {
    long long hi = 1;
    while (!pred(hi)) hi *= 2;              // doubling phase: <= lg p probes
    long long lo = hi / 2 + 1;              // pred(hi/2) was false
    while (lo < hi) {                       // binary phase: <= lg p probes
        const long long mid = lo + (hi - lo) / 2;
        if (pred(mid)) hi = mid;
        else           lo = mid + 1;
    }
    return lo;
}
```

**3. Bisection for roots (square roots, and any continuous `f`).** `√n` lies in `[1, n]`. Test `m = (l+r)/2`: if `n ≥ m²` recurse right, else left. After `⌈lg n⌉` rounds you have `√n` to `±1/2`. Generalizes: if `f` is continuous with `f(l) > 0` and `f(r) < 0`, a root lies between them, and the sign of `f(m)` halves the window.

> Root-finding algorithms converging faster than binary search are known… Still, binary search is **simple, robust, and works as well as possible without additional information** on the nature of the function.

**Recognition pattern for all of these:** you have a **monotone predicate** over an ordered domain, and you want the boundary. That is the general form — "binary search on the answer" — and it is one of the highest-frequency competitive-programming patterns. See the Recognition Table.

---

## 3. War Story: Finding the Bug in the Bug — parallelizing binary search

[Skiena §5.2, p.150]

Skiena's team built synthetic attenuated viruses by replacing a 1,200-base gene region — and killed the virus. Somewhere in those 1,200 bases was a hidden survival signal. Finding it by binary search would take `lg(16) = 4` sequential rounds of experiment, and **each round took Yutong a month** to synthesize, clone and grow.

> Yutong realized that the power of binary search came from **interaction**: the query we make in round `r` depends upon the answers to queries in rounds `1` through `r−1`. **Binary search is an inherently sequential algorithm.** When each individual comparison is a slow and laborious process, suddenly `lg n` comparisons doesn't look so good.

**The fix.** Run all four "rounds" *simultaneously* as four separate designs, each half red (dead-strain sequence) and half green (viable), arranged so that the 16 candidate regions get **16 distinct red/green column patterns**. The live/dead outcome of the four designs is a 4-bit code naming the region.

This is exactly the difference between **adaptive** and **non-adaptive** search. Adaptive binary search takes `lg n` sequential steps; non-adaptive requires `lg n` *parallel* queries, but each query may be an arbitrary subset rather than a contiguous half. Skiena's designs are the rows of the binary-encoding matrix — the same construction as a Hamming-style identification code.

**The engineering lesson generalizes far beyond biology.** Whenever each probe is expensive in *latency* but cheap in *throughput* — a batch of CI runs, a set of A/B experiments, a round of network probes — convert the adaptive binary search into a one-round set of `lg n` subset queries.

---

## 4. Method 1: Substitution

### The method [CLRS §4.3, p.90]

1. **Guess** the form of the solution, using symbolic constants.
2. **Use mathematical induction** to show it works, and solve for the constants.

> It's usually best not to try to do both at the same time. Rather than trying to prove a `Θ`-bound directly, first prove an `O`-bound, and then prove an `Ω`-bound.

### Worked example — `T(n) = 2T(⌊n/2⌋) + Θ(n)` is `O(n lg n)`

**Hypothesis:** `T(n) ≤ cn lg n` for all `n ≥ n₀`, constants chosen later.

```
T(n) ≤ 2(c⌊n/2⌋ lg⌊n/2⌋) + Θ(n)
     ≤ 2(c(n/2) lg(n/2)) + Θ(n)
     = cn lg(n/2) + Θ(n)
     = cn lg n − cn lg 2 + Θ(n)
     = cn lg n − cn + Θ(n)
     ≤ cn lg n
```

— the last step holding **if `c` and `n₀` are large enough that `cn` dominates the anonymous function hidden by `Θ(n)`.**

**Base cases.** Need `T(n) ≤ cn lg n` for `n₀ ≤ n < 2n₀`. Requires `n₀ > 1` so that `n lg n > 0`; pick `n₀ = 2`. Since the recurrence is algorithmic, `T(2)` and `T(3)` are constants. Pick `c = max{T(2), T(3)}`: then `T(2) ≤ c < (2 lg 2)c` and `T(3) ≤ c < (3 lg 3)c`. ∎

> In the algorithms literature, people rarely carry out their substitution proofs to this level of detail, especially in their treatment of base cases. … You ground the induction on a range of values from a convenient positive constant `n₀` up to some constant `n₀′ > n₀` such that for `n ≥ n₀′`, the recurrence always bottoms out in a constant-sized base case. [CLRS p.91]

**Translation:** in an interview, do the inductive step carefully and wave at the base cases. Do not skip the inductive step.

### Making a good guess

There is no general method. Three heuristics [CLRS §4.3, p.92]:

**1. Pattern-match against recurrences you know.** `T(n) = 2T(n/2 + 17) + Θ(n)` looks like merge sort; the `+17` shouldn't matter for large `n` since both still cut `n` nearly in half. Guess `O(n lg n)` and verify.

**2. Squeeze from both sides.** Start with a loose `Ω(n)` (from the `Θ(n)` term) and a loose `O(n²)`, then alternate lowering the upper bound and raising the lower until they meet.

**3. Draw the recursion tree** (§5 below) and read the guess off it.

### The trick of the trade: **subtract a lower-order term**

Consider `T(n) = 2T(n/2) + Θ(1)`. Guess `T(n) ≤ cn`:

```
T(n) ≤ 2(c(n/2)) + Θ(1) = cn + Θ(1)    ✗ does NOT give ≤ cn
```

The guess `O(n)` is **correct and tight** — the problem is the hypothesis is too weak. Strengthen it to `T(n) ≤ cn − d` for a constant `d ≥ 0`:

```
T(n) ≤ 2(c(n/2) − d) + Θ(1)
     = cn − 2d + Θ(1)
     ≤ cn − d − (d − Θ(1))
     ≤ cn − d                      ✓ as long as d exceeds the Θ's hidden constant
```

**Why subtract rather than add** — this is the part people get backwards:

> When the recurrence contains more than one recursive invocation, if you **add** a lower-order term to the guess, then you end up adding it once **for each** recursive invocation. Doing so takes you even further away from the inductive hypothesis. On the other hand, if you **subtract** a lower-order term, then you get to subtract it once for each of the recursive invocations. [CLRS p.93]

With coefficient `2`, you subtract `d` twice and only need to give back `d` once — the slack is yours.

### The two pitfalls

**Pitfall 1 — asymptotic notation inside the inductive hypothesis.** This "proves" `T(n) = 2T(⌊n/2⌋) + Θ(n)` is `O(n)`:

```
T(n) ≤ 2·O(⌊n/2⌋) + Θ(n) = 2·O(n) + Θ(n) = O(n)      ← WRONG
```

The fallacy: **the constant hidden by `O` changes**. Redo it with an explicit constant and it collapses:

```
T(n) ≤ 2(c⌊n/2⌋) + Θ(n) ≤ cn + Θ(n)
```

`cn + Θ(n)` is indeed `O(n)`, but the hidden constant must **exceed `c`** — so you cannot conclude `≤ cn`.

> When using the substitution method, you must be careful that the constants hidden by any asymptotic notation are **the same constants throughout the proof**. Consequently, it's best to **avoid asymptotic notation in your inductive hypothesis and to name constants explicitly.**

**Pitfall 2 — proving the goal instead of the hypothesis.**

```
T(n) ≤ 2(c⌊n/2⌋) + Θ(n) ≤ cn + Θ(n) = O(n)      ← WRONG
```

The mistake is the gap between the **goal** (`T(n) = O(n)`) and the **inductive hypothesis** (`T(n) ≤ cn`). Induction requires you to prove **the exact statement of the hypothesis** — here, `T(n) ≤ cn`, which you have not.

---

## 5. Method 2: Recursion Trees

### What it is

> In a recursion tree, each node represents the cost of a single subproblem somewhere in the set of recursive function invocations. You typically sum the costs within each level to obtain the per-level costs, and then sum all the per-level costs. [CLRS §4.4, p.95]

> A recursion tree is best used to **generate intuition for a good guess**, which you can then verify by the substitution method. If you are meticulous when drawing out a recursion tree and summing the costs, however, you can use it as a **direct proof**.

**Practical advice:** be sloppy when guessing, precise when verifying.

### The three quantities to extract

| Quantity | How to get it |
|---|---|
| **Depth** | subproblem size at depth `i` is `n/bⁱ`; hits the base case at `i = log_b n` |
| **Nodes at depth `i`** | `aⁱ` |
| **Cost per level `i`** | `aⁱ · f(n/bⁱ)` |
| **Number of leaves** | `a^{log_b n} = n^{log_b a}` (by the identity `a^{log_b c} = c^{log_b a}`) |
| **Leaf cost** | `Θ(n^{log_b a})` |

Then ask: does the **sequence of level costs** grow, stay flat, or shrink geometrically? That is the whole master theorem.

### Worked example — `T(n) = 3T(n/4) + Θ(n²)` [CLRS Fig. 4.1]

```
depth 0:                     cn²                                   cost  cn²
depth 1:        c(n/4)²   c(n/4)²   c(n/4)²                        cost  (3/16)cn²
depth 2:   9 nodes, each c(n/16)²                                  cost  (3/16)²cn²
  ⋮
depth log₄n:  3^{log₄ n} = n^{log₄ 3} leaves, each Θ(1)            cost  Θ(n^{log₄3})
```

Summing:

```
T(n) = Σ_{i=0}^{log₄n} (3/16)ⁱ cn²  +  Θ(n^{log₄3})
     < cn² Σ_{i=0}^{∞} (3/16)ⁱ      +  Θ(n^{log₄3})
     = cn² · 1/(1 − 3/16)           +  Θ(n^{log₄3})     [geometric series, A.7]
     = (16/13)cn²                   +  Θ(n^{0.793})
     = O(n²)
```

**The coefficients form a decreasing geometric series**, so the whole tree costs a constant multiple of the root. The root dominates.

And the bound is **tight**: the first call alone contributes `Θ(n²)`, so `Ω(n²)` holds too.

**Verifying by substitution.** Show `T(n) ≤ dn²`:

```
T(n) ≤ 3T(n/4) + cn² ≤ 3d(n/4)² + cn² = (3/16)dn² + cn² ≤ dn²
```

whenever `d ≥ (16/13)c`. ✓

**Note the two constants.** `c` is *given to us* by the `Θ(n²)` — we can't pick it (though any `c′ ≥ c` also works). `d` we choose freely, and its value depending on `c` is fine, since `d` is constant when `c` is.

### Worked example — the unbalanced tree `T(n) = T(n/3) + T(2n/3) + Θ(n)` [CLRS Fig. 4.2]

```
                      cn                                      total cn
              c(n/3)      c(2n/3)                             total cn
         c(n/9) c(2n/9) c(2n/9) c(4n/9)                        total cn
              ⋮       (unbalanced — leaves at different depths)
```

**Height.** The *longest* path runs down the right edge: `n, (2/3)n, (4/9)n, …`. It hits the threshold when `(2/3)ʰn < n₀`, giving `h = ⌊log_{3/2}(n/n₀)⌋ + 1 = Θ(lg n)`.

**Internal nodes.** Each *full* level sums to exactly `cn` (the two children's arguments sum back to `n`). At most `cn` per level × `Θ(lg n)` levels = **`O(n lg n)`**.

**Leaves — and the instructive trap.** Tempting bound: the tree sits inside a complete binary tree of height `h = ⌊log_{3/2} n⌋ + 1`, which has `2^h ≤ 2n^{log_{3/2}2} = O(n^{1.71})` leaves. That would swamp the `O(n lg n)` internal cost — **and it is not tight.**

Do it properly with a separate recurrence for the leaf count:

```
L(n) = 1                        if n < n₀
L(n) = L(n/3) + L(2n/3)         if n ≥ n₀
```

Substitution with `L(n) ≤ dn`: `L(n) ≤ dn/3 + 2dn/3 = dn` ✓ for any `d > 0`, and `d = 1` handles the base case. So **`L(n) = O(n)`**, and the total leaf cost is `Θ(n)` — asymptotically *less* than the internal cost.

```
T(n) = O(n lg n) + Θ(n) = O(n lg n)      (and Ω(n lg n), so Θ(n lg n))
```

> **The cost of the internal nodes dominates the cost of the leaves, not vice versa.** … You may see recurrences for which the cost of leaves dominates the cost of internal nodes, and then you'll be in better shape if you've had some experience analyzing the number of leaves. [CLRS p.100]

**The general lesson:** bounding an unbalanced recursion tree by the complete binary tree that contains it is almost always far too generous. Write a recurrence for the leaf count instead.

### Skiena's picture of the general tree [Fig. 5.2, p.154]

For `T(n) = aT(n/b) + f(n)`: **vertex degree `a`**, **partition size `n/bⁱ`**, **height `log_b n`**, **width (leaf count) `a^{log_b n} = n^{log_b a}`**.

---

## 6. Method 3: The Master Theorem

### Theorem 4.1 (Master theorem) [CLRS §4.5, p.102]

Let `a > 0` and `b > 1` be constants, `f(n)` a **driving function** defined and nonnegative on all sufficiently large reals. Define

```
T(n) = a·T(n/b) + f(n)
```

(where `aT(n/b)` implicitly means `a′T(⌊n/b⌋) + a″T(⌈n/b⌉)` for `a′ + a″ = a`). Call `n^{log_b a}` the **watershed function**. Then:

| Case | Condition | Solution | Recursion tree behaviour |
|---|---|---|---|
| **1** | `∃ε > 0` such that `f(n) = O(n^{log_b a − ε})` | `T(n) = Θ(n^{log_b a})` | level costs **grow** geometrically; **leaves dominate** |
| **2** | `∃k ≥ 0` such that `f(n) = Θ(n^{log_b a} lg^k n)` | `T(n) = Θ(n^{log_b a} lg^{k+1} n)` | every level costs the same; `Θ(lg n)` levels |
| **3** | `∃ε > 0` such that `f(n) = Ω(n^{log_b a + ε})` **and** the **regularity condition** `a·f(n/b) ≤ c·f(n)` holds for some `c < 1` and all large `n` | `T(n) = Θ(f(n))` | level costs **shrink** geometrically; **root dominates** |

Skiena's version of the same three, in one sentence each [§5.4, p.155]:

- **Case 1: too many leaves.** The leaf count outweighs the internal evaluation cost → `O(n^{log_b a})`.
- **Case 2: equal work per level.** Cost per level × number of levels → `O(n^{log_b a} lg n)`.
- **Case 3: too expensive a root.** Internal cost grows so fast the root dominates → `O(f(n))`.

> Case 1 holds for heap construction and matrix multiplication, while Case 2 holds for mergesort. **Case 3 generally arises with clumsier algorithms, where the cost of combining the subproblems dominates everything.**

### The two technical details people skip

**Polynomial separation, in cases 1 and 3.**

> Not only must the watershed function grow asymptotically faster than the driving function, it must grow **polynomially** faster — by at least a factor of `Θ(n^ε)` for some constant `ε > 0`.

The separation need not be big. For `T(n) = 4T(n/2) + n^{1.99}`, watershed is `n²`, driving is smaller by a factor `n^{0.01}` — case 1 applies with `ε = 0.01`.

**The regularity condition, in case 3.** `a·f(n/b) ≤ c·f(n)` for some `c < 1`. It is satisfied by essentially every polynomially bounded function you will meet. It fails for functions that grow slowly locally but quickly overall (CLRS Ex. 4.5-5: `f(n) = 2^{⌈lg n⌉}`).

**Case 2 in practice.** *"The most common situation for case 2 occurs when `k = 0`"* — watershed and driving function have the same growth, giving `T(n) = Θ(n^{log_b a} lg n)`.

### Worked applications

| Recurrence | `a` | `b` | watershed `n^{log_b a}` | `f(n)` | Case | Solution |
|---|---|---|---|---|---|---|
| `T(n) = 9T(n/3) + n` | 9 | 3 | `n²` | `n` | 1 (`ε ≤ 1`) | `Θ(n²)` |
| `T(n) = T(2n/3) + 1` | 1 | 3/2 | `n⁰ = 1` | `1` | 2 (`k=0`) | `Θ(lg n)` |
| `T(n) = 3T(n/4) + n lg n` | 3 | 4 | `n^{0.793}` | `n lg n` | 3 (`ε ≈ 0.2`; regularity: `3(n/4)lg(n/4) ≤ (3/4)n lg n`, `c = 3/4`) | `Θ(n lg n)` |
| `T(n) = 2T(n/2) + n lg n` | 2 | 2 | `n` | `n lg n` | 2 (`k=1`) | `Θ(n lg² n)` |
| `T(n) = 2T(n/2) + Θ(n)` (merge sort) | 2 | 2 | `n` | `Θ(n)` | 2 (`k=0`) | `Θ(n lg n)` |
| `T(n) = 8T(n/2) + Θ(1)` (recursive matmul) | 8 | 2 | `n³` | `Θ(1)` | 1 (any `ε < 3`) | `Θ(n³)` |
| `T(n) = 7T(n/2) + Θ(n²)` (Strassen) | 7 | 2 | `n^{lg 7}` | `Θ(n²)` | 1 (`ε = 0.8`) | `Θ(n^{lg 7})` |
| `T(n) = T(n/2) + Θ(1)` (binary search) | 1 | 2 | `1` | `Θ(1)` | 2 (`k=0`) | `Θ(lg n)` |
| `T(n) = 2T(n/2) + Θ(lg n)` (heap build) | 2 | 2 | `n` | `lg n` | 1 | `Θ(n)` |

### When the master method does **not** apply

Three failure modes [CLRS p.105]:

**1. Incomparable functions.** `f(n)` may exceed `n^{log_b a}` for infinitely many `n` and fall below it for infinitely many others. Rare in practice.

**2. The gap between cases 1 and 2.** `f(n) = o(n^{log_b a})` but *not polynomially* smaller.

**3. The gap between cases 2 and 3.** `f(n) = ω(n^{log_b a})` by more than polylog but less than polynomial. Also: regularity fails.

**The canonical gap example:** `T(n) = 2T(n/2) + n/lg n`. Watershed is `n`. Driving `n/lg n = o(n)` — but only *logarithmically* smaller, not polynomially: since `lg n = o(n^ε)` for every `ε > 0`, we get `n/lg n = ω(n^{1−ε})`, so no `ε` makes case 1 work. And case 2 fails because it would need `k = −1`, while `k ≥ 0` is required. Answer (via Akra–Bazzi or substitution): **`Θ(n lg lg n)`** [CLRS Ex. 4.6-3].

> Although the master theorem doesn't handle this particular recurrence, it does handle the **overwhelming majority** of recurrences that tend to arise in practice.

---

## 7. Method 4: Akra–Bazzi (unequal subproblems)

### When you need it

The master theorem requires **all subproblems the same size**. Akra–Bazzi handles

```
T(n) = f(n) + Σ_{i=1}^{k} aᵢ·T(n/bᵢ)
```

with all `aᵢ > 0`, all `bᵢ > 1`, `f` nonnegative. [CLRS §4.7, p.115]

### The method

1. Find the **unique real `p`** solving `Σ_{i=1}^{k} aᵢ/bᵢ^p = 1`. (It always exists: the sum → ∞ as `p → −∞`, decreases in `p`, → 0 as `p → ∞`.)
2. Then

```
T(n) = Θ( n^p · (1 + ∫₁ⁿ f(x)/x^{p+1} dx) )
```

### Worked example — the selection recurrence

`T(n) = T(n/5) + T(7n/10) + n` (median-of-medians, [M05](M05-sorting.md)).

Solve `(1/5)^p + (7/10)^p = 1`. Exactly, `p = 0.83978…` — but **you don't need the exact value**: at `p = 0` the sum is `2 > 1`, at `p = 1` it is `9/10 < 1`, so `0 < p < 1`. That's enough.

Using `∫x^k dx = x^{k+1}/(k+1)` for `k ≠ −1`, with `k = −p ≠ −1`:

```
T(n) = Θ( n^p (1 + ∫₁ⁿ x^{−p} dx) )
     = Θ( n^p (1 + [x^{1−p}/(1−p)]₁ⁿ) )
     = Θ( n^p (1 + (n^{1−p} − 1)/(1−p)) )
     = Θ( n^p · Θ(n^{1−p}) )                  since 1 − p is a positive constant
     = Θ(n)
```

### Floors and ceilings — the polynomial-growth condition

Dropping floors and ceilings is **not** always safe, because driving functions can be pathological. The sufficient condition [CLRS p.116]:

> `f(n)` satisfies the **polynomial-growth condition** if there exists `n̂ > 0` such that: for every constant `φ ≥ 1`, there exists `d > 1` (depending on `φ`) with `f(n)/d ≤ f(ψn) ≤ d·f(n)` for all `1 ≤ ψ ≤ φ` and `n ≥ n̂`.

CLRS calls this possibly the hardest definition in the book. **To first order it says `f(Θ(n)) = Θ(f(n))`.**

| Satisfies it | Does not |
|---|---|
| `f(n) = Θ(n^α lg^β n lg^γ lg n)` for constants `α, β, γ` | exponentials (`2ⁿ`) and superexponentials |
| most polynomially bounded functions in this book | some polynomially bounded functions too |

**Theorem 4.5.** When `f` satisfies the polynomial-growth condition, replacing every `T(n/bᵢ)` with `T(⌈n/bᵢ⌉)` or `T(⌊n/bᵢ⌋)` **does not change the asymptotic solution.**

Even more slack is available: replacing `T(n/bᵢ)` with `T(n/bᵢ + hᵢ(n))` where `|hᵢ(n)| = O(n/lg^{1+ε} n)` leaves the solution unaffected.

> Thus, the divide step in a divide-and-conquer algorithm can be **moderately coarse** without affecting the solution to its running-time recurrence.

### Master vs Akra–Bazzi

| | Master theorem | Akra–Bazzi |
|---|---|---|
| Subproblem sizes | must be equal | may differ |
| Math needed | comparison of two functions | calculus (an integral) |
| Floors/ceilings | ignore freely | need polynomial-growth condition |
| Ease | much simpler | more general |

> **They are both good tools for your algorithmic toolkit.**

---

## 8. Algorithm: Karatsuba Multiplication

### Problem

Multiply two `n`-digit integers `A` and `B`.

### Baseline

Long multiplication is `Θ(n²)` digit products — this is the algorithm you learned in school.

### The naive divide and conquer, and why it fails

Split each number in half. With `w = 10^{n/2}`, write `A = a₀ + a₁w`, `B = b₀ + b₁w`:

```
A × B = (a₀ + a₁w)(b₀ + b₁w) = a₀b₀ + (a₀b₁ + a₁b₀)w + a₁b₁w²
```

Four half-size products plus `O(n)` additions and shifts (multiplication by `w` is just zero-padding, not a real multiply):

```
T(n) = 4T(n/2) + O(n)   →   watershed n^{log₂4} = n²   →   case 1   →   Θ(n²)
```

> **We divided, but we did not conquer.** [Skiena §5.5, p.156]

### Core intuition — trade a multiplication for additions

The seed idea, from CLRS's discussion of Strassen: to compute `x² − y²` you *seem* to need two multiplications, but `x² − y² = (x+y)(x−y)` needs only **one multiplication and two additions**. When `x` and `y` are scalars this is a wash; when they are large objects, **multiplication costs far more than addition**, so the trade wins.

### The algorithm

```
q₀ = a₀·b₀
q₁ = (a₀ + a₁)(b₀ + b₁)
q₂ = a₁·b₁

A × B = q₀ + (q₁ − q₀ − q₂)·w + q₂·w²
```

Check: `q₁ − q₀ − q₂ = (a₀b₀ + a₀b₁ + a₁b₀ + a₁b₁) − a₀b₀ − a₁b₁ = a₀b₁ + a₁b₀`. ✓ — exactly the middle coefficient, obtained without computing either cross product.

### Complexity

```
T(n) = 3T(n/2) + O(n)
```

Watershed `n^{log₂3} = n^{1.585}`. Since `f(n) = O(n) = O(n^{log₂3 − ε})` with `ε ≈ 0.585`, **case 1**:

```
T(n) = Θ(n^{log₂3}) = Θ(n^{1.585})
```

> This is a substantial improvement over the quadratic algorithm for large numbers, and indeed **beats the standard multiplication algorithm soundly for numbers of 500 digits or so.**

### Mental model

**Three multiplications instead of four; the middle term is recovered by subtraction.** Same shape as Strassen (7 instead of 8) and as the `(x+y)(x−y)` trick.

### C++ Implementation

```cpp
#include <vector>
#include <algorithm>
#include <cstdint>

// Big integers as little-endian base-10000 limbs (4 decimal digits each),
// so intermediate products fit comfortably in int64.
using BigNum = std::vector<std::int64_t>;
static constexpr std::int64_t kBase = 10000;

namespace detail {

void trim(BigNum& a) { while (a.size() > 1 && a.back() == 0) a.pop_back(); }

BigNum add(const BigNum& a, const BigNum& b) {
    BigNum r(std::max(a.size(), b.size()) + 1, 0);
    for (size_t i = 0; i < r.size(); ++i) {
        if (i < a.size()) r[i] += a[i];
        if (i < b.size()) r[i] += b[i];
    }
    trim(r);
    return r;                                  // limbs may exceed kBase; normalized at the end
}

// a - b, assuming a >= b (borrows resolved during normalization).
BigNum sub(const BigNum& a, const BigNum& b) {
    BigNum r = a;
    r.resize(std::max(a.size(), b.size()), 0);
    for (size_t i = 0; i < b.size(); ++i) r[i] -= b[i];
    trim(r);
    return r;
}

// Shift left by k limbs == multiply by kBase^k.
BigNum shiftLimbs(const BigNum& a, size_t k) {
    if (a.size() == 1 && a[0] == 0) return a;
    BigNum r(k, 0);
    r.insert(r.end(), a.begin(), a.end());
    return r;
}

BigNum schoolbook(const BigNum& a, const BigNum& b) {
    BigNum r(a.size() + b.size(), 0);
    for (size_t i = 0; i < a.size(); ++i)
        for (size_t j = 0; j < b.size(); ++j)
            r[i + j] += a[i] * b[j];
    trim(r);
    return r;
}

}  // namespace detail

// Karatsuba: Theta(n^log2(3)) limb multiplications.
BigNum karatsuba(BigNum a, BigNum b) {
    const size_t n = std::max(a.size(), b.size());
    if (n <= 32) return detail::schoolbook(a, b);      // small-case cutoff

    const size_t m = n / 2;
    a.resize(n, 0);
    b.resize(n, 0);

    const BigNum a0(a.begin(), a.begin() + m), a1(a.begin() + m, a.end());
    const BigNum b0(b.begin(), b.begin() + m), b1(b.begin() + m, b.end());

    const BigNum q0 = karatsuba(a0, b0);                                  // low
    const BigNum q2 = karatsuba(a1, b1);                                  // high
    const BigNum q1 = karatsuba(detail::add(a0, a1), detail::add(b0, b1));

    // mid = q1 - q0 - q2  ==  a0*b1 + a1*b0
    const BigNum mid = detail::sub(detail::sub(q1, q0), q2);

    BigNum r = detail::add(q0, detail::shiftLimbs(mid, m));
    r = detail::add(r, detail::shiftLimbs(q2, 2 * m));
    detail::trim(r);
    return r;
}

// Resolve carries/borrows so every limb lies in [0, kBase).
void normalize(BigNum& a) {
    std::int64_t carry = 0;
    for (size_t i = 0; i < a.size(); ++i) {
        a[i] += carry;
        carry = a[i] / kBase;
        a[i] %= kBase;
        if (a[i] < 0) { a[i] += kBase; --carry; }
    }
    while (carry > 0) { a.push_back(carry % kBase); carry /= kBase; }
    detail::trim(a);
}
```

### Implementation notes

- **Deferred normalization.** Limbs are allowed to exceed the base during the recursion and are normalized once at the end. This is what makes the `sub` calls safe without borrow-chasing, and it is meaningfully faster.
- **Base 10000, not 10.** Four decimal digits per limb cuts the limb count 4× and keeps `a[i]*b[j] ≤ 10⁸` — nowhere near `int64` overflow even after summing `n` of them for realistic `n`.
- **Cutoff to schoolbook at ~32 limbs.** Karatsuba's constant factor is worse; below the crossover, `n²` with a small constant beats `n^{1.585}` with a large one. This is the same "coarsen the leaves" idea as insertion sort inside merge sort [CLRS Problem 2-1].
- `q1` is computed on operands one limb longer than `m` — that is fine and is why `add` allocates `max+1`.
- For production big-integer work use GMP. Above ~10⁴ digits, FFT-based multiplication ([M23](M23-matrix-fft.md)) beats Karatsuba.

### Common bugs

- Forgetting that multiplication by `w` is a **shift**, and counting it as a multiplication (turning `3T(n/2)` back into `4T(n/2)`).
- Computing `mid` as `q1 − q0 − q2` with unsigned limbs → underflow.
- No cutoff → recursion down to 1 limb, dominated by call overhead.
- Splitting at `a.size()/2` and `b.size()/2` separately instead of at a common `m`.

### Recognition pattern

You have an operation that looks like it needs `k` expensive sub-operations, and the sub-operations are on *large objects* where addition is much cheaper than multiplication. Look for an algebraic identity that reuses one product in two places.

### Alternatives

| Method | Complexity | When |
|---|---|---|
| Schoolbook | `Θ(n²)` | `n` up to a few hundred digits |
| **Karatsuba** | `Θ(n^{1.585})` | hundreds to ~10⁴ digits |
| Toom–Cook (Toom-3) | `Θ(n^{1.465})` | intermediate range |
| Schönhage–Strassen / FFT | `O(n log n log log n)` | very large `n` — [M23](M23-matrix-fft.md) |

---

## 9. Algorithm: Strassen's Matrix Multiplication

### Problem

Multiply two `n × n` matrices, `C = A·B`, where `cᵢⱼ = Σₖ aᵢₖ·bₖⱼ`.

### Baselines

**Triple loop:** `Θ(n³)` — `n²` entries, each an `n`-term dot product.

**Naive divide and conquer** [CLRS §4.1]. Partition each matrix into four `n/2 × n/2` blocks:

```
⎡C₁₁ C₁₂⎤   ⎡A₁₁ A₁₂⎤ ⎡B₁₁ B₁₂⎤
⎣C₂₁ C₂₂⎦ = ⎣A₂₁ A₂₂⎦ ⎣B₂₁ B₂₂⎦

C₁₁ = A₁₁B₁₁ + A₁₂B₂₁      C₁₂ = A₁₁B₁₂ + A₁₂B₂₂
C₂₁ = A₂₁B₁₁ + A₂₂B₂₁      C₂₂ = A₂₁B₁₂ + A₂₂B₂₂
```

Eight `n/2` multiplications, four block additions. **Partition by index calculation, not copying** — a submatrix is specified by *where it lies*, which is constant-size location information, so partitioning is `Θ(1)` and updates land in the original storage. (Copying instead takes `Θ(n²)` for `3n²` element copies; CLRS Ex. 4.1-3 shows it doesn't change the asymptotics *here*, but Ex. 4.1-4 shows it does for matrix *addition*.)

```
T(n) = 8T(n/2) + Θ(1)   →   Θ(n³)
```

**No better than the triple loop.** Why? Compare the recursion trees:

> The factor of 2 in the merge-sort recurrence determines how many children each tree node has… for recurrence (4.9), each internal node has **eight** children, not two, leading to a **"bushier"** recursion tree with many more leaves, despite the fact that the internal nodes are each much smaller. [CLRS p.84]

**This is the central insight of the whole module.** The exponent is set by the branching factor `a`, not by how cheap `f(n)` is. `Θ(1)` combine work cannot save an 8-way branch.

### Core intuition

> The key to Strassen's method is to use the divide-and-conquer idea… but **make the recursion tree less bushy**. We'll actually increase the work for each divide and combine step by a constant factor, but the reduction in bushiness will pay off. [CLRS §4.2, p.85]

Seven recursive multiplications instead of eight, at the cost of 18 block additions.

> Strassen's strategy for reducing the number of matrix multiplications at the expense of more matrix additions is not at all obvious — **perhaps the biggest understatement in this book!**

### The algorithm

**Step 2** — form ten `n/2 × n/2` sums:

```
S₁ = B₁₂ − B₂₂     S₂ = A₁₁ + A₁₂     S₃ = A₂₁ + A₂₂     S₄ = B₂₁ − B₁₁
S₅ = A₁₁ + A₂₂     S₆ = B₁₁ + B₂₂     S₇ = A₁₂ − A₂₂     S₈ = B₂₁ + B₂₂
S₉ = A₁₁ − A₂₁     S₁₀ = B₁₁ + B₁₂
```

**Step 3** — seven recursive products:

```
P₁ = A₁₁·S₁     P₂ = S₂·B₂₂     P₃ = S₃·B₁₁     P₄ = A₂₂·S₄
P₅ = S₅·S₆      P₆ = S₇·S₈      P₇ = S₉·S₁₀
```

**Step 4** — combine:

```
C₁₁ += P₅ + P₄ − P₂ + P₆
C₁₂ += P₁ + P₂
C₂₁ += P₃ + P₄
C₂₂ += P₅ + P₁ − P₃ − P₇
```

### Why it works

Pure algebra — expand each `Pᵢ` and watch terms cancel. For `C₁₁`:

```
  A₁₁B₁₁ + A₁₁B₂₂ + A₂₂B₁₁ + A₂₂B₂₂     (P₅)
        − A₂₂B₁₁ + A₂₂B₂₁                (P₄)
        − A₁₁B₂₂ − A₁₂B₂₂                (−P₂)
        − A₂₂B₂₂ − A₂₂B₂₁ + A₁₂B₂₂ + A₁₂B₂₁   (P₆)
  ─────────────────────────────────────
  = A₁₁B₁₁ + A₁₂B₂₁        ✓ matches the definition of C₁₁
```

The other three verify the same way [CLRS pp.88–89]. **The products in the right-hand columns are never computed explicitly** — only the seven `Pᵢ`.

### Complexity

```
T(n) = 7T(n/2) + Θ(n²)
```

Watershed `n^{log₂7} = n^{2.807355…}`. With `ε = 0.8`, `f(n) = Θ(n²) = O(n^{lg7 − 0.8})` — **case 1**:

```
T(n) = Θ(n^{lg 7}) = O(n^{2.81})
```

Uses **7 submatrix multiplications and 18 submatrix additions**.

### Implementation notes / practical reality

- **Constant factor.** 18 block additions vs 4 makes Strassen slower than a well-tuned `n³` BLAS routine until `n` is in the several hundreds to low thousands.
- **Numerical stability.** The subtractions make Strassen less numerically stable than the standard algorithm for floating point — a real objection in scientific computing.
- **Non-powers of 2.** Pad to the next power of 2, or peel one row/column ([CLRS Ex. 4.1-1]).
- Real implementations use Strassen only above a cutoff and fall back to blocked `n³` below.

### Alternatives / history

> This algorithm has been repeatedly "improved" by increasingly complicated recurrences, and the current best is `O(n^{2.3727})`. [Skiena §5.5, p.157]

These galactic algorithms are asymptotically better and practically useless. See [M23](M23-matrix-fft.md).

**A useful exercise to have thought about** [CLRS Ex. 4.2-3]: if you could multiply `3×3` matrices with `k` multiplications, you'd get `T(n) = kT(n/3) + Θ(n²)` → `Θ(n^{log₃k})`. Beating Strassen needs `log₃k < lg 7`, i.e. `k ≤ 21`. (The best known is 23.)

---

## 10. The "left, right, or straddling the middle" template

Two problems, one shape. This is the D&C pattern you are most likely to be asked to invent in an interview.

### Algorithm: Maximum Subarray (largest subrange)

**Problem** [Skiena §5.6, p.157]. Given `A[0..n−1]`, find indices `i ≤ j` maximizing `S = Σ_{k=i}^{j} A[k]`. Summing everything doesn't work because of negative entries. Brute force over all pairs is `Ω(n²)`.

*(Skiena's framing: a hedge fund's monthly returns `[−17, 5, 3, −10, 6, 1, 4, −3, 8, 1, −13, 4]` lost money for the year, but May–October netted `+17` — "this gives you something to brag about.")*

**Core intuition.** Split at the middle `m`. The best subarray is **entirely left**, **entirely right**, or **straddles `m`**. The first two are recursive calls. The straddling one is the union of *the best suffix of the left half* and *the best prefix of the right half* — and each is found by a single linear sweep.

**Mental model.** *Three candidates: left, right, and the greedy sweep outward from the centre.*

**Pseudocode** for the crossing half [Skiena]:

```
LeftMidMaxRange(A, l, m)
    S = M = 0
    for i = m downto l
        S = S + A[i]
        if S > M then M = S
    return M
```

**Complexity.** `T(n) = 2T(n/2) + Θ(n)` → master case 2 → **`Θ(n log n)`**.

**C++ Implementation**

```cpp
#include <vector>
#include <algorithm>
#include <limits>
#include <cstdint>

namespace detail {

// Best sum over subarrays of a[lo..hi], hi >= lo. Divide and conquer, O(n log n).
std::int64_t maxSubRec(const std::vector<int>& a, int lo, int hi) {
    if (lo == hi) return a[lo];
    const int mid = lo + (hi - lo) / 2;

    const std::int64_t best = std::max(maxSubRec(a, lo, mid),
                                       maxSubRec(a, mid + 1, hi));

    // Best suffix of the left half (must include a[mid]).
    std::int64_t s = 0, leftBest = std::numeric_limits<std::int64_t>::min();
    for (int i = mid; i >= lo; --i) { s += a[i]; leftBest = std::max(leftBest, s); }

    // Best prefix of the right half (must include a[mid + 1]).
    s = 0;
    std::int64_t rightBest = std::numeric_limits<std::int64_t>::min();
    for (int i = mid + 1; i <= hi; ++i) { s += a[i]; rightBest = std::max(rightBest, s); }

    return std::max(best, leftBest + rightBest);
}

}  // namespace detail

std::int64_t maxSubarrayDC(const std::vector<int>& a) {
    if (a.empty()) return 0;
    return detail::maxSubRec(a, 0, static_cast<int>(a.size()) - 1);
}

// Kadane's algorithm: the O(n) DP solution. Preferred in practice.
std::int64_t maxSubarrayKadane(const std::vector<int>& a) {
    if (a.empty()) return 0;
    std::int64_t best = a[0], cur = a[0];
    for (size_t i = 1; i < a.size(); ++i) {
        // Either extend the running subarray, or restart at a[i].
        cur = std::max<std::int64_t>(a[i], cur + a[i]);
        best = std::max(best, cur);
    }
    return best;
}
```

**Common bugs.** Initialising `leftBest`/`rightBest` to `0` instead of `−∞` — this silently allows an *empty* crossing part and breaks all-negative inputs. Forgetting that the crossing sweeps must **include** `a[mid]` and `a[mid+1]`.

**Alternatives.** Kadane's `Θ(n)` DP (above) beats the `Θ(n log n)` D&C and is what you should write unless asked specifically for divide and conquer. The D&C version is still worth knowing because it **generalizes**: it extends to 2-D, to segment-tree node merging (giving `O(log n)` range queries for max-subarray), and to problems where no linear scan exists.

### Algorithm: Closest Pair of Points

**1-D.** After sorting, the closest pair must be neighbours — a linear sweep gives `Θ(n log n)` dominated by the sort. The D&C version:

```
ClosestPair(A, l, r)
    mid = ⌊(l + r)/2⌋
    lmin = ClosestPair(A, l, mid)
    rmin = ClosestPair(A, mid + 1, r)
    return min(lmin, rmin, A[mid + 1] − A[mid])
```

`T(n) = 2T(n/2) + O(1)` → master **case 1** → **`Θ(n)`** (after sorting).

**2-D — the real payoff.** Sort by `x`. Split at the median `x`. The closest pair is left, right, or **straddling**. Let `d = min(lmin, rmin)`. A straddling pair must lie within a vertical strip of width `2d` around the dividing line *and* have `y`-coordinates within `d` of each other. With careful bookkeeping (sort the strip by `y`; each point need only be compared to the next few in `y`-order, because a `d × 2d` box can hold at most a constant number of points that are pairwise `≥ d` apart), the strip is processed in linear time:

```
T(n) = 2T(n/2) + Θ(n)   →   Θ(n log n)
```

> This general approach of **"find the best on each side, and then check what is straddling the middle"** can be applied to other problems as well. [Skiena §5.6, p.158]

### Recognition pattern for the whole template

You are optimizing over **contiguous ranges or geometric neighbourhoods**, and a solution either lies wholly in one half or crosses the boundary. If the crossing case can be handled in `O(n)` (or `O(1)`), you get `Θ(n log n)` (or `Θ(n)`).

---

## 11. Divide and conquer for parallelism

### Why they fit together

> Divide and conquer is the algorithm paradigm most suited to parallel computation. Typically, we seek to partition our problem of size `n` into `p` equal-sized parts, and simultaneously feed one to each processor. This reduces the makespan from `T(n)` to `T(n/p)`, plus the cost of combining. [Skiena §5.7, p.159]

**The speedup illusion.** If `T(n)` is linear, max speedup is `p`. If `T(n) = Θ(n²)` it *looks* like you can do better — you can't:

> Suppose we want to sweep through all pairs of `n` items. Sure we can partition into `p` independent chunks, but `n² − p(n/p)²` of the `n²` possible pairs will **never have both elements on the same processor**.

**Data parallelism** — running one algorithm over independent data sets (rendering animation frames, chunking a batch job) — is what actually works. *"Such tasks are often called embarrassingly parallel."*

### Skiena's four pitfalls [§5.7.2, p.160]

| Pitfall | The point |
|---|---|
| **Small upper bound on the win** | 24 cores buy at most 24×. Time spent parallelizing might be better spent on a faster sequential algorithm — and profilers are far better for sequential code. |
| **Speedup means nothing** | 24× speedup on 24 cores is meaningless if the 1-core parallel version is a crummy algorithm. Classic case: brute-force game-tree search parallelizes trivially, but alpha–beta pruning saves 99.99% of the work sequentially, dwarfing any parallel brute-force gain. Alpha–beta parallelizes badly. |
| **Tough to debug** | Non-deterministic communication → different results each run. Data-parallel programs with no inter-processor communication are much simpler. |
| **Load balancing** | See below. |

> I recommend considering parallel processing **only after** attempts at solving a problem sequentially prove too slow. Even then, I would restrict attention to data parallel algorithms where no communication is needed between processors.

### War Story: Going Nowhere Fast — the load-balancing failure

[Skiena §5.8, p.161]

Continuing the pyramidal-numbers story from [M02](M02-asymptotics.md): the supercomputing colleague split `1..10⁹` into 16 equal *intervals*, one per processor. He first fought reliability problems ("one processor died last night", "the machine was rebooted by accident", "nobody can command the entire machine for more than 13 hours"). Then, having locked half the machine:

> He failed to realize that **the time to test each integer increased as the numbers got larger**. … Thus, at longer and longer intervals, each new processor would announce its completion. Because of the architecture of the hypercube, he couldn't return any of the processors until our entire job was completed. Eventually, **half the machine and most of its users were held hostage by one, final interval.**

> If you are going to parallelize a problem, be sure to **balance the load carefully among the processors**.

**Engineering translation:** equal *input ranges* are not equal *work*. Partition by estimated cost (or use dynamic work-stealing / a task queue), not by index. The same mistake shows up in sharding databases by ID range and in splitting test suites by file count.

---

## 12. Convolution — a preview

[Skiena §5.9, p.162]

The **convolution** of arrays `A` (length `m`) and `B` (length `n`):

```
C[k] = Σ_{j=0}^{m−1} A[j]·B[k − j]        (out-of-range treated as 0)
```

The obvious nested loop is `Θ(nm)`. **A divide-and-conquer algorithm computes it in `O(n log n)`** — via the FFT, developed in [M23](M23-matrix-fft.md).

> Going from `O(n²)` to `O(n log n)` is as big a win for convolution as it was for sorting. Taking advantage of it requires **recognizing when you are doing a convolution operation**.

### When you are secretly doing a convolution

> Convolutions often arise when you are **trying all possible ways of doing things that add up to `k`**, for a large range of values of `k`, or when **sliding a mask or pattern `A` over a sequence `B`** and calculating at each position.

| Application | How it's a convolution |
|---|---|
| **Polynomial multiplication** | the `xᵏ` coefficient of a product is exactly `C[k]` — sum of products of terms whose exponents add to `k` |
| **Integer multiplication** | treat digits as polynomial coefficients in base `b`; multiply, then carry (`C[i]/b` into `C[i+1]`, `C[i] mod b`) or evaluate at `b`. **Faster than Karatsuba: `O(n log n)`.** |
| **Cross-correlation** | `C[k] = Σⱼ A[j]B[j+k]` — a *backward* shift; feed in the **reversed** sequence `Bᴿ` and it becomes a convolution. (Sales correlating with ad spend lagged `k` days.) |
| **Moving-average filters** | `C[i−1] = 0.25B[i−1] + 0.5B[i] + 0.25B[i+1]` — `A` is the window's weight vector |
| **String matching** | encode each character as a length-`α` one-hot binary vector; the dot product over a window equals `m` exactly when the pattern starts there. So `O(n log n)` string matching. |

> **Take-Home Lesson:** Learn to recognize possible convolutions. A magical `Θ(n log n)` algorithm instead of `O(n²)` is your reward for seeing this.

### The idea behind the fast algorithm (sketch)

Three observations [Skiena §5.9.2]:

1. **A degree-`n` polynomial is determined by `n+1` points.** Coefficient form ↔ point-value form.
2. **In point-value form, multiplication is `O(n)`** — just multiply the `y`-values at matching `x`-values.
3. **Evaluation at `n` arbitrary points costs `O(n²)`** — too slow. *Unless* you choose the points cleverly: at the complex `n`-th roots of unity, a degree-`n` polynomial splits into two degree-`n/2` polynomials in `x²`, giving `T(n) = 2T(n/2) + O(n) = O(n log n)`.

Full treatment in [M23](M23-matrix-fft.md).

---

## Chapter in One Page

| Concept | The one-line version |
|---|---|
| The method | Divide → Conquer → Combine, plus a base case. |
| When it pays | When merging costs less than solving the subproblems. |
| Recurrence | An equation defining a function via itself on smaller arguments. |
| Algorithmic recurrence | `T(n) = Θ(1)` below the threshold; every path terminates. Lets you omit base cases. |
| Floors/ceilings | Drop them — safe whenever the driving function satisfies polynomial growth. |
| **Substitution** | Guess a form with explicit constants; prove by induction. Prove `O` and `Ω` separately. |
| Subtract-a-term trick | When `≤ cn` won't close, try `≤ cn − d`. Subtract, never add — you get it once per recursive call. |
| Substitution pitfall 1 | Never put asymptotic notation in the inductive hypothesis. |
| Substitution pitfall 2 | You must prove the exact hypothesis (`≤ cn`), not the goal (`O(n)`). |
| **Recursion tree** | Depth `log_b n`; `aⁱ` nodes at depth `i`; `n^{log_b a}` leaves; level cost `aⁱf(n/bⁱ)`. |
| Unbalanced trees | Don't bound leaves by the enclosing complete binary tree — write `L(n)` and solve it. |
| **Master theorem** | Compare driving `f(n)` to watershed `n^{log_b a}`. |
| Case 1 | `f` polynomially smaller → `Θ(n^{log_b a})`; **leaves dominate**. |
| Case 2 | `f = Θ(n^{log_b a} lg^k n)` → `Θ(n^{log_b a} lg^{k+1} n)`; **equal per level**. |
| Case 3 | `f` polynomially larger **+ regularity** → `Θ(f(n))`; **root dominates**. |
| Master gaps | Non-polynomial separation (e.g. `2T(n/2) + n/lg n = Θ(n lg lg n)`); regularity failure; incomparable functions. |
| **Akra–Bazzi** | Unequal subproblems: find `p` with `Σaᵢ/bᵢ^p = 1`, then `T(n) = Θ(n^p(1 + ∫f(x)/x^{p+1}dx))`. |
| Binary search | `T(n) = T(n/2) + Θ(1) = Θ(lg n)`. Overflow-safe midpoint. One interval convention per function. |
| Count occurrences | `upperBound − lowerBound`, `O(lg n)` regardless of block size. |
| One-sided search | Double until you overshoot, then binary search. `2⌈lg p⌉` probes, unbounded array. |
| Binary search is sequential | `lg n` **adaptive** rounds; convert to `lg n` **parallel** subset queries when each probe is slow. |
| **Bushiness sets the exponent** | `8T(n/2)+Θ(1) = Θ(n³)` vs `2T(n/2)+Θ(n) = Θ(n lg n)`. Reduce `a`, not `f`. |
| Karatsuba | `3T(n/2) + O(n) = Θ(n^{1.585})`. `q₁ − q₀ − q₂` recovers the cross terms. |
| Strassen | `7T(n/2) + Θ(n²) = Θ(n^{lg7}) = O(n^{2.81})`. 7 mults, 18 adds. |
| The trade | One multiplication ↔ several additions. `x² − y² = (x+y)(x−y)`. |
| Left/right/straddle | Max subarray and closest pair: `2T(n/2) + Θ(n) = Θ(n lg n)`. |
| Kadane | `Θ(n)` beats the `Θ(n lg n)` D&C for max subarray in practice. |
| Parallel D&C | Data parallelism works; speedup numbers lie; **balance the load by cost, not by index range**. |
| Convolution | `Θ(nm)` naive, `O(n log n)` by FFT. Recognize: "all ways to add to `k`", sliding windows, cross-correlation. |

---

## Recognition Table

| Clue | Technique |
|---|---|
| Sorted array, or any **monotone predicate** over an ordered domain | binary search — including "binary search on the answer" |
| "Minimize the maximum" / "maximize the minimum" / "smallest `x` such that feasible(`x`)" | binary search on the answer + an `O(n)` feasibility check |
| Find the boundary of a run of equal keys | `lower_bound` / `upper_bound` |
| Unbounded or infinite input, want a nearby target | one-sided / exponential search |
| Continuous function, want a root | bisection |
| Each probe is slow but batchable | non-adaptive parallel binary search (`lg n` subset queries in one round) |
| Answer is best-in-left, best-in-right, or crosses the middle | left/right/straddle D&C |
| Contiguous-range optimization | max-subarray family — try Kadane first |
| Geometric nearest / farthest pair | sort by one axis, split, handle the strip |
| Operation needs `k` expensive sub-operations on large objects | look for an identity trading a multiply for adds (Karatsuba/Strassen) |
| Recurrence `aT(n/b) + f(n)` | master theorem |
| Subproblems of **different** sizes | Akra–Bazzi, or a recursion tree + substitution |
| Master theorem doesn't apply (gap) | recursion tree to guess, substitution to verify |
| Sliding a pattern over a sequence, or "all pairs summing to `k`" | convolution → FFT ([M23](M23-matrix-fft.md)) |
| Recursion drops by 1 each call | `T(n) = T(n−1) + f(n)` — sum, don't use the master theorem |
| Recursion into overlapping subproblems | **not** D&C — dynamic programming ([M11](M11-dynamic-programming.md)) |

---

## Common Mistakes Recap

1. Using the master theorem when subproblem sizes differ (use Akra–Bazzi or a recursion tree).
2. Forgetting the **polynomial** separation requirement in cases 1 and 3 — e.g. claiming case 1 for `2T(n/2) + n/lg n`.
3. Skipping the **regularity condition** in case 3.
4. Applying the master theorem to `T(n) = T(n−1) + f(n)`, which is not of the form `aT(n/b) + f(n)`.
5. Asymptotic notation inside a substitution hypothesis.
6. Proving the goal `O(n)` instead of the hypothesis `≤ cn`.
7. *Adding* a lower-order term when the induction won't close, instead of subtracting.
8. Bounding an unbalanced tree's leaves by the enclosing complete binary tree.
9. `(lo + hi)/2` overflow.
10. Mixing `[lo, hi]` and `[lo, hi)` conventions inside one binary search.
11. Counting multiplication-by-a-power-of-the-base as a real multiplication in Karatsuba.
12. Initialising the crossing sums to `0` rather than `−∞` in max-subarray.
13. No small-case cutoff in Karatsuba/Strassen — the constant factor eats the asymptotic win.
14. Partitioning parallel work by equal index ranges when per-item cost grows.
15. Copying submatrices instead of using index calculations (matters for cheaper block operations).

---

## Self-Test

1. State the three D&C steps and the condition under which D&C beats the direct method. *(§1)*
2. What makes a recurrence "algorithmic", and what three conveniences does that buy you? *(§1)*
3. Write `lower_bound` from memory. Why the half-open interval? Prove it terminates. *(§2)*
4. How do you count occurrences of a key in a sorted array in `O(log n)` when the array might be all one key? *(§2)*
5. Describe one-sided binary search and give its comparison count. *(§2)*
6. Why is binary search inherently sequential, and how did Skiena parallelize it? *(§3)*
7. Prove `T(n) = 2T(⌊n/2⌋) + Θ(n)` is `O(n lg n)` by substitution, including the base case. *(§4)*
8. Show that `T(n) ≤ cn` fails for `T(n) = 2T(n/2) + Θ(1)`, then fix it. Why **subtract**? *(§4)*
9. Give the two substitution fallacies and expose each with an explicit constant. *(§4)*
10. For `T(n) = 3T(n/4) + Θ(n²)`: draw the tree, give per-level cost, leaf count, and total. *(§5)*
11. For `T(n) = T(n/3) + T(2n/3) + Θ(n)`: give the height, the internal cost, and the correct leaf count. Why is the complete-binary-tree bound wrong? *(§5)*
12. State all three master cases including the fine print. What is the watershed function? *(§6)*
13. Give the two gaps where the master theorem fails, with an example of each. *(§6)*
14. Solve `T(n) = T(n/5) + T(7n/10) + n` by Akra–Bazzi without computing `p` exactly. *(§7)*
15. What is the polynomial-growth condition, roughly, and what does it buy you? *(§7)*
16. Derive Karatsuba's three products and show `q₁ − q₀ − q₂` gives the cross terms. State the recurrence and exponent. *(§8)*
17. Why is `T(n) = 8T(n/2) + Θ(1)` cubic while `T(n) = 2T(n/2) + Θ(n)` is `n log n`? *(§9)*
18. State Strassen's recurrence and its solution. How many multiplications and additions? What `k` would you need for `3×3` blocks to beat it? *(§9)*
19. Give the left/right/straddle recurrence for max subarray, and say why Kadane is preferred. *(§10)*
20. Why can't `Θ(n²)` all-pairs work be sped up by more than `p` with `p` processors? *(§11)*
21. What went wrong in the "Going Nowhere Fast" war story, and what is the fix? *(§11)*
22. Name four problems that are secretly convolutions. *(§12)*

---

*Previous: [M02 — Asymptotics](M02-asymptotics.md) · Next: [M04 — Randomization & Probabilistic Analysis](M04-randomization.md)*
