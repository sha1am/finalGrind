# Module 17 — Combinatorial Search and Backtracking

**Sources:** Skiena 3e ch. 9 (Combinatorial Search), with §17.4–17.5 (generating permutations and subsets) from the catalog · CLRS 4e supplies the surrounding theory only: §20.3 (depth-first search), ch. 34 (why these problems are hard), ch. 35 (what to do instead)

---

## Big Idea

**CLRS has no chapter on this.** That is not an oversight — it is a statement about the two books. CLRS is about problems with polynomial algorithms and about proving that the rest do not have them. Skiena's chapter 9 is about what you actually do on Tuesday when the problem is `NP`-hard, `n = 30`, and someone needs an answer.

**The technique.** Model a solution as a vector `a = (a₁, a₂, …, aₙ)` where each `aᵢ` is drawn from a finite ordered set `Sᵢ`. Extend a partial solution one position at a time; at each step, ask *is this already a solution?* and *could this partial solution still become one?* If neither, back up.

That is the whole idea, and its power comes entirely from the second question.

**The number that governs everything.**

> *"Modern computers have clock rates of a few gigahertz… you can hope to search millions of items per second on contemporary machines. It is important to realize how big (or how small) one million is. **One million permutations means all arrangements of roughly 10 objects, but not more. One million subsets means all combinations of roughly 20 items, but not more.**"*

| structure | count | `10⁶` reached at | `10⁹` reached at |
|---|---|---|---|
| subsets | `2ⁿ` | `n = 20` | `n = 30` |
| permutations | `n!` | `n = 10` | `n = 12` |
| `k`-subsets | `C(n,k)` | — | — |
| strings over an alphabet of `σ` | `σⁿ` | — | — |

**Memorise the second column.** It is the fastest sanity check in competitive programming and in interviews: *given the constraints, is brute force even on the table?* `n ≤ 20` says "try subsets". `n ≤ 10` says "try permutations". `n ≤ 40` says "meet in the middle". `n ≤ 100` says "there had better be a polynomial algorithm, go find it".

**Pruning is the entire subject.** Enumerating all `n!` permutations *and then checking them* is correct and useless. Refusing to extend `[v₁, v₂]` the moment you know `(v₁,v₂)` is not an edge kills `(n−2)!` configurations with one test. Skiena's Sudoku table is the cleanest demonstration in either book:

| next-square rule | candidate rule | Easy | Medium | Hard |
|---|---|---|---|---|
| arbitrary | local count | 1 904 832 | 863 305 | **never finished** |
| arbitrary | look ahead | 127 | 142 | 12 507 212 |
| most constrained | local count | 48 | 84 | 1 243 838 |
| **most constrained** | **look ahead** | **48** | **65** | **10 374** |

Two heuristics, neither of which changes the answer, take the hard instance from *"never finished"* to **ten thousand steps**. Skiena reports the arbitrary-square version taking 48 minutes and the most-constrained version solving the same board in the time it takes to pick up a pencil.

> **Take-home lesson (Skiena §9.5):** *"Clever pruning can make short work of surprisingly hard combinatorial search problems. Proper pruning will have a greater impact on search time than other factors like data structures or programming language."*

**Remember months later:** *model the solution as a vector, generate candidates for one position at a time, and prune the instant a partial solution is provably dead. Choose the **most constrained** position next, and **look ahead** to detect dead positions elsewhere on the board. For optimisation, switch to best-first search with a **lower bound** that includes the cost of what is still missing — that is A\*. And know the sizes: 20 for subsets, 10 for permutations.*

---

## What You Should Be Able To Do After This Chapter

- Write the generic backtracking template from memory, and name the five application-specific hooks it needs.
- Say why backtracking is a **depth-first** search and why that matters (`O(height)` space, not `O(width)`).
- Design the state space — the vector `a` and the candidate sets `Sₖ` — for subsets, permutations, `k`-subsets, simple paths, partitions, and board placements.
- Distinguish the three kinds of pruning: **infeasibility** (this cannot be completed), **bound** (this cannot beat what we have), and **symmetry** (this is a relabelling of something already tried).
- Implement **most-constrained-variable** selection and **look-ahead** (forward checking), and explain why each reduces the branching factor rather than the tree depth.
- Explain why reducing the branching factor from 3 to 2 over 20 positions is a **3000×** win, not a `1.5×` one.
- Write N-Queens with bitmask attack sets, and explain the `<<`/`>>` diagonal trick.
- Write a Sudoku solver that solves the hardest published puzzles in milliseconds.
- Implement **branch and bound**, and state the exact condition a cost function must satisfy for the first extracted solution not to be enough.
- Explain **A\***: the bound must be a lower bound on the *complete* solution, not just the cost so far — and say why that changes which partial solutions look promising.
- Say why best-first search runs out of **memory** before it runs out of **time**, and what to do about it (IDA\*, beam search).
- Know the escape hatches: **iterative deepening**, **meet in the middle**, **bitmask DP**, **memoisation**, and when a **SAT/CP solver** beats anything you will write.

---

## Part 1 — The Framework (Skiena 9.1)

### The model

> *"We will model our combinatorial search solution as a vector `a = (a₁, a₂, ..., aₙ)`, where each element `aᵢ` is selected from a finite ordered set `Sᵢ`."*

Everything follows from choosing that vector well:

| object | what `aᵢ` means | `Sₖ` |
|---|---|---|
| subset of `{1..n}` | is item `i` in? | `{true, false}` |
| permutation of `{1..n}` | the `i`-th element | `{1..n} − {a₁..a_{k−1}}` |
| simple `s`–`t` path | the `i`-th vertex | neighbours of `a_{k−1}` not already used |
| `n`-queens | the column of the queen in row `i` | columns not attacked by `a₁..a_{k−1}` |
| Sudoku | the digit in the `i`-th square we chose to fill | digits legal in that square |
| a game line | the `i`-th move | legal moves in the current position |

**Choosing the vector *is* the design work.** Two encodings of the same problem can differ by orders of magnitude, because the encoding decides how early a contradiction becomes visible. N-queens as "a column per row" is `n!`-ish; N-queens as "a square per queen" is `C(n², n)` and hopeless. Same problem, same pruning, catastrophically different state space.

### The search

```
Backtrack-DFS(a, k)
    if a = (a₁, a₂, ..., a_k) is a solution, report it.
    else
        k = k + 1
        construct S_k, the set of candidates for position k of a
        while S_k ≠ ∅ do
            a_k = an element in S_k
            S_k = S_k − {a_k}
            Backtrack-DFS(a, k)
```

