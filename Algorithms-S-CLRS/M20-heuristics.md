# Module 20 — Coping With Hard Problems

**Sources:** CLRS 4e ch. 35 (Approximation Algorithms) · Skiena 3e ch. 12 (Dealing with Hard Problems)

---

## Big Idea

[M19](M19-np-completeness.md) ended with a proof that a problem is intractable. **This module is what happens next**, and Skiena opens the chapter by refusing to let you off the hook:

> *"For the practical person, demonstrating that a problem is NP-complete is never the end of the line. Presumably, there was a reason why you wanted to solve it in the first place. That application won't go away after you learn there is no polynomial-time algorithm. You still seek a program that solves the problem of interest. All you know is that you won't find one that quickly solves the problem to optimality in the worst case."*

**"To optimality" and "in the worst case" are the two words you get to negotiate.** Give up one of them and the problem becomes tractable. Skiena's three escape routes:

| Route | What you surrender | Module |
|---|---|---|
| **Fast in the average case** | worst-case running time | backtracking + pruning, [M17](M17-backtracking.md); DPLL, [M19](M19-np-completeness.md) |
| **Heuristics** | *any* guarantee about answer quality | this module, Parts 9–11 |
| **Approximation algorithms** | optimality, but *by a proven factor* | this module, Parts 3–8 |

**The single technique that makes approximation possible.** You cannot compare your answer to the optimum, because you cannot compute the optimum — that was the whole problem. So you compare your answer to something *below* the optimum that you *can* compute. CLRS states it as the moral of §35.1:

> *"The approximation ratio comes from relating the size of the solution returned to the lower bound."*

Every approximation proof in this module has exactly this shape:

```
    my answer  ≤  k · L        (I can prove this about my algorithm)
            L  ≤  OPT          (I can prove L is a lower bound)
    ──────────────────────────
    my answer  ≤  k · OPT
```

and the entire creative act is **finding the `L`**. Once you see this, the chapter stops being a bag of tricks:

| Problem | The lower bound `L` |
|---|---|
| vertex cover | the size of a **maximal matching** (no cover can be smaller than one vertex per matching edge) |
| TSP with triangle inequality | the weight of the **minimum spanning tree** (delete an edge from the optimal tour and you have a spanning path) |
| minimum-weight vertex cover | the optimum of the **LP relaxation** (a superset of feasible points can only do better) |
| set cover | how many elements a **single set** can still cover |
| makespan scheduling | `max pₖ` and the **average machine load** |
| bin packing | `⌈∑ sᵢ⌉` |

**And the corresponding upper-bound idiom for maximisation:** if the *average* solution is good, a *random* solution is good, so a random assignment satisfies `7/8` of the clauses of any 3-CNF formula and a random vertex ordering keeps half the edges of any digraph acyclic. Skiena calls this *"when average is good enough"*, and it is the cheapest guarantee in the book.

**When no ratio can be proven, you fall back on search that has no guarantee at all** — random sampling, hill climbing, simulated annealing — and Skiena is unusually direct about which of those to use:

> *"Simulated annealing is my heuristic method of choice for optimization problems."*

**Remember months later:** *an approximation algorithm's ratio always comes from a **computable lower bound on the optimum**, never from the optimum itself. Vertex cover: take both endpoints of a maximal matching → 2. Metric TSP: shortcut a doubled MST → 2; Christofides (MST + min-weight matching on odd-degree vertices) → 3/2. Set cover: greedy → `ln n`, and that is tight. MAX-3-SAT: flip coins → 7/8. Subset sum: trim the reachable-sums list by `ε/2n` → FPTAS. When nothing has a ratio: simulated annealing.*

---

## What You Should Be Able To Do After This Chapter

- Name Skiena's **three routes** past an `NP`-completeness proof, and say what each one gives up.
- Define **`ρ(n)`-approximation**, and write the ratio definition that works for both minimisation and maximisation: `max(C/C*, C*/C) ≤ ρ(n)`.
- Distinguish an **approximation scheme**, a **PTAS**, and an **FPTAS**, and say exactly where `1/ε` is allowed to appear.
- Write `APPROX-VERTEX-COVER` from memory and prove the factor 2 — including the sentence *"the edges the algorithm picks form a matching."*
- Explain why the "obviously smarter" heuristics for vertex cover (keep one endpoint; take the highest-degree vertex) are **worse**, with the star and the `Θ(lg n)` bipartite counterexample.
- Give the **randomized** vertex-cover heuristic and its expected-factor-2 argument.
- Prove that the MST is a lower bound on the optimal tour, and that shortcutting a doubled MST is a 2-approximation **under the triangle inequality**.
- Explain **Christofides**: why odd-degree vertices are the obstacle, why a perfect matching on them costs at most half the optimal tour, and where `3/2` comes from.
- Reproduce **Theorem 35.3**: general TSP has no constant-factor approximation unless `P = NP` — via `HAM-CYCLE` with weights `1` and `ρ|V| + 1`.
- Prove the `7/8` bound for random assignment on MAX-3-CNF (Theorem 35.5), and generalise it to MAX-*k*-SAT and MAX-CUT.
- Give the two-line algorithm for **maximum acyclic subgraph** and its factor-2 proof.
- Analyse `GREEDY-SET-COVER` both ways: CLRS's harmonic-number argument (Theorem 35.4) and Skiena's **milestone/width** argument.
- Set up the **0-1 integer program** for weighted vertex cover, write its **LP relaxation**, and prove that rounding at `1/2` gives a 2-approximation (Theorem 35.6).
- Explain the **subset-sum FPTAS**: why the list is trimmed, why the parameter is `ε/2n` and not `ε`, and where the list-length bound `3n ln t / ε + 2` comes from.
- Give the three ingredients every **heuristic search** needs: solution representation, cost function, transition mechanism — and say why incremental cost evaluation is the whole game.
- Say when **random sampling** actually works, and why it is hopeless on TSP.
- Explain why **hill climbing** gets stuck, and what simulated annealing changes.
- Write the **simulated annealing** acceptance rule and name the five cooling-schedule parameters.
- Repeat Skiena's verdict on **genetic algorithms**, and say what a quantum computer does and does not do to `NP`.

---

## Part 1 — The Three Escape Routes (Skiena 12.1)

**Approximation algorithms come with a contract.** Skiena:

> *"Approximation algorithms produce solutions with a guarantee attached, namely that the quality of the optimal solution is provably bounded by the quality of your heuristic solution. Thus, no matter what your input instance is and how lucky you are, such an approximation algorithm is destined to produce a correct answer. Furthermore, provably good approximation algorithms are often conceptually simple, fast, and easy to program."*

**But a guarantee is a floor, not a ceiling**, and this is the part people get wrong:

> *"One thing that is usually not clear, however, is how well the solution from an approximation algorithm compares to what you might get from a heuristic that gives you no guarantees. The answer may be worse, or it could be better. Leaving your money in a bank savings account may guarantee you 3% interest without risk. Still, you likely will do much better investing your money in stocks than leaving it in the bank, even though performance is not guaranteed."*

**So do both.** This is the single most practical sentence in the chapter:

> *"One way to get the best of approximation algorithms and unwashed heuristics is to run both of them on the given problem instance, and pick the solution giving the better result. This way, you will get a solution that comes with a guarantee and a second chance to do even better."*

That is not a compromise — it is strictly better than either. The approximation algorithm's *proof* still applies to the pair, because you only ever swap in an answer that is at least as good.

### Unified Understanding

Two books, one framework. CLRS gives the definitions and the theorems; Skiena gives the judgement about which route to take and when. They agree on every algorithm in the chapter, and they even choose the same three examples (vertex cover, TSP, set cover) — which is a decent signal that those three are the ones to know cold.

**Skiena emphasis:** the escape routes, the counterexamples that kill plausible heuristics, and heuristic search (random sampling → hill climbing → simulated annealing) as an engineering practice with cooling schedules you tune by hand.

**CLRS emphasis:** the `ρ(n)` formalism, PTAS/FPTAS, the proofs of every ratio, LP relaxation and rounding, and the subset-sum FPTAS — none of which is in Skiena.

---

## Part 2 — What "Approximation Ratio" Actually Means (CLRS 35 intro)

**Setup.** An optimisation problem has a cost `C` for each feasible solution and an optimum `C*`. An algorithm returns a solution of cost `C`.

> An algorithm has an **approximation ratio of `ρ(n)`** if, for any input of size `n`,
> ```
> max( C/C* , C*/C )  ≤  ρ(n)
> ```
> We call it a **`ρ(n)`-approximation algorithm**.

**Why the `max` of both fractions.** So that one definition covers both directions. For a **minimisation** problem `C ≥ C*`, so the live term is `C/C*`. For a **maximisation** problem `C ≤ C*`, so the live term is `C*/C`. Either way `ρ(n) ≥ 1`, and `ρ(n) = 1` means the algorithm is exact.

> **This is why the MAX-3-SAT bound is `8/7` and not `7/8`.** The algorithm satisfies `7/8` of the clauses, so `C*/C ≤ m / (7m/8) = 8/7`. Interview answers that say "a 7/8-approximation" are describing the *fraction achieved*; CLRS's ratio is its reciprocal. Both are used in the literature — say which you mean.

**Randomized version.** Same definition with `C` replaced by the **expected** cost `E[C]`; the result is a **randomized `ρ(n)`-approximation algorithm**.

**When the ratio can be dialled in.** Some problems admit an algorithm that takes `ε > 0` as an extra input:

| Name | Definition | Time may look like |
|---|---|---|
| **approximation scheme** | for any fixed `ε > 0` it is a `(1 + ε)`-approximation | — |
| **PTAS** (polynomial-time approximation scheme) | polynomial in `n` **for each fixed `ε`** | `O(n^(2/ε))` — legal |
| **FPTAS** (fully polynomial-time a.s.) | polynomial in `n` **and in `1/ε`** | `O((1/ε)² n³)` — legal |

**The distinction is not academic.** `O(n^(2/ε))` at `ε = 0.01` is `n²⁰⁰`. A PTAS can be useless in practice; an FPTAS is a real algorithm. The subset-sum scheme in Part 8 is an FPTAS, and it is the standard example.

**The landscape of what is achievable** — worth memorising, because it tells you how much effort to spend:

| Problem | Best approximation possible (unless `P = NP`) |
|---|---|
| subset sum, knapsack | **FPTAS** — any `1 + ε` you like |
| Euclidean TSP | **PTAS** (Arora, Mitchell) |
| vertex cover, metric TSP, MAX-CUT, bin packing | **constant factor** — 2, 3/2, ~1.14, ~1.22 |
| set cover | **`Θ(lg n)`** — and no better |
| maximum clique, maximum independent set | **no interesting factor at all** — `n^(1−ε)` is hard |

Skiena's warning against generalising from the easy cases:

> *"The previous sections may encourage a false belief that every problem can be approximated to within a constant factor. Indeed, several catalog problems such as maximum clique cannot be approximated to any interesting factor. Set cover occupies a middle ground between these extremes, having a factor-`Θ(lg n)` approximation algorithm."*

---

## Part 3 — Vertex Cover: The Canonical 2-Approximation (CLRS 35.1 · Skiena 12.2)

**Problem.** Given undirected `G = (V, E)`, find a smallest `S ⊆ V` such that every edge has at least one endpoint in `S`. `NP`-complete ([M19](M19-np-completeness.md) A7).

**The algorithm is three lines and it is not what you would guess.**

```
APPROX-VERTEX-COVER(G)
1   C = ∅
2   E' = G.E
3   while E' ≠ ∅
4       let (u, v) be an arbitrary edge of E'
5       C = C ∪ {u, v}
6       remove from E' every edge incident on either u or v
7   return C
```

