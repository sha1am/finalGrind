# Module 15 — Shortest Paths

**Sources:** CLRS 4e ch. 22 (Single-Source Shortest Paths) + ch. 23 (All-Pairs Shortest Paths) · Skiena 3e §8.3 (Shortest Paths — Dijkstra, Floyd–Warshall, transitive closure) + §8.4 (War Story: Dialing for Documents)

---

## Big Idea

**Problem.** Given a weighted, directed graph `G = (V, E)` with `w : E → ℝ`, the **weight of a path** `p = ⟨v₀, v₁, …, v_k⟩` is `w(p) = Σᵢ w(v_{i−1}, vᵢ)`, and the **shortest-path weight** is

```
δ(u,v) = min { w(p) : u ⇝ v }   if any path exists
       = ∞                       otherwise
```

A **shortest path** is any path achieving `δ(u,v)`.

**Everything in this module is one operation applied in different orders.** That operation is **relaxation**:

```
RELAX(u, v, w)
  if v.d > u.d + w(u,v)
      v.d = u.d + w(u,v)
      v.π = u
```

`v.d` is an *upper-bound estimate* on `δ(s,v)` that only ever decreases, and `v.π` is a predecessor pointer. Every single-source algorithm here initializes `s.d = 0`, everything else `∞`, and then relaxes edges. **The only difference between them is the order in which edges are relaxed, and how many times.**

| Algorithm | Relaxation order | Requires | Time |
|---|---|---|---|
| **Bellman-Ford** | every edge, `\|V\|−1` times | nothing | `O(VE)` |
| **DAG-shortest-paths** | every edge once, in topological order | acyclic | `Θ(V+E)` |
| **Dijkstra** | edges out of `u`, in increasing `d[u]` order | `w ≥ 0` | `O(E lg V)` |

The reason the orderings differ in cost is a single structural fact — **Lemma 22.15 (path relaxation)**: if the edges of *some* shortest path to `v` get relaxed *in order*, then `v.d = δ(s,v)` afterwards, no matter what else happened in between. So an algorithm only has to guarantee that ordering. Bellman-Ford brute-forces it (a shortest path has `≤ |V|−1` edges, so `|V|−1` full passes must contain every shortest path as a subsequence). A DAG's topological order *is* that ordering, for free. Dijkstra earns it with a greedy argument that needs `w ≥ 0`.

Then the all-pairs problem (`δ(u,v)` for **every** pair) gets its own two answers: **Floyd–Warshall** `Θ(V³)`, a DP over "which vertices may be used as intermediates", and **Johnson** `O(V² lg V + VE)`, which *reweights* the graph so Dijkstra becomes legal and then runs it `|V|` times.

**Remember months later:** *`δ(u,v)`, relaxation, and the six properties are the whole theory. Negative edges are the fault line: they break Dijkstra (not Bellman-Ford), and negative* **cycles** *break the problem itself (`δ = −∞`). Sparse + non-negative ⟹ Dijkstra. Negative weights ⟹ Bellman-Ford. DAG ⟹ topological order, and remember it also gives you longest paths. All pairs, dense ⟹ Floyd–Warshall; all pairs, sparse ⟹ Johnson.*

---

## What You Should Be Able To Do After This Chapter

- Define `δ(u,v)`, state **Lemma 22.1** (subpaths of shortest paths are shortest paths), and explain why negative-weight cycles make `δ = −∞` and why shortest paths can be assumed **simple**.
- Write `RELAX` from memory and state the **six properties** (triangle inequality, upper-bound, no-path, convergence, path-relaxation, predecessor-subgraph) and which algorithm's correctness rests on which.
- Write **Bellman-Ford**, prove it (Lemma 22.2 → Theorem 22.4), and extend it to *report* a negative cycle and to mark `−∞` vertices.
- Write **DAG-SHORTEST-PATHS**, and use it for **longest paths / critical paths (PERT)** — the one setting where longest paths are easy.
- Write **Dijkstra** with a binary heap and the lazy decrease-key idiom, give all three priority-queue complexities, and **prove Theorem 22.6**.
- Explain concretely — not just "it fails" — *how* Dijkstra fails on a negative edge, and why a `visited` set turns a slow algorithm into a wrong one.
- Model a system of **difference constraints** as a shortest-path problem and solve it with Bellman-Ford.
- Derive the **Floyd–Warshall** recurrence from the "intermediate vertices `{1..k}`" characterization, explain why `k` must be the **outermost** loop, and adapt it to **transitive closure**.
- Explain **Johnson's reweighting** `ŵ(u,v) = w(u,v) + h(u) − h(v)`, prove it preserves shortest paths, and say why `h(v) = δ(s,v)` from a super-source makes `ŵ ≥ 0`.
- Choose the right algorithm from `V`, `E`, sign of weights, and single-source vs all-pairs — in about five seconds, in an interview.
- Recognize when a problem that *isn't about* distances is secretly a shortest-path problem (Skiena's war story; Viterbi).

---

## Part 1 — Foundations (CLRS 22, preamble)

### Unified Understanding

Skiena opens with the practical framing: *"There are typically an enormous number of possible paths connecting two nodes in any given road or social network. The path that minimizes the sum of edge weights… is likely to be the most interesting, reflecting the fastest travel path or the closest kinship between the nodes."* And the key warning that motivates the whole chapter: **BFS is not enough.** In an unweighted graph, BFS's minimum-link path *is* the shortest path (M13, Lemma 20.6). In a weighted graph *"the shortest weighted path might require a large number of edges, just as the fastest route from home to office may involve complicated backroad shortcuts."*

CLRS supplies the formalism. Note the four problem variants and the fact that **they are all the same problem**:

| Variant | Reduction |
|---|---|
| **single-destination** `δ(v, t)` for all `v` | reverse every edge, run single-source from `t` |
| **single-pair** `δ(u, v)` | no asymptotically better algorithm is known than solving single-**source** from `u` |
| **all-pairs** | ch. 23 |
| **single-source** | the one we solve |

That single-pair line is worth internalizing: **there is no known way to compute one distance faster, in the worst case, than computing all `|V|` of them from that source.** (Practical speedups — A*, bidirectional search — are in the Outside Context section, and they help enormously in practice without improving the worst case.)

### Lemma 22.1 — Optimal substructure

> **Subpaths of shortest paths are shortest paths.** If `p = ⟨v₀, …, v_k⟩` is a shortest path from `v₀` to `v_k`, then for any `0 ≤ i ≤ j ≤ k`, the subpath `p_{ij} = ⟨vᵢ, …, v_j⟩` is a shortest path from `vᵢ` to `v_j`.

**Proof skeleton (cut-and-paste — the standard DP/greedy move from M11/M12).** Decompose `p` as `v₀ ⇝ vᵢ ⇝ v_j ⇝ v_k` with weight `w(p) = w(p_{0i}) + w(p_{ij}) + w(p_{jk})`. If some `p′_{ij}` were lighter, splicing it in gives a `v₀ ⇝ v_k` path of weight `< w(p)`, contradicting optimality of `p`. ∎

This one lemma is the reason **every** algorithm in both chapters works. It is what makes `v.π` meaningful (a tree of shortest paths, not a pile of unrelated paths), it is the optimal-substructure step for Floyd–Warshall and for the matrix-multiplication DP, and it powers the triangle inequality.

**Skiena's version of the same insight**, stated as motivation for Dijkstra: *"Suppose the shortest path from s to t in graph G passes through a particular intermediate vertex x. Clearly, the best s-to-t path must contain the shortest path from s to x as its prefix, because if it doesn't we can improve the path by starting with the shorter s-to-x prefix. Thus, we must compute the shortest path from s to x before we find the path from s to t."*

### Negative-weight edges and negative-weight cycles

These are **two different problems** and conflating them is the single most common confusion in this chapter.

- **Negative-weight edges** are fine. `δ` is well-defined; Bellman-Ford handles them; only *Dijkstra* is broken by them.
- **Negative-weight cycles reachable from `s`** destroy the problem. Any path that can reach the cycle can go around it again for less, so no *shortest* path exists: **`δ(s,v) = −∞`** for every `v` reachable from such a cycle. CLRS defines `δ(s,v) = −∞` for exactly this case.

Two consequences people get wrong:

1. A negative-weight cycle that is **not reachable from `s`** is harmless — `δ` is unaffected, and Bellman-Ford correctly returns `TRUE`. *(Verified: a graph with `s→a` in one component and a `−5/−5` two-cycle in another returns `ok = true`.)*
2. Vertices reachable from `s` but **not** reachable from the negative cycle still have finite, correct `δ`. Marking `−∞` is a *reachability* computation on top of Bellman-Ford, not a global flag.

Skiena's version of why this matters, in the classic bank-lobby image:

> *"During the execution we may encounter an edge with weight so negative that it changes the cheapest way to get from s to some other vertex already in the tree. Indeed, the most cost-effective way to get from your house to your next-door neighbor would be to repeatedly cycle through the lobby of any bank offering you enough free money to make the detour worthwhile. Unless that bank limits its reward to one per customer, you might so benefit by making an unlimited number of trips through the lobby that you would never actually reach your destination!"*

He then adds the practical note that keeps this in perspective: *"Fortunately, most applications don't have negative weights, making this discussion largely academic."* True for road networks. **Not** true for the settings where shortest paths get *used as a subroutine*: difference constraints (§22.4), Johnson's reweighting (§23.3), min-cost flow, currency arbitrage, and Viterbi decoding all produce negative weights on purpose.

### Can a shortest path contain a cycle?

**No — you can always assume shortest paths are simple, with at most `|V| − 1` edges.**

- **Negative-weight cycle:** then no shortest path exists at all (the case above).
- **Positive-weight cycle:** removing it strictly lowers the weight, so a path containing one is never shortest.
- **Zero-weight cycle:** removing it doesn't change the weight, so there is *also* a simple shortest path. We take that one.

This is the fact that gives Bellman-Ford its `|V| − 1` and gives the matrix DP its `L^(n−1)`.

### Shortest-paths trees

The output is not a list of `|V|` separate paths; it is a **tree**. A shortest-paths tree rooted at `s` is a subgraph `G′ = (V′, E′)` where:

1. `V′` is exactly the set of vertices reachable from `s`,
2. `G′` is a rooted tree with root `s`,
3. for every `v ∈ V′`, the unique simple `s ⇝ v` path in `G′` is a shortest path in `G`.

Shortest-paths trees are **not unique** (ties in `δ` give different trees of equal quality), and the tree produced depends on the relaxation order. **A shortest-paths tree is not the same object as a minimum spanning tree (M14)** — the MST minimizes total weight, the SPT minimizes each root-to-vertex distance. On the triangle `s–a` = 1, `s–b` = 1, `a–b` = 1.5, the MST is `{sa, ab}` (weight 2.5) but the SPT from `s` is `{sa, sb}` (weight 2). Different trees, different objectives.

### Relaxation — the one operation

`INITIALIZE-SINGLE-SOURCE` sets `v.d = ∞`, `v.π = NIL`, `s.d = 0`. `RELAX(u,v,w)` asks *"is going through `u` a better way to reach `v` than what I have?"* and, if so, records it.

CLRS notes the terminology is historical and backwards-sounding: *"the term is historical. The outcome of a relaxation step can be viewed as a relaxation of the constraint `v.d ≤ u.d + w(u,v)`, which, by the triangle inequality, must be satisfied if `u.d = δ(s,u)` and `v.d = δ(s,v)`."* You are **tightening** an estimate by **relaxing** a violated constraint. Don't fight the name.

**One implementation trap that is not in the pseudocode:** if you represent `∞` as a large finite number (`INT_MAX`, `LLONG_MAX`), then `u.d + w(u,v)` with `u.d = ∞` and `w < 0` is *less than* `∞` and will relax a vertex you cannot even reach — and with `INT_MAX` it also overflows. Guard it: **never relax out of an unreachable vertex.** This is the `if (r.d[u] == INF) return false;` line below and it is the single most common source of wrong answers in negative-weight code.

### The six properties (CLRS p. 611; proofs in §22.5)

Every correctness proof in ch. 22 is assembled from these six. Learn them as a unit.