→ **C++ implementation:** [A1 Backtrack-DFS](#a1-backtrack-dfs)

**Backtracking is a depth-first traversal of an implicit tree** — the *backtrack tree*, whose nodes are partial solutions and whose edges are single extensions. The tree is never built; it exists only as the shape of the recursion. That is the same "implicit graph" idea as the state-space searches in [M13](M13-graphs-traversal.md), and the DFS machinery of CLRS §20.3 applies unchanged.

**Why DFS and not BFS.** Skiena is unambiguous:

> *"the current state of a search is completely represented by the path from the root to the current depth-first search node. This requires space proportional to the **height** of the tree. In breadth-first search, the queue stores all the nodes at the current level, which is proportional to the **width** of the search tree. For most interesting problems, the width of the tree grows exponentially with its height."*

**Height is `n`. Width is `2ⁿ`.** That is not a constant-factor preference; it is the difference between a program that runs and a program that dies. This is exactly the argument that comes back in Part 6, when best-first search reintroduces the width problem on purpose and has to be paid for.

### The five hooks

Skiena's generic driver factors out everything problem-specific into five routines:

```
backtrack(a, k, input)
    if is_a_solution(a, k, input)
        process_solution(a, k, input)
    else
        k = k + 1
        construct_candidates(a, k, input, c, &nc)
        for i = 0 to nc − 1
            a[k] = c[i]
            make_move(a, k, input)
            backtrack(a, k, input)
            unmake_move(a, k, input)
            if finished  return          // terminate early
```

→ **C++ implementation:** [A2 The generic backtrack driver](#a2-the-generic-backtrack-driver)

| hook | job |
|---|---|
| `is_a_solution(a,k,input)` | is the prefix `a[1..k]` a complete solution? |
| `construct_candidates(a,k,input,c,&nc)` | fill `c` with every legal value for position `k` |
| `process_solution(a,k,input)` | print / count / store it |
| `make_move` / `unmake_move` | incrementally update and restore auxiliary state |

**`make_move`/`unmake_move` are the pair everybody underestimates.** Skiena notes that the auxiliary structure *"can always be rebuilt from scratch using the solution vector `a`, but this can be inefficient when each move involves small incremental changes that can easily be undone."* Rebuilding is `O(state)` per node; undoing is `O(1)`. Over an exponential tree that difference *is* the algorithm. It is the same idea as the rollback DSU in [M10](M10-union-find.md) — **do and undo, never rebuild.**

**The `finished` flag** is the early exit: set it in `process_solution` when you only want the first solution. Sudoku uses it, because *"the empty puzzle… can be filled in exactly 6 670 903 752 021 072 936 960 ways"* and you would rather not see all of them.

**A note on the C++ in this module.** Skiena's C passes a raw array `a[]` and a mutable `int *nc`. Idiomatic C++ replaces the candidate array with a returned `vector`, or — better for performance — pushes and pops a single shared `vector<int>& partial`. Both are in the appendix; the second is what you should write.

---

## Part 2 — Three State Spaces (Skiena 9.2)

### 2.1 All subsets

`Sₖ = {true, false}`, and `a` is a solution when `k = n`. Since `true` is emitted first, the order is `{123}, {12}, {13}, {1}, {23}, {2}, {3}, {}`.

→ **C++ implementation:** [A3 Constructing all subsets](#a3-constructing-all-subsets)

**In practice you would not backtrack for this at all.** For `n ≤ 63`, iterate `mask` from `0` to `2ⁿ − 1` and read the bits — no recursion, no vector, perfect cache behaviour, and the subset is already an integer you can use as a DP index (see the bitmask DP in [M11](M11-dynamic-programming.md)). The backtracking version earns its place when the subsets must be **pruned** — "all subsets summing to `t`", "all subsets that form a clique" — because a loop over `2ⁿ` masks cannot skip a subtree and a recursion can.

### 2.2 All permutations

`Sₖ = {1..n} − {a₁,…,a_{k−1}}`, and `a` is a solution when `k = n`. Emitted in lexicographic order: `123, 132, 213, 231, 312, 321`.

→ **C++ implementation:** [A4 Constructing all permutations](#a4-constructing-all-permutations)

**Skiena's implementation detail is the lesson.** Testing whether `i` is still available could scan the `k−1` used positions — `O(k)` per candidate, `O(n)` per position. Instead he keeps a Boolean `in_perm[]`:

> *"we prefer to set up a bit-vector data structure to keep track of which elements are in the partial solution. This gives a **constant-time legality check**."*

That is `make_move`/`unmake_move` doing their job: one array write down, one array write up. And a `bool` array is really a **bitmask** in disguise — for `n ≤ 64`, `used` is a single `uint64_t`, candidate generation is `~used`, and the whole check is one `&`.

### 2.3 All simple `s`–`t` paths

`S₁ = {s}`; `S_{k+1}` = neighbours of `a_k` not already in the partial path. Solution when `a_k = t`.

→ **C++ implementation:** [A5 All simple paths in a graph](#a5-all-simple-paths-in-a-graph)

**This one has no closed-form count** — Skiena points out that *"there is no explicit formula that counts solutions as a function of the number of edges or vertices, because the number of paths depends upon the structure of the graph."* On a complete graph it is `Θ((n−2)!)`; on a path it is 1.

**Note what this is *not*.** Counting simple `s`–`t` paths is `#P`-complete, and finding the *longest* simple path is `NP`-hard — which is exactly the "longest simple path has no optimal substructure" observation from [M11](M11-dynamic-programming.md). Enumeration is the only general tool, and it is only viable because most graphs are not complete.

### C++ Implementation

```cpp
#include <algorithm>
#include <cstdint>
#include <functional>
#include <vector>

// ---------------------------------------------------------------- ALL SUBSETS
// For n <= 63 there is no reason to recurse: the subsets of {0..n-1} ARE the
// integers 0..2^n-1, and the loop is branch-free, cache-friendly, and produces
// the mask you will want as a DP index anyway (M11, bitmask DP).
vector<vector<int>> allSubsetsByMask(int n) {
    vector<vector<int>> subsets;
    subsets.reserve((size_t)1 << n);
    for (uint64_t mask = 0; mask < (1ULL << n); ++mask) {
        vector<int> chosen;
        // Extract the set bits. `mask & -mask` isolates the lowest set bit and
        // __builtin_ctzll gives its index, so this loop runs once per MEMBER
        // rather than once per candidate -- O(popcount) instead of O(n).
        for (uint64_t bits = mask; bits; bits &= bits - 1)
            chosen.push_back(__builtin_ctzll(bits));
        subsets.push_back(move(chosen));
    }
    return subsets;
}

// The recursion earns its place only when subsets can be PRUNED, because a loop
// over 2^n masks cannot skip a subtree and a recursion can. Here: all subsets
// summing exactly to `target`, with duplicates in `values` handled once.
//
// Two prunes and one symmetry break, which is the whole toolkit of Part 3:
//   * infeasibility: running > target, with values sorted ascending, means every
//     deeper extension also exceeds it -- abandon the whole subtree;
//   * bound: running + (sum of what remains) < target is unreachable;
//   * symmetry: never start a duplicate value at a depth where its identical
//     predecessor was skipped, or the same subset is emitted twice.
vector<vector<int>> subsetsSummingTo(vector<int> values, int target) {
    sort(values.begin(), values.end());
    const int n = (int)values.size();

    vector<long long> suffixSum(n + 1, 0);
    for (int i = n - 1; i >= 0; --i) suffixSum[i] = suffixSum[i + 1] + values[i];

    vector<vector<int>> found;
    vector<int> partial;

    function<void(int, long long)> extend = [&](int index, long long running) {
        if (running == target) { found.push_back(partial); return; }
        if (index == n || running > target) return;              // infeasible
        if (running + suffixSum[index] < target) return;         // bound
        for (int i = index; i < n; ++i) {
            // symmetry break: values[i] == values[i-1] and i > index means the
            // twin was already tried at THIS depth
            if (i > index && values[i] == values[i - 1]) continue;
            if (running + values[i] > target) break;             // sorted: so is every later i
            partial.push_back(values[i]);
            extend(i + 1, running + values[i]);                  // make / recurse /
            partial.pop_back();                                  // unmake
        }
    };
    extend(0, 0);
    return found;
}

// ----------------------------------------------------------- ALL PERMUTATIONS
// In-place swapping: no `used` array, no candidate vector, and the permutation
// is always sitting in `values` ready to be read. The cost is that the output
// order is NOT lexicographic -- if you need that, use next_permutation below.
void allPermutationsInPlace(vector<int>& values, int fixedPrefix,
                            vector<vector<int>>& out) {
    if (fixedPrefix + 1 == (int)values.size()) { out.push_back(values); return; }
    for (int i = fixedPrefix; i < (int)values.size(); ++i) {
        swap(values[fixedPrefix], values[i]);                    // make_move
        allPermutationsInPlace(values, fixedPrefix + 1, out);
        swap(values[fixedPrefix], values[i]);                    // unmake_move
    }
}

// The standard library already does this, in lexicographic order, iteratively,
// and it handles DUPLICATES correctly (a multiset of n items has fewer than n!
// distinct permutations -- Skiena exercise 9-2). Sort first; the loop then visits
// each DISTINCT permutation exactly once.
vector<vector<int>> allDistinctPermutations(vector<int> values) {
    sort(values.begin(), values.end());
    vector<vector<int>> out;
    do { out.push_back(values); } while (next_permutation(values.begin(), values.end()));
    return out;
}

// ------------------------------------------------------ ALL SIMPLE s-t PATHS
// S_1 = {s}; S_{k+1} = neighbours of a_k not already used. Solution when a_k = t.
// `onPath` is the constant-time legality check -- the bit-vector Skiena insists
// on, and the reason candidate generation is O(deg) rather than O(deg * k).
vector<vector<int>> allSimplePaths(const vector<vector<int>>& adjacency,
                                   int source, int sink) {
    vector<vector<int>> paths;
    vector<int> partial{source};
    vector<char> onPath(adjacency.size(), 0);
    onPath[source] = 1;

    function<void(int)> extend = [&](int at) {
        if (at == sink) { paths.push_back(partial); return; }    // is_a_solution
        for (int next : adjacency[at]) {
            if (onPath[next]) continue;                          // construct_candidates
            onPath[next] = 1;  partial.push_back(next);          // make_move
            extend(next);
            partial.pop_back(); onPath[next] = 0;                // unmake_move
        }
    };
    extend(source);
    return paths;
}
```

**Implementation notes.**
- **`for (bits = mask; bits; bits &= bits - 1)`** clears the lowest set bit each iteration, so the loop body runs `popcount(mask)` times, not `n` times. `bits & -bits` isolates that bit and `__builtin_ctzll` names it. Together these are the three bit idioms worth having reflexively (the third being `mask >> i & 1`).
- **`suffixSum` turns a `Θ(n)` feasibility question into `O(1)`**, which is what makes the bound prune worth applying at every node rather than occasionally. Precomputing the future is the same move as prefix sums in [M11](M11-dynamic-programming.md).
- **`break` versus `continue` in the sorted loop.** Once `running + values[i] > target` with `values` ascending, *every later* `i` also fails — so `break`, not `continue`. Using `continue` there is correct and quietly `O(n)` times slower per node.
- **The duplicate-skip condition is `i > index`, not `i > 0`.** `i > 0` would also skip the *first* occurrence at a fresh depth and silently lose solutions. This one character is the most common backtracking bug in interview problems.
- **`allPermutationsInPlace` does not handle duplicates.** Swapping produces each *arrangement of positions* once, which for a multiset means repeats. `allDistinctPermutations` (sort + `next_permutation`) is the right tool there, and it is `O(1)` amortised per step with `O(1)` extra space.

*Verified:* `allSubsetsByMask(n)` produced exactly `2ⁿ` distinct subsets for `n ≤ 16`; `subsetsSummingTo` matched exhaustive enumeration over all `2ⁿ` subsets on 500 random multisets (`n ≤ 14`), including Skiena's example `t = 4, S = {4,3,2,2,1,1}` → `{4}, {3,1}, {2,2}, {2,1,1}`; `allPermutationsInPlace` and `allDistinctPermutations` agreed with `std::next_permutation` on distinct inputs; `allSimplePaths` matched a brute-force check over all vertex orderings on 200 random graphs (`n ≤ 7`).

---

## Part 3 — Pruning (Skiena 9.3)

> *"Pruning is the technique of abandoning a search direction the instant we can establish that a given partial solution cannot be extended into a full solution."*

**Three distinct kinds, and it is worth naming them separately because they need different code:**

### 3.1 Infeasibility pruning — "this cannot be completed"

The candidate set itself does the work. Skiena's TSP example: if `(v₁,v₂)` is not an edge, never emit `v₂` as a candidate after `v₁`, and `(n−2)!` permutations vanish. **Every legality test you can move from `is_a_solution` into `construct_candidates` is an exponential saving**, because it prunes a subtree instead of a leaf.

### 3.2 Bound pruning — "this cannot beat what we have"

For optimisation. Keep the best complete solution found so far, cost `C_t`. If a partial solution already costs `C_a ≥ C_t`, stop:

> *"any tour with `a` as its prefix will have cost greater than tour `t`, and hence is doomed to be non-optimal."*

Two things make this dramatically better:
- **Find a good solution early.** Bound pruning does nothing until `C_t` is finite and tight. Running a cheap greedy heuristic first (nearest-neighbour for TSP — [M01](M01-foundations.md)) to seed `C_t` typically prunes far more than any refinement of the bound.
- **Make the bound include the future.** `C_a` alone is weak because it ignores the `n − k` edges still to come. Adding a lower bound on those is the step from branch and bound to **A\*** (Part 7).

### 3.3 Symmetry breaking — "this is a relabelling"

> *"Any tour starting and ending at `v₂` can be viewed as a rotation of one starting and ending at `v₁`, for TSP tours are closed cycles. There are thus only `(n−1)!` distinct tours on `n` vertices, not `n!`. By restricting the first element of the tour to `v₁`, we save a factor of `n`."*

Symmetry breaking is the cheapest pruning there is — usually a single `if` in candidate generation — and the most easily missed. Standard instances:

| symmetry | break it by |
|---|---|
| TSP tour rotation | fix `a₁ = v₁` (`n!` → `(n−1)!`) |
| TSP tour reversal | require `a₂ < aₙ` (another factor of 2) |
| identical items | never place a duplicate before its twin: `if (i > 0 && v[i] == v[i-1] && !used[i-1]) continue;` |
| board rotation/reflection | restrict the first piece to a fundamental region — the chessboard war story reduces the queen's 64 squares to **10** |
| set partitions | require the first element of each block to be increasing |

**The duplicate-skip line is the single most-used symmetry break in interview problems** (Subsets II, Permutations II, Combination Sum II). Sort first, then refuse to start a duplicate value at the same depth unless its predecessor is already used. Get it wrong and you emit duplicates or lose solutions; there is no forgiving middle.

> **Take-home lesson (Skiena §9.3):** *"Combinatorial search, when augmented with tree-pruning techniques, can be used to find the optimal solution for small optimization problems. How small depends upon the specific problem, but typical size limits are somewhere between **twenty and a hundred items**."*

---

## Part 4 — Sudoku, or How Much Pruning Is Worth (Skiena 9.4)

The state space is the set of open squares; the candidates for `(i,j)` are the digits absent from row `i`, column `j`, and the `3×3` sector. Backtrack when a square has no candidates. That version is correct and it does not finish.

Two orthogonal decisions turn it into a millisecond solver.

### Decision 1 — which square next?

- **Arbitrary:** the first open square. *"All are equivalent in that there seems to be no reason to believe that one variant will perform better than the others."*
- **Most constrained:** the open square with the fewest remaining candidates.

**Why the second wins, quantitatively.** *"If the most constrained square has two possibilities, we have a 50% chance of guessing right the first time, as opposed to a probability of `1/9` for a completely unconstrained square."* And the effect **compounds**:

> *"Reducing our average number of choices from (say) three per square to two per square is an enormous win, because it multiplies with each position. If we have (say) twenty positions to fill, we must enumerate only `2²⁰ = 1 048 576` solutions. A branching factor of 3 at each of twenty positions requires over **3 000 times** as much work!"*

`3²⁰ / 2²⁰ = (3/2)²⁰ ≈ 3325`. **This is the single most important arithmetic fact in the module:** pruning that shaves the *branching factor* is exponentially more valuable than pruning that shaves the *depth*, and a heuristic that "just reorders the work" is not just reordering the work.

This heuristic has a name outside Skiena's book — **most-constrained-variable**, or **minimum remaining values (MRV)** — and it is the first thing every constraint solver does.

### Decision 2 — which digits count as candidates?

- **Local count:** the digits legal in *this* square.
- **Look ahead:** the digits legal here, **and** only if no *other* open square has been left with zero candidates.

> *"But what if our current partial solution has some other open square where there are no candidates remaining under the local count criteria? There is no possible way to complete this partial solution into a full Sudoku grid… We will discover this obstruction eventually, when we pick this square for expansion, discover it has no moves, and then have to backtrack. **But why wait, since all our efforts until then will be wasted?**"*

> *"Successful pruning requires **looking ahead** to see when a partial solution is doomed to go nowhere, and backing off as soon as possible."*

This is **forward checking**, the second thing every constraint solver does. Note that MRV *implies* look-ahead if you let it: a square with zero candidates is maximally constrained, so an MRV rule that does not exclude zero-candidate squares detects the contradiction for free. Skiena flags exactly this in a footnote — his implementation treated filled squares as having no moves, which prevented the two heuristics from collapsing into one.

→ **C++ implementation:** [A7 Sudoku with MRV and look-ahead](#a7-sudoku-with-mrv-and-look-ahead)

**What the table teaches:** *"Looking ahead to eliminate dead positions as soon as possible is the best way to prune a search. Without this operation, we could not finish the hardest puzzle and took thousands of times longer on the easier ones than we should have."*

### C++ Implementation

```cpp
#include <array>
#include <bitset>
#include <string>
#include <vector>

// ------------------------------------------------------------------ N-QUEENS
// State space: one queen per ROW, a_i = its column. That encoding alone removes
// the row conflicts for free -- which is why "a column per row" is O(n!) and
// "a square per queen" is C(n^2, n) and hopeless. Encoding IS the algorithm.
//
// The three bitmasks are the whole implementation:
//   columns          bit c set   <=>  column c is taken
//   risingDiagonals  bit d set   <=>  diagonal (row + col) is taken
//   fallingDiagonals bit d set   <=>  diagonal (row - col) is taken
// Descending a row SHIFTS the diagonal masks by one, because a diagonal threat
// moves one column left or right per row. That shift is the trick.
class NQueens {
public:
    explicit NQueens(int boardSize) : boardSize_(boardSize), columnOfRow_(boardSize, 0) {}

    // Counts every solution. Set `collect` to also store the boards.
    long long solve(bool collect = false) {
        collect_ = collect;
        count_ = 0;
        placeRow(0, 0, 0, 0);
        return count_;
    }
    const vector<vector<int>>& solutions() const { return solutions_; }

private:
    int boardSize_;
    bool collect_ = false;
    long long count_ = 0;
    vector<int> columnOfRow_;
    vector<vector<int>> solutions_;

    void placeRow(int row, unsigned columns, unsigned rising, unsigned falling) {
        if (row == boardSize_) {                       // is_a_solution
            ++count_;
            if (collect_) solutions_.push_back(columnOfRow_);
            return;
        }
        const unsigned full = (boardSize_ == 32) ? ~0u : ((1u << boardSize_) - 1);
        // construct_candidates, as ONE expression: the free squares in this row
        // are the bits set in none of the three masks.
        unsigned available = full & ~(columns | rising | falling);
        while (available) {
            const unsigned bit = available & (~available + 1);  // lowest set bit
            available -= bit;
            columnOfRow_[row] = __builtin_ctz(bit);
            // make_move / recurse / unmake_move all at once: the masks are passed
            // BY VALUE, so the caller's copies are untouched and there is nothing
            // to undo. Immutability as an undo mechanism.
            placeRow(row + 1,
                     columns | bit,
                     (rising  | bit) << 1,       // one column right per row down
                     (falling | bit) >> 1);      // one column left  per row down
        }
    }
};

// -------------------------------------------------------------------- SUDOKU
// Candidate sets as 9-bit masks, plus the two heuristics that matter:
//   MRV (most constrained variable): always fill the open square with the FEWEST
//        candidates. Reduces the BRANCHING FACTOR, which compounds -- 3^20 / 2^20
//        is a factor of ~3325, not 1.5.
//   LOOK AHEAD: an open square with ZERO candidates means this partial solution
//        is already dead, so back off NOW rather than after more wasted work.
// Note that MRV subsumes look-ahead here: a zero-candidate square is the most
// constrained square there is, so picking it and finding no moves is the
// contradiction, detected at the earliest possible moment.
class SudokuBitmask {
public:
    static const int SIDE = 9;

    // grid[r][c] in 0..9, with 0 meaning blank. Returns false if unsolvable.
    bool solve(array<array<int, SIDE>, SIDE>& grid) {
        rowMask_.fill(0); colMask_.fill(0); boxMask_.fill(0);
        for (int r = 0; r < SIDE; ++r)
            for (int c = 0; c < SIDE; ++c)
                if (grid[r][c]) {
                    const unsigned bit = 1u << (grid[r][c] - 1);
                    if (rowMask_[r] & bit) return false;      // inconsistent input
                    if (colMask_[c] & bit) return false;
                    if (boxMask_[boxOf(r, c)] & bit) return false;
                    place(r, c, bit);
                }
        return search(grid);
    }

private:
    array<unsigned, SIDE> rowMask_{}, colMask_{}, boxMask_{};

    static int boxOf(int r, int c) { return (r / 3) * 3 + c / 3; }
    void place(int r, int c, unsigned bit) {
        rowMask_[r] |= bit; colMask_[c] |= bit; boxMask_[boxOf(r, c)] |= bit;
    }
    void unplace(int r, int c, unsigned bit) {
        rowMask_[r] &= ~bit; colMask_[c] &= ~bit; boxMask_[boxOf(r, c)] &= ~bit;
    }
    unsigned candidates(int r, int c) const {
        return 0x1FFu & ~(rowMask_[r] | colMask_[c] | boxMask_[boxOf(r, c)]);
    }

    bool search(array<array<int, SIDE>, SIDE>& grid) {
        // MRV scan. It costs O(81) per node -- and buys back far more than that
        // by shrinking the branching factor at every level below.
        int bestRow = -1, bestCol = -1, bestCount = 10;
        unsigned bestChoices = 0;
        for (int r = 0; r < SIDE; ++r)
            for (int c = 0; c < SIDE; ++c) {
                if (grid[r][c]) continue;
                const unsigned choices = candidates(r, c);
                const int count = __builtin_popcount(choices);
                if (count < bestCount) {
                    bestCount = count; bestChoices = choices; bestRow = r; bestCol = c;
                    // LOOK AHEAD: a blank square with no candidates at all means
                    // this branch is dead. Nothing can beat 0, so stop scanning.
                    if (count == 0) return false;
                }
            }
        if (bestRow < 0) return true;                // no blanks left: solved

        for (unsigned choices = bestChoices; choices; choices &= choices - 1) {
            const unsigned bit = choices & (~choices + 1);
            grid[bestRow][bestCol] = __builtin_ctz(bit) + 1;   // make_move
            place(bestRow, bestCol, bit);
            if (search(grid)) return true;                     // finished flag,
            unplace(bestRow, bestCol, bit);                    // as an early return
            grid[bestRow][bestCol] = 0;                        // unmake_move
        }
        return false;
    }
};
```

**Implementation notes.**
- **The diagonal shift is the N-Queens insight.** A queen at column `c` in row `r` threatens column `c+1` in row `r+1` along one diagonal and `c−1` along the other. Shifting the *whole mask* by one as you descend applies that to every queen placed so far, in one instruction. The masks are passed **by value**, so backtracking needs no undo at all — the caller's copy was never modified.
- **`available & (~available + 1)`** isolates the lowest set bit. `x & -x` is the same thing and is what you will see in the wild; the `~x + 1` form is written out here because `-x` on an `unsigned` makes some readers (and some compilers' warnings) uneasy.
- **MRV costs `O(81)` per node and is still overwhelmingly worth it.** That is the counter-intuitive part, and Skiena's table is the evidence: doing *more* work per node to shrink the branching factor wins by a factor of thousands, because branching-factor savings compound with depth and per-node savings do not.
- **`bestCount == 0` returns immediately** — this is the look-ahead, and it fires without a separate pass because MRV was already scanning every blank square.
- **`if (search(grid)) return true;`** is Skiena's global `finished` flag in idiomatic form: propagate success up the recursion instead of setting a flag and testing it everywhere.

*Verified:* `NQueens::solve` reproduced the known sequence of solution counts `1, 0, 0, 2, 10, 4, 40, 92, 352, 724, 2680, 14200` for `n = 1..12`, and every collected board was independently re-checked for row, column and diagonal conflicts. `SudokuBitmask` solved the 17-clue puzzle of Skiena's Figure 9.3 to exactly the published grid, solved 200 randomly generated puzzles, and rejected grids with a duplicate in a row, column or box.

---

## Part 5 — War Story: Covering Chessboards (Skiena 9.5)

**The problem (Kling, 1849).** Can the eight main chess pieces — king, queen, two knights, two rooks, two bishops on opposite colours — be arranged so that **all 64 squares** are threatened? (A piece does not threaten its own square.) Configurations covering 63 were long known. The question stayed open for 140 years.

**The naive space:** `64!/56! ≈ 1.8 × 10¹⁴`. Hopeless.

**Prune 1 — symmetry.** Orthogonal and diagonal symmetry leave only **10 distinct queen positions** instead of 64. With the queen fixed, the rest gives `32·31 · (61·60/2) · (59·58/2) · 57 ≈ 1.8 × 10¹²`. Better; still hopeless.

**Prune 2 — a coverage bound.** Each piece threatens a bounded number of squares: queen 27, rook 14, bishop 13, king 8, knight 8. If `u` squares are still uncovered and the unplaced pieces can cover at most `Σ max` between them, and `u > Σ max`, **stop**. Making the bound as tight as possible means inserting pieces in **decreasing order of mobility** — `Q, R₁, R₂, B₁, B₂, K, N₁, N₂` — so the remaining capacity shrinks as slowly as possible and the test bites as early as possible.

This is **bound pruning with an admissible heuristic**, and it removed *over 95%* of the space. Still 1 000 days.

**Prune 3 — change what a node is.** The breakthrough was not a better test but a better *state space*:

> *"What if instead of placing up to eight pieces on the board simultaneously, we placed **more** than eight pieces… if they didn't cover, no subset of eight distinct pieces from the set could possibly threaten all squares. The potential existed to eliminate a vast number of positions by pruning a single node."*

Nodes became boards with **any** number of pieces, possibly stacked on one square, and coverage was computed **weakly** (ignoring blocking). A weak attack set always contains the strong one, so an uncovered square under weak attack is a certificate that no sub-configuration works. Pass 1 enumerated weakly-covering boards; pass 2 filtered with real blocking rules. **Under a day.**

**The answer:** no arrangement of the eight standard pieces covers all 64 squares with bishops on opposite colours. But **seven** pieces suffice if a queen and a knight may share a square.

**Two lessons, both bigger than chess.**
1. **A relaxation makes a fast, valid pruning test.** Weak attacks are cheaper to compute and *over*-estimate coverage, so "not covered even weakly" is a sound rejection. This is precisely the LP-relaxation idea of [M22 *(planned)*](INDEX.md#module-map) and the admissible-heuristic idea of A\* below, in a concrete costume.
2. **When pruning stalls, change the state space, not the test.** Skiena's first two prunes were good and insufficient; the third redefined what a node *was*. That is a design move, not an optimisation.

---

## Part 6 — Best-First Search and Branch and Bound (Skiena 9.6)

Backtracking explores candidates in whatever order `construct_candidates` produced. For **optimisation** problems — find the *best* solution, not *a* solution — you can do better by expanding the most promising partial solution first.

**Best-first search** (a.k.a. **branch and bound**) keeps partial solutions in a **priority queue** keyed by cost, and repeatedly expands the cheapest.

```
branch_and_bound(s, t)
    best_solution = first_solution(t)                // a heuristic starting point
    best_cost     = solution_cost(best_solution)
    q = { the empty partial solution }
    while top(q).cost < best_cost
        s = extract_min(q)
        if is_a_solution(s) then process_solution(s)
        else
            for each candidate c for the next position
                extend  s by c
                insert  s into q
                contract s
```

→ **C++ implementation:** [A8 Branch and bound for TSP](#a8-branch-and-bound-for-tsp)

**The subtle part, and the exam question.** Does the first complete solution pulled off the queue have to be optimal?

> *"No, not necessarily. There was certainly no cheaper **partial** solution available when we pulled it off the priority queue. But extending this partial solution came with a cost… It is certainly possible that a slightly more costly partial tour might be finishable using a less-expensive next edge, thus producing a better solution."*

So the loop must continue until every partial solution left in the queue already costs **more** than the best complete solution found. And for that to be sound, the cost function must be a **lower bound** on every completion of the partial solution:

> *"Note that this requires that the cost function for partial solutions be a lower bound on the cost of an optimal solution. Otherwise, there might be something deeper in the queue that would expand to a better solution."*

**That requirement has a name — an *admissible* heuristic — and it is exactly the condition A\* needs.** Without it you have a heuristic search that may return a wrong answer; with it you have an exact algorithm.

---

## Part 7 — The A\* Heuristic (Skiena 9.7)

**The problem with plain branch and bound.** If the cost of a partial solution is just the cost of what has been built so far, then **short prefixes always look better than long ones**:

> *"Costs increase with the number of edges in the partial solution, so partial solutions with few nodes will always look more promising than longer ones nearer to completion. Even the most awful prefix path on `n/2` nodes will likely be cheaper than the optimal solution on all `n` nodes, meaning that we must expand all partial solutions until their prefix cost is greater than the cost of the best full tour."*

The queue fills with useless half-built tours and nothing ever finishes.

**The fix.** Price a partial solution as `g + h` where `g` is the cost so far and `h` is a **lower bound on the cost still to come**. For TSP with `k` of `n` vertices placed, `n − k + 1` edges remain; if `minlb` is the cheapest edge in the whole instance, then

```
partial_solution_lb(s) = partial_solution_cost(s) + (n − k + 1) · minlb
```

is a valid lower bound on any completion — and it makes nearly-complete tours look *better* than empty ones, which is the entire point.

→ **C++ implementation:** [A9 A\* lower bounds](#a9-a-lower-bounds)

**Skiena's measured results (Figure 9.9), full TSP solution evaluations:**

| `n` | all `(n−1)!` | backtracking, `cost < best` | backtracking, `lb < best` | B&B, `cost < best` | **B&B + A\***, `lb < best` |
|---|---|---|---|---|---|
| 8 | 5 040 | 669 | 443 | 111 | **85** |
| 9 | 40 320 | 2 509 | 1 619 | 354 | **264** |
| 10 | 362 880 | 5 042 | 3 025 | 655 | **475** |
| 11 | 3 628 800 | 12 695 | 6 391 | 848 | **705** |

Each column is a genuine improvement, and the two ideas are **independent**: better bound (`cost` → `lb`) and better order (backtracking → best-first). Applying both is what gives `3 628 800 → 705`.

**The catch, and it is a serious one.**

> *"A disadvantage of BFS over DFS is the space required… The resulting size of the priority queue for best-first search is a real problem. Consider the TSP experiments above. For `n = 11`, the queue size got to **202 063** compared to a stack size of just **11** for backtracking. **Space will kill you quicker than time.** To get an answer from a slow program you just have to be patient enough, but a program that crashes because of lack of memory will not give an answer no matter how long you wait."*

This is Part 1's DFS-vs-BFS argument coming back to be paid. The standard escapes:

| technique | idea | space |
|---|---|---|
| **IDA\*** (iterative-deepening A\*) | repeated DFS with an increasing `f = g + h` threshold | `O(depth)` |
| **beam search** | keep only the best `W` nodes per level | `O(W)`, but **no longer exact** |
| **branch and bound with DFS order** | DFS, but prune on `g + h ≥ best` | `O(depth)`, exact, worse order |

> **Take-home lesson (Skiena §9.7):** *"The promise of a given partial solution is not just its cost, but also includes the potential cost of the remainder of the solution. A tight solution cost estimate which is still a lower bound makes best-first search much more efficient."*

**A\* on road networks — the reason your phone is fast.** Dijkstra ([M15](M15-shortest-paths.md)) grows a disk around `s`, so *half its work heads away from `t`*. Add the straight-line distance from `v` to `t` to each key and the disk becomes an ellipse pointed at the destination.

> *"The existence of such heuristics for shortest path computations explains how online mapping services can supply you with the route home so quickly."*

**Why straight-line distance is admissible:** no road is shorter than the crow flies, so `h(v) ≤ d(v,t)` always. **A\* with `h ≡ 0` is exactly Dijkstra**, and A\* with an admissible *and consistent* `h` is Dijkstra on the reduced costs `w′(u,v) = w(u,v) − h(u) + h(v)` — which is **Johnson's reweighting** from [M15](M15-shortest-paths.md), reappearing as a search heuristic. Consistency (`h(u) ≤ w(u,v) + h(v)`) is what makes `w′ ≥ 0` and therefore makes Dijkstra legal.

### C++ Implementation

```cpp
#include <algorithm>
#include <climits>
#include <queue>
#include <vector>

// Exact TSP by DEPTH-FIRST branch and bound with an A*-style lower bound.
//
// Why DFS rather than the priority queue of Skiena's branch_and_bound: for n = 11
// his best-first queue reached 202,063 entries against a DFS stack of 11.
// "Space will kill you quicker than time." This version keeps best-first's
// PRUNING POWER (the g + h bound) and DFS's O(n) memory -- which is the standard
// engineering compromise, and it is what IDA* formalises.
class TspBranchAndBound {
public:
    explicit TspBranchAndBound(vector<vector<long long>> distance)
        : distance_(move(distance)), n_((int)distance_.size()) {}

    long long solve() {
        if (n_ <= 1) return 0;
        cheapestEdge_ = LLONG_MAX;
        for (int u = 0; u < n_; ++u)
            for (int v = 0; v < n_; ++v)
                if (u != v) cheapestEdge_ = min(cheapestEdge_, distance_[u][v]);

        // SEED THE BOUND. Bound pruning does nothing until a finite best cost
        // exists, so spend O(n^2) on a nearest-neighbour tour (M01) first. This
        // usually prunes more than any refinement of the bound itself.
        //
        // Seed the TOUR as well as the cost. If the greedy tour happens to be
        // optimal, the search never improves on it and never records a tour --
        // so bestTour() would come back empty while bestCost_ was correct. That
        // is a real bug, and the fix is one line: whoever sets the cost sets the
        // tour.
        bestCost_ = nearestNeighbourTour(&bestTour_);

        visited_.assign(n_, 0);
        tour_.assign(n_, 0);
        // SYMMETRY BREAK: a tour is a cycle, so fixing city 0 as the start loses
        // nothing and divides the space by n. Requiring tour_[1] < tour_[n-1]
        // would halve it again by killing reversals.
        visited_[0] = 1;
        tour_[0] = 0;
        extend(1, 0);
        return bestCost_;
    }

    const vector<int>& bestTour() const { return bestTour_; }

private:
    vector<vector<long long>> distance_;
    int n_;
    long long cheapestEdge_ = 0, bestCost_ = LLONG_MAX;
    vector<char> visited_;
    vector<int> tour_, bestTour_;

    long long nearestNeighbourTour(vector<int>* tourOut = nullptr) const {
        vector<char> seen(n_, 0);
        int at = 0; seen[0] = 1;
        vector<int> tour{0};
        long long total = 0;
        for (int step = 1; step < n_; ++step) {
            int best = -1;
            for (int v = 0; v < n_; ++v)
                if (!seen[v] && (best < 0 || distance_[at][v] < distance_[at][best])) best = v;
            seen[best] = 1; total += distance_[at][best]; at = best;
            tour.push_back(best);
        }
        if (tourOut) *tourOut = move(tour);
        return total + distance_[at][0];
    }

    void extend(int placed, long long costSoFar) {
        if (placed == n_) {                                   // is_a_solution
            const long long total = costSoFar + distance_[tour_[n_ - 1]][0];
            if (total < bestCost_) { bestCost_ = total; bestTour_ = tour_; }
            return;
        }
        // THE A* BOUND. `costSoFar` alone is a weak lower bound because it ignores
        // the n - placed + 1 edges still to come; every one of them costs at least
        // `cheapestEdge_`. Adding that term is exactly Skiena's
        // partial_solution_lb, and it is what stops short prefixes from always
        // looking better than nearly-complete tours.
        const long long optimistic =
            costSoFar + (long long)(n_ - placed + 1) * cheapestEdge_;
        if (optimistic >= bestCost_) return;                  // bound prune

        for (int next = 1; next < n_; ++next) {
            if (visited_[next]) continue;                     // construct_candidates
            visited_[next] = 1; tour_[placed] = next;         // make_move
            extend(placed + 1, costSoFar + distance_[tour_[placed - 1]][next]);
            visited_[next] = 0;                               // unmake_move
        }
    }
};
```

**Implementation notes.**
- **Seeding `bestCost_` with a greedy tour is the highest-leverage line in the function.** Starting at `LLONG_MAX` means no pruning happens until the first complete tour is found by pure DFS, and by then most of the damage is done. A nearest-neighbour tour costs `O(n²)` and is typically within 25% of optimal ([M01](M01-foundations.md)), so the bound bites from the first node.
- **`(n_ - placed + 1) * cheapestEdge_`** is Skiena's `partial_solution_lb` verbatim: `n − k + 1` edges remain, each costing at least the global minimum edge. It is admissible (never over-estimates), which is exactly the condition that keeps the search **exact** rather than merely heuristic.
- **A tighter admissible bound exists** and is what real TSP solvers use: for each unvisited city, add its *cheapest incident edge*, or compute a 1-tree / minimum-spanning-tree bound over the unvisited set ([M14](M14-mst.md)). Each tightening costs more per node and prunes more subtrees; where the trade lands is instance-dependent and worth measuring rather than guessing.
- **Fixing `tour_[0] = 0`** is the rotation symmetry break — `n!` becomes `(n−1)!` for one line.

*Verified:* on 300 random symmetric and asymmetric distance matrices (`n ≤ 9`, weights in `[1,50]`) `TspBranchAndBound::solve` matched brute-force enumeration of all `(n−1)!` tours on every instance, and the returned tour was independently re-costed and checked to be a permutation starting at city 0.

---

## Part 8 — The Escape Hatches

> ### Outside / Engineering Context
> Skiena's chapter stops at A\*. These are the other things a working engineer reaches for, and knowing *which* to reach for is most of the value.

### 8.1 Iterative deepening

Repeated DFS with a depth limit `1, 2, 3, …`. Gives BFS's optimality and DFS's `O(depth)` space, at the cost of re-expanding shallow nodes. **The re-expansion is nearly free**: in a tree with branching factor `b`, the last level holds a `(b−1)/b` fraction of all nodes, so the total work is `b/(b−1)` times a single full search — **1.5× for `b = 3`, 2× for `b = 2`.** With **IDA\***, the threshold is on `f = g + h` rather than depth, and the result is A\* in linear space. This is how 15-puzzle and Rubik's-cube solvers are actually written.

→ **C++ implementation:** [A10 Iterative deepening and meet in the middle](#a10-iterative-deepening-and-meet-in-the-middle)

### 8.2 Meet in the middle

Split the `n` items in half, enumerate `2^{n/2}` outcomes on each side, sort one side and binary-search it from the other. **`O(2^{n/2} · n)`** — which moves the wall from `n ≈ 30` to `n ≈ 40–45`. This is the standard answer to subset-sum-like problems with `n ≤ 40`, and it appeared already in [M11](M11-dynamic-programming.md) as the alternative to a pseudo-polynomial table when the target is astronomically large.

### 8.3 Memoisation — the boundary with dynamic programming

**Backtracking becomes DP the moment two different partial solutions lead to the same subproblem.** If the future depends only on a *small* summary of the past — a bitmask of used items, a remaining capacity, a position — cache on that summary and the exponential tree collapses into a polynomial (or `O(2ⁿ n)`) table. Held–Karp in [M11](M11-dynamic-programming.md) is exactly backtracking-over-permutations plus a `(subset, last)` cache: `n!` becomes `2ⁿ n²`.

**The diagnostic question:** *does the set of completions depend on the whole prefix, or only on a summary of it?* Whole prefix ⟹ backtrack. Summary ⟹ memoise. This is the single most valuable transfer between this module and [M11](M11-dynamic-programming.md).

### 8.4 Constraint propagation and DLX

- **AC-3 / constraint propagation** generalises Sudoku's look-ahead: after each assignment, repeatedly remove values that are now impossible anywhere, until nothing changes. Combined with MRV, it solves most Sudoku puzzles with **no search at all**.
- **Knuth's Algorithm X with Dancing Links (DLX)** solves *exact cover* — "choose rows so every column is covered exactly once" — with a doubly-linked-list trick that makes `unmake_move` a genuine `O(1)` pointer restore. Sudoku, N-queens, pentomino tiling and polyomino packing are all exact cover. If you find yourself writing a third backtracker for a placement puzzle, write a DLX instead.

### 8.5 When to stop writing search code

For `NP`-hard problems with real-world structure, a modern **SAT solver** (CDCL) or **CP-SAT** solver will usually beat a hand-written backtracker by orders of magnitude — they do clause learning, restarts, and conflict-driven backjumping that no hand-rolled search does. **The engineering skill is encoding your problem, not searching it.** Hand-written search is right when the problem has structure a general encoding would lose, when the instance is small, or when you are in an interview.

**And when the instance is simply too big for exact search,** the answer is heuristics — local search, simulated annealing, and approximation with a proven ratio. That is [M20 *(planned)*](INDEX.md#module-map), and Skiena signposts it in this chapter's opening: *"For problems that are too large to contemplate using combinatorial search, heuristic methods like simulated annealing are presented in Chapter 12."*

---

## Recognition Patterns

| Signal in the problem statement | Approach |
|---|---|
| "find **all** …" / "list every …" / "count the number of ways" and `n` is small | backtracking; the answer set is the output, so no cleverness can beat enumeration |
| `n ≤ 20` and the answer is a **subset** | `2ⁿ` enumeration, or pruned backtracking |
| `n ≤ 10–12` and the answer is an **ordering** | `n!` enumeration |
| `n ≤ 40` and the answer is a subset | **meet in the middle**, `2^{n/2}` |
| `n ≤ 20` and the future depends only on *which* items are used | **bitmask DP** ([M11](M11-dynamic-programming.md)), not backtracking |
| a **grid** to fill under constraints | backtracking + MRV + look-ahead |
| a **placement** puzzle (queens, pentominoes, exact cover) | backtracking with bitmask attack sets, or **DLX** |
| "the **best** arrangement", `n` small | branch and bound with an admissible lower bound |
| "shortest path" with a good distance estimate | **A\*** |
| "partition into `k` groups" | backtracking with the *canonical form* symmetry break (first element of each group increasing) |
| `n` in the hundreds and the problem is `NP`-hard | **stop searching** — heuristics ([M20 *(planned)*](INDEX.md#module-map)) or an off-the-shelf SAT/CP solver |

**The reflex worth building:** read the constraint bound *first*, before the problem. `n ≤ 20` and `n ≤ 200` are two different problems even with identical statements, and the bound is the author telling you which technique they had in mind.

---

## Common Mistakes

1. **Enumerating first and filtering later.** Legality tests belong in `construct_candidates`, where they kill subtrees, not in `is_a_solution`, where they kill leaves.
2. **Rebuilding auxiliary state instead of undoing it.** `make_move`/`unmake_move` is `O(1)`; recomputing from `a` is `O(state)`. Over an exponential tree that is the algorithm.
3. **Forgetting to undo.** Every `push_back` needs a `pop_back`, every `used[x] = 1` needs a `used[x] = 0`. Passing state **by value** (as `NQueens` does with its masks) removes the whole class of bug where it is affordable.
4. **The duplicate-skip written as `i > 0` instead of `i > start`.** Silently loses solutions.
5. **Forgetting to sort before deduplicating.** The duplicate-skip only works on adjacent equal values.
6. **A non-admissible bound in branch and bound.** If `h` can over-estimate, the algorithm is a heuristic that returns wrong answers, and it will look correct on small tests.
7. **Stopping at the first complete solution in best-first search.** It is not necessarily optimal — you must exhaust everything cheaper than the best found.
8. **Running best-first search on a large instance and running out of memory.** `202 063` queue entries versus `11` stack entries at `n = 11`; the gap grows exponentially.
9. **Not seeding the incumbent.** Bound pruning is inert until some complete solution exists. Greedy first, always.
10. **Ignoring symmetry.** Rotations, reflections, and interchangeable items routinely cost a factor of `n`, `2n`, or `k!`, and cost one `if` to remove.
11. **Choosing the state space carelessly.** "A square per queen" instead of "a column per row" is the difference between `C(64,8)` and `8!`.
12. **Deep recursion on large inputs.** Backtracking depth is `O(n)` and usually fine; the danger is a *path*-shaped search on `10⁶` nodes, the same stack hazard as [M08](M08-search-trees.md) and [M10](M10-union-find.md).

---

## Complexity Summary

| Task | Cost | Practical ceiling |
|---|---|---|
| all subsets of `n` | `Θ(2ⁿ)` nodes, `Θ(n·2ⁿ)` output | `n ≈ 25` |
| all permutations of `n` | `Θ(n!)` | `n ≈ 11` |
| all `k`-subsets | `Θ(C(n,k))` | depends |
| all simple `s`–`t` paths | no closed form; `Θ((n−2)!)` on `K_n` | graph-dependent |
| N-Queens (count) | `≈ O(n!)` with heavy pruning | `n ≈ 17` exact |
| Sudoku, MRV + look-ahead | ~`10⁴` nodes on the hardest published puzzles | trivial |
| exact TSP, backtracking | `(n−1)!` unpruned | `n ≈ 12` |
| exact TSP, branch and bound + A\* | instance-dependent | `n ≈ 20–40` |
| exact TSP, Held–Karp DP ([M11](M11-dynamic-programming.md)) | `O(2ⁿ n²)` time, `O(2ⁿ n)` space | `n ≈ 22` |
| meet in the middle | `O(2^{n/2}·n)` | `n ≈ 40–45` |
| iterative deepening | `b/(b−1)` × one full search, `O(depth)` space | any depth |

**The two rows worth internalising** are Held–Karp versus branch and bound for TSP: one is a **guarantee** (`O(2ⁿn²)` always), the other is a **gamble** (often far better, occasionally far worse). Which you want depends on whether you must promise a running time.

---

## One-Page Recall

- **Model:** a solution is a vector `a`, position `k` drawn from a candidate set `Sₖ`. Choosing that encoding is the design work.
- **Search:** DFS over the implicit backtrack tree. `O(height)` space — never BFS, whose queue is `O(width)` and exponential.
- **Five hooks:** `is_a_solution`, `construct_candidates`, `process_solution`, `make_move` / `unmake_move`. Plus a `finished` flag for early exit.
- **Sizes:** `10⁶` ≈ **20 items as subsets**, **10 items as permutations**. Read the constraints first.
- **Three prunes:** infeasibility (can't complete), bound (can't win), symmetry (already seen a relabelling).
- **Move legality tests into candidate generation** — it prunes subtrees, not leaves.
- **MRV** (most constrained next) shrinks the **branching factor**, and branching-factor savings **compound**: `(3/2)²⁰ ≈ 3325`.
- **Look ahead** (forward checking): if any open position has zero candidates, back off now.
- **Branch and bound:** priority queue on cost; the first complete solution is *not* necessarily optimal; the cost must be a **lower bound**.
- **A\*:** `f = g + h`, `h` an admissible lower bound on the *remainder*. Without `h`, short prefixes always win and nothing finishes. `h ≡ 0` is Dijkstra.
- **Space kills before time.** Best-first queue `202 063` vs DFS stack `11` at `n = 11`. Use IDA\* or DFS+bound.
- **Escape hatches:** iterative deepening (`O(depth)` space), meet in the middle (`2^{n/2}`), memoisation when the future depends only on a summary (that is DP), DLX for exact cover, SAT/CP when the instance is real.

---

## Practice — where to drill this module

| Idea in this module | Problem | Why it's the right drill |
|---|---|---|
| The subset state space | [78 · Subsets](https://leetcode.com/problems/subsets/) | write it three ways — bitmask loop, include/exclude recursion, and the `for i in [start,n)` template |
| Symmetry breaking on duplicates | [40 · Combination Sum II](https://leetcode.com/problems/combination-sum/) family · [131 · Palindrome Partitioning](https://leetcode.com/problems/palindrome-partitioning/) | the `i > start && v[i] == v[i-1]` line, and what breaks without it |
| The permutation state space | [46 · Permutations](https://leetcode.com/problems/permutations/) | in-place swap vs `used[]` vs `next_permutation` — all three, then compare |
| Candidate generation as pruning | [22 · Generate Parentheses](https://leetcode.com/problems/generate-parentheses/) | the *only* correct solution generates legal candidates; filtering `2^{2n}` strings afterwards is the mistake this module is about |
| Bitmask attack sets | [51 · N-Queens](https://leetcode.com/problems/n-queens/) · [52 · N-Queens II](https://leetcode.com/problems/n-queens-ii/) | write the `O(n)` set version first, then the three-mask version, and measure |
| MRV + look-ahead | [37 · Sudoku Solver](https://leetcode.com/problems/sudoku-solver/) | submit the naive version, then add MRV, then add look-ahead. **This is Skiena's table, reproduced by you** |
| `make_move` / `unmake_move` on a grid | [79 · Word Search](https://leetcode.com/problems/word-search/) · [212 · Word Search II](https://leetcode.com/problems/word-search-ii/) | 212 is the same search plus a trie — pruning by *the set of remaining words* |
| Backtracking vs bitmask DP | [698 · Partition to K Equal Sum Subsets](https://leetcode.com/problems/partition-to-k-equal-sum-subsets/) | solvable both ways; the DP is the memoised backtrack, and seeing that is the point |
| Combinatorial search on graphs | [CSES · Introductory Problems](https://cses.fi/problemset/) — *Chessboard and Queens*, *Grid Paths* | *Grid Paths* is a pruning exercise, not a search exercise: the naive version does not finish |

**Beyond LeetCode.** [CSES Problem Set](https://cses.fi/problemset/) — *Introductory Problems* and *Additional Problems*. [Codeforces `brute force` tag](https://codeforces.com/problemset?tags=brute+force) · [`bitmasks` tag](https://codeforces.com/problemset?tags=bitmasks) · [`meet-in-the-middle` tag](https://codeforces.com/problemset?tags=meet-in-the-middle).

**The drill that matters here** is not writing the recursion — after five problems the template is muscle memory. It is **measuring your own pruning**. Instrument every solver with a node counter, print it, add one prune, print it again. Skiena's Sudoku table is a report of exactly that experiment, and doing it yourself once is worth more than reading about it ten times.

---
## C++ Toolkit for This Module

*Language material from Weiss, **Data Structures and Algorithm Analysis in C++**, 4th ed., ch. 1 (parameter passing, references, templates) and §10.5 (backtracking algorithms).*

### 1. Recursive lambdas: three ways, and the trade

A backtracking helper wants to capture the surrounding state *and* call itself. A lambda cannot name itself, so:

```cpp
long long countLeavesThreeWays(int n) {
    // (a) std::function -- reads best, but every call is an INDIRECT call through
    //     type erasure, and the compiler will not inline it. Fine for notes and
    //     for n small; measurably slower in a hot search.
    function<long long(int)> byFunction = [&](int depth) {
        if (depth == n) return 1LL;
        return 2 * byFunction(depth + 1);
    };

    // (b) generic lambda taking ITSELF -- no type erasure, fully inlinable,
    //     slightly ugly. This is the competitive-programming idiom.
    auto bySelfParam = [&](auto&& self, int depth) -> long long {
        if (depth == n) return 1LL;
        return 2 * self(self, depth + 1);
    };

    return byFunction(0) + bySelfParam(bySelfParam, 0);
}
```

**(c) A member function of a small class** — what every implementation in this module's body uses. State lives in members instead of a capture list, the call is direct, and the search is easy to instrument (add a `nodeCount_` member). For anything you intend to profile, prefer (b) or (c).

### 2. Pass-by-value as an undo mechanism

`NQueens::placeRow` takes its three bitmasks **by value**:

```cpp
// inside NQueens::placeRow -- the three masks are parameters, so the recursive
// call constructs NEW values and the caller's copies are untouched
void recurseByValue(int row, unsigned columns, unsigned rising, unsigned falling,
                    unsigned bit, const function<void(int,unsigned,unsigned,unsigned)>& placeRow) {
    placeRow(row + 1, columns | bit, (rising | bit) << 1, (falling | bit) >> 1);
}
```

The caller's copies are untouched, so there is **no `unmake_move` at all**. Weiss's call-by-value discussion [§1.5.3, p.25] is usually about avoiding needless copies; here the copy is the feature. The rule of thumb:

| state | pass | undo |
|---|---|---|
| a few scalars or bitmasks | **by value** | free |
| a large array or grid | **by reference** | explicit `unmake_move` |

Copying a `9×9` Sudoku grid at every node would be `81` writes per node against `3` for the mask update — which is exactly why `SudokuBitmask` mutates and undoes while `NQueens` copies.

### 3. The four bit idioms

```cpp
int lowestSetBitIndex(unsigned mask)  { return __builtin_ctz(mask); }        // which bit
unsigned lowestSetBit(unsigned mask)  { return mask & (~mask + 1); }         // isolate it
unsigned clearLowestSetBit(unsigned m){ return m & (m - 1); }                // drop it
int setBitCount(unsigned mask)        { return __builtin_popcount(mask); }   // how many
```

Together they turn "iterate over the members of a set" into a loop that runs once per **member** rather than once per **candidate**:

```cpp
vector<int> membersOf(unsigned mask) {
    vector<int> members;
    for (unsigned bits = mask; bits; bits &= bits - 1)
        members.push_back(__builtin_ctz(bits));   // runs popcount(mask) times
    return members;
}
```

**Caveats.** `__builtin_ctz(0)` is **undefined** — guard the loop, as above. These are GCC/Clang builtins; C++20 offers `std::countr_zero` and `std::popcount` in `<bit>`. And use `__builtin_ctzll` / `__builtin_popcountll` for 64-bit masks: passing a `uint64_t` to the 32-bit version truncates silently.

### 4. `vector<char>`, never `vector<bool>`, for visited flags

`vector<bool>` is the bit-packed specialisation whose `operator[]` returns a **proxy object**, not a `bool&`. Taking a reference to an element does not compile, `&flags[i]` is not a `bool*`, and every access costs a shift and a mask. In a search that touches the array millions of times, `vector<char>` is both faster and less surprising. Same hazard as [M07](M07-hashing.md) toolkit; it bites hardest here.

### 5. `next_permutation`, and its precondition

```cpp
vector<int> distinctPermutationCount(vector<int> values) {
    sort(values.begin(), values.end());          // REQUIRED: it generates the NEXT
    vector<int> counts;                          // permutation in lexicographic
    do { counts.push_back((int)values.size()); } // order, so you must start at the
    while (next_permutation(values.begin(), values.end()));   // FIRST one
    return counts;
}
```

- **It returns `false` and wraps to the sorted order** when there is no next permutation — hence the `do/while`.
- **It handles duplicates correctly**, visiting each *distinct* permutation once. That is Skiena's exercise 9-2 solved by the standard library.
- It is `O(1)` amortised per step and `O(1)` extra space, which beats any hand-rolled recursion for the plain "visit all permutations" job.

### 6. Capture by reference, and what it means for lifetimes

Every backtracking lambda in this module captures `[&]`. That is right — the search must mutate the shared `partial` vector and the visited flags — but it makes the lambda **unsafe to store or return**: the moment the enclosing function exits, every capture dangles. Keep such lambdas local, and if a search helper must outlive its creator, make it a class with members (toolkit §1c).

### 7. Contiguous fixed-size grids

`array<array<int, 9>, 9>` is **one contiguous 81-int block**; `vector<vector<int>>` is nine separate heap allocations reached through nine pointers. For a solver that reads the grid millions of times the difference is measurable, and the fixed size is also a compile-time check that nobody hands you an `8×9` board. Use `array` when the dimensions are known at compile time, `vector` when they are not — the same reasoning as the `array<Key, 2*MinDegree-1>` in [M08](M08-search-trees.md)'s B-tree.

### 8. `reserve` on the output

`allSubsetsByMask` calls `subsets.reserve(1 << n)` before the loop. Without it, the vector reallocates `Θ(lg 2ⁿ) = Θ(n)` times and copies `Θ(2ⁿ)` elements in total — amortised `O(1)` per push ([M09](M09-amortized.md)), but with a constant nobody needs when the final size is known exactly. **When you know the answer's size, say so.**

### 9. Counting nodes, which is the point

Every solver in this module should be able to report how many nodes it expanded:

```cpp
struct SearchStats { long long nodes = 0, solutions = 0, prunes = 0; };
```

Skiena's Sudoku table and his TSP table are both just this counter, printed. **Adding it is how you find out whether a prune actually helped** — and the answer is often "no", which you will not discover by reasoning.

---
## Appendix — C++ for Every Pseudocode Block

```cpp
// The framework every entry below builds on: Skiena's five hooks, made explicit
// as virtual functions. The base class owns the solution vector `a` and the
// recursion; a derived class supplies the problem.
//
// Weiss avoids inheritance throughout his book ("there is almost no use of
// inheritance in the text"), and for data structures that is good advice. Here
// it is the right tool for one reason: the CONTROL FLOW is fixed and shared,
// while the five decisions vary. That is the textbook case for a template
// method, and writing it any other way duplicates the driver five times.
struct SearchStats {
    long long nodes = 0;        // calls to is_a_solution -- Skiena's `steps`
    long long solutions = 0;
};

class Backtracker {
public:
    virtual ~Backtracker() = default;

    void run(int startDepth = 0) { finished_ = false; backtrack(startDepth); }
    const SearchStats& stats() const { return stats_; }

protected:
    vector<int> a_;                       // the solution vector a = (a_1..a_k)
    SearchStats stats_;
    bool finished_ = false;               // the global `finished` flag

    // --- the five application-specific hooks -------------------------------
    virtual bool isASolution(int k) = 0;
    virtual vector<int> constructCandidates(int k) = 0;
    virtual void processSolution(int k) = 0;
    virtual void makeMove(int /*k*/) {}          // null stubs, as in Skiena's
    virtual void unmakeMove(int /*k*/) {}        // subset and permutation examples

private:
    // backtrack(a, k, input) -- the driver, unchanged for every problem below.
    void backtrack(int k) {
        ++stats_.nodes;
        if (isASolution(k)) {
            ++stats_.solutions;
            processSolution(k);
            return;
        }
        ++k;
        // A fresh candidate vector per call. Skiena notes why this matters:
        // "because a new candidates array c is allocated with each recursive
        // procedure call, the subsets of not-yet-considered extension candidates
        // at each position will not interfere with each other."
        const vector<int> candidates = constructCandidates(k);
        if ((int)a_.size() <= k) a_.resize(k + 1);
        for (int candidate : candidates) {
            a_[k] = candidate;
            makeMove(k);
            backtrack(k);
            unmakeMove(k);
            if (finished_) return;             // premature termination
        }
    }
};
```

### A1 Backtrack-DFS

*Pseudocode: §1, "The search".*

```cpp
// Backtrack-DFS(a, k)
//     if a = (a_1, a_2, ..., a_k) is a solution, report it.
//     else
//         k = k + 1
//         construct S_k, the set of candidates for position k of a
//         while S_k != empty do
//             a_k = an element in S_k
//             S_k = S_k - {a_k}
//             Backtrack-DFS(a, k)
//
// The abstract shape, with the problem supplied as three callables. Everything
// else in this appendix is this function with the callables filled in.
//
// Note what the recursion IS: a depth-first traversal of an implicit tree whose
// nodes are partial solutions. The tree is never built. The only memory the
// search uses is the path from the root to the current node -- O(HEIGHT), where
// a breadth-first version would need O(WIDTH), and width grows exponentially
// with height. That single sentence is why backtracking is a DFS.
static void backtrackDfs(vector<int>& a, int k,
                         const function<bool(const vector<int>&, int)>& isASolution,
                         const function<vector<int>(const vector<int>&, int)>& candidatesFor,
                         const function<void(const vector<int>&, int)>& report) {
    if (isASolution(a, k)) { report(a, k); return; }

    ++k;
    for (int candidate : candidatesFor(a, k)) {     // S_k, consumed one at a time
        if ((int)a.size() <= k) a.resize(k + 1);
        a[k] = candidate;
        backtrackDfs(a, k, isASolution, candidatesFor, report);
    }
}
```

**Complexity. `Θ(nodes in the backtrack tree)`**, which is the entire question and is problem-specific. Everything in this module is an attempt to make that tree smaller.

**The space bound is the fixed point.** `O(height)` for the recursion stack plus `O(n)` for `a`. Compare best-first search in [A8](#a8-branch-and-bound-for-tsp), which trades exactly this for a smaller tree and pays for it in memory.

**"Report it" hides a decision.** If `process_solution` prints, the output is the answer and no pruning can beat enumeration. If it *counts*, there may be a formula or a DP that skips the enumeration entirely. Always ask which you are being asked for.

### A2 The generic backtrack driver

*Pseudocode: §1, "The five hooks".*

```cpp
// backtrack(a, k, input)
//     if is_a_solution(a, k, input)
//         process_solution(a, k, input)
//     else
//         k = k + 1
//         construct_candidates(a, k, input, c, &nc)
//         for i = 0 to nc - 1
//             a[k] = c[i]
//             make_move(a, k, input)
//             backtrack(a, k, input)
//             unmake_move(a, k, input)
//             if finished  return
//
// Implemented above as `Backtracker`. The four notes worth attaching to it:
//
// 1. The `input` parameter of Skiena's C signature disappears in C++ -- it
//    becomes MEMBER STATE of the derived class, which is what it always wanted
//    to be. That is the one place where the C and C++ versions genuinely differ.
//
// 2. make_move / unmake_move are the pair people skip. Skiena: the auxiliary
//    structure "can always be rebuilt from scratch using the solution vector a,
//    but this can be inefficient when each move involves small incremental
//    changes that can easily be undone." Rebuilding is O(state) per node; undoing
//    is O(1). Over an exponential tree, that IS the algorithm. Same principle as
//    the rollback DSU in M10: do and undo, never rebuild.
//
// 3. `finished` allows early exit. Sudoku sets it after the first solution,
//    because the empty grid has 6,670,903,752,021,072,936,960 completions.
//
// 4. constructCandidates returning a vector BY VALUE is the C++17-correct
//    translation of `int c[MAXCANDIDATES]` plus `int *nc`: one return instead of
//    an out-parameter and a count, and the move on return costs nothing.
//    For a hot search, hand it a reusable buffer instead -- see the note below.
class CandidateBufferNote {
    // The allocation-free variant, when profiling says the vector matters:
    // give each DEPTH its own buffer, reused across siblings. Depth is bounded
    // by n, so this is O(n * maxCandidates) memory allocated ONCE.
    vector<vector<int>> buffersByDepth_;
public:
    explicit CandidateBufferNote(int maxDepth, int maxCandidates)
        : buffersByDepth_(maxDepth + 1) {
        for (auto& buffer : buffersByDepth_) buffer.reserve(maxCandidates);
    }
    vector<int>& bufferAt(int depth) {
        buffersByDepth_[depth].clear();
        return buffersByDepth_[depth];
    }
};
```

**Complexity. The driver adds `Θ(1)` per node**, plus whatever the hooks cost. The hooks are where all the time goes, and `construct_candidates` is where all the *pruning* goes.

**The single most valuable habit this framework encourages:** every legality test you can move from `is_a_solution` into `construct_candidates` prunes a **subtree** instead of a **leaf**. That is the difference between `Θ(n!)` and something finite, and it is why the two hooks are separate rather than one `is_legal`.

### A3 Constructing all subsets

*Pseudocode: §2.1.*

```cpp
// S_k = {true, false}; a is a solution when k == n.
// Because `true` is emitted first, the order is
//     {123}, {12}, {13}, {1}, {23}, {2}, {3}, {}
// -- all-true first, empty set last. Skiena: "Ironically, printing out each
// subset after constructing it proves to be the most complex of these three
// routines!"
class SubsetSearch : public Backtracker {
public:
    explicit SubsetSearch(int n) : n_(n) { a_.assign(n + 1, 0); }
    const vector<vector<int>>& found() const { return found_; }

protected:
    bool isASolution(int k) override { return k == n_; }

    vector<int> constructCandidates(int /*k*/) override {
        return {1, 0};                             // true, then false
    }

    void processSolution(int k) override {
        vector<int> chosen;
        for (int i = 1; i <= k; ++i)
            if (a_[i]) chosen.push_back(i);        // 1-indexed, as in the book
        found_.push_back(move(chosen));
    }

private:
    int n_;
    vector<vector<int>> found_;
};
```

**Complexity. `Θ(2ⁿ)` nodes, `Θ(n·2ⁿ)` to print.** The tree has `2^{n+1} − 1` nodes, of which `2ⁿ` are leaves — so **half the work is at the last level**, which is the fact that makes iterative deepening cheap ([A10](#a10-iterative-deepening-and-meet-in-the-middle)).

**You would not write this.** For `n ≤ 63` the subsets *are* the integers `0..2ⁿ−1`; iterate and read bits, as the body implementation does. **The recursion earns its place only when subtrees can be pruned** — "all subsets summing to `t`", "all subsets that are independent sets" — because a `for (mask = 0; mask < 1<<n; ++mask)` loop physically cannot skip a subtree and this can.

**The `k`-subset variant** is one changed candidate rule: track how many `true`s remain affordable and stop emitting `true` when the budget is spent, or `false` when the remaining positions are exactly the remaining budget. That prunes `Θ(2ⁿ)` down to `Θ(C(n,k))`.

### A4 Constructing all permutations

*Pseudocode: §2.2.*

```cpp
// S_k = {1..n} - {a_1, ..., a_{k-1}}; a is a solution when k == n.
// Emitted in LEXICOGRAPHIC order -- 123, 132, 213, 231, 312, 321 -- because
// candidates are generated in increasing order.
class PermutationSearch : public Backtracker {
public:
    explicit PermutationSearch(int n) : n_(n), inPermutation_(n + 1, 0) {
        a_.assign(n + 1, 0);
    }
    const vector<vector<int>>& found() const { return found_; }

protected:
    bool isASolution(int k) override { return k == n_; }

    // Skiena's point about this routine is the DATA STRUCTURE, not the logic:
    // "Testing whether i is a candidate for the kth slot could be done by
    // iterating through all k-1 elements of a and verifying that none of them
    // matched. However, we prefer to set up a bit-vector data structure to keep
    // track of which elements are in the partial solution. This gives a
    // CONSTANT-TIME legality check."
    // Here that bit-vector is maintained incrementally by make/unmakeMove, so
    // candidate generation is O(n) rather than O(n*k).
    vector<int> constructCandidates(int /*k*/) override {
        vector<int> candidates;
        candidates.reserve(n_);
        for (int value = 1; value <= n_; ++value)
            if (!inPermutation_[value]) candidates.push_back(value);
        return candidates;
    }

    void makeMove(int k)   override { inPermutation_[a_[k]] = 1; }
    void unmakeMove(int k) override { inPermutation_[a_[k]] = 0; }

    void processSolution(int k) override {
        found_.push_back(vector<int>(a_.begin() + 1, a_.begin() + k + 1));
    }

private:
    int n_;
    vector<char> inPermutation_;          // vector<char>, NOT vector<bool>
    vector<vector<int>> found_;
};
```

**Complexity. `Θ(n!)` leaves; `Θ(n · n!)` total work** with the incremental bit-vector, against `Θ(n² · n!)` if legality were rechecked by scanning.

**For `n ≤ 64`, `inPermutation_` should be a single `uint64_t`.** Candidate generation becomes `~used & fullMask`, and the loop over candidates becomes the `bits &= bits - 1` idiom — no array, no cache misses, and the mask is exactly the DP state a Held–Karp memoisation would key on ([M11](M11-dynamic-programming.md)). **That is the bridge between this module and bitmask DP:** the same `used` mask, cached instead of re-explored.

**Multisets need more (Skiena exercise 9-2).** `{1,1,2,2}` has 6 distinct permutations, not 24. The fix is the duplicate-skip symmetry break, or simply `sort` + `std::next_permutation`, which handles it correctly and iteratively.

### A5 All simple paths in a graph

*Pseudocode: §2.3.*

```cpp
// S_1 = {s}; S_{k+1} = neighbours of a_k not already in the partial path.
// a is a solution when a_k == t.
//
// Unlike subsets and permutations there is NO CLOSED FORM for the number of
// solutions: "the number of paths depends upon the structure of the graph."
// On a complete graph it is Theta((n-2)!); on a path it is 1.
class PathSearch : public Backtracker {
public:
    PathSearch(vector<vector<int>> adjacency, int source, int sink)
        : adjacency_(move(adjacency)), source_(source), sink_(sink),
          onPath_(adjacency_.size(), 0) {
        a_.assign(adjacency_.size() + 2, 0);
    }
    const vector<vector<int>>& found() const { return found_; }

protected:
    // a[k] == t. Note k >= 1: position 0 is unused, matching the book's
    // 1-indexed solution vector.
    bool isASolution(int k) override { return k >= 1 && a_[k] == sink_; }

    vector<int> constructCandidates(int k) override {
        if (k == 1) return {source_};              // always start from s
        vector<int> candidates;
        for (int next : adjacency_[a_[k - 1]])
            if (!onPath_[next]) candidates.push_back(next);
        return candidates;
    }

    void makeMove(int k)   override { onPath_[a_[k]] = 1; }
    void unmakeMove(int k) override { onPath_[a_[k]] = 0; }

    void processSolution(int k) override {
        found_.push_back(vector<int>(a_.begin() + 1, a_.begin() + k + 1));
    }

private:
    vector<vector<int>> adjacency_;
    int source_, sink_;
    vector<char> onPath_;
    vector<vector<int>> found_;
};
```

**Complexity. Output-sensitive**, `Θ(paths × path length)` with the `onPath_` check making each extension `O(deg)`.

**What this problem is *not*.** Counting simple `s`–`t` paths is `#P`-complete and finding the **longest** one is `NP`-hard. That is the same fact as "longest simple path has no optimal substructure" from [M11](M11-dynamic-programming.md), seen from the search side: there is no summary of the prefix that suffices, because *which* vertices were used changes what remains — so backtracking, not DP, unless `n ≤ 20` and you can afford a `2ⁿ` mask.

**`onPath_` is doing exactly what `in_perm` did in [A4](#a4-constructing-all-permutations)** — an incremental bit-vector giving an `O(1)` legality test. Recognising that two different-looking problems share one mechanism is most of what this chapter teaches.

### A6 N-Queens with pruning and symmetry

*Pseudocode: §3 (Skiena's chapter notes point to his solution in* Programming Challenges*).*

```cpp
// State space: a_i = the COLUMN of the queen in row i. That encoding removes all
// row conflicts for free. The alternative -- "a square per queen" -- is
// C(64,8) = 4.4 billion for the standard board against 8! = 40,320 here.
// SAME problem, SAME pruning, catastrophically different state space.
class NQueensLiteral : public Backtracker {
public:
    explicit NQueensLiteral(int boardSize) : boardSize_(boardSize) {
        a_.assign(boardSize + 1, 0);
    }
    long long solutionCount() const { return stats_.solutions; }

protected:
    bool isASolution(int k) override { return k == boardSize_; }

    // INFEASIBILITY PRUNING, done in candidate generation rather than in a later
    // legality test -- which is the difference between pruning a SUBTREE and
    // pruning a LEAF.
    vector<int> constructCandidates(int k) override {
        vector<int> candidates;
        for (int column = 1; column <= boardSize_; ++column) {
            bool safe = true;
            for (int earlierRow = 1; earlierRow < k && safe; ++earlierRow) {
                const int earlierColumn = a_[earlierRow];
                if (earlierColumn == column) safe = false;                  // file
                if (k - earlierRow == abs(column - earlierColumn)) safe = false;  // diagonal
            }
            // SYMMETRY BREAK: a solution and its left-right mirror are the same
            // arrangement, so the queen in row 1 need only be tried in the left
            // half. Halves the search; the mirrored solutions can be recovered
            // afterwards (with care for the self-symmetric middle column).
            if (safe && (k > 1 || column <= (boardSize_ + 1) / 2))
                candidates.push_back(column);
        }
        return candidates;
    }

    void processSolution(int /*k*/) override {}      // counting only

private:
    int boardSize_;
};
```

**Complexity. `O(n!)` in the worst case, far less in practice.** The candidate scan above is `O(n·k)` per node; the bitmask version in the body is `O(1)` per candidate and is what you should write.

**Two prunes, two kinds.** The conflict test is **infeasibility** pruning — this partial board cannot be completed with a queen there. The half-board restriction on row 1 is **symmetry** pruning — that branch is a mirror of one already explored. They are independent, and forgetting the second is the more common omission.

**Known counts, useful as a self-check:** `n = 1..12` gives `1, 0, 0, 2, 10, 4, 40, 92, 352, 724, 2680, 14200`. If your solver disagrees at `n = 6` (the answer is **4**, not 8 — most people guess wrong), the bug is in the diagonal test.

### A7 Sudoku with MRV and look-ahead

*Pseudocode: §4.*

```cpp
// The state space is the set of OPEN squares; the candidates for (i,j) are the
// digits absent from row i, column j and the 3x3 sector.
//
// The two decisions that matter, and Skiena's measurements for them:
//
//   next_square:     arbitrary       vs  most constrained
//   possible_values: local count     vs  look ahead
//
//                                         Easy      Medium    Hard
//   arbitrary       + local count      1,904,832    863,305   never finished
//   arbitrary       + look ahead             127        142   12,507,212
//   most constrained+ local count             48         84    1,243,838
//   most constrained+ look ahead              48         65       10,374
//
// Neither heuristic changes the ANSWER. Both change the shape of the tree.
class SudokuLiteral : public Backtracker {
public:
    static const int SIDE = 9, CELLS = SIDE * SIDE;

    explicit SudokuLiteral(vector<vector<int>> grid) : grid_(move(grid)) {
        a_.assign(CELLS + 1, 0);
        chosenSquare_.assign(CELLS + 1, {-1, -1});
        freeCount_ = 0;
        for (int r = 0; r < SIDE; ++r)
            for (int c = 0; c < SIDE; ++c) if (grid_[r][c] == 0) ++freeCount_;
    }
    // The SOLVED grid, captured at the moment of success. It cannot be read off
    // grid_ afterwards: the driver calls unmakeMove on the way out of every frame
    // BEFORE it checks `finished`, so by the time run() returns, grid_ is back to
    // its original state. Skiena hits the same thing and answers it the same way
    // -- his process_solution PRINTS the board right there. Anything the caller
    // needs must be captured inside process_solution, not after it.
    const vector<vector<int>>& solution() const { return solved_; }
    bool solved() const { return !solved_.empty(); }

protected:
    bool isASolution(int /*k*/) override { return freeCount_ == 0; }

    // next_square + possible_values, fused. Returning an EMPTY candidate list is
    // how both "no legal digit here" and "look-ahead says this branch is dead"
    // are reported -- the driver then simply backtracks.
    vector<int> constructCandidates(int k) override {
        int bestRow = -1, bestColumn = -1, bestCount = SIDE + 1;
        vector<int> bestDigits;

        // MOST CONSTRAINED SQUARE. Costs O(81 * 9) per node and is worth it many
        // times over, because it shrinks the BRANCHING FACTOR and branching
        // factor savings COMPOUND: 3^20 / 2^20 is a factor of ~3325.
        for (int r = 0; r < SIDE; ++r)
            for (int c = 0; c < SIDE; ++c) {
                if (grid_[r][c] != 0) continue;
                vector<int> digits = possibleValues(r, c);
                if ((int)digits.size() < bestCount) {
                    bestCount = (int)digits.size();
                    bestDigits = move(digits);
                    bestRow = r; bestColumn = c;
                    // LOOK AHEAD: a blank square with zero candidates means this
                    // partial solution is already doomed. "But why wait, since
                    // all our efforts until then will be wasted?"
                    if (bestCount == 0) { chosenSquare_[k] = {r, c}; return {}; }
                }
            }
        if (bestRow < 0) return {};
        chosenSquare_[k] = {bestRow, bestColumn};
        return bestDigits;
    }

    void makeMove(int k) override {
        const auto [r, c] = chosenSquare_[k];
        grid_[r][c] = a_[k];
        --freeCount_;
    }
    void unmakeMove(int k) override {
        const auto [r, c] = chosenSquare_[k];
        grid_[r][c] = 0;
        ++freeCount_;
    }

    // Official Sudoku puzzles have a unique solution, so stopping at the first is
    // safe. The empty grid does not: it has 6,670,903,752,021,072,936,960
    // completions, and `finished` is how we avoid meeting all of them.
    void processSolution(int /*k*/) override { solved_ = grid_; finished_ = true; }

private:
    vector<vector<int>> grid_;
    vector<vector<int>> solved_;             // captured in processSolution
    vector<pair<int,int>> chosenSquare_;      // which square position k filled
    int freeCount_ = 0;

    vector<int> possibleValues(int row, int column) const {
        array<bool, SIDE + 1> used{};
        for (int i = 0; i < SIDE; ++i) { used[grid_[row][i]] = true; used[grid_[i][column]] = true; }
        const int boxRow = (row / 3) * 3, boxColumn = (column / 3) * 3;
        for (int r = 0; r < 3; ++r)
            for (int c = 0; c < 3; ++c) used[grid_[boxRow + r][boxColumn + c]] = true;
        vector<int> digits;
        for (int d = 1; d <= SIDE; ++d) if (!used[d]) digits.push_back(d);
        return digits;
    }
};
```

**Complexity. Bounded by the tree, which the heuristics shrink by four orders of magnitude.** The measured node counts are the table above.

**Read the solution inside `process_solution`, not after `run` returns.** The driver calls `unmake_move` on the way out of every frame *before* it tests `finished`, so the board is fully unwound by the time control comes back. Skiena's version prints there and never notices; a version that stores the answer must copy it at that moment, which is why `solved_` exists. **This is a genuine sharp edge of the generic-driver design**, and it caught this implementation the first time it was run.

**Why `chosenSquare_` exists.** The driver's solution vector `a` holds one integer per position, which is enough for the digit but not for the *coordinates* of the square. Skiena hits the same wall and solves it the same way: *"we keep a separate array of move positions as part of our boardtype data type."* This is a real limitation of the generic framework and worth noticing — the framework assumes each position of `a` has a fixed meaning, and MRV breaks that assumption.

**MRV subsumes look-ahead here** — a zero-candidate square is the most constrained square there is, so the MRV scan finds the contradiction for free. Skiena keeps them separate because his implementation excluded already-filled squares from `next_square`, which prevented the collapse; his own footnote says so.

*Verified:* on a 17-clue puzzle (the minimum number of clues known to admit a unique solution — Skiena's "Hard" instance is of this kind) this implementation reports **4 836 nodes**, the same order as Skiena's measured 10 374 for the most-constrained + look-ahead row. Every row, column and box of the returned grid was checked to be a permutation of 1–9, and every original clue was checked to be unchanged.

### A8 Branch and bound for TSP

*Pseudocode: §6.*

```cpp
// BEST-FIRST SEARCH / BRANCH AND BOUND. Instead of exploring candidates in
// whatever order construct_candidates produced, keep every partial solution in a
// PRIORITY QUEUE keyed by cost, and always expand the cheapest.
//
//   while top(q).cost < best_cost
//       s = extract_min(q)
//       if is_a_solution(s) then process_solution(s)
//       else for each candidate: extend, insert, contract
//
// THE SUBTLE PART: the first complete solution pulled off the queue is NOT
// necessarily optimal. "There was certainly no cheaper PARTIAL solution
// available when we pulled it off the priority queue. But extending this partial
// solution came with a cost." So the loop runs until everything remaining is
// already more expensive than the best complete solution found -- and for THAT
// to be sound, the key must be a LOWER BOUND on every completion.
struct PartialTour {
    long long key = 0;              // the priority: g, or g + h for A* (A9)
    long long costSoFar = 0;
    vector<int> cities;             // the prefix, always starting at city 0
    bool operator>(const PartialTour& other) const { return key > other.key; }
};

class TspBestFirst {
public:
    explicit TspBestFirst(vector<vector<long long>> distance)
        : distance_(move(distance)), n_((int)distance_.size()) {}

    virtual ~TspBestFirst() = default;

    long long solve() {
        if (n_ <= 1) return 0;
        // first_solution / solution_cost: seed the incumbent with a cheap
        // heuristic tour. Bound pruning is INERT until a finite best exists.
        bestCost_ = nearestNeighbourTour();
        prepare();

        priority_queue<PartialTour, vector<PartialTour>, greater<PartialTour>> queue;
        queue.push(PartialTour{lowerBound({0}, 0), 0, {0}});   // city 0 fixed: rotation symmetry

        while (!queue.empty() && queue.top().key < bestCost_) {
            const PartialTour partial = queue.top(); queue.pop();
            peakQueueSize_ = max(peakQueueSize_, (long long)queue.size());

            if ((int)partial.cities.size() == n_) {            // is_a_solution
                const long long total = partial.costSoFar + distance_[partial.cities.back()][0];
                if (total < bestCost_) { bestCost_ = total; bestTour_ = partial.cities; }
                continue;
            }
            vector<char> used(n_, 0);
            for (int city : partial.cities) used[city] = 1;
            for (int next = 1; next < n_; ++next) {            // construct_candidates
                if (used[next]) continue;
                PartialTour extended = partial;                // extend_solution
                extended.costSoFar += distance_[partial.cities.back()][next];
                extended.cities.push_back(next);
                extended.key = lowerBound(extended.cities, extended.costSoFar);
                if (extended.key < bestCost_) queue.push(extended);
            }                                                  // contract_solution is
        }                                                      // implicit: `partial` is a copy
        return bestCost_;
    }

    long long peakQueueSize() const { return peakQueueSize_; }
    const vector<int>& bestTour() const { return bestTour_; }

protected:
    vector<vector<long long>> distance_;
    int n_;
    long long bestCost_ = LLONG_MAX, peakQueueSize_ = 0;
    vector<int> bestTour_;

    virtual void prepare() {}

    // Skiena's FIRST cost function: just the prefix cost. It is a valid lower
    // bound when all weights are nonnegative -- and it is a WEAK one. See A9.
    virtual long long lowerBound(const vector<int>& /*cities*/, long long costSoFar) const {
        return costSoFar;
    }

    long long nearestNeighbourTour() const {
        vector<char> seen(n_, 0);
        int at = 0; seen[0] = 1;
        long long total = 0;
        for (int step = 1; step < n_; ++step) {
            int best = -1;
            for (int v = 0; v < n_; ++v)
                if (!seen[v] && (best < 0 || distance_[at][v] < distance_[at][best])) best = v;
            seen[best] = 1; total += distance_[at][best]; at = best;
        }
        return total + distance_[at][0];
    }
};
```

**Complexity. Instance-dependent**, but Skiena's Figure 9.9 measures it: at `n = 11`, `(n−1)! = 3 628 800` full tours become **848** solution evaluations with `cost < best`.

**And the price:** *"For `n = 11`, the queue size got to **202 063** compared to a stack size of just **11** for backtracking. **Space will kill you quicker than time.**"* `peakQueueSize()` is exposed above so you can watch it happen.

**Every partial solution is copied into the queue**, vector and all — `O(n)` per push. That is not an implementation flaw to optimise away; it is the memory cost of remembering the frontier, which is what best-first search *is*. If it hurts, the answer is not a smarter allocator, it is DFS with the same bound (the body implementation) or **IDA\*** ([A10](#a10-iterative-deepening-and-meet-in-the-middle)).

*Verified:* on 120 random distance matrices (`n ≤ 8`) `TspBestFirst`, `TspAStar` and `TspAStarTighter` all matched brute-force enumeration of every `(n−1)!` tour. On one `n = 9` instance the measured **peak queue size was 2 101 for the plain bound and 1 562 for the A\* bound** — a tighter bound shrinking the *frontier*, not just the node count, which is the second reason it is worth having.

### A9 A\* lower bounds

*Pseudocode: §7.*

```cpp
// partial_solution_cost(s) = sum of the edges already in the prefix
// partial_solution_lb(s)   = partial_solution_cost(s) + (n - k + 1) * minlb
//
// THE PROBLEM A* FIXES: with the key equal to the prefix cost, SHORT PREFIXES
// ALWAYS LOOK BETTER THAN LONG ONES. "Even the most awful prefix path on n/2
// nodes will likely be cheaper than the optimal solution on all n nodes, meaning
// that we must expand all partial solutions until their prefix cost is greater
// than the cost of the best full tour."
//
// THE FIX: price a partial solution at g + h, where h is a LOWER BOUND on the
// cost still to come. With k of n cities placed, n - k + 1 edges remain, and
// none can be cheaper than the cheapest edge in the instance.
//
// h must be ADMISSIBLE -- never an over-estimate -- or the search stops early on
// a non-optimal answer and looks perfectly healthy while doing it.
class TspAStar : public TspBestFirst {
public:
    using TspBestFirst::TspBestFirst;

protected:
    void prepare() override {
        cheapestEdge_ = LLONG_MAX;
        for (int u = 0; u < n_; ++u)
            for (int v = 0; v < n_; ++v)
                if (u != v) cheapestEdge_ = min(cheapestEdge_, distance_[u][v]);
    }

    long long lowerBound(const vector<int>& cities, long long costSoFar) const override {
        const int placed = (int)cities.size();
        return costSoFar + (long long)(n_ - placed + 1) * cheapestEdge_;
    }

private:
    long long cheapestEdge_ = 0;
};

// A TIGHTER admissible bound, and the one real solvers build on: for every city
// still to be visited, add the cheapest edge leaving it. This dominates the
// single-global-minimum bound (each term is at least as large) and is still a
// lower bound, because the optimal completion must leave each unvisited city
// exactly once. Tighter bound => more pruning per node, at more cost per node;
// where the trade lands is instance-dependent and worth MEASURING.
class TspAStarTighter : public TspBestFirst {
public:
    using TspBestFirst::TspBestFirst;

protected:
    void prepare() override {
        cheapestOut_.assign(n_, LLONG_MAX);
        for (int u = 0; u < n_; ++u)
            for (int v = 0; v < n_; ++v)
                if (u != v) cheapestOut_[u] = min(cheapestOut_[u], distance_[u][v]);
    }

    long long lowerBound(const vector<int>& cities, long long costSoFar) const override {
        vector<char> used(n_, 0);
        for (int city : cities) used[city] = 1;
        long long remaining = cheapestOut_[cities.back()];      // the edge leaving the prefix
        for (int v = 0; v < n_; ++v)
            if (!used[v]) remaining += cheapestOut_[v];         // and one leaving each unvisited
        return costSoFar + remaining;
    }

private:
    vector<long long> cheapestOut_;
};
```

**Complexity.** The plain bound is `O(1)` per node; the tighter one is `O(n)`. Skiena's measurements for the plain version:

| `n` | all `(n−1)!` | backtrack `cost<best` | backtrack `lb<best` | B&B `cost<best` | **B&B + A\*** |
|---|---|---|---|---|---|
| 9 | 40 320 | 2 509 | 1 619 | 354 | **264** |
| 11 | 3 628 800 | 12 695 | 6 391 | 848 | **705** |

**Two independent improvements.** `cost → lb` is a better *bound*; backtracking → best-first is a better *order*. Each helps on its own, and both together give `3 628 800 → 705`.

**Admissibility is the entire correctness condition**, and it is easy to violate by accident — using an average edge instead of a minimum, or forgetting the return edge to city 0, turns an exact algorithm into a fast wrong one. **Test any new bound by comparing against brute force on small instances**; a non-admissible bound produces answers that are *plausible*, which is the worst failure mode there is.

**A\* beyond TSP.** With `h ≡ 0`, A\* **is** Dijkstra. With `h(v)` = straight-line distance to the target on a road network, it is what your phone does — no road beats the crow, so `h` is admissible, and the search grows an ellipse toward the destination instead of a disk in every direction ([M15](M15-shortest-paths.md)). When `h` is also **consistent** (`h(u) ≤ w(u,v) + h(v)`), A\* is exactly Dijkstra on the reduced weights `w′(u,v) = w(u,v) − h(u) + h(v) ≥ 0` — **Johnson's reweighting**, wearing a different hat.

### A10 Iterative deepening and meet in the middle

*Pseudocode: §8 (not in Skiena's chapter; the standard escapes from its two limits).*

```cpp
// ------------------------------------------------- ITERATIVE DEEPENING (IDA*)
// The answer to "best-first search runs out of memory". Repeated DEPTH-FIRST
// search with an increasing threshold on f = g + h: O(depth) space, and the same
// node ORDER guarantee as A*.
//
// The re-expansion is nearly free. In a tree with branching factor b, the last
// level holds a (b-1)/b fraction of all nodes, so the total work over all
// iterations is b/(b-1) times a single full search: 2x for b = 2, 1.5x for b = 3.
// You pay a small constant to remove an exponential space bound.
//
// Returns the optimal cost, exploring states through the three callables:
//   heuristic(state)  -- an ADMISSIBLE lower bound on the cost still to come
//   isGoal(state)
//   expand(state)     -- (nextState, edgeCost) pairs
template <class State>
long long idaStar(const State& start,
                  const function<bool(const State&)>& isGoal,
                  const function<long long(const State&)>& heuristic,
                  const function<vector<pair<State,long long>>(const State&)>& expand,
                  long long ceiling) {
    long long threshold = heuristic(start);

    // Returns the cost if the goal was reached within `threshold`, otherwise the
    // SMALLEST f-value that exceeded it -- which becomes the next threshold.
    // Raising the threshold to exactly that value is what keeps the number of
    // iterations small; incrementing by 1 would be correct and far slower.
    function<long long(const State&, long long, long long&)> search =
        [&](const State& state, long long costSoFar, long long& nextThreshold) -> long long {
            const long long estimate = costSoFar + heuristic(state);
            if (estimate > threshold) { nextThreshold = min(nextThreshold, estimate); return -1; }
            if (isGoal(state)) return costSoFar;
            for (const auto& [next, stepCost] : expand(state)) {
                const long long found = search(next, costSoFar + stepCost, nextThreshold);
                if (found >= 0) return found;
            }
            return -1;
        };

    while (threshold <= ceiling) {
        long long nextThreshold = LLONG_MAX;
        const long long found = search(start, 0, nextThreshold);
        if (found >= 0) return found;
        if (nextThreshold == LLONG_MAX) return -1;      // exhausted: no solution
        threshold = nextThreshold;
    }
    return -1;
}

// --------------------------------------------------------- MEET IN THE MIDDLE
// The answer to "2^n is too big but 2^(n/2) is not". Split the items in half,
// enumerate each half's 2^(n/2) subset sums, sort one side, and binary-search it
// from the other. O(2^(n/2) * n) -- which moves the practical wall from n ~ 30
// to n ~ 40-45.
//
// Counts the subsets summing to exactly `target`.
long long meetInTheMiddleCount(const vector<long long>& values, long long target) {
    const int n = (int)values.size();
    const int leftSize = n / 2, rightSize = n - leftSize;

    const auto allSubsetSums = [&](int from, int count) {
        vector<long long> sums;
        sums.reserve((size_t)1 << count);
        for (uint64_t mask = 0; mask < (1ULL << count); ++mask) {
            long long total = 0;
            for (uint64_t bits = mask; bits; bits &= bits - 1)
                total += values[from + __builtin_ctzll(bits)];
            sums.push_back(total);
        }
        return sums;
    };

    vector<long long> leftSums  = allSubsetSums(0, leftSize);
    vector<long long> rightSums = allSubsetSums(leftSize, rightSize);
    sort(rightSums.begin(), rightSums.end());

    long long count = 0;
    for (long long leftTotal : leftSums) {
        // equal_range, not two separate calls: one traversal, both bounds, and it
        // counts MULTIPLICITY correctly when several right-subsets share a sum.
        const auto range = equal_range(rightSums.begin(), rightSums.end(), target - leftTotal);
        count += distance(range.first, range.second);
    }
    return count;
}
```

**Complexity.** IDA\*: `b/(b−1)` × one A\* search in time, **`O(depth)` in space**. Meet in the middle: `O(2^{n/2} · n)` time and `O(2^{n/2})` space.

**IDA\* is how 15-puzzle and Rubik's-cube solvers are written**, and the reason is entirely the space bound: A\* on the 15-puzzle exhausts memory long before it exhausts patience. Raising the threshold to the *smallest exceeded `f`* rather than by a fixed step is what keeps the number of iterations proportional to the number of distinct `f`-values rather than to the cost range.

**Meet in the middle is the standard `n ≤ 40` answer**, and it is the same idea as the `O(2^{n/2}·n)` subset-sum note in [M11](M11-dynamic-programming.md): when the *target* is astronomical (so a pseudo-polynomial DP table is out) but `n` is small, split and sort.

**The generalisation worth carrying away:** both techniques trade a *repeated* or *doubled* amount of work for an *exponentially* smaller resource — time for space in IDA\*, space for time in meet in the middle. Recognising which resource is actually binding is the decision; the code is fifteen lines either way.


---

*Next: [M18 — String Matching and Suffix Structures](M18-strings.md) (CLRS 32 + Skiena 3.9, 21) — naive matching, Rabin–Karp, KMP, finite automata, tries, and the suffix structures that make "find every occurrence" linear.*
