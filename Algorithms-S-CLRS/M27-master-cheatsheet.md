# Module 27 — Master Cheat Sheet & Recognition Playbook

**Sources:** cross-module synthesis of [M01](M01-foundations.md)–[M26](M26-geometry.md) · Skiena 3e ch. 13 (*How to Design Algorithms*, §13.1 *Preparing for Tech Company Interviews*), ch. 14 (*A Catalog of Algorithmic Problems* — how to use it) · CLRS 4e (the complexity results, consolidated)

> **What this module is.** Not a new topic — the last one. Twenty-six modules of material compressed into what you would want in front of you the night before an interview, at the start of a design problem, or six months from now when the details have faded but you need to remember *which door to open*. Everything here links back to where it is derived.
>
> **How to use it.** Read Part 1 once for the map. Then use Parts 2 and 3 as lookup tables — you are meant to scan them, not read them. Part 4 is what to do at a whiteboard. Part 5 is the list of ways these notes' own code was wrong before testing caught it, which is the most useful page in the whole archive.

---

## Big Idea

**Skiena opens *How to Design Algorithms* with a story that is the right frame for all of this.**

> *"This list of questions was inspired by a passage in **The Right Stuff** — a wonderful book about the US space program. It concerned the radio transmissions from test pilots just before their planes crashed. One might have expected that they would panic… Instead, **the pilots ran through a list of what their possible actions could be.** 'I've tried the flaps. I've checked the engine. Still got two wings. I've reset the—.' They had the right stuff. Because of this, **they sometimes managed to miss the mountain.**"*

> *"**Too many people freeze up in their thinking when faced with a design problem.** After reading or hearing the problem, they sit down and realize that they don't know what to do next. **Avoid this fate.** Follow the sequence of questions I provide below."*

**The point of these notes is not that you will remember every algorithm. It is that when you are stuck, you have a list.**

**Three lists, in fact, and the whole module is these three:**

1. **A recognition list** — *what does this problem look like?* Sorted input, an ordering to exploit, repeated queries, overlapping subproblems, a graph hiding in the phrasing. (Part 2)
2. **A paradigm list** — *what tools does that shape unlock?* And in what order to try them. (Part 1, Part 4)
3. **A failure list** — *how does the thing I just wrote break?* Off-by-one, overflow, the degenerate input, the comparator that is not a strict weak ordering. (Part 5)

**And one meta-technique that outranks all of them, because it is what caught every real bug in this archive:**

> **Write the slow, obviously-correct version. Run both on random inputs. Compare.**

Twelve genuine bugs in these notes were found that way — a wrong span in a fork-join trace, an offline oracle too weak to reach a published figure, an adversary that had quietly stopped adversing, a hull algorithm that failed on one grid input in five. **Not one of them was found by reading the code.** Part 5 is the catalogue.

**Remember months later:** *Sort first. Ask what the loop writes before parallelising it. Ask what the recursion recomputes before memoising it. Every `Θ(n lg n)` is a sort or a balanced tree; every `Θ(n)` amortized is a potential function; every "is this optimal?" is an exchange argument or a cut. When it looks hard, check whether it is `NP`-complete before trying harder — and if it is, approximate, restrict, or search. **And test against a brute-force oracle, because you cannot see your own bugs.***

---

## Part 1 — The Paradigm Map

**Nine design paradigms cover essentially everything in these notes. This is what each one *is*, when it applies, and what it costs.**

| paradigm | the move | applies when | typical cost | module |
|---|---|---|---|---|
| **Sort and scan** | impose an order, then one pass | order makes the answer local | `Θ(n lg n)` | [M05](M05-sorting.md) |
| **Divide & conquer** | split, recurse, combine | subproblems are independent | master theorem | [M03](M03-divide-conquer.md) |
| **Dynamic programming** | subproblems **overlap** — cache them | optimal substructure + overlap | states × transitions | [M11](M11-dynamic-programming.md) |
| **Greedy** | take the locally best, never reconsider | the greedy-choice property holds | `Θ(n lg n)` after sorting | [M12](M12-greedy.md) |
| **Data structure design** | pay once to make queries cheap | the same query, many times | build + query | [M06](M06-elementary-ds.md)–[M10](M10-union-find.md) |
| **Graph modelling** | make the objects vertices, relations edges | anything with "connected", "reachable", "depends on" | traversal or flow | [M13](M13-graphs-traversal.md)–[M16](M16-network-flow.md) |
| **Randomization** | flip a coin to defeat the adversary | worst case is structured, average is fine | expected bounds | [M04](M04-randomization.md) |
| **Search with pruning** | enumerate, but prune early | exponential but the tree is thin | branch and bound | [M17](M17-backtracking.md) |
| **Reduction** | turn it into a problem you solved | it *is* another problem in disguise | translation cost | [M19](M19-np-completeness.md) |

**The order to try them in, which is Skiena's order and not an accident:**

```
1.  Understand the problem exactly.        ← most failures happen here
2.  Write brute force.                     ← now you have a correct oracle
3.  Is it in the catalog?                  ← someone solved it in 1978
4.  Can I sort my way out of it?           ← the cheapest win there is
5.  Is there structure?  order → DP, independence → D&C, exchange → greedy
6.  Are there repeated queries?            ← a data structure, not an algorithm
7.  Is it a graph?                         ← more problems are than look it
8.  Is it NP-hard?                         ← check BEFORE trying harder
9.  If hard: approximate / restrict / search / randomize
```

### Dynamic programming vs greedy vs divide and conquer

**The three get confused, and the distinction is precise:**

| | subproblems overlap? | need all of them? | decision is |
|---|---|---|---|
| **divide & conquer** | no | yes | structural (split in half) |
| **dynamic programming** | **yes** | yes — try every choice | *after* solving subproblems |
| **greedy** | yes | **no — one choice suffices** | *before* solving subproblems |

> **The test for greedy, from [M12](M12-greedy.md):** *can you prove that some locally optimal choice is contained in **some** globally optimal solution?* That is the **greedy-choice property**, and it is proved by an **exchange argument** — take an optimal solution, swap in the greedy choice, show it is no worse. **If you cannot write that proof, you do not have a greedy algorithm; you have a heuristic.** ([M20](M20-heuristics.md) is where heuristics live, and they come with approximation ratios instead of proofs.)

### The recurrence toolkit ([M03](M03-divide-conquer.md))

```
T(n) = a·T(n/b) + f(n)      compare f(n) against n^(log_b a):
   f smaller polynomially   → Θ(n^(log_b a))       leaves dominate
   f equal (× lg^k n)       → Θ(n^(log_b a) lg^(k+1) n)
   f larger polynomially    → Θ(f(n))              root dominates  (+ regularity)
```

| recurrence | solution | where |
|---|---|---|
| `T(n) = 2T(n/2) + Θ(n)` | `Θ(n lg n)` | merge sort, closest pair |
| `T(n) = 2T(n/2) + Θ(1)` | `Θ(n)` | tree traversal |
| `T(n) = T(n/2) + Θ(1)` | `Θ(lg n)` | binary search |
| `T(n) = T(n−1) + Θ(n)` | `Θ(n²)` | worst-case quicksort |
| `T(n) = 7T(n/2) + Θ(n²)` | `Θ(n^lg 7)` | Strassen |
| `T(n) = 2T(n/2) + Θ(n lg n)` | `Θ(n lg²n)` | (case 2, `k = 1`) |
| `T(n) = T(n/5) + T(7n/10) + Θ(n)` | `Θ(n)` | median of medians |
| `T(n) = T(3n/4) + Θ(lg n)` | `Θ(lg²n)` | parallel merge span |

---

## Part 2 — The Recognition Playbook

**The single most useful page here. Scan the left column; the right column is where to go.**

### Phrasing → technique