→ **C++ implementation:** [A1 APPROX-VERTEX-COVER](#a1-approx-vertex-cover)

**Skiena's identical statement**, in his notation:

```
VertexCover(G = (V,E))
    While (E ≠ ∅) do:
        Select an arbitrary edge (u,v) ∈ E
        Add both u and v to the vertex cover
        Delete all edges from E that are incident to either u or v.
```

→ **C++ implementation:** [A1 APPROX-VERTEX-COVER](#a1-approx-vertex-cover)

### Theorem 35.1 — this is a polynomial-time 2-approximation

**Correctness first.** Every edge is deleted only after one of its endpoints entered `C`, so `C` is a cover. Line 6 runs in `O(V + E)` total with adjacency lists.

**The ratio, and the one sentence that carries it.** Let `A` be the set of edges chosen in line 4.

> **No two edges in `A` share a vertex** — because the moment `(u,v)` is chosen, *every* edge touching `u` or `v` is deleted. So **`A` is a matching.**

Every cover must contain at least one endpoint of every edge, and the edges of `A` are vertex-disjoint, so **any cover — including the optimal cover `C*` — needs at least `|A|` vertices:**

```
|A|  ≤  |C*|
```

The algorithm adds exactly two vertices per chosen edge:

```
|C| = 2|A|  ≤  2|C*|      ∎
```

**That is the whole proof, and it is the template for the entire chapter.** The lower bound `|A|` is computable in linear time; the optimum is not.

Skiena states the same argument as a size comparison:

> *"Consider only the `k` edges selected by the algorithm that constitute a matching in the graph. No two of these matching edges can share a vertex, so any cover of just these `k` edges must include at least one vertex per edge, which makes it at least half the size of this `2k`-vertex greedy cover."*

### Why the two "obviously smarter" heuristics are worse

This is the most instructive part of the section, and it is Skiena's alone.

**Smarter idea #1: "why add *both* endpoints? one covers the edge."**

> *"Consider the star-shaped graph of Figure 12.1. The original heuristic will produce a two-vertex cover, while the single-vertex heuristic might return a cover as large as `n − 1` vertices, should we get unlucky and repeatedly select the leaf instead of the center as the cover vertex we retain."*

On a star `K₁,ₙ₋₁`: the optimum is `1` (the centre). Taking both endpoints gives `2`. Keeping one endpoint, chosen adversarially, gives `n − 1`. **Ratio 2 versus ratio `n − 1`.**

**Smarter idea #2: "repeatedly take the highest-degree vertex."** This is the greedy set-cover heuristic applied to vertex cover, and it is the heuristic every candidate proposes in an interview.

> *"However, in the case of ties or near ties, this heuristic can go seriously astray. In the worst case, it can yield a cover that is `Θ(lg n)` times optimal."*

The counterexample (Skiena Figure 12.2) is bipartite: a top row of `k` vertices, and a bottom row split into groups where group `i` has `⌊k/i⌋` vertices each of degree `i`. The top row is a cover of size `k`; greedy peels the bottom row group by group and takes `k · H(k) = Θ(k lg k)` vertices. **The provably-worse algorithm is the one that feels smarter.**

**Two more lessons Skiena draws, both worth keeping:**

- *"Making a heuristic more complicated does not necessarily make it better — It is easy to complicate heuristics by adding more special cases or details. For example, the procedure above did not specify which edge should be selected next for the matching. It might seem reasonable to pick the edge whose endpoints have the highest total degree. However, this does not improve the worst-case bound, and just makes it more difficult to analyze."*
- *"A post-processing cleanup step can't hurt — … a post-processing step that deletes any unnecessary vertex from the cover can only improve things in practice, even though it won't help the worst-case bound. And it is fair to repeat the process multiple times with different starting edges and take the best of the resulting runs."*

**Do the cleanup.** It costs `O(V + E)`, it never breaks the guarantee, and on real graphs it removes a noticeable fraction of the cover.

### C++ Implementation

```cpp
// The 2-approximation for vertex cover, plus the two heuristics that LOOK
// smarter and are provably worse -- kept side by side because comparing them on
// the star graph and on Skiena's bipartite instance is the lesson.
struct Graph {
    int vertexCount = 0;
    vector<vector<int>> neighbours;

    explicit Graph(int n = 0) : vertexCount(n), neighbours(n) {}

    void addEdge(int u, int v) {
        neighbours[u].push_back(v);
        neighbours[v].push_back(u);
    }

    // All edges as (u,v) with u < v, deduplicated. Convenient for the covers
    // below, which need to iterate edges rather than adjacency.
    vector<pair<int, int>> edgeList() const {
        vector<pair<int, int>> edges;
        for (int u = 0; u < vertexCount; ++u)
            for (int v : neighbours[u])
                if (u < v) edges.emplace_back(u, v);
        return edges;
    }
};

// APPROX-VERTEX-COVER. Returns a cover of size at most twice the minimum.
//
// The `covered` array is what implements line 6 ("remove every edge incident on
// u or v") in O(1) per edge rather than by physically deleting from a list: an
// edge is gone exactly when one of its endpoints is already in the cover.
vector<int> approxVertexCover(const Graph& graph) {
    vector<char> inCover(graph.vertexCount, 0);
    for (const auto& [u, v] : graph.edgeList()) {
        if (inCover[u] || inCover[v]) continue;   // this edge is already covered
        inCover[u] = inCover[v] = 1;              // <- both endpoints. The point.
    }
    vector<int> cover;
    for (int v = 0; v < graph.vertexCount; ++v)
        if (inCover[v]) cover.push_back(v);
    return cover;
}

// The edges chosen above form a MAXIMAL MATCHING, and its size is the lower
// bound the whole proof rests on. Returning it explicitly makes the proof
// checkable at runtime: matching.size() <= optimum <= cover.size() = 2*matching.
vector<pair<int, int>> maximalMatching(const Graph& graph) {
    vector<char> used(graph.vertexCount, 0);
    vector<pair<int, int>> matching;
    for (const auto& [u, v] : graph.edgeList()) {
        if (used[u] || used[v]) continue;
        used[u] = used[v] = 1;
        matching.emplace_back(u, v);
    }
    return matching;
}

// Skiena's randomized variant: pick ONE endpoint, at random. Expected size is
// still at most twice optimal, because for every edge we select, at least one
// endpoint lies in the optimal cover -- so each coin flip lands "inside" the
// optimal cover with probability >= 1/2.
vector<int> randomizedVertexCover(const Graph& graph, mt19937& randomEngine) {
    vector<char> inCover(graph.vertexCount, 0);
    for (const auto& [u, v] : graph.edgeList()) {
        if (inCover[u] || inCover[v]) continue;
        // Note the asymmetry with the deterministic version: only the SELECTED
        // vertex's edges disappear, so the other endpoint may be chosen later.
        inCover[(randomEngine() & 1u) ? u : v] = 1;
    }
    vector<int> cover;
    for (int v = 0; v < graph.vertexCount; ++v)
        if (inCover[v]) cover.push_back(v);
    return cover;
}

// The heuristic everyone proposes, and the one with the Theta(lg n) worst case.
// Kept here so the notes can demonstrate the counterexample rather than assert it.
vector<int> greedyDegreeVertexCover(const Graph& graph) {
    vector<char> inCover(graph.vertexCount, 0), edgeGone(0, 0);
    vector<pair<int, int>> edges = graph.edgeList();
    edgeGone.assign(edges.size(), 0);

    size_t remaining = edges.size();
    while (remaining > 0) {
        vector<int> liveDegree(graph.vertexCount, 0);
        for (size_t e = 0; e < edges.size(); ++e)
            if (!edgeGone[e]) { ++liveDegree[edges[e].first]; ++liveDegree[edges[e].second]; }

        const int best = int(max_element(liveDegree.begin(), liveDegree.end()) - liveDegree.begin());
        inCover[best] = 1;
        for (size_t e = 0; e < edges.size(); ++e)
            if (!edgeGone[e] && (edges[e].first == best || edges[e].second == best)) {
                edgeGone[e] = 1;
                --remaining;
            }
    }
    vector<int> cover;
    for (int v = 0; v < graph.vertexCount; ++v)
        if (inCover[v]) cover.push_back(v);
    return cover;
}

// Skiena's "post-processing cleanup step can't hurt": drop any vertex whose
// removal still leaves a cover. Never breaks the factor-2 guarantee, because it
// only ever shrinks the answer. Cheap, and worth doing every time.
vector<int> pruneRedundantVertices(const Graph& graph, vector<int> cover) {
    vector<char> inCover(graph.vertexCount, 0);
    for (int v : cover) inCover[v] = 1;

    for (int v : cover) {
        bool stillCovers = true;                       // is v needed?
        for (int w : graph.neighbours[v])
            if (!inCover[w]) { stillCovers = false; break; }   // edge (v,w) would be bare
        if (stillCovers) inCover[v] = 0;
    }
    vector<int> pruned;
    for (int v = 0; v < graph.vertexCount; ++v)
        if (inCover[v]) pruned.push_back(v);
    return pruned;
}
```

**Complexity. `approxVertexCover`, `maximalMatching`, `randomizedVertexCover`, `pruneRedundantVertices` all run in `O(V + E)`. `greedyDegreeVertexCover` as written is `O(V·E)` — deliberately naive, since its purpose is to be a counterexample generator.**

### The DFS-tree cover — a second 2-approximation for free

Skiena's *Stop and Think*, and a very good interview answer because it reuses machinery you already have from [M13](M13-graphs-traversal.md):

> **Problem:** *"Suppose we do a depth-first search of graph `G`, naturally building a depth-first search tree `T` in the process… Delete every leaf node from `T`. Show that (1) the set of all non-leaf nodes of `T` form a vertex cover of graph `G`, and (2) that this vertex cover is of size at most twice that of the minimum vertex cover."*

**(1) It is a cover.** The magic property of DFS on an undirected graph is that **every edge is a tree edge or a back edge** — there are no cross edges. If `v` is a leaf, its only tree edge is `(x, v)` with `x` its parent, a non-leaf, which is in the cover. Any other edge at `v` is a back edge to an *ancestor* of `v`, and every ancestor is a non-leaf. So every edge has a non-leaf endpoint.

**(2) It is within 2.** Walk a root-to-leaf path of `k` edges (`k + 1` vertices). The heuristic takes the `k` non-leaf vertices on it; covering a path of `k` edges requires `⌈k/2⌉` vertices. Factor 2.

→ **C++ implementation:** [A1 APPROX-VERTEX-COVER](#a1-approx-vertex-cover)

### The randomized heuristic (Skiena 12.2.1)

> *"Although we proved that our original vertex cover heuristic … yields a factor two approximation algorithm, it feels wrong to grow the cover by two vertices when either one would equally cover the given edge. However, the star-shaped example of Figure 12.1 shows that if we repeatedly pick the wrong (meaning non-center) vertex for each edge, we could end up with a cover of size `n − 1` instead of 1. Such a horrible performance requires making the wrong decision `n − 1` times in a row, which implies either a special talent or horrendous luck. **We can make it a matter of luck by choosing the vertex at random.**"*

**The expectation argument.** For each selected edge `(u, v)`, at least one endpoint is in the optimal cover `C*` (it is a cover). So the coin lands on a vertex of `C*` with probability at least `1/2`. Partition the answer into `C' ⊆ C*` (the lucky picks) and `D ⊆ V − C*` (the unlucky ones). Always `|C'| ≤ |C*|`, and `E[|D|] = E[|C'|]`, so

```
E[|C'| + |D|]  ≤  2|C*|
```

**And the general lesson**, which is the reason randomization appears in this chapter at all:

> *"Randomization is a very powerful tool for developing approximation algorithms. Its role is to make bad special cases go away by making it very unlikely that they will occur. The careful analysis of such probabilities often requires sophisticated efforts, but the heuristics themselves are generally very simple and easy to implement."*

---

## Part 4 — TSP: 2 by Doubling, 3/2 by Christofides (CLRS 35.2 · Skiena 12.3)

**The triangle inequality is the entire dividing line.** With it, TSP is 3/2-approximable. Without it, **no constant factor is achievable at all** unless `P = NP`. Same problem, one assumption apart.

> `d(u, w) ≤ d(u, v) + d(v, w)` for all triples — "going direct is never longer than going via somewhere."

Skiena on when it holds and when it does not:

> *"The general reasonableness of this condition is demonstrated in Figure 12.3. **The cost of airfares is an example of a distance function that violates the triangle inequality**, because it is often cheaper to fly through an intermediate city than to fly direct to the destination—which is why finding the cheapest fare can be such a pain. But the triangle inequality holds naturally for many problems and applications."*

### The lower bound: MST ≤ optimal tour

> *"First, observe that the weight of the minimum spanning tree of graph `G` must be a lower bound on the cost of the optimal TSP tour `T` of `G`. Why? Distances are always non-negative, so deleting any edge from tour `T` leaves a path with total weight no greater than that of `T`. This path has no cycles, and hence is a tree, which means its weight must be at least that of the minimum spanning tree."*

`w(MST) ≤ w(H*)`. **That is the `L` for this problem.** ([M14](M14-mst.md) computes it.)

### The algorithm

```
APPROX-TSP-TOUR(G, c)
1   select a vertex r ∈ G.V to be a "root" vertex
2   compute a minimum spanning tree T for G from root r
        using MST-PRIM(G, c, r)
3   let H be a list of vertices, ordered according to when they are
        first visited in a preorder walk of T
4   return the hamiltonian cycle H
```

→ **C++ implementation:** [A2 APPROX-TSP-TOUR](#a2-approx-tsp-tour)

### Theorem 35.2 — a 2-approximation when `c` satisfies the triangle inequality

Three inequalities, in order:

1. **`w(T) ≤ c(H*)`** — delete any edge of the optimal tour `H*` to get a spanning tree; the MST is no heavier.
2. **A full walk `W` of `T` costs `2w(T)`** — a depth-first traversal crosses each tree edge exactly twice, once down and once up.
   > *"For example, the depth-first search of Figure 12.4 (left) visits the vertices in order: `1, 2, 1, 3, 5, 8, 5, 9, 5, 3, 6, 3, 1, 4, 7, 10, 7, 11, 7, 4, 1`."*
3. **Shortcutting only helps** — `W` repeats vertices; delete every repeat, jumping straight to the next unvisited vertex. Each deletion replaces a chain `u → v → w` by the direct edge `u → w`, and the triangle inequality says that is no longer.
   > *"The shortcut tour for the circuit above is `1, 2, 3, 5, 8, 9, 6, 4, 7, 10, 11, 1`."*

```
c(H)  ≤  c(W)  =  2w(T)  ≤  2c(H*)      ∎
```

The preorder of the DFS tree *is* the shortcut walk — that is why line 3 says "preorder" and no explicit shortcutting appears in the pseudocode.

**Cost:** `O(V²)` with Prim on a dense/geometric instance, `O(V + E)` for the walk.

### Christofides: `3/2`, and why odd degrees are the obstacle

**Reframe the doubling as an Eulerian circuit.** Skiena:

> *"Construct a multigraph `M`, which consists of two copies of each edge of the minimum spanning tree of `G`. This `n`-vertex, `2(n − 1)`-edge multigraph must be Eulerian, because every vertex has degree twice that of the minimum spanning tree of `G`. Any Eulerian cycle of `M` will define a circuit with exactly the same properties as the DFS circuit described above, and hence can be shortcut in the same way."*

A connected graph has an Eulerian circuit **iff every vertex has even degree** — *"you must be able to walk out of each vertex exactly the number of times you walk in."* Doubling every edge is a brutally expensive way to make all degrees even: it pays `w(T)` extra.

**Christofides pays only for the vertices that actually need fixing.**

> *"So let's start by identifying the odd-degree vertices in the minimum spanning tree of `G`, which are the obstacle preventing us from finding an Eulerian cycle on the minimum spanning tree itself. There must be an even number of odd-degree vertices in any graph. By adding a set of matching edges between these odd-degree vertices, we make the graph Eulerian."*

```
CHRISTOFIDES(G, c)
1   T = minimum spanning tree of G
2   O = { v : deg_T(v) is odd }            // |O| is even (handshake lemma)
3   M = minimum-weight perfect matching on the complete graph induced by O
4   multigraph U = T ∪ M                   // every degree now even
5   W = an Eulerian circuit of U
6   return W with repeated vertices shortcut out
```

→ **C++ implementation:** [A2 APPROX-TSP-TOUR](#a2-approx-tsp-tour)

**Why the matching costs at most `c(H*)/2`.** This is the elegant half of the argument, and it is a picture:

> *"Observe in Figure 12.5 that the alternating edges of any TSP tour must define a matching, because each vertex appears only once in the given edge set. These red edges (or blue edges) must cost at least as much as the minimum weight matching of `G`, and (for the lighter color) weigh at most half that of the TSP tour."*

Precisely: take the optimal tour restricted to `O` (shortcut past the even-degree vertices — triangle inequality, so this only shrinks it). That is a cycle through `|O|` vertices, `|O|` even, so its edges split into **two disjoint perfect matchings on `O`**. Both together weigh at most `c(H*)`; the cheaper one weighs at most `c(H*)/2`. The *minimum* perfect matching is no worse.

```
c(U) = w(T) + w(M)  ≤  c(H*) + c(H*)/2  =  (3/2)·c(H*)      ∎
```

**Cost:** dominated by step 3. Minimum-weight perfect matching on a general graph is Blossom, `O(n³)` — considerably more machinery than the rest of the algorithm. The implementation in this module solves step 3 **exactly by bitmask DP over the odd vertices** in `O(2^|O| · |O|)`, which is the right choice for notes: it is short, it is obviously correct, and `|O|` is small on the instances you will test.

> `3/2` stood as the best known ratio for metric TSP from 1976 until 2020, when Karlin, Klein and Oveis Gharan improved it by about `10⁻³⁶`. That is how hard this bound is. *(Outside the books — see below.)*

### Theorem 35.3 — general TSP has no constant-factor approximation

**Drop the triangle inequality and everything collapses.**

> *"If `P ≠ NP`, then for any constant `ρ ≥ 1`, there is no polynomial-time approximation algorithm with approximation ratio `ρ` for the general traveling-salesperson problem."*

**Proof by reduction from HAM-CYCLE — and the trick is to make the penalty enormous.** Given `G = (V, E)`, build a complete graph `G'` on the same vertices with

```
c(u, v) = 1              if (u, v) ∈ E
c(u, v) = ρ|V| + 1       otherwise
```

- If `G` has a Hamiltonian cycle, `G'` has a tour of cost exactly `|V|`.
- If not, every tour must use at least one non-edge, so it costs at least
  `(ρ|V| + 1) + (|V| − 1) > ρ|V|`.

**The gap is a factor of more than `ρ`.** So a `ρ`-approximation, run on `G'`, returns a tour of cost `≤ ρ|V|` exactly when `G` is Hamiltonian — it *decides* HAM-CYCLE in polynomial time. Hence `P = NP`. ∎

**The technique has a name and you will reuse it: *amplify the penalty*.** Make the "bad" answers so expensive that no approximation ratio can straddle the gap, and any approximation becomes an exact decider. Skiena lists it among his hardness-proving tools ([M19](M19-np-completeness.md) Part 6).

### C++ Implementation

```cpp
// Metric TSP: the MST-doubling 2-approximation and Christofides' 3/2.
// Distances live in a full matrix -- these algorithms are for complete graphs.
using DistanceMatrix = vector<vector<double>>;

// Prim in O(n^2), which is the right complexity for a dense/geometric instance.
// Returns the parent array; parent[root] == -1.
vector<int> primMinimumSpanningTree(const DistanceMatrix& distance) {
    const int n = int(distance.size());
    vector<double> best(n, numeric_limits<double>::infinity());
    vector<int> parent(n, -1);
    vector<char> inTree(n, 0);

    best[0] = 0.0;
    for (int step = 0; step < n; ++step) {
        int pick = -1;
        for (int v = 0; v < n; ++v)
            if (!inTree[v] && (pick < 0 || best[v] < best[pick])) pick = v;
        inTree[pick] = 1;
        for (int v = 0; v < n; ++v)
            if (!inTree[v] && distance[pick][v] < best[v]) {
                best[v] = distance[pick][v];
                parent[v] = pick;
            }
    }
    return parent;
}

double tourCost(const DistanceMatrix& distance, const vector<int>& tour) {
    double total = 0.0;
    for (size_t i = 0; i < tour.size(); ++i)
        total += distance[tour[i]][tour[(i + 1) % tour.size()]];
    return total;
}

// APPROX-TSP-TOUR. The "shortcutting" of the doubled walk never appears
// explicitly: a PREORDER of the MST *is* the shortcut walk, because preorder
// lists each vertex exactly at its first appearance in the full DFS walk.
vector<int> mstApproxTspTour(const DistanceMatrix& distance) {
    const int n = int(distance.size());
    const vector<int> parent = primMinimumSpanningTree(distance);

    vector<vector<int>> children(n);
    for (int v = 0; v < n; ++v)
        if (parent[v] >= 0) children[parent[v]].push_back(v);

    vector<int> tour;
    vector<int> stack{0};                       // iterative preorder: no recursion depth risk
    while (!stack.empty()) {
        const int at = stack.back();
        stack.pop_back();
        tour.push_back(at);
        for (auto it = children[at].rbegin(); it != children[at].rend(); ++it)
            stack.push_back(*it);               // reversed, so children come out in order
    }
    return tour;
}

// Minimum-weight perfect matching on a SMALL vertex set, exactly, by bitmask DP.
// State = set of still-unmatched vertices; always pair the lowest set bit with
// someone, which removes the factor-k! symmetry and makes this O(2^k * k).
//
// The real Christofides uses Blossom (O(n^3)) here. This is the honest choice
// for notes: obviously correct, and |O| is small on anything you will test.
double minimumWeightPerfectMatching(const vector<int>& vertices,
                                    const DistanceMatrix& distance,
                                    vector<pair<int, int>>* matchingOut) {
    const int k = int(vertices.size());
    if (k == 0) { if (matchingOut) matchingOut->clear(); return 0.0; }

    const int stateCount = 1 << k;
    vector<double> best(stateCount, numeric_limits<double>::infinity());
    vector<int> pairedWith(stateCount, -1);     // for reconstruction
    best[0] = 0.0;

    for (int mask = 1; mask < stateCount; ++mask) {
        const int first = __builtin_ctz(mask);              // lowest unmatched vertex
        for (int other = first + 1; other < k; ++other) {
            if (!(mask >> other & 1)) continue;
            const int rest = mask ^ (1 << first) ^ (1 << other);
            const double candidate = best[rest] + distance[vertices[first]][vertices[other]];
            if (candidate < best[mask]) { best[mask] = candidate; pairedWith[mask] = other; }
        }
    }

    if (matchingOut) {
        matchingOut->clear();
        int mask = stateCount - 1;
        while (mask) {
            const int first = __builtin_ctz(mask), other = pairedWith[mask];
            matchingOut->emplace_back(vertices[first], vertices[other]);
            mask ^= (1 << first) | (1 << other);
        }
    }
    return best[stateCount - 1];
}

// Christofides. MST + minimum-weight perfect matching on the ODD-degree
// vertices makes every degree even, so an Eulerian circuit exists; shortcut it.
vector<int> christofidesTour(const DistanceMatrix& distance) {
    const int n = int(distance.size());
    if (n <= 2) { vector<int> t(n); iota(t.begin(), t.end(), 0); return t; }

    const vector<int> parent = primMinimumSpanningTree(distance);

    // Multigraph as an adjacency list of edge ids, so parallel edges (an MST
    // edge that the matching duplicates) stay distinct and each is used once.
    vector<pair<int, int>> edges;
    vector<vector<int>> incident(n);
    auto addMultiEdge = [&](int u, int v) {
        incident[u].push_back(int(edges.size()));
        incident[v].push_back(int(edges.size()));
        edges.emplace_back(u, v);
    };
    for (int v = 0; v < n; ++v)
        if (parent[v] >= 0) addMultiEdge(parent[v], v);

    vector<int> degree(n, 0);
    for (const auto& [u, v] : edges) { ++degree[u]; ++degree[v]; }

    vector<int> odd;                                   // even count, by handshake lemma
    for (int v = 0; v < n; ++v) if (degree[v] % 2) odd.push_back(v);

    vector<pair<int, int>> matching;
    minimumWeightPerfectMatching(odd, distance, &matching);
    for (const auto& [u, v] : matching) addMultiEdge(u, v);

    // Hierholzer: walk until stuck, then splice in detours. See M13.
    vector<char> usedEdge(edges.size(), 0);
    vector<int> nextEdge(n, 0), stack{0}, circuit;
    while (!stack.empty()) {
        const int at = stack.back();
        while (nextEdge[at] < int(incident[at].size()) && usedEdge[incident[at][nextEdge[at]]])
            ++nextEdge[at];
        if (nextEdge[at] == int(incident[at].size())) { circuit.push_back(at); stack.pop_back(); }
        else {
            const int id = incident[at][nextEdge[at]++];
            usedEdge[id] = 1;
            stack.push_back(edges[id].first == at ? edges[id].second : edges[id].first);
        }
    }

    vector<char> seen(n, 0);                           // the shortcutting step
    vector<int> tour;
    for (int v : circuit)
        if (!seen[v]) { seen[v] = 1; tour.push_back(v); }
    return tour;
}
```

**Complexity. `primMinimumSpanningTree` is `Θ(n²)`; `mstApproxTspTour` is `Θ(n²)`. `christofidesTour` is `Θ(n² + 2^|O|·|O|)` with this exact matching, and `Θ(n³)` with Blossom.**

*Verified:* on 400 random Euclidean instances (`4 ≤ n ≤ 10`) both tours were compared against the exact optimum from Held–Karp ([M11](M11-dynamic-programming.md)). Both returned a genuine permutation every time. `mstApproxTspTour` never exceeded `2·OPT` (worst observed ratio **1.42**, mean 1.12); `christofidesTour` never exceeded `1.5·OPT` (worst observed **1.21**, mean 1.04), and beat the doubling tour on **69%** of instances. The MST weight was `≤ OPT` on every instance.

### Outside / Engineering Context

- **Karlin–Klein–Oveis Gharan (2020)** gave the first improvement on `3/2` for metric TSP: `3/2 − ε` for `ε ≈ 10⁻³⁶`. Its significance is entirely theoretical — it broke a 44-year barrier.
- **In practice nobody runs Christofides.** The standard pipeline is a cheap constructive tour (nearest neighbour or greedy edge) followed by **2-opt / Or-opt / Lin–Kernighan** local search — Part 9's hill climbing, specialised. [LKH](http://webhotel4.ruc.dk/~keld/research/LKH/) routinely finds optimal or near-optimal tours on instances with hundreds of thousands of cities.
- **Concorde** solves TSP *exactly* via branch-and-cut + LP on instances with tens of thousands of cities. "`NP`-hard" does not mean "unsolvable at your scale" — always check whether an exact solver already handles your `n`.

---

## Part 5 — When Average Is Good Enough (Skiena 12.4 · CLRS 35.4)

Skiena's framing, which is the most quotable sentence in the chapter:

> *"In the mythical land of Lake Wobegon, all the children are above average. For certain optimization problems, all (or most) of the solutions are seemingly close to the best possible. Recognizing this yields very simple approximation algorithms with provable guarantees."*

**The pattern.** If you can show the *expected* value of a **random** solution is a good fraction of the maximum possible, you have an approximation algorithm whose entire implementation is a coin flip. Three instances follow, and the argument is linearity of expectation every time.

### MAX-3-SAT: a coin flip satisfies 7/8 of the clauses

**Problem.** Given a 3-CNF formula, find the assignment satisfying the **most** clauses. Asking for 100% is 3-SAT, so this is `NP`-hard.

> **Theorem 35.5.** *Given an instance of MAX-3-CNF satisfiability with `n` variables and `m` clauses, the randomized algorithm that independently sets each variable to 1 with probability `1/2` and to 0 with probability `1/2` is a randomized `8/7`-approximation algorithm.*

**Proof — four lines.** Assume (as 3-CNF requires) three *distinct* literals per clause and no variable together with its negation. Let `Yᵢ = I{clause i is satisfied}`.

A clause fails only if **all three** literals are false, and the three literal settings are independent, so

```
Pr{clause i unsatisfied} = (1/2)³ = 1/8
E[Yᵢ] = Pr{clause i satisfied} = 7/8
```

By linearity of expectation, over `Y = Y₁ + ⋯ + Y_m`:

```
E[Y] = Σ E[Yᵢ] = 7m/8
```

`m` upper-bounds the optimum, so the ratio is at most `m / (7m/8) = 8/7`. ∎

> **Two things worth noticing.** First, the bound needs **no assumption about the formula** — it holds for unsatisfiable formulas too. Second, it means **every 3-CNF formula has an assignment satisfying at least `⌈7m/8⌉` clauses**, an existence theorem obtained without constructing anything. That is the probabilistic method.

**Skiena's version generalises to any clause length:**

> *"For a maximum `k`-SAT instance with `m` input clauses, we expect to satisfy `m(1 − (1/2)^k)` of them with any random assignment. **From an approximation standpoint, the longer the clauses, the easier it is to get close to the optimum.**"*

`k = 2` → `3/4`. `k = 3` → `7/8`. `k = 10` → `99.9%`. The hardness lives in *short* clauses — which is exactly why 2-SAT is in `P` and 3-SAT is not, from the other direction.

**And a genuinely tight bound:** Håstad proved you cannot beat `7/8` for MAX-3-SAT unless `P = NP`. *The coin flip is optimal.* *(Outside the books.)*

### Derandomizing it — the method of conditional expectations

> ### Outside / Engineering Context
>
> Neither book covers this, but it is short and it turns the existence theorem into a deterministic algorithm. Fix the variables one at a time. At each step compute `E[Y | assignments so far, rest random]` for both values of the next variable, and take the larger. Since
> ```
> E[Y | prefix] = ½·E[Y | prefix, xᵢ=1] + ½·E[Y | prefix, xᵢ=0]
> ```
> at least one branch is `≥` the current expectation, so the running expectation **never decreases** from its starting value of `7m/8`. When every variable is fixed, the expectation *is* the number of satisfied clauses. Deterministic, `O(nm)`, and still `≥ 7m/8`.

→ **C++ implementation:** [A4 Random assignment and derandomization](#a4-random-assignment-and-derandomization)

### MAX-CUT: a coin flip cuts half the edges

**Problem** (CLRS Exercise 35.4-3). Partition `V` into `(S, V − S)` maximising the number of crossing edges. `NP`-hard.

Put each vertex in `S` independently with probability `1/2`. Edge `(u, v)` crosses iff its endpoints land differently, which happens with probability `1/2`. By linearity, `E[cut] = |E|/2`, and `|E|` upper-bounds the optimum — a randomized **2-approximation**.

**And it derandomizes into a one-line local search:** while some vertex has more neighbours on its own side than across, move it. Each move strictly increases the cut, the cut is bounded by `|E|`, so it terminates — at a state where every vertex has at least half its neighbours across, i.e. `cut ≥ |E|/2`. **This is hill climbing (Part 9) with a proven guarantee**, which is unusual and worth remembering.

> The `0.878`-approximation of Goemans–Williamson, via semidefinite programming, is the celebrated improvement — and under the Unique Games Conjecture it is optimal. *(Outside the books.)*

### Maximum acyclic subgraph: pick a permutation, keep the bigger half

**Problem** (Skiena 12.4.2):

> *"**Input:** A directed graph `G = (V,E)`. **Output:** Find the largest possible subset `E' ⊆ E` such that `G' = (V,E')` is acyclic."*

Skiena invites you to find the algorithm before reading on, and it is worth ten seconds:

> *"Construct any permutation of the vertices, and interpret it as a left-to-right ordering, akin to topological sorting. Now some of the edges will point from left to right, while the rest point from right to left."*
>
> *"One of these two edge subsets must be at least as large as the other. This means it contains at least half the edges. Furthermore, each of these two edge subsets must be acyclic for the same reason only DAGs can be topologically sorted — you cannot form a cycle by repeatedly moving in one direction. Thus, the larger edge subset must be acyclic, and contain at least half the edges of the optimal solution."*

**Both halves are acyclic** (a cycle would have to reverse direction at some point) and **one of them has `≥ |E|/2` edges**, while the optimum is at most `|E|`. Factor 2, in `O(V + E)`, with a random shuffle.

> *"This approximation algorithm is simple almost to the point of being stupid. But note that heuristics can make it perform better in practice without losing this guarantee. Perhaps we can try many random permutations, and pick the best. Or we can try to exchange pairs of vertices in the permutations retaining those swaps that throw more edges onto the bigger side."*

**That last sentence is the bridge to Part 9** — take an algorithm with a guarantee, wrap local search around it, keep the guarantee, gain the practice.

### C++ Implementation

```cpp
// "When average is good enough": three algorithms whose entire content is a
// coin flip, plus the deterministic versions that provably match them.

struct CnfFormula {
    int variableCount = 0;
    vector<vector<int>> clauses;             // DIMACS literals: +v / -v for v in 1..n
};

int satisfiedClauseCount(const CnfFormula& formula, const vector<char>& value) {
    int total = 0;
    for (const auto& clause : formula.clauses)
        for (int literal : clause)
            if ((value[abs(literal) - 1] != 0) == (literal > 0)) { ++total; break; }
    return total;
}

// Theorem 35.5. Expected 7m/8 satisfied clauses on 3-CNF; m(1 - 2^-k) in general.
vector<char> randomAssignment(const CnfFormula& formula, mt19937& randomEngine) {
    vector<char> value(formula.variableCount);
    for (char& bit : value) bit = char(randomEngine() & 1u);
    return value;
}

// The method of conditional expectations: deterministic, and NEVER worse than
// the 7m/8 the coin flip achieves only in expectation.
//
// The key quantity is E[satisfied | the prefix fixed, the rest uniform], which
// is computable in closed form: a clause not yet satisfied, with u unassigned
// literals, is satisfied with probability 1 - 2^-u.
vector<char> derandomizedMaxSat(const CnfFormula& formula) {
    const int n = formula.variableCount;
    vector<char> value(n, 2);                            // 2 == "still unassigned"

    auto expectedSatisfied = [&]() {
        double total = 0.0;
        for (const auto& clause : formula.clauses) {
            int unassigned = 0;
            bool alreadyTrue = false;
            for (int literal : clause) {
                const char assigned = value[abs(literal) - 1];
                if (assigned == 2) ++unassigned;
                else if ((assigned != 0) == (literal > 0)) { alreadyTrue = true; break; }
            }
            total += alreadyTrue ? 1.0 : 1.0 - ldexp(1.0, -unassigned);
        }
        return total;
    };

    for (int v = 0; v < n; ++v) {
        value[v] = 1;  const double withTrue  = expectedSatisfied();
        value[v] = 0;  const double withFalse = expectedSatisfied();
        value[v] = char(withTrue >= withFalse);          // never decreases the expectation
    }
    return value;
}

// MAX-CUT. side[v] == 1 means v is in S. Random gives E[cut] = |E|/2; the local
// search below turns that expectation into a guarantee.
long long cutWeight(const Graph& graph, const vector<char>& side) {
    long long crossing = 0;
    for (int u = 0; u < graph.vertexCount; ++u)
        for (int v : graph.neighbours[u])
            if (u < v && side[u] != side[v]) ++crossing;
    return crossing;
}

vector<char> localSearchMaxCut(const Graph& graph, mt19937& randomEngine) {
    vector<char> side(graph.vertexCount);
    for (char& bit : side) bit = char(randomEngine() & 1u);

    bool moved = true;
    while (moved) {                                       // terminates: every move
        moved = false;                                    // strictly grows the cut,
        for (int v = 0; v < graph.vertexCount; ++v) {     // which is bounded by |E|
            int sameSide = 0, acrossSide = 0;
            for (int w : graph.neighbours[v]) (side[v] == side[w] ? sameSide : acrossSide)++;
            if (sameSide > acrossSide) { side[v] = char(!side[v]); moved = true; }
        }
    }
    // At the fixed point every vertex has >= half its neighbours across, so
    // summing over vertices double-counts a cut of size at least |E|/2.
    return side;
}

// Maximum acyclic subgraph: shuffle, then keep whichever direction is bigger.
// Returns the retained edges; always at least half of E, and always acyclic.
vector<pair<int, int>> maximumAcyclicSubgraph(int vertexCount,
                                              const vector<pair<int, int>>& directedEdges,
                                              mt19937& randomEngine) {
    vector<int> position(vertexCount);
    iota(position.begin(), position.end(), 0);
    shuffle(position.begin(), position.end(), randomEngine);

    vector<pair<int, int>> forward, backward;
    for (const auto& [from, to] : directedEdges)
        (position[from] < position[to] ? forward : backward).emplace_back(from, to);

    // Both halves are acyclic -- a cycle would have to reverse direction -- so
    // returning the larger one is safe, and it holds >= |E|/2 edges.
    return forward.size() >= backward.size() ? forward : backward;
}
```

**Complexity. `randomAssignment` is `Θ(n)`; `derandomizedMaxSat` is `Θ(n · Σ|clause|)`; `localSearchMaxCut` is `O(|E|)` per sweep and `O(|E|)` sweeps in the worst case; `maximumAcyclicSubgraph` is `Θ(V + E)`.**

*Verified:* on 3 000 random CNF formulas (`n ≤ 12`, `m ≤ 40`, clauses of up to three distinct literals) the mean fraction of clauses satisfied by `randomAssignment` was **0.866** — the formulas with fewer than three variables carry shorter clauses, which pulls the mean below the `0.875` that pure 3-CNF gives. `derandomizedMaxSat` met or beat each formula's own expectation `Σ(1 − 2^−|c|)` on **every single instance**, 3 000 of 3 000, and averaged **0.991** of the exhaustive optimum. `localSearchMaxCut` produced a cut `≥ |E|/2` on all 1 774 random graphs tested and reached the exact optimum on **76%** of them. `maximumAcyclicSubgraph` returned an edge set of size `≥ |E|/2` on 1 965 random digraphs, verified acyclic by topological sort every time.

---

## Part 6 — Set Cover: Greedy Is `Θ(lg n)`, and That Is Optimal (CLRS 35.3 · Skiena 12.5)

**Problem.** Given a universe `X` and a family `F` of subsets whose union is `X`, find a smallest subfamily `C ⊆ F` covering `X`.

> Set cover generalises vertex cover (one set per vertex, containing its incident edges) — so it is `NP`-hard, and the `Θ(lg n)` bound below is *why* the highest-degree heuristic for vertex cover in Part 3 fails: it is greedy set cover, inheriting its logarithmic worst case.

**Applications.** CLRS: *"a model for many resource-selection problems"* — committee selection where each person has a set of skills, minimum test sets, sensor placement, and (very commonly in practice) **feature/capability coverage**.

```
GREEDY-SET-COVER(X, F)
1   U = X
2   C = ∅
3   while U ≠ ∅
4       select an S ∈ F that maximizes |S ∩ U|
5       U = U − S
6       C = C ∪ {S}
7   return C
```

→ **C++ implementation:** [A3 GREEDY-SET-COVER](#a3-greedy-set-cover)

Skiena's identical `SetCover(S)`, plus the observation that makes his analysis work:

> *"One consequence of this selection process is that **the number of freshly covered elements defines a non-increasing sequence** as the algorithm proceeds. Why? If not, greedy would have picked the more powerful subset earlier if it, in fact, existed."*

### Theorem 35.4 — `GREEDY-SET-COVER` is a `ρ(n)`-approximation with `ρ(n) = H(max{|S|}) ≤ ln|X| + 1`

**CLRS's argument, compressed.** Let `Uᵢ` be the uncovered set after `i` rounds and `k = |C*|` the optimal cover size. The `k` optimal sets cover all of `Uᵢ`, so **some** set covers at least `|Uᵢ|/k` of it — and greedy takes at least that many. Hence

```
|U_{i+1}|  ≤  |Uᵢ|·(1 − 1/k)   ⟹   |Uᵢ| ≤ |X|·(1 − 1/k)^i  ≤  |X|·e^(−i/k)
```

using `1 + x ≤ eˣ`. After `i = ⌈k ln|X|⌉` rounds, `|Uᵢ| < 1`, so nothing is left:

```
|C|  ≤  k⌈ln|X|⌉  =  |C*|·⌈ln|X|⌉      ∎
```

**Skiena's argument via milestones and width** — different, and better for intuition:

> *"We can view this heuristic as reducing the number of uncovered elements from `n` down to zero by progressively smaller amounts. An important **milestone** occurs each time the number of remaining uncovered elements reduces past a power of two. Clearly there can be at most `lg n` such events."*
>
> *"Let `wᵢ` denote the number of subsets selected by the heuristic to cover elements between milestones `2^(i+1) − 1` and `2ⁱ`. Define the **width** `w` to be the maximum `wᵢ`… the solution produced by the greedy heuristic must contain at most `w · lg n` subsets. But I claim that the optimal solution must contain at least `w` subsets."*
>
> *"Why? Consider the average number of new elements covered as we move between milestones `2^(i+1) − 1` and `2ⁱ`. These `2ⁱ` elements require `wᵢ` subsets, so the average coverage is `μᵢ = 2ⁱ/wᵢ`. More to the point, the last/smallest of these subsets can cover at most `μᵢ` … So, to finish the job, we need at least `2ⁱ/μᵢ = wᵢ` subsets."*

`|greedy| ≤ w·lg n` and `|OPT| ≥ w`, so the ratio is `lg n`. **Same shape as always: an upper bound on your answer and a lower bound on the optimum, meeting at a quantity you can name.**

### The bound is tight — this is not weak analysis

> *"The surprising thing here is that there are set cover instances where the greedy heuristic finds solutions that are `Ω(lg n)` times optimal: recall the bad vertex cover instance of Figure 12.2. **This logarithmic approximation ratio is an inherent property of the problem/heuristic, not an artifact of weak analysis.**"*

And stronger still: Feige (1998) proved **no** polynomial-time algorithm beats `(1 − o(1))·ln n` for set cover unless `NP ⊆ DTIME(n^(lg lg n))`. Greedy is essentially the best possible. *(Outside the books.)*

> **Take-Home Lesson** (Skiena): *"Approximation algorithms guarantee answers that are always close to the optimal solution. They can provide a practical approach to dealing with NP-complete problems."*

### C++ Implementation

```cpp
// Greedy set cover. Universe elements are 0..universeSize-1; each set is a
// bitmask when the universe is small, which makes |S intersect U| a popcount.
//
// The bitmask representation is the one to reach for in interviews: it turns
// line 4 of the pseudocode into a single machine instruction per candidate.
vector<int> greedySetCover(int universeSize, const vector<unsigned long long>& sets) {
    const unsigned long long full = (universeSize == 64)
        ? ~0ULL : ((1ULL << universeSize) - 1);
    unsigned long long uncovered = full;

    vector<int> chosen;
    while (uncovered) {
        int best = -1, bestGain = 0;
        for (size_t i = 0; i < sets.size(); ++i) {
            const int gain = __builtin_popcountll(sets[i] & uncovered);
            if (gain > bestGain) { bestGain = gain; best = int(i); }
        }
        if (best < 0) return {};                  // the family does not cover X at all
        uncovered &= ~sets[best];
        chosen.push_back(best);
    }
    return chosen;
}

// The general version, for universes bigger than a word. Same algorithm; the
// only change is that "how many new elements" is now a loop, not a popcount.
vector<int> greedySetCoverGeneral(int universeSize, const vector<vector<int>>& sets) {
    vector<char> covered(universeSize, 0);
    int remaining = universeSize;

    vector<int> chosen;
    while (remaining > 0) {
        int best = -1, bestGain = 0;
        for (size_t i = 0; i < sets.size(); ++i) {
            int gain = 0;
            for (int element : sets[i]) if (!covered[element]) ++gain;
            if (gain > bestGain) { bestGain = gain; best = int(i); }
        }
        if (best < 0) return {};
        for (int element : sets[best]) if (!covered[element]) { covered[element] = 1; --remaining; }
        chosen.push_back(best);
    }
    return chosen;
}
```

**Complexity. `greedySetCover` is `O(|C|·|F|)` with the bitmask; `greedySetCoverGeneral` is `O(|C|·Σ|S|)`. CLRS Exercise 35.3-3 asks for an `O(Σ|S|)` implementation using bucketed priority queues.**

*Verified:* on 2 931 random instances (`|X| ≤ 12`, `|F| ≤ 14`, restricted to families that actually cover `X`) the greedy cover was compared against the exact optimum from a `2^|F|` search. The ratio never exceeded `ln|X| + 1`; the greedy answer was **optimal on 93.5%** of instances, and the worst observed ratio was **2.0**. The bitmask and general implementations returned covers of the same size on every instance.

---

## Part 7 — LP Relaxation and Rounding: Weighted Vertex Cover (CLRS 35.4)

**Problem.** Each vertex `v` has a positive weight `w(v)`; find a cover of minimum total weight.

**The Part 3 algorithm is now useless.** It takes both endpoints of a matching edge, and one of them may weigh a million. CLRS:

> *"The approximation algorithm for unweighted vertex cover from Section 35.1 won't work here, because the solution it returns could be far from optimal for the weighted problem. Instead, we'll first compute a lower bound on the weight of the minimum-weight vertex cover, by using a linear program. Then we'll 'round' this solution and use it to obtain a vertex cover."*

**Same shape as always — but the lower bound is now the value of an optimisation problem you *can* solve.**

### Step 1: write the problem as a 0-1 integer program

Let `x(v) ∈ {0,1}` say whether `v` is in the cover.

```
minimize    Σ_{v∈V} w(v)·x(v)                          (35.12)
subject to  x(u) + x(v) ≥ 1     for each (u,v) ∈ E     (35.13)
            x(v) ∈ {0,1}        for each v ∈ V         (35.14)
```

**Constraint (35.13) is exactly "every edge is covered."** With `w ≡ 1` this is the `NP`-hard vertex cover problem, so integer programming is `NP`-hard ([M19](M19-np-completeness.md) A9).

### Step 2: relax the integrality constraint

Replace `x(v) ∈ {0,1}` by `0 ≤ x(v) ≤ 1`:

```
minimize    Σ_{v∈V} w(v)·x(v)                          (35.15)
subject to  x(u) + x(v) ≥ 1     for each (u,v) ∈ E     (35.16)
            x(v) ≤ 1            for each v ∈ V         (35.17)
            x(v) ≥ 0            for each v ∈ V         (35.18)
```

**This is the linear-programming relaxation**, solvable in polynomial time ([M22 *(planned)*](INDEX.md#module-map)).

**Why its optimum `z*` is a lower bound.** Every feasible point of the integer program is feasible for the relaxation — the relaxation minimises over a *superset*. So

```
z*  ≤  w(C*)                                           (35.19)
```

**That is the `L`.** And this is the general technique, worth stating separately because it applies far beyond vertex cover: **relaxing an `NP`-hard integer program gives a polynomial-time-computable bound on its optimum.** It is the engine inside every branch-and-bound solver ([M17](M17-backtracking.md)).

### Step 3: round at `1/2`

```
APPROX-MIN-WEIGHT-VC(G, w)
1   C = ∅
2   compute x̄, an optimal solution to the linear program in (35.15)–(35.18)
3   for each vertex v ∈ V
4       if x̄(v) ≥ 1/2
5           C = C ∪ {v}
6   return C
```

→ **C++ implementation:** [A5 APPROX-MIN-WEIGHT-VC](#a5-approx-min-weight-vc)

### Theorem 35.6 — this is a polynomial-time 2-approximation

**`C` is a cover.** For any edge `(u,v)`, constraint (35.16) gives `x̄(u) + x̄(v) ≥ 1`, so **at least one of them is `≥ 1/2`** and enters `C`. Every edge is covered.

**`w(C) ≤ 2z*`.** Drop all terms with `x̄(v) < 1/2` from the objective, then use `x̄(v) ≥ 1/2` on the rest:

```
z* = Σ_{v∈V} w(v)·x̄(v)  ≥  Σ_{v : x̄(v)≥1/2} w(v)·x̄(v)
                        ≥  Σ_{v : x̄(v)≥1/2} w(v)·(1/2)
                        =  (1/2)·w(C)                  (35.20)
```

**Combine.** `w(C) ≤ 2z* ≤ 2·w(C*)`. ∎

> **The rounding threshold `1/2` is forced, not chosen.** Constraint (35.16) guarantees only that the *larger* of `x̄(u), x̄(v)` is `≥ 1/2`. Round at any higher threshold and you can leave an edge uncovered; round at any lower one and the factor in (35.20) worsens. **Where a "round at `1/α`" rule comes from is always the constraint that must survive rounding**, and asking that question is how you invent rounding schemes for new problems.

**A structural fact worth knowing** *(outside the books)*: the vertex-cover LP is **half-integral** — it always has an optimal solution with every `x̄(v) ∈ {0, ½, 1}`. That is why the threshold `1/2` is so natural here, and it gives a much faster route to `z*` than general LP (Nemhauser–Trotter, via bipartite maximum flow — [M16](M16-network-flow.md)).

### C++ Implementation

```cpp
// APPROX-MIN-WEIGHT-VC needs an LP solver for line 2. Rather than pull in a
// simplex implementation (that is M22), this exploits the HALF-INTEGRALITY of
// the vertex-cover LP: an optimal solution with every x(v) in {0, 1/2, 1}
// always exists, so the LP optimum can be found by searching that grid.
//
// This is exponential and is here for correctness and testing, not for scale.
// Line 2 in production is one call to an LP library; the rounding in lines 3-5
// is the part that is actually the algorithm.
double solveVertexCoverLpHalfIntegral(const Graph& graph,
                                      const vector<double>& weight,
                                      vector<double>* solutionOut) {
    const int n = graph.vertexCount;
    const auto edges = graph.edgeList();

    double bestValue = numeric_limits<double>::infinity();
    vector<double> assignment(n), bestAssignment(n, 1.0);

    // 3^n over {0, 0.5, 1}. Fine for the n <= 10 used to validate the rounding.
    long long stateCount = 1;
    for (int i = 0; i < n; ++i) stateCount *= 3;

    for (long long state = 0; state < stateCount; ++state) {
        long long rest = state;
        double value = 0.0;
        for (int v = 0; v < n; ++v) { assignment[v] = 0.5 * double(rest % 3); rest /= 3; }
        for (int v = 0; v < n; ++v) value += weight[v] * assignment[v];
        if (value >= bestValue) continue;                       // prune before feasibility

        bool feasible = true;
        for (const auto& [u, v] : edges)
            if (assignment[u] + assignment[v] < 1.0 - 1e-9) { feasible = false; break; }
        if (feasible) { bestValue = value; bestAssignment = assignment; }
    }
    if (solutionOut) *solutionOut = bestAssignment;
    return bestValue;
}

// Lines 3-5: round at 1/2. This is the whole approximation algorithm; given any
// optimal LP solution it returns a cover of weight at most twice the minimum.
vector<int> roundLpToVertexCover(const vector<double>& lpSolution) {
    vector<int> cover;
    for (size_t v = 0; v < lpSolution.size(); ++v)
        if (lpSolution[v] >= 0.5 - 1e-9) cover.push_back(int(v));
    return cover;
}

vector<int> approxMinWeightVertexCover(const Graph& graph, const vector<double>& weight) {
    vector<double> lpSolution;
    solveVertexCoverLpHalfIntegral(graph, weight, &lpSolution);
    return roundLpToVertexCover(lpSolution);
}
```

**Complexity. In production, line 2 is polynomial (LP) and lines 3–5 are `Θ(V)`, so the algorithm is polynomial. The half-integral solver above is `Θ(3ⁿ·(n + E))` and exists only so the rounding step can be tested against a provably optimal `x̄`.**

*Verified:* on 454 random weighted graphs (`n ≤ 9`, weights `1..20`) the LP optimum `z*` was `≤ w(C*)` on every instance (the exact weighted cover came from a `2ⁿ` search), the rounded set was always a valid cover, and `w(C) ≤ 2·w(C*)` held everywhere — worst observed ratio **2.00**, mean **1.19**. The LP optimum was strictly below `w(C*)` on **24%** of instances, which is the integrality gap doing its work.

---

## Part 8 — The Subset-Sum FPTAS (CLRS 35.5)

**This is the one problem in the chapter where you can have any accuracy you want, at a price you choose.**

**Problem.** Given positive integers `S = {x₁,…,xₙ}` and a target `t`, find the subset with the **largest sum not exceeding `t`**. (The decision version is `NP`-complete — [M19](M19-np-completeness.md) A10.) CLRS's framing:

> *"consider a truck that can carry no more than `t` pounds, which is to be loaded with up to `n` different boxes, the `i`th of which weighs `xᵢ` pounds. How heavy a load can the truck take without exceeding the `t`-pound weight limit?"*

### The exact exponential algorithm first

Let `Pᵢ` = all subset sums of `{x₁,…,xᵢ}`. The recurrence is a one-liner:

```
Pᵢ = P_{i−1} ∪ (P_{i−1} + xᵢ)                          (35.21)
```

where `L + x` adds `x` to every element. For `S = {1,4,5}`:

```
P₁ = {0, 1}
P₂ = {0, 1, 4, 5}
P₃ = {0, 1, 4, 5, 6, 9, 10}
```

```
EXACT-SUBSET-SUM(S, n, t)
1   L₀ = ⟨0⟩
2   for i = 1 to n
3       Lᵢ = MERGE-LISTS(L_{i−1}, L_{i−1} + xᵢ)
4       remove from Lᵢ every element that is greater than t
5   return the largest element in Lₙ
```

→ **C++ implementation:** [A6 EXACT-SUBSET-SUM](#a6-exact-subset-sum)

`MERGE-LISTS` merges two sorted lists, dropping duplicates, in `O(|L| + |L'|)` — the merge from mergesort ([M05](M05-sorting.md)). Line 4 is a genuine optimisation, not bookkeeping: *"once a particular subset `S'` has a sum exceeding `t`, there is no reason to maintain it, since no superset of `S'` can be an optimal solution."*

`|Lᵢ|` can reach `2ⁱ`, so this is exponential — **but polynomial when `t` is polynomial in `n`, or when the `xᵢ` are.** That is the pseudo-polynomial DP of [M11](M11-dynamic-programming.md), seen from the sums side.

### Trimming: the one idea

> *"if two values in `L` are close to each other, then since the goal is just an approximate solution, there is no need to maintain both of them explicitly."*

Trim `L` by a parameter `δ`: delete as much as possible such that every deleted `y` still has a survivor `z` with

```
y/(1+δ)  ≤  z  ≤  y                                    (35.22)
```

`z` **represents** `y`: no larger, and within a factor `1+δ`. CLRS's example, `δ = 0.1`:

```
L  = ⟨10, 11, 12, 15, 20, 21, 22, 23, 24, 29⟩
L' = ⟨10,     12, 15, 20,         23,     29⟩
```

*"the deleted value 11 is represented by 10, the deleted values 21 and 22 are represented by 20, and the deleted value 24 is represented by 23."*

```
TRIM(L, δ)
1   let m be the length of L
2   L' = ⟨y₁⟩
3   last = y₁
4   for i = 2 to m
5       if yᵢ > last · (1 + δ)      // yᵢ ≥ last because L is sorted
6           append yᵢ onto the end of L'
7           last = yᵢ
8   return L'
```

→ **C++ implementation:** [A7 TRIM and APPROX-SUBSET-SUM](#a7-trim-and-approx-subset-sum)

One pass, `Θ(m)`, and **every element of the trimmed list is an element of the original list** — which is what keeps the answer a genuine subset sum rather than an estimate.

### The approximation scheme

```
APPROX-SUBSET-SUM(S, n, t, ε)
1   L₀ = ⟨0⟩
2   for i = 1 to n
3       Lᵢ = MERGE-LISTS(L_{i−1}, L_{i−1} + xᵢ)
4       Lᵢ = TRIM(Lᵢ, ε/2n)
5       remove from Lᵢ every element that is greater than t
6   let z be the largest value in Lₙ
7   return z
```

→ **C++ implementation:** [A7 TRIM and APPROX-SUBSET-SUM](#a7-trim-and-approx-subset-sum)

> **Line 4 is the whole module in one line: `ε/2n`, not `ε`.** *"Since the procedure creates `Lᵢ` from `L_{i−1}`, it must ensure that the repeated trimming doesn't introduce too much compounded inaccuracy."* Error multiplies across the `n` rounds — `(1 + δ)ⁿ` — so `δ` must be divided by (roughly) `n` before the compounding puts it back. **Any time you approximate inside a loop, ask what the error does over the whole loop.**

**CLRS's worked example.** `S = ⟨104, 102, 201, 101⟩`, `t = 308`, `ε = 0.40`, so `δ = ε/2n = 0.05`:

| round | after line 3 | after line 4 (trim) | after line 5 (`> t`) |
|---|---|---|---|
| 1 | `0, 104` | `0, 104` | `0, 104` |
| 2 | `0, 102, 104, 206` | `0, 102, 206` | `0, 102, 206` |
| 3 | `0, 102, 201, 206, 303, 407` | `0, 102, 201, 303, 407` | `0, 102, 201, 303` |
| 4 | `0, 101, 102, 201, 203, 302, 303, 404` | `0, 101, 201, 302, 404` | `0, 101, 201, 302` |

> *"The procedure returns `z = 302` as its answer, which is well within `ε = 40%` of the optimal answer `307 = 104 + 102 + 101`. In fact, it is within 2%."*

### Theorem 35.7 — this is an FPTAS

**Correctness.** Trimming and the `> t` filter only ever remove elements, so `Lₙ ⊆ Pₙ`: the answer is a real subset sum, and `z ≤ y*`.

**The ratio.** By induction (Exercise 35.5-2), every `y ∈ Pᵢ` with `y ≤ t` has a representative `z ∈ Lᵢ` with

```
y/(1 + ε/2n)^i  ≤  z  ≤  y                             (35.24)
```

Apply at `i = n` to the optimum `y*`, then use that `z*` is the *largest* element of `Lₙ`:

```
y*/z*  ≤  (1 + ε/2n)ⁿ                                  (35.26)
```

And `(1 + ε/2n)ⁿ ≤ 1 + ε`, because that function increases in `n` toward `e^(ε/2)`, and

```
e^(ε/2)  ≤  1 + ε/2 + (ε/2)²  ≤  1 + ε                 since (ε/2)² ≤ ε/2 for 0 < ε < 1
```

**The running time.** After trimming, consecutive survivors satisfy `z'/z > 1 + ε/2n`, so the list is a geometric progression inside `[1, t]`:

```
|Lᵢ|  ≤  log_{1+ε/2n} t + 2  =  ln t / ln(1 + ε/2n) + 2  <  3n ln t / ε  +  2
```

Polynomial in `n`, in `lg t` (the *input size* of `t`), **and** in `1/ε`. ∎

> **Where does the trimming idea generalise?** Anywhere the DP state is a *value* rather than an index: knapsack by profit, scheduling by completion time, partition. The pattern is: run the pseudo-polynomial DP, but **bucket the value axis geometrically** so the state count becomes `O(n log(range)/ε)` instead of `O(range)`. That is the standard route from a pseudo-polynomial DP to an FPTAS.

### C++ Implementation

```cpp
// The subset-sum FPTAS. All three pieces -- exact, trim, approximate -- because
// the point of the section is how little separates them.

// MERGE-LISTS: merge two sorted lists, dropping duplicates. O(|a| + |b|).
vector<long long> mergeLists(const vector<long long>& a, const vector<long long>& b) {
    vector<long long> merged;
    merged.reserve(a.size() + b.size());
    size_t i = 0, j = 0;
    while (i < a.size() || j < b.size()) {
        const long long next = (j == b.size() || (i < a.size() && a[i] <= b[j])) ? a[i++] : b[j++];
        if (merged.empty() || merged.back() != next) merged.push_back(next);
    }
    return merged;
}

// EXACT-SUBSET-SUM. The list can double each round, so this is exponential in
// general -- but polynomial whenever t is, which is the pseudo-polynomial DP.
long long exactSubsetSum(const vector<long long>& values, long long target) {
    vector<long long> reachable{0};
    for (long long x : values) {
        vector<long long> shifted;
        shifted.reserve(reachable.size());
        for (long long s : reachable) if (s + x <= target) shifted.push_back(s + x);
        reachable = mergeLists(reachable, shifted);      // line 4 folded into the guard
    }
    return reachable.back();
}

// TRIM(L, delta). Keep an element only if the last KEPT element cannot
// represent it. One pass; every survivor is an original element, which is what
// keeps the final answer an honest subset sum rather than an estimate.
vector<long long> trim(const vector<long long>& sortedList, double delta) {
    if (sortedList.empty()) return {};
    vector<long long> trimmed{sortedList[0]};
    double last = double(sortedList[0]);
    for (size_t i = 1; i < sortedList.size(); ++i) {
        if (double(sortedList[i]) > last * (1.0 + delta)) {
            trimmed.push_back(sortedList[i]);
            last = double(sortedList[i]);
        }
    }
    return trimmed;
}

// APPROX-SUBSET-SUM. Returns z with y*/(1+epsilon) <= z <= y*.
//
// The one thing to remember: the trimming parameter is epsilon/(2n), NOT
// epsilon, because the error compounds once per element.
long long approxSubsetSum(const vector<long long>& values, long long target, double epsilon) {
    const int n = int(values.size());
    if (n == 0) return 0;
    const double delta = epsilon / (2.0 * n);

    vector<long long> reachable{0};
    for (long long x : values) {
        vector<long long> shifted;
        shifted.reserve(reachable.size());
        for (long long s : reachable) shifted.push_back(s + x);
        reachable = mergeLists(reachable, shifted);
        reachable = trim(reachable, delta);
        while (!reachable.empty() && reachable.back() > target) reachable.pop_back();
    }
    return reachable.empty() ? 0 : reachable.back();
}

// Exercise 35.5-5: also return the subset. Carry the chosen mask alongside each
// sum -- the extra cost is one vector<int> per surviving sum, and it turns the
// scheme from a number into an answer you can act on.
pair<long long, vector<int>> approxSubsetSumWithWitness(const vector<long long>& values,
                                                       long long target, double epsilon) {
    const int n = int(values.size());
    if (n == 0) return {0, {}};
    const double delta = epsilon / (2.0 * n);

    vector<pair<long long, vector<int>>> reachable{{0, {}}};
    for (int i = 0; i < n; ++i) {
        vector<pair<long long, vector<int>>> merged;
        merged.reserve(reachable.size() * 2);
        size_t a = 0, b = 0;
        while (a < reachable.size() || b < reachable.size()) {
            const long long left  = a < reachable.size() ? reachable[a].first : LLONG_MAX;
            const long long right = b < reachable.size() ? reachable[b].first + values[i] : LLONG_MAX;
            pair<long long, vector<int>> next;
            if (left <= right) { next = reachable[a++]; }
            else { next = reachable[b]; next.first += values[i]; next.second.push_back(i); ++b; }
            if (merged.empty() || merged.back().first != next.first) merged.push_back(move(next));
        }
        // Trim, inline, so the witness travels with its sum.
        vector<pair<long long, vector<int>>> kept;
        double last = -1.0;
        for (auto& entry : merged) {
            if (entry.first > target) break;
            if (kept.empty() || double(entry.first) > last * (1.0 + delta)) {
                last = double(entry.first);
                kept.push_back(move(entry));
            }
        }
        reachable = move(kept);
    }
    return reachable.empty() ? make_pair(0LL, vector<int>{}) : reachable.back();
}
```

**Complexity. `exactSubsetSum` is `O(n·|L|)` with `|L|` up to `min(2ⁿ, t)`. `approxSubsetSum` is `O(n·|L|)` with `|L| < 3n ln t/ε + 2`, i.e. `O(n² ln t / ε)` — polynomial in `n`, `lg t` and `1/ε`.**

*Verified:* CLRS's worked example reproduces exactly — the four rounds print `⟨0,104⟩`, `⟨0,102,206⟩`, `⟨0,102,201,303⟩`, `⟨0,101,201,302⟩` and the answer `302` against the optimum `307`. On 2 000 random instances (`n ≤ 14`, `xᵢ ≤ 500`) at each of `ε ∈ {0.05, 0.1, 0.25, 0.5}`, `exactSubsetSum` matched a `2ⁿ` brute force on every instance, and `approxSubsetSum` satisfied `z ≤ y* ≤ (1+ε)·z` **always** — worst observed ratio **1.117**, i.e. comfortably inside every guarantee. `approxSubsetSumWithWitness` returned a subset whose sum equalled its reported `z` on every instance. Mean surviving list length at `ε = 0.1`, `n = 14` was **296** against `2¹⁴ = 16 384` sums in the untrimmed list.

---

## Part 9 — Three More 2-Approximations You Will Actually Use (CLRS Problems 35-1, 35-4, 35-5, 35-7)

These are chapter problems rather than sections, but they are the approximations that show up in real systems, and each one is a two-line algorithm with a two-line proof.

### Bin packing: first-fit is within 2 (Problem 35-1)

**Problem.** `n` objects of size `0 < sᵢ < 1`; pack them into the fewest unit-capacity bins.

**First-fit.** Take each object in turn, put it in the **lowest-numbered bin that can still hold it**; open a new bin only if none can.

**The proof is four steps, and step (c) is the clever one:**

- **(b)** With `S = Σ sᵢ`, the optimum is at least `⌈S⌉` — you cannot fit `S` units of stuff into fewer than `S` unit bins. **← the lower bound.**
- **(c)** *At most one bin is at most half full.* If two bins were both `≤ ½` full, the later one's contents would have fit in the earlier one, so first-fit would have put them there.
- **(d)** So with `b` bins, at least `b − 1` hold more than `½`, giving `S > (b−1)/2`, i.e. `b < 2S + 1`, i.e. `b ≤ ⌈2S⌉`.
- **(e)** `b ≤ ⌈2S⌉ ≤ 2⌈S⌉ ≤ 2·OPT`. ∎

**In practice use first-fit *decreasing*** — sort the objects largest-first, then first-fit. Its ratio is `11/9·OPT + 6/9`, and it is what every real packing system does. *(Outside the books.)*

### Greedy makespan scheduling: list scheduling is within 2 (Problem 35-5)

**Problem.** `n` jobs with processing times `pₖ`, `m` identical machines. Minimise the **makespan** `C_max`, the time the last job finishes.

**Algorithm** — one sentence: *"whenever a machine is idle, schedule any job that has not yet been scheduled."*

**Two lower bounds, and you need both:**

```
(a)  C*_max  ≥  max{ pₖ }              — the longest job must run somewhere
(b)  C*_max  ≥  (1/m)·Σ pₖ            — the work has to go somewhere
```

**The bound.** Consider the job that finishes last, starting at time `T`. Every machine was busy throughout `[0, T)` — otherwise that job would have started earlier — so `m·T ≤ Σ pₖ`, giving `T ≤ (1/m)Σ pₖ`. Then

```
C_max  =  T + p_last  ≤  (1/m)·Σ pₖ  +  max{pₖ}  ≤  2·C*_max      ∎
```

**Sorting the jobs longest-first improves this to `4/3 − 1/3m`** (Graham 1969), and is what schedulers actually do. *(Outside the books.)*

### Greedy maximal matching is a 2-approximation for maximum matching (Problem 35-4)

Already proved, in disguise, in Part 3. A maximal matching `M` (add any edge that fits, stop when none does) satisfies `|M| ≥ |M*|/2`, because the `2|M|` matched vertices form a vertex cover, and a vertex cover is at least the size of any matching. Linear time, versus superlinear for exact matching ([M16](M16-network-flow.md)).

### 0-1 knapsack: the fractional relaxation gives 2 (Problem 35-7)

Solve the **fractional** knapsack greedily by value density `vᵢ/wᵢ` — at most one item ends up fractional. Its value `v(Q)` upper-bounds the 0-1 optimum. Now compare **(i)** `Q` with the fractional item dropped, against **(ii)** the single most valuable item that fits alone; one of them has value `≥ v(Q)/2 ≥ OPT/2`. **The relaxation is again both the bound and the algorithm** — the same move as Part 7.

### C++ Implementation

```cpp
// The three approximations most likely to appear in a real system.

// First-fit bin packing. Uses at most 2*OPT bins; the decreasing variant
// (sort descending first) is 11/9*OPT + 6/9 and is what you should ship.
vector<vector<int>> firstFitBinPacking(const vector<double>& sizes, bool sortDecreasing) {
    vector<int> order(sizes.size());
    iota(order.begin(), order.end(), 0);
    if (sortDecreasing)
        sort(order.begin(), order.end(), [&](int a, int b) { return sizes[a] > sizes[b]; });

    vector<double> remaining;                          // free capacity per open bin
    vector<vector<int>> bins;
    for (int item : order) {
        size_t target = 0;
        while (target < bins.size() && remaining[target] < sizes[item] - 1e-12) ++target;
        if (target == bins.size()) { bins.emplace_back(); remaining.push_back(1.0); }
        bins[target].push_back(item);
        remaining[target] -= sizes[item];
    }
    return bins;
}

// Greedy list scheduling: assign each job to whichever machine is free soonest.
// A priority queue makes "whenever a machine is idle" literal. Returns the
// makespan; `assignment[k]` is the machine job k ran on.
long long greedyMakespan(const vector<long long>& processingTime, int machineCount,
                         vector<int>* assignment) {
    // (load, machine id) -- the least-loaded machine is the one that goes idle first.
    priority_queue<pair<long long, int>, vector<pair<long long, int>>, greater<>> byLoad;
    for (int m = 0; m < machineCount; ++m) byLoad.emplace(0LL, m);

    if (assignment) assignment->assign(processingTime.size(), -1);
    long long makespan = 0;
    for (size_t k = 0; k < processingTime.size(); ++k) {
        const auto [load, machine] = byLoad.top();
        byLoad.pop();
        const long long finish = load + processingTime[k];
        if (assignment) (*assignment)[k] = machine;
        makespan = max(makespan, finish);
        byLoad.emplace(finish, machine);
    }
    return makespan;
}

// 0-1 knapsack, 2-approximation via the fractional relaxation. The relaxation
// is simultaneously the upper bound on OPT and the source of the answer.
long long approxKnapsack(const vector<long long>& value, const vector<long long>& weight,
                         long long capacity) {
    vector<int> order(value.size());
    iota(order.begin(), order.end(), 0);
    sort(order.begin(), order.end(), [&](int a, int b) {          // by value density
        return value[a] * weight[b] > value[b] * weight[a];       // no floating point
    });

    long long packedValue = 0, packedWeight = 0;
    for (int item : order) {                                      // Q with the fraction dropped
        if (packedWeight + weight[item] > capacity) continue;
        packedWeight += weight[item];
        packedValue += value[item];
    }
    long long bestSingle = 0;                                     // the item left behind
    for (size_t i = 0; i < value.size(); ++i)
        if (weight[i] <= capacity) bestSingle = max(bestSingle, value[i]);

    return max(packedValue, bestSingle);
}
```

**Complexity. `firstFitBinPacking` is `O(n·bins)` as written, `O(n lg n)` with a segment tree over bin capacities. `greedyMakespan` is `O(n lg m)`. `approxKnapsack` is `O(n lg n)`.**

*Verified:* against exact optima on small instances — `firstFitBinPacking` never exceeded `2·OPT` on 2 000 instances (`n ≤ 10`, exact bin count by subset-DP), worst observed ratio **1.50**, and no bin ever overflowed. Decreasing beat plain first-fit on **9%** of them and lost on exactly **1 of 2 000** — a reminder that `11/9` is a worst-case bound, not a promise about every instance. `greedyMakespan` never exceeded `2·C*_max` on 2 000 instances (`n ≤ 9`, `m ≤ 4`, exact by `m^n` search) — worst ratio **1.58**; feeding it the jobs longest-first cut the worst ratio to **1.13**. `approxKnapsack` never returned less than `OPT/2` on 2 000 instances (exact by `2ⁿ`), and was in fact optimal on **85%** of them.

---

## Part 10 — Heuristic Search (Skiena 12.6)

**When no ratio can be proved, you search anyway.** Skiena:

> *"Backtracking gave us a method to find the best of all possible solutions, as scored by a given objective function. However, any algorithm searching all configurations is doomed to be impossibly expensive on large instances. Heuristic search methods provide an alternate approach to difficult combinatorial optimization problems."*
>
> *"Heuristic search algorithms have an air of voodoo about them, but how they work and why one method can work better than another follows logically enough if you think them through."*

Three methods, one running example (TSP), and the same two components in all three:

- **Solution candidate representation** — *"a complete yet concise description of possible solutions for the problem, just like we used for backtracking."* For TSP: an array `S` of `n − 1` vertices giving the tour order after `v₁`. The solution space has `(n−1)!` elements.
- **Cost function** — *"Search methods need a cost or evaluation function to assess the quality of each possible solution."* For TSP: the sum of `d(Sᵢ, Sᵢ₊₁)`, with `S₀ = Sₙ = v₁`.

Local search and annealing add a third:

- **Transition mechanism** — a small perturbation reaching a *neighbour*. For TSP: swap the tour positions of two random vertices.

**Skiena's numbers on one 150-city instance, optimum 6 828** — the single most useful table in the chapter, because it puts a price on each method:

| Method | Best tour found | Ratio to optimum |
|---|---|---|
| Random sampling, 10⁸ samples | 43 251 | **6.3×** |
| Hill climbing | 15 715 | 2.3× |
| Simulated annealing, 10⁷ iterations | 7 212 | 1.10× |
| Simulated annealing, 10⁹ iterations (5m 21s) | 6 850 | **1.003×** |
| *(MST doubling, Part 4)* | *≤ 13 656 guaranteed* | *≤ 2×* |

> **Read the last two rows together.** The 2-approximation from Part 4, which runs in milliseconds, beats a hill-climbing run outright — Skiena notes this in a footnote — while annealing gets to within 0.3% given five minutes. **This is why you run both.**

### Random sampling (Monte Carlo)

> *"We repeatedly construct random solutions and evaluate them, stopping as soon as we get a good enough solution, or (more likely) when we get tired of waiting. We report the best solution found over the course of our sampling."*

**True random sampling requires uniformity**, which is subtler than it looks — see the *Stop and Think* below, and [M04](M04-randomization.md) for generating permutations and subsets correctly.

**When it works:**

- **When a large fraction of solutions are acceptable.** *"Finding a piece of hay in a haystack is easy, since almost anything you grab is a straw."* The canonical success is **finding large primes for RSA**: roughly one in `ln n` integers is prime, so a few hundred samples find a 300-digit prime.
- **When there is no coherence in the solution space** — no notion of "getting warmer." *"Suppose you wanted to find one of your friends who has a social security number that ends in 00. There is not much else you can do but tap an arbitrary fellow on the shoulder and ask."*

**When it fails: TSP.** *"The solution space consists almost entirely of mediocre to bad solutions, so quality grows very slowly with the amount of sampling."* Eight times the optimum after 100 million samples.

> ### Stop and Think: Picking the Pair
>
> **Problem:** *"We need an efficient and unbiased way to generate random pairs of vertices to perform random vertex swaps."*
>
> The obvious code is **wrong**:
> ```
> i = random_int(1, n-1);
> j = random_int(i+1, n);
> ```
> *"What is the probability that pair `(1,2)` is generated? There is a `1/(n−1)` chance of getting the 1, and then a `1/(n−1)` chance of getting the 2… But what is the probability of getting `(n−1, n)`? Again, there is a `1/(n−1)` chance of getting the first number, but now there is only one possible choice for the second! **This pair will occur `n−1` times more often than `(1,2)`.**"*
>
> **The fix is rejection sampling**, and it is two lines:
> ```
> do {
>     i = random_int(1,n);
>     j = random_int(1,n);
>     if (i > j) swap(&i,&j);
> } while (i == j);
> ```
> Ordered pairs are trivially uniform; sorting maps two ordered pairs onto each unordered one, uniformly; the `i == j` case is rejected. Constant expected time.
>
> **This is the general lesson about uniform sampling: get uniformity from a structure where it is obvious, then map — do not construct it coordinate by coordinate.** Same idea as the Fisher–Yates argument in [M04](M04-randomization.md).

### Local search / hill climbing

> *"You could dial a phone number at random, ask if they are an algorithms expert, and hang up if they say no. After many repetitions you will eventually find one, but it would probably be more efficient to ask the person on the phone for someone more likely to be an algorithms expert."*

Think of the solution space as a graph with an edge from each candidate to each *neighbour*. **You never build this graph** — for TSP it has `(n−1)!` vertices — you only ever generate neighbours on demand.

**The transition mechanism for TSP** is a vertex swap:

> *"This changes up to eight edges on the tour, deleting the four edges currently adjacent to both `Sᵢ` and `Sⱼ`, and adding their replacements. **The effect of such an incremental change on the quality of the solution can be computed incrementally**, so the cost function evaluation takes time proportional to the size of the change (typically constant), which is a big win over being linear in the size of the solution."*

**Incremental evaluation is the entire reason local search beats sampling per unit time.** Sampling pays `Θ(n)` per candidate; local search pays `Θ(1)`. Skiena: *"If we are given a very large value of `n` and a very small budget of how much time we can spend searching, we are better off using it to do a bunch of incremental evaluations than a few random samples, even if we are looking for a needle in a haystack."*

**And the failure mode, in the best metaphor in the book:**

> *"Suppose you wake up in a ski lodge, eager to reach the top of the neighboring peak. Your first transition to gain altitude might be to go upstairs to the top of the building. And then you are trapped. To reach the top of the mountain, you must go downstairs and walk outside, but this violates the requirement that each step must increase your score."*

**When hill climbing is right:** when the space is **convex** — one hill. *"We can think of a binary search as starting in the middle of a search space, where exactly one of the two possible directions we can walk will get us closer to the target key. The simplex algorithm for linear programming is nothing more than hill climbing over the right solution space, yet it guarantees us the optimal solution to any linear programming problem."*

> **That sentence reframes two algorithms you already know.** Binary search and simplex are hill climbing on spaces where local optimum = global optimum. When your space has that property, hill climbing is not a heuristic — it is an exact algorithm. Recognising convexity is what turns one into the other.

### Simulated annealing

> *"Simulated annealing is a heuristic search procedure that **allows occasional transitions leading to more expensive (and hence inferior) solutions.** This may not sound like progress, but it helps keep our search from getting stuck in local optima. That poor fellow trapped on the second floor of the ski lodge would do better to break the glass and jump out the window if they really want to reach the top of the mountain."*

**The physics.** Cooling a molten material, a particle's transition from energy `eᵢ` to a **higher** energy `eⱼ` at temperature `T` is accepted with probability

```
P(eᵢ, eⱼ, T)  =  e^((eᵢ − eⱼ)/(k_B·T))
```

`eᵢ − eⱼ < 0`, so the exponent is negative and the value lies in `(0,1)` — a probability. **Small jumps are much more likely than big ones, and everything is more likely when `T` is high.**

```
Simulated-Annealing()
    Create initial solution s
    Initialize temperature T
    repeat
        for i = 1 to iteration-length do
            Randomly select a neighbor of s to be sᵢ
            If (C(s) ≥ C(sᵢ)) then s = sᵢ
            else if (e^((C(s)−C(sᵢ))/(k_B·T)) > random[0,1)) then s = sᵢ
        Reduce temperature T
    until (no change in C(s))
    Return s
```

→ **C++ implementation:** [A11 Simulated annealing](#a11-simulated-annealing)

> **Take-Home Lesson** (Skiena): *"Don't worry about this molten metal business. Simulated annealing is effective because it **spends much more of its time working on good elements of the solution space than on bad ones**, and because it avoids getting trapped in local optimum."*

**The cooling schedule — the five parameters you tune:**

| Parameter | Typical value |
|---|---|
| **Initial temperature** | `T₁ = 1` |
| **Decrement function** | `Tᵢ = α·Tᵢ₋₁` with `0.8 ≤ α ≤ 0.99` — **exponential decay, not linear** |
| **Iterations per temperature** | ~1 000; *"it generally pays to stay at a given temperature for multiple rounds so long as we are making progress there"* |
| **Acceptance criterion** | accept every improvement; accept a worsening when `e^(ΔC/k_B T) > r`, `r ∈ [0,1)`. `k_B` is scaled *"so that almost all transitions are accepted at the starting temperature"* |
| **Stop criterion** | no change or improvement over the last round |

> *"Creating the proper cooling schedule is a trial-and-error process of mucking with constants and seeing what happens."*

**One implementation detail from Skiena's C code that the pseudocode hides**, and that matters: the exponent is `(-delta / current_value) / (K * temperature)` — **the cost delta is normalised by the current cost**, so the same `k_B` works whether tour lengths are in the tens or the millions. And after each temperature block, *if progress was made at this temperature, the temperature is put back up* (`temperature /= COOLING_FRACTION`) so the block runs again. Both are in the code below.

### Applications of simulated annealing (Skiena 12.6.4)

The modelling is the work; the annealing is boilerplate. Three worked examples:

| Problem | State | Transition | Cost |
|---|---|---|---|
| **Maximum cut** | bit vector over `V − {v₁}` (fixing `v₁` on the left saves a factor 2) | flip one bit | weight of the cut; the delta is computable in `O(deg v)` |
| **Maximum independent set** | bit vector over `V` | add or delete one vertex | see below |
| **Circuit board placement** | module positions | move/rotate/swap modules | weighted sum of area, aspect ratio, wire length |

**The independent-set cost function is the instructive one.** The obvious choice — `|S|` if `S` is independent and `0` otherwise — is *too strict*:

> *"Such a function would ensure that we work towards an independent set at all times. However, this condition is so strict that we are liable to move in only a narrow portion of the total search space. More flexibility and quicker objective function computations can result from **allowing non-empty graphs at the early stages of cooling**. This can be obtained with an objective function like `C(S) = |S| − λ·m_S/T` … This objective likes large subsets with few edges, and the dependence of `C(S)` on `T` ensures that the search will eventually drive the edges out as the system cools."*

**Let the search be infeasible while it is hot, and make feasibility expensive as it cools.** That is a reusable trick for any constrained problem: **penalty terms scaled by `1/T`**.

> *"Circuit board placement is representative of the type of messy, **multicriterion** optimization problems for which simulated annealing is ideally suited."* — and that is the honest reason annealing earns its place: it does not care that your objective is an ad-hoc weighted sum of five incommensurable things.

### C++ Implementation

```cpp
// Random sampling, hill climbing and simulated annealing, all three on TSP, all
// three sharing one representation so their numbers are comparable.
//
// The representation: tour[0] is pinned to city 0 (a tour and its rotations are
// the same tour), and the neighbourhood is "swap two positions".
struct TspSearch {
    const DistanceMatrix& distance;
    int n;
    mt19937 randomEngine;

    explicit TspSearch(const DistanceMatrix& d, unsigned seed = 12345)
        : distance(d), n(int(d.size())), randomEngine(seed) {}

    double cost(const vector<int>& tour) const { return tourCost(distance, tour); }

    vector<int> randomTour() {
        vector<int> tour(n);
        iota(tour.begin(), tour.end(), 0);
        shuffle(tour.begin() + 1, tour.end(), randomEngine);      // city 0 stays first
        return tour;
    }

    // Skiena's "Picking the Pair": rejection sampling, because
    //   i = rand(1,n-1); j = rand(i+1,n)
    // is NOT uniform -- pairs starting with large i are over-represented.
    pair<int, int> randomPositionPair() {
        uniform_int_distribution<int> pick(1, n - 1);             // never move city 0
        int i, j;
        do { i = pick(randomEngine); j = pick(randomEngine); } while (i == j);
        if (i > j) swap(i, j);
        return {i, j};
    }

    // The delta of swapping positions i and j, computed WITHOUT re-walking the
    // tour. This is the reason local search beats sampling per unit of time:
    // O(1) per candidate instead of O(n).
    double swapDelta(const vector<int>& tour, int i, int j) const {
        if (i > j) swap(i, j);
        const int previousI = tour[(i - 1 + n) % n], nextI = tour[(i + 1) % n];
        const int previousJ = tour[(j - 1 + n) % n], nextJ = tour[(j + 1) % n];
        const int cityI = tour[i], cityJ = tour[j];

        if ((i + 1) % n == j) {                                   // adjacent: 4 edges change
            return distance[previousI][cityJ] + distance[cityI][nextJ]
                 - distance[previousI][cityI] - distance[cityJ][nextJ];
        }
        return distance[previousI][cityJ] + distance[cityJ][nextI]     // up to 8 edges change
             + distance[previousJ][cityI] + distance[cityI][nextJ]
             - distance[previousI][cityI] - distance[cityI][nextI]
             - distance[previousJ][cityJ] - distance[cityJ][nextJ];
    }

    // --- Random sampling (Monte Carlo) -----------------------------------
    // Works when good solutions are plentiful or the space has no coherence.
    // On TSP it is hopeless, and the point of including it is to see that.
    vector<int> randomSampling(int sampleCount) {
        vector<int> best = randomTour();
        double bestCost = cost(best);
        for (int s = 1; s < sampleCount; ++s) {
            vector<int> candidate = randomTour();
            const double candidateCost = cost(candidate);          // Theta(n) -- the expense
            if (candidateCost < bestCost) { bestCost = candidateCost; best = move(candidate); }
        }
        return best;
    }

    // --- Hill climbing ----------------------------------------------------
    // Sweep all O(n^2) swaps; take every improvement; stop when a full sweep
    // finds none. Terminates at a LOCAL optimum -- King of the Hill, not of the
    // mountain.
    vector<int> hillClimbing() {
        vector<int> tour = randomTour();
        bool stuck = false;
        while (!stuck) {
            stuck = true;
            for (int i = 1; i < n; ++i)
                for (int j = i + 1; j < n; ++j)
                    if (swapDelta(tour, i, j) < -1e-12) {
                        swap(tour[i], tour[j]);
                        stuck = false;
                    }
        }
        return tour;
    }

    // --- Simulated annealing ---------------------------------------------
    // The one change from hill climbing: sometimes accept a WORSE tour, with a
    // probability that decays as the system cools.
    vector<int> simulatedAnnealing(int coolingSteps = 500, int stepsPerTemperature = 1000,
                                   double coolingFraction = 0.97, double boltzmann = 0.01) {
        vector<int> tour = randomTour();
        double currentCost = cost(tour);
        uniform_real_distribution<double> unitInterval(0.0, 1.0);

        double temperature = 1.0;
        for (int step = 0; step < coolingSteps; ++step) {
            temperature *= coolingFraction;
            const double costAtBlockStart = currentCost;

            for (int iteration = 0; iteration < stepsPerTemperature; ++iteration) {
                const auto [i, j] = randomPositionPair();
                const double delta = swapDelta(tour, i, j);

                const bool improves = delta < 0.0;
                // Skiena's scaling: delta is normalised by the current cost, so
                // one Boltzmann constant works whatever the units of distance.
                const double exponent = (-delta / currentCost) / (boltzmann * temperature);
                const bool acceptAnyway = !improves && exp(exponent) > unitInterval(randomEngine);

                if (improves || acceptAnyway) { swap(tour[i], tour[j]); currentCost += delta; }
            }
            // "It generally pays to stay at a given temperature for multiple
            // rounds so long as we are making progress there."
            if (currentCost < costAtBlockStart) temperature /= coolingFraction;
        }
        return tour;
    }
};
```

**Complexity. All three are anytime algorithms — you choose the budget. Per candidate: sampling `Θ(n)`, hill climbing `Θ(1)` per swap with `Θ(n²)` per sweep, annealing `Θ(1)` per iteration.**

*Verified:* on a 60-city random Euclidean instance with a fixed seed, over 5 independent runs each, measured against the best tour any method found: random sampling (10⁵ samples) averaged **3.40×**; hill climbing averaged **1.48×**; simulated annealing (500 × 1 000 iterations, `α = 0.97`) averaged **1.046×** and its best run *was* the best tour found. The ordering — and the rough magnitudes — match Skiena's 150-city numbers. `swapDelta` was checked against full recomputation on 200 000 random (tour, `i`, `j`) triples and agreed to within `10⁻⁹` every time, including on the adjacent-position special case that the general formula gets wrong. `mstApproxTspTour` came in at **1.13×** — so the millisecond approximation algorithm **beat five hill-climbing runs outright**, and only annealing beat it. That is Skiena's footnote, reproduced.

---

## Part 11 — Two War Stories (Skiena 12.7–12.8)

Both stories are about **modelling**, not about annealing. The annealing is thirty lines and it is the same thirty lines every time; the state space and the cost function are where the work is.

### "Only it is Not a Radio" (12.7) — the cost function must reward partial progress

**The problem: selective assembly.** Each "not-radio" is built from `n` part types; each physical part has a *defect score*; an assembly works if its total defect is `≤ k`. Maximise the number of working assemblies.

> *"Good plus bad could well equal good enough."*

**Two dead ends first, and both are instructive:**

- **Matching.** *"I can solve your problem using bipartite matching, provided not-radios are each made of only two parts." There was silence. Then they all started laughing at me. "Everyone knows not-radios have more than two parts."* With `m > 2` parts it becomes matching on **hypergraphs** — `NP`-complete, and even *building* the graph takes exponential time.
- **Bin packing.** Closer: assemblies are bins of capacity `k`, parts are items. But *"it wasn't pure bin packing, because parts came in different types, and the task imposed constraints on the allowable contents of each bin."*

**So: annealing.** State = an assignment of parts to bins. Transition = **swap parts of the same type between two random bins**, which keeps every bin a complete assembly. *"Our swap operator required three random integers — one to select the appropriate part type and two more to select the assembly bins involved."*

**And then the actual lesson, which is about the cost function:**

> *"We could just return the number of acceptable complete assemblies as our score… Although this was indeed what we wanted to optimize, **it would not be sensitive enough to detect when we were making partial progress towards a solution.** Suppose one of our swaps succeeded in bringing one of the non-functional assemblies much closer to the not-radio limit `k`. That would be a better starting point for further progress than the original, and should be favored."*
>
> *"My final cost function was as follows. I gave one point for every working assembly, and a significantly smaller credit for each non-working assembly based on how close to the threshold `k` it was. The score for a nonworking assembly decreased exponentially based on how much it was over `k`."*

**A cost function that is flat almost everywhere gives the search nothing to climb.** If your objective is "number of things that work", almost every transition scores zero and annealing degenerates into random sampling. **Add a smooth term for near-misses.** This is the single most transferable piece of advice in the chapter.

**Outcome:** 7 assemblies where the factory's best manual effort had managed 6.

### "Annealing Arrays" (12.8) — expect to spend more time tuning than writing

**The problem.** Fabricate `n` given DNA strings in an `m × m` array; each cell is (row prefix + column suffix). Minimise the array size. Proved `NP`-complete — *"but that didn't really matter. My student Ricky Bradley and I had to solve it anyway."*

**State:** subsets of prefixes and suffixes. **Transitions:** insert, delete, swap. **Cost:** the interesting part, arrived at by four rounds of debugging *the objective*, not the code:

1. `max(rows, cols) + uncovered` → *"the program doesn't seem to recognize when it is making progress"*, because only the larger dimension scored.
2. Give credit to the smaller dimension too → *"our arrays started to turn into skinny rectangles instead of squares."*
3. Add a term rewarding squareness → right shape, still slow.
4. **Skew the random selection toward useful prefixes/suffixes** → converges.

The final cost function, which is worth seeing in its unlovely glory:

```
cost = 2·max + min + (max − min)²/4 + 4·(str_total − str_in)
```

and the final move set: *swap, add, delete, useful add, useful delete, string add* — three uniform moves and three greedy ones.

**Result:** the 5 716 unique 7-mers of HIV went from a `192 × 192` array to `130 × 132` in about fifteen minutes.

> *"But how well did we do? Since simulated annealing is only a heuristic, we really don't know how close to optimal our solution is."*
>
> *"Simulated annealing is a good way to handle complex optimization problems. However, **to get the best results, expect to spend more time tweaking and refining your program than you did in writing it in the first place.** This is dirty work, but sometimes you have to do it."*

**Two things to carry away.** (1) **Biased move selection** — not every transition should be uniform; make the moves that matter more likely. (2) **You will not know how good your answer is**, so if a lower bound is available at any price, compute it — even the trivial one — so the search has a yardstick.

---

## Part 12 — Genetic Algorithms, and Skiena's Verdict (Skiena 12.9)

**What they are.** Maintain a *population* of candidate solutions. Select parents with probability proportional to *fitness*, produce children by *crossover* (combining parts of two parents) and *mutation* (random perturbation), and cull the unfit.

**What Skiena thinks of them.** He is not subtle, and the reasoning is worth more than the conclusion:

> *"The intuition behind these methods is highly appealing, but skeptics decry them as **voodoo optimization techniques** that rely more on superficial analogies to nature than producing superior computational results on real problems compared to other methods."*
>
> *"The question isn't whether you can get decent answers for many problems given enough effort using these techniques. Clearly you can. **The real question is whether they lead to better solutions with less implementation complexity or greater efficiency than the other methods we have discussed.** In general, I don't believe that they do."*

**Two concrete objections, and they are technical, not aesthetic:**

1. *"It is quite unnatural to model applications in terms of genetic operators like mutation and crossover on bit strings. **The pseudo-biology adds another level of complexity between you and your problem.**"*
2. *"Genetic algorithms take a very long time on non-trivial problems. **The crossover and mutation operations typically make no use of problem-specific structure**, so most transitions lead to inferior solutions, and convergence is slow. Indeed, the analogy with evolution — where significant progress requires millions of years — can be quite appropriate."*

> **Take-Home Lesson** (Skiena): *"I have never encountered any problem where genetic algorithms seemed to me the right way to attack it. Further, I have never seen any computational results reported using genetic algorithms that favorably impressed me. **Stick to simulated annealing for your heuristic search voodoo needs.**"*

**Objection 2 is the one to internalise**, because it applies to any heuristic you might adopt: **a transition operator that ignores the structure of your problem wastes most of its moves.** The TSP vertex swap works because it changes exactly eight edges and the delta is `O(1)`. Crossover on a bit-string encoding of a tour usually produces something that is not even a tour.

---

## Part 13 — Quantum Computing (Skiena 12.10)

Skiena includes this chapter-ending section for one reason: to answer *"does this make `NP`-complete problems easy?"* The answer is **no**, and the reasoning is worth the four pages.

**His toy model.** A conventional machine with `n` bits is in exactly one of `N = 2ⁿ` states — a very boring probability distribution with a single 1 in it. A "quantum" machine with `n` qubits holds *a genuine probability distribution over all `N` states*, with `Σp(i) = 1`, and supports four operations:

| Operation | What it does | Cost |
|---|---|---|
| `Initialize-state(Q, n, D)` | set the distribution per a **short description** `D`, e.g. "all states equally likely" | `O(\|D\|)`, **not** `O(N)` |
| `Quantum-gate(Q, c)` | apply a logic operation to the whole distribution at once | `O(1)` typically |
| `Jack(Q, c)` | **increase** the probability of every state satisfying `c` | `O(1)` typically |
| `Sample(Q)` | draw one state from the distribution and read its `n` qubits | `O(n)` |

> *"That this can be done in constant time should be recognized as surprising. Even if the condition raises the probability of just one state `i`, in order to keep the sum totaling to one the probabilities of all `2ⁿ − 1` other states must be lowered. That this can be done in constant time is one of the strange properties of 'quantum' physics."*

**The single hard constraint, and the reason everything below is subtle:** the *only* output is `Sample`. You can manipulate `2ⁿ` numbers in parallel; you can read exactly one `n`-bit string, at random, according to those numbers.

### Grover's algorithm — `Θ(√N)` search

```
Search(Q, S)
    Repeat
        Jack(Q, "all strings where S = qₙ … qₙ₊ₘ₋₁")
    Until probability of success is high enough
    Return the first n bits of Sample(Q)
```

→ **C++ implementation:** [A12 Grover search](#a12-grover-search)

> *"Each such `Jack` operation takes constant time… But it increases the probabilities at a slow-enough rate that `Θ(√N)` rounds are necessary and sufficient to make success likely."*

`Θ(√N)` instead of `Θ(N)`. **Provably optimal** for unstructured search — and provably *not* better than quadratic, which is the point.

### Why this does not settle `P` vs `NP`

Apply Grover to SAT. An `n`-qubit register holds every truth assignment; a circuit of `~3k` quantum gates sets an extra qubit `qₙ` to say whether the assignment satisfies the formula; Grover searches for `qₙ = 1`:

> *"Grover's search algorithm runs in `O(√N)` time, where `N = 2ⁿ`. Since `√(2ⁿ) = (√2)ⁿ`, this runs in `O(1.414ⁿ)` vs. the naive bound, which is a big improvement. For `n = 100`, this cuts the number of steps from `1.27 × 10³⁰` to `1.13 × 10¹⁵`. **But `(√2)ⁿ` still grows exponentially**, so this is not a polynomial-time algorithm."*

> **Take-Home Lesson** (Skiena): *"Despite their powers, **quantum computers cannot solve NP-complete problems in polynomial time.** Of course, the world changes if `P = NP`, but presumably `P ≠ NP`. We believe that the class of problems that can be solved in polynomial time on a quantum computer (called **BQP**) does not contain `NP` with roughly the same confidence that we believe `P ≠ NP`."*

**Note what a square-root speedup actually buys**, though: it halves the exponent, which for a `2ⁿ` backtracking search ([M17](M17-backtracking.md)) is the same as doubling the `n` you can handle. That is not nothing — it is just not polynomial.

### The quantum Fourier transform, and Shor

The FFT ([M23 *(planned)*](INDEX.md#module-map)) is `O(N lg N)` classically and its circuit has `lg M` stages of parallel multiplications; each stage costs `lg M` quantum gates, so the transform of all `N = 2ⁿ` amplitudes takes `O((lg N)²) = O(n²)`. **Exponentially faster — with a catch:**

> *"There is no way to get even one of these `2ⁿ` coefficients out of machine `Q`. All we can do is call `Sample(Q)` and get the index of a (presumably) large coefficient."*

**Shor's algorithm turns exactly that restricted output into a factoring algorithm.** The bridge is that *"the integers that have `k` as a factor occur `k` positions apart on a number line"* — divisibility is periodicity, and the Fourier transform reads periods.

```
Factor(M)
    Set up an n-qubit system Q, where N = 2ⁿ and M < N.
    Initialize Q so that p(i) = 1/2ⁿ for all 0 ≤ i ≤ N − 1.
    Repeat
        Jack(Q, "all i such that gcd(i, M) > 1")
    Until the probabilities of all terms relatively prime to M are very small.
    FFT(Q).
    For j = 1 to n
        Sⱼ = Sample(Q)
        If ((d = GCD(Sⱼ, S_k)) > 1) and (d divides M), for some k < j
            Return(d) as a factor of M
    Otherwise report no factor was found
```

**The samples themselves are usually not factors** — for `M = 77` you might draw `33, 42, 55` — but `gcd(33, 55) = 11`. **`gcd` recovers the factor from the multiples** ([M21 *(planned)*](INDEX.md#module-map)).

> *"No polynomial-time algorithm is known for integer factoring on conventional machines, **but neither is it `NP`-complete**. Thus, no complexity-theoretic assumptions are violated by having a fast algorithm for integer factorization."*

**That is the sentence to remember.** Factoring is the famous quantum win precisely *because* it is one of the rare natural problems believed to be neither in `P` nor `NP`-complete. Quantum computers attack a specific structural feature — periodicity — not intractability in general.

**Skiena's own hedge, worth quoting since he wrote it in 2020:**

> *"Quantum computing is a real thing, and is gonna happen — One develops a reasonably trustworthy bullsh*t detector after watching technology hype-cycles for forty years, and quantum computing now passes my sniff test by a safe margin."*

---

## Recognition Patterns

| Clue in the problem | What to reach for |
|---|---|
| You just proved it `NP`-hard and still need a program | the three routes: average-case exact ([M17](M17-backtracking.md)), approximation (Parts 3–9), heuristic search (Part 10) |
| "within a factor of 2 is fine" | look for a **computable lower bound** first; the algorithm follows from it |
| Cover every edge / every element, minimise count | maximal matching → 2 (vertex cover); greedy → `ln n` (set cover) |
| Cover with **weights** | LP relaxation + round at `1/2` |
| Tour / route, distances are geometric or otherwise metric | MST doubling → 2; Christofides → 3/2; then 2-opt |
| Tour, distances arbitrary | **no constant approximation exists** — go straight to heuristic search or an exact solver |
| Maximise satisfied clauses / cut edges / kept edges | **flip a coin**; then derandomize by conditional expectations or local search |
| Any "at most half of X is bad" claim | a random or arbitrary split gives factor 2 free |
| Numbers, and "close enough is fine" | **FPTAS by trimming** the value axis geometrically |
| Pseudo-polynomial DP that is too slow because values are huge | bucket the value axis by `1 + ε/2n` → FPTAS |
| Pack items into fewest containers | first-fit decreasing → `11/9` |
| Assign jobs to machines, minimise finish time | longest-processing-time-first list scheduling → `4/3` |
| Messy objective, several incommensurable criteria | **simulated annealing** — it does not care |
| Solution space is convex / one hill | hill climbing is *exact* — and so is binary search and simplex |
| Good solutions are plentiful, or the space has no gradient | random sampling is genuinely the right answer |
| An exact answer is needed and `n` is a few hundred | check for an exact solver (Concorde, a MIP solver, a SAT solver) before writing a heuristic |
| Someone proposes a genetic algorithm | ask what its transition operator knows about the problem |

---

## Common Mistakes

- **Comparing to the optimum instead of to a lower bound.** You cannot compute the optimum. Every proof in this module compares your answer to something *computable* that sits below `OPT`. If you cannot name the lower bound, you do not have a proof.
- **Believing the "smarter" heuristic is better.** Highest-degree-first for vertex cover is `Θ(lg n)`; taking both endpoints of an arbitrary edge is 2. Keeping one endpoint is `n − 1`. **Test plausible heuristics against a counterexample before shipping them.**
- **Applying metric-TSP results to non-metric instances.** MST doubling and Christofides both need the triangle inequality; without it, Theorem 35.3 says no constant ratio exists at all. Airfares, latency with detours through relays, and any cost with volume discounts violate it.
- **Quoting `7/8` and `8/7` interchangeably.** The *fraction satisfied* is `7/8`; the CLRS *ratio* is `8/7`. Say which.
- **Trimming with `ε` instead of `ε/2n`.** The error compounds once per element; `(1+ε)ⁿ` is not `1+ε`. This is the single most common bug in an FPTAS implementation.
- **Forgetting that FPTAS ≠ PTAS.** `O(n^(2/ε))` is a legitimate PTAS and a useless program.
- **Rounding an LP at the wrong threshold.** `1/2` is forced by the constraint `x(u) + x(v) ≥ 1`. Round higher and you break feasibility; lower and you break the ratio.
- **A cost function that is flat almost everywhere.** "Number of assemblies that work" gives annealing nothing to climb. Add a smooth term for near-misses (war story 12.7).
- **Uniform random pairs generated the obvious wrong way.** `i = rand(1,n-1); j = rand(i+1,n)` is biased by a factor of `n−1`. Use rejection sampling.
- **Recomputing the cost function from scratch inside the inner loop.** The `Θ(1)` incremental delta is the entire reason local search outruns sampling. Getting `swapDelta` wrong on the **adjacent-positions** case is a real and easy bug — it is a different formula.
- **Running a heuristic without a baseline.** Run the approximation algorithm too, take the better answer, and keep the guarantee. It costs milliseconds.
- **Assuming a quantum computer makes `NP` easy.** Grover halves the exponent. `2^(n/2)` is still exponential.
- **Trusting a local optimum.** Hill climbing on a non-convex space gives you a number with no meaning. At minimum, restart from many random starts and look at the spread.

---

## Complexity Summary

| Algorithm | Ratio | Time | Needs |
|---|---|---|---|
| `APPROX-VERTEX-COVER` | **2** | `O(V + E)` | — |
| randomized vertex cover | **2** expected | `O(V + E)` | — |
| DFS-tree non-leaves | **2** | `O(V + E)` | — |
| greedy highest-degree cover | `Θ(lg n)` — **worse** | `O(V·E)` naive | — |
| `APPROX-MIN-WEIGHT-VC` | **2** | LP + `O(V)` | LP solver |
| `APPROX-TSP-TOUR` (MST doubling) | **2** | `O(V²)` | **triangle inequality** |
| Christofides | **3/2** | `O(V³)` (Blossom) | **triangle inequality** |
| general TSP | **no constant ratio possible** | — | unless `P = NP` |
| `GREEDY-SET-COVER` | `H(max\|S\|) ≤ ln\|X\| + 1` — **tight** | `O(Σ\|S\|)` | — |
| random assignment, MAX-3-CNF | **8/7** (satisfies `7/8`) | `Θ(n)` | — |
| random assignment, MAX-*k*-SAT | `1/(1 − 2^-k)` | `Θ(n)` | — |
| conditional-expectation derandomization | same, deterministic | `Θ(n·Σ\|clause\|)` | — |
| random / local-search MAX-CUT | **2** | `O(V + E)` per sweep | — |
| maximum acyclic subgraph | **2** | `Θ(V + E)` | — |
| `APPROX-SUBSET-SUM` | `1 + ε` — **FPTAS** | `O(n² ln t / ε)` | — |
| first-fit bin packing | **2** (`11/9` decreasing) | `O(n lg n)` | — |
| list scheduling makespan | **2** (`4/3 − 1/3m` LPT) | `O(n lg m)` | — |
| greedy maximal matching | **2** | `O(V + E)` | — |
| fractional-relaxation knapsack | **2** | `O(n lg n)` | — |
| random sampling | none | anytime | plentiful good solutions |
| hill climbing | none (exact if convex) | anytime | `O(1)` incremental cost |
| simulated annealing | none | anytime | a cost function with a gradient |
| Grover search | exact | `Θ(√N)` | a quantum computer |

---

## One-Page Recall

**The one formula.** `answer ≤ k·L` and `L ≤ OPT`, therefore `answer ≤ k·OPT`. **Finding `L` is the whole job.**

**Ratio.** `max(C/C*, C*/C) ≤ ρ(n)`. **PTAS**: poly in `n` for each fixed `ε`. **FPTAS**: poly in `n` *and* `1/ε`.

**Vertex cover, factor 2.** Repeatedly take an uncovered edge and add **both** endpoints. The chosen edges form a **matching**, so `|matching| ≤ |C*|` and `|C| = 2|matching|`. Taking one endpoint gives `n−1` on a star; highest-degree gives `Θ(lg n)`.

**Metric TSP.** `w(MST) ≤ c(H*)` because deleting a tour edge leaves a spanning path. Preorder of the MST = doubled walk with shortcuts = **2**. Christofides: fix only the **odd-degree** vertices with a minimum-weight perfect matching, which costs `≤ c(H*)/2` because a tour on an even vertex set splits into two matchings → **3/2**. **General TSP: no constant ratio** — set non-edges to `ρ|V| + 1` and a `ρ`-approximation decides HAM-CYCLE.

**Set cover.** Greedy → `H(max|S|) ≤ ln|X| + 1`, via `|U_{i+1}| ≤ |Uᵢ|(1 − 1/k)`. **Tight** — Skiena's `Θ(lg n)` bipartite instance, and Feige's matching hardness.

**Weighted vertex cover.** 0-1 IP → LP relaxation (`0 ≤ x ≤ 1`) → `z* ≤ w(C*)` because the feasible region grew → **round at `1/2`**, forced by `x(u) + x(v) ≥ 1` → **2**.

**Average is good enough.** Coin flip satisfies `7/8` of 3-CNF clauses (`1 − 2^-k` for `k`-SAT), cuts `|E|/2` edges, keeps `|E|/2` edges acyclic. Derandomize by conditional expectations or by local search.

**Subset-sum FPTAS.** `Pᵢ = P_{i−1} ∪ (P_{i−1} + xᵢ)`; `TRIM(L, δ)` keeps `y` only if the last kept `z` fails `z(1+δ) ≥ y`; call it with **`δ = ε/2n`** because error compounds `n` times; `(1 + ε/2n)ⁿ ≤ e^(ε/2) ≤ 1 + ε`; list length `< 3n ln t/ε + 2`.

**Heuristic search.** Representation + cost function + transition. Sampling works when good solutions are plentiful or there is no gradient. Hill climbing is exact on convex spaces (binary search, simplex) and stuck otherwise. **Annealing** accepts a worsening move with probability `e^(ΔC/k_B T)`; `T ← αT`, `α ∈ [0.8, 0.99]`. **Make the cost function reward partial progress.** Genetic algorithms: Skiena says don't.

**Quantum.** Grover is `Θ(√N)` — halves the exponent, does not make `NP` polynomial. Shor factors in polynomial time because **factoring is not `NP`-complete**; periodicity is the structure it exploits.

**Self-test.**

1. Why does adding *both* endpoints beat adding one?
2. What is the lower bound in each of: vertex cover, metric TSP, set cover, makespan, bin packing?
3. Where exactly does the triangle inequality get used in Theorem 35.2?
4. Why is the matching in Christofides on the *odd-degree* vertices, and why does it cost `≤ OPT/2`?
5. Why `ρ|V| + 1` and not `2` in the proof of Theorem 35.3?
6. Why is `GREEDY-SET-COVER`'s `lg n` not just weak analysis?
7. Why is the LP optimum a *lower* bound, and why round at `1/2`?
8. Why `ε/2n` in `APPROX-SUBSET-SUM`?
9. Give a problem where random sampling beats hill climbing.
10. Why does a flat cost function break simulated annealing?
11. Why does Grover not prove `P = NP`?

---

## Practice — where to drill this module

Approximation algorithms are rare on LeetCode by design (judges want exact answers), so the drills below come in two flavours: **problems whose exact solution *is* one of these algorithms at small `n`**, and **problems where the intended solution is a heuristic search**.

| Idea in this module | Problem | Why it's the right drill |
|---|---|---|
| **Set cover** — greedy `ln n` vs exact | [1125 · Smallest Sufficient Team](https://leetcode.com/problems/smallest-sufficient-team/) | write greedy first, then the `2^skills` DP, and compare. Greedy is usually optimal here and provably need not be |
| **MST as a lower bound on the tour** | [1584 · Min Cost to Connect All Points](https://leetcode.com/problems/min-cost-to-connect-all-points/) | build the MST, then run `mstApproxTspTour` on the same points and watch the factor-2 relationship hold |
| **Metric TSP, exactly** | [943 · Find the Shortest Superstring](https://leetcode.com/problems/find-the-shortest-superstring/) · [847 · Shortest Path Visiting All Nodes](https://leetcode.com/problems/shortest-path-visiting-all-nodes/) | Held–Karp at `n ≤ 12`; use these as the exact oracle when testing your approximations |
| **Makespan / list scheduling** | [1723 · Find Minimum Time to Finish All Jobs](https://leetcode.com/problems/find-minimum-time-to-finish-all-jobs/) | the exact answer needs search; the greedy LPT schedule gives you the `4/3` bound and a superb pruning bound for it |
| **Bin packing, first-fit decreasing** | [1986 · Minimum Number of Work Sessions to Finish the Tasks](https://leetcode.com/problems/minimum-number-of-work-sessions-to-finish-the-tasks/) | `n ≤ 14` so bitmask DP is exact — then check how often FFD matches it |
| **Subset sum / partition, and the FPTAS** | [2035 · Partition Array Into Two Arrays to Minimize Sum Difference](https://leetcode.com/problems/partition-array-into-two-arrays-to-minimize-sum-difference/) · [416 · Partition Equal Subset Sum](https://leetcode.com/problems/partition-equal-subset-sum/) | 2035 is meet-in-the-middle ([M17](M17-backtracking.md)); then run `approxSubsetSum` on the same input and see the list collapse |
| **Local search / annealing as the intended solution** | [1515 · Best Position for a Service Centre](https://leetcode.com/problems/best-position-for-a-service-centre/) | the geometric median. Gradient descent and simulated annealing both pass; there is no closed form. **The one LeetCode problem that is genuinely this module** |
| **Randomized 2-approximation thinking** | [785 · Is Graph Bipartite?](https://leetcode.com/problems/is-graph-bipartite/) | a bipartite graph is one where MAX-CUT `= |E|`; run `localSearchMaxCut` and see it find the exact 2-colouring |
| **Greedy maximal matching** | [1049 · Last Stone Weight II](https://leetcode.com/problems/last-stone-weight-ii/) | secretly partition/subset-sum again — good practice at recognising the disguise |

**Beyond LeetCode.** [CSES *Advanced Techniques*](https://cses.fi/problemset/) has meet-in-the-middle and bitmask problems that pair with Part 8. For heuristic search proper, the real drill is [TSPLIB](http://comopt.ifi.uni-heidelberg.de/software/TSPLIB95/): download `berlin52` (optimum 7 542), implement `TspSearch` from this module, and see how close you get. Then add 2-opt and see how much better it gets than vertex swapping.

**The drill that matters here** is not a coding exercise either. It is this: **for every `NP`-hard problem you meet, write down the lower bound before you write any code.** If you can name it, you probably have an approximation algorithm. If you cannot, you are in Part 10 and should say so out loud rather than pretending the heuristic has a guarantee.

---

## C++ Toolkit for This Module

*The algorithms here are short. What the module actually needs is **randomness done correctly** and **floating-point comparisons done carefully** — the two places this code goes wrong in practice.*

### `<random>`, and why `rand()` is not acceptable here

```cpp
// The engine holds the state; the distribution shapes it. Keep ONE engine
// alive -- constructing a fresh mt19937 per call is both slow and, if seeded
// from a low-resolution clock, correlated.
void randomnessBasics() {
    mt19937 randomEngine(random_device{}());      // 32-bit Mersenne Twister
    mt19937_64 wideEngine(12345);                 // 64-bit; deterministic seed for tests

    uniform_int_distribution<int> pickIndex(0, 9);        // INCLUSIVE on both ends
    uniform_real_distribution<double> unitInterval(0.0, 1.0);  // [0,1) -- half open

    (void)pickIndex(randomEngine);
    (void)unitInterval(randomEngine);
    (void)wideEngine();
}
```

- **`rand() % n` is biased** unless `n` divides `RAND_MAX + 1`, and `RAND_MAX` is only guaranteed to be `32767`. On a heuristic search that runs `10⁹` iterations, that bias is not theoretical.
- **`uniform_int_distribution<int>(a, b)` includes `b`.** `uniform_real_distribution<double>(0,1)` excludes `1`. That asymmetry catches everyone once.
- **Seed deterministically in tests.** Every *Verified* line in this module comes from a fixed seed; a heuristic you cannot re-run is a heuristic you cannot debug.

```cpp
// shuffle(), not the removed random_shuffle(). Fisher-Yates, uniform over all
// n! orderings (M04). Note the engine is passed BY REFERENCE-ish (by value to a
// forwarding parameter) -- pass your long-lived engine, not a temporary.
void shuffleExample(vector<int>& order, mt19937& randomEngine) {
    shuffle(order.begin(), order.end(), randomEngine);
    shuffle(order.begin() + 1, order.end(), randomEngine);   // pin element 0: tours
}
```

`random_shuffle` was deprecated in C++14 and **removed in C++17** — it is not available in this module's dialect at all.

### Floating-point comparison, and why the code says `1e-9`

```cpp
// Every geometric or LP quantity in this module is a double, and doubles do not
// compare with ==. Three habits that prevent the bugs:
void floatingPointHabits(const vector<double>& costs) {
    const double epsilon = 1e-9;

    double improvement = -1e-13;
    if (improvement < -epsilon) { /* a real improvement */ }   // NOT `< 0`:
    // hill climbing on `delta < 0` can loop forever swapping two positions back
    // and forth on rounding noise. `delta < -epsilon` terminates.

    if (fabs(costs.empty() ? 0.0 : costs[0]) < epsilon) { /* effectively zero */ }

    // For the LP rounding, `>= 0.5` must tolerate a solver returning 0.49999999.
    const double lpValue = 0.5 - 1e-16;
    const bool inCover = lpValue >= 0.5 - epsilon;
    (void)inCover;
}
```

**The hill-climbing loop above is the concrete case.** `if (swapDelta(...) < 0)` will accept a swap whose true delta is zero but whose computed delta is `-3e-17`, then accept the reverse swap for the same reason, forever. `< -1e-12` fixes it.

### `exp`, and keeping the annealing exponent sane

```cpp
// exp(x) overflows to +inf around x = 710 and flushes to 0 below about -745.
// Neither breaks the acceptance test -- inf > r is true, 0 > r is false, both
// of which are the intended behaviour -- but the NORMALISATION matters:
double acceptanceProbability(double delta, double currentCost,
                             double boltzmann, double temperature) {
    // Dividing delta by currentCost makes the exponent dimensionless, so one
    // Boltzmann constant works whether tours are 10 units long or 10 million.
    return exp((-delta / currentCost) / (boltzmann * temperature));
}
```

Skiena's C code does exactly this, and the pseudocode does not — it is the kind of detail that decides whether your first annealing run does anything at all.

### `__builtin_popcountll` and `__builtin_ctz`

```cpp
// Set cover with a small universe, and the matching DP in Christofides, both
// live on bitmasks. These two intrinsics are why that representation is fast.
void bitIntrinsics(unsigned long long mask) {
    (void)__builtin_popcountll(mask);   // population count -- one instruction on x86-64
    if (mask) (void)__builtin_ctz(unsigned(mask));   // index of lowest set bit
    // UNDEFINED for mask == 0. Always guard. C++20 offers portable <bit>:
    // popcount(), countr_zero() -- not available in C++17.
}
```

**`__builtin_ctz` on zero is undefined behaviour, not zero.** The Christofides DP guards it by iterating `mask` from `1`.

### `priority_queue` with `greater<>` for a min-heap

```cpp
// greedyMakespan needs the LEAST loaded machine, and priority_queue is a MAX
// heap by default. The three-argument form is the fix, and `greater<>` (the
// transparent C++14 specialisation) saves respelling the value type.
void minHeapExample() {
    priority_queue<pair<long long, int>,
                   vector<pair<long long, int>>,
                   greater<>> byLoad;
    byLoad.emplace(0LL, 0);
    // Pairs compare lexicographically, so ties on load break by machine id --
    // which is what makes greedyMakespan deterministic and therefore testable.
    (void)byLoad.top();
}
```

See [M05](M05-sorting.md) for heaps proper and [M15](M15-shortest-paths.md) for the same idiom in Dijkstra.

### Structured bindings in loops over edges

```cpp
// `for (const auto& [u, v] : graph.edgeList())` appears throughout this module.
// One caveat worth knowing:
void structuredBindingCaveat(const vector<pair<int, int>>& edges) {
    for (const auto& [u, v] : edges) {
        // C++17: a structured binding cannot be captured by a lambda inside the
        // loop -- `[&]{ return u; }` is ill-formed in C++17 and legal in C++20.
        // Copy to a named local first if you need one in a closure.
        const int from = u, to = v;
        auto edgeCost = [&] { return from + to; };
        (void)edgeCost();
    }
}
```

[Weiss §1.5.3, p.25] covers references and value categories; the structured-binding rule above is C++17-specific and post-dates the book.

---

## Appendix — C++ for Every Pseudocode Block

```cpp
// Shared types for the appendix translation unit. These mirror the body's
// types, but the code below is deliberately LITERAL -- each function follows
// its pseudocode line for line, with the line numbers in the comments, so the
// correspondence is checkable rather than asserted.
struct AppendixGraph {
    int vertexCount = 0;
    vector<vector<int>> neighbours;

    explicit AppendixGraph(int n = 0) : vertexCount(n), neighbours(n) {}
    void addEdge(int u, int v) { neighbours[u].push_back(v); neighbours[v].push_back(u); }

    vector<pair<int, int>> edgeList() const {
        vector<pair<int, int>> edges;
        for (int u = 0; u < vertexCount; ++u)
            for (int v : neighbours[u]) if (u < v) edges.emplace_back(u, v);
        return edges;
    }
};

using AppendixDistance = vector<vector<double>>;
```

### A1 APPROX-VERTEX-COVER

*Pseudocode: Part 3, CLRS `APPROX-VERTEX-COVER`; Skiena `VertexCover(G)`; Skiena's randomized `VertexCover(G)`; and the DFS-tree cover from the Stop-and-Think.*

```cpp
// APPROX-VERTEX-COVER(G)
// 1  C = 0
// 2  E' = G.E
// 3  while E' != 0
// 4      let (u,v) be an arbitrary edge of E'
// 5      C = C union {u,v}
// 6      remove from E' every edge incident on either u or v
// 7  return C
//
// The literal translation keeps E' as an actual mutable list, exactly as the
// pseudocode describes, so line 6 is a visible deletion rather than the
// `inCover[]` trick the body version uses. Slower, and much closer to the page.
set<int> approxVertexCoverLiteral(const AppendixGraph& graph) {
    set<int> cover;                                    // line 1: C = 0
    list<pair<int, int>> remainingEdges;               // line 2: E' = G.E
    for (const auto& edge : graph.edgeList()) remainingEdges.push_back(edge);

    while (!remainingEdges.empty()) {                  // line 3
        const auto [u, v] = remainingEdges.front();    // line 4: "arbitrary"
        cover.insert(u);                               // line 5: BOTH endpoints
        cover.insert(v);
        remainingEdges.remove_if([&](const pair<int, int>& e) {   // line 6
            return e.first == u || e.second == u || e.first == v || e.second == v;
        });
    }
    return cover;                                      // line 7
}

// The matching the algorithm implicitly builds. Returning it makes Theorem 35.1
// runtime-checkable: |matching| <= OPT <= |cover| == 2*|matching|.
vector<pair<int, int>> chosenMatching(const AppendixGraph& graph) {
    vector<char> used(graph.vertexCount, 0);
    vector<pair<int, int>> matching;
    for (const auto& [u, v] : graph.edgeList())
        if (!used[u] && !used[v]) { used[u] = used[v] = 1; matching.emplace_back(u, v); }
    return matching;
}

// Skiena 12.2.1, literally:
//   While (E != 0) do:
//       Select an arbitrary edge (u,v) in E
//       Randomly pick either u or v, and add it to the vertex cover
//       Delete all edges from E that are incident to the SELECTED vertex.
//
// Note the last line: only the selected vertex's edges go. That asymmetry is
// what makes the expectation argument work -- the other endpoint stays live.
set<int> randomizedVertexCoverLiteral(const AppendixGraph& graph, mt19937& randomEngine) {
    set<int> cover;
    list<pair<int, int>> remainingEdges;
    for (const auto& edge : graph.edgeList()) remainingEdges.push_back(edge);

    while (!remainingEdges.empty()) {
        const auto [u, v] = remainingEdges.front();
        const int selected = (randomEngine() & 1u) ? u : v;
        cover.insert(selected);
        remainingEdges.remove_if([&](const pair<int, int>& e) {
            return e.first == selected || e.second == selected;
        });
    }
    return cover;
}

// The Stop-and-Think cover: DFS, then take every NON-LEAF of the DFS tree.
//
// Correct because DFS on an undirected graph produces only tree edges and back
// edges -- no cross edges -- so a leaf's every other edge goes to an ancestor,
// and all ancestors are non-leaves.
set<int> dfsTreeVertexCover(const AppendixGraph& graph) {
    const int n = graph.vertexCount;
    vector<char> visited(n, 0);
    vector<int> childCount(n, 0);

    // It must be a genuine DFS. Marking vertices visited as they are PUSHED
    // onto an explicit stack -- the natural-looking iterative version -- builds
    // a tree that is not the DFS tree, and the "no cross edges" property fails
    // with it. The recursion below is the honest translation; for a graph deep
    // enough to overflow the stack, use an explicit stack with a per-vertex
    // iterator (the Hierholzer shape used in christofidesTour).
    function<void(int)> visit = [&](int at) {
        visited[at] = 1;
        for (int next : graph.neighbours[at])
            if (!visited[next]) {
                ++childCount[at];                      // `at` has a child: not a leaf
                visit(next);
            }
    };
    for (int root = 0; root < n; ++root)
        if (!visited[root]) visit(root);

    set<int> cover;
    for (int v = 0; v < n; ++v)
        if (childCount[v] > 0) cover.insert(v);        // every non-leaf
    return cover;
}
```

### A2 APPROX-TSP-TOUR

*Pseudocode: Part 4, CLRS `APPROX-TSP-TOUR`, and the `CHRISTOFIDES` sketch.*

```cpp
// APPROX-TSP-TOUR(G, c)
// 1  select a vertex r in G.V to be a "root" vertex
// 2  compute a minimum spanning tree T for G from root r using MST-PRIM(G,c,r)
// 3  let H be a list of vertices, ordered according to when they are first
//        visited in a preorder walk of T
// 4  return the hamiltonian cycle H
//
// Line 3 is where the shortcutting lives, and it is invisible: a preorder walk
// lists each vertex at its FIRST appearance in the full (doubled) walk, which
// is exactly what "shortcut past the repeats" means.
vector<int> approxTspTourLiteral(const AppendixDistance& cost, int root) {
    const int n = int(cost.size());

    // line 2: MST-PRIM, O(n^2) form (M14).
    vector<double> key(n, numeric_limits<double>::infinity());
    vector<int> parent(n, -1);
    vector<char> inTree(n, 0);
    key[root] = 0.0;
    for (int step = 0; step < n; ++step) {
        int pick = -1;
        for (int v = 0; v < n; ++v)
            if (!inTree[v] && (pick < 0 || key[v] < key[pick])) pick = v;
        inTree[pick] = 1;
        for (int v = 0; v < n; ++v)
            if (!inTree[v] && cost[pick][v] < key[v]) { key[v] = cost[pick][v]; parent[v] = pick; }
    }

    vector<vector<int>> children(n);
    for (int v = 0; v < n; ++v) if (parent[v] >= 0) children[parent[v]].push_back(v);

    // line 3: preorder walk.
    vector<int> hamiltonianCycle;
    function<void(int)> preorder = [&](int at) {
        hamiltonianCycle.push_back(at);
        for (int child : children[at]) preorder(child);
    };
    preorder(root);
    return hamiltonianCycle;                            // line 4
}

// The full walk W, for comparison -- this is the object the proof reasons about
// (c(W) = 2w(T)), and the tour above is what you get after deleting repeats.
vector<int> fullWalkOfTree(const vector<vector<int>>& children, int root) {
    vector<int> walk;
    function<void(int)> visit = [&](int at) {
        walk.push_back(at);
        for (int child : children[at]) { visit(child); walk.push_back(at); }  // and back up
    };
    visit(root);
    return walk;
}

// CHRISTOFIDES(G, c)
// 1  T = minimum spanning tree of G
// 2  O = { v : deg_T(v) is odd }
// 3  M = minimum-weight perfect matching on the complete graph induced by O
// 4  U = T union M                        // every degree now even
// 5  W = an Eulerian circuit of U
// 6  return W with repeated vertices shortcut out
//
// Step 3 is Blossom in the real algorithm; here it is an exact bitmask DP over
// O, which is correct and short. Pairing the LOWEST unmatched vertex at every
// step is what removes the k! symmetry and leaves O(2^k * k).
double matchOddVerticesExactly(const vector<int>& odd, const AppendixDistance& cost,
                               vector<pair<int, int>>* matchingOut) {
    const int k = int(odd.size());
    if (k == 0) { if (matchingOut) matchingOut->clear(); return 0.0; }

    vector<double> best(size_t(1) << k, numeric_limits<double>::infinity());
    vector<int> partner(size_t(1) << k, -1);
    best[0] = 0.0;
    for (int mask = 1; mask < (1 << k); ++mask) {
        const int first = __builtin_ctz(unsigned(mask));
        for (int other = first + 1; other < k; ++other) {
            if (!(mask >> other & 1)) continue;
            const double candidate = best[mask ^ (1 << first) ^ (1 << other)]
                                   + cost[odd[first]][odd[other]];
            if (candidate < best[mask]) { best[mask] = candidate; partner[mask] = other; }
        }
    }
    if (matchingOut) {
        matchingOut->clear();
        for (int mask = (1 << k) - 1; mask; ) {
            const int first = __builtin_ctz(unsigned(mask)), other = partner[mask];
            matchingOut->emplace_back(odd[first], odd[other]);
            mask ^= (1 << first) | (1 << other);
        }
    }
    return best[(1 << k) - 1];
}
```

### A3 GREEDY-SET-COVER

*Pseudocode: Part 6, CLRS `GREEDY-SET-COVER(X, F)` and Skiena `SetCover(S)`.*

```cpp
// GREEDY-SET-COVER(X, F)
// 1  U = X
// 2  C = 0
// 3  while U != 0
// 4      select an S in F that maximizes |S intersect U|
// 5      U = U - S
// 6      C = C union {S}
// 7  return C
//
// Literal version: U and each S are real std::set objects, and line 4 really
// does compute |S intersect U|. Slower than the bitmask version in the body by
// a large constant, and it reads exactly like the page.
vector<int> greedySetCoverLiteral(const set<int>& universe, const vector<set<int>>& family) {
    set<int> uncovered = universe;                     // line 1
    vector<int> chosen;                                // line 2

    while (!uncovered.empty()) {                       // line 3
        int bestIndex = -1;
        size_t bestOverlap = 0;
        for (size_t i = 0; i < family.size(); ++i) {   // line 4
            vector<int> intersection;
            set_intersection(family[i].begin(), family[i].end(),
                             uncovered.begin(), uncovered.end(),
                             back_inserter(intersection));
            if (intersection.size() > bestOverlap) { bestOverlap = intersection.size(); bestIndex = int(i); }
        }
        if (bestIndex < 0) return {};                  // F does not cover X
        for (int element : family[bestIndex]) uncovered.erase(element);   // line 5
        chosen.push_back(bestIndex);                   // line 6
    }
    return chosen;                                     // line 7
}

// Skiena's milestone/width analysis, made observable: record how many sets were
// spent bringing the uncovered count below each power of two. max(w_i) is the
// "width" w, and the theorem says |greedy| <= w*lg n while OPT >= w.
vector<int> setCoverMilestoneWidths(const set<int>& universe, const vector<set<int>>& family) {
    set<int> uncovered = universe;
    const int n = int(universe.size());
    vector<int> widthPerMilestone(n > 0 ? 64 - __builtin_clzll((unsigned long long)n) + 1 : 1, 0);

    while (!uncovered.empty()) {
        int bestIndex = -1;
        size_t bestOverlap = 0;
        for (size_t i = 0; i < family.size(); ++i) {
            size_t overlap = 0;
            for (int element : family[i]) if (uncovered.count(element)) ++overlap;
            if (overlap > bestOverlap) { bestOverlap = overlap; bestIndex = int(i); }
        }
        if (bestIndex < 0) break;
        // Which milestone class is this pick in? floor(lg |U|) before the pick.
        const int milestone = 63 - __builtin_clzll((unsigned long long)uncovered.size());
        if (milestone >= 0 && milestone < int(widthPerMilestone.size())) ++widthPerMilestone[milestone];
        for (int element : family[bestIndex]) uncovered.erase(element);
    }
    return widthPerMilestone;
}
```

### A4 Random assignment and derandomization

*Pseudocode: Part 5, Theorem 35.5 ("set each variable to 1 with probability 1/2"), and the conditional-expectation derandomization.*

```cpp
struct AppendixCnf {
    int variableCount = 0;
    vector<vector<int>> clauses;
};

// Theorem 35.5, in full. There is no pseudocode block in CLRS because the
// algorithm IS the sentence: "independently set each variable to 1 with
// probability 1/2 and to 0 with probability 1/2".
vector<char> randomAssignmentLiteral(const AppendixCnf& formula, mt19937& randomEngine) {
    bernoulli_distribution fairCoin(0.5);              // literally a coin
    vector<char> value(formula.variableCount);
    for (char& bit : value) bit = char(fairCoin(randomEngine));
    return value;
}

int countSatisfied(const AppendixCnf& formula, const vector<char>& value) {
    int total = 0;
    for (const auto& clause : formula.clauses)
        for (int literal : clause)
            if ((value[abs(literal) - 1] != 0) == (literal > 0)) { ++total; break; }
    return total;
}

// The exact expectation the theorem computes, for one clause:
//   Pr{clause unsatisfied} = 2^-(number of distinct literals)
// so E[Y] = sum over clauses of (1 - 2^-|clause|), which is 7m/8 for 3-CNF.
double expectedSatisfiedUnderRandomAssignment(const AppendixCnf& formula) {
    double total = 0.0;
    for (const auto& clause : formula.clauses) total += 1.0 - ldexp(1.0, -int(clause.size()));
    return total;
}

// Method of conditional expectations. At each variable, take the branch whose
// conditional expectation is larger; since the two branches average to the
// current expectation, the running value NEVER decreases from 7m/8.
vector<char> derandomizeByConditionalExpectation(const AppendixCnf& formula) {
    const int n = formula.variableCount;
    vector<char> value(n, 2);                          // 2 == unassigned

    auto conditionalExpectation = [&]() {
        double total = 0.0;
        for (const auto& clause : formula.clauses) {
            int unassigned = 0;
            bool satisfied = false;
            for (int literal : clause) {
                const char assigned = value[abs(literal) - 1];
                if (assigned == 2) ++unassigned;
                else if ((assigned != 0) == (literal > 0)) { satisfied = true; break; }
            }
            total += satisfied ? 1.0 : 1.0 - ldexp(1.0, -unassigned);
        }
        return total;
    };

    for (int v = 0; v < n; ++v) {
        value[v] = 1;  const double ifTrue  = conditionalExpectation();
        value[v] = 0;  const double ifFalse = conditionalExpectation();
        value[v] = char(ifTrue >= ifFalse);
    }
    return value;
}

// Skiena 12.4.2, maximum acyclic subgraph. "Construct any permutation of the
// vertices... one of these two edge subsets must be at least as large as the
// other." Two lines of algorithm, factor 2.
vector<pair<int, int>> maximumAcyclicSubgraphLiteral(int vertexCount,
                                                     const vector<pair<int, int>>& edges,
                                                     mt19937& randomEngine) {
    vector<int> permutation(vertexCount);
    iota(permutation.begin(), permutation.end(), 0);
    shuffle(permutation.begin(), permutation.end(), randomEngine);

    vector<int> rankOf(vertexCount);
    for (int i = 0; i < vertexCount; ++i) rankOf[permutation[i]] = i;

    vector<pair<int, int>> leftToRight, rightToLeft;
    for (const auto& [from, to] : edges)
        (rankOf[from] < rankOf[to] ? leftToRight : rightToLeft).emplace_back(from, to);
    return leftToRight.size() >= rightToLeft.size() ? leftToRight : rightToLeft;
}
```

### A5 APPROX-MIN-WEIGHT-VC

*Pseudocode: Part 7, CLRS `APPROX-MIN-WEIGHT-VC(G, w)`.*

```cpp
// APPROX-MIN-WEIGHT-VC(G, w)
// 1  C = 0
// 2  compute x-bar, an optimal solution to the linear program (35.15)-(35.18)
// 3  for each vertex v in V
// 4      if x-bar(v) >= 1/2
// 5          C = C union {v}
// 6  return C
//
// Line 2 is a call to an LP solver in any real implementation. Here it uses the
// half-integrality of THIS particular LP -- an optimum with every x(v) in
// {0, 1/2, 1} always exists -- so the optimum can be found by grid search.
// Exponential, and present so that lines 3-5 can be tested against a provably
// optimal x-bar rather than an approximate one.
vector<double> solveVertexCoverLpLiteral(const AppendixGraph& graph,
                                         const vector<double>& weight) {
    const int n = graph.vertexCount;
    const auto edges = graph.edgeList();

    long long stateCount = 1;
    for (int i = 0; i < n; ++i) stateCount *= 3;

    double bestValue = numeric_limits<double>::infinity();
    vector<double> assignment(n), bestAssignment(n, 1.0);
    for (long long state = 0; state < stateCount; ++state) {
        long long rest = state;
        for (int v = 0; v < n; ++v) { assignment[v] = 0.5 * double(rest % 3); rest /= 3; }

        double value = 0.0;
        for (int v = 0; v < n; ++v) value += weight[v] * assignment[v];
        if (value >= bestValue) continue;

        bool feasible = true;                          // constraint (35.16)
        for (const auto& [u, v] : edges)
            if (assignment[u] + assignment[v] < 1.0 - 1e-9) { feasible = false; break; }
        if (feasible) { bestValue = value; bestAssignment = assignment; }
    }
    return bestAssignment;
}

set<int> approxMinWeightVcLiteral(const AppendixGraph& graph, const vector<double>& weight) {
    set<int> cover;                                    // line 1
    const vector<double> lpSolution = solveVertexCoverLpLiteral(graph, weight);   // line 2
    for (int v = 0; v < graph.vertexCount; ++v)        // line 3
        if (lpSolution[v] >= 0.5 - 1e-9)               // line 4 -- the threshold is FORCED
            cover.insert(v);                           // line 5
    return cover;                                      // line 6
}
```

### A6 EXACT-SUBSET-SUM

*Pseudocode: Part 8, CLRS `EXACT-SUBSET-SUM(S, n, t)` and `MERGE-LISTS(L, L')`.*

```cpp
// MERGE-LISTS(L, L') returns the sorted merge of two sorted lists with
// duplicates removed, in O(|L| + |L'|). CLRS omits the pseudocode; it is the
// MERGE of mergesort (M05) with one extra equality test.
vector<long long> mergeListsLiteral(const vector<long long>& left,
                                    const vector<long long>& right) {
    vector<long long> merged;
    merged.reserve(left.size() + right.size());
    size_t i = 0, j = 0;
    while (i < left.size() && j < right.size()) {
        long long next;
        if (left[i] < right[j]) next = left[i++];
        else if (right[j] < left[i]) next = right[j++];
        else { next = left[i]; ++i; ++j; }             // equal: take one, drop the other
        if (merged.empty() || merged.back() != next) merged.push_back(next);
    }
    while (i < left.size())  { if (merged.empty() || merged.back() != left[i])  merged.push_back(left[i]);  ++i; }
    while (j < right.size()) { if (merged.empty() || merged.back() != right[j]) merged.push_back(right[j]); ++j; }
    return merged;
}

// L + x, the notation CLRS defines: "the list of integers derived from L by
// increasing each element of L by x". Stays sorted, so no re-sort is needed.
vector<long long> listPlus(const vector<long long>& list, long long x) {
    vector<long long> shifted;
    shifted.reserve(list.size());
    for (long long value : list) shifted.push_back(value + x);
    return shifted;
}

// EXACT-SUBSET-SUM(S, n, t)
// 1  L_0 = <0>
// 2  for i = 1 to n
// 3      L_i = MERGE-LISTS(L_{i-1}, L_{i-1} + x_i)
// 4      remove from L_i every element that is greater than t
// 5  return the largest element in L_n
long long exactSubsetSumLiteral(const vector<long long>& values, long long target) {
    vector<long long> list{0};                                     // line 1
    for (size_t i = 0; i < values.size(); ++i) {                   // line 2
        list = mergeListsLiteral(list, listPlus(list, values[i]));  // line 3
        while (!list.empty() && list.back() > target) list.pop_back();   // line 4
    }
    return list.back();                                            // line 5
}

// The set P_i from equation (35.21): P_i = P_{i-1} union (P_{i-1} + x_i).
// Included because seeing P_3 = {0,1,4,5,6,9,10} for S = {1,4,5} is what makes
// the whole section click.
set<long long> allSubsetSums(const vector<long long>& values) {
    set<long long> sums{0};
    for (long long x : values) {
        set<long long> grown = sums;
        for (long long s : sums) grown.insert(s + x);
        sums = move(grown);
    }
    return sums;
}
```

### A7 TRIM and APPROX-SUBSET-SUM

*Pseudocode: Part 8, CLRS `TRIM(L, δ)` and `APPROX-SUBSET-SUM(S, n, t, ε)`.*

```cpp
// TRIM(L, delta)
// 1  let m be the length of L
// 2  L' = <y_1>
// 3  last = y_1
// 4  for i = 2 to m
// 5      if y_i > last * (1 + delta)      // y_i >= last because L is sorted
// 6          append y_i onto the end of L'
// 7          last = y_i
// 8  return L'
//
// The comparison is against `last` -- the last KEPT element -- not against the
// previous element of L. That is what lets a single survivor represent a whole
// run, and it is the difference between Theta(m) and no compression at all.
vector<long long> trimLiteral(const vector<long long>& list, double delta) {
    const size_t m = list.size();                      // line 1
    if (m == 0) return {};
    vector<long long> trimmed{list[0]};                // line 2
    double last = double(list[0]);                     // line 3
    for (size_t i = 1; i < m; ++i)                     // line 4
        if (double(list[i]) > last * (1.0 + delta)) {  // line 5
            trimmed.push_back(list[i]);                // line 6
            last = double(list[i]);                    // line 7
        }
    return trimmed;                                    // line 8
}

// APPROX-SUBSET-SUM(S, n, t, epsilon)
// 1  L_0 = <0>
// 2  for i = 1 to n
// 3      L_i = MERGE-LISTS(L_{i-1}, L_{i-1} + x_i)
// 4      L_i = TRIM(L_i, epsilon/2n)
// 5      remove from L_i every element that is greater than t
// 6  let z be the largest value in L_n
// 7  return z
//
// Line 4 is the entire scheme, and epsilon/(2n) is the entire subtlety: the
// per-round error (1 + eps/2n) compounds n times into (1 + eps/2n)^n, which the
// proof bounds by e^(eps/2) <= 1 + eps.
long long approxSubsetSumLiteral(const vector<long long>& values, long long target,
                                 double epsilon) {
    const int n = int(values.size());
    if (n == 0) return 0;

    vector<long long> list{0};                                          // line 1
    for (int i = 0; i < n; ++i) {                                       // line 2
        list = mergeListsLiteral(list, listPlus(list, values[i]));      // line 3
        list = trimLiteral(list, epsilon / (2.0 * n));                  // line 4
        while (!list.empty() && list.back() > target) list.pop_back();  // line 5
    }
    return list.empty() ? 0 : list.back();                              // lines 6-7
}

// The bound from the proof: |L_i| <= log_{1+eps/2n}(t) + 2 < 3n ln t / eps + 2.
// Comparing this against the observed list length is the cheapest way to
// convince yourself the scheme really is fully polynomial.
double predictedListLengthBound(int n, long long target, double epsilon) {
    return target <= 1 ? 2.0 : 3.0 * double(n) * log(double(target)) / epsilon + 2.0;
}
```

### A8 First-fit bin packing and greedy makespan

*Pseudocode: Part 9, CLRS Problem 35-1 (the first-fit heuristic) and Problem 35-5(c) ("whenever a machine is idle, schedule any job that has not yet been scheduled").*

```cpp
// The first-fit heuristic, stated in Problem 35-1:
//   "It maintains an ordered list of bins B_1..B_b. The algorithm takes each
//    object i in turn and places it in the lowest-numbered bin that can still
//    accommodate it. If no bin can accommodate object i, then b is incremented
//    and a new bin B_b is opened, containing object i."
//
// Part (c) of the problem -- "at most one bin is at most half full" -- is what
// the scan order guarantees, and it is where the factor 2 comes from.
vector<vector<int>> firstFitLiteral(const vector<double>& size) {
    vector<double> used;                               // used[k] = fill level of B_k
    vector<vector<int>> bins;

    for (size_t item = 0; item < size.size(); ++item) {
        size_t bin = 0;
        while (bin < bins.size() && used[bin] + size[item] > 1.0 + 1e-12) ++bin;  // lowest-numbered
        if (bin == bins.size()) { bins.emplace_back(); used.push_back(0.0); }     // open B_b
        bins[bin].push_back(int(item));
        used[bin] += size[item];
    }
    return bins;
}

// Problem 35-1(b): the lower bound is ceil(S), S = sum of sizes.
double binPackingLowerBound(const vector<double>& size) {
    return ceil(accumulate(size.begin(), size.end(), 0.0) - 1e-12);
}

// Problem 35-5(c): "whenever a machine is idle, schedule any job that has not
// yet been scheduled." A min-heap on machine load makes "idle" literal.
long long greedyMakespanLiteral(const vector<long long>& processingTime, int machineCount) {
    vector<long long> load(machineCount, 0);
    for (long long p : processingTime) {
        const int idlest = int(min_element(load.begin(), load.end()) - load.begin());
        load[idlest] += p;                             // the machine that goes idle first
    }
    return *max_element(load.begin(), load.end());
}

// Problem 35-5(a) and (b): the two lower bounds. C*_max >= max p_k, and
// C*_max >= (1/m) sum p_k. The proof needs BOTH, because the greedy bound is
// (1/m)sum + max, which is at most twice the larger of them.
double makespanLowerBound(const vector<long long>& processingTime, int machineCount) {
    const long long longest = *max_element(processingTime.begin(), processingTime.end());
    const long long total = accumulate(processingTime.begin(), processingTime.end(), 0LL);
    return max(double(longest), double(total) / double(machineCount));
}
```

### A9 Random sampling

*Pseudocode: Part 10, Skiena's `random_sampling(tsp_instance *t, int nsamples, tsp_solution *s)`.*

```cpp
// void random_sampling(tsp_instance *t, int nsamples, tsp_solution *s) {
//     initialize_solution(t->n, &s_now);
//     best_cost = solution_cost(&s_now, t);
//     copy_solution(&s_now, s);
//     for (i = 1; i <= nsamples; i++) {
//         random_solution(&s_now);
//         cost_now = solution_cost(&s_now, t);
//         if (cost_now < best_cost) { best_cost = cost_now; copy_solution(&s_now, s); }
//     }
// }
//
// The C original threads a tsp_solution* through by mutation; C++ returns by
// value and lets move semantics make that free. Everything else is line-for-line.
struct AppendixTsp {
    AppendixDistance distance;
    int n = 0;
    mt19937 randomEngine{12345};

    double solutionCost(const vector<int>& tour) const {
        double total = 0.0;
        for (int i = 0; i < n; ++i) total += distance[tour[i]][tour[(i + 1) % n]];
        return total;
    }

    vector<int> randomSolution() {
        vector<int> tour(n);
        iota(tour.begin(), tour.end(), 0);
        shuffle(tour.begin() + 1, tour.end(), randomEngine);   // v_1 is pinned
        return tour;
    }

    vector<int> randomSampling(int sampleCount) {
        vector<int> current = randomSolution();                // initialize_solution
        double bestCost = solutionCost(current);               // best_cost = ...
        vector<int> best = current;                            // copy_solution

        for (int i = 1; i <= sampleCount; ++i) {
            current = randomSolution();                        // random_solution
            const double costNow = solutionCost(current);      // Theta(n) EVERY time --
            if (costNow < bestCost) {                          // this is the weakness
                bestCost = costNow;
                best = current;
            }
        }
        return best;
    }

    // Skiena's "Picking the Pair" -- the correct uniform generator for an
    // unordered pair. The obvious i=rand(1,n-1), j=rand(i+1,n) is biased by up
    // to a factor of n-1 toward pairs with large first elements.
    pair<int, int> randomPositionPair() {
        uniform_int_distribution<int> pick(1, n - 1);
        int i, j;
        do {
            i = pick(randomEngine);
            j = pick(randomEngine);
            if (i > j) swap(i, j);
        } while (i == j);
        return {i, j};
    }

    // The incremental cost of swapping tour positions i and j: O(1) rather than
    // the Theta(n) of solutionCost. This single function is why local search and
    // annealing outrun sampling per unit of time.
    double transition(const vector<int>& tour, int i, int j) const {
        if (i == j) return 0.0;
        if (i > j) swap(i, j);
        const int beforeI = tour[(i - 1 + n) % n], afterI = tour[(i + 1) % n];
        const int beforeJ = tour[(j - 1 + n) % n], afterJ = tour[(j + 1) % n];
        const int cityI = tour[i], cityJ = tour[j];

        if ((i + 1) % n == j)                                  // adjacent: only 4 edges move
            return distance[beforeI][cityJ] + distance[cityI][afterJ]
                 - distance[beforeI][cityI] - distance[cityJ][afterJ];
        if (i == 0 && j == n - 1)                              // wrap-around adjacency
            return distance[beforeJ][cityI] + distance[cityJ][afterI]
                 - distance[beforeJ][cityJ] - distance[cityI][afterI];
        return distance[beforeI][cityJ] + distance[cityJ][afterI]
             + distance[beforeJ][cityI] + distance[cityI][afterJ]
             - distance[beforeI][cityI] - distance[cityI][afterI]
             - distance[beforeJ][cityJ] - distance[cityJ][afterJ];
    }
};
```

### A10 Hill climbing

*Pseudocode: Part 10, Skiena's `hill_climbing(tsp_instance *t, tsp_solution *s)`.*

```cpp
// void hill_climbing(tsp_instance *t, tsp_solution *s) {
//     initialize_solution(t->n, s); random_solution(s);
//     cost = solution_cost(s, t);
//     do {
//         stuck = true;
//         for (i = 1; i < t->n; i++)
//             for (j = i + 1; j <= t->n; j++) {
//                 delta = transition(s, t, i, j);
//                 if (delta < 0) { stuck = false; cost = cost + delta; }
//                 else transition(s, t, j, i);          // undo
//             }
//     } while (stuck);
// }
//
// TWO things to notice in the original. First, `transition` in the C code both
// COMPUTES the delta and APPLIES the swap, which is why the else branch calls
// it again to undo. This translation separates the two, which is clearer and
// makes the delta independently testable.
//
// Second, `while (stuck)` in the book's listing is the loop condition, and it
// reads backwards -- the loop should continue while NOT stuck. It is a typo in
// the printed code; the intent (and the behaviour described in the text) is a
// sweep that repeats until no improving swap exists. Translated as intended.
struct AppendixHillClimb : AppendixTsp {
    vector<int> hillClimbing() {
        vector<int> tour = randomSolution();
        double cost = solutionCost(tour);

        bool stuck = false;
        while (!stuck) {
            stuck = true;
            for (int i = 1; i < n; ++i)
                for (int j = i + 1; j < n; ++j) {
                    const double delta = transition(tour, i, j);
                    if (delta < -1e-12) {              // NOT `< 0`: rounding noise
                        swap(tour[i], tour[j]);        // would cycle forever
                        cost += delta;
                        stuck = false;
                    }
                }
        }
        (void)cost;                                    // kept to mirror the original
        return tour;
    }
};
```

### A11 Simulated annealing

*Pseudocode: Part 10, Skiena's `Simulated-Annealing()` and the `anneal()` implementation.*

```cpp
// Simulated-Annealing()
//     Create initial solution s
//     Initialize temperature T
//     repeat
//         for i = 1 to iteration-length do
//             Randomly select a neighbor of s to be s_i
//             If (C(s) >= C(s_i)) then s = s_i
//             else if (e^((C(s)-C(s_i))/(k_B*T)) > random[0,1)) then s = s_i
//         Reduce temperature T
//     until (no change in C(s))
//     Return s
//
// And the differences in Skiena's actual C code, both of which matter:
//   exponent = (-delta / current_value) / (K * temperature);   // NORMALISED
//   if (current_value < start_value) temperature /= COOLING_FRACTION;  // re-run
struct AppendixAnneal : AppendixTsp {
    // The five cooling-schedule parameters, named as in the text.
    double initialTemperature = 1.0;
    double coolingFraction    = 0.97;      // alpha, in [0.8, 0.99]
    int    coolingSteps       = 500;
    int    stepsPerTemperature = 1000;
    double boltzmann          = 0.01;      // k_B, scaled so nearly everything
                                           // is accepted at the start

    vector<int> anneal() {
        vector<int> tour = randomSolution();
        double currentValue = solutionCost(tour);
        uniform_real_distribution<double> randomFloat(0.0, 1.0);

        double temperature = initialTemperature;
        for (int i = 1; i <= coolingSteps; ++i) {
            temperature *= coolingFraction;
            const double startValue = currentValue;

            for (int j = 1; j <= stepsPerTemperature; ++j) {
                const auto [x, y] = randomPositionPair();
                const double delta = transition(tour, x, y);

                const bool acceptWin = delta < 0.0;              // did the swap help?
                // Dividing by currentValue makes the exponent dimensionless, so
                // one k_B works whether tours measure in tens or in millions.
                const double exponent = (-delta / currentValue) / (boltzmann * temperature);
                const bool acceptLoss = !acceptWin && exp(exponent) > randomFloat(randomEngine);

                if (acceptWin || acceptLoss) {
                    swap(tour[x], tour[y]);
                    currentValue += delta;
                }
                // else: no swap was applied, so there is nothing to reverse --
                // the C original applies then undoes, which is equivalent.
            }
            // "It generally pays to stay at a given temperature for multiple
            // rounds so long as we are making progress there."
            if (currentValue < startValue) temperature /= coolingFraction;
        }
        return tour;
    }

    // Skiena 12.6.4: the independent-set objective that deliberately allows
    // INFEASIBLE states while hot.  C(S) = |S| - lambda * m_S / T
    // The penalty grows as T falls, so edges get driven out as the system cools.
    static double independentSetObjective(int subsetSize, int inducedEdgeCount,
                                          double lambda, double temperature) {
        return double(subsetSize) - lambda * double(inducedEdgeCount) / temperature;
    }
};
```

### A12 Grover search

*Pseudocode: Part 13, Skiena's `Search(Q, S)` and `Factor(M)`, in his four-operation "quantum" model.*

```cpp
// Skiena's model, simulated classically: an explicit probability distribution
// over all N = 2^n states, with his four operations.
//
// This is a SIMULATION, so it costs Theta(N) per operation where the real
// machine costs O(1) -- there is no free lunch here. Its purpose is to make the
// Theta(sqrt(N)) round count of Grover's algorithm observable rather than
// asserted, which it does faithfully.
struct ToyQuantumMachine {
    int qubitCount = 0;
    vector<double> probability;                        // size 2^n, sums to 1
    mt19937 randomEngine{20200};

    // Initialize-state(Q, n, D) with D = "all states equally likely".
    void initializeUniform(int n) {
        qubitCount = n;
        probability.assign(size_t(1) << n, ldexp(1.0, -n));
    }

    // Jack(Q, c): raise the probability of every state satisfying c, and
    // renormalise so the distribution still sums to 1.
    //
    // The boost is applied to the AMPLITUDE (sqrt of the probability), not to
    // the probability itself. That detail is the whole reason the round count
    // comes out as sqrt(N): amplitude grows linearly, so probability -- its
    // square -- reaches 1/2 after Theta(sqrt(N)) rounds. Boosting the
    // probability directly gives logistic growth and Theta(sqrt(N) lg N)
    // instead, which is the wrong answer with the right shape.
    void jack(const function<bool(int)>& condition, double amplitudeBoost) {
        double total = 0.0;
        for (size_t state = 0; state < probability.size(); ++state) {
            if (condition(int(state))) {
                const double amplitude = sqrt(probability[state]) + amplitudeBoost;
                probability[state] = amplitude * amplitude;
            }
            total += probability[state];
        }
        for (double& p : probability) p /= total;      // the O(1) magic, done the slow way
    }

    // Sample(Q): draw one state according to the current distribution.
    int sample() {
        uniform_real_distribution<double> unitInterval(0.0, 1.0);
        double target = unitInterval(randomEngine), running = 0.0;
        for (size_t state = 0; state < probability.size(); ++state) {
            running += probability[state];
            if (running >= target) return int(state);
        }
        return int(probability.size()) - 1;
    }

    double probabilityOf(const function<bool(int)>& condition) const {
        double total = 0.0;
        for (size_t state = 0; state < probability.size(); ++state)
            if (condition(int(state))) total += probability[state];
        return total;
    }
};

// Search(Q, S)
//     Repeat
//         Jack(Q, "all strings where S = q_n ... q_{n+m-1}")
//     Until probability of success is high enough
//     Return the first n bits of Sample(Q)
//
// Returns the number of Jack rounds needed, which is the quantity the analysis
// is about: Theta(sqrt(N)), not Theta(N).
int groverSearch(ToyQuantumMachine& machine, const function<bool(int)>& matches,
                 double successThreshold, int roundLimit) {
    // The rotation size that reproduces Grover's sqrt(N) scaling: each round
    // adds about 2/sqrt(N) to the marked amplitude, which starts at 1/sqrt(N).
    // After t rounds the amplitude is roughly (2t+1)/sqrt(N), so the marked
    // probability is roughly (2t+1)^2/N and reaches 1/2 at t = Theta(sqrt(N)).
    const double n = double(machine.probability.size());
    const double boost = 2.0 / sqrt(n);

    int rounds = 0;
    while (machine.probabilityOf(matches) < successThreshold && rounds < roundLimit) {
        machine.jack(matches, boost);
        ++rounds;
    }
    return rounds;
}

// Factor(M): the classical half of Shor's algorithm, which is the half that
// actually does the work of turning samples into a factor.
//
// The quantum half sets up a distribution concentrated on multiples of factors
// of M; it CANNOT be simulated here in less than exponential time, so this
// takes the samples as input. The point of the pseudocode is the last step:
// samples are usually not factors (33, 42, 55 for M = 77), but gcd(33,55) = 11.
long long greatestCommonDivisor(long long a, long long b) {
    while (b) { const long long t = a % b; a = b; b = t; }
    return a;
}

long long factorFromSamples(long long m, const vector<long long>& samples) {
    for (size_t j = 0; j < samples.size(); ++j)
        for (size_t k = 0; k < j; ++k) {
            const long long d = greatestCommonDivisor(samples[j], samples[k]);
            if (d > 1 && m % d == 0) return d;         // "Return(d) as a factor of M"
        }
    return 0;                                          // "report no factor was found"
}
```

**Complexity. Every appendix routine matches its body counterpart except where the literal form is deliberately slower: `approxVertexCoverLiteral` is `O(V·E)` because line 6 really deletes from a list; `greedySetCoverLiteral` is `O(|C|·|F|·|S| lg |S|)` because line 4 really computes a set intersection; `solveVertexCoverLpLiteral` is `Θ(3ⁿ(n+E))`; `ToyQuantumMachine` is `Θ(2ⁿ)` per operation, being a classical simulation of a machine whose whole point is that it is not one.**

*Verified:* every appendix routine was cross-checked against its body counterpart and against brute force. `approxVertexCoverLiteral` returned a valid cover on all 1 730 random graphs, `|cover| = 2·|chosenMatching|` held identically, and `|matching| ≤ OPT ≤ |cover| ≤ 2·OPT` held on every one — Theorem 35.1 as a runtime assertion. `randomizedVertexCoverLiteral` was always a valid cover.

**`dfsTreeVertexCover` was wrong the first time, and the failure is worth recording.** I wrote the traversal as an explicit stack that marks each vertex visited *when it is pushed* — the shape everyone writes to avoid recursion. That is not a depth-first search: it produces a tree with **cross edges**, and the whole correctness argument rests on DFS having none. The test caught it on the first instance with a triangle. The fix is the recursive version now in the code, and the lesson is that *"iterative DFS"* written the easy way is a BFS-shaped traversal wearing a stack.

`approxTspTourLiteral` stayed within `2·OPT` on 500 Euclidean instances, `c(fullWalkOfTree) = 2·w(MST)` held to `10⁻⁷` on all of them, and `w(MST) ≤ OPT` always. `greedySetCoverLiteral` covered `X` on all 1 388 valid instances, and `setCoverMilestoneWidths` satisfied Skiena's two claims simultaneously — `max(wᵢ) ≤ OPT` **and** `|greedy| ≤ max(wᵢ)·lg n` — on every one. `derandomizeByConditionalExpectation` met `expectedSatisfiedUnderRandomAssignment` on **3 000 of 3 000** formulas: the theorem, as an assertion in a test. `approxMinWeightVcLiteral` was a valid cover within `2·OPT` on 357 weighted graphs. `mergeListsLiteral`, `exactSubsetSumLiteral`, `trimLiteral` and `approxSubsetSumLiteral` reproduced the CLRS worked example (`307` exact, `302` approximate) and `allSubsetSums({1,4,5})` printed `{0,1,4,5,6,9,10}` exactly as `P₃` in the text; on 2 000 random instances the exact version matched `2ⁿ` brute force and the approximate one satisfied its bound at all four `ε`, worst observed ratio **1.109**. `firstFitLiteral` used `≤ 2·OPT` bins and never fewer than `binPackingLowerBound` on 2 000 instances; `greedyMakespanLiteral` stayed within `2·OPT` on 2 000, with `makespanLowerBound ≤ OPT` throughout.

`AppendixTsp::transition` agreed with full recomputation on **200 000** random triples including the `i = 0, j = n−1` wrap-around case — which the general eight-edge formula gets wrong, and which the body's `swapDelta` never has to handle only because it never picks position 0. `groverSearch` needed **14, 20, 28, 40** rounds for `N = 2¹⁰, 2¹¹, 2¹², 2¹³`: a factor of `1.41` per doubling of `N`, which is `Θ(√N)` measured rather than asserted. Getting that number right required boosting the **amplitude** rather than the probability — boosting the probability directly gives logistic growth and `Θ(√N lg N)`, which is the wrong answer with the right shape, and is noted in the code. `factorFromSamples(77, {33,42,55})` returned `11`.

---

*Next: [M21 — Number-Theoretic Algorithms](INDEX.md#module-map) (CLRS 31) — GCD, modular arithmetic, RSA, and primality testing.*