| # | Property | Statement | Used by |
|---|---|---|---|
| **22.10** | **Triangle inequality** | `δ(s,v) ≤ δ(s,u) + w(u,v)` for all `(u,v) ∈ E` | everything; and directly by Johnson to prove `ŵ ≥ 0` |
| **22.11** | **Upper-bound** | `v.d ≥ δ(s,v)` always; once `v.d = δ(s,v)` it never changes | everything |
| **22.12** | **No-path** | if `v` unreachable then `v.d = δ(s,v) = ∞` forever | Bellman-Ford, Dijkstra |
| **22.14** | **Convergence** | if `s ⇝ u → v` is a shortest path and `u.d = δ(s,u)` *before* `RELAX(u,v,w)`, then `v.d = δ(s,v)` *after*, forever | Dijkstra, DAG |
| **22.15** | **Path-relaxation** | if the edges of a shortest path `⟨v₀,…,v_k⟩` are relaxed **in order**, then `v_k.d = δ(s,v_k)` — regardless of any interleaved relaxations | **Bellman-Ford** |
| **22.17** | **Predecessor-subgraph** | once `v.d = δ(s,v)` for all `v`, `G_π` is a shortest-paths tree | all, for the *tree* half of the answer |

**Proof sketches, all short:**

- **Triangle inequality (22.10):** a shortest `s ⇝ v` path is no heavier than the particular path "shortest `s ⇝ u`, then edge `(u,v)`".
- **Upper-bound (22.11):** induction on relaxation steps. Base: `s.d = 0 ≥ δ(s,s)` and `∞ ≥ δ` elsewhere. Step: if `v.d` changes it becomes `u.d + w(u,v) ≥ δ(s,u) + w(u,v) ≥ δ(s,v)` — inductive hypothesis then triangle inequality. And once `v.d = δ(s,v)` it cannot decrease (it's a lower bound) and cannot increase (relaxation never increases `d`).
- **No-path (22.12):** immediate corollary — `∞ = δ(s,v) ≤ v.d` forces `v.d = ∞`.
- **Lemma 22.13** (the helper): immediately after `RELAX(u,v,w)`, `v.d ≤ u.d + w(u,v)`. Either the relaxation fired (equality) or the condition already held.
- **Convergence (22.14):** `v.d ≤ u.d + w(u,v) = δ(s,u) + w(u,v) = δ(s,v)` by 22.13, the hypothesis, and Lemma 22.1. Combined with the upper-bound property, `v.d = δ(s,v)`.
- **Path-relaxation (22.15):** induction along the path, applying convergence at each edge. `v₀.d = s.d = 0 = δ(s,s)` is the base.
- **Predecessor-subgraph (22.17):** first show `G_π` is always a rooted tree (Lemma 22.16 — a cycle in `G_π` would have to be a negative-weight cycle, by summing the `vᵢ.d ≥ v_{i−1}.d + w` inequalities around it against the one strict inequality that created the cycle); then check the three defining properties of an SPT.

> **Empirical check.** These are not decorative. Over 300 random graphs with negative edges (no negative cycles), relaxing a *randomly chosen* edge `5|E| + 10` times and checking every invariant after **every single step**: `d[v] ≥ δ(v)` always held, `d[v]` never increased, unreachable vertices stayed `∞`, converged vertices stayed converged, and `d[v] ≤ d[u] + w(u,v)` held immediately after each relaxation. 843 separate path-relaxation instances (relaxing one shortest path's edges in order, with random unrelated relaxations interleaved) all converged immediately, exactly as Lemma 22.15 promises.

### C++ Implementation

```cpp
const long long INF = LLONG_MAX / 4;   // "infinity" that survives one addition

struct Edge { int u, v; long long w; };

struct Graph {                          // directed, weighted
    int n;
    vector<vector<pair<int, long long>>> adj;   // adj[u] = {(v, w(u,v)), ...}
    vector<Edge> edges;                          // same edges, flat (Bellman-Ford)

    explicit Graph(int n_) : n(n_), adj(n_) {}

    void addEdge(int u, int v, long long w) {
        adj[u].push_back({v, w});
        edges.push_back({u, v, w});
    }
};

struct SSSP {
    vector<long long> d;    // d[v] = shortest-path estimate
    vector<int> pi;         // pi[v] = predecessor, -1 = NIL
};

void initializeSingleSource(const Graph& g, int s, SSSP& r) {
    r.d.assign(g.n, INF);
    r.pi.assign(g.n, -1);
    r.d[s] = 0;
}

// The one operation every algorithm in this module is built from.
bool relax(int u, int v, long long w, SSSP& r) {
    if (r.d[u] == INF) return false;             // never relax out of "unreachable"
    if (r.d[v] > r.d[u] + w) {
        r.d[v] = r.d[u] + w;
        r.pi[v] = u;
        return true;
    }
    return false;
}

// Walk the predecessor chain backwards, then reverse.  Empty ⟹ v unreachable.
vector<int> extractPath(const SSSP& r, int s, int v) {
    if (r.d[v] == INF) return {};
    vector<int> path;
    for (int x = v; x != -1; x = r.pi[x]) {
        path.push_back(x);
        if (x == s) break;
    }
    if (path.back() != s) return {};
    reverse(path.begin(), path.end());
    return path;
}
```

**Implementation notes.**

- `INF = LLONG_MAX / 4` rather than `LLONG_MAX`: it survives `INF + w` for any sane `w` without overflowing, and it still compares as "unreachable" against any real distance. Never use `INT_MAX` with `+`.
- `relax` returns `bool` — this is what makes Bellman-Ford's early exit, Dijkstra's push, and the negative-cycle detector all one-liners.
- Storing edges **twice** (adjacency list + flat list) costs `Θ(E)` memory and buys you both traversal orders. In a contest, keep only the one you need.
- `extractPath` walks `π` backwards. Skiena: *"We follow the backward parent pointers from t until we hit start (or -1 if no such path exists), exactly as was done in the BFS/DFS find\_path() routine."* Same routine as M13 — the tree structure is the same, only the tree differs.

---

## Part 2 — Bellman-Ford (CLRS 22.1)

### Unified Understanding

Bellman-Ford is the algorithm you get by refusing to be clever. **Relax every edge, `|V| − 1` times.** Then check once more: if anything still improves, there is a negative-weight cycle.

```
BELLMAN-FORD(G, w, s)
1  INITIALIZE-SINGLE-SOURCE(G, s)
2  for i = 1 to |G.V| - 1
3      for each edge (u,v) ∈ G.E
4          RELAX(u, v, w)
5  for each edge (u,v) ∈ G.E              // the |V|-th pass is the test
6      if v.d > u.d + w(u,v)
7          return FALSE
8  return TRUE
```

### Why it works

**The entire correctness argument is one application of the path-relaxation property.**

Take any vertex `v` reachable from `s`, and a shortest path `p = ⟨s = v₀, v₁, …, v_k = v⟩` to it. We argued above that `p` may be assumed **simple**, so `k ≤ |V| − 1`. Now: pass 1 relaxes every edge, so in particular it relaxes `(v₀, v₁)`. Pass 2 relaxes `(v₁, v₂)`. In general, **pass `i` relaxes `(v_{i−1}, vᵢ)`**. After `k ≤ |V| − 1` passes, the edges of `p` have been relaxed *in order* (with lots of other relaxations interleaved, which Lemma 22.15 explicitly permits), so `v.d = δ(s,v)`.

That's it. The algorithm is a brute-force way to guarantee the hypothesis of Lemma 22.15 for **every** shortest path simultaneously.

### Proof Skeleton

**Lemma 22.2.** If `G` has no negative-weight cycle reachable from `s`, then after `|V| − 1` passes, `v.d = δ(s,v)` for all `v` reachable from `s`.
*Proof:* exactly the path-relaxation argument above. Unreachable vertices are handled by the no-path property.

**Corollary 22.3.** `v.d = δ(s,v)` **iff** `G_π` contains a path `s ⇝ v`. (Combines Lemma 22.2 with the predecessor-subgraph property.)

**Theorem 22.4 (correctness of BELLMAN-FORD).**
- *If there is no reachable negative cycle:* by Lemma 22.2, `v.d = δ(s,v)`, so for every edge the triangle inequality gives `v.d = δ(s,v) ≤ δ(s,u) + w(u,v) = u.d + w(u,v)`. The check never fires; return `TRUE`. And `G_π` is a shortest-paths tree by 22.17.
- *If there is a reachable negative cycle `c = ⟨v₀, …, v_k⟩`, `v₀ = v_k`, with `Σ w(v_{i−1}, vᵢ) < 0`:* suppose for contradiction the check does **not** fire, i.e. `vᵢ.d ≤ v_{i−1}.d + w(v_{i−1}, vᵢ)` for all `i`. Sum these `k` inequalities around the cycle:

  ```
  Σᵢ vᵢ.d  ≤  Σᵢ v_{i−1}.d  +  Σᵢ w(v_{i−1}, vᵢ)
  ```

  Each vertex of `c` appears exactly once in each of the two `d`-sums (because `v₀ = v_k`), so those sums are **equal and finite** — finite because the cycle is reachable, so every `vᵢ.d < ∞`. Cancel them:

  ```
  0 ≤ Σᵢ w(v_{i−1}, vᵢ) = w(c) < 0
  ```

  A contradiction. So the check fires and the algorithm returns `FALSE`. ∎

**This "sum the inequalities around the cycle and cancel" move is worth memorizing verbatim.** It appears again, essentially unchanged, in Lemma 22.16 (the `π`-subgraph is acyclic), in Theorem 22.9 (difference constraints are infeasible iff the constraint graph has a negative cycle), and in Lemma 23.1 (Johnson's reweighting preserves negative cycles).

### Complexity

- **`INITIALIZE-SINGLE-SOURCE`:** `Θ(V)`.
- **Main loop:** `|V| − 1` passes × `|E|` relaxations × `Θ(1)` each = **`Θ(VE)`**.
- **Check:** `O(E)`.
- **Total: `Θ(VE)`** — `Θ(V³)` on a dense graph, `Θ(V²)` on a sparse one.
- **Space:** `Θ(V)` auxiliary (`d`, `π`), plus the graph. **No recursion**, so no stack term.

**Where the `|V| − 1` comes from:** it is exactly the maximum number of edges on a simple path. Not "a safety margin" — the tight bound.

> **Empirical check.** On a random `V = 200`, `E = 995` graph with weights in `[1,100]`, Bellman-Ford **converged in 7 passes**, not 199 — random graphs have small diameter, so the early-exit test pays for itself many times over. On an adversarial instance (a 200-vertex path, with the edges *added in reverse order* so each pass advances the frontier by exactly one vertex), it needed **all 199 passes**. The bound is tight, and the constant factor in practice is a function of the graph's **shortest-path hop diameter**, not `|V|`.

**The early-exit optimization is free and always worth writing:** if a pass changes nothing, no later pass will either, so stop. It turns Bellman-Ford from `Θ(VE)` into `Θ(hE)` where `h` is the largest hop-count of any shortest path.

### C++ Implementation

```cpp
struct BellmanFordResult {
    bool ok;        // false ⟺ a negative-weight cycle is reachable from s
    SSSP r;
};

BellmanFordResult bellmanFord(const Graph& g, int s) {
    BellmanFordResult res;
    initializeSingleSource(g, s, res.r);

    for (int i = 1; i < g.n; ++i) {              // |V| - 1 passes
        bool changed = false;
        for (const Edge& e : g.edges)
            if (relax(e.u, e.v, e.w, res.r)) changed = true;
        if (!changed) break;                     // early exit: already converged
    }

    res.ok = true;                               // the |V|-th pass is the test
    for (const Edge& e : g.edges)
        if (res.r.d[e.u] != INF && res.r.d[e.v] > res.r.d[e.u] + e.w) { res.ok = false; break; }
    return res;
}

const long long NEG_INF = LLONG_MIN / 4;

// Exercise 22.1-4: after bellmanFord, set d[v] = -inf for every v whose true
// shortest-path weight is -inf (reachable from a reachable negative cycle).
void markNegativeInfinity(const Graph& g, SSSP& r) {
    vector<char> bad(g.n, 0);
    vector<int> stack;
    for (const Edge& e : g.edges)                // still-relaxable ⟹ downstream of a neg. cycle
        if (r.d[e.u] != INF && r.d[e.v] > r.d[e.u] + e.w && !bad[e.v]) {
            bad[e.v] = 1; stack.push_back(e.v);
        }
    while (!stack.empty()) {                     // ...and everything reachable from those
        int u = stack.back(); stack.pop_back();
        for (const auto& [v, w] : g.adj[u]) {
            (void)w;
            if (!bad[v]) { bad[v] = 1; stack.push_back(v); }
        }
    }
    for (int v = 0; v < g.n; ++v) if (bad[v]) r.d[v] = NEG_INF;
}

// Exercise 22.1-7: recover an actual negative-weight cycle reachable from s.
// Returns v0 ... vk with v0 == vk, or {} if none exists.
vector<int> findNegativeCycle(const Graph& g, int s) {
    SSSP r;
    initializeSingleSource(g, s, r);
    int x = -1;
    for (int i = 0; i < g.n; ++i) {              // |V| passes, remembering the last change
        x = -1;
        for (const Edge& e : g.edges)
            if (relax(e.u, e.v, e.w, r)) x = e.v;
    }
    if (x == -1) return {};                      // nothing relaxed on pass |V|
    for (int i = 0; i < g.n; ++i) x = r.pi[x];   // walk |V| steps back: guaranteed onto the cycle
    vector<int> cycle;
    for (int v = x;; v = r.pi[v]) {
        cycle.push_back(v);
        if (v == x && cycle.size() > 1) break;
    }
    reverse(cycle.begin(), cycle.end());
    return cycle;
}
```

**Why `findNegativeCycle` walks `|V|` steps back.** After `|V|` passes, `x` is a vertex that *still* relaxed, so `x` is reachable from a negative cycle via `π` pointers. The `π`-chain from `x` may enter the cycle after some prefix, but that prefix has fewer than `|V|` vertices, so **`|V|` steps backwards lands you inside the cycle for sure.** Then walk `π` until you see the same vertex again. This is a trick worth memorizing — it comes up constantly in competitive programming (currency arbitrage, "find a profitable loop").

> **Empirical check.** Over 600 random 4–11 vertex graphs with weights in `[−12, 8]`, **415 had a reachable negative cycle**. In all 415, `findNegativeCycle` returned a genuine cycle (every consecutive pair an actual edge, first vertex = last vertex) whose total weight was **strictly negative**. And in all 415, `markNegativeInfinity` agreed *exactly* with an independent oracle: `v` is `−∞` iff `v` is reachable from `s` **and** reachable from some vertex `c` with `Floyd-Warshall d[c][c] < 0` that is itself reachable from `s`.

### Practical variant: SPFA (queue-based Bellman-Ford)

Only relax out of vertices whose `d` actually changed. Keep them in a FIFO queue with an "in queue" flag. Same `O(VE)` worst case, dramatically faster typical case. Known as **SPFA** in competitive programming. Two caveats: (1) it is `O(VE)` in the worst case and adversarial test data targeting SPFA is common on judges; (2) with the **SLF** (small-label-first) and **LLL** heuristics it gets faster still, but never gains a better bound. Use it when you need Bellman-Ford's generality and Bellman-Ford's constant hurts.

---

## Part 3 — Shortest Paths in a DAG (CLRS 22.2)

### Unified Understanding

If the graph is acyclic, **the topological order is the correct relaxation order, for free.**

```
DAG-SHORTEST-PATHS(G, w, s)
1  topologically sort the vertices of G
2  INITIALIZE-SINGLE-SOURCE(G, s)
3  for each vertex u, taken in topologically sorted order
4      for each vertex v ∈ G.Adj[u]
5          RELAX(u, v, w)
```

**One pass. Every edge relaxed exactly once. Negative weights are fine.**

### Why It Works — Theorem 22.5

**Proof skeleton.** Let `v` be reachable from `s` and `p = ⟨v₀ = s, …, v_k = v⟩` a shortest path. Because the graph is a DAG and `p` is a path, `v₀, v₁, …, v_k` appear **in that relative order** in *any* topological order (Lemma 20.11 / M13). The algorithm processes vertices in topological order and relaxes all of `u`'s out-edges when it reaches `u`, so it relaxes `(v₀,v₁)`, then `(v₁,v₂)`, …, then `(v_{k−1},v_k)` — **in order**. Path-relaxation property ⟹ `v.d = δ(s,v)`. Vertices not reachable from `s` get `∞` by the no-path property. ∎

The topological order *is* the ordering that Bellman-Ford spends `|V|−1` passes brute-forcing. That's the entire speedup.

**Why negative edges are harmless here:** the argument never used `w ≥ 0`. And a DAG has no cycles at all, so no negative cycles.

### Complexity

- Topological sort: `Θ(V + E)` (DFS or Kahn — M13).
- Main loop: each vertex dequeued once, each edge relaxed once: `Θ(V + E)`.
- **Total: `Θ(V + E)`. Space `Θ(V)`.**

This is the **fastest shortest-path algorithm in the module** — linear, and it tolerates negative weights. Whenever a problem's graph is acyclic, use it.

### The killer application: longest paths, PERT, and critical paths

Longest path is NP-hard in a general graph (M19). **In a DAG it is linear**, because you can just negate the weights:

> `longest(s,v) = −δ_{−w}(s,v)`

Negation is legal because there are no cycles to turn negative. (Contrast M14: negating weights works for MST too, but for shortest paths in a *general* graph it is catastrophic — negation manufactures negative cycles.)

CLRS's application is **PERT chart analysis**: vertices are jobs, an edge `(u,v)` means job `u` must precede job `v`, and the edge weight is `u`'s duration. The **critical path** — the longest path through the DAG — is the **minimum possible time to complete all jobs**, and any delay on it delays the whole project. Two equivalent implementations: negate the weights and run `DAG-SHORTEST-PATHS`, or replace `min` with `max` and `∞` with `−∞` in `RELAX` directly.

Skiena's version of the same idea, from the war story below: the Viterbi algorithm *"is basically solving a shortest-path problem on a DAG."*

### C++ Implementation

```cpp
// Kahn topological order; empty result ⟹ the graph has a cycle.
vector<int> topoOrder(const Graph& g) {
    vector<int> indeg(g.n, 0), order;
    for (const Edge& e : g.edges) ++indeg[e.v];
    vector<int> q;
    for (int v = 0; v < g.n; ++v) if (indeg[v] == 0) q.push_back(v);
    while (!q.empty()) {
        int u = q.back(); q.pop_back();
        order.push_back(u);
        for (const auto& [v, w] : g.adj[u]) { (void)w; if (--indeg[v] == 0) q.push_back(v); }
    }
    return (int)order.size() == g.n ? order : vector<int>{};
}

SSSP dagShortestPaths(const Graph& g, int s) {
    SSSP r;
    initializeSingleSource(g, s, r);
    for (int u : topoOrder(g))                   // one pass, in topological order
        if (r.d[u] != INF)
            for (const auto& [v, w] : g.adj[u]) relax(u, v, w, r);
    return r;
}

// PERT / critical path: longest path in a DAG = shortest path with negated weights.
SSSP dagLongestPaths(const Graph& g, int s) {
    Graph h(g.n);
    for (const Edge& e : g.edges) h.addEdge(e.u, e.v, -e.w);
    SSSP r = dagShortestPaths(h, s);
    for (long long& x : r.d) if (x != INF) x = -x;
    return r;
}
```

> **Empirical check.** CLRS Figure 22.5 (`r,s,t,x,y,z` with source `s`) reproduces exactly: `d = [∞, 0, 2, 6, 5, 3]`, and Bellman-Ford on the same graph agrees. Over 400 random DAGs with weights in `[−20, 20]` (all of them containing negative edges), `dagShortestPaths` agreed with Bellman-Ford, Floyd–Warshall and Johnson from **every** source. `dagLongestPaths` agreed with a direct max-DP on 300 random DAGs, and on the 5-task example gives critical path `0→1→3→4` of length 9.

---

## Part 4 — Dijkstra's Algorithm (CLRS 22.3, Skiena 8.3.1)

### Unified Understanding

**Requires `w(u,v) ≥ 0` for all edges.** Maintain a set `S` of vertices whose shortest-path weights are **final**. Repeatedly extract the vertex `u ∉ S` with the smallest `u.d`, add it to `S`, and relax all its out-edges.

```
DIJKSTRA(G, w, s)
1  INITIALIZE-SINGLE-SOURCE(G, s)
2  S = ∅
3  Q = ∅
4  for each vertex u ∈ G.V
5      INSERT(Q, u)
6  while Q ≠ ∅
7      u = EXTRACT-MIN(Q)
8      S = S ∪ {u}
9      for each vertex v ∈ G.Adj[u]
10         if RELAX(u, v, w)
11             DECREASE-KEY(Q, v, v.d)
```

**Skiena's framing is the one to keep**, because it makes the algorithm impossible to forget: *"The basic idea is very similar to Prim's algorithm. In each iteration, we add exactly one vertex to the tree of vertices for which we know the shortest path from s. As in Prim's, we keep track of the best path seen to date for all vertices outside the tree, and insert them in order of increasing cost."* And then the punchline — he presents Dijkstra as *"an implementation of Dijkstra's algorithm based on changing exactly four lines from our Prim's implementation—one of which is simply the name of the function!"*

> **The only difference between Prim and Dijkstra:**
>
> | | key `v` is ranked by |
> |---|---|
> | **Prim (M14)** | `w(u,v)` — the weight of the connecting edge |
> | **Dijkstra** | `d[u] + w(u,v)` — the distance from `s` through `u` |
>
> Skiena: *"In the minimum spanning tree algorithm, we sought to minimize the weight of the next potential tree edge. In shortest path, we want to identify the closest outside vertex (in shortest-path distance) to s. This desirability is a function of both the new edge weight and the distance from s to the tree vertex it is adjacent to."*

That one-line difference is also exactly why Prim tolerates negative weights and Dijkstra does not: Prim's keys don't accumulate.

**CLRS's framing** is the greedy one: Dijkstra *"always chooses the 'lightest' or 'closest' vertex in `V − S` to add to set `S`"* — an instance of the greedy strategy of M12. Note that this greedy choice is provably optimal (unlike, say, 0-1 knapsack), and the proof is Theorem 22.6.

### Why It Works — Theorem 22.6

> **Loop invariant:** at the start of each iteration of the `while` loop, `v.d = δ(s,v)` for all `v ∈ S`.

**Proof skeleton (the squeeze).** Suppose for contradiction `u` is the **first** vertex extracted with `u.d ≠ δ(s,u)`. Then `u ≠ s` (since `s.d = 0 = δ(s,s)` and `s` is extracted first), and `u` must be reachable (else `u.d = δ = ∞` by the no-path property), so a shortest path `p : s ⇝ u` exists.

Just before `u` is extracted, `s ∈ S` and `u ∉ S`. So walking `p` from `s`, there is a **first** vertex `y ∈ p` with `y ∉ S`; let `x ∈ S` be its predecessor on `p`. Decompose `p` as `s ⇝ x → y ⇝ u`.

1. `x.d = δ(s,x)` — because `x ∈ S` and `u` was the first bad extraction.
2. Edge `(x,y)` was relaxed when `x` was added to `S`, and `x.d` was already correct then, so by the **convergence property** `y.d = δ(s,y)`.
3. `y` precedes `u` on a shortest path, so `δ(s,y) ≤ δ(s,u)` — **this step needs non-negative weights**: the segment `y ⇝ u` has weight `≥ 0`.
4. `u` was chosen by `EXTRACT-MIN` over `y`, so `u.d ≤ y.d`.

Chain them:

```
δ(s,y)  ≤  δ(s,u)  ≤  u.d  ≤  y.d  =  δ(s,y)
   (3)       (22.11)    (4)      (2)
```

Everything is squeezed to equality, so `u.d = δ(s,u)` — contradicting the assumption. ∎

**Corollary 22.7:** on termination `v.d = δ(s,v)` for all `v`, and `G_π` is a shortest-paths tree (by 22.17).

**Look at where `w ≥ 0` entered: step 3, and only step 3.** That is the entire dependency. Everything else in the proof is sign-agnostic. Knowing *exactly which line* fails is what lets you answer "why doesn't Dijkstra work with negative edges?" in an interview with something better than "it just doesn't."

### Complexity — three implementations

The running time is `Θ(V)` inserts + `Θ(V)` extract-mins + `≤ E` decrease-keys, so:

| Priority queue | INSERT | EXTRACT-MIN | DECREASE-KEY | **Total** | Best when |
|---|---|---|---|---|---|
| **array / linear scan** | `O(1)` | `O(V)` | `O(1)` | **`Θ(V² + E) = Θ(V²)`** | **dense**: `E = Ω(V²/lg V)` |
| **binary min-heap** | `O(lg V)` | `O(lg V)` | `O(lg V)` | **`O((V + E) lg V) = O(E lg V)`** | **sparse** — the practical default |
| **Fibonacci heap** | `O(1)` am. | `O(lg V)` am. | `O(1)` **am.** | **`O(V lg V + E)`** | theory; large constants |

*(The `O(E lg V)` simplification assumes `E ≥ V`, i.e. every vertex is reachable — otherwise write `O((V+E) lg V)`.)*

**Where each term comes from — say this, don't just quote the bound:**
- `V` extract-mins, one per vertex, because each vertex enters `S` exactly once.
- `≤ E` decrease-keys, because a decrease-key can only follow a successful relaxation, and each edge is relaxed once.
- So the total is `V · T_extract + E · T_decrease`. Read the table as that formula.

**CLRS's historical note is the memorable part:** Fibonacci heaps were *invented* to make this line `O(1)`. *"Because the number of DECREASE-KEY operations is typically much greater than the number of EXTRACT-MIN operations, any method that reduces the amortized time of DECREASE-KEY without increasing the amortized time of EXTRACT-MIN yields an asymptotically faster implementation."* That is the entire design brief of the Fibonacci heap (M09's potential method built it).

Skiena's implementation is the `Θ(V²)` array version, and he is explicit that this is a *feature*, not a shortcoming: *"As implemented here, the complexity is `O(n²)`, exactly the same running time as a proper version of Prim's algorithm. This is because, except for the extension condition, it is exactly the same algorithm as Prim's."*

> **Empirical check.** Heap pushes never exceeded `E + 1` on any tested graph: `V=100, E=198 → 89` pushes; `V=400, E=79794 → 1882` pushes. Note how far *below* the bound the count is on a random graph — most relaxations don't improve anything. Meanwhile the `Θ(V²)` version does a fixed `V² = 160,000` scan steps regardless. The crossover is real: at `V=400, E=3190` the heap does 704 pushes against 160,000 scan steps, and at `V=400, E≈V²/2` the heap's `E lg V` finally loses to the array's `V²`.

### The lazy decrease-key idiom (the one you should actually write)

`std::priority_queue` has no `decrease-key`. The standard workaround — the same one used for Prim in M14 — is to **push a new entry on every improvement and skip stale entries on pop**:

```
if (du > r.d[u]) continue;   // this entry is stale; a better one is already in d[]
```

The queue can hold up to `E` entries instead of `V`, so the bound becomes `O(E lg E) = O(E lg V)` — **the same**, because `lg E ≤ lg V² = 2 lg V`. Memory goes from `Θ(V)` to `Θ(E)`. In exchange, you never write a heap. This is the right default.

### C++ Implementation

```cpp
SSSP dijkstra(const Graph& g, int s) {
    SSSP r;
    initializeSingleSource(g, s, r);
    using P = pair<long long, int>;                        // (d[v], v)
    priority_queue<P, vector<P>, greater<P>> pq;
    pq.push({0, s});
    while (!pq.empty()) {
        auto [du, u] = pq.top(); pq.pop();
        if (du > r.d[u]) continue;                         // stale entry: lazy decrease-key
        for (const auto& [v, w] : g.adj[u])
            if (relax(u, v, w, r)) pq.push({r.d[v], v});
    }
    return r;
}

// Θ(V²) Dijkstra: no heap, linear scan for the minimum.  Wins on dense graphs.
SSSP dijkstraDense(const Graph& g, int s) {
    SSSP r;
    initializeSingleSource(g, s, r);
    vector<char> done(g.n, 0);
    for (int iter = 0; iter < g.n; ++iter) {
        int u = -1;
        long long best = INF;
        for (int i = 0; i < g.n; ++i)
            if (!done[i] && r.d[i] < best) { best = r.d[i]; u = i; }
        if (u == -1) break;                                // rest is unreachable
        done[u] = 1;
        for (const auto& [v, w] : g.adj[u]) relax(u, v, w, r);
    }
    return r;
}

// Skiena's "design graphs, not algorithms": vertex costs become edge weights.
SSSP vertexWeightedShortestPaths(int n, const vector<vector<int>>& out,
                                 const vector<long long>& cost, int s) {
    Graph g(n);
    for (int u = 0; u < n; ++u)
        for (int v : out[u]) g.addEdge(u, v, cost[v]);     // pay for the vertex you enter
    SSSP r = dijkstra(g, s);
    if (r.d[s] != INF) r.d[s] = cost[s];                   // plus the source's own cost
    for (int v = 0; v < n; ++v) if (v != s && r.d[v] != INF) r.d[v] += cost[s];
    return r;
}
```

**Common bugs in Dijkstra, in order of how often they appear in real code:**

1. **Forgetting the stale-entry check** (`if (du > r.d[u]) continue;`). Still correct, but re-expands vertices and can blow up.
2. **Using `int` for distances.** `V · max_w` overflows `int` fast. Use `long long`.
3. **Comparator direction.** `std::priority_queue` is a **max**-heap by default. You need `greater<P>` (or push negated keys). Getting this backwards produces plausible-looking wrong answers.
4. **Pair ordering.** Push `{distance, vertex}`, not `{vertex, distance}` — the heap sorts on `.first`.
5. **Running it on a graph with negative edges** because "the weights are *mostly* positive". See below.
6. **Relaxing out of an unreachable vertex** when `∞` is a finite sentinel.

### Why negative edges break it — concretely

Skiena's bank-lobby image (quoted in Part 1) explains negative *cycles*. But Dijkstra breaks on a single negative **edge**, with no cycle at all. Exercise 22.3-2 asks for exactly this, and the smallest instance is worth memorizing:

```
        s ──1──▶ u ──1──▶ t
        │        ▲
        2        │
        ▼       −2
        v ───────┘
```

`δ(s,u) = 0` (via `s → v → u`, weight `2 + (−2)`), so `δ(s,t) = 1`. But Dijkstra extracts `u` **first**, with `u.d = 1`, because `1 < 2`. Step 3 of Theorem 22.6 has failed: `y = v` sits on the shortest path to `u` but `δ(s,v) = 2 > 0 = δ(s,u)`. Once `u` is in `S` and its out-edges have been relaxed with the wrong value, `t.d = 2` and never recovers.

> **Empirical check.** On exactly this graph: `δ(s,u) = 0` but `u` is finalized at `1`. `dijkstraDense` — which has an explicit `done[]` set, like the textbook — **returns `d[t] = 2` when the truth is `1`.** Bellman-Ford gets `1`.

**Here is the subtlety almost nobody knows, and it is a great interview follow-up.** The *lazy-heap* version above has **no `visited` set** — a stale-entry check is not the same thing. So when `v.d` improves after `v` was already popped, it simply gets pushed again and re-expanded. That makes it **correct on graphs with negative edges but no negative cycles** — and destroys the running-time guarantee, because the `V` extract-mins / `E` decrease-keys accounting no longer holds. It degenerates into a Bellman-Ford-flavoured algorithm (essentially SPFA with a heap).

> **Empirical check.** On a chain of `k` "late-discovered discount" gadgets (`V = 2k+1`, `E = 3k`, one route free, one route expensive-then-refunded so it pops last and re-triggers everything downstream), pops grow as **`(k+1)²`**:
>
> | `k` | `V` | `E` | pops |
> |---|---|---|---|
> | 4 | 9 | 12 | 25 |
> | 8 | 17 | 24 | 81 |
> | 16 | 33 | 48 | 289 |
> | 32 | 65 | 96 | 1089 |
> | 64 | 129 | 192 | **4225** |
>
> The answer was correct every time (checked against Bellman-Ford) but the pop count is `Θ(V²)` on a graph with `Θ(V)` edges — nothing like `O(E lg V)`. Instances forcing far worse than quadratic blow-up are known. **Summary: with a `visited` set, negative edges make Dijkstra wrong; without one, they make it slow. Neither is what you want — use Bellman-Ford, or reweight with Johnson.**

### Stop and Think: shortest path with node costs (Skiena)

> **Problem.** Given a directed graph whose weights are on the **vertices** instead of the edges — the cost of a path from `x` to `y` is the sum of the weights of all vertices on it — find shortest paths.

Skiena gives two solutions and clearly prefers the second:

> *"A natural idea would be to adapt the algorithm we have for edge-weighted graphs (Dijkstra's) to the new vertex-weighted domain… However, my preferred approach would leave Dijkstra's algorithm intact and instead concentrate on constructing an edge-weighted graph on which Dijkstra's algorithm will give the desired answer. Set the weight of each directed edge `(i, j)` in the input graph to the cost of vertex `j`. Dijkstra's algorithm now does the job.* **Try to design graphs, not algorithms.***"*

That italicized sentence is one of the most valuable lines in Skiena's book, and it is the mental move that a huge fraction of hard interview graph problems reward. **Do not modify the algorithm. Modify the graph so a stock algorithm answers your question.** Some standard instances of the move:

| Problem | Graph you build |
|---|---|
| Costs on vertices | `w(i,j) = cost(j)`; add `cost(s)` at the end |
| Costs on both vertices and edges | `w(i,j) = edge(i,j) + cost(j)` |
| At most `k` "free" edges / refuels / discounts | **layered graph**: `k+1` copies of `V`, free edges jump a layer |
| Alternating constraints (must alternate red/blue edges) | 2 copies of `V`, one per state |
| Node capacity in flow (M16) | split `v` into `v_in → v_out` with capacity on the middle edge |
| Shortest path with parity / mod-`m` constraint | `m` copies of `V` |
| Time-dependent edges (trains, schedules) | vertices = (station, time) |

Every one of these is Dijkstra or BFS on a **different graph**, not a different algorithm.

> **Empirical check.** Over 300 random vertex-weighted graphs, the edge-weight transformation matched a direct vertex-cost relaxation computed independently, on every instance.

---

## Part 5 — Difference Constraints and Shortest Paths (CLRS 22.4)

### Unified Understanding

This is where shortest paths stop being about distance. It is the best evidence in either book for "graph algorithms are a **modelling language**, not just a toolbox."

A **system of difference constraints** is a linear program `Ax ≤ b` in which **every row has exactly one `+1` and one `−1`**, i.e. every constraint has the form

```
x_j − x_i ≤ b_k
```

Such systems show up whenever the unknowns are **times** and the constraints are **"at least / at most this much time must elapse between two events."** CLRS's example: *"If the manufacturer applies an adhesive that takes 2 hours to set at time `x₁` and has to wait until it sets to install a part at time `x₂`, then there is a constraint that `x₂ ≥ x₁ + 2` or, equivalently, that `x₁ − x₂ ≤ −2`."* Scheduling, timing analysis in circuits, temporal databases and build systems are all shaped like this.

**Lemma 22.8 (the shift lemma).** If `x` is a solution, so is `x + d·𝟙` for any constant `d`. *Proof:* `(x_j + d) − (xᵢ + d) = x_j − xᵢ`. ∎ So solutions come in translation classes — you can always normalize `x₀ = 0`.

Also note: if every `bᵢ ≥ 0`, the system is trivially feasible (set all `xᵢ` equal). **The problem is interesting only when some `bᵢ < 0`** — which is exactly when negative edges appear.

### The constraint graph

View the `m × n` matrix `A` as the **transpose of an incidence matrix**. Build `G = (V, E)`:

- `V = {v₀, v₁, …, v_n}` — one vertex per unknown, **plus a super-source `v₀`**,
- for each constraint `x_j − xᵢ ≤ b_k`, an edge `(vᵢ, v_j)` of weight `b_k`,
- an edge `(v₀, vᵢ)` of weight `0` for every `i`.

The `v₀` edges exist for one reason: **to guarantee some vertex can reach all the others**, so a single Bellman-Ford run sees the whole graph (and so every negative cycle is reachable from the source and therefore detected).

### Theorem 22.9

> If `G` has **no negative-weight cycle**, then `x = (δ(v₀,v₁), …, δ(v₀,v_n))` is a **feasible solution**. If `G` **has** a negative-weight cycle, the system has **no** feasible solution.

**Proof skeleton — and it is beautifully short in both directions.**

*Feasibility.* For any edge `(vᵢ, v_j)` the **triangle inequality** gives `δ(v₀,v_j) ≤ δ(v₀,vᵢ) + w(vᵢ,v_j)`, i.e. `x_j − xᵢ ≤ b_k`. **That is literally the constraint.** The triangle inequality *is* the difference constraint. ∎

*Infeasibility.* Let `c = ⟨v₁, …, v_k⟩`, `v₁ = v_k`, be a negative cycle. (`v₀` cannot be on it — it has no entering edges.) The edges of `c` correspond to constraints `x₂ − x₁ ≤ w(v₁,v₂)`, …, `x_k − x_{k−1} ≤ w(v_{k−1},v_k)`. Sum them: on the left, each unknown is added once and subtracted once (since `x₁ = x_k`), so the left side is **0**; the right side is `w(c)`. So any solution would satisfy `0 ≤ w(c) < 0`. Contradiction. ∎

**Same move as Theorem 22.4.** Sum around the cycle, watch the `x`'s telescope to zero, contradict.

### Complexity

`m` constraints on `n` unknowns ⟹ `n + 1` vertices and `n + m` edges ⟹ Bellman-Ford runs in `O((n+1)(n+m)) = O(n² + nm)`. Exercise 22.4-5 improves this to `O(nm)` even when `m ≪ n` (the trick: the `v₀` edges never need re-relaxing, so initialize all `d = 0` and drop `v₀` entirely — Exercise 22.4-7).

Two exercises worth knowing as facts, because they turn a feasibility solver into an optimizer:

- **Ex 22.4-8:** Bellman-Ford's solution **maximizes `Σ xᵢ`** subject to `Ax ≤ b` and `xᵢ ≤ 0`.
- **Ex 22.4-9:** it also **minimizes `max{xᵢ} − min{xᵢ}`** — i.e. it produces the schedule with the **shortest makespan**. That is why this is genuinely useful for scheduling construction jobs, not just a cute reduction.

### C++ Implementation

```cpp
struct Constraint { int i, j; long long b; };               // means  x[j] - x[i] <= b

bool solveDifferenceConstraints(int n, const vector<Constraint>& cs, vector<long long>& x) {
    Graph g(n + 1);
    const int v0 = n;                                       // the extra super-source
    for (const Constraint& c : cs) g.addEdge(c.i, c.j, c.b);
    for (int i = 0; i < n; ++i) g.addEdge(v0, i, 0);
    BellmanFordResult res = bellmanFord(g, v0);
    if (!res.ok) return false;                              // negative cycle ⟹ infeasible
    x.assign(n, 0);
    for (int i = 0; i < n; ++i) x[i] = res.r.d[i];          // x_i = δ(v0, v_i)
    return true;
}
```

> **Empirical check.** CLRS's system (22.2)–(22.9) yields exactly the book's answer `x = (−5, −3, 0, −1, −4)`, every constraint verified, and shifting by `−100`, `+7`, `+1000` stays feasible (Lemma 22.8). A two-constraint cycle `x₁ − x₀ ≤ −1`, `x₀ − x₁ ≤ −1` is correctly rejected. Over **400 random systems**: 283 reported feasible — every returned `x` satisfies every constraint; 117 reported infeasible — **an exhaustive search over the box `[−6,6]³` with `x₀ = 0` fixed (legal by Lemma 22.8) found no solution in any of them.**

**Recognition pattern.** If a problem's constraints are all of the form *"`b` happens at least/at most `k` after `a`"*, or *"the difference between these two quantities is bounded"*, it is a difference-constraint system: **build the constraint graph and run Bellman-Ford.** Infeasibility = negative cycle. This also covers equality constraints `xᵢ = x_j + b` (encode as `≤ b` and `≥ b`, i.e. two edges — Ex 22.4-6) and single-variable bounds `xᵢ ≤ b` (an edge from `v₀` — Ex 22.4-10).

---

## Part 6 — All-Pairs Shortest Paths: The Setup (CLRS 23, preamble)

### Unified Understanding

Now compute `δ(u,v)` for **every** ordered pair. Output is an `n × n` matrix `D` plus (optionally) an `n × n` predecessor matrix `Π`.

**The naive answers, which are also sometimes the right answers:**

| Approach | Time | Use when |
|---|---|---|
| `V` × Dijkstra (array queue) | `O(V³ + VE) = O(V³)` | dense, `w ≥ 0` |
| `V` × Dijkstra (binary heap) | `O(V(V+E) lg V) = O(VE lg V)` sparse | **sparse, `w ≥ 0`** |
| `V` × Dijkstra (Fibonacci heap) | `O(V² lg V + VE)` | sparse, `w ≥ 0`, theory |
| `V` × Bellman-Ford | `O(V²E)` = `O(V⁴)` dense | negative weights — **and this is what we want to beat** |
| **Floyd–Warshall** | **`Θ(V³)`** | dense, negative weights OK |
| **Johnson** | **`O(V² lg V + VE)`** | **sparse, negative weights** |

**Representation switch.** Chapter 22 used adjacency lists. Chapter 23 uses an **adjacency matrix**, and Skiena explains why this is not extravagant: *"Floyd's algorithm is best employed on an adjacency matrix data structure, which is no extravagance since we must store all `n²` pairwise distances anyway."* The output is `Θ(V²)` no matter what, so the `Θ(V²)` input representation is free. Johnson is the exception — it uses adjacency lists, because it is the *sparse-graph* algorithm.

The input convention (23.1):

```
w_ij = 0            if i = j
     = w(i,j)       if i ≠ j and (i,j) ∈ E
     = ∞            if i ≠ j and (i,j) ∉ E
```

**Skiena's warning on this is the single most practical sentence in his shortest-paths section:**

> *"The critical issue in an adjacency matrix implementation is how we denote the edges absent from the graph. A common convention for unweighted graphs denotes graph edges by 1 and non-edges by 0. This gives exactly the wrong interpretation if the numbers denote edge weights, because the non-edges get interpreted as a free ride between vertices. Instead, we should initialize each non-edge to MAXINT."*

A `0` in a weight matrix means "free edge," not "no edge." This bug produces answers that look reasonable and are entirely wrong.

**The honest motivating application.** CLRS punctures the standard one: a road atlas distance table sounds like all-pairs shortest paths, but *"a road map modeled as a graph has one vertex for every road intersection… the United States has approximately 300,000 signal-controlled intersections"* while the table has 100 cities. The **legitimate** application is the **diameter** of a network — the longest of all shortest paths, i.e. worst-case message transit time. Skiena adds the **graph center** — *"the one that minimizes the longest or average distance to all the other nodes. This might be the best place to start a new business."*

### The matrix-multiplication view (CLRS 23.1) — worth knowing for the idea, not the algorithm

Define `l_ij^(r)` = minimum weight of any path from `i` to `j` **using at most `r` edges**. Then `l_ij^(0) = 0` if `i = j`, else `∞`, and

```
l_ij^(r) = min { l_ik^(r−1) + w_kj : 1 ≤ k ≤ n }                        (23.3)
```

*(The "or don't extend at all" case `l_ij^(r−1)` is absorbed because `w_jj = 0`.)*

Since shortest paths are simple and have `≤ n − 1` edges, `δ(i,j) = l_ij^(n−1) = l_ij^(n) = …` (23.4).

**Now the observation the section exists for.** Compare (23.3) with ordinary matrix multiplication `c_ij = Σ_k a_ik · b_kj`:

| matrix multiply | extend-shortest-paths |
|---|---|
| `Σ` | `min` |
| `·` | `+` |
| identity for `Σ` = `0` | identity for `min` = `∞` |
| identity for `·` = `1` | identity for `+` = `0` |

**`EXTEND-SHORTEST-PATHS` *is* matrix multiplication over the `(min, +)` semiring** — the **tropical semiring**. So `L^(r) = L^(r−1) ⊙ W = W^r`, and the answer is `W^(n−1)`.

- Naive: `n − 1` products × `Θ(n³)` each = **`Θ(n⁴)`** (`SLOW-APSP`).
- **Repeated squaring** (the same trick as fast modular exponentiation): the `⊙` product is associative, and `L^(r) = L^(n−1)` for all `r ≥ n − 1`, so compute `W¹, W², W⁴, …, W^(2^⌈lg(n−1)⌉)` in `⌈lg(n−1)⌉` products = **`Θ(n³ lg n)`** (`FASTER-APSP`).

**Why learn this if Floyd–Warshall beats it?** Three reasons:
1. **The semiring swap is a reusable technique.** Change `(min, +)` to `(∨, ∧)` and you get transitive closure. Change it to `(+, ×)` and the same code **counts paths**. Change it to `(max, min)` and it computes **bottleneck** (widest-path) capacities. Same code, different algebra. (M11 used exactly this move to turn CYK parsing into minimum-edit CYK.)
2. **Repeated squaring generalizes.** "Shortest path using exactly / at most `k` edges" is `W^k` and computable in `Θ(n³ lg k)` — a genuinely useful competitive-programming primitive that Floyd–Warshall cannot do.
3. It is the bridge to sub-cubic results: fast matrix multiplication does **not** directly apply (the tropical semiring lacks subtraction, so Strassen-style algorithms don't work), which is why `Θ(V³)` has been so hard to beat. The best known is `O(V³ (lg lg V / lg V)^{1/3})` (Fredman) and later `V³/2^{Ω(√lg V)}` bounds — polylog improvements, not polynomial ones.

---

## Part 7 — The Floyd–Warshall Algorithm (CLRS 23.2, Skiena 8.3.2)

### Unified Understanding

**A different characterization of a shortest path — and a much better one.** Instead of counting edges, restrict which vertices may be used as **intermediates**.

> An **intermediate vertex** of a path `p = ⟨v₁, v₂, …, v_l⟩` is any vertex other than `v₁` and `v_l`.

Number the vertices `1..n` — Skiena stresses the numbering carries no meaning: *"We use these numbers not to label the vertices, but to order them."*

Let `d_ij^(k)` = weight of a shortest `i ⇝ j` path **all of whose intermediate vertices lie in `{1, 2, …, k}`**.

- `k = 0`: no intermediates allowed at all, so `d_ij^(0) = w_ij` — **the adjacency matrix itself**.
- `k = n`: everything allowed, so `d_ij^(n) = δ(i,j)` — **the answer**.

### The recurrence and why it's correct

For each pair `(i,j)`, consider a shortest path `p` with intermediates in `{1..k}`. **Either `k` is on `p`, or it isn't.**

- **`k` not on `p`:** every intermediate of `p` is in `{1..k−1}`, so `d_ij^(k) = d_ij^(k−1)`.
- **`k` on `p`:** decompose `p` as `i ⇝ k ⇝ j`. By **Lemma 22.1**, `p₁ = i ⇝ k` and `p₂ = k ⇝ j` are themselves shortest paths. And here is the crucial detail: **`k` is not an intermediate vertex of `p₁` or of `p₂`** — it is an *endpoint* of each. (Shortest paths are simple, so `k` appears exactly once on `p`.) So both subpaths have all intermediates in `{1..k−1}`, giving `d_ij^(k) = d_ik^(k−1) + d_kj^(k−1)`.

```
d_ij^(0) = w_ij
d_ij^(k) = min ( d_ij^(k−1) ,  d_ik^(k−1) + d_kj^(k−1) )        for k ≥ 1     (23.6)
```

Skiena writes it identically and, being honest, flags the subtlety: *"The correctness of this is somewhat subtle, and I encourage you to convince yourself of it. Indeed, it is a great example of dynamic programming."* **The subtle step is exactly the "`k` is an endpoint, not an intermediate, of each half" observation.** If you can't produce that sentence, you don't yet understand Floyd–Warshall.

```
FLOYD-WARSHALL(W, n)
1  D^(0) = W
2  for k = 1 to n
3      let D^(k) be a new n × n matrix
4      for i = 1 to n
5          for j = 1 to n
6              d_ij^(k) = min(d_ij^(k−1), d_ik^(k−1) + d_kj^(k−1))
7  return D^(n)
```

### The one thing to never get wrong: loop order

**`k` must be the OUTERMOST loop.** This is the most common Floyd–Warshall bug in existence, and it is silent — the code compiles, runs in the same time, and returns wrong answers on some graphs.

The reason is the DP structure, not a coincidence: stage `k` depends on *all* of stage `k−1`. Writing `for i / for j / for k` computes, for each pair, some ad-hoc mixture of stages and never establishes the invariant "all paths through `{1..k}` have been found."

**Mnemonic:** *`k` is the DP dimension; `i` and `j` are just the table you fill in at each stage.*

**Exercise 23.2-4 — you can drop the superscripts.** The in-place version, which is what everyone writes (and what Skiena prints), is correct: during iteration `k`, the entries `d[i][k]` and `d[k][j]` never change, because `d_ik^(k) = min(d_ik^(k−1), d_ik^(k−1) + d_kk^(k−1))` and `d_kk^(k−1) = 0` (no negative cycles). So reading a partially-updated row or column is harmless. **Space drops from `Θ(n³)` to `Θ(n²)`.**

### Complexity

- Three nested loops, `Θ(1)` inside: **`Θ(n³) = Θ(V³)`**, with no dependence on `E`.
- **Space `Θ(V²)`** (in-place), or `Θ(V²)` for `D` plus `Θ(V²)` for `Π`.
- **`Θ`, not `O`** — there is no early exit, no data-dependence, no best case. It always does exactly `n³` iterations.

**Why it beats `V` × Dijkstra in practice despite matching or losing asymptotically.** Skiena is blunt and correct: *"The Floyd–Warshall all-pairs shortest-path algorithm runs in `O(n³)` time, which is asymptotically no better than `n` calls to Dijkstra's algorithm. However, the loops are so tight and the program so short that it runs better in practice. It is notable as one of the rare graph algorithms that work better on adjacency matrices than adjacency lists."* Three flat arrays, unit-stride inner loop, perfect branch prediction, no heap, no pointer chasing, trivially vectorizable and cache-blockable. **Constant factors matter, and this is the canonical example.**

> **Empirical check.** CLRS Figure 23.1/23.4's five-vertex matrix reproduces exactly, and the in-place variant returns the identical matrix. At `V = 400`: on a **sparse** graph (`E = 1596`) Floyd–Warshall took **37.5 ms** and Johnson **19.6 ms** — Johnson wins. On a **dense** graph (`E = 95,767`) Floyd–Warshall took **59.9 ms** and Johnson **135.8 ms** — Floyd–Warshall wins by more than 2×. Note also that Floyd–Warshall's time barely moved between the two (37 ms → 60 ms) because it is `Θ(V³)` regardless of `E`, while Johnson's grew 7×.

### Constructing shortest paths

Two options.

**(a) Compute `Π` alongside `D`.** `π_ij^(k)` = predecessor of `j` on a shortest `i ⇝ j` path with intermediates in `{1..k}`.

```
π_ij^(0) = NIL          if i = j or w_ij = ∞
         = i            otherwise                                        (23.7)

π_ij^(k) = π_ij^(k−1)                if d_ij^(k−1) ≤ d_ik^(k−1) + d_kj^(k−1)
         = π_kj^(k−1)                otherwise                           (23.8)
```

**Read (23.8) carefully — it is `π_kj`, not `π_ik` and not `k`.** When routing through `k`, the last hop into `j` is whatever the last hop into `j` was on the `k ⇝ j` path. Row `i` of `Π` is then a shortest-paths **tree** rooted at `i`, and `PRINT-ALL-PAIRS-SHORTEST-PATH` walks it exactly like Chapter 22's `PRINT-PATH`.

**(b) Skiena's variant: store the *middle* vertex.** *"These paths can be recovered if we retain a parent matrix `P` containing our choice of the last intermediate vertex used for each vertex pair `(x,y)`. Say this value is `k`. The shortest path from `x` to `y` is the concatenation of the shortest path from `x` to `k` with the shortest path from `k` to `y`, which can be reconstructed recursively given the matrix `P`."* Store `mid[i][j] = k` whenever the `k`-route wins; reconstruct by recursing on `(i,k)` and `(k,j)`. Equivalent; some find it more natural.

And Skiena's practical note, which is why he doesn't bother: *"most all-pairs applications only need the resulting distance matrix. These are the jobs that Floyd's algorithm was designed for."*

### Transitive closure (CLRS 23.2, Skiena 8.3.3) — the semiring swap

The **transitive closure** `G* = (V, E*)` has `(i,j) ∈ E*` iff `G` has a path `i ⇝ j`.

**Method 1 (Skiena's).** Run Floyd–Warshall with all edge weights `1`. *"If the shortest path from `i` to `j` remains MAXINT after running Floyd's algorithm, you can be sure that no directed path exists from `i` to `j`. Any vertex pair of weight less than MAXINT must be reachable."* `Θ(V³)`, works, wastes memory on `long long`s.

**Method 2 (CLRS's, better).** Substitute the boolean semiring: `min → ∨`, `+ → ∧`, weights → `{0,1}`.

```
t_ij^(0) = 1 if i = j or (i,j) ∈ E, else 0
t_ij^(k) = t_ij^(k−1) ∨ (t_ik^(k−1) ∧ t_kj^(k−1))                        (23.9)
```

Still `Θ(V³)` time but with **boolean** values, so it uses `Θ(V²)` bits instead of words — and it **bitset-vectorizes**: pack row `j` into a `std::bitset<N>` and the inner loop becomes `if (t[i][k]) t[i] |= t[k];`, giving a `Θ(V³/w)` algorithm with `w = 64`. That's a 64× constant-factor win and it is the standard trick.

**Skiena's blackmail graph** is the memorable framing. *"Consider the blackmail graph, where there is a directed edge `(i,j)` if person `i` has sensitive-enough private information on person `j` so that `i` can get `j` to do whatever they want. You wish to hire one of these `n` people to be your personal representative. Who has the most power in terms of blackmail potential?"* The naive answer is the vertex of highest out-degree; the right answer is the vertex that **reaches** the most others. *"Steve might only be able to blackmail Miguel directly, but if Miguel can blackmail everyone else then Steve is the person you want to hire."*

> **Empirical check.** Over 300 random graphs, the `(∨,∧)` closure agreed exactly with BFS-from-every-vertex **and** with the `d < INF` characterization. On the blackmail graph (Steve → Miguel → everyone; a decoy vertex with out-degree 2): `outdeg(Steve) = 1` but `reach(Steve) = 6`, versus `reach(decoy) = 2` — **out-degree is the wrong metric, closure is the right one.**

### C++ Implementation

```cpp
struct APSP {
    vector<vector<long long>> d;
    vector<vector<int>> pi;                                 // -1 = NIL
};

APSP floydWarshall(const vector<vector<long long>>& W) {
    int n = (int)W.size();
    APSP a;
    a.d = W;
    a.pi.assign(n, vector<int>(n, -1));
    for (int i = 0; i < n; ++i)                             // (23.7)
        for (int j = 0; j < n; ++j)
            if (i != j && W[i][j] < INF) a.pi[i][j] = i;

    for (int k = 0; k < n; ++k)                             // (23.6) — k outermost!
        for (int i = 0; i < n; ++i) {
            if (a.d[i][k] == INF) continue;                 // prune: nothing through k
            for (int j = 0; j < n; ++j) {
                if (a.d[k][j] == INF) continue;
                long long through = a.d[i][k] + a.d[k][j];
                if (through < a.d[i][j]) {
                    a.d[i][j] = through;
                    a.pi[i][j] = a.pi[k][j];                // (23.8)
                }
            }
        }
    return a;
}

// Exercise 23.2-4: the superscripts are unnecessary — update in place.
vector<vector<long long>> floydWarshallInPlace(vector<vector<long long>> d) {
    int n = (int)d.size();
    for (int k = 0; k < n; ++k)
        for (int i = 0; i < n; ++i)
            for (int j = 0; j < n; ++j)
                if (d[i][k] != INF && d[k][j] != INF && d[i][k] + d[k][j] < d[i][j])
                    d[i][j] = d[i][k] + d[k][j];
    return d;
}

void printAllPairsPath(const APSP& a, int i, int j, vector<int>& out) {
    if (i == j) out.push_back(i);
    else if (a.pi[i][j] == -1) out.clear();                 // no path
    else { printAllPairsPath(a, i, a.pi[i][j], out); out.push_back(j); }
}

// (23.9): the same recurrence over (∨, ∧) instead of (min, +).
vector<vector<char>> transitiveClosure(const vector<vector<char>>& adj) {
    int n = (int)adj.size();
    vector<vector<char>> t = adj;
    for (int i = 0; i < n; ++i) t[i][i] = 1;
    for (int k = 0; k < n; ++k)
        for (int i = 0; i < n; ++i)
            if (t[i][k])
                for (int j = 0; j < n; ++j)
                    if (t[k][j]) t[i][j] = 1;
    return t;
}
```

**The `if (a.d[i][k] == INF) continue;` line is the single most valuable micro-optimization in Floyd–Warshall.** It hoists a test out of the inner loop and, on sparse graphs, skips the vast majority of the `n³` iterations. It also removes the overflow risk from `INF + INF`.

**Extra facts worth carrying:**

- **`d[i][i] < 0` after Floyd–Warshall ⟺ vertex `i` lies on a negative-weight cycle.** This is the cheapest global negative-cycle detector there is, and it also tells you *which* vertices are involved. (Used as the independent oracle in the Bellman-Ford `−∞` test above.)
- **Graph diameter** = `max_{i,j} d[i][j]` over finite entries. **Graph center** = `argmin_i max_j d[i][j]`.
- Replace `(min,+)` with `(max,min)` and you get the **widest path / bottleneck** matrix — the maximum over paths of the minimum edge capacity. (Connects to M14's minimum-bottleneck spanning tree.)
- Replace `(min,+)` with `(+,×)` on a DAG's adjacency matrix and you **count paths**.

---

## Part 8 — Johnson's Algorithm for Sparse Graphs (CLRS 23.3)

### Unified Understanding

**The problem:** on a sparse graph, `V` × Dijkstra (`O(VE lg V)`) crushes Floyd–Warshall (`Θ(V³)`) — but Dijkstra needs `w ≥ 0`.

**The wrong fix**, which is Exercise 23.3-4 and which everyone proposes first: let `w* = min{w(u,v)}` and set `ŵ(u,v) = w(u,v) − w*`. **This does not work**, and knowing *why* is the point of the exercise: subtracting a constant per **edge** penalizes paths with more edges. A 2-edge path loses `2w*` and a 5-edge path loses `5w*`, so the ranking changes. **Any reweighting must be path-length-independent.**

**The right fix — telescoping.** Assign each **vertex** a value `h(v)` and set

```
ŵ(u,v) = w(u,v) + h(u) − h(v)
```

Now sum along a path `p = ⟨v₀, …, v_k⟩`:

```
ŵ(p) = Σᵢ [ w(v_{i−1},vᵢ) + h(v_{i−1}) − h(vᵢ) ]
     = w(p) + h(v₀) − h(v_k)        ← every interior h cancels
```

**The correction depends only on the endpoints, not on the path.** So for a fixed `(u,v)`, *every* `u ⇝ v` path shifts by the same amount `h(u) − h(v)`, and the ranking is preserved. That is Lemma 23.1.

### Lemma 23.1

> With `ŵ(u,v) = w(u,v) + h(u) − h(v)`:
> 1. `p` is a shortest `u ⇝ v` path under `w` **iff** it is one under `ŵ`, and `δ̂(u,v) = δ(u,v) + h(u) − h(v)`.
> 2. `G` has a negative-weight cycle under `w` **iff** it does under `ŵ`.

*Proof of (1):* the telescoping computation above, applied to every path. *Proof of (2):* for a cycle `c` with `v₀ = v_k`, `ŵ(c) = w(c) + h(v₀) − h(v_k) = w(c)`. **Cycle weights are completely unchanged.** ∎

### Choosing `h` — and this is the elegant part

We need `ŵ(u,v) ≥ 0`, i.e. `w(u,v) + h(u) − h(v) ≥ 0`, i.e.

```
h(v) − h(u) ≤ w(u,v)      for every edge (u,v)
```

**That is a system of difference constraints** (§22.4) — the same object as Part 5. And Theorem 22.9 already told us a feasible solution: shortest-path weights from a super-source.

So: build `G′` = `G` plus a new vertex `s` with a weight-`0` edge to every vertex, run **Bellman-Ford** from `s`, and set `h(v) = δ(s,v)`. Then the triangle inequality gives, for every edge `(u,v)`,

```
δ(s,v) ≤ δ(s,u) + w(u,v)   ⟺   h(v) ≤ h(u) + w(u,v)   ⟺   ŵ(u,v) ≥ 0
```

**Done.** The whole non-negativity guarantee is one application of the triangle inequality. (And note `h(v) = δ(s,v) ≤ 0` always, since the `0`-weight edge `s → v` is one candidate path.)

**Why the new source `s` is necessary** (Exercise 23.3-2 / 23.3-6): to guarantee **every** vertex is reachable, so `h` is finite everywhere and Bellman-Ford sees every negative cycle. Adding `s` cannot change any `δ(u,v)` for `u,v ∈ V`, because `s` has **no incoming edges** and therefore lies on no `u ⇝ v` path. If `G` happens to be strongly connected, any vertex works as `s`.

```
JOHNSON(G, w)
1  build G′: V′ = V ∪ {s}, E′ = E ∪ {(s,v) : v ∈ V}, w(s,v) = 0
2  if BELLMAN-FORD(G′, w, s) == FALSE
3      report "negative-weight cycle"; return
4  for each v ∈ V′:  h(v) = δ(s,v)
5  for each (u,v) ∈ E′:  ŵ(u,v) = w(u,v) + h(u) − h(v)
6  for each u ∈ V
7      run DIJKSTRA(G, ŵ, u) to get δ̂(u,v) for all v
8      for each v ∈ V
9          d_uv = δ̂(u,v) + h(v) − h(u)                                   (23.11)
10 return D
```

**Line 9 undoes the reweighting.** By Lemma 23.1, `δ̂(u,v) = δ(u,v) + h(u) − h(v)`, so `δ(u,v) = δ̂(u,v) + h(v) − h(u)`. **Note the sign flip — `+h(v) − h(u)`, the reverse of the edge formula.** Getting this backwards is the classic Johnson bug.

### Complexity

| Step | Cost |
|---|---|
| Build `G′` | `Θ(V + E)` |
| Bellman-Ford on `G′` (`V+1` vertices, `E+V` edges) | `O(VE)` |
| Reweight all edges | `Θ(E)` |
| `V` × Dijkstra (Fibonacci heap) | `V · O(V lg V + E)` = **`O(V² lg V + VE)`** |
| `V` × Dijkstra (binary heap) | `V · O(E lg V)` = `O(VE lg V)` |
| Undo reweighting | `Θ(V²)` |

**Total: `O(V² lg V + VE)`** with Fibonacci heaps, `O(VE lg V)` with binary heaps. The Dijkstra phase dominates; the one Bellman-Ford run is a `O(VE)` rounding error. **Space `Θ(V²)`** for the output (unavoidable) plus `Θ(V + E)`.

**When to pick which:** `E ≈ V` ⟹ Johnson is `O(V² lg V)` vs Floyd–Warshall's `Θ(V³)` — a huge win. `E ≈ V²` ⟹ Johnson is `O(V³ lg V)` vs `Θ(V³)` — Floyd–Warshall wins, and by more than the `lg` suggests because of constants. **Crossover in practice is well below `E = V²`;** the measurement above put it comfortably between `E = 1596` and `E = 95,767` at `V = 400`.

### C++ Implementation

```cpp
bool johnson(const Graph& g, vector<vector<long long>>& D) {
    const int n = g.n;
    Graph gp(n + 1);                                        // G′ = G + super-source s
    for (const Edge& e : g.edges) gp.addEdge(e.u, e.v, e.w);
    for (int v = 0; v < n; ++v) gp.addEdge(n, v, 0);

    BellmanFordResult bf = bellmanFord(gp, n);
    if (!bf.ok) return false;                               // negative-weight cycle

    vector<long long> h(bf.r.d.begin(), bf.r.d.begin() + n);   // h(v) = δ(s, v) ≤ 0

    Graph gh(n);                                            // ŵ(u,v) = w(u,v) + h(u) − h(v) ≥ 0
    for (const Edge& e : g.edges) gh.addEdge(e.u, e.v, e.w + h[e.u] - h[e.v]);

    D.assign(n, vector<long long>(n, INF));
    for (int u = 0; u < n; ++u) {
        SSSP r = dijkstra(gh, u);
        for (int v = 0; v < n; ++v)
            if (r.d[v] != INF) D[u][v] = r.d[v] + h[v] - h[u];   // undo the reweighting
    }
    return true;
}
```

> **Empirical check.** Johnson reproduces CLRS Figure 23.4's matrix exactly. Over 400 random DAGs with weights in `[−20,20]` and 454 random cyclic graphs with negative edges (no negative cycles), `johnson` agreed with Floyd–Warshall on **every entry of every matrix**. And Lemma 23.1's two guarantees were verified directly on 108 graphs: `ŵ(u,v) ≥ 0` for **every** edge, and `h(v) ≤ 0` for **every** vertex.

**Johnson is worth studying even if you never implement it,** because it is the cleanest example in either book of a **three-technique composition**: difference constraints (§22.4) supply the reweighting scheme, Bellman-Ford (§22.1) solves for `h`, and Dijkstra (§22.3) exploits the result. The same "reweight so a faster algorithm becomes legal" pattern reappears in **min-cost max-flow** (M16), where Johnson's potentials are exactly what makes successive-shortest-paths run Dijkstra instead of Bellman-Ford.

---

## Outside / Engineering Context

*Not from Skiena or CLRS ch. 22–23; included because these come up constantly in interviews and in production routing code.*

| Technique | Idea | Cost | When |
|---|---|---|---|
| **A\*** | Dijkstra with priority `d[v] + h(v)` for an **admissible, consistent** heuristic `h` (`h(v) ≤ δ(v,t)`, `h(u) ≤ w(u,v) + h(v)`). With a consistent `h`, A\* is exactly Dijkstra on reweighted edges `w(u,v) + h(v) − h(u)` — **literally Johnson's formula**. | same bound, far fewer expansions | single-pair with geometry (maps, games); `h` = straight-line distance |
| **Bidirectional Dijkstra** | search forward from `s` and backward from `t`; stop on a correct meeting condition (not merely "they touched") | ~√ the explored area | single-pair, no heuristic available |
| **0-1 BFS** | weights only `0` or `1`: replace the heap with a **deque**, push-front for `0`, push-back for `1` | **`O(V + E)`** | grids with free/costly moves — extremely common in CP |
| **Dial's algorithm** | integer weights bounded by `C`: bucket queue with `C·V + 1` buckets | `O(E + VC)` | small integer weights |
| **`k`-ary heap** | tune `EXTRACT-MIN` `O(k log_k V)` vs `DECREASE-KEY` `O(log_k V)`; `k = E/V` balances them | `O(E log_{E/V} V)` | CLRS Problem 23-2: matches Fibonacci-heap bounds on `ε`-dense graphs without the complexity |
| **Contraction hierarchies / hub labels** | heavy preprocessing, then continent-scale queries in microseconds | preprocessing `~O(E lg V)`, query `~O(lg V)` | this is what real map services actually run |
| **Yen's algorithm** | `k` shortest **loopless** paths, by repeatedly forbidding spur edges | `O(k V (E + V lg V))` | routing alternatives |
| **Eppstein's algorithm** | `k` shortest paths allowing loops | `O(E + V lg V + k)` | theory + some CP |
| **Viterbi** | max-probability state sequence in an HMM = **shortest path in a DAG** with `−log` weights | `Θ(T · S²)` | speech, handwriting, decoding — see the war story |
| **Currency arbitrage** | maximize `Π rates` ⟹ minimize `Σ (−log rate)` ⟹ **profitable cycle = negative cycle** | `O(VE)` Bellman-Ford | the canonical negative-cycle interview question |
| **Minimum mean cycle (Karp)** | the cycle minimizing `w(c)/|c|`; a DP over `d_k(v)` = min weight of a `k`-edge walk | `O(VE)` | min-cost-to-time-ratio problems |

**The log trick is worth its own line.** `Π xᵢ` is monotone in `Σ log xᵢ`, so **any multiplicative path objective becomes additive under logs.** Maximize a product of probabilities ⟹ minimize a sum of `−log p` (all non-negative since `p ≤ 1`, so **Dijkstra applies**). Maximize a product of exchange rates ⟹ minimize `Σ −log(rate)`, where rates `> 1` give negative weights, so **Bellman-Ford applies and a negative cycle is an arbitrage**. Same trick as M14's minimum-product spanning tree.

---

## War Story: Dialing for Documents (Skiena 8.4)

The point of this story is not telephones. It is: **a problem with no distances, no map, and no graph in the statement was solved by building a graph and running a shortest-path algorithm.**

**The setup.** On an old telephone keypad each digit carries three letters. Typing one keystroke per letter is ambiguous: `2` could be A, B or C. Skiena's claim, made to an unimpressed tour guide at Periphonics: *"I'll bet that we could reconstruct English text correctly if it was typed in a telephone at one keystroke per letter."*

**Three failures before the graph.**
1. **Trigram frequencies** in a sliding window. *"The trigram statistics did a decent job of translating it into gibberish, but a terrible job of transcribing English."* No knowledge of words.
2. **Dictionary + trigrams for the rest.** But collisions are brutal — *"the code string '22737' collides with eleven distinct English words, including cases, cares, cards, capes, caper, and bases."*
3. **Dictionary + word frequency.** *"This still made too many mistakes."* No grammar.

**The graph formulation.** Working with Harald Rau and grammatical statistics from the Brown Corpus:

> *"Think of a sentence as a series of tokens, each representing a word in the sentence. Each token has a list of words from the dictionary that match it. How can we choose which one is right? Each possible sentence interpretation can be thought of as a path in a graph. Each vertex of this graph is one word from the complete set of possible word choices. There will be an edge from each possible choice for the `i`th word to each possible choice for the `(i+1)`st word. The cheapest path across this graph defines the best interpretation of the sentence."*

And then Harald's objection, which is the actual lesson:

> *"But all the paths look the same. They have the same number of edges."* — *"Exactly! The cost of an edge will reflect how likely it is that we will travel through the given pair of words. Perhaps we can count how often that pair of words occurred together in previous texts. Or we can weigh them by the part of speech of each word. Maybe nouns don't like to be next to nouns as much as they like being next to verbs."*
> *"How can we factor [word frequency] into things?"* — *"We can pay a cost for walking through a particular vertex that depends upon the frequency of the word."*

**Notice what just happened.** The graph is a **layered DAG** (layer `i` = candidate words for token `i`), so the shortest path is `Θ(V+E)` by `DAG-SHORTEST-PATHS` — no Dijkstra needed, and negative weights would be fine. Edge costs encode **transition** likelihood (bigrams, part-of-speech compatibility); vertex costs encode **emission**/prior likelihood, folded into edges by exactly the transformation of Skiena's earlier "Stop and Think." **This is a hidden Markov model, and the shortest path is the Viterbi decode.**

**The result:** *"we typically guessed about 99% of all characters correctly,"* reconstructing the Gettysburg Address with a handful of errors (BATTLEFIELD OF THAT **WAS**; FINAL **SERVING** PLACE; WHO HERE **HAVE** THEIR LIVES). Periphonics licensed it. *"The reconstruction time was faster than anyone can type text in on a phone keypad."*

**The takeaway, in Skiena's words:** *"The constraints for many pattern recognition problems can be naturally formulated as shortest-path problems in graphs… Despite the fancy name, the Viterbi algorithm is basically solving a shortest-path problem on a DAG.* **Hunting for a graph formulation to solve your problem is often the right idea.***"*

---

## Recognition Patterns

**Reach for shortest paths when you see:**

| Signal | Algorithm |
|---|---|
| "minimum cost / time / distance to get from … to …" | single-source |
| **unweighted** graph, or all weights equal | **BFS** (M13) — don't reach for Dijkstra |
| weights only `0` and `1` | **0-1 BFS** with a deque |
| non-negative weights, one source | **Dijkstra** |
| any negative weight present | **Bellman-Ford** |
| "is there an arbitrage / a profitable loop / an inconsistency" | Bellman-Ford **negative-cycle detection** |
| the graph is a **DAG** (dependencies, stages, time steps, layers) | **DAG-shortest-paths** — linear, and negatives are fine |
| "longest path" / "critical path" / "maximum score" — **on a DAG** | negate and run DAG-shortest-paths |
| "longest path" on a general graph | **NP-hard** (M19) — say so |
| all pairs, dense, `V ≲ 500` | **Floyd–Warshall** |
| all pairs, sparse, negative weights | **Johnson** |
| all pairs, sparse, non-negative | just run `V` × Dijkstra |
| "can vertex `i` reach vertex `j`" for all pairs | **transitive closure** (bitset Floyd–Warshall) |
| "diameter" / "center" / "eccentricity" | all-pairs, then reduce over the matrix |
| constraints of the form `x_j − x_i ≤ b` | **difference constraints** → constraint graph → Bellman-Ford |
| maximize a **product** along a path | take `−log`, minimize the sum |
| costs on **vertices** | move the cost onto in-edges |
| bounded number of special moves (`≤ k` refuels, teleports, discounts) | **layered graph**, `k+1` copies |
| state beyond position matters (fuel, parity, keys held, last move) | vertices = (position, state) |
| "shortest path using exactly `k` edges" | `(min,+)` matrix power `W^k` by repeated squaring, `Θ(V³ lg k)` |
| maximize the **minimum** edge on a path (widest path) | `(max,min)` semiring, or MST (M14) |
| best interpretation of a sequence under local costs | **layered DAG / Viterbi** |

---

## Common Mistakes

1. **Using Dijkstra with negative edges.** With a `visited` set it is *wrong*; without one it is *slow* (measured `Θ(V²)` pops on `Θ(V)` edges). Neither is acceptable. Use Bellman-Ford.
2. **Confusing "negative edge" with "negative cycle."** Negative edges are a solved problem. Negative cycles mean *no answer exists*.
3. **Relaxing out of an unreachable vertex.** `INF + (−5) < INF` is true. Always guard `if (d[u] == INF) continue;`.
4. **Overflow.** `INT_MAX + w` wraps around. Use `long long` and `INF = LLONG_MAX / 4`.
5. **Floyd–Warshall with `k` not outermost.** Silent wrong answers. `k` is the DP stage; `i`,`j` are the table.
6. **`0` for "no edge" in a weight matrix.** Skiena's warning: a `0` is a **free edge**, not a missing one. Use `INF`.
7. **Forgetting `d[i][i] = 0`** in the Floyd–Warshall input matrix.
8. **Getting Johnson's un-reweighting backwards.** Edges use `+h(u) − h(v)`; distances use `+h(v) − h(u)`.
9. **Reweighting by subtracting `min w`.** Ex 23.3-4 — it penalizes long paths and changes the answer.
10. **Forgetting the stale-entry check** in the lazy-heap Dijkstra, or writing `less<>` instead of `greater<>`.
11. **Assuming the SPT is the MST.** Different objectives, usually different trees.
12. **Using Dijkstra where BFS suffices.** On an unweighted graph BFS is `Θ(V+E)`; Dijkstra adds a `lg V` for nothing.
13. **Reconstructing paths without checking reachability.** Walking `π` from an unreachable `v` gives an empty or garbage path.
14. **Only detecting a negative cycle, when the problem asked you to print one.** Learn the `|V|`-steps-back trick.
15. **Trying to compute a single-pair distance "faster."** There is no known asymptotic improvement; only heuristics (A\*, bidirectional).

---

## Complexity Summary

**Single-source:**

| Algorithm | Time | Space | Negative edges | Negative cycles |
|---|---|---|---|---|
| **BFS** (unweighted) | `Θ(V + E)` | `Θ(V)` | n/a | n/a |
| **0-1 BFS** (deque) | `Θ(V + E)` | `Θ(V)` | no | n/a |
| **DAG-shortest-paths** | `Θ(V + E)` | `Θ(V)` | **yes** | impossible (acyclic) |
| **Dijkstra**, array | `Θ(V² + E)` | `Θ(V)` | **no** | no |
| **Dijkstra**, binary heap | `O((V+E) lg V)` | `Θ(V + E)` lazy | **no** | no |
| **Dijkstra**, Fibonacci heap | `O(V lg V + E)` | `Θ(V)` | **no** | no |
| **Dial** (weights `≤ C`) | `O(E + VC)` | `Θ(V + C)` | no | no |
| **Bellman-Ford** | `Θ(VE)`, `Θ(hE)` w/ early exit | `Θ(V)` | **yes** | **detects** |
| **SPFA** (queued BF) | `O(VE)` worst, fast typical | `Θ(V)` | **yes** | detects |

**All-pairs:**

| Algorithm | Time | Space | Negative edges | Notes |
|---|---|---|---|---|
| `V` × Dijkstra (heap) | `O(VE lg V)` | `Θ(V²)` | **no** | best for sparse non-negative |
| `V` × Bellman-Ford | `O(V²E)` | `Θ(V²)` | yes | the baseline to beat |
| `SLOW-APSP` (`(min,+)` powers) | `Θ(V⁴)` | `Θ(V²)` | yes | pedagogical |
| `FASTER-APSP` (repeated squaring) | `Θ(V³ lg V)` | `Θ(V²)` | yes | **but gives "exactly `k` edges" for free** |
| **Floyd–Warshall** | **`Θ(V³)`** | `Θ(V²)` | yes | tightest constants; **detects negative cycles via `d[i][i] < 0`** |
| Transitive closure `(∨,∧)` | `Θ(V³)`, `Θ(V³/64)` bitset | `Θ(V²)` bits | n/a | Warshall |
| **Johnson** | **`O(V² lg V + VE)`** Fib, `O(VE lg V)` heap | `Θ(V²)` | yes | best for **sparse** with negatives; **detects negative cycles** |

**Where the numbers come from (say these, don't memorize them):**
- Bellman-Ford `Θ(VE)`: `|V| − 1` passes because a simple path has at most `|V| − 1` edges; `|E|` relaxations per pass.
- Dijkstra: `V` extract-mins (each vertex is finalized once) + `≤ E` decrease-keys (each edge is relaxed once). Plug the queue's costs into `V·T_extract + E·T_decrease`.
- Floyd–Warshall `Θ(V³)`: `V` stages × `V²` table entries × `O(1)`.
- Johnson: one `O(VE)` Bellman-Ford + `V` Dijkstras. The Dijkstras dominate.

---

## One-Page Recall

- **`δ(u,v)`** = min weight over all `u ⇝ v` paths; `∞` if unreachable, **`−∞`** if a negative-weight cycle sits on some `u ⇝ v` walk.
- **Lemma 22.1:** subpaths of shortest paths are shortest paths. This is the optimal substructure everything rests on.
- Shortest paths may be assumed **simple**, hence `≤ |V| − 1` edges. Positive cycles never help, zero cycles never need to be used, negative cycles destroy the problem.
- **`RELAX(u,v,w)`: `if v.d > u.d + w then v.d = u.d + w; v.π = u`.** Every algorithm here is "relax edges in a good order." Always guard against relaxing out of an `∞` vertex.
- **Six properties:** triangle inequality `δ(s,v) ≤ δ(s,u)+w(u,v)`; upper-bound `v.d ≥ δ`; no-path; convergence; **path-relaxation** (relax a shortest path's edges in order ⟹ converged); predecessor-subgraph (`G_π` is an SPT).
- **Bellman-Ford:** `|V|−1` passes over all edges, then one more pass as the negative-cycle test. `Θ(VE)`. Correct because `|V|−1` passes contain every simple shortest path as an in-order subsequence (Lemma 22.15). Add the **early exit**. Negative-cycle proof = *sum the inequalities around the cycle, the `d`'s cancel, get `0 ≤ w(c) < 0`.*
- To **print** a negative cycle: after `|V|` passes take a vertex that still relaxed, walk `π` back `|V|` times (guaranteed inside the cycle), then walk until repeat. To mark **`−∞`**: flood-fill forward from every still-relaxable endpoint.
- **DAG-shortest-paths:** topological order, one pass. **`Θ(V+E)`, negative weights fine.** Negate for **longest path / critical path / PERT** — the only setting where longest path is easy.
- **Dijkstra:** greedily finalize the closest unfinalized vertex. **Needs `w ≥ 0`.** `Θ(V²)` array / `O(E lg V)` binary heap / `O(V lg V + E)` Fibonacci heap — from `V` extract-mins + `E` decrease-keys.
- **Theorem 22.6's squeeze:** `δ(s,y) ≤ δ(s,u) ≤ u.d ≤ y.d = δ(s,y)`. **Non-negativity is used in exactly one step** — `δ(s,y) ≤ δ(s,u)` for `y` earlier on the path.
- **Dijkstra vs Prim: the only difference is the key.** Prim ranks by `w(u,v)`, Dijkstra by `d[u] + w(u,v)`. Skiena: *four changed lines.*
- **Lazy decrease-key:** push on every improvement, `if (du > d[u]) continue;` on pop. Same bound, no custom heap, `Θ(E)` memory.
- **Negative edges + Dijkstra:** with a `visited` set → *wrong*; without → *correct but Bellman-Ford-slow*.
- **Design graphs, not algorithms** (Skiena). Vertex costs → in-edge weights. `k` special moves → `k+1` layers. Extra state → product graph. Products → logs.
- **Difference constraints** `x_j − xᵢ ≤ b`: edge `(vᵢ,v_j)` of weight `b`, plus super-source `v₀` with `0`-edges. Feasible ⟺ no negative cycle, and `xᵢ = δ(v₀,vᵢ)` is a solution — because **the triangle inequality *is* the constraint**. `O(nm)`.
- **`(min,+)` = tropical semiring.** `EXTEND-SHORTEST-PATHS` is matrix multiplication in it; `L^(n−1) = W^(n−1)` is the answer; repeated squaring gives `Θ(V³ lg V)` and, more usefully, "shortest walk of exactly `k` edges" in `Θ(V³ lg k)`. Swap the semiring for closure `(∨,∧)`, path counts `(+,×)`, bottlenecks `(max,min)`.
- **Floyd–Warshall:** `d_ij^(k) = min(d_ij^(k−1), d_ik^(k−1) + d_kj^(k−1))`, `k` = "intermediates allowed from `{1..k}`". **`k` OUTERMOST.** `Θ(V³)`, `Θ(V²)` space in place, tiny constants, best on dense graphs. Correct because when `k` is on the path it is an **endpoint**, not an intermediate, of each half.
- **`d[i][i] < 0` after Floyd–Warshall ⟺ `i` is on a negative cycle.** Also gives diameter, center, transitive closure (bitset it: 64×).
- **Johnson:** `ŵ(u,v) = w(u,v) + h(u) − h(v)` **telescopes**, so path weights shift by `h(u) − h(v)` regardless of length, and cycle weights don't change at all. Take `h(v) = δ(s,v)` from a super-source via Bellman-Ford; the **triangle inequality** then gives `ŵ ≥ 0`; run `V` Dijkstras; undo with `δ(u,v) = δ̂(u,v) + h(v) − h(u)`. `O(V² lg V + VE)`. **Do not** reweight by subtracting `min w`.
- **Choosing, in five seconds:** unweighted → BFS. DAG → topological. One source, `w ≥ 0` → Dijkstra. Any negative weight → Bellman-Ford. All pairs, dense → Floyd–Warshall. All pairs, sparse → Johnson (or `V` × Dijkstra if `w ≥ 0`).

---

*Next: [M16 — Network Flow & Matching](M16-flow-matching.md) (CLRS 24–25 + Skiena 8.5) — max-flow min-cut, Ford-Fulkerson and Edmonds-Karp, Dinic, and matching as a flow problem.*