| the problem says… | reach for | module |
|---|---|---|
| "sorted", "in order", "k-th smallest" | **sort first**, or a heap, or quickselect | [M05](M05-sorting.md) |
| "how many pairs such that…" | sort + two pointers, or a BIT/merge-sort count | [M05](M05-sorting.md), [M08](M08-search-trees.md) |
| "the maximum/minimum over all ways to…" | **DP** — define the state, then the transition | [M11](M11-dynamic-programming.md) |
| "count the number of ways" | DP, same state, sum instead of max | [M11](M11-dynamic-programming.md) |
| "is it possible to…" | DP over reachable states, or a flow/matching | [M11](M11-dynamic-programming.md), [M16](M16-network-flow.md) |
| "longest / shortest subsequence" | DP on prefixes — `O(n²)`, or `O(n lg n)` for LIS | [M11](M11-dynamic-programming.md) |
| "substring" (contiguous!) | sliding window, or a suffix structure | [M18](M18-strings.md) |
| "the best schedule / the most activities" | **greedy** — sort by finish time, prove by exchange | [M12](M12-greedy.md) |
| "minimum total cost to connect everything" | **MST** | [M14](M14-mst.md) |
| "shortest path", non-negative weights | **Dijkstra** | [M15](M15-shortest-paths.md) |
| "shortest path", negative weights | **Bellman–Ford** — and it detects negative cycles | [M15](M15-shortest-paths.md) |
| "shortest path between all pairs" | **Floyd–Warshall**, `Θ(V³)` | [M15](M15-shortest-paths.md) |
| "shortest path", unweighted | **BFS** | [M13](M13-graphs-traversal.md) |
| "maximum matching", "assign A to B" | **bipartite matching** = max flow | [M16](M16-network-flow.md) |
| "the bottleneck", "the minimum cut" | **max-flow = min-cut** | [M16](M16-network-flow.md) |
| "in what order must these be done" | **topological sort** | [M13](M13-graphs-traversal.md) |
| "are these two in the same group" | **union-find** | [M10](M10-union-find.md) |
| "have I seen this before" | **hash table** | [M07](M07-hashing.md) |
| "the largest so far", "the next one to process" | **heap** | [M05](M05-sorting.md), [M06](M06-elementary-ds.md) |
| "range query", "prefix sum", "k-th in range" | BIT / segment tree / augmented BST | [M08](M08-search-trees.md) |
| "try all combinations" | **backtracking** with pruning | [M17](M17-backtracking.md) |
| "find the pattern in the text" | KMP / Z / Rabin–Karp / suffix automaton | [M18](M18-strings.md) |
| "the answer is a real number, minimise it" | **gradient descent**, or ternary search if unimodal | [M25](M25-machine-learning.md) |
| "group these, no labels given" | `k`-means, or MST + cut long edges | [M25](M25-machine-learning.md), [M26](M26-geometry.md) |
| "left of / right of / inside / do they cross" | the **orientation predicate** | [M26](M26-geometry.md) |
| "the shape or extent of these points" | **convex hull** | [M26](M26-geometry.md) |
| "do any of these `n` shapes overlap" | **sweep line** | [M26](M26-geometry.md) |
| "decide now, the input keeps coming" | **online** — measure by competitive ratio | [M24](M24-parallel-online.md) |
| "make it run on many cores" | **fork-join**; work vs span, and watch the writes | [M24](M24-parallel-online.md) |
| "modulo a prime", "very large integers" | modular arithmetic, fast exponentiation | [M21](M21-number-theory.md) |
| "maximise subject to linear constraints" | **linear programming**; the dual is the certificate | [M22](M22-linear-programming.md) |
| "multiply these polynomials / convolve" | **FFT** | [M23](M23-matrices-fft.md) |
| it smells exponential and nothing works | check if it is **`NP`-complete** — then approximate | [M19](M19-np-completeness.md), [M20](M20-heuristics.md) |

### Constraints → intended complexity

**Interviewers and judges pick `n` to tell you the answer. Read it.**

| `n` up to | budget (≈10⁸ ops/s) | intended solution |
|---|---|---|
| `10–12` | `n!` | permutations, brute force |
| `15–25` | `2ⁿ` or `2ⁿ·n` | **bitmask DP**, subset enumeration |
| `40–50` | `2^(n/2)` | **meet in the middle** |
| `100–500` | `n³` | Floyd–Warshall, matrix DP, interval DP |
| `1 000–5 000` | `n²` | DP on pairs, all-pairs distances |
| `10⁵–10⁶` | `n lg n` | **sort, heap, BIT, sweep, D&C** |
| `10⁶–10⁷` | `n` | two pointers, counting, one pass |
| `10⁹+` | `lg n` or `√n` | binary search, matrix power, number theory |
| `10¹⁸` | `lg n` | **binary exponentiation, matrix power** |

**Two corollaries worth internalising.** `n = 20` with a subset-shaped problem is *always* bitmask DP. And an `n` of `10⁵` with a quadratic-looking problem means there is a sort or a data structure you have not spotted yet.

### Proof techniques → what they prove

| technique | proves | where |
|---|---|---|
| **loop invariant** | the algorithm is correct | [M01](M01-foundations.md) |
| **induction on subproblem size** | recursive correctness | [M03](M03-divide-conquer.md) |
| **cut-and-paste** | optimal substructure (so DP applies) | [M11](M11-dynamic-programming.md) |
| **exchange argument** | the greedy choice is safe | [M12](M12-greedy.md) |
| **cut property** | the light edge crossing a cut is in some MST | [M14](M14-mst.md) |
| **potential function** | amortized bounds; competitive bounds; convergence | [M09](M09-amortized.md), [M24](M24-parallel-online.md), [M25](M25-machine-learning.md) |
| **decision-tree counting** | comparison lower bounds (`n!` leaves ⟹ `Ω(n lg n)`) | [M05](M05-sorting.md) |
| **adversary argument** | lower bounds against deterministic algorithms | [M24](M24-parallel-online.md) |
| **reduction** | hardness *and* algorithms *and* lower bounds | [M19](M19-np-completeness.md) |
| **duality / certificate** | this solution is optimal, verifiably | [M22](M22-linear-programming.md), [M16](M16-network-flow.md) |
| **linearity of expectation** | expected cost, without independence | [M04](M04-randomization.md) |
| **the probabilistic method** | a good object exists, without constructing it | [M04](M04-randomization.md), [M20](M20-heuristics.md) |

---

## Part 3 — The Complexity Master Table

**Everything in the archive, in one place. `n` = elements, `V`/`E` = vertices/edges, `h` = output size where output-sensitive.**

### Sorting and selection ([M05](M05-sorting.md))

| | best | average | worst | space | stable |
|---|---|---|---|---|---|
| insertion sort | `n` | `n²` | `n²` | `1` | yes |
| merge sort | `n lg n` | `n lg n` | `n lg n` | `n` | yes |
| heapsort | `n lg n` | `n lg n` | `n lg n` | `1` | no |
| quicksort | `n lg n` | `n lg n` | **`n²`** | `lg n` | no |
| randomized quicksort | — | `n lg n` **whp** | `n²` (vanishing) | `lg n` | no |
| counting / radix / bucket | — | `n + k` / `d(n+k)` / `n` | — | `n + k` | yes |
| **comparison lower bound** | | | **`Ω(n lg n)`** | | |
| quickselect | `n` | `n` | `n²` | `1` | — |
| median of medians | `n` | `n` | **`n`** | `lg n` | — |

### Data structures ([M06](M06-elementary-ds.md)–[M10](M10-union-find.md))

| structure | search | insert | delete | notes |
|---|---|---|---|---|
| sorted array | `lg n` | `n` | `n` | binary search |
| hash table (chaining) | `1` expected | `1` | `1` | `Θ(n)` worst case |
| BST (unbalanced) | `h` | `h` | `h` | `h = n` worst case |
| **red-black / AVL** | `lg n` | `lg n` | `lg n` | the default |
| B-tree | `log_t n` | `log_t n` | `log_t n` | disk; `t` large |
| skip list | `lg n` exp. | `lg n` exp. | `lg n` exp. | simpler than RB |
| binary heap | `n` (find) | `lg n` | `lg n` (extract) | `Θ(n)` build |
| Fibonacci heap | — | `1` am. | `lg n` am. | decrease-key `Θ(1)` am. |
| **union-find** (rank + path compression) | | `α(n)` am. | | effectively constant |
| BIT / Fenwick | `lg n` | `lg n` | — | prefix sums |
| segment tree | `lg n` | `lg n` | — | any associative op |
| kd-tree | `lg n` (low `d`) | — | — | **`n` above `d ≈ 20`** |
| trie | `\|s\|` | `\|s\|` | `\|s\|` | alphabet-sized nodes |
| suffix array | `lg n` per query | `n` (build, `n lg n` simple) | — | + LCP array |

### Graphs ([M13](M13-graphs-traversal.md)–[M16](M16-network-flow.md))

| problem | algorithm | cost |
|---|---|---|
| traversal | BFS / DFS | `Θ(V + E)` |
| topological sort | DFS finish order / Kahn | `Θ(V + E)` |
| strongly connected components | Kosaraju / Tarjan | `Θ(V + E)` |
| bridges, articulation points | DFS low-link | `Θ(V + E)` |
| **MST** | Kruskal | `Θ(E lg V)` |
| | Prim + binary heap | `Θ(E lg V)` |
| | Prim + Fibonacci heap | `Θ(E + V lg V)` |
| | Borůvka | `Θ(E lg V)` |
| **shortest path**, non-negative | Dijkstra + binary heap | `Θ((V+E) lg V)` |
| | Dijkstra + Fibonacci heap | `Θ(E + V lg V)` |
| **shortest path**, negative edges | Bellman–Ford | `Θ(VE)` |
| shortest path, DAG | topological relaxation | `Θ(V + E)` |
| **all pairs** | Floyd–Warshall | `Θ(V³)` |
| | Johnson (sparse) | `Θ(V² lg V + VE)` |
| **max flow** | Edmonds–Karp | `Θ(VE²)` |
| | Dinic | `Θ(V²E)`, `Θ(E√V)` unit caps |
| bipartite matching | Hopcroft–Karp | `Θ(E√V)` |
| min-cost flow | successive shortest paths | `Θ(V E² lg V)`-ish |

### Strings ([M18](M18-strings.md))

| problem | algorithm | cost |
|---|---|---|
| single pattern | KMP / Z | `Θ(n + m)` |
| single pattern, expected | Rabin–Karp | `Θ(n + m)` expected |
| many patterns | Aho–Corasick | `Θ(n + m + z)` |
| all palindromic substrings | Manacher | `Θ(n)` |
| suffix array | SA-IS | `Θ(n)` |
| longest common substring | suffix automaton / array | `Θ(n)` |
| edit distance | DP | `Θ(nm)` |

### Hard problems, and coping ([M19](M19-np-completeness.md)–[M20](M20-heuristics.md))

| problem | status | best practical answer |
|---|---|---|
| SAT, 3-SAT | `NP`-complete | CDCL solvers; huge instances in practice |
| vertex cover | `NP`-complete | **2-approx**; FPT in `k` |
| set cover | `NP`-complete | greedy, **`H(n)`-approx**, and that is optimal |
| TSP, metric | `NP`-hard | MST-doubling **2**, Christofides **3/2** |
| TSP, general | `NP`-hard | **no constant ratio** unless `P = NP` |
| knapsack | `NP`-complete | pseudo-poly DP; **FPTAS** |
| subset-sum | `NP`-complete | DP; FPTAS by trimming |
| bin packing | `NP`-hard | first-fit **17/10**, first-fit-decreasing **11/9** |
| graph colouring | `NP`-complete | greedy by degree; DSATUR |
| max-3-SAT | `NP`-hard | random assignment gives **7/8** |
| `k`-means | `NP`-hard | Lloyd + restarts; `9+ε` approx exists |

### Numerical, parallel, geometric ([M21](M21-number-theory.md)–[M26](M26-geometry.md))

| problem | cost |
|---|---|
| gcd (Euclid) | `Θ(lg min(a,b))` |
| modular exponentiation | `Θ(lg n)` multiplications |
| Miller–Rabin primality | `Θ(k lg³n)` |
| Pollard's rho factoring | `Θ(n^(1/4))` expected |
| LU decomposition | `Θ(n³)`; then `Θ(n²)` per solve |
| matrix multiply | `Θ(n³)`; Strassen `Θ(n^2.81)` |
| **FFT / polynomial multiply** | **`Θ(n lg n)`** |
| simplex | exponential worst case, fast in practice |
| interior point | polynomial |
| **`P-MERGE-SORT`** | work `Θ(n lg n)`, span `Θ(lg³n)` |
| `P-MATRIX-MULTIPLY-RECURSIVE` | work `Θ(n³)`, span `Θ(lg²n)` |
| `WEIGHTED-MAJORITY` | `2m* + 4√(m* ln n)` mistakes |
| gradient descent | `T = R²L²/ε²` iterations |
| **convex hull** | **`Θ(n lg n)`**, matching lower bound |
| Delaunay / Voronoi | `Θ(n lg n)` |
| segment intersection (detect) | `Θ(n lg n)` |
| closest pair | `Θ(n lg n)` |

---

## Part 4 — At the Whiteboard

**Skiena's advice is specific, and it is the opposite of what people do under pressure.**

> *"First, I encourage you to **ask enough clarifying questions to make sure you understand exactly what the problem is**. You are likely to get few points for correctly solving the wrong problem. I strongly encourage you to **first present a simple, slow, and correct algorithm before trying to get fancy**. After that you can, and should, see whether you can do better. Usually the questioners want to see **how you think**, and are less concerned with the actual final algorithm than seeing an active thought process."*

> **And a warning that is worth hearing from someone with his standing:** *"Students of mine who take these interviews often report that **they are given incorrect solutions by their interviewers!** Getting a job at a nice company does not turn you into an algorithms expert by osmosis. Often the interviewers are just asking questions that other people asked them, so **don't be intimidated.**"*

### The seven-step loop

```
1. RESTATE the problem in your own words. Get agreement.
2. ASK:   input type and range? duplicates? sorted? negative? empty?
          what exactly is the output? ties? all answers or one?
          is n 10, 10^5, or 10^18?          ← this picks the algorithm
3. EXAMPLE: work one small instance BY HAND. Say what you notice.
4. BRUTE FORCE: state it, give its complexity, say it is correct.
                ← now you have a baseline and an oracle. Never skip this.
5. IMPROVE: name the wasted work, then name the paradigm that removes it.
            "I'm recomputing overlapping subproblems"  → DP
            "I'm re-scanning for the max"              → heap
            "I'm re-testing membership"                → hash set
            "the order doesn't matter but I'm keeping it" → sort or counting
6. CODE it. Say the invariant out loud as you write the loop.
7. TEST:  empty, one element, two, all-equal, already-sorted, reversed,
          maximum size, negative, overflow.   ← walk one through by hand
```

**Step 4 is the one people skip and the one that decides the interview.** A stated brute force converts "I don't know" into "I have a correct `O(n³)`; now let me remove the third loop", which is a conversation instead of a silence.

### Skiena's design questions, condensed

**The full list is his; this is the compression worth memorising:**

1. **Do I really understand the problem?** *"What exactly does the input consist of? What exactly are the desired results? Can I construct an input example small enough to solve by hand? How important is it that I always find the optimal answer — might I settle for something close? How large is a typical instance? How important is speed? Am I trying to solve a numerical problem? A graph problem? A geometric problem? A string problem? A set problem?"*
2. **Can I find a simple algorithm or heuristic?** *"Will brute force solve my problem correctly by searching through all subsets or arrangements? … Can I solve my problem by repeatedly trying some simple rule, like picking the biggest item first?"* — and then: *"on what inputs does this heuristic work badly? **If no such examples can be found, can I show that it always works well?**"*
3. **Is my problem in the catalog?** *"Did I browse through all the pictures? Did I look in the index under all possible keywords?"*
4. **Are there special cases I know how to solve?** *"Does the problem become easier when some input parameters are set to trivial values? … **Why can't this special-case algorithm be generalized?**"*
5. **Which paradigm applies?** *"Is there a set of items that can be sorted by size or some key? … Is there a way to split the problem into two smaller problems? … Does the input have a natural left-to-right order — could I use dynamic programming to exploit it? … Are there certain operations being done repeatedly — can I use a data structure? … Can I use random sampling? … Can I formulate my problem as a linear program? … Does my problem resemble satisfiability or the travelling salesman problem?"*
6. **Am I still stumped?** *"Go back to the beginning and work through these questions again. **Did any of my answers change during my latest trip through the list?**"*

### Using the catalog ([Skiena Part II](M26-geometry.md#part-6--how-to-use-the-catalog))

> *"**First, think about your problem.** If you recall the name, look up the catalog entry… **Leaf through the catalog, looking at the pictures and problem names to see if anything strikes a chord.** Don't be afraid to use the index, for every problem in the book is listed there under several possible keywords and applications."*

**And the field that is the actual product:** *"Once you have identified your problem, the discussion section tells you what you should do about it… **For each problem, a quick-and-dirty solution is outlined, with pointers to more powerful algorithms to try if the first attempt is not sufficient.**"*

### On the screening round

> *"The major tech companies attract so many applications that the first round of screening is often mechanical… **These programming challenge problems test coding speed and correctness.** … performance on these problems **improves with practice**. … figure out whether your weak spot is in the **correctness of boundary cases** or **errors in your algorithm itself**, and then work to improve."*

**That diagnostic is worth taking literally.** Keep a log of failed submissions and label each one *algorithm* or *boundary*. They need completely different practice, and most people have a strong bias toward one.

---

## Part 5 — Every Bug These Notes Actually Had

**This is the most useful section in the archive, and the only one that could not have been written without running the code.**

**Every implementation in these 27 modules was checked against a brute-force oracle on randomized inputs. Twelve genuine bugs surfaced. Not one was found by reading the code — several had been read many times.** Here they all are, grouped by the failure mode, because the *patterns* generalise even when the algorithms do not.

### Pattern 1 — The oracle was wrong

| bug | how it surfaced |
|---|---|
| **The offline `FORESEE` oracle only moved the *searched* element** ([M24](M24-parallel-online.md)), so it scored CLRS Figure 27.1 at 14 instead of the published 13. A too-weak oracle makes the online algorithm look *better* than it is. | **Reproducing a published figure.** No random test would have caught it — the bound still held, just too easily. |
| **The `Ω(k)` caching adversary evicted by overwriting a slot**, destroying the insertion order its own eviction rule depended on ([M24](M24-parallel-online.md)). The simulated policy silently stopped being the policy under test and LRU sailed through at ratio 1.11 instead of 7.89. | **A suspiciously good result.** An adversary that stops adversing reports success. |
| **The parametric `double` segment-intersection reference was wrong on zero-length segments** ([M26](M26-geometry.md)) — 25 disagreements in 500 000, every one the *reference's* error. | The exact code disagreeing with the "obvious" reference. **Oracles have degeneracies too.** |

> **The lesson:** *an oracle you did not test is not an oracle.* Check it against a published example, or against a second independently written oracle. [M25](M25-machine-learning.md) does the latter — two separately written offline optima agreeing on 2 000 instances.

### Pattern 2 — Arithmetic that silently wrapped

| bug | how it surfaced |
|---|---|
| **`((a % m) + m) % m` overflows** when `m` is near `2⁶³` ([M21](M21-number-theory.md)) — `a + m` exceeds `LLONG_MAX`. | Only the large-modulus test caught it; every small-modulus test passed. |
| **Comparing two angles as exact rationals overflowed at ~10²¹** ([M26](M26-geometry.md)), producing a "measurement" showing the Delaunay triangulation with a *worse* minimum angle than the one it improved. | **Contradicting a theorem.** 185 apparent regressions in 3 000; `__int128` took it to 0. |
| **`incircle` is degree 4, `orient` is degree 2** ([M26](M26-geometry.md)) — the same `long long` is safe to `2³¹` for one and `2¹⁵` for the other. | Knowing the *degree* of the predicate is the whole discipline. |

> **The lesson:** *know the degree of every polynomial predicate, and compute its overflow budget before you need it.* Signed overflow is undefined behaviour, not wraparound — the optimizer may delete your after-the-fact check.

### Pattern 3 — The degenerate input

| bug | how it surfaced |
|---|---|
| **The Graham scan's collinear tie-break was backwards** ([M26](M26-geometry.md)). "Reverse the final collinear run" is right for a `< 0` pop and wrong for a `<= 0` pop — **wrong on 19.9% of grid inputs and 0.00% of wide-range random ones.** | Half the test inputs drawn from a tight grid. With random real-valued points it never fires. |
| **`incrementalTriangulation` emitted duplicate zero-area triangles** on collinear input ([M26](M26-geometry.md)), because `< 0` popped on a *straight* turn from both chains. | **The areas failing to sum to the hull area** — an invariant no count-based check would notice. |
| **`grahamScan` did not deduplicate**, so three identical points returned a two-vertex "hull". | Inputs with exact duplicates, which a small coordinate range produces constantly. |
| **The shortest-path LP is unbounded unless every vertex is reachable from `s`** ([M22](M22-linear-programming.md)) — a precondition neither book states. | 2 034 of 3 000 random graphs failing before the precondition was understood. |

> **The lesson:** *test on a tight integer grid, not on wide random values.* Skiena says it plainly: *"interesting data often comes from points sampled on a grid, which tends to be highly degenerate."* Duplicates, collinearity, ties and empties are where the code is wrong, and wide random inputs never produce them.

### Pattern 4 — The analysis, not the algorithm

| bug | how it surfaced |
|---|---|
| **`fibTrace` counted a spawn and a call the same way** ([M24](M24-parallel-online.md)), reporting span 10 for `P-FIB(4)` where CLRS Figure 26.2 says 8. A spawn puts 2 parent strands on the child's path; a call puts 3. | **Disagreeing with a published figure.** The work was right; only the span was wrong. |
| **`euclidCallCount` was off by one** ([M21](M21-number-theory.md)) — it returned `calls − 1`. | CLRS's own sentence *"this computation calls EUCLID recursively three times"* for `gcd(30,21)`. |
| **A "3n/4 bound" claimed without instrumenting it** ([M24](M24-parallel-online.md)) — measured at exactly 0.7500, attained and never exceeded; and deleting the load-balancing `if` pushed it to 0.9998, about **1 400× more recursion levels**. | Measuring a bound instead of quoting it. |

> **The lesson:** *published figures are test cases.* Every worked example in CLRS and Skiena is a free unit test with a known answer, and three of these bugs were found by exactly one of them.

### Pattern 5 — The claim that was simply false

| bug | how it surfaced |
|---|---|
| **`dfsTreeVertexCover` was not a DFS** ([M20](M20-heuristics.md)) — marking visited at *push* time yields a tree with cross edges, so the "every non-leaf is a cover" argument fails. | The first test graph containing a triangle. |
| **Simplex Phase II could pivot an artificial variable back into the basis** ([M22](M22-linear-programming.md)), leaving `basic_[i] == -1` and indexing `result.x[-1]`. | A heap-corruption abort — the *good* outcome, since silent corruption is the alternative. |
| **The claimed matmul loop-order speedup was 2.9×; measured 1.1×** at `n = 256` ([M23](M23-matrices-fft.md)). | Measuring rather than repeating folklore. Re-measured at `n = 512` → 1.5×. |
| **Exercise 33.2-1's stated bound `m ≤ m*⌈lg n⌉` is false** ([M25](M25-machine-learning.md)) — it fails on 6% of random instances. The provable form is `(m*+1)(⌈lg n⌉+1)`. | Testing an exercise's claim instead of assuming it. |

> **The lesson:** *"I am sure this is right" is not evidence.* Every `*Verified:*` line in these notes exists because at least once the number in it was different from the number that had been written there first.

### The harness that found all of them

**One pattern, reusable everywhere:**

```
for many random inputs:
    generate a SMALL input   (small enough that brute force is fast,
                              and that degenerate cases actually occur)
    run the real algorithm
    run the brute-force oracle
    compare
    on mismatch: PRINT THE INPUT and stop
```

**Four design rules that make it work, each of which was learned the hard way above:**

1. **Small inputs, not large ones.** `n ≤ 8` with values in `[0, 3]` produces ties, duplicates and collinearity on nearly every trial. `n = 10⁶` random doubles produces none of them, ever.
2. **Check invariants, not just outputs.** Areas summing to the hull area, a potential staying non-negative, `f` decreasing monotonically — these catch structural corruption that a spot-check of the final answer sails past.
3. **Test the claim, not the code.** "This is 2-competitive", "this maximises the minimum angle", "this needs `⌈lg n⌉` mistakes" — assert the *bound*, on every run, against a real optimum.
4. **Delete a line and confirm it breaks.** The erase-time neighbour test in the sweep (0.81% false negatives), the strict tie-break in Lloyd's procedure, the temporary `D` in parallel matrix multiply (990/1 000 wrong). *If removing it changes nothing, it was not doing anything.*

→ **C++ implementation:** [The differential testing harness](#the-differential-testing-harness)

---

## Part 6 — The Thirty Things Worth Knowing Cold

**If you remember nothing else.**

1. **`Θ(n lg n)` is a sort or a balanced tree.** There is no third source.
2. **Sort first.** It makes search, uniqueness, closest pair, mode, selection and convex hull easy.
3. **The comparison lower bound is `Ω(n lg n)`,** and it comes from `n!` leaves in a decision tree. Step outside the model (counting, radix) and you break it — at the price of assumptions about the keys.
4. **Binary search needs a monotone predicate,** not a sorted array. That generalisation — "binary search the answer" — is worth more than the array version.
5. **Hash tables are `Θ(1)` expected and `Θ(n)` worst case.** Balanced trees are `Θ(lg n)` always, and keep order.
6. **A heap is `Θ(n)` to build, `Θ(lg n)` to update.** Building by repeated insertion is `Θ(n lg n)` and unnecessary.
7. **Amortized ≠ average.** Amortized is a worst-case guarantee over a sequence; no probability is involved.
8. **Union-find is `α(n)` amortized** with union by rank *and* path compression. Either alone is `Θ(lg n)`.
9. **DP = optimal substructure + overlapping subproblems.** Without overlap you have divide and conquer; without substructure you have nothing.
10. **Write the recurrence before the code.** The state *is* the algorithm.
11. **Greedy needs an exchange argument.** No proof, no greedy — you have a heuristic, and heuristics come with ratios instead.
12. **BFS gives shortest paths only in unweighted graphs.** Dijkstra needs non-negative weights. Bellman–Ford handles negatives *and* detects negative cycles.
13. **Dijkstra fails on negative edges, and *how* it fails depends on the implementation.** With a `visited`/finalized set — the textbook version every correctness proof is about — it is **wrong**, silently: measured wrong on 0.7% of random negative-edge graphs, and on the three-vertex counterexample `s→a = 1`, `s→b = 2`, `b→a = −2`. With lazy deletion and no finalized set (the variant in [M15](M15-shortest-paths.md)) it stays **correct** but degrades toward Bellman-Ford's cost. *Wrong or slow; neither is what you want — use Bellman-Ford, or reweight with Johnson.*
14. **The MST cut property:** the minimum-weight edge crossing any cut is in some MST. Kruskal and Prim are two ways of applying it.
15. **Max-flow = min-cut**, and the min cut is a *certificate* — a checkable proof of optimality.
16. **Bipartite matching is max flow.** So is vertex-disjoint paths, so is much of scheduling.
17. **Modelling is the hard part of graph problems.** Most problems that mention "connected", "depends on", "assign", or "reachable" are graph problems in disguise.
18. **Backtracking is DFS on a state space.** The pruning is the algorithm; the enumeration is bookkeeping.
19. **`NP`-complete means: no polynomial algorithm known, and one would settle `P = NP`.** It does not mean unsolvable — it means *choose* which of optimality, generality or speed to give up.
20. **To prove hardness, reduce a known-hard problem TO yours.** The direction is the whole thing, and reversing it proves nothing.
21. **Reductions also build algorithms and transfer lower bounds** — sorting → convex hull gives `Ω(n lg n)` for hulls.
22. **A 2-approximation is often five lines,** and knowing the ratio is what separates it from a guess.
23. **Randomization defeats the adversary, not the input.** The guarantee is over your coin flips, and it evaporates against an adversary who sees them.
24. **The potential function is the universal tool** for anything with uneven per-step cost — amortized analysis, competitive analysis, gradient descent convergence.
25. **Work adds; span maxes.** Parallelism is `T₁/T∞`, and no machine can beat it.
26. **Before parallelising a loop, ask what it writes.** Two strands writing one location is a race, and a race is a bug that usually works.
27. **Competitive ratio is a ratio against a clairvoyant opponent,** which normalises away how hard the input intrinsically is.
28. **"Spend up to what the alternative costs, then switch"** is 2-competitive, and it is the single most reused idea in online algorithms.
29. **One determinant — the signed triangle area — is half of planar geometry.** Use integers so its sign is exact.
30. **Test against a brute-force oracle.** You cannot see your own bugs. Twelve in this archive say so.

---

## Common Mistakes

- **Optimising before you have a correct version.** You have nothing to compare against, and no oracle.
- **Reaching for the fancy algorithm.** `n = 500` does not need a suffix automaton.
- **Not reading the constraints.** `n ≤ 20` is telling you the answer is `2ⁿ`.
- **Using average-case reasoning where the worst case matters,** or the reverse. Hash tables are `Θ(1)` expected; a real-time system may not accept that.
- **Confusing amortized with average.** One is a worst-case guarantee, the other is a probabilistic one.
- **Applying Dijkstra to negative edges.** It fails silently.
- **Forgetting that greedy needs proof.** Most greedy algorithms people invent are wrong, and the exchange argument is how you find out.
- **Writing a DP without writing the recurrence.** The bugs are all in the state definition.
- **Ignoring integer overflow.** Know the degree of your expression and its budget.
- **Comparing floating-point values with `==`,** or using an absolute epsilon where a relative one is needed.
- **Writing a comparator that is not a strict weak ordering.** `std::sort` will walk off the end of the array — undefined behaviour, not a wrong answer.
- **Testing only on large random inputs.** They contain no ties, no duplicates, no degeneracies. All the bugs are there.
- **Trusting an oracle you did not test.** Three bugs above were in the *reference*.
- **Believing a bound because a book states it.** Two exercise bounds in these notes are false as literally written.
- **Assuming a passing test suite means no race.** *"You can run tests in the lab for days without a failure."* Use a race detector.
- **Not stating the brute force in an interview.** It converts silence into a conversation.
- **Solving the wrong problem well.** *"You are likely to get few points for correctly solving the wrong problem."*

---

## One-Page Recall

**The loop.** Understand → brute force → is it in the catalog → sort → find the structure → data structure → is it a graph → is it `NP`-hard → approximate.

**Paradigms.** Sort & scan · divide & conquer · DP · greedy · data structures · graph modelling · randomization · search with pruning · reduction.

**The three cousins.** D&C: independent subproblems. DP: overlapping, decide *after*. Greedy: overlapping, decide *before* — needs an exchange argument.

**Master theorem.** `T(n) = aT(n/b) + f(n)`; compare `f` with `n^(log_b a)`; leaves / tie / root.

**Constraints read backwards.** `20 → 2ⁿ` · `50 → 2^(n/2)` · `500 → n³` · `5 000 → n²` · `10⁶ → n lg n` · `10⁷ → n` · `10¹⁸ → lg n`.

**Proof techniques.** Loop invariant · induction · cut-and-paste · exchange · cut property · potential function · decision-tree counting · adversary · reduction · duality · linearity of expectation.

**Graphs.** BFS/DFS `Θ(V+E)` · MST `Θ(E lg V)` · Dijkstra `Θ((V+E) lg V)` · Bellman–Ford `Θ(VE)` · Floyd `Θ(V³)` · Dinic `Θ(V²E)` · Hopcroft–Karp `Θ(E√V)`.

**Certificates.** Min cut certifies max flow. The LP dual certifies the primal. A verifier certifies `NP`. **When you can hand someone a proof of optimality, do.**

**Coping with hard.** Approximate (with a ratio) · restrict the input · exponential-but-pruned search · heuristics with restarts · accept `ε` error.

**Online and parallel.** Competitive ratio against a clairvoyant · potential functions again · work adds, span maxes · ask what the loop writes.

**Geometry.** One determinant, exact on integers. Sort then sweep.

**And the meta-rule.** *Write the slow correct version. Run both on small random inputs. Compare. Delete a line and confirm it breaks.*

**Self-test.**

1. Name the nine paradigms and one problem each.
2. Given `n ≤ 22` and a subset-shaped problem, what is the intended solution?
3. State the master theorem's three cases and the regularity condition.
4. What exactly distinguishes DP from divide and conquer? From greedy?
5. What must you prove to use a greedy algorithm, and how?
6. Why does Dijkstra fail on negative edges? Give a three-vertex example.
7. State the cut property and derive both Kruskal and Prim from it.
8. What does a min cut certify, and why is that useful?
9. Which direction do you reduce to prove hardness? What does the other direction prove?
10. Give three reductions that produce algorithms rather than hardness proofs.
11. What is a potential function, and name four places these notes use one.
12. Amortized vs average vs expected — define each.
13. Why is `α(n)` effectively constant, and what two heuristics produce it?
14. What is a competitive ratio, and why divide by the offline optimum?
15. Work, span, parallelism, speedup, slackness — define all five.
16. Why can't the `k` loop in `P-MATRIX-MULTIPLY` be parallel?
17. State the comparison lower bound and its proof in one sentence.
18. Give the signed-area determinant and its three interpretations.
19. Name four bugs from Part 5 and say what caught each.
20. Design a differential test for an algorithm you wrote today.

---

## Practice — the consolidated drill list

**Every problem in these notes, ranked by how often it earns its keep. All slugs verified against live search.**

### The twelve that matter most

| # | problem | what it drills | module |
|---|---|---|---|
| 1 | [146 · LRU Cache](https://leetcode.com/problems/lru-cache/) | hash map + list; **the most-asked problem in the archive** | [M07](M07-hashing.md), [M24](M24-parallel-online.md) |
| 2 | [56 · Merge Intervals](https://leetcode.com/problems/merge-intervals/) | the sweep, in its simplest form | [M26](M26-geometry.md) |
| 3 | [206 · Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/) | pointer discipline; the baseline warm-up | [M06](M06-elementary-ds.md) |
| 4 | [200 · Number of Islands](https://leetcode.com/problems/number-of-islands/) | BFS/DFS on an implicit graph | [M13](M13-graphs-traversal.md) |
| 5 | [207 · Course Schedule](https://leetcode.com/problems/course-schedule/) | topological sort = cycle detection | [M13](M13-graphs-traversal.md) |
| 6 | [300 · Longest Increasing Subsequence](https://leetcode.com/problems/longest-increasing-subsequence/) | DP `O(n²)` **and** the `O(n lg n)` patience version | [M11](M11-dynamic-programming.md) |
| 7 | [53 · Maximum Subarray](https://leetcode.com/problems/maximum-subarray/) | Kadane; the smallest real DP | [M11](M11-dynamic-programming.md) |
| 8 | [215 · Kth Largest Element in an Array](https://leetcode.com/problems/kth-largest-element-in-an-array/) | quickselect vs heap — know both costs | [M05](M05-sorting.md) |
| 9 | [1584 · Min Cost to Connect All Points](https://leetcode.com/problems/min-cost-to-connect-all-points/) | MST on a complete geometric graph | [M14](M14-mst.md), [M26](M26-geometry.md) |
| 10 | [743 · Network Delay Time](https://leetcode.com/problems/network-delay-time/) | Dijkstra, plainly | [M15](M15-shortest-paths.md) |
| 11 | [42 · Trapping Rain Water](https://leetcode.com/problems/trapping-rain-water/) | three correct solutions at three complexities | [M05](M05-sorting.md), [M09](M09-amortized.md) |
| 12 | [218 · The Skyline Problem](https://leetcode.com/problems/the-skyline-problem/) | the sweep at full difficulty | [M26](M26-geometry.md) |

### By module

| module | problems |
|---|---|
| [M05](M05-sorting.md) Sorting | [215 Kth Largest](https://leetcode.com/problems/kth-largest-element-in-an-array/) · [912 Sort an Array](https://leetcode.com/problems/sort-an-array/) · [75 Sort Colors](https://leetcode.com/problems/sort-colors/) |
| [M07](M07-hashing.md) Hashing | [1 Two Sum](https://leetcode.com/problems/two-sum/) · [146 LRU Cache](https://leetcode.com/problems/lru-cache/) · [128 Longest Consecutive Sequence](https://leetcode.com/problems/longest-consecutive-sequence/) |
| [M08](M08-search-trees.md) Search trees | [98 Validate BST](https://leetcode.com/problems/validate-binary-search-tree/) · [307 Range Sum Query — Mutable](https://leetcode.com/problems/range-sum-query-mutable/) |
| [M09](M09-amortized.md) Amortized | [155 Min Stack](https://leetcode.com/problems/min-stack/) · [84 Largest Rectangle in Histogram](https://leetcode.com/problems/largest-rectangle-in-histogram/) |
| [M10](M10-union-find.md) Union-find | [547 Number of Provinces](https://leetcode.com/problems/number-of-provinces/) · [684 Redundant Connection](https://leetcode.com/problems/redundant-connection/) |
| [M11](M11-dynamic-programming.md) DP | [300 LIS](https://leetcode.com/problems/longest-increasing-subsequence/) · [53 Max Subarray](https://leetcode.com/problems/maximum-subarray/) · [72 Edit Distance](https://leetcode.com/problems/edit-distance/) · [416 Partition Equal Subset Sum](https://leetcode.com/problems/partition-equal-subset-sum/) |
| [M12](M12-greedy.md) Greedy | [435 Non-overlapping Intervals](https://leetcode.com/problems/non-overlapping-intervals/) · [621 Task Scheduler](https://leetcode.com/problems/task-scheduler/) |
| [M13](M13-graphs-traversal.md) Traversal | [200 Number of Islands](https://leetcode.com/problems/number-of-islands/) · [207 Course Schedule](https://leetcode.com/problems/course-schedule/) |
| [M15](M15-shortest-paths.md) Shortest paths | [743 Network Delay Time](https://leetcode.com/problems/network-delay-time/) · [787 Cheapest Flights Within K Stops](https://leetcode.com/problems/cheapest-flights-within-k-stops/) |
| [M17](M17-backtracking.md) Backtracking | [51 N-Queens](https://leetcode.com/problems/n-queens/) · [39 Combination Sum](https://leetcode.com/problems/combination-sum/) |
| [M18](M18-strings.md) Strings | [28 Find the Index of the First Occurrence](https://leetcode.com/problems/find-the-index-of-the-first-occurrence-in-a-string/) · [5 Longest Palindromic Substring](https://leetcode.com/problems/longest-palindromic-substring/) |
| [M24](M24-parallel-online.md) Parallel & online | [1114 Print in Order](https://leetcode.com/problems/print-in-order/) · [1226 The Dining Philosophers](https://leetcode.com/problems/the-dining-philosophers/) · [460 LFU Cache](https://leetcode.com/problems/lfu-cache/) |
| [M25](M25-machine-learning.md) ML | [528 Random Pick with Weight](https://leetcode.com/problems/random-pick-with-weight/) · [69 Sqrt(x)](https://leetcode.com/problems/sqrtx/) · [162 Find Peak Element](https://leetcode.com/problems/find-peak-element/) |
| [M26](M26-geometry.md) Geometry | [587 Erect the Fence](https://leetcode.com/problems/erect-the-fence/) · [218 The Skyline Problem](https://leetcode.com/problems/the-skyline-problem/) · [149 Max Points on a Line](https://leetcode.com/problems/max-points-on-a-line/) |

**Beyond LeetCode**

- **[CSES Problem Set](https://cses.fi/problemset/)** — 300 problems organised by exactly the topics of these notes, with no noise. *The single best structured practice available.*
- **[Codeforces](https://codeforces.com/problemset)** — filter by tag and rating; the tags map onto Part 2's recognition table almost one to one.
- **Skiena's own recommendation:** *"I recommend solving some coding problems on judging sites like HackerRank and LeetCode… Start simple and build up your speed, and do it to **have fun**."*

---

## A Study Plan

**Twelve weeks, one module every two or three days, with the last week for recall only.**

| week | modules | focus |
|---|---|---|
| 1 | [M01](M01-foundations.md)–[M03](M03-divide-conquer.md) | correctness, asymptotics, recurrences — the vocabulary |
| 2 | [M04](M04-randomization.md)–[M05](M05-sorting.md) | randomization and sorting; the lower bound |
| 3 | [M06](M06-elementary-ds.md)–[M07](M07-hashing.md) | lists, stacks, queues, hashing |
| 4 | [M08](M08-search-trees.md) | balanced trees, augmentation — the longest module |
| 5 | [M09](M09-amortized.md)–[M10](M10-union-find.md) | amortized analysis, union-find |
| 6 | [M11](M11-dynamic-programming.md) | DP — spend the whole week |
| 7 | [M12](M12-greedy.md)–[M13](M13-graphs-traversal.md) | greedy, graph modelling and traversal |
| 8 | [M14](M14-mst.md)–[M15](M15-shortest-paths.md) | MST, shortest paths |
| 9 | [M16](M16-network-flow.md)–[M17](M17-backtracking.md) | flow, matching, backtracking |
| 10 | [M18](M18-strings.md)–[M19](M19-np-completeness.md) | strings, `NP`-completeness |
| 11 | [M20](M20-heuristics.md)–[M23](M23-matrices-fft.md) | coping with hard problems; the numerical modules |
| 12 | [M24](M24-parallel-online.md)–[M27](M27-master-cheatsheet.md) | parallel, online, ML, geometry, this module |

**How to work a module, which is the part that decides whether any of it sticks:**

1. Read the **Big Idea** and **What You Should Be Able To Do**. Ten minutes.
2. Work the body, following each `→ C++ implementation:` link when the pseudocode stops being obvious.
3. Read the **C++ Toolkit** once.
4. Do **three** practice problems, not the whole table.
5. **Attempt the self-test from memory before re-reading anything.** This is the step that matters, and it is the step everyone skips.
6. Come back in a week and re-do the **One-Page Recall** only.

> **Skiena's warning about cramming is worth quoting exactly**, because it is the argument for the whole plan: *"with respect to algorithm design **people know what they know**, and hence **cramming the night before an interview won't help much**. … Algorithm design techniques **tend to stick with you** after you learn them, so it pays to put in the time."*

---

## C++ Toolkit — The Consolidated Reference

**The language machinery these 27 modules actually depend on, in one place.**

### The differential testing harness

```cpp
// THE MOST REUSABLE THING IN THIS ARCHIVE, and the tool that found every bug
// listed in Part 5. Nothing here is clever; the value is entirely in the four
// design rules, each of which was learned by a test failing to catch something.

// A random source you can seed reproducibly. Seed it ONCE and pass it by
// reference -- a function that constructs its own engine per call returns
// correlated garbage, and the bug looks like an algorithm bug.
mt19937& testEngine() {
    static mt19937 engine(20260910u);                    // fixed: failures reproduce
    return engine;
}
int randomInt(int low, int high) {
    return uniform_int_distribution<int>(low, high)(testEngine());
}

// RULE 1: SMALL INPUTS, NOT LARGE ONES.
//
// n <= 8 with values in [0, 3] produces ties, duplicates, collinear triples and
// empty ranges on nearly every trial. n = 10^6 random doubles produces NONE of
// them, ever -- and every bug in Part 5 lived in exactly those cases.
vector<int> randomSmallArray(int maxLength = 8, int maxValue = 3) {
    vector<int> values(randomInt(0, maxLength));
    for (int& v : values) v = randomInt(0, maxValue);
    return values;
}

// The core loop. `fast` is the algorithm under test, `slow` the obviously
// correct oracle, `generate` the input source.
template <typename Generate, typename Fast, typename Slow>
bool differentialTest(int trials, Generate generate, Fast fast, Slow slow) {
    for (int t = 0; t < trials; ++t) {
        const auto input = generate();
        const auto got = fast(input);
        const auto want = slow(input);
        if (got != want) {
            // PRINT THE INPUT AND STOP. A count of failures tells you nothing;
            // the smallest failing input tells you everything, and with a fixed
            // seed you can re-run straight into the debugger.
            printf("MISMATCH on trial %d\n", t);
            return false;
        }
    }
    return true;
}

// RULE 2: CHECK INVARIANTS, NOT JUST OUTPUTS.
//
// Structural corruption sails past a spot-check of the final answer. The bugs
// in Part 5 were caught by: triangle areas summing to the hull area; a potential
// staying non-negative; an objective decreasing monotonically; a weight vector
// equalling (1-eps)^(mistake count). None of those is the "answer".
template <typename Generate, typename Run, typename Invariant>
bool invariantTest(int trials, Generate generate, Run run, Invariant holds) {
    for (int t = 0; t < trials; ++t) {
        const auto input = generate();
        const auto state = run(input);
        if (!holds(input, state)) { printf("INVARIANT VIOLATED on trial %d\n", t); return false; }
    }
    return true;
}

// RULE 3: TEST THE CLAIM, NOT THE CODE.
//
// "2-competitive", "maximises the minimum angle", "at most ceil(lg n) mistakes"
// -- assert the BOUND, on every run, against a real optimum. This is what
// exposed the too-weak offline oracle and the adversary that had stopped
// adversing: both made the bound hold too EASILY, which a pass/fail test cannot
// see but a recorded worst-case ratio can.
template <typename Generate, typename Algorithm, typename Optimal>
double worstObservedRatio(int trials, Generate generate, Algorithm algorithm,
                          Optimal optimal, double provenBound) {
    double worst = 0.0;
    for (int t = 0; t < trials; ++t) {
        const auto input = generate();
        const double best = (double)optimal(input);
        if (best <= 0.0) continue;
        const double ratio = (double)algorithm(input) / best;
        worst = max(worst, ratio);
        if (ratio > provenBound + 1e-9) { printf("BOUND VIOLATED on trial %d\n", t); break; }
    }
    return worst;                                        // report it, do not just pass
}

// RULE 4: DELETE A LINE AND CONFIRM IT BREAKS.
//
// The strongest test in the archive, and the least used. Run the algorithm with
// one safeguard removed and MEASURE the damage:
//   - the sweep without its erase-time neighbour test:  0.81% false negatives
//   - parallel matrix multiply without the temporary D: 990/1000 wrong
//   - the Graham scan with the classic reversal:        19.9% wrong on grids
//   - Lloyd's procedure without the strict tie-break:   does not terminate
// If removing it changes nothing, it was not doing anything -- and you have
// either dead code or a test that cannot see the case it protects against.
template <typename Generate, typename Correct, typename Crippled>
double measuredDamage(int trials, Generate generate, Correct correct, Crippled crippled) {
    int wrong = 0;
    for (int t = 0; t < trials; ++t) {
        const auto input = generate();
        if (crippled(input) != correct(input)) ++wrong;
    }
    return 100.0 * wrong / trials;                       // a percentage, not a bool
}
```

*Verified — the harness was tested on itself, which is the one piece of code in this archive that has no oracle above it.*

**It passes when it should:** two agreeing sort implementations over **200 000** trials, no false alarm.

**It fails when it should, and rule 1 is the reason.** The planted bug was chosen to manifest *only on duplicates* — "find the **first** index of a target in a sorted array", implemented as a textbook binary search that returns *any* match. Over 200 independent runs of 200 trials each, it was caught **200/200 times with values drawn from `[0, 3]`** and **0/200 times with values drawn from `[0, 10⁹]`**. *The same test, the same bug, the same number of trials — and a range change takes it from certain detection to certain silence.* The mechanism is measurable directly: an 8-element input contains a duplicate on **64.1%** of small-range trials and **0.0000%** of large-range ones.

**Rule 2 was demonstrated by building a heap wrong.** A one-step sift-up violates the heap property immediately — the invariant check catches it on **trial 0** — yet the root still holds the maximum on **76.2%** of inputs. *An output-only check sees nothing three times out of four.*

**Rule 3 reports a ratio rather than a verdict.** Ski rental's genuinely 2-competitive rule gave a worst observed ratio of **1.9833** over 200 000 instances, approaching the proven 2 from below; "buy on day 1" reached **3.5** and tripped the bound check. The number is what tells you *how much room is left*, which a pass/fail cannot.

**Rule 4 quantifies a removed safeguard.** Kadane without the negative-array guard is wrong on **100%** of all-negative inputs and **2.5%** of mostly-positive ones. That 2.5% is the whole argument for rule 1 restated: a test that only generates mixed-sign arrays finds this bug once in forty runs, and concludes it was a flake.

### Complexity budgeting

```cpp
// Reading the constraint backwards to get the intended algorithm -- the single
// most useful thirty seconds at the start of a problem.
const char* intendedComplexity(long long n) {
    if (n <= 12)        return "n!            -- permutations, brute force";
    if (n <= 25)        return "2^n           -- BITMASK DP, subset enumeration";
    if (n <= 50)        return "2^(n/2)       -- meet in the middle";
    if (n <= 500)       return "n^3           -- Floyd-Warshall, interval DP";
    if (n <= 5000)      return "n^2           -- DP on pairs";
    if (n <= 1000000)   return "n lg n        -- sort, heap, BIT, sweep, D&C";
    if (n <= 10000000)  return "n             -- two pointers, counting, one pass";
    return              "lg n or sqrt(n) -- binary search, matrix power, number theory";
}

// Roughly how many operations of each shape fit in one second, at ~10^8-10^9
// simple operations per second. Useful for the "will this pass?" question BEFORE
// writing the code rather than after the timeout.
double estimatedSeconds(long long n, const string& shape) {
    const double operationsPerSecond = 1e8;
    double work = (double)n;
    if (shape == "n lg n")  work = n * log2((double)n);
    else if (shape == "n^2") work = (double)n * n;
    else if (shape == "n^3") work = (double)n * n * n;
    else if (shape == "2^n") work = pow(2.0, (double)n);
    return work / operationsPerSecond;
}
```

*Verified:* the table and the estimator were checked for **self-consistency** — every complexity shape the table recommends must actually fit a time budget at the `n` it recommends it for. All five checked out: `2ⁿ` at `n = 25` → **0.336 s**; `n³` at `n = 500` → **1.250 s**; `n²` at `n = 5 000` → **0.250 s**; `n lg n` at `n = 10⁶` → **0.199 s**; `n` at `n = 10⁷` → **0.100 s**. **0 recommendations exceeded a 10-second budget.** And the boundary bites where it should: `n²` at `n = 10⁶` is **10 000 s**, which is why the table sends `10⁶` to `n lg n` and not one shape slower.

### Overflow and precision budgets

```cpp
// Every integer expression is a polynomial, and its DEGREE is its budget.
// long long holds ~9.2 * 10^18 = 2^63.
//
//   degree 1 (a + b)         safe to |a| ~ 4.6e18
//   degree 2 (a * b)         safe to |a| ~ 3.0e9     -- cross products, distances
//   degree 3 (a * b * c)     safe to |a| ~ 2.0e6
//   degree 4 (in-circle)     safe to |a| ~ 5.5e4     -- Delaunay predicates
//
// Signed overflow is UNDEFINED BEHAVIOUR, not wraparound: the optimizer may
// delete a post-hoc check like `if (product < 0)` outright, so the check has to
// come BEFORE the multiplication or the type has to be wide enough.
bool multiplicationOverflows(long long a, long long b) {
    if (a == 0 || b == 0) return false;
    return llabs(a) > numeric_limits<long long>::max() / llabs(b);
}

// __int128 is the cheap escalation: a GCC/Clang extension, roughly as fast as
// long long for multiplication, and it doubles every budget above. Only the
// SIGN usually needs to escape the function, so it never has to spread.
int wideSign(long long a, long long b, long long c, long long d) {
    const __int128 value = (__int128)a * b - (__int128)c * d;
    return (value > 0) - (value < 0);
}

// Modular arithmetic without overflow (M21). The naive ((a % m) + m) % m
// OVERFLOWS when m is near 2^63, because a + m exceeds LLONG_MAX -- a bug that
// every small-modulus test passes.
long long normaliseMod(long long a, long long m) {
    const long long remainder = a % m;                   // in (-m, m)
    return remainder < 0 ? remainder + m : remainder;
}

// Floating-point comparison: RELATIVE, not absolute. An absolute 1e-9 is far too
// strict at magnitude 1e9 and far too loose at 1e-12.
bool nearlyEqual(double a, double b, double relativeTolerance = 1e-9) {
    return fabs(a - b) <= relativeTolerance * max({1.0, fabs(a), fabs(b)});
}
bool isNotANumber(double v) { return v != v; }           // the definition and the test
```

*Verified:* `multiplicationOverflows` agreed with `__int128` ground truth on **2 000 000** random pairs — **0 mismatches** — which matters because the naive alternative (multiply, then check the sign) is undefined behaviour the optimizer is entitled to delete.

**The degree budgets are tight, and one of them was wrong when first written.** At the stated limits: degree 2 at `3.0 × 10⁹` → `9.00 × 10¹⁸` (fits, against `long long`'s `9.22 × 10¹⁸`); degree 3 at `2.0 × 10⁶` → `8.00 × 10¹⁸` (fits); degree 4 at `5.5 × 10⁴` → `9.15 × 10¹⁸` (fits, with 0.8% to spare). The degree-3 figure originally read `2.1 × 10⁶`, which gives `9.26 × 10¹⁸` and **overflows** — caught by evaluating the claim instead of trusting the arithmetic. One notch higher on either end overflows by two orders of magnitude, as it should.

`wideSign` got the sign right on **500 000/500 000** trials of `a·b − c·d` where the true value is exactly `−1` and the operands sit near `3 × 10⁹`; **`double` got it wrong 497 809 times (99.6%)** on the identical inputs. That is [M26](M26-geometry.md)'s orientation-predicate measurement reproduced from the other direction.

**`normaliseMod` was verified, and the failure mode of the naive form is the opposite of the obvious guess.** For *negative* `a` the naive `((a % m) + m) % m` is perfectly safe — `a % m` lands in `(−m, 0]`, so adding `m` lands in `(0, m]` and cannot exceed `LLONG_MAX`; it agreed with the branch on **500 000/500 000** trials at `m ≈ 4 × 10¹⁸`. **The overflow is on the positive side:** when `a % m` is just under `m`, the sum reaches `2m − 1`, which wraps for any `m` above `2⁶²` — measured as **500 000/500 000 wrong** at `m ≈ LLONG_MAX`. [M21](M21-number-theory.md)'s comment states exactly that case, and this is the check that confirms it rather than the folklore version.

`nearlyEqual`'s relative tolerance accepts `(10⁹, 10⁹+1)` where an absolute `10⁻⁹` epsilon rejects it, and `isNotANumber` distinguishes NaN from 0.0 and from infinity.

### The comparator contract

```cpp
// std::sort and std::set require a STRICT WEAK ORDERING. Violating it is
// UNDEFINED BEHAVIOUR -- in practice, std::sort walking off the end of the
// array. This is the most common way otherwise-correct code crashes.
//
//   irreflexive:  comp(a, a) is false
//   asymmetric:   comp(a, b) implies !comp(b, a)
//   transitive:   comp(a,b) && comp(b,c) implies comp(a,c)
//                 AND the same for "neither is less than the other"
//
// That last clause is the one that bites: EQUIVALENCE MUST BE TRANSITIVE TOO.
// "collinear with the pivot" is not transitive, which is why an angular sort
// comparator must break every tie and produce a TOTAL order.
struct SafeComparatorExample {
    // Wrong: returns false both ways for equivalent-but-unequal elements in a
    // way that is not transitive.
    //     [](const T& a, const T& b) { return primaryKeyOf(a) < primaryKeyOf(b); }
    // is fine only if elements with equal primary keys are genuinely
    // interchangeable. When they are not, break the tie:
    static bool less(pair<int, int> a, pair<int, int> b) {
        if (a.first != b.first) return a.first < b.first;
        return a.second < b.second;                      // total order, always
    }
};
```

*Verified:* the lexicographic comparator was checked **exhaustively** against all three strict-weak-ordering laws over every triple from a 16-element domain — **0 violations of irreflexivity, 0 of asymmetry, 0 of transitivity, and 0 of equivalence-transitivity**, that last being the clause people do not know exists.

**And a comparator that violates only that clause was measured:** "`a` is less than `b` if `a.first + 1 < b.first`" — a perfectly reasonable-looking "within 1 of each other" rule — has transitive *ordering* but **non-transitive equivalence, violated on 256 triples** of the same domain. `std::sort` on that comparator is undefined behaviour, not a wrong answer: it can and does read past the end of the array. *This is the single most common way otherwise-correct code crashes, and it is invisible to every output check.*

### Containers, at a glance

```cpp
void containerChoice() {
    // vector       contiguous, cache-friendly, Theta(1) amortized push_back.
    //              THE DEFAULT. Reserve when the size is known.
    vector<int> values; values.reserve(1000);

    // deque        Theta(1) at both ends, not contiguous. Sliding windows.
    // list         Theta(1) splice and stable iterators; poor locality.
    //              Almost never the right answer, LRU caches excepted.

    // map/set      ordered, Theta(lg n), stable iterators across insertion.
    //              Needed when you want predecessor/successor -- which is
    //              exactly what a sweep-line status needs.
    set<int> ordered;
    auto position = ordered.insert(5).first;
    if (position != ordered.begin()) { auto below = prev(position); (void)below; }

    // unordered_map/set   Theta(1) expected, Theta(n) worst case, no order.
    //                     Iterators invalidated by rehash.
    unordered_map<int, int> counts;
    counts.reserve(1000);                                // avoids rehashing

    // priority_queue  a max-heap by default. For a MIN-heap:
    priority_queue<int, vector<int>, greater<int>> minHeap;

    // multiset     ordered with duplicates -- the skyline's status structure.
    //              erase(value) removes EVERY copy; erase(find(value)) removes
    //              ONE. The single commonest bug in a multiset-based sweep.
    multiset<int> active{3, 3, 5};
    active.erase(active.find(3));                        // one copy, not both
    (void)position; (void)minHeap;
}

// The algorithms worth knowing by name, because each replaces a loop that is
// easy to get wrong:
void algorithmsWorthKnowing() {
    vector<int> v{5, 3, 8, 1};

    sort(v.begin(), v.end());
    stable_sort(v.begin(), v.end());                     // preserves ties
    nth_element(v.begin(), v.begin() + 2, v.end());      // quickselect, Theta(n)
    partial_sort(v.begin(), v.begin() + 2, v.end());     // top k

    lower_bound(v.begin(), v.end(), 5);                  // first >= 5
    upper_bound(v.begin(), v.end(), 5);                  // first > 5
    v.erase(unique(v.begin(), v.end()), v.end());        // sort THEN unique

    partial_sum(v.begin(), v.end(), v.begin());          // prefix sums
    adjacent_difference(v.begin(), v.end(), v.begin());  // its inverse
    accumulate(v.begin(), v.end(), 0LL);                 // note the 0LL
    iota(v.begin(), v.end(), 0);                         // 0, 1, 2, ...

    next_permutation(v.begin(), v.end());                // needs sorted input first
    rotate(v.begin(), v.begin() + 1, v.end());
}
```

*Verified:* every container idiom and every algorithm named above was executed — **all ran without error**. And the `multiset` trap was measured rather than described: on `{3, 3, 5}`, `erase(3)` leaves **1 element** and `erase(find(3))` leaves **2**. The first removes *every* copy. That is the bug that quietly deletes other buildings of the same height from a skyline sweep ([M26](M26-geometry.md)), and it produces a plausible-looking wrong answer rather than a crash.

### Reading input fast

```cpp
// On judging sites, cin with synchronisation enabled is often the difference
// between passing and a timeout on 10^6 lines of input.
void fastInput() {
    ios_base::sync_with_stdio(false);                    // decouple from C stdio
    cin.tie(nullptr);                                    // stop flushing cout before cin

    // AFTER THIS, DO NOT MIX cin/cout WITH scanf/printf -- the two buffers are
    // no longer synchronised and the output interleaves wrongly.
    //
    // And prefer "\n" (a newline) to endl: endl flushes on every line, which on 10^6 lines
    // of output costs more than the algorithm.
}
```

**And the one habit that outlasts all of this.** Every module in these notes ends with numbers that were measured rather than assumed, and in twelve cases the measurement contradicted what had been written. *Write the slow version. Compare. Delete a line and confirm it breaks.*

---

*This is the last module. The set runs [M01](M01-foundations.md) → [M26](M26-geometry.md), and this one is the map back into it. Revise from the **One-Page Recall** sections, not from the modules; return to a module only when the self-test finds the gap.*
