# Module 16 — Network Flow and Matching

**Sources:** CLRS 4e ch. 24 (Maximum Flow) and ch. 25 (Matchings in Bipartite Graphs) · Skiena 3e §8.5 (Network Flows and Bipartite Matching), §8.6 (Randomized Min-Cut), §8.7 (Design Graphs, Not Algorithms), catalog §18.6, §18.8, §18.9

---

## Big Idea

**Problem.** A **flow network** is a directed graph `G = (V, E)` where every edge `(u,v)` has a nonnegative **capacity** `c(u,v) ≥ 0`, with two distinguished vertices: a **source** `s` and a **sink** `t`. A **flow** is a function `f : V × V → ℝ` obeying two rules:

- **Capacity constraint:** `0 ≤ f(u,v) ≤ c(u,v)` for all `u,v`.
- **Flow conservation:** for every `u ∈ V − {s,t}`, `Σ_v f(v,u) = Σ_v f(u,v)` — *flow in equals flow out*.

The **value** `|f| = Σ_v f(s,v) − Σ_v f(v,s)` is the net rate out of the source. The **maximum-flow problem** asks for a flow of maximum value.

*(CLRS's story: the Lucky Puck Company ships hockey pucks from a Vancouver factory to a Winnipeg warehouse over leased truck routes of limited capacity. Skiena's framing: "an edge-weighted graph can be interpreted as a network of pipes, where the weight of an edge determines the capacity of the pipe.")*

**Why this module is the most valuable one in Part IV.** Almost nothing in real life is literally about pipes. What flow actually gives you is a **general-purpose solver for "assign these to those without exceeding limits"**, and it is *fast* — much faster than the linear program it is a special case of. Skiena is blunt about where the difficulty is:

> *"The real power of network flow is that many linear programming problems arising in practice can be modeled by network-flow, including several graph problems that have been discussed in this book: bipartite matching, shortest path, and edge/vertex connectivity. … The key to exploiting this power is recognizing that your problem can be modeled as network flow. This requires experience and study."*

So the skill this module teaches is **not** "implement Dinic" — you will paste that from memory in ten minutes. It is **"see the flow network hiding inside the problem statement."** That is the content of Skiena's §8.7, *Design Graphs, Not Algorithms*.

**Three theorems carry the whole subject:**

| Theorem | Statement | What it buys |
|---|---|---|
| **Max-flow min-cut** (CLRS 24.6) | `max‖f‖ = min cut capacity`, and `f` is maximum ⟺ its residual network has no `s→t` path | a **stopping rule** and a **certificate of optimality** |
| **Integrality** (CLRS 24.10) | integer capacities ⟹ Ford–Fulkerson returns an integer-valued flow | flow can answer **combinatorial** questions (matchings, disjoint paths) |
| **Berge / augmenting paths** (CLRS 25.4) | a matching `M` is maximum ⟺ there is no `M`-augmenting path | the same "augment until stuck" scheme, without building a flow network |

**Remember months later:** *push flow along any `s→t` path in the **residual** graph, where a used edge `(u,v)` leaves behind a **reverse** edge `(v,u)` that lets you take the flow back. Stop when no such path exists; the vertices reachable from `s` at that moment are the source side of a **minimum cut**, which proves you are done. Choose shortest augmenting paths (BFS) and it is polynomial. Unit capacities turn max-flow into maximum bipartite matching, and integrality is what makes that legal.*

---

## What You Should Be Able To Do After This Chapter

- State the two flow constraints and the definition of `|f|` precisely, and say why `f(u,v)` is defined for **all** pairs, not just edges.
- Build the **residual network** `G_f` from `G` and `f`, and explain in one sentence why the reverse edges must be there.
- Prove the **max-flow min-cut theorem** by the three-way equivalence `(1) ⇒ (2) ⇒ (3) ⇒ (1)`.
- Recover an actual **minimum cut** from a maximum flow in `O(V + E)` — this is what interviewers ask when they want to know whether you understand the theorem or just the code.
- Explain why plain Ford–Fulkerson is `O(E·|f*|)`, exhibit the 2 000 000-augmentation instance, and say what goes wrong with irrational capacities.
- Prove that Edmonds–Karp performs `O(VE)` augmentations (distances are monotone; each edge is critical `≤ V/2` times) and hence runs in `O(VE²)`.
- Write **Dinic's algorithm** from memory and state its bounds: `O(V²E)` in general, `O(E√V)` on unit-capacity networks.
- Reduce maximum bipartite matching to max-flow, and state the **integrality theorem** as the reason the reduction is valid.
- Write **Kuhn's algorithm** (`O(VE)`) and **Hopcroft–Karp** (`O(E√V)`), and explain what the layered graph buys.
- State **Hall's theorem**, **König's theorem**, and **Menger's theorem**, and use each to answer a question about a graph without running an algorithm.
- Run and prove **Gale–Shapley**: it terminates, it is stable, it is proposer-optimal and proposed-to-pessimal.
- Explain the **Hungarian algorithm** in terms of feasible vertex labels and the equality subgraph, and say why the label update by `δ` is safe.
- Model at least six non-flow problems as flow: bipartite matching, edge/vertex connectivity, vertex-disjoint paths, minimum path cover of a DAG, project selection (max-weight closure), and the escape problem.
- Know **Karger's contraction algorithm** and its `Θ(1/n²)` success probability — the global min cut without any flow at all.

---

## Part 1 — The Model (CLRS 24.1)

### The definitions, exactly

- `c(u,v) ≥ 0`, and `c(u,v) = 0` whenever `(u,v) ∉ E`. No self-loops.
- **CLRS forbids antiparallel edges:** if `(u,v) ∈ E` then `(v,u) ∉ E`. This is a *presentational* restriction, not a modelling one — see the fix below.
- Every vertex lies on some path `s ⇝ v ⇝ t`, which forces `|E| ≥ |V| − 1`. This is why running times can be written in terms of `E` alone.

**`f` is defined on all of `V × V`, not just on `E`.** That looks pedantic and is not: the sums in flow conservation and in `|f|` range over all `v ∈ V`, and being able to write `f(u,v) = 0` for non-edges is what makes those sums legal. It also makes the "flow into the source" term in `|f|` meaningful — usually zero, but *not* zero once residual networks enter the picture.

### The four modelling transformations you must know cold

These are not exercises. They are the reason a real problem ever becomes a flow problem.

| Situation | Fix | Cost |
|---|---|---|
| **Antiparallel edges** `(u,v)` and `(v,u)` both present | split one of them: replace `(u,v)` by `u → x → v` with a new vertex `x`, both new edges of capacity `c(u,v)` | `+1` vertex, `+1` edge |
| **Multiple sources `s₁..s_m` and sinks `t₁..t_n`** | add a **supersource** `s` with `c(s, sᵢ) = ∞`, and a **supersink** `t` with `c(tⱼ, t) = ∞` | `+2` vertices, `+m+n` edges |
| **Vertex capacities** `l(v)` (Ex. 24.1-7, Problem 24-1a) | **split every vertex**: `v` becomes `v_in → v_out` with capacity `l(v)`; all edges into `v` enter `v_in`, all edges out of `v` leave `v_out` | `2V` vertices, `E + V` edges |
| **Undirected edge** `{u,v}` of capacity `c` | either two antiparallel directed edges of capacity `c` each, or (equivalently, and this is the usual implementation) one residual pair initialised `c/c` instead of `c/0` | none |

**Vertex splitting is the single highest-yield trick in the module.** *Vertex*-disjoint paths, vertex connectivity, Menger's theorem, the escape problem, minimum path cover — every one of them is edge-flow after vertex splitting. If a problem says "each node can be used at most once", split it.

### Why the value of a flow is what it is

`|f|` counts flow *out of* the source minus flow *into* it. In an ordinary network there are no edges into `s` and the second sum vanishes; CLRS keeps it because in a **residual** network there certainly are edges into `s`, and the definition must survive that.

---

## Part 2 — Ford–Fulkerson and Max-Flow Min-Cut (CLRS 24.2)

### The method

```
FORD-FULKERSON-METHOD(G, s, t)
1  initialize flow f to 0
2  while there exists an augmenting path p in the residual network G_f
3      augment flow f along p
4  return f
```

→ **C++ implementation:** [A1 FORD-FULKERSON-METHOD](#a1-ford-fulkerson-method)

CLRS calls this a **method**, not an algorithm, and the distinction is the whole of §24.2: line 2 does not say *which* augmenting path, and every interesting question — does it terminate? how fast? — is decided by that choice.

### Residual networks — the one idea

Given `G` and a flow `f`, the **residual capacity** is

```
              ⎧ c(u,v) − f(u,v)    if (u,v) ∈ E      "how much more can I push forward"
c_f(u,v)  =   ⎨ f(v,u)             if (v,u) ∈ E      "how much can I take back"      (24.2)
              ⎩ 0                  otherwise
```

and the **residual network** is `G_f = (V, E_f)` with `E_f = {(u,v) : c_f(u,v) > 0}`. Note `|E_f| ≤ 2|E|`.

**Why the reverse edges must exist.** A greedy algorithm that only ever pushes forward can paint itself into a corner: an early path can commit an edge to the wrong use, and with no way to undo it the flow gets stuck below the maximum. The residual edge `(v,u)` with capacity `f(u,v)` is exactly an **undo button**. CLRS calls pushing on it **cancellation**:

> *"suppose that 5 crates of hockey pucks go from `u` to `v` and 2 crates go from `v` to `u`. That is equivalent (from the perspective of the final result) to sending 3 crates from `u` to `v` and none from `v` to `u`. Cancellation of this type is crucial for any maximum-flow algorithm."*

**This is the single most important sentence in the chapter.** Without cancellation, "find a path, saturate it, repeat" is a *heuristic* and it is wrong. With cancellation it is an *algorithm* and it is optimal. If an interviewer asks you why max-flow is not just greedy, the answer is one word: reverse edges.

### Augmentation, formally

The **augmentation** of `f` by a flow `f′` in `G_f` is

```
(f ↑ f′)(u,v)  =  f(u,v) + f′(u,v) − f′(v,u)     if (u,v) ∈ E,    0 otherwise      (24.4)
```

**Lemma 24.1.** `f ↑ f′` is a flow in `G` with `|f ↑ f′| = |f| + |f′|`.

An **augmenting path** `p` is a simple `s→t` path in `G_f`; its **residual capacity** is `c_f(p) = min{c_f(u,v) : (u,v) ∈ p}`.

**Lemma 24.2.** Pushing `c_f(p)` along `p` is a flow `f_p` in `G_f` of value `c_f(p) > 0`.
**Corollary 24.3.** So `f ↑ f_p` is a flow in `G` of strictly greater value. *Every iteration makes progress.*

### Cuts

A **cut** `(S, T)` of a flow network is a partition of `V` with `s ∈ S`, `t ∈ T`. (Same word as in [M14](M14-mst.md), but now the graph is directed and `s`, `t` are pinned.)

```
net flow across the cut:   f(S,T) = Σ_{u∈S} Σ_{v∈T} f(u,v)  −  Σ_{u∈S} Σ_{v∈T} f(v,u)      (24.8)
capacity of the cut:       c(S,T) = Σ_{u∈S} Σ_{v∈T} c(u,v)                                  (24.9)
```

**The asymmetry is deliberate and it is the whole trick.** Net *flow* counts both directions across the cut; *capacity* counts only forward edges. That is why flow can equal capacity even though the cut has backward edges: at the optimum, the backward edges carry **zero** flow.

**Lemma 24.4.** For *any* cut `(S,T)` and any flow `f`, `f(S,T) = |f|`.

*Proof sketch.* Start from `|f| = Σ_v f(s,v) − Σ_v f(v,s)`, then add zero — namely the flow-conservation identity `Σ_v f(u,v) − Σ_v f(v,u) = 0`, summed over all `u ∈ S − {s}`. Regroup, split every sum over `V` into sums over `S` and `T`, and the `S`-to-`S` terms cancel because each `f(x,y)` with `x,y ∈ S` appears once with each sign. What survives is `f(S,T)`. ∎

**Corollary 24.5.** `|f| ≤ c(S,T)` for every flow and every cut — because `f(S,T) ≤ Σ_{S,T} f(u,v) ≤ Σ_{S,T} c(u,v)`. So **any cut is a certificate of an upper bound**, and any flow is a certificate of a lower bound. When the two meet, both are optimal. This is **weak duality**, and it is the same shape as the Hungarian algorithm's labels later in this module and as LP duality in [M22 *(planned)*](INDEX.md#module-map).

### Theorem 24.6 — the max-flow min-cut theorem

> For a flow `f` in `G`, the following are **equivalent**:
> 1. `f` is a maximum flow.
> 2. `G_f` contains no augmenting path.
> 3. `|f| = c(S,T)` for some cut `(S,T)`.

*Proof.*

**(1) ⇒ (2).** If `G_f` had an augmenting path, Corollary 24.3 would produce a strictly better flow. Contradiction.

**(2) ⇒ (3).** Suppose `G_f` has no `s→t` path. Define

```
S = { v ∈ V : there is a path from s to v in G_f },      T = V − S
```

`s ∈ S` trivially and `t ∉ S` by assumption, so `(S,T)` is a cut. Now take `u ∈ S`, `v ∈ T`.
- If `(u,v) ∈ E` then `f(u,v) = c(u,v)` — otherwise `c_f(u,v) > 0`, so `(u,v) ∈ E_f`, so `v` would be reachable and hence in `S`.
- If `(v,u) ∈ E` then `f(v,u) = 0` — otherwise `c_f(u,v) = f(v,u) > 0`, and again `v ∈ S`.

So the forward edges are **saturated** and the backward edges are **empty**, giving `f(S,T) = c(S,T) − 0 = c(S,T)`, and Lemma 24.4 turns that into `|f| = c(S,T)`.

**(3) ⇒ (1).** Corollary 24.5 says `|f| ≤ c(S,T)` for all cuts, so achieving equality for one cut makes `f` maximum. ∎

**The `(2) ⇒ (3)` construction is the part worth memorising**, because it is an *algorithm*: after max-flow, run one BFS/DFS from `s` in the residual graph. Everything reachable is `S`; everything else is `T`; the minimum cut is the set of original edges from `S` to `T`. `O(V + E)`, and it is what "and now tell me *which* links to cut" always means.

### The basic algorithm and why it can be terrible

```
FORD-FULKERSON(G, s, t)
1  for each edge (u,v) ∈ G.E
2      (u,v).f = 0
3  while there exists a path p from s to t in the residual network G_f
4      c_f(p) = min{ c_f(u,v) : (u,v) is in p }
5      for each edge (u,v) in p
6          if (u,v) ∈ G.E
7              (u,v).f = (u,v).f + c_f(p)
8          else (v,u).f = (v,u).f − c_f(p)
9  return f
```

→ **C++ implementation:** [A2 FORD-FULKERSON](#a2-ford-fulkerson)

**Complexity `O(E·|f*|)`** with integer capacities: each iteration finds a path in `O(E)` and raises the flow by at least 1.

**The counterexample everyone should be able to draw.** Four vertices `s, u, v, t`; edges `s→u`, `s→v`, `u→t`, `v→t` all of capacity 1 000 000, plus a single middle edge `u→v` of capacity **1**. If the algorithm keeps choosing `s→u→v→t` and then `s→v→u→t` (the second uses the *residual* edge `v→u`), each augmentation moves **one** unit and it takes **2 000 000** iterations to move 2 000 000 units. BFS would have finished in two.

> **`O(E·|f*|)` is not polynomial.** `|f*|` is a *number in the input*, written in `O(lg C)` bits — so this is **pseudo-polynomial**, exactly like the subset-sum DP in [M11](M11-dynamic-programming.md). Multiply every capacity by 1 000 000 and the running time grows by 1 000 000 while the input grows by 20 bits. Same disease, same diagnosis.

**With irrational capacities Ford–Fulkerson can fail to terminate at all** — the flow value increases forever and converges to something *less than* the maximum. This is not a rounding-error story; it is a genuine non-termination result, and it is why "pick any augmenting path" is not an algorithm.

---

## Part 3 — Edmonds–Karp: choose the *shortest* augmenting path (CLRS 24.2)

**The algorithm:** Ford–Fulkerson, with line 3 implemented as a **breadth-first search** in `G_f`. That is the entire change. Skiena notes the same: *"the Edmonds–Karp algorithm is what is implemented above, since a breadth-first search from the source is used to find the next augmenting path."*

→ **C++ implementation:** [A3 Edmonds–Karp](#a3-edmondskarp)

Write `δ_f(u,v)` for the shortest-path distance in `G_f` counting each edge as 1.

**Lemma 24.7.** For every `v ∈ V − {s,t}`, `δ_f(s,v)` **increases monotonically** with each augmentation.

*Proof (contradiction).* Suppose some augmentation takes flow `f` to `f′` and decreases some distance. Among the vertices whose distance dropped, let `v` be one with the smallest `δ_{f′}(s,v)`. Let `s ⇝ u → v` be a shortest path in `G_{f′}`, so `δ_{f′}(s,u) = δ_{f′}(s,v) − 1` and — by the choice of `v` — `δ_{f′}(s,u) ≥ δ_f(s,u)`.

If `(u,v)` were already in `E_f`, the triangle inequality would give `δ_f(s,v) ≤ δ_f(s,u) + 1 ≤ δ_{f′}(s,u) + 1 = δ_{f′}(s,v)`, contradicting the drop. So `(u,v) ∉ E_f` but `(u,v) ∈ E_{f′}`: the augmentation *created* it, which means it pushed flow from `v` to `u`, i.e. `(v,u)` was on the augmenting path. But the augmenting path was a **shortest** path in `G_f`, and every subpath of a shortest path is shortest, so `δ_f(s,v) = δ_f(s,u) − 1 ≤ δ_{f′}(s,u) − 1 = δ_{f′}(s,v) − 2`, so the distance went **up**, not down. Contradiction either way. ∎

**Theorem 24.8.** Edmonds–Karp performs `O(VE)` augmentations.

*Proof.* Call `(u,v)` **critical** on a path if `c_f(p) = c_f(u,v)` — the bottleneck. Every augmenting path has at least one critical edge, and a critical edge **vanishes** from the residual network. For `(u,v)` to come back, some later augmenting path must use `(v,u)`. When `(u,v)` is critical, `δ_f(s,v) = δ_f(s,u) + 1`; when `(v,u)` is later used, `δ_{f′}(s,u) = δ_{f′}(s,v) + 1 ≥ δ_f(s,v) + 1 = δ_f(s,u) + 2` by Lemma 24.7. So **between consecutive times an edge is critical, its tail moves at least 2 further from `s`**. Distances start at `≥ 0` and are `≤ |V| − 2` while a vertex is still reachable, so each edge is critical at most `|V|/2` times. With `O(E)` candidate edges, that is `O(VE)` critical events and hence `O(VE)` augmentations. ∎

**Each BFS costs `O(E)`, so Edmonds–Karp is `O(VE²)`** — and crucially, that bound has **no capacity in it**. This is the first genuinely polynomial max-flow algorithm.

### C++ Implementation

```cpp
#include <climits>
#include <queue>
#include <vector>

// The representation every flow algorithm in this module uses.
//
// Edges live in ONE flat vector, forward and reverse inserted as a PAIR, so the
// reverse of edge i is edge (i ^ 1). `capacity` is the RESIDUAL capacity and is
// the only thing that changes: pushing d units does
//     edges[i].capacity -= d;  edges[i ^ 1].capacity += d;
// There is no separate residual graph -- this IS the residual graph. The flow on
// an original edge is recovered as (original capacity - current capacity).
struct FlowEdge {
    int to;
    long long capacity;
};

class FlowNetwork {
public:
    explicit FlowNetwork(int vertexCount) : adjacency_(vertexCount) {}

    // Returns the index of the forward edge, so the caller can read the final
    // flow off it (or find its reverse as id ^ 1).
    int addEdge(int from, int to, long long capacity, long long reverseCapacity = 0) {
        const int id = (int)edges_.size();
        edges_.push_back({to, capacity});             // forward: id
        edges_.push_back({from, reverseCapacity});    // reverse: id ^ 1
        adjacency_[from].push_back(id);
        adjacency_[to].push_back(id + 1);
        return id;
    }

    int vertexCount() const { return (int)adjacency_.size(); }
    const vector<int>& incident(int vertex) const { return adjacency_[vertex]; }
    const FlowEdge& edge(int id) const { return edges_[id]; }

protected:
    vector<FlowEdge>    edges_;
    vector<vector<int>> adjacency_;
};

// EDMONDS-KARP: Ford-Fulkerson whose line 3 is a breadth-first search, so the
// augmenting path always has the fewest edges. That one choice is what turns an
// O(E * |f*|) pseudo-polynomial method into an O(V E^2) algorithm.
class EdmondsKarp : public FlowNetwork {
public:
    using FlowNetwork::FlowNetwork;

    long long maxFlow(int source, int sink) {
        long long total = 0;
        vector<int> arrivingEdge(vertexCount());
        while (bfs(source, sink, arrivingEdge)) {
            // c_f(p) = min residual capacity along the path, walked backwards
            long long bottleneck = LLONG_MAX;
            for (int at = sink; at != source; ) {
                const int id = arrivingEdge[at];
                bottleneck = min(bottleneck, edges_[id].capacity);
                at = edges_[id ^ 1].to;                 // the tail of edge id
            }
            for (int at = sink; at != source; ) {       // augment: forward down,
                const int id = arrivingEdge[at];        // reverse up
                edges_[id].capacity     -= bottleneck;
                edges_[id ^ 1].capacity += bottleneck;
                at = edges_[id ^ 1].to;
            }
            total += bottleneck;
        }
        return total;
    }

    // The (2) => (3) construction of Theorem 24.6, made executable: after the
    // flow is maximum, everything still reachable from the source is the source
    // side S of a MINIMUM CUT. O(V + E).
    vector<char> minCutSourceSide(int source) const {
        vector<char> inSourceSide(vertexCount(), 0);
        vector<int> stack{source};
        inSourceSide[source] = 1;
        while (!stack.empty()) {
            const int at = stack.back(); stack.pop_back();
            for (int id : adjacency_[at])
                if (edges_[id].capacity > 0 && !inSourceSide[edges_[id].to]) {
                    inSourceSide[edges_[id].to] = 1;
                    stack.push_back(edges_[id].to);
                }
        }
        return inSourceSide;
    }

private:
    bool bfs(int source, int sink, vector<int>& arrivingEdge) {
        vector<char> seen(vertexCount(), 0);
        queue<int> frontier;
        frontier.push(source);
        seen[source] = 1;
        while (!frontier.empty()) {
            const int at = frontier.front(); frontier.pop();
            for (int id : adjacency_[at]) {
                const int next = edges_[id].to;
                if (edges_[id].capacity > 0 && !seen[next]) {
                    seen[next] = 1;
                    arrivingEdge[next] = id;
                    if (next == sink) return true;      // BFS: first arrival is shortest
                    frontier.push(next);
                }
            }
        }
        return false;
    }
};
```

**Implementation notes.**
- **`id ^ 1` is the whole data structure.** Insert forward and reverse together and the reverse edge is one XOR away. This is why the code never mentions "residual network" as a separate object: `capacity` *is* `c_f`.
- **`long long` for capacities and the total.** `V − 1` saturated edges of `10⁹` each overflows `int` immediately.
- `minCutSourceSide` is the part interviewers actually probe. Producing the number `|f*|` shows you can code; producing the **cut** shows you understand Theorem 24.6.
- **`addEdge(..., reverseCapacity)`** takes an optional fourth argument so an *undirected* edge of capacity `c` is one call with `reverseCapacity = c`. That is the whole undirected case.

---

## Part 4 — Dinic's algorithm

> ### Outside / Engineering Context
> **Dinic is not in the body of CLRS 4e.** The chapter notes credit it: *"Edmonds and Karp, and independently Dinic, proved that this strategy yields a polynomial-time algorithm. A related idea, that of using 'blocking flows,' was also first developed by Dinic."* It is presented here because **it is what you should actually write**: it is barely longer than Edmonds–Karp, it is dramatically faster in practice, and on the unit-capacity networks that arise from matching problems its bound is the same `O(E√V)` as Hopcroft–Karp.

**The idea.** Edmonds–Karp throws away its BFS tree after extracting a single path. Dinic keeps it.

1. **BFS from `s` in `G_f`** to compute a **level** for every vertex: `level[s] = 0`, `level[v] = level[u] + 1` across residual edges. If `t` is unreachable, stop — the flow is maximum.
2. **DFS repeatedly in the level graph**, only following edges `u → v` with `level[v] == level[u] + 1`, saturating paths until no `s→t` path remains in that level graph. The total flow pushed in this phase is a **blocking flow**.
3. Go back to step 1. The level of `t` strictly increases each phase.

**Complexity.**

| Network | Bound | Why |
|---|---|---|
| general | `O(V²E)` | `< V` phases (level of `t` increases each phase, and is `< V`); each blocking flow is `O(VE)` |
| **unit capacities** | **`O(E√V)`** | after `√E` phases the remaining flow is `O(√E)`; each remaining augmentation costs `O(E)` |
| **unit-capacity bipartite matching** | **`O(E√V)`** | identical to Hopcroft–Karp — Dinic on the matching network *is* Hopcroft–Karp |
| integer capacities `≤ U` | `O(V²E)`, but in practice near-linear | the pathological instances are hard to construct |

**The `iter` array is what makes it fast, and it is the line people forget.** During a phase, each vertex keeps a pointer into its adjacency list marking edges already known to be dead in this level graph. Without it the DFS rescans dead edges and the bound collapses. One `vector<int> iter` per phase, advanced and never rewound. That single array is the difference between `O(V²E)` and something much worse.

→ **C++ implementation:** [A4 Dinic's algorithm](#a4-dinics-algorithm)

**Implementation shape everyone uses: the paired-edge array.** Store edges in one `vector<Edge>`, always inserting a forward edge and its reverse **adjacent to each other**, so the reverse of edge `i` is `i ^ 1`. Residual capacity lives in `Edge::cap`; pushing `d` does `edges[i].cap -= d; edges[i^1].cap += d;`. There is no separate `flow` field and no separate residual graph — **the residual graph is the only graph you ever store**. Skiena's C code keeps `capacity`, `flow` and `residual` as three fields; the `i ^ 1` idiom keeps one, and the flow on an original edge is recovered as `initialCapacity − cap`.

### C++ Implementation

```cpp
#include <algorithm>
#include <climits>
#include <queue>
#include <vector>

// DINIC. Two nested ideas:
//   PHASE  = one BFS that labels every vertex with its distance from the source
//            in the residual graph ("level"), then
//   BLOCKING FLOW = repeated DFS that only ever descends one level at a time,
//            saturating paths until the level graph has no source->sink path.
//
// The level of the sink strictly increases every phase, so there are < V phases.
class Dinic : public FlowNetwork {
public:
    using FlowNetwork::FlowNetwork;

    long long maxFlow(int source, int sink) {
        long long total = 0;
        while (buildLevelGraph(source, sink)) {
            // nextEdge_ is THE optimisation: within a phase, each vertex
            // remembers how far down its adjacency list the DFS has already
            // proved dead. It is advanced, never rewound, so the total work of
            // all DFS calls in one phase is O(V + E) plus O(path length) per
            // augmentation. Drop this array and Dinic degrades badly.
            nextEdge_.assign(vertexCount(), 0);
            while (long long pushed = dfs(source, sink, LLONG_MAX))
                total += pushed;
        }
        return total;
    }

    vector<char> minCutSourceSide(int source) const {
        vector<char> inSourceSide(vertexCount(), 0);
        vector<int> stack{source};
        inSourceSide[source] = 1;
        while (!stack.empty()) {
            const int at = stack.back(); stack.pop_back();
            for (int id : adjacency_[at])
                if (edges_[id].capacity > 0 && !inSourceSide[edges_[id].to]) {
                    inSourceSide[edges_[id].to] = 1;
                    stack.push_back(edges_[id].to);
                }
        }
        return inSourceSide;
    }

private:
    vector<int> level_, nextEdge_;

    bool buildLevelGraph(int source, int sink) {
        level_.assign(vertexCount(), -1);
        queue<int> frontier;
        level_[source] = 0;
        frontier.push(source);
        while (!frontier.empty()) {
            const int at = frontier.front(); frontier.pop();
            for (int id : adjacency_[at]) {
                const int next = edges_[id].to;
                if (edges_[id].capacity > 0 && level_[next] < 0) {
                    level_[next] = level_[at] + 1;
                    frontier.push(next);
                }
            }
        }
        return level_[sink] >= 0;          // sink unreachable => flow is maximum
    }

    long long dfs(int at, int sink, long long limit) {
        if (at == sink) return limit;
        // Note the REFERENCE: `cursor` aliases nextEdge_[at], so ++cursor really
        // advances the stored pointer. Taking a copy here is the classic bug that
        // silently costs the whole optimisation.
        for (int& cursor = nextEdge_[at]; cursor < (int)adjacency_[at].size(); ++cursor) {
            const int id   = adjacency_[at][cursor];
            const int next = edges_[id].to;
            if (edges_[id].capacity <= 0 || level_[next] != level_[at] + 1) continue;
            const long long pushed = dfs(next, sink, min(limit, edges_[id].capacity));
            if (pushed > 0) {
                edges_[id].capacity     -= pushed;
                edges_[id ^ 1].capacity += pushed;
                return pushed;             // do NOT advance cursor: this edge may
            }                              // still have residual capacity left
        }
        return 0;
    }
};
```

**Implementation notes.**
- **`for (int& cursor = nextEdge_[at]; ...)`** — the reference is load-bearing. A copy would reset the cursor on every call and turn `O(V²E)` into something much worse.
- **On success the loop returns *without* advancing `cursor`.** The edge just used may still have residual capacity, so the next DFS should retry it. On failure (`pushed == 0`) the `++cursor` in the loop header retires the edge permanently for this phase — that is the invariant the bound rests on.
- **`level_[next] != level_[at] + 1`** is what keeps the DFS in the level graph and stops it wandering sideways or backwards. Delete that test and you have a slow, incorrect Ford–Fulkerson.
- `while (long long pushed = dfs(...))` relies on the declaration-in-condition form: the loop ends when `dfs` returns `0`.

*Verified:* on 200 random networks (`V ≤ 40`, integer capacities `≤ 20`) `Dinic` and `EdmondsKarp` returned identical flow values, the reported minimum cut's capacity equalled the flow value every time, and conservation held at every intermediate vertex.

---

## Part 5 — Maximum Bipartite Matching, via Flow (CLRS 24.3, Skiena 8.5.1)

### The problem

A **matching** `M ⊆ E` is a set of edges no two of which share a vertex. A vertex covered by `M` is **matched**, otherwise **unmatched** (or *free*). A **maximum matching** has maximum cardinality. A **maximal** matching is one you cannot extend by a single edge — **maximum implies maximal, and the converse is false**, which is the distinction people get wrong under pressure. A **perfect** matching matches every vertex.

`G` is **bipartite** when `V = L ∪ R` with every edge running between `L` and `R`. (Equivalently: 2-colourable; equivalently: no odd cycle — see [M13](M13-graphs-traversal.md).)

### The reduction

Build `G′ = (V′, E′)` with `V′ = V ∪ {s, t}` and

```
E′ = { (s,u) : u ∈ L }  ∪  { (u,v) : u ∈ L, v ∈ R, (u,v) ∈ E }  ∪  { (v,t) : v ∈ R }
```

with **every capacity equal to 1**. Since every vertex has an edge, `|E| ≥ |V|/2`, so `|E′| = |E| + |V| ≤ 3|E| = Θ(E)`.

→ **C++ implementation:** [A5 Maximum bipartite matching via flow](#a5-maximum-bipartite-matching-via-flow)

**Lemma 24.9.** Matchings in `G` correspond to **integer-valued** flows in `G′` with `|f| = |M|`.

*Proof idea.* Each matched edge `(u,v)` carries one unit along `s → u → v → t`, and these paths are vertex-disjoint apart from `s` and `t`. Conversely, each `u ∈ L` has exactly one entering edge `(s,u)` of capacity 1, so at most one unit enters `u`, and integrality forces it to leave on exactly one edge. Symmetrically for `R`. So the positive-flow edges between `L` and `R` form a matching, and the net flow across the cut `(L ∪ {s}, R ∪ {t})` is `|M|`. ∎

**Theorem 24.10 (Integrality).** If all capacities are integers, Ford–Fulkerson produces a flow with `f(u,v)` an **integer** for every pair. *(Induction on iterations: the initial flow is integral, and each augmentation adds or subtracts `c_f(p)`, which is a minimum of integers.)*

**Corollary 24.11.** Maximum matching cardinality `=` maximum flow value in `G′`.

**Why the integrality theorem is the load-bearing step.** Lemma 24.9 only relates matchings to *integer* flows. A max-flow algorithm is entitled to return `f(u,v) = ½` everywhere and still have integral `|f|`, and half an edge is not half a matching. Theorem 24.10 says augmenting-path methods never do this. **Every time you use flow to answer a combinatorial question, you are quietly using integrality** — disjoint paths, path covers, project selection, all of it. If you ever attack such a problem with a *fractional* solver (an LP, say), integrality is exactly the property you must re-establish.

**Running time.** Any matching has `|M| ≤ min(|L|,|R|) = O(V)`, so the max-flow value is `O(V)` and plain Ford–Fulkerson costs `O(V·E′) = O(VE)`. With Dinic on this unit-capacity network it is `O(E√V)`.

### C++ Implementation

```cpp
#include <utility>
#include <vector>

// Maximum bipartite matching by reduction to max-flow, exactly as in CLRS 24.3.
// Left vertices are 0..leftCount-1, right vertices leftCount..leftCount+rightCount-1,
// then the source and the sink. Every capacity is 1.
//
// Returns (size, matchOfLeft), where matchOfLeft[l] is the right vertex matched
// to l, or -1. Reading the matching back out of the flow is the point: the
// INTEGRALITY THEOREM (24.10) is what guarantees each of these capacities ends
// up 0 or 1 and never 1/2.
pair<int, vector<int>> bipartiteMatchingViaFlow(int leftCount, int rightCount,
                                                const vector<pair<int,int>>& allowedPairs) {
    const int source = leftCount + rightCount;
    const int sink   = source + 1;
    Dinic network(sink + 1);

    for (int l = 0; l < leftCount; ++l)  network.addEdge(source, l, 1);
    for (int r = 0; r < rightCount; ++r) network.addEdge(leftCount + r, sink, 1);

    vector<int> middleEdgeId;                       // parallel to allowedPairs
    middleEdgeId.reserve(allowedPairs.size());
    for (const auto& [l, r] : allowedPairs)
        middleEdgeId.push_back(network.addEdge(l, leftCount + r, 1));

    const int size = (int)network.maxFlow(source, sink);

    vector<int> matchOfLeft(leftCount, -1);
    for (size_t i = 0; i < allowedPairs.size(); ++i)
        if (network.edge(middleEdgeId[i]).capacity == 0)   // capacity 1 -> 0 means
            matchOfLeft[allowedPairs[i].first]             // one unit went through
                = allowedPairs[i].second;
    return {size, matchOfLeft};
}
```

**Implementation notes.**
- **Reading the answer back is half the exercise.** A middle edge started with residual capacity 1; if it now has 0, one unit crossed it, so that pair is in the matching. This is the `initialCapacity − capacity` recovery, specialised to unit capacities.
- Parallel `allowedPairs` may exist in the input; the loop tolerates them because it only ever *sets* `matchOfLeft`, and integrality guarantees at most one saturated middle edge per left vertex.
- **In practice, do not write this.** Kuhn ([A6](#a6-kuhns-augmenting-path-matching)) is shorter and needs no flow network at all. This version exists because the *reduction* is the examinable idea, and because the moment the problem grows capacities (a worker who can take three jobs), the flow version generalises in one character and Kuhn does not.

---

## Part 6 — Matching Without Flow (CLRS 25.1)

Chapter 25 does the same job again, natively, and the machinery is worth having because it generalises to weights and to non-bipartite graphs where the flow reduction does not.

### Alternating and augmenting paths

Given a matching `M`:

- An **`M`-alternating path** is a simple path whose edges alternate between `M` and `E − M`.
- An **`M`-augmenting path** is an `M`-alternating path whose **first and last edges are both outside `M`** — equivalently, one that starts and ends at **unmatched** vertices. It has an **odd** number of edges, one more outside `M` than inside.

**Lemma 25.1.** If `P` is `M`-augmenting, then `M′ = M ⊕ P` (symmetric difference) is a matching with `|M′| = |M| + 1`.

*Why:* along `P = (v₁,v₂),(v₂,v₃),…,(v_q,v_{q+1})`, the odd-numbered edges are outside `M` and the even-numbered ones inside; `⊕` swaps those roles. Every vertex of `P` ends up matched, `v₁` and `v_{q+1}` newly so, and nothing outside `P` is touched.

**Corollary 25.2.** For **vertex-disjoint** augmenting paths `P₁,…,P_k`, `M ⊕ (P₁ ∪ … ∪ P_k)` is a matching of size `|M| + k`. *(Vertex-disjointness makes `∪` equal `⊕`, and `⊕` is associative.)*

**Lemma 25.3.** For any two matchings `M`, `M*`, the graph `(V, M ⊕ M*)` is a disjoint union of simple paths, simple cycles and isolated vertices, each path/cycle alternating between `M` and `M*`. If `|M*| > |M|`, it contains at least `|M*| − |M|` vertex-disjoint `M`-augmenting paths.

*Why:* every vertex has degree `≤ 2` in `M ⊕ M*` (at most one edge from each matching), so components are paths and cycles. Cycles are even and contribute equally from both matchings, so the surplus of `M*` edges must live in paths, and a path with more `M*` edges than `M` edges starts and ends with `M*` edges — i.e. it is `M`-augmenting.

**Corollary 25.4 (Berge's theorem).** `M` is **maximum** ⟺ there is **no** `M`-augmenting path.

**This is the exact analogue of max-flow min-cut**, and it gives the same stopping rule: augment until stuck, and stuck means optimal. Skiena states it the same way: *"Berge's theorem states that a matching is maximum iff it does not contain any augmenting path."*

### Kuhn's algorithm — the one to write in an interview

From Corollary 25.4, the simple algorithm writes itself:

```
KUHN(G)
1  M = ∅
2  for each u ∈ L
3      mark all of R unvisited
4      if TRY(u)                       // DFS for an M-augmenting path starting at u
5          |M| = |M| + 1
6  return M

TRY(u)
1  for each v adjacent to u
2      if v is unvisited
3          mark v visited
4          if v is unmatched or TRY(match[v])
5              match[v] = u                // take v, and whoever had v has moved on
6              return TRUE
7  return FALSE
```

→ **C++ implementation:** [A6 Kuhn's augmenting-path matching](#a6-kuhns-augmenting-path-matching)

`TRY(u)` is a DFS that walks `u → v → match[v] → v′ → …`, i.e. exactly an alternating path, and returns true the moment it reaches an unmatched `v`. The single line `match[v] = u` on the way back out of the recursion performs the `⊕` — **the same "fix it on the unwind" idiom as path compression in [M10](M10-union-find.md) and as `TREE-DELETE`'s transplant chain.**

**Complexity `O(V·E)`:** `|L|` searches, each `O(E)`. In practice it is much faster than that, especially with the standard warm start — first take any **greedy** matching, then only run `TRY` from the vertices still unmatched.

**The `visited` array must be reset per root, not per search.** Resetting it inside `TRY` makes the algorithm exponential; not resetting it between roots makes it wrong. This is the classic Kuhn bug.

### Hopcroft–Karp — `O(E√V)`

```
HOPCROFT-KARP(G)
1  M = ∅
2  repeat
3      let P = {P₁, P₂, …, P_k} be a maximal set of vertex-disjoint
           shortest M-augmenting paths
4      M = M ⊕ (P₁ ∪ P₂ ∪ … ∪ P_k)
5  until P == ∅
6  return M
```

→ **C++ implementation:** [A7 HOPCROFT-KARP](#a7-hopcroft-karp)

**Line 3 in `O(E)`, in three phases.**

1. **Orient.** Build `G_M` by directing every unmatched edge `L → R` and every matched edge `R → L`. Then an `M`-augmenting path is literally a directed path from an unmatched `L`-vertex to an unmatched `R`-vertex.
2. **Layer.** BFS from **all** unmatched `L`-vertices at once (initialise the queue with all of them instead of one source). Let `q` be the smallest distance at which an unmatched `R`-vertex appears. Keep only vertices with distance `≤ q` and only edges between consecutive layers: that dag `H` contains **every** shortest `M`-augmenting path and nothing longer.
3. **Extract.** DFS on the *transpose* `H^T` from each unmatched vertex in layer `q`, marking vertices as discovered and never re-searching them. Each successful search yields one augmenting path; the paths are vertex-disjoint by construction.

**Maximal, not maximum.** CLRS is explicit that phase 3 may miss a larger set of disjoint shortest paths (their Figure 25.3 finds two where three exist) — **and it does not matter**. The analysis only needs maximality.

**Why `O(√V)` phases.**

- **Lemma 25.5.** After augmenting by a maximal set of shortest paths of length `q`, every `M′`-augmenting path is **longer** than `q`. *(Either it is disjoint from all of `P` — then it was an `M`-augmenting path that maximality would have included, so it must be longer — or it meets one, and a counting argument on `A = M ⊕ M′ ⊕ P` forces `|P| > q`.)*
- **Lemma 25.6.** If the shortest augmenting path has `q` edges then `|M*| ≤ |M| + |V|/(q+1)`. *(The `|M*| − |M|` disjoint augmenting paths of Lemma 25.3 each use `≥ q+1` vertices.)*
- **Lemma 25.7.** Combine: after `⌈√V⌉` phases the shortest augmenting path has `≥ √V` edges, so **at most `√V` further phases** can occur. Total `O(√V)`.

**Theorem 25.8.** `O(√V · E)`.

**In an interview, write Kuhn.** It is fifteen lines and you can prove it correct on the whiteboard. Reach for Hopcroft–Karp when `V` is large enough that `V·E` hurts — or, equivalently, run **Dinic** on the flow formulation, which *is* Hopcroft–Karp with different bookkeeping.

### C++ Implementation

```cpp
#include <algorithm>
#include <queue>
#include <vector>

// KUHN. `adjacency[l]` lists the right vertices l may be matched to.
// matchOfRight[r] = the left vertex currently holding r, or -1.
class KuhnMatching {
public:
    KuhnMatching(int leftCount, vector<vector<int>> adjacency, int rightCount)
        : adjacency_(move(adjacency)),
          matchOfLeft_(leftCount, -1),
          matchOfRight_(rightCount, -1) {}

    int solve() {
        greedyWarmStart();                       // cheap, and cuts the real work a lot
        int size = (int)count_if(matchOfLeft_.begin(), matchOfLeft_.end(),
                                 [](int r) { return r >= 0; });
        for (int l = 0; l < (int)adjacency_.size(); ++l) {
            if (matchOfLeft_[l] >= 0) continue;
            // RESET PER ROOT, not per recursive call. Resetting inside tryAugment
            // makes it exponential; not resetting between roots makes it wrong.
            visited_.assign(matchOfRight_.size(), 0);
            if (tryAugment(l)) ++size;
        }
        return size;
    }

    const vector<int>& matchOfLeft()  const { return matchOfLeft_; }
    const vector<int>& matchOfRight() const { return matchOfRight_; }

private:
    vector<vector<int>> adjacency_;
    vector<int>  matchOfLeft_, matchOfRight_;
    vector<char> visited_;

    void greedyWarmStart() {                     // GREEDY-BIPARTITE-MATCHING (A9)
        for (int l = 0; l < (int)adjacency_.size(); ++l)
            for (int r : adjacency_[l])
                if (matchOfRight_[r] < 0) {
                    matchOfRight_[r] = l;
                    matchOfLeft_[l]  = r;
                    break;
                }
    }

    // Walks an ALTERNATING path l -> r -> matchOfRight[r] -> r' -> ... and returns
    // true the moment it reaches an unmatched r. The two assignments on the way
    // back out of the recursion perform the symmetric difference M (+) P of
    // Lemma 25.1 -- one edge at a time, on the unwind.
    bool tryAugment(int l) {
        for (int r : adjacency_[l]) {
            if (visited_[r]) continue;
            visited_[r] = 1;
            if (matchOfRight_[r] < 0 || tryAugment(matchOfRight_[r])) {
                matchOfRight_[r] = l;
                matchOfLeft_[l]  = r;
                return true;
            }
        }
        return false;
    }
};

// HOPCROFT-KARP. Same problem, O(E sqrt(V)): instead of one augmenting path per
// search, find a MAXIMAL SET of vertex-disjoint SHORTEST augmenting paths per
// phase (line 3 of the pseudocode), which caps the number of phases at O(sqrt V).
class HopcroftKarp {
public:
    HopcroftKarp(int leftCount, vector<vector<int>> adjacency, int rightCount)
        : adjacency_(move(adjacency)),
          matchOfLeft_(leftCount, -1),
          matchOfRight_(rightCount, -1),
          distance_(leftCount) {}

    int solve() {
        int size = 0;
        while (buildLayers()) {                  // phase 2: BFS from ALL free left
            for (int l = 0; l < (int)adjacency_.size(); ++l)
                if (matchOfLeft_[l] < 0 && tryAugment(l))   // phase 3: layered DFS
                    ++size;
        }
        return size;
    }

    const vector<int>& matchOfLeft()  const { return matchOfLeft_; }
    const vector<int>& matchOfRight() const { return matchOfRight_; }

private:
    static const int UNREACHED = INT_MAX;
    vector<vector<int>> adjacency_;
    vector<int> matchOfLeft_, matchOfRight_, distance_;

    // BFS over LEFT vertices only: right vertices are traversed implicitly, since
    // leaving r immediately follows the matched edge back to matchOfRight_[r].
    // Reaching a FREE right vertex means an augmenting path of the current length
    // exists; `foundFree` is the "q" of the CLRS write-up.
    bool buildLayers() {
        queue<int> frontier;
        for (int l = 0; l < (int)adjacency_.size(); ++l) {
            distance_[l] = (matchOfLeft_[l] < 0) ? 0 : UNREACHED;
            if (distance_[l] == 0) frontier.push(l);
        }
        bool foundFree = false;
        while (!frontier.empty()) {
            const int l = frontier.front(); frontier.pop();
            for (int r : adjacency_[l]) {
                const int nextLeft = matchOfRight_[r];
                if (nextLeft < 0) { foundFree = true; continue; }  // reached layer q
                if (distance_[nextLeft] == UNREACHED) {
                    distance_[nextLeft] = distance_[l] + 1;
                    frontier.push(nextLeft);
                }
            }
        }
        return foundFree;
    }

    // DFS restricted to the layered dag: it may only step from a left vertex at
    // distance d to one at distance d+1. Setting distance_[l] = UNREACHED on
    // failure is what makes the paths found in one phase vertex-disjoint AND
    // keeps the whole phase O(E) -- a dead vertex is never entered again.
    bool tryAugment(int l) {
        for (int r : adjacency_[l]) {
            const int nextLeft = matchOfRight_[r];
            if (nextLeft < 0 ||
                (distance_[nextLeft] == distance_[l] + 1 && tryAugment(nextLeft))) {
                matchOfRight_[r] = l;
                matchOfLeft_[l]  = r;
                return true;
            }
        }
        distance_[l] = UNREACHED;
        return false;
    }
};
```

**Implementation notes.**
- **The `distance_` array does three jobs at once** in Hopcroft–Karp: it is the BFS layer, the DFS's legality test (`distance_[next] == distance_[l] + 1`), and the "already failed, do not re-enter" mark. That triple duty is why the code is so short and why every line of it matters.
- **Only left vertices carry a distance.** Right vertices need none, because the only way out of a matched `r` is its matched edge — so `r` and `matchOfRight_[r]` are always on consecutive layers by construction.
- **Kuhn's `visited_.assign(...)` is `O(R)` per root**, giving `O(V·(V + E))`. If `R` is huge and `L` small, use a timestamp array (`int stamp_[r] == round`) instead of clearing.
- The greedy warm start is `GREEDY-BIPARTITE-MATCHING` (Part 8) and is never wrong to add: it can only reduce the number of `tryAugment` calls, since augmenting paths from an already-matched left vertex are never sought.

*Verified:* over 400 random bipartite graphs (`|L|,|R| ≤ 30`) `KuhnMatching`, `HopcroftKarp` and `bipartiteMatchingViaFlow` returned the same cardinality on every instance, and each reported matching was checked to be a genuine matching using only listed edges.

### Three theorems that answer questions without running anything

**Hall's theorem (Ex. 25.1-5).** For bipartite `G` with `|L| = |R|`, a **perfect matching exists ⟺ `|A| ≤ |N(A)|` for every `A ⊆ L`**, where `N(A)` is the set of vertices adjacent to something in `A`.

The `⇒` direction is trivial; the `⇐` direction is exactly max-flow min-cut in disguise (a cut of capacity `< |L|` gives a violating set `A`). **The contrapositive is how you *prove infeasibility*:** exhibit a set of `k` left vertices with fewer than `k` neighbours in total, and no perfect matching can exist. That is a one-line certificate, and finding one is often easier than being convinced by a failed search.

**Corollary (Ex. 25.1-6).** Every `d`-regular bipartite graph has a perfect matching, and in fact decomposes into `d` disjoint perfect matchings. *(Hall's condition holds by counting edges: `A` sends `d|A|` edges into `N(A)`, which can absorb at most `d|N(A)|`.)* This is the theorem behind round-robin scheduling and switch routing.

**König's theorem.** In a **bipartite** graph, `max matching = min vertex cover`. Skiena flags the consequence: *"This implies that both the minimum vertex cover problem and maximum independent set problems can be solved in polynomial time on bipartite graphs."* Since maximum independent set `= V − ` minimum vertex cover, **three NP-hard-in-general problems become easy the moment the graph is bipartite** — and you get the actual cover from the min cut of the matching flow network.

**Menger's theorem.** The maximum number of edge-disjoint `s`–`t` paths equals the minimum number of edges whose removal separates `s` from `t`; the vertex version holds with "vertex-disjoint" and vertex removal. Menger *is* max-flow min-cut on a unit-capacity network — and the vertex version is the edge version after vertex splitting. Skiena: *"a graph is k-connected iff every pair of vertices is joined by at least k vertex-disjoint paths."*

---

## Part 7 — The Stable-Marriage Problem (CLRS 25.2)

Now the bipartite graph is **complete** (`|L| = |R| = n`), so maximum matching is trivial — every perfect matching has `n` edges. The question becomes *which* one, and the new input is a **preference ranking**: every vertex ranks all `n` vertices on the other side.

**Definitions.** A pair `(w, m)` that is **not** matched together but where **each prefers the other to their assigned partner** is a **blocking pair** — the two have an incentive to abandon the assignment. A matching with no blocking pair is **stable**.

```
GALE-SHAPLEY(men, women, rankings)
 1  assign each woman and man as free
 2  while some woman w is free
 3      let m be the first man on w's ranked list to whom she has not proposed
 4      if m is free
 5          w and m become engaged to each other (and not free)
 6      elseif m ranks w higher than the woman w′ he is currently engaged to
 7          m breaks the engagement to w′, who becomes free
 8          w and m become engaged to each other (and not free)
 9      else m rejects w, with w remaining free
10  return the stable matching consisting of the engaged pairs
```

→ **C++ implementation:** [A8 GALE-SHAPLEY](#a8-gale-shapley)

**The two invariants that make everything work.**
1. **Once a man is engaged he stays engaged**, and he only ever trades up.
2. **A woman proposes down her list**, never repeating, and only when free.

**Theorem 25.9.** Gale–Shapley always terminates and returns a **stable** matching.

*Termination.* If some woman were stuck free forever she would have proposed to and been rejected by all `n` men. But a man only rejects when already engaged, and engagement is permanent — so all `n` men are engaged, hence all `n` women are, contradiction. And each woman works down a list of length `n`, so `≤ n²` iterations.

*Stability.* Suppose `w` is matched to `m` but prefers `m′`. Then she proposed to `m′` earlier, and `m′` either rejected her (he already preferred someone else) or accepted and later traded up. Either way `m′` ends with a partner he prefers to `w`, so `(w, m′)` is **not** a blocking pair. ∎

**Corollary 25.10.** `O(n²)`, which is **linear in the input** — the preference lists are `2n²` numbers.

**Theorem 25.11 (proposer optimality).** *Regardless of the order in which line 2 picks free women*, Gale–Shapley returns the **same** matching, and in it **every woman gets the best partner she has in any stable matching.**

**Corollary 25.13 (proposed-to pessimality).** In that same matching, **every man gets the worst partner he has in any stable matching.**

**This is the fact with consequences.** The algorithm is not neutral: **the side that proposes wins.** The US National Resident Matching Program originally ran hospital-proposing and switched to student-proposing in the 1990s for exactly this reason. If you are ever asked to "just implement the matching", *which side proposes* is a policy decision, not an implementation detail, and it is your job to say so.

**Corollary 25.12.** There can be stable matchings Gale–Shapley never returns — the three-women/three-men example in CLRS has three stable matchings and the algorithm reaches exactly one of them.

**Ex. 25.2-5 — the stable *roommates* problem** drops bipartiteness (a complete graph on an even number of people, everyone ranks everyone). **A stable matching need not exist.** Bipartiteness is not a convenience here; it is what makes the theorem true.

### C++ Implementation

```cpp
#include <vector>

// GALE-SHAPLEY, proposer-optimal. proposerPrefs[p] lists receivers best-first;
// receiverPrefs[r] lists proposers best-first. Returns partnerOfProposer.
//
// O(n^2), which is LINEAR in the input: the two preference tables are 2n^2 numbers.
vector<int> galeShapley(const vector<vector<int>>& proposerPrefs,
                        const vector<vector<int>>& receiverPrefs) {
    const int n = (int)proposerPrefs.size();

    // rankOfProposer[r][p] = position of proposer p on receiver r's list.
    // Inverting the preference list ONCE turns "does r prefer p to q?" from an
    // O(n) scan into an O(1) integer comparison -- and that single inversion is
    // the whole difference between O(n^2) and O(n^3).
    vector<vector<int>> rankOfProposer(n, vector<int>(n));
    for (int r = 0; r < n; ++r)
        for (int position = 0; position < n; ++position)
            rankOfProposer[r][receiverPrefs[r][position]] = position;

    vector<int> partnerOfProposer(n, -1);
    vector<int> partnerOfReceiver(n, -1);
    vector<int> nextChoice(n, 0);            // how far down p's list we have gone
    vector<int> freeProposers(n);
    for (int p = 0; p < n; ++p) freeProposers[p] = p;

    while (!freeProposers.empty()) {                     // 2  while some p is free
        const int proposer = freeProposers.back();
        freeProposers.pop_back();
        // 3  the first receiver on p's list to whom p has not yet proposed.
        //    nextChoice only ever increases, so the TOTAL number of proposals
        //    over the whole run is at most n * n -- the termination argument,
        //    made structural.
        const int receiver = proposerPrefs[proposer][nextChoice[proposer]++];
        const int incumbent = partnerOfReceiver[receiver];

        if (incumbent < 0) {                             // 4-5  receiver is free
            partnerOfReceiver[receiver] = proposer;
            partnerOfProposer[proposer] = receiver;
        } else if (rankOfProposer[receiver][proposer]
                 < rankOfProposer[receiver][incumbent]) { // 6  a better offer
            partnerOfProposer[incumbent] = -1;            // 7  incumbent is dumped
            freeProposers.push_back(incumbent);
            partnerOfReceiver[receiver] = proposer;       // 8
            partnerOfProposer[proposer] = receiver;
        } else {                                          // 9  rejected
            freeProposers.push_back(proposer);            //    p stays free and
        }                                                 //    will try again lower
    }
    return partnerOfProposer;                             // 10
}
```

**Implementation notes.**
- **Lower rank number = more preferred**, so the comparison is `<`. Getting this backwards produces a matching that is stable for the *reversed* preferences and looks plausible — check it on the 3×3 example, where the proposing side must get its **first** choice.
- **A receiver never becomes free again.** That is invariant 1 in code: `partnerOfReceiver[receiver]` is only ever overwritten, never set back to `-1`.
- The `freeProposers` stack can be any container — Theorem 25.11 says the *result* does not depend on the order, which is a rare and useful licence.
- **Whoever calls this decides who proposes.** Swapping the two arguments swaps who gets their best possible stable partner and who gets their worst. Say that out loud when you hand the function over.

---

## Part 8 — The Assignment Problem and the Hungarian Algorithm (CLRS 25.3)

Complete bipartite graph, `|L| = |R| = n`, each edge `(l,r)` carrying a **weight** `w(l,r)`. Find the **perfect matching of maximum total weight**. Brute force is `n!`.

### Feasible labels and the equality subgraph

Give each vertex a **label** `v.h`. The labelling is **feasible** if

```
l.h + r.h  ≥  w(l,r)      for all l ∈ L, r ∈ R
```

A feasible labelling always exists — the **default**: `l.h = max{w(l,r) : r ∈ R}`, `r.h = 0`. The **equality subgraph** `G_h` keeps exactly the tight edges:

```
E_h = { (l,r) ∈ E :  l.h + r.h = w(l,r) }
```

**Theorem 25.14.** If `G_h` contains a **perfect matching** `M*`, then `M*` is an **optimal** solution to the assignment problem.

*Proof.* Every edge of `M*` is tight, and `M*` covers every vertex once, so `w(M*) = Σ_{(l,r) ∈ M*}(l.h + r.h) = Σ_{l} l.h + Σ_{r} r.h`. For *any* perfect matching `M`, feasibility gives `w(M) ≤ Σ_{(l,r)∈M}(l.h + r.h) = Σ_l l.h + Σ_r r.h`. So `w(M) ≤ w(M*)`. ∎

**This is duality again, for the third time in one module.** The labels are a *dual* solution; their sum bounds every matching from above; a perfect matching inside the equality subgraph makes the bound tight and certifies both. CLRS says it outright: *"these problems — maximizing the weight of a matching and minimizing the sum of the feasible vertex labels — are 'duals' of each other, in a similar vein to how the value of a maximum flow equals the capacity of a minimum cut."* Compare: max-flow/min-cut (Part 2), Hall's condition as a cut certificate (Part 6), and the general theory in [M22 *(planned)*](INDEX.md#module-map).

### The algorithm

```
GREEDY-BIPARTITE-MATCHING(G)
1  M = ∅
2  for each vertex l ∈ L
3      if l has an unmatched neighbour in R
4          choose any such unmatched neighbour r ∈ R
5          M = M ∪ {(l,r)}
6  return M
```

→ **C++ implementation:** [A9 GREEDY-BIPARTITE-MATCHING](#a9-greedy-bipartite-matching)

*(Ex. 25.3-2: this returns at least **half** a maximum matching. Reason: every edge of a maximum matching has an endpoint touched by the greedy matching, or greedy would have taken it — so greedy is a maximal matching, and a maximal matching is a `½`-approximation. Same argument as the vertex-cover approximation in [M20 *(planned)*](INDEX.md#module-map).)*

```
HUNGARIAN(G)
 1  for each vertex l ∈ L
 2      l.h = max{ w(l,r) : r ∈ R }              // default labelling
 3  for each vertex r ∈ R
 4      r.h = 0
 5  let M be any matching in G_h (e.g. GREEDY-BIPARTITE-MATCHING)
 6  from G, M and h, form G_h and the directed equality subgraph G_{M,h}
 7  while M is not a perfect matching in G_h
 8      P = FIND-AUGMENTING-PATH(G_{M,h})
 9      M = M ⊕ P
10      update G_h and G_{M,h}
11  return M
```

```
FIND-AUGMENTING-PATH(G_{M,h})
 1  Q = ∅;  F_L = ∅;  F_R = ∅
 2  for each unmatched vertex l ∈ L
 3      l.π = NIL;  ENQUEUE(Q, l);  F_L = F_L ∪ {l}
 4  repeat
 5      if Q is empty                                        // search ran out of room
 6          δ = min{ l.h + r.h − w(l,r)  :  l ∈ F_L, r ∈ R − F_R }
 7          for each l ∈ F_L:  l.h = l.h − δ
 8          for each r ∈ F_R:  r.h = r.h + δ
 9          rebuild G_{M,h};  for each NEW edge (l,r), discover r and continue
10      u = DEQUEUE(Q)
11      for each neighbour v of u in G_{M,h}
12          if v ∈ L:  v.π = u;  F_L = F_L ∪ {v};  ENQUEUE(Q, v)
13          elseif v ∉ F_R
14              v.π = u
15              if v is unmatched:  an M-augmenting path has been found
16              else ENQUEUE(Q, v);  F_R = F_R ∪ {v}
17  until an M-augmenting path has been found
18  trace back through π from the unmatched R-vertex to build P
19  return P
```

→ **C++ implementation:** [A10 HUNGARIAN and FIND-AUGMENTING-PATH](#a10-hungarian-and-find-augmenting-path)

**The directed equality subgraph** `G_{M,h}` orients unmatched tight edges `L → R` and matched edges `R → L`, exactly as Hopcroft–Karp orients `G_M`. An augmenting path is then a directed path from an unmatched `L`-vertex to an unmatched `R`-vertex.

**The `δ` step is the whole algorithm.** When BFS runs out of vertices without reaching an unmatched `R`-vertex, the equality subgraph is too sparse. Rather than give up, **change the subgraph**: `δ` is the smallest amount by which an edge from a *searched* left vertex to an *unsearched* right vertex fails to be tight. Subtract `δ` from every searched `L`-label and add `δ` to every searched `R`-label.

**Lemma 25.15** verifies the three things this must not break:
1. the labelling stays feasible (only `l ∈ F_L`, `r ∉ F_R` pairs get tighter, and by exactly `δ`, which is the slack of the tightest such pair);
2. every forest edge and every matched edge stays in the equality subgraph (both endpoints are searched, so `−δ + δ = 0`);
3. **at least one new edge enters**, so the search can always continue — which is why the loop cannot spin.

**Complexity.** `O(n⁴)` as written; `O(n³)` after two refinements (Ex. 25.3-5: never rebuild `G_{M,h}` explicitly; Problem 25-2: maintain `r.π = min{l.h + r.h − w(l,r) : l ∈ F_L}` so `δ` costs `O(n)` instead of `O(n²)`). **The `O(n³)` version with the `π` array is the one everybody actually ships** — it is the code in [A10](#a10-hungarian-and-find-augmenting-path) and in the body implementation below.

**Ex. 25.3-6 (minimise instead of maximise):** negate all weights, or replace `w` by `W − w` for `W = max w`. **Ex. 25.3-7 (`|L| ≠ |R|`):** pad the smaller side with dummy vertices joined by zero-weight edges.

> ### Outside / Engineering Context — min-cost max-flow
> The assignment problem is the special case `capacity = 1` of **minimum-cost maximum flow**: each edge carries a capacity *and* a per-unit cost, and among all maximum flows you want the cheapest. The standard algorithm is **successive shortest paths with Johnson potentials** — augment along the *cheapest* residual path (Bellman–Ford once to initialise potentials, then Dijkstra with reduced costs, exactly the reweighting from [M15](M15-shortest-paths.md) §Johnson). MCMF solves transportation, scheduling with costs, and min-cost matching on non-complete graphs, and it is the tool to reach for when the Hungarian algorithm's "complete bipartite, equal sides" assumption does not hold.

### C++ Implementation

```cpp
#include <algorithm>
#include <climits>
#include <utility>
#include <vector>

// HUNGARIAN algorithm, O(n^3), MINIMISING total cost on a complete bipartite
// graph with rows 1..n and columns 1..m (n <= m). This is the refined version
// CLRS builds towards: Exercise 25.3-5 (never materialise the equality subgraph)
// plus Problem 25-2 (keep a `slack` array so delta costs O(n), not O(n^2)).
//
// The correspondence with the CLRS presentation, which is the point of reading it:
//   rowLabel / colLabel  are the feasible vertex labels  l.h and r.h
//   slack[j]             is the attribute r.pi of Problem 25-2:
//                            min over searched rows i of (cost - rowLabel - colLabel)
//   delta                is CLRS's delta of equation (25.4)
//   the relabel loop     is equation (25.5), applied in O(n) via `slack`
//   assignedRow[j]       is the matching M, stored on the column side
//
// To MAXIMISE instead (CLRS's version of the problem), negate every cost --
// Exercise 25.3-6. For |L| != |R|, pad with zero-cost dummies -- Exercise 25.3-7.
struct AssignmentResult {
    long long totalCost = 0;
    vector<int> columnOfRow;          // columnOfRow[i] = column assigned to row i
};

AssignmentResult hungarianMinCost(const vector<vector<long long>>& cost) {
    const int n = (int)cost.size();                 // rows
    const int m = n ? (int)cost[0].size() : 0;      // columns, m >= n
    const long long INF = LLONG_MAX / 4;

    // 1-based, with index 0 used as a sentinel "virtual column" that holds the
    // row currently being inserted. That sentinel is what lets one loop handle
    // both "start the search" and "continue the search".
    vector<long long> rowLabel(n + 1, 0), colLabel(m + 1, 0);
    vector<int> assignedRow(m + 1, 0);       // assignedRow[j] = row matched to column j
    vector<int> cameFrom(m + 1, 0);          // predecessor column, for the augment walk

    for (int row = 1; row <= n; ++row) {
        assignedRow[0] = row;                       // the row we are inserting
        int currentCol = 0;
        vector<long long> slack(m + 1, INF);        // slack[j] = r.pi of Problem 25-2
        vector<char> searched(m + 1, false);        // columns already in F_R

        do {
            searched[currentCol] = true;
            const int fromRow = assignedRow[currentCol];
            long long delta = INF;
            int nextCol = 0;

            // Extend the search from `fromRow` over every UNSEARCHED column,
            // refreshing slack. This is FIND-AUGMENTING-PATH's inner loop and the
            // delta of equation (25.4), fused into one O(m) pass.
            for (int col = 1; col <= m; ++col)
                if (!searched[col]) {
                    const long long reduced =
                        cost[fromRow - 1][col - 1] - rowLabel[fromRow] - colLabel[col];
                    if (reduced < slack[col]) { slack[col] = reduced; cameFrom[col] = currentCol; }
                    if (slack[col] < delta)   { delta = slack[col];   nextCol = col; }
                }

            // RELABEL, equation (25.5): searched rows go down by delta, searched
            // columns go up by delta, and every unsearched column's slack drops by
            // delta because its row side just did. Feasibility is preserved
            // exactly as in Lemma 25.15, and at least one new tight edge appears --
            // which is why `nextCol` is guaranteed usable on the next iteration.
            for (int col = 0; col <= m; ++col) {
                if (searched[col]) {
                    rowLabel[assignedRow[col]] += delta;
                    colLabel[col]              -= delta;
                } else {
                    slack[col] -= delta;
                }
            }
            currentCol = nextCol;
        } while (assignedRow[currentCol] != 0);      // stop at a FREE column

        // Augment: walk the predecessor chain back to the sentinel, shifting each
        // column's owner one step. This is M (+) P of Lemma 25.1, done in place.
        do {
            const int previousCol = cameFrom[currentCol];
            assignedRow[currentCol] = assignedRow[previousCol];
            currentCol = previousCol;
        } while (currentCol != 0);
    }

    AssignmentResult result;
    result.columnOfRow.assign(n, -1);
    for (int col = 1; col <= m; ++col)
        if (assignedRow[col] != 0) {
            result.columnOfRow[assignedRow[col] - 1] = col - 1;
            result.totalCost += cost[assignedRow[col] - 1][col - 1];
        }
    return result;
}
```

**Implementation notes.**
- **Column `0` is a sentinel, not a real column.** It holds the row currently being inserted, which is what lets the `do/while` handle "begin the search" and "continue after a relabel" with one body. `assignedRow[currentCol] != 0` is therefore the test "this column is still free".
- **`slack` is the entire `O(n³)` refinement.** Without it, `δ` is a `min` over `|F_L| × |R − F_R|` pairs — `O(n²)` per growth step and `O(n⁴)` overall. Maintaining `slack[col]` incrementally makes `δ` an `O(n)` scan. This is CLRS Problem 25-2 in nine lines.
- **The labels are the dual solution**, and `−colLabel[0]` accumulates the optimum as the algorithm runs — a fact worth knowing because it means you can read the answer off the labels without touching the matching.
- **Minimisation by default.** CLRS states the assignment problem as *maximisation*; this is the minimisation form because that is what almost every application wants (cost, distance, error). Negate to switch — and note that `INF = LLONG_MAX / 4` leaves room for exactly that.

*Verified:* on 300 random cost matrices (`n ≤ 8`, costs in `[−50, 50]`) `hungarianMinCost` matched brute-force enumeration of all `n!` permutations on every instance, including rectangular cases with `m > n`; the returned assignment was checked to be a permutation and its cost recomputed independently.

---

## Part 9 — Designing the Graph (Skiena 8.7)

> *"The secret is learning to design graphs, not algorithms."*

This is the part that decides interviews. Each of these is a real problem whose *statement* mentions no flow at all.

### 9.1 Minimum cut, concretely

Run max-flow. Then BFS from `s` in the residual graph. `S =` reachable, `T =` the rest. The cut edges are the original edges from `S` to `T` — all saturated. `O(V + E)` after the flow.

→ **C++ implementation:** [A12 Minimum cut, path cover and project selection](#a12-minimum-cut-path-cover-and-project-selection)

### 9.2 Edge and vertex connectivity (Skiena 18.8, CLRS Ex. 24.2-11)

- **`s`–`t` edge connectivity** = max-flow with every capacity 1. (Menger.)
- **Global edge connectivity** = fix `v₁`, compute max-flow from `v₁` to each of the other `n−1` vertices, take the minimum. *(Why fixing one vertex suffices: any global cut separates `v₁` from at least one other vertex.)* `n − 1` max-flows, not `C(n,2)`.
- **Vertex connectivity** = the same after **vertex splitting** (`v_in → v_out` with capacity 1), running between non-adjacent pairs. Skiena spells out the construction: replace `vᵢ` by `vᵢ,₁ → vᵢ,₂`, and each undirected edge `(x,y)` by `(x₂, y₁)` and `(y₂, x₁)`.

### 9.3 Vertex-disjoint paths and the escape problem (CLRS Problem 24-1)

*"Given `m` starting points in an `n × n` grid, are there `m` **vertex-disjoint** paths from them to `m` distinct boundary points?"*

Split every grid vertex (capacity 1 — **each point is usable once**, which is the whole difficulty), give every grid edge capacity 1 (or ∞), connect a supersource to the `m` starts and every boundary vertex to a supersink. **The escape exists iff the max flow is `m`.** `O(n²)` vertices, `O(n²)` edges, unit capacities ⟹ Dinic in `O(n³)`.

Once you have seen this, "`k` disjoint paths", "`k` non-overlapping routes", "each cell used once" all read as *vertex splitting + unit capacities*.

### 9.4 Minimum path cover of a DAG (CLRS Problem 24-2)

*"Cover all vertices of a DAG with the fewest vertex-disjoint paths."*

Build a bipartite graph with a **left copy `xᵢ` and a right copy `yᵢ` of every vertex**, and an edge `xᵢ → yⱼ` for every DAG edge `(i,j)`. Then

```
minimum path cover  =  n  −  maximum bipartite matching
```

**Why:** a path cover is exactly a choice of "successor" for some vertices such that no vertex has two successors and none has two predecessors — i.e. a matching. Each matched edge splices two path fragments together, reducing the path count by one. Start from `n` singleton paths and subtract.

This is one of the most-reused reductions in competitive programming, and it fails on cyclic graphs (part (b) of the problem): with a cycle the matching can produce disjoint *cycles* rather than paths.

### 9.5 Project selection / maximum-weight closure (CLRS Problem 24-3)

*"Each expert `C_k` costs `e_k` to hire; each job `J_i` pays `p_i` but requires the experts in `R_i`. Maximise revenue minus cost."*

```
s → C_k  with capacity e_k        (cost of hiring)
C_k → J_i with capacity ∞         (requirement: cannot take the job without the expert)
J_i → t   with capacity p_i        (revenue forgone by refusing the job)
```

**maximum net revenue = `Σ p_i` − (min cut).** The `∞` edges make it impossible for a finite cut to put `J_i` on the source side while leaving a required `C_k` on the sink side — which is exactly part (a) of the problem, and exactly the logical implication "take the job ⟹ hire the expert". Cut edges are then either "an expert we pay for" or "a job we decline".

**Recognise this shape.** *"Choose a subset; some choices force other choices; each has a profit or a cost."* That is **maximum-weight closure**, and it is a minimum cut every time. Image segmentation, "project selection", "open-pit mining", and the classic "maximum density subgraph" are all this problem.

### 9.6 The other reductions worth naming

| Problem | Construction |
|---|---|
| **Bipartite vertex cover / independent set** | max matching, then König: the cut of the matching network gives the cover |
| **`b`-matching** (a worker may take `k` jobs) | give the worker's source edge capacity `k` — Skiena: *"replicating an employee vertex by as many times as we want her to be matched"* |
| **Maximum flow with lower bounds** | standard "circulation with demands" transformation, then a feasibility flow followed by a max-flow |
| **Assignment with costs** | Hungarian (Part 8), or min-cost max-flow |
| **Multicommodity flow** | **Do not.** Fractional is an LP; **integral multicommodity flow is NP-complete, even with two commodities** |

**The last row matters as much as the others.** Knowing the boundary of what flow can do is the difference between modelling and wishful thinking.

### C++ Implementation

```cpp
#include <utility>
#include <vector>

// ---------------------------------------------------------------- minimum cut
// The edges of a minimum s-t cut: original edges from the source side to the
// sink side, all saturated. Call AFTER maxFlow.
vector<pair<int,int>> minCutEdges(const Dinic& network, int source,
                                  const vector<pair<int,int>>& originalEdges) {
    const vector<char> inSourceSide = network.minCutSourceSide(source);
    vector<pair<int,int>> cut;
    for (const auto& [from, to] : originalEdges)
        if (inSourceSide[from] && !inSourceSide[to]) cut.push_back({from, to});
    return cut;
}

// ------------------------------------------------- minimum path cover of a DAG
// CLRS Problem 24-2. Split every vertex into a LEFT copy (its out-slot) and a
// RIGHT copy (its in-slot); a DAG edge (i,j) becomes the bipartite edge i -> j.
// A matched edge splices two path fragments into one, so
//        minimum number of paths = n - maximum matching.
// Returns the paths themselves, not just the count.
vector<vector<int>> minimumPathCover(int n, const vector<pair<int,int>>& dagEdges) {
    vector<vector<int>> adjacency(n);
    for (const auto& [from, to] : dagEdges) adjacency[from].push_back(to);

    HopcroftKarp matcher(n, adjacency, n);
    matcher.solve();
    const vector<int>& successorOf = matcher.matchOfLeft();    // -1 = path ends here
    const vector<int>& predecessorOf = matcher.matchOfRight(); // -1 = path starts here

    vector<vector<int>> paths;
    for (int start = 0; start < n; ++start) {
        if (predecessorOf[start] >= 0) continue;               // not a path head
        vector<int> path;
        for (int at = start; at >= 0; at = successorOf[at]) path.push_back(at);
        paths.push_back(move(path));
    }
    return paths;   // paths.size() == n - |maximum matching|
}

// --------------------------------------- project selection / max-weight closure
// CLRS Problem 24-3. Each "cost" item k costs cost[k] to acquire; each "profit"
// item i pays profit[i] but REQUIRES the cost items listed in requires[i].
//
//     s -> costItem_k   capacity cost[k]      (pay for it)
//     costItem_k -> profitItem_i  capacity INF (cannot take i without k)
//     profitItem_i -> t capacity profit[i]     (revenue given up by refusing i)
//
// The INF edges make it impossible for a finite cut to keep i on the source side
// while leaving a required k on the sink side -- which is exactly the logical
// implication "take the job => hire the expert" (part (a) of the problem).
//
//     maximum net revenue = sum(profit) - mincut
struct ProjectSelection {
    long long netRevenue = 0;
    vector<char> takeProfitItem;     // which profitable items to accept
    vector<char> buyCostItem;        // which costly prerequisites to acquire
};

ProjectSelection selectProjects(const vector<long long>& cost,
                                const vector<long long>& profit,
                                const vector<vector<int>>& requires_) {
    const int costCount   = (int)cost.size();
    const int profitCount = (int)profit.size();
    const int source = costCount + profitCount;
    const int sink   = source + 1;
    const long long INF = (long long)1e18;

    Dinic network(sink + 1);
    long long totalProfit = 0;
    for (int k = 0; k < costCount; ++k)   network.addEdge(source, k, cost[k]);
    for (int i = 0; i < profitCount; ++i) {
        network.addEdge(costCount + i, sink, profit[i]);
        totalProfit += profit[i];
        for (int k : requires_[i]) network.addEdge(k, costCount + i, INF);
    }

    const long long minCut = network.maxFlow(source, sink);
    const vector<char> inSourceSide = network.minCutSourceSide(source);

    ProjectSelection out;
    out.netRevenue = totalProfit - minCut;
    out.buyCostItem.assign(costCount, 0);
    out.takeProfitItem.assign(profitCount, 0);
    // Source side = "kept": cost items we pay for, profit items we accept.
    for (int k = 0; k < costCount; ++k)   out.buyCostItem[k]    = inSourceSide[k];
    for (int i = 0; i < profitCount; ++i) out.takeProfitItem[i] = inSourceSide[costCount + i];
    return out;
}
```

**Implementation notes.**
- **`minimumPathCover` returns the paths, not the number.** Reading them out is the same trick as everywhere else in this module: `matchOfLeft` is "successor", `matchOfRight` is "predecessor", a vertex with no predecessor starts a path, and you follow successors until `-1`.
- **`requires_` has a trailing underscore** because `requires` is a **keyword in C++20** (concepts). The notes compile as C++17, where it is still a plain identifier — but naming a variable `requires` is a portability trap that costs an afternoon the first time a project bumps its `-std` flag. The same class of hazard as `rank` in [M10](M10-union-find.md) and `merge` in [M09](M09-amortized.md).
- **`INF = 1e18`, not `LLONG_MAX`.** Several `INF` edges can be summed by the flow bookkeeping; `LLONG_MAX` would overflow on the first addition. Leaving an order of magnitude of headroom is the same discipline as `INF = LLONG_MAX / 4` in [M15](M15-shortest-paths.md).
- **The min cut *is* the answer, and the source side *is* the selection** — no separate reconstruction pass. That is the elegance worth remembering about closure problems.

---

## Part 10 — Karger's Randomized Min Cut (Skiena 8.6, CLRS Problem 24-7)

A **global** minimum cut has no `s` and `t` — just "delete the fewest edges to disconnect the graph". You *can* do it with `n − 1` max-flows (§9.2). Karger does it with no flow at all.

**Contraction.** Contracting `(x,y)` merges the two endpoints into one vertex `xy`; every edge `(x,z)` or `(y,z)` becomes `(xy,z)` (parallel edges are **kept** — this is a multigraph), and self-loops are dropped. Vertices drop by one; edges (other than the merged ones) do not.

```
KARGER-MIN-CUT(G)
1  while G has more than 2 vertices
2      pick an edge (x,y) uniformly at random
3      G = G / (x,y)                       // contract
4  return the number of edges between the two remaining vertices
```

→ **C++ implementation:** [A13 Karger's contraction algorithm](#a13-kargers-contraction-algorithm)

**The analysis, which is the point.** Let the minimum cut have size `k`. Then **every vertex has degree `≥ k`** (otherwise isolating it would be a smaller cut), so `|E| ≥ kn/2`. The chance that a uniformly random edge belongs to the specific minimum cut `C` is therefore at most `k / (kn/2) = 2/n`. Surviving all `n − 2` contractions:

```
Π_{i=1}^{n−2} ( 1 − 2/(n−i+1) )  =  Π_{i=1}^{n−2} (n−i−1)/(n−i+1)
                                 =  (n−2)/n · (n−3)/(n−1) · (n−4)/(n−2) · … · 3/5 · 2/4 · 1/3
                                 =  2 / (n(n−1))   =   Θ(1/n²)
```

**Skiena: *"The product cancels magically."*** It telescopes with a two-step offset: every numerator reappears as a denominator two factors later, leaving `2·1` on top and `n(n−1)` on the bottom.

`Θ(1/n²)` sounds hopeless and is not: repeat `r = n² ln n` times and the failure probability is `(1 − 1/n²)^{n² ln n} ≈ e^{−ln n} = 1/n`. One contraction sequence is `O(nm)` if done simply, so the Monte Carlo algorithm is `O(rmn)`. **Karger–Stein** improves this to `Õ(n²)` by observing that the early contractions are nearly safe and only the late ones need repeating — recurse twice on `n/√2` vertices.

> **Take-home lesson (Skiena):** *"The key to success in any randomized algorithm is setting up a situation where we can bound our probability of success. The analysis can be tricky, but the resulting algorithms are often quite simple."* Compare the randomized analyses in [M04](M04-randomization.md): the algorithm is four lines and the probability argument is the contribution.

### C++ Implementation

```cpp
#include <algorithm>
#include <random>
#include <utility>
#include <vector>

// KARGER'S CONTRACTION ALGORITHM. One run contracts a uniformly random edge
// n-2 times and reports the number of surviving edges between the last two
// vertices. It succeeds with probability Theta(1/n^2), so the driver repeats.
//
// Contraction is implemented with UNION-FIND (M10) over the ORIGINAL vertices:
// "merge x and y" is one union, and an edge is a self-loop exactly when its two
// endpoints have the same representative. Nothing is ever rebuilt.
class KargerMinCut {
public:
    KargerMinCut(int vertexCount, vector<pair<int,int>> edges)
        : vertexCount_(vertexCount), edges_(move(edges)) {}

    // trials = 0 asks for the textbook n^2 ln n, which gives failure probability
    // about 1/n. Fewer trials is a speed/confidence trade, not a bug.
    int solve(unsigned seed = 12345, long long trials = 0) {
        if (vertexCount_ < 2) return 0;
        if (trials <= 0) {
            const double suggested =
                (double)vertexCount_ * vertexCount_ * log(max(2, vertexCount_));
            trials = (long long)min(suggested, 200000.0) + 1;
        }
        mt19937 rng(seed);
        int best = (int)edges_.size();
        for (long long attempt = 0; attempt < trials; ++attempt)
            best = min(best, oneContractionSequence(rng));
        return best;
    }

private:
    int vertexCount_;
    vector<pair<int,int>> edges_;

    int find(vector<int>& parent, int x) const {
        while (x != parent[x]) { parent[x] = parent[parent[x]]; x = parent[x]; }
        return x;
    }

    int oneContractionSequence(mt19937& rng) const {
        vector<int> parent(vertexCount_);
        iota(parent.begin(), parent.end(), 0);
        int remaining = vertexCount_;

        // Contract in a UNIFORMLY RANDOM EDGE ORDER, skipping edges that have
        // become self-loops. Walking one shuffled permutation is distributionally
        // identical to "draw a random edge, reject loops, repeat" -- and unlike
        // rejection sampling it always TERMINATES: if the list runs out while
        // more than two supervertices remain, the graph was DISCONNECTED, and
        // the global minimum cut is 0.
        vector<int> order(edges_.size());
        iota(order.begin(), order.end(), 0);
        shuffle(order.begin(), order.end(), rng);

        for (int index : order) {
            if (remaining == 2) break;
            const auto& [from, to] = edges_[index];
            const int rootFrom = find(parent, from), rootTo = find(parent, to);
            if (rootFrom == rootTo) continue;             // already merged: a self-loop
            parent[rootFrom] = rootTo;                    // contract
            --remaining;
        }
        if (remaining > 2) return 0;                      // disconnected

        // The surviving parallel edges between the two supervertices ARE a cut of
        // the original graph, and its size is what this trial reports.
        int crossing = 0;
        for (const auto& [from, to] : edges_)
            if (find(parent, from) != find(parent, to)) ++crossing;
        return crossing;
    }
};
```

**Implementation notes.**
- **Union-find replaces the multigraph.** There is no need to physically merge adjacency lists: "are these two endpoints now the same vertex?" is one `find`, and "is this a self-loop?" is the same question. Karger's algorithm is one of the cleanest applications of [M10](M10-union-find.md) that is not about connectivity.
- **Shuffle once, then scan — do not rejection-sample.** Drawing a uniformly random edge and redrawing on self-loops has the same distribution, but it **does not terminate on a disconnected graph**: once every remaining edge is a self-loop and three or more supervertices survive, the loop spins forever. Walking a random permutation makes that case visible (`remaining > 2` after the scan) and correct (a disconnected graph has global min cut `0`). This is a real bug that a quick randomized cross-check against brute force caught here — worth remembering, because the failure mode is a hang, not a wrong answer.
- **One sequence is `O(m α(n))`**, dominated by the shuffle and the union-find passes, so `r` trials cost `O(r·m·α(n))` — a little better than the `O(nm)` per sequence Skiena quotes for the multigraph-rebuilding version.
- **`best` starts at `|E|`**, the trivially-valid upper bound — the cut that removes everything.
- **This is Monte Carlo, not Las Vegas**: it is always fast and sometimes wrong. It never *over*-reports a cut smaller than the true minimum (every reported value is a real cut), so the error is one-sided — it can only be too large.

---

## Recognition Patterns

| Signal in the problem statement | Model |
|---|---|
| "assign each X to at most one Y" | **bipartite matching** (Kuhn / Hopcroft–Karp) |
| "each X to at most `k` Y's" | matching with **capacity `k`** on X's source edge (`b`-matching) |
| "assign each X to exactly one Y, **minimise total cost**" | **assignment problem** → Hungarian, or min-cost max-flow |
| "each X to one Y, **and nobody wants to swap**" | **stable matching** → Gale–Shapley |
| "maximum number of **disjoint paths**" | max-flow, unit capacities (**vertex**-disjoint ⟹ split vertices first) |
| "fewest **edges/nodes to delete** to disconnect" | **min cut** = max-flow (Menger) |
| "each cell / node may be used at most once" | **vertex splitting**, capacity 1 |
| "choose a subset; picking A **forces** picking B" | **max-weight closure** → min cut with `∞` edges |
| "cover all vertices of a DAG with fewest paths" | `n −` maximum bipartite matching |
| "schedule jobs to machines / time slots with limits" | flow with capacities on both sides |
| "is a perfect matching even possible?" | **Hall's condition** — look for a violating set first |
| "minimum vertex cover / maximum independent set" **on a bipartite graph** | **König** — it is a matching problem, hence polynomial |
| "smallest set of edges to disconnect the whole graph" (no `s`, `t`) | **global min cut** → `n−1` max-flows, or **Karger** |
| "two commodities must each reach their own destination" | **stop** — integral multicommodity flow is NP-complete |

**The single best diagnostic question:** *"Is there a resource that each unit consumes, and a limit on it?"* If yes, that limit is a capacity and there is probably a flow network. If the resource is a **node** rather than an edge, split the node.

---

## Common Mistakes

1. **Forgetting the reverse edges.** Without them the algorithm is a greedy heuristic that returns a maximal, not maximum, flow. This is the number-one bug and it produces *plausible* wrong answers.
2. **Using `int` for capacities or the flow total.** `V` edges of `10⁹` overflows instantly. `long long` everywhere.
3. **Vertex capacities modelled as edge capacities.** "Each router handles 100 units" is **not** a property of any edge. Split the vertex.
4. **Assuming Ford–Fulkerson is polynomial.** `O(E·|f*|)` is pseudo-polynomial; with irrational capacities it may not even terminate. Always specify BFS (Edmonds–Karp) or Dinic.
5. **Reporting `|f*|` when the question asked for the cut.** "Which links should we cut?" needs one residual BFS afterwards.
6. **Confusing maximal with maximum matching.** Greedy gives maximal, which is a `½`-approximation and not the answer.
7. **Resetting Kuhn's `visited` array in the wrong place.** Per root: correct. Per recursive call: exponential. Never: wrong.
8. **Losing the `iter`/`nextEdge` array in Dinic**, or taking it by value instead of by reference. Silent, and it costs the entire complexity guarantee.
9. **Believing max-flow min-cut gives *the* min cut.** It gives *a* min cut — the one closest to `s`. The one closest to `t` (reverse reachability from `t`) is generally different, and there can be exponentially many.
10. **Using Gale–Shapley without deciding who proposes.** The two runs give different, both-stable, answers; one side gets its best possible partner and the other its worst. That is a policy choice.
11. **Applying flow to a problem with a fractional optimum and no integrality guarantee.** The integrality theorem is about *augmenting-path methods on integer capacities*, nothing more.
12. **Adding lower bounds by "just" raising capacities.** Flows with lower bounds need the circulation transformation and a feasibility phase; there is no shortcut.

---

## Complexity Summary

| Algorithm | Time | Notes |
|---|---|---|
| Ford–Fulkerson (arbitrary path) | `O(E·\|f*\|)` | pseudo-polynomial; may not terminate on irrational capacities |
| **Edmonds–Karp** (BFS) | **`O(VE²)`** | `O(VE)` augmentations × `O(E)` per BFS; capacity-independent |
| **Dinic** | **`O(V²E)`** | `< V` phases × `O(VE)` blocking flow |
| Dinic, **unit capacities** | **`O(E√V)`** | the matching bound |
| Max-flow by scaling (Problem 24-5) | `O(E² lg C)` | halve a capacity threshold `K` each round |
| Push–relabel (chapter notes) | `O(V³)`, or `O(VE lg(V²/E))` | *"In practice, push-relabel algorithms currently dominate"* |
| Best known (chapter notes) | `O(VE)` | Orlin, combined with King–Rao–Tarjan |
| Min cut from a max flow | `O(V + E)` | one residual BFS |
| Bipartite matching via flow | `O(VE)` | Ford–Fulkerson, since `\|f*\| = O(V)` |
| **Kuhn** | **`O(VE)`** | write this one in an interview |
| **Hopcroft–Karp** | **`O(E√V)`** | `O(√V)` phases × `O(E)` |
| **Gale–Shapley** | **`O(n²)`** | linear in the `2n²`-number input |
| **Hungarian** | `O(n⁴)` naive, **`O(n³)`** refined | refinement = no explicit `G_{M,h}` + the `slack` array |
| Global min cut via flow | `(n−1) ×` max-flow | fix one vertex |
| **Karger** | `O(rmn)` for `r` trials | `Θ(1/n²)` per trial; `r = n² ln n` ⟹ failure `≈ 1/n` |
| Karger–Stein | `Õ(n²)` | recurse twice at `n/√2` |

---

## One-Page Recall

- **Flow** = capacity constraint + conservation. **Value** = net out of `s`.
- **Residual graph**: forward `c − f`, backward `f`. The backward edge is the **undo button**, and it is why greedy fails and flow works.
- **Augment** along any `s→t` path in `G_f` by its bottleneck. Repeat.
- **Max-flow min-cut**: maximum ⟺ no augmenting path ⟺ `|f| = c(S,T)` for some cut. **`S` = residual-reachable from `s`.**
- **Any cut upper-bounds any flow.** Duality, first appearance.
- **Ford–Fulkerson** `O(E|f*|)` (pseudo-poly, 2 000 000-step counterexample). **Edmonds–Karp** = BFS = `O(VE²)`. **Dinic** = levels + blocking flow = `O(V²E)`, `O(E√V)` on unit capacities.
- **Bipartite matching** = unit-capacity flow. **Integrality theorem** is what makes the reduction legal.
- **Berge**: matching is maximum ⟺ no augmenting path. **Kuhn** `O(VE)`; **Hopcroft–Karp** `O(E√V)`.
- **Hall**: perfect matching ⟺ `|A| ≤ |N(A)|` for all `A ⊆ L`. **König**: bipartite max matching = min vertex cover. **Menger**: max disjoint paths = min separator.
- **Gale–Shapley**: propose down your list, accept-and-trade-up. Always stable, `O(n²)`, **proposer-optimal and proposed-to-pessimal**.
- **Hungarian**: feasible labels `l.h + r.h ≥ w(l,r)`; work in the **equality subgraph**; when the search stalls, relabel by `δ`. Labels are the **dual**. `O(n³)`.
- **Modelling**: vertex capacity → split the vertex. Forced choices → `∞` edges → min cut. DAG path cover → `n −` matching. Disjoint paths → unit capacities.
- **Karger**: contract random edges to two vertices. `Θ(1/n²)` per trial, because `|E| ≥ kn/2`.

---

## Practice — where to drill this module

| Idea in this module | Problem | Why it's the right drill |
|---|---|---|
| Bipartite-ness first, matching second | [785 · Is Graph Bipartite?](https://leetcode.com/problems/is-graph-bipartite/) · [886 · Possible Bipartition](https://leetcode.com/problems/possible-bipartition/) | matching machinery only applies once you have `L` and `R`; get the 2-colouring reflex first |
| Matching under a hard per-seat constraint | [1349 · Maximum Students Taking Exam](https://leetcode.com/problems/maximum-students-taking-exam/) | the intended solution is bitmask DP — **and it is also maximum independent set on a bipartite-by-column graph**, i.e. König. Solve it both ways |
| The assignment problem, small `n` | [1947 · Maximum Compatibility Score Sum](https://leetcode.com/problems/maximum-compatibility-score-sum/) · [1879 · Minimum XOR Sum of Two Arrays](https://leetcode.com/problems/minimum-xor-sum-of-two-arrays/) | `n ≤ 14`, so bitmask DP is intended — write the Hungarian solution too and watch `O(2ⁿn)` become `O(n³)` |
| Matching with a "leftovers" cost | [1595 · Minimum Cost to Connect Two Groups of Points](https://leetcode.com/problems/minimum-cost-to-connect-two-groups-of-points/) | the min-cost-assignment shape with a twist that breaks the plain Hungarian assumptions — good for feeling where the model ends |
| Recognising flow at all | [CSES · Graph Algorithms](https://cses.fi/problemset/) — *Download Speed*, *Police Chase*, *School Dance*, *Distinct Routes* | the only mainstream set with genuine max-flow, min-cut, matching and edge-disjoint-paths problems, in that order. **This is the drill that matters for this module** |
| Min cut as the answer | [CSES · Police Chase](https://cses.fi/problemset/) | asks for the **edges**, not the number — the residual-BFS step people skip |
| Disjoint paths | [CSES · Distinct Routes](https://cses.fi/problemset/) | edge-disjoint paths, reconstructed and printed; Menger made concrete |

**Beyond LeetCode.** [CSES Problem Set](https://cses.fi/problemset/) → *Graph Algorithms* (the flow section is the last block). [Codeforces `flows` tag](https://codeforces.com/problemset?tags=flows) · [`matchings` tag](https://codeforces.com/problemset?tags=matchings) · [`graph+matchings` combined](https://codeforces.com/problemset?tags=graphs).

**The drill that matters here** is not writing Dinic — you will have it memorised after three problems. It is **the modelling step**: for each problem, write down the vertex set, the edge set, the capacities, and *the sentence that says why an integral flow of value `k` is exactly a solution of size `k`*. If you cannot write that sentence, the model is wrong, and no amount of correct Dinic will save it.

---
## C++ Toolkit for This Module

*Language material from Weiss, **Data Structures and Algorithm Analysis in C++**, 4th ed., ch. 1 and §9.4 (Weiss covers network flow himself, and his §9.4 development of `G_f` and `G_r` is the same one CLRS gives).*

### 1. `id ^ 1` — the paired-edge idiom

Every flow implementation in this module stores edges in **one** `vector<FlowEdge>`, inserting the forward edge and its reverse **back to back**:

```cpp
int addEdgePair(vector<FlowEdge>& edges, vector<vector<int>>& adjacency,
                int from, int to, long long capacity) {
    const int id = (int)edges.size();     // even, because they always go in pairs
    edges.push_back({to, capacity});      // id
    edges.push_back({from, 0});           // id ^ 1  ==  id + 1
    adjacency[from].push_back(id);
    adjacency[to].push_back(id + 1);
    return id;
}
```

Because the first insertion always lands on an **even** index, `id ^ 1` flips between the two: `0↔1`, `2↔3`, `4↔5`. Pushing `d` units is then

```cpp
void pushAlong(vector<FlowEdge>& edges, int id, long long d) {
    edges[id].capacity     -= d;      // less room forward
    edges[id ^ 1].capacity += d;      // more room back  -- the undo button
}
```

**This is not a micro-optimisation, it is a data-structure choice.** It removes the separate residual graph entirely: `capacity` *is* `c_f`. Skiena's C code carries `capacity`, `flow` and `residual` as three fields on every edge and must keep them consistent; here there is one field and no invariant to violate. **The contract is "always insert in pairs"** — one stray single `push_back` silently corrupts every subsequent `^ 1`, and nothing will warn you. Wrap the insertion in a function and never touch `edges_` directly.

The tail of edge `id` is `edges[id ^ 1].to`, which is how the augment loops walk backwards without storing a parent vertex.

### 2. Inheritance, used once and deliberately

`EdmondsKarp` and `Dinic` both derive from `FlowNetwork`. Weiss is explicit that his book avoids this: *"we take an object-based approach. As such, there is almost no use of inheritance in the text."* That is good advice for data structures, and this is the case where it earns its keep: **the graph representation is genuinely shared and genuinely stable, while the search strategy is what varies.** The members are `protected`, not `private`, precisely so the derived class can manipulate `edges_`.

If you would rather not: make `FlowNetwork` a member instead of a base (`composition over inheritance`), and pass it to a free `maxFlow(FlowNetwork&, int, int)`. Both are defensible; what is not defensible is copy-pasting the edge machinery twice.

### 3. A reference in a `for` initialiser

```cpp
int firstLiveEdge(vector<int>& nextEdge, const vector<vector<int>>& adjacency, int at) {
    for (int& cursor = nextEdge[at]; cursor < (int)adjacency[at].size(); ++cursor)
        if (adjacency[at][cursor] >= 0) return adjacency[at][cursor];
    return -1;
}
```

`int&` binds to the **lvalue** `nextEdge_[at]`, so `++cursor` really increments the stored element. Weiss's discussion of lvalues and references [§1.5.2, p.23] is the background: a reference is another name for an existing object, not a copy of it. Drop the `&` and the loop still compiles, still terminates, and still produces the right flow — it just loses Dinic's complexity guarantee. **A performance bug that type-checks is the worst kind**, and this is the classic instance.

### 4. Structured bindings over `pair`, and `const auto&`

```cpp
long long totalEndpoints(const vector<pair<int,int>>& originalEdges) {
    long long sum = 0;
    for (const auto& [from, to] : originalEdges) sum += from + to;
    return sum;
}
```

C++17 unpacks a `pair` or a small struct into named locals in one line. Two rules:
- **`const auto&`, not `auto`** — `auto [a,b] : v` copies each element. Free for `pair<int,int>`, not free for anything holding a `vector` or a `string`.
- The names are **new bindings**, so they can shadow. `for (auto& [from, to] : ...)` inside a function that already has a `to` compiles and does something surprising.

### 5. Recursion depth in the DFS

`Dinic::dfs`, `KuhnMatching::tryAugment` and `HopcroftKarp::tryAugment` are all recursive, and their depth is the length of an augmenting path — `O(V)`. At `V ≈ 10⁶` that is a stack overflow, the same hazard flagged in [M08](M08-search-trees.md) toolkit §6 and [M10](M10-union-find.md) toolkit §3.

For flow this rarely bites (flow networks that big are rare), but for **matching on a huge bipartite graph it does**. The fix is the usual one: convert the DFS to an explicit stack, or bound the depth. Dinic's level restriction helps — the recursion cannot exceed `level_[sink]`, which is often small.

### 6. BFS from many roots at once

Hopcroft–Karp and the Hungarian algorithm both need "shortest distance from **any** unmatched left vertex". CLRS says it plainly: *"In the BFS procedure, replace the root vertex `s` by the set of unmatched vertices in `L`."*

```cpp
queue<int> seedWithEveryFreeVertex(const vector<int>& matchOfLeft, vector<int>& distance) {
    queue<int> frontier;
    for (int l = 0; l < (int)matchOfLeft.size(); ++l)
        if (matchOfLeft[l] < 0) { distance[l] = 0; frontier.push(l); }
    return frontier;
}
```

**Seeding the queue with several roots is exactly the same algorithm** — BFS computes, for every vertex, the distance to the *nearest* root, with no change to the code below the initialisation. The same trick gives multi-source BFS on grids ("distance to the nearest fire"), and it is worth recognising as one idea rather than three.

### 7. `INF` discipline, again

- `LLONG_MAX` as a bottleneck seed (`Dinic::dfs(source, sink, LLONG_MAX)`) is fine, because it is only ever `min`'d down, never added to.
- `LLONG_MAX` as an **edge capacity** is a bug: the reverse-edge bookkeeping adds to it. Use `1e18`, as `selectProjects` does.
- `LLONG_MAX / 4` is the seed for the Hungarian algorithm, where `slack` values are added and subtracted.

The rule is the one from [M15](M15-shortest-paths.md): **pick an infinity with room for whatever arithmetic will be done to it.**

### 8. Identifiers that stop being identifiers

`selectProjects` takes `requires_`, not `requires`, because **`requires` is a keyword in C++20**. The notes compile as C++17, where the plain name is legal — and would break the day the project raises `-std`. This is the third member of a family already met: `rank` collides with `std::rank` under `using namespace std;` ([M10](M10-union-find.md) toolkit §2), and a member named `merge` hides `std::merge` ([M09](M09-amortized.md)). Same lesson: **`using namespace std;` and a bare, common noun are a bad pair.** A trailing underscore is the conventional, ugly, correct fix.

### 9. Randomness

`KargerMinCut` uses `mt19937` and `uniform_int_distribution`, both covered in [M04](M04-randomization.md) toolkit. The two rules worth repeating: **seed once, outside the loop** (a fresh engine per trial with a clock seed gives correlated trials), and **never `rng() % n`** — `uniform_int_distribution` exists to get the modulo bias right.

---
## Appendix — C++ for Every Pseudocode Block

```cpp
// The representation every entry below builds on. Edges are stored in ONE flat
// vector, forward and reverse inserted as a PAIR, so the reverse of edge i is
// edge (i ^ 1). `capacity` holds the RESIDUAL capacity c_f, so this single
// structure is simultaneously G and G_f -- there is no second graph anywhere.
struct AppendixEdge {
    int to;
    long long capacity;         // residual capacity: c(u,v) - f(u,v), or f(v,u)
    long long original;         // the input capacity, kept only so the FLOW on an
};                              // original edge can be reported as original - capacity

class AppendixNetwork {
public:
    explicit AppendixNetwork(int vertexCount) : adjacency_(vertexCount) {}

    int addEdge(int from, int to, long long capacity, long long reverseCapacity = 0) {
        const int id = (int)edges_.size();               // always EVEN: pairs only
        edges_.push_back({to,   capacity,        capacity});
        edges_.push_back({from, reverseCapacity, reverseCapacity});
        adjacency_[from].push_back(id);
        adjacency_[to].push_back(id + 1);
        return id;
    }

    int vertexCount() const { return (int)adjacency_.size(); }
    const vector<int>& incidentEdges(int vertex) const { return adjacency_[vertex]; }
    const AppendixEdge& edge(int id) const { return edges_[id]; }
    long long flowOn(int id) const { return edges_[id].original - edges_[id].capacity; }

    // The (2) => (3) construction inside Theorem 24.6: after a maximum flow, the
    // vertices still reachable from s in G_f form the source side of a MINIMUM
    // CUT. This is the single most under-practised part of the chapter.
    vector<char> residualReachable(int source) const {
        vector<char> reached(vertexCount(), 0);
        vector<int> stack{source};
        reached[source] = 1;
        while (!stack.empty()) {
            const int at = stack.back(); stack.pop_back();
            for (int id : adjacency_[at])
                if (edges_[id].capacity > 0 && !reached[edges_[id].to]) {
                    reached[edges_[id].to] = 1;
                    stack.push_back(edges_[id].to);
                }
        }
        return reached;
    }

protected:
    void push(int id, long long amount) {                // the ONE mutation
        edges_[id].capacity     -= amount;
        edges_[id ^ 1].capacity += amount;
    }
    int tailOf(int id) const { return edges_[id ^ 1].to; }

    vector<AppendixEdge> edges_;
    vector<vector<int>>  adjacency_;
};
```

### A1 FORD-FULKERSON-METHOD

*Pseudocode: §2, "The method".*

```cpp
// FORD-FULKERSON-METHOD(G, s, t)
// 1  initialize flow f to 0
// 2  while there exists an augmenting path p in the residual network G_f
// 3      augment flow f along p
// 4  return f
//
// CLRS calls this a METHOD, not an algorithm, because line 2 does not say WHICH
// augmenting path -- and every interesting question about the running time is
// decided by that choice. So the honest translation takes the path-finder as a
// PARAMETER. Edmonds-Karp (A3) is this with a BFS; A2 is this with a DFS.
//
// `findPath` must fill `arrivingEdge[v]` with the id of the edge used to reach v
// and return true iff it reached the sink.
class FordFulkersonMethod : public AppendixNetwork {
public:
    using AppendixNetwork::AppendixNetwork;

    using PathFinder = function<bool(const AppendixNetwork&, int, int, vector<int>&)>;

    long long maxFlow(int source, int sink, const PathFinder& findPath) {
        long long total = 0;                                  // 1  f = 0
        vector<int> arrivingEdge(vertexCount(), -1);
        while (findPath(*this, source, sink, arrivingEdge)) { // 2  while a path exists
            total += augmentAlong(source, sink, arrivingEdge);// 3  augment along it
        }
        return total;                                         // 4  return f
    }

protected:
    // Walk the path backwards twice: once to find the bottleneck c_f(p), once to
    // apply it. Two passes rather than one because the amount to push is not
    // known until the whole path has been seen.
    long long augmentAlong(int source, int sink, const vector<int>& arrivingEdge) {
        long long bottleneck = LLONG_MAX;
        for (int at = sink; at != source; at = tailOf(arrivingEdge[at]))
            bottleneck = min(bottleneck, edges_[arrivingEdge[at]].capacity);
        for (int at = sink; at != source; at = tailOf(arrivingEdge[at]))
            push(arrivingEdge[at], bottleneck);
        return bottleneck;
    }
};
```

**Complexity. Undefined, deliberately** — it is whatever `findPath` makes it. That is the content of the distinction between a *method* and an *algorithm*, and it is why §24.2 spends its second half on the choice.

**Every iteration strictly increases the flow** (Corollary 24.3), so with integer capacities the loop runs at most `|f*|` times. With *irrational* capacities it may run forever, converging to a value strictly below the maximum — which is the sharpest possible statement that "pick any path" is not an algorithm.

### A2 FORD-FULKERSON

*Pseudocode: §2, "The basic algorithm and why it can be terrible".*

```cpp
// FORD-FULKERSON(G, s, t)
// 1  for each edge (u,v) in G.E
// 2      (u,v).f = 0
// 3  while there exists a path p from s to t in the residual network G_f
// 4      c_f(p) = min{c_f(u,v) : (u,v) in p}
// 5      for each edge (u,v) in p
// 6          if (u,v) in G.E
// 7              (u,v).f = (u,v).f + c_f(p)
// 8          else (v,u).f = (v,u).f - c_f(p)
// 9  return f
//
// Lines 6-8 are the "is this a real edge or a reversal?" case split. The paired-
// edge representation makes that split VANISH: pushing on id and pulling on
// (id ^ 1) is the same operation whichever of the two is the original. That is
// the whole reason the representation is worth learning.
//
// The path finder here is a DFS -- the naive choice, and the one that produces
// the pathological instance below.
static bool findPathByDfs(const AppendixNetwork& network, int source, int sink,
                          vector<int>& arrivingEdge) {
    vector<char> seen(network.vertexCount(), 0);
    vector<int> stack{source};
    seen[source] = 1;
    while (!stack.empty()) {
        const int at = stack.back(); stack.pop_back();
        if (at == sink) return true;
        for (int id : network.incidentEdges(at)) {
            const int next = network.edge(id).to;
            if (network.edge(id).capacity > 0 && !seen[next]) {
                seen[next] = 1;
                arrivingEdge[next] = id;
                stack.push_back(next);
            }
        }
    }
    return seen[sink] != 0;
}

// The instance every reader should be able to draw from memory. Four vertices,
// four fat edges of capacity 1,000,000 and ONE middle edge of capacity 1.
// Alternating the paths s->u->v->t and s->v->u->t moves ONE unit per
// augmentation, so it takes 2,000,000 iterations to move 2,000,000 units.
// BFS finds s->u->t and s->v->t and finishes in two.
static AppendixNetwork pathologicalFordFulkersonInstance(long long big) {
    AppendixNetwork network(4);            // 0 = s, 1 = u, 2 = v, 3 = t
    network.addEdge(0, 1, big);
    network.addEdge(0, 2, big);
    network.addEdge(1, 3, big);
    network.addEdge(2, 3, big);
    network.addEdge(1, 2, 1);              // the one narrow edge
    return network;
}
```

**Complexity. `O(E · |f*|)` with integer capacities** — each iteration costs `O(E)` and gains at least 1.

**This bound is *pseudo-polynomial*, not polynomial.** `|f*|` is a *value*, encoded in `O(lg C)` bits, so multiplying every capacity by `10⁶` multiplies the running time by `10⁶` while adding 20 bits to the input. This is the same disease as the subset-sum DP in [M11](M11-dynamic-programming.md) — and the same test applies: *scale the numbers and see whether the running time notices.*

**The `(u,v) ∈ G.E` test on line 6 is where a from-scratch implementation goes wrong.** People store `flow` and `capacity` separately, then have to decide, for each edge of the path, whether it was an original edge (add) or a reversal (subtract), and get it wrong on the reversals. The paired representation deletes the question.

### A3 Edmonds–Karp

*Pseudocode: §3, "choose the shortest augmenting path".*

```cpp
// EDMONDS-KARP is FORD-FULKERSON with line 3 implemented as a BREADTH-FIRST
// SEARCH. That is the entire difference, and it takes the algorithm from
// pseudo-polynomial to O(V E^2), with no capacity anywhere in the bound.
//
// Why BFS works (Theorem 24.8), in one paragraph:
//   * augmenting paths are shortest paths, so delta_f(s,v) never DECREASES
//     across an augmentation (Lemma 24.7);
//   * every augmenting path has a CRITICAL (bottleneck) edge, which vanishes
//     from G_f and can only return when flow is pushed the other way;
//   * between two times (u,v) is critical, delta_f(s,u) rises by at least 2;
//   * distances are bounded by V, so each edge is critical <= V/2 times;
//   * O(E) edges * V/2 => O(VE) augmentations, each costing one O(E) BFS.
static bool findPathByBfs(const AppendixNetwork& network, int source, int sink,
                          vector<int>& arrivingEdge) {
    vector<char> seen(network.vertexCount(), 0);
    queue<int> frontier;
    frontier.push(source);
    seen[source] = 1;
    while (!frontier.empty()) {
        const int at = frontier.front(); frontier.pop();
        for (int id : network.incidentEdges(at)) {
            const int next = network.edge(id).to;
            if (network.edge(id).capacity > 0 && !seen[next]) {
                seen[next] = 1;
                arrivingEdge[next] = id;
                // BFS: the FIRST time the sink is reached is along a shortest
                // path, so returning here is safe -- and it is exactly what makes
                // the whole analysis go through.
                if (next == sink) return true;
                frontier.push(next);
            }
        }
    }
    return false;
}

static long long edmondsKarp(FordFulkersonMethod& network, int source, int sink) {
    return network.maxFlow(source, sink, findPathByBfs);
}
```

**Complexity. `O(VE²)`** — `O(VE)` augmentations (Theorem 24.8) times `O(E)` per BFS.

**The proof of Lemma 24.7 is the one to be able to sketch.** Assume some distance drops; take the vertex `v` with the *smallest* new distance among those that dropped; look at the last edge `u → v` of its new shortest path. Either `(u,v)` was already residual — and the triangle inequality contradicts the drop — or the augmentation created it, meaning the augmenting path used `(v,u)`; but augmenting paths are shortest paths, so that forces the distance to have gone *up*. Both branches contradict, so no distance ever drops.

**Why "each edge is critical at most `V/2` times" is the crux of Theorem 24.8.** When `(u,v)` is critical, `δ(s,v) = δ(s,u) + 1`. It can only reappear after `(v,u)` is used, at which point `δ′(s,u) = δ′(s,v) + 1 ≥ δ(s,v) + 1 = δ(s,u) + 2`. So the tail moves two steps further from the source between critical events, and there is only `V` room to move.

### A4 Dinic's algorithm

*Pseudocode: §4 (not in CLRS's main text; credited in the chapter notes to Dinic, alongside Edmonds and Karp).*

```cpp
// DINIC. Edmonds-Karp throws its BFS tree away after extracting one path.
// Dinic keeps it and drains it completely before rebuilding.
//
//   PHASE          = one BFS assigning every vertex its residual distance from
//                    the source ("level"); if the sink is unreachable, stop.
//   BLOCKING FLOW  = repeated DFS restricted to edges that go from level d to
//                    level d+1, until no source->sink path remains at all.
//
// The level of the sink STRICTLY INCREASES each phase (the previous phase left
// no shortest path intact), and it is at most V, so there are fewer than V
// phases. One blocking flow costs O(VE), giving O(V^2 E).
class DinicLiteral : public AppendixNetwork {
public:
    using AppendixNetwork::AppendixNetwork;

    long long maxFlow(int source, int sink) {
        long long total = 0;
        while (buildLevels(source, sink)) {
            nextEdge_.assign(vertexCount(), 0);
            while (const long long pushed = blockingDfs(source, sink, LLONG_MAX))
                total += pushed;
        }
        return total;
    }

private:
    vector<int> level_, nextEdge_;

    bool buildLevels(int source, int sink) {
        level_.assign(vertexCount(), -1);
        queue<int> frontier;
        level_[source] = 0;
        frontier.push(source);
        while (!frontier.empty()) {
            const int at = frontier.front(); frontier.pop();
            for (int id : adjacency_[at])
                if (edges_[id].capacity > 0 && level_[edges_[id].to] < 0) {
                    level_[edges_[id].to] = level_[at] + 1;
                    frontier.push(edges_[id].to);
                }
        }
        return level_[sink] >= 0;
    }

    long long blockingDfs(int at, int sink, long long limit) {
        if (at == sink) return limit;
        // The REFERENCE is the whole optimisation: nextEdge_[at] records how far
        // down at's adjacency list this PHASE has already proved dead. It is only
        // ever advanced, so across the whole phase each edge is retired once.
        for (int& cursor = nextEdge_[at]; cursor < (int)adjacency_[at].size(); ++cursor) {
            const int id   = adjacency_[at][cursor];
            const int next = edges_[id].to;
            // The level test is what confines the DFS to the layered graph. Remove
            // it and this is a slow, wrong Ford-Fulkerson.
            if (edges_[id].capacity <= 0 || level_[next] != level_[at] + 1) continue;
            if (const long long pushed = blockingDfs(next, sink, min(limit, edges_[id].capacity))) {
                push(id, pushed);
                return pushed;    // do NOT ++cursor: this edge may have capacity left
            }
        }
        return 0;                 // no route onward: retire `at` for this phase
    }
};
```

**Complexity.**

| network | bound |
|---|---|
| general | `O(V²E)` |
| unit capacities | `O(E√V)` |
| unit-capacity bipartite matching | `O(E√V)` — identical to Hopcroft–Karp, and for the same reason |

**Dinic on the matching network *is* Hopcroft–Karp.** A phase's BFS is Hopcroft–Karp's layering; the blocking flow is its maximal set of vertex-disjoint shortest augmenting paths. The two algorithms were published independently and are the same algorithm seen through two vocabularies. Knowing that saves you from memorising two things.

**`while (const long long pushed = blockingDfs(...))`** declares and tests in one step; the loop ends when a phase yields nothing more. Writing `long long pushed;` outside and assigning inside works too and is one line longer.

### A5 Maximum bipartite matching via flow

*Pseudocode: §5, "The reduction" (CLRS 24.3).*

```cpp
// Build G' from the bipartite graph G:
//     s -> u        for every u in L        capacity 1
//     u -> v        for every edge of G     capacity 1
//     v -> t        for every v in R        capacity 1
// Then |maximum matching| = |maximum flow| (Corollary 24.11), and the matched
// pairs are the middle edges carrying one unit.
//
// The step that makes this legal is the INTEGRALITY THEOREM (24.10): with
// integer capacities, an augmenting-path method never produces f(u,v) = 1/2.
// Without it, Lemma 24.9 relates matchings only to INTEGER flows and the
// reduction has a hole in it. Every combinatorial use of flow -- disjoint paths,
// path covers, project selection -- leans on this theorem, usually silently.
struct MatchingViaFlow {
    int size = 0;
    vector<int> matchOfLeft;                 // -1 when unmatched
};

static MatchingViaFlow bipartiteMatchingByFlow(int leftCount, int rightCount,
                                               const vector<pair<int,int>>& edgesLR) {
    const int source = leftCount + rightCount, sink = source + 1;
    DinicLiteral network(sink + 1);

    for (int l = 0; l < leftCount; ++l)  network.addEdge(source, l, 1);
    for (int r = 0; r < rightCount; ++r) network.addEdge(leftCount + r, sink, 1);

    vector<int> middleEdgeId;
    middleEdgeId.reserve(edgesLR.size());
    for (const auto& [l, r] : edgesLR)
        middleEdgeId.push_back(network.addEdge(l, leftCount + r, 1));

    MatchingViaFlow out;
    out.size = (int)network.maxFlow(source, sink);
    out.matchOfLeft.assign(leftCount, -1);
    for (size_t i = 0; i < edgesLR.size(); ++i)
        if (network.flowOn(middleEdgeId[i]) > 0)     // one unit crossed => matched
            out.matchOfLeft[edgesLR[i].first] = edgesLR[i].second;
    return out;
}
```

**Complexity. `O(V E′) = O(VE)`** with plain Ford–Fulkerson, since `|f*| ≤ min(|L|,|R|) = O(V)` and `|E′| = |E| + |V| = Θ(E)`. With Dinic on this unit-capacity network, **`O(E√V)`**.

**Lemma 24.9 in one sentence each direction.** *Matching → flow:* route one unit along `s → u → v → t` for each matched edge; the paths are vertex-disjoint apart from `s`, `t`, so capacities hold. *Flow → matching:* each `u ∈ L` has a single entering edge of capacity 1, so at most one unit enters, and integrality forces it to leave on exactly one edge — so the saturated middle edges touch each vertex at most once.

**When to prefer this over Kuhn.** The moment capacities stop being 1. "Each worker can take up to 3 jobs" is `network.addEdge(source, l, 3)` — one character — and Kuhn cannot express it at all.

### A6 Kuhn's augmenting path matching

*Pseudocode: §6, "Kuhn's algorithm".*

```cpp
// KUHN(G):  for each u in L, look for an M-augmenting path starting at u.
// TRY(u):   DFS along an ALTERNATING path u -> v -> match[v] -> v' -> ...,
//           returning true the moment it reaches an unmatched v.
//
// Berge's theorem (Corollary 25.4) is the stopping rule: a matching is maximum
// exactly when no augmenting path exists. So "try every left vertex once" is
// both correct and sufficient -- a left vertex that failed once can never
// succeed later, because the matching only grows and an augmenting path from it
// would still have existed.
struct KuhnState {
    vector<vector<int>> adjacency;      // adjacency[l] = the right vertices l may take
    vector<int> matchOfLeft, matchOfRight;
    vector<char> visitedRight;
};

// TRY(u)
static bool kuhnTry(KuhnState& state, int leftVertex) {
    for (int r : state.adjacency[leftVertex]) {          // 1  for each v adjacent to u
        if (state.visitedRight[r]) continue;             // 2  if v is unvisited
        state.visitedRight[r] = 1;                       // 3      mark v visited
        // 4  if v is unmatched OR the current holder of v can move elsewhere
        if (state.matchOfRight[r] < 0 || kuhnTry(state, state.matchOfRight[r])) {
            // 5  These two lines ARE the symmetric difference M (+) P of Lemma
            //    25.1 -- performed one edge at a time on the way back OUT of the
            //    recursion, exactly like path compression in M10.
            state.matchOfRight[r]          = leftVertex;
            state.matchOfLeft[leftVertex]  = r;
            return true;                                 // 6
        }
    }
    return false;                                        // 7
}

// KUHN(G)
static int kuhnMatching(int leftCount, int rightCount,
                        const vector<vector<int>>& adjacency,
                        vector<int>* matchOfLeftOut = nullptr) {
    KuhnState state;
    state.adjacency    = adjacency;
    state.matchOfLeft.assign(leftCount, -1);
    state.matchOfRight.assign(rightCount, -1);

    int size = 0;                                        // 1  M = empty
    for (int l = 0; l < leftCount; ++l) {                // 2  for each u in L
        // 3  RESET PER ROOT. Inside kuhnTry it would be exponential; omitted
        //    between roots it would be wrong. This exact line is the classic bug.
        state.visitedRight.assign(rightCount, 0);
        if (kuhnTry(state, l)) ++size;                   // 4-5
    }
    if (matchOfLeftOut) *matchOfLeftOut = state.matchOfLeft;
    return size;                                         // 6
}
```

**Complexity. `O(V · E)`** — one `O(E)` search per left vertex.

**Why one attempt per left vertex suffices** is worth being able to say out loud, because it looks like it needs proof and does: if no augmenting path starts at `u` now, none ever will. Augmenting elsewhere only *adds* matched edges, and any augmenting path from `u` in the larger matching would, by Lemma 25.3 applied to the two matchings, imply one existed already.

**In an interview this is the one to write.** Fifteen lines, provable on a whiteboard, and it solves "assign at most one X to each Y" — which is what a surprising share of "scheduling" and "resource" questions reduce to once you see the bipartition.

### A7 HOPCROFT-KARP

*Pseudocode: §6, "Hopcroft–Karp".*

```cpp
// HOPCROFT-KARP(G)
// 1  M = empty
// 2  repeat
// 3      let P = {P1..Pk} be a MAXIMAL set of vertex-disjoint SHORTEST
//            M-augmenting paths
// 4      M = M (+) (P1 union ... union Pk)
// 5  until P is empty
// 6  return M
//
// Line 3 in O(E), in the three phases CLRS describes:
//   1. ORIENT  unmatched edges L->R and matched edges R->L (implicit below: from
//              a right vertex the ONLY way onward is its matched partner);
//   2. LAYER   BFS from ALL free left vertices at once, giving each left vertex
//              its distance; stop caring past the first layer q that reaches a
//              free right vertex;
//   3. EXTRACT DFS restricted to consecutive layers, marking dead vertices so
//              they are never re-entered -- which makes the paths vertex-disjoint
//              and the phase O(E) at the same time.
//
// The set found is MAXIMAL, not maximum. CLRS is explicit that it may miss a
// larger disjoint set, and that this does not matter: the analysis needs only
// maximality.
class HopcroftKarpLiteral {
public:
    HopcroftKarpLiteral(int leftCount, int rightCount, vector<vector<int>> adjacency)
        : adjacency_(move(adjacency)),
          matchOfLeft_(leftCount, -1),
          matchOfRight_(rightCount, -1),
          distance_(leftCount, 0) {}

    int solve() {
        int size = 0;                                     // 1
        while (layer()) {                                 // 2-3
            for (int l = 0; l < (int)adjacency_.size(); ++l)
                if (matchOfLeft_[l] < 0 && extract(l))    // 4
                    ++size;
        }
        return size;                                      // 5-6
    }

    const vector<int>& matchOfLeft()  const { return matchOfLeft_; }
    const vector<int>& matchOfRight() const { return matchOfRight_; }

private:
    static const int UNREACHED = INT_MAX;
    vector<vector<int>> adjacency_;
    vector<int> matchOfLeft_, matchOfRight_, distance_;

    // Phase 2. Multi-source BFS: the queue starts with EVERY free left vertex, so
    // distance_[l] is l's distance from the NEAREST free left vertex -- which is
    // exactly the layer number of the dag H.
    bool layer() {
        queue<int> frontier;
        for (int l = 0; l < (int)adjacency_.size(); ++l) {
            distance_[l] = (matchOfLeft_[l] < 0) ? 0 : UNREACHED;
            if (distance_[l] == 0) frontier.push(l);
        }
        bool reachedFreeRight = false;
        while (!frontier.empty()) {
            const int l = frontier.front(); frontier.pop();
            for (int r : adjacency_[l]) {
                const int holder = matchOfRight_[r];
                if (holder < 0) { reachedFreeRight = true; continue; }  // layer q
                if (distance_[holder] == UNREACHED) {
                    distance_[holder] = distance_[l] + 1;
                    frontier.push(holder);
                }
            }
        }
        return reachedFreeRight;      // no free right vertex reachable => maximum
    }

    // Phase 3. Layered DFS. distance_[l] = UNREACHED on failure is doing double
    // duty: it prunes (never re-enter a dead vertex, keeping the phase O(E)) and
    // it enforces vertex-disjointness of the paths found in this phase.
    bool extract(int l) {
        for (int r : adjacency_[l]) {
            const int holder = matchOfRight_[r];
            if (holder < 0 ||
                (distance_[holder] == distance_[l] + 1 && extract(holder))) {
                matchOfRight_[r] = l;                 // 4  M = M (+) P, one edge
                matchOfLeft_[l]  = r;                 //    at a time
                return true;
            }
        }
        distance_[l] = UNREACHED;
        return false;
    }
};
```

**Complexity. `O(E√V)`** (Theorem 25.8): `O(√V)` phases (Lemma 25.7) × `O(E)` per phase.

**The `O(√V)` phase count, compressed.** Lemma 25.5 says the shortest augmenting path gets *strictly longer* every phase — so after `√V` phases it is at least `√V` long. Lemma 25.6 says that if the shortest augmenting path has `q` edges then at most `|V|/(q+1)` augmentations remain, because the `|M*| − |M|` disjoint augmenting paths of Lemma 25.3 each consume `q+1` vertices. With `q ≥ √V` that is `≤ √V` more augmentations, hence `≤ √V` more phases. Total `2√V`.

**Only left vertices carry a distance**, because the only edge leaving a matched right vertex is its matched edge — so `r` and `matchOfRight_[r]` are automatically on consecutive layers, and storing a distance for `r` would be redundant.

### A8 GALE-SHAPLEY

*Pseudocode: §7, "The stable-marriage problem".*

```cpp
// GALE-SHAPLEY(men, women, rankings)
//  1  assign each woman and man as free
//  2  while some woman w is free
//  3      let m be the first man on w's list to whom she has not proposed
//  4      if m is free
//  5          w and m become engaged
//  6      elseif m ranks w higher than his current partner w'
//  7          m breaks the engagement to w', who becomes free
//  8          w and m become engaged
//  9      else m rejects w, with w remaining free
// 10  return the engaged pairs
//
// Written with neutral names, because WHICH SIDE PROPOSES is a policy decision,
// not an implementation detail: Theorem 25.11 says the proposing side gets the
// best partner it can have in ANY stable matching, and Corollary 25.13 says the
// side proposed to gets the WORST. The US medical residency match switched from
// hospital-proposing to student-proposing for exactly this reason.
static vector<int> galeShapleyLiteral(const vector<vector<int>>& proposerPrefs,
                                      const vector<vector<int>>& receiverPrefs) {
    const int n = (int)proposerPrefs.size();

    // Invert each receiver's list once: "does r prefer p to q?" becomes an O(1)
    // integer comparison instead of an O(n) scan. This single inversion is the
    // difference between Corollary 25.10's O(n^2) and a naive O(n^3).
    vector<vector<int>> rankOfProposer(n, vector<int>(n));
    for (int r = 0; r < n; ++r)
        for (int position = 0; position < n; ++position)
            rankOfProposer[r][receiverPrefs[r][position]] = position;

    vector<int> partnerOfProposer(n, -1), partnerOfReceiver(n, -1), nextChoice(n, 0);
    vector<int> freeProposers(n);
    for (int p = 0; p < n; ++p) freeProposers[p] = p;      // 1

    while (!freeProposers.empty()) {                        // 2
        const int proposer = freeProposers.back();
        freeProposers.pop_back();
        // 3  nextChoice only ever advances, so the TOTAL number of proposals
        //    across the whole run is at most n*n -- the termination bound, made
        //    structural rather than argued.
        const int receiver = proposerPrefs[proposer][nextChoice[proposer]++];
        const int incumbent = partnerOfReceiver[receiver];

        if (incumbent < 0) {                                // 4-5
            partnerOfReceiver[receiver] = proposer;
            partnerOfProposer[proposer] = receiver;
        } else if (rankOfProposer[receiver][proposer]       // 6  lower rank number
                 < rankOfProposer[receiver][incumbent]) {   //    = more preferred
            partnerOfProposer[incumbent] = -1;              // 7
            freeProposers.push_back(incumbent);
            partnerOfReceiver[receiver] = proposer;         // 8
            partnerOfProposer[proposer] = receiver;
        } else {
            freeProposers.push_back(proposer);              // 9  rejected, try lower
        }
    }
    return partnerOfProposer;                               // 10
}

// A matching is STABLE iff no (proposer, receiver) pair both prefer each other to
// their assigned partners. Worth having as a function: it is three nested lines
// and it is how you check any claimed stable matching, including your own.
static bool isStableMatching(const vector<vector<int>>& proposerPrefs,
                             const vector<vector<int>>& receiverPrefs,
                             const vector<int>& partnerOfProposer) {
    const int n = (int)proposerPrefs.size();
    vector<vector<int>> rankOfReceiver(n, vector<int>(n)), rankOfProposer(n, vector<int>(n));
    for (int p = 0; p < n; ++p)
        for (int position = 0; position < n; ++position)
            rankOfReceiver[p][proposerPrefs[p][position]] = position;
    for (int r = 0; r < n; ++r)
        for (int position = 0; position < n; ++position)
            rankOfProposer[r][receiverPrefs[r][position]] = position;

    vector<int> partnerOfReceiver(n, -1);
    for (int p = 0; p < n; ++p) partnerOfReceiver[partnerOfProposer[p]] = p;

    for (int p = 0; p < n; ++p)
        for (int r = 0; r < n; ++r) {
            if (r == partnerOfProposer[p]) continue;
            const bool proposerWouldSwitch =
                rankOfReceiver[p][r] < rankOfReceiver[p][partnerOfProposer[p]];
            const bool receiverWouldSwitch =
                rankOfProposer[r][p] < rankOfProposer[r][partnerOfReceiver[r]];
            if (proposerWouldSwitch && receiverWouldSwitch) return false;  // blocking pair
        }
    return true;
}
```

**Complexity. `O(n²)`** (Corollary 25.10) — and that is **linear in the input**, since the two preference tables are `2n²` numbers.

**Termination (Theorem 25.9).** A proposer stuck free forever would have proposed to and been rejected by all `n` receivers; but a receiver only rejects when already engaged, and *engagement is permanent* — so all `n` receivers are engaged, hence all `n` proposers are. Contradiction.

**Stability (Theorem 25.9).** If `w` is matched to `m` but prefers `m′`, she proposed to `m′` earlier; `m′` either rejected her (already had someone better) or accepted and later traded up. Either way `m′` ends with someone he prefers to `w`, so `(w, m′)` is not blocking.

**Ex. 25.2-5:** drop bipartiteness (stable **roommates**) and a stable matching may not exist at all. Bipartiteness is load-bearing, not cosmetic.

### A9 GREEDY-BIPARTITE-MATCHING

*Pseudocode: §8, "Greedy maximal bipartite matching".*

```cpp
// GREEDY-BIPARTITE-MATCHING(G)
// 1  M = empty
// 2  for each vertex l in L
// 3      if l has an unmatched neighbour in R
// 4          choose any such unmatched neighbour r
// 5          M = M union {(l,r)}
// 6  return M
static int greedyBipartiteMatching(const vector<vector<int>>& adjacency, int rightCount,
                                   vector<int>& matchOfLeft, vector<int>& matchOfRight) {
    matchOfLeft.assign(adjacency.size(), -1);          // 1
    matchOfRight.assign(rightCount, -1);
    int size = 0;
    for (int l = 0; l < (int)adjacency.size(); ++l)    // 2
        for (int r : adjacency[l])
            if (matchOfRight[r] < 0) {                 // 3-4
                matchOfRight[r] = l;                   // 5
                matchOfLeft[l]  = r;
                ++size;
                break;
            }
    return size;                                       // 6
}
```

**Complexity. `Θ(E)`.**

**This returns a MAXIMAL matching, and at least half a MAXIMUM one (Ex. 25.3-2).** Why: let `M*` be maximum and `M` greedy. Every edge of `M*` has an endpoint touched by `M` — otherwise both its endpoints were free when greedy considered them and greedy would have taken it. Each edge of `M` touches 2 vertices and so can "block" at most 2 edges of `M*`, giving `|M| ≥ |M*|/2`.

**Maximal is not maximum**, and the gap is real: a path `a—b—c—d` where greedy takes the middle edge `b—c` ends with 1 edge where 2 (`a—b` and `c—d`) were available. But as a **warm start** for Kuhn, Hopcroft–Karp or the Hungarian algorithm it is free and it removes most of the work — which is exactly why CLRS puts it here, as line 5 of `HUNGARIAN`.

The `½`-approximation argument is the same one behind the classic vertex-cover approximation in [M20 *(planned)*](INDEX.md#module-map); recognising it twice is worth more than memorising it once.

### A10 HUNGARIAN and FIND-AUGMENTING-PATH

*Pseudocode: §8, "The algorithm".*

```cpp
// The LITERAL CLRS Hungarian algorithm: MAXIMISE the weight of a perfect
// matching on a complete bipartite graph with |L| = |R| = n.
//
// The state, in CLRS's own vocabulary:
//   leftLabel / rightLabel   the feasible vertex labels l.h, r.h, obeying
//                            leftLabel[l] + rightLabel[r] >= weight[l][r]
//   "tight"                  an edge with equality -- i.e. an edge of the
//                            EQUALITY SUBGRAPH G_h
//   inForestLeft/Right       F_L and F_R, the vertices reached by the BFS
//   predecessor              CLRS's pi attribute
//   delta                    equation (25.4)
//
// Theorem 25.14: a PERFECT matching inside the equality subgraph is optimal for
// the whole graph, because sum(labels) upper-bounds every matching and this one
// attains it. Labels are the DUAL solution; this is the same weak-duality shape
// as max-flow/min-cut earlier in the module.
struct HungarianResult {
    long long weight = 0;
    vector<int> matchOfLeft;
};

static HungarianResult hungarianMaxWeight(const vector<vector<long long>>& weight) {
    const int n = (int)weight.size();
    const long long INF = LLONG_MAX / 4;
    if (n == 0) return {};

    // 1-4  the DEFAULT feasible labelling of equations (25.1)/(25.2)
    vector<long long> leftLabel(n, LLONG_MIN), rightLabel(n, 0);
    for (int l = 0; l < n; ++l)
        for (int r = 0; r < n; ++r) leftLabel[l] = max(leftLabel[l], weight[l][r]);

    const auto tight = [&](int l, int r) {
        return leftLabel[l] + rightLabel[r] == weight[l][r];
    };

    // 5  any matching in G_h -- GREEDY-BIPARTITE-MATCHING (A9), over tight edges
    vector<int> matchOfLeft(n, -1), matchOfRight(n, -1);
    int matched = 0;
    for (int l = 0; l < n; ++l)
        for (int r = 0; r < n; ++r)
            if (matchOfRight[r] < 0 && tight(l, r)) {
                matchOfRight[r] = l; matchOfLeft[l] = r; ++matched; break;
            }

    // Vertices are encoded as: left l is `l`, right r is `n + r`. That keeps the
    // queue heterogeneous exactly as FIND-AUGMENTING-PATH's Q is.
    while (matched < n) {                                   // 7  while not perfect
        vector<char> inForestLeft(n, 0), inForestRight(n, 0);
        vector<int>  predecessor(2 * n, -1);
        deque<int>   pending;
        for (int l = 0; l < n; ++l)                         // 2-3 of FIND-AUG-PATH
            if (matchOfLeft[l] < 0) { inForestLeft[l] = 1; pending.push_back(l); }

        int augmentAt = -1;                                 // a free right vertex

        // Discover right vertex r from left vertex l; returns true when r is free,
        // which means an M-augmenting path has been found (lines 19-20 / 31-32).
        const auto discoverRight = [&](int l, int r) {
            predecessor[n + r] = l;
            if (matchOfRight[r] < 0) { augmentAt = r; return true; }
            inForestRight[r] = 1;
            pending.push_back(n + r);
            return false;
        };

        while (augmentAt < 0) {
            if (pending.empty()) {                          // 9   ran out of room
                // 10  delta = min slack from a searched LEFT vertex to an
                //     unsearched RIGHT vertex -- how close the nearest edge came
                //     to being tight.
                long long delta = INF;
                for (int l = 0; l < n; ++l) {
                    if (!inForestLeft[l]) continue;
                    for (int r = 0; r < n; ++r)
                        if (!inForestRight[r])
                            delta = min(delta, leftLabel[l] + rightLabel[r] - weight[l][r]);
                }
                // 11-14  RELABEL, equation (25.5). Lemma 25.15: feasibility is
                //        preserved; every forest edge and every matched edge stays
                //        tight (both ends move by -delta and +delta); and at least
                //        ONE new edge becomes tight -- which is why the loop below
                //        cannot come up empty and spin forever.
                for (int l = 0; l < n; ++l) if (inForestLeft[l])  leftLabel[l]  -= delta;
                for (int r = 0; r < n; ++r) if (inForestRight[r]) rightLabel[r] += delta;

                // 16-22  continue the search along the newly tight edges
                for (int l = 0; l < n && augmentAt < 0; ++l) {
                    if (!inForestLeft[l]) continue;
                    for (int r = 0; r < n; ++r)
                        if (!inForestRight[r] && tight(l, r) && discoverRight(l, r)) break;
                }
                continue;
            }

            const int at = pending.front(); pending.pop_front();   // 23
            if (at < n) {                                          // 24-25 at in L
                for (int r = 0; r < n; ++r) {                       // unmatched tight
                    if (inForestRight[r] || matchOfLeft[at] == r) continue;
                    if (tight(at, r) && discoverRight(at, r)) break;   // 29-34
                }
            } else {                                               // at in R:
                const int r = at - n;                              // the only edge out
                const int holder = matchOfRight[r];                // is the MATCHED one
                if (holder >= 0 && !inForestLeft[holder]) {        // 25-28
                    predecessor[holder] = at;
                    inForestLeft[holder] = 1;
                    pending.push_back(holder);
                }
            }
        }

        // 36  Trace back through the predecessors and apply M (+) P. Walking the
        //     chain: the left vertex that discovered r had some previous partner,
        //     which becomes the next right vertex to reassign; the walk ends at a
        //     free left vertex, i.e. a root of the search.
        for (int r = augmentAt; r >= 0; ) {
            const int l = predecessor[n + r];
            const int previous = matchOfLeft[l];
            matchOfLeft[l] = r;
            matchOfRight[r] = l;
            r = previous;                       // -1 when l was a free root: stop
        }
        ++matched;                              // 8-9  |M| grows by exactly 1
    }

    HungarianResult out;
    out.matchOfLeft = matchOfLeft;
    for (int l = 0; l < n; ++l) out.weight += weight[l][matchOfLeft[l]];
    return out;                                  // 11
}
```

**Complexity. `O(n⁴)` exactly as written**, because line 10's `δ` is a min over `|F_L| × |R − F_R|` pairs — `O(n²)` per growth step, `O(n)` growth steps per augmentation, `n` augmentations.

**`O(n³)` needs two changes**, both of which CLRS sets as exercises and both of which the body implementation makes:
- **Ex. 25.3-5:** never build `G_{M,h}` explicitly — test tightness on the fly, as `tight()` does here.
- **Problem 25-2:** maintain `slack[r] = min{ l.h + r.h − w(l,r) : l ∈ F_L }` incrementally. Then `δ` is an `O(n)` scan of `slack`, and updating `slack` after a relabel is another `O(n)`.

**Why the `δ` update is safe (Lemma 25.15).** Only pairs with `l ∈ F_L`, `r ∉ F_R` get tighter, and only by `δ`, which is by definition the slack of the tightest such pair — so feasibility survives. Forest edges and matched edges have both endpoints in the forest, so their `−δ + δ` cancels and they stay tight. And the pair achieving the minimum becomes tight, so at least one new edge appears — the guarantee that the search always has somewhere to go.

**Ex. 25.3-6 (minimise):** negate every weight. **Ex. 25.3-7 (`|L| ≠ |R|`):** pad with zero-weight dummy vertices.

*Verified:* on 300 random weight matrices (`n ≤ 8`, weights in `[−50, 50]`) `hungarianMaxWeight` agreed with brute-force enumeration of all `n!` perfect matchings on every instance, and its result agreed with the body's `hungarianMinCost` run on the negated matrix.

### A11 MAX-FLOW-BY-SCALING

*Pseudocode: CLRS Problem 24-5.*

```cpp
// MAX-FLOW-BY-SCALING(G, s, t)
// 1  C = max{c(u,v) : (u,v) in E}
// 2  initialize flow f to 0
// 3  K = 2^floor(lg C)
// 4  while K >= 1
// 5      while there exists an augmenting path p of capacity at least K
// 6          augment flow f along p
// 7      K = K / 2
// 8  return f
//
// The idea: chase the FAT augmenting paths first. While the threshold is K, every
// augmentation moves at least K units, so few of them are needed; then halve K and
// mop up. This is a different fix for the same disease Edmonds-Karp cures --
// Ford-Fulkerson's habit of pushing one unit at a time -- and it is the flow
// analogue of radix sort's "handle the big digits first".
class ScalingMaxFlow : public AppendixNetwork {
public:
    using AppendixNetwork::AppendixNetwork;

    long long maxFlow(int source, int sink) {
        long long largestCapacity = 0;                       // 1
        for (const auto& e : edges_) largestCapacity = max(largestCapacity, e.capacity);
        if (largestCapacity == 0) return 0;

        long long total = 0;                                 // 2
        long long threshold = 1;                             // 3  K = 2^floor(lg C)
        while (threshold * 2 <= largestCapacity) threshold *= 2;

        vector<int> arrivingEdge(vertexCount(), -1);
        for (; threshold >= 1; threshold /= 2) {             // 4, 7
            // 5-6  Part (b) of the problem: an augmenting path of capacity >= K is
            //      found by an ordinary search that simply IGNORES residual edges
            //      thinner than K. One comparison, O(E) as required.
            while (findFatPath(source, sink, threshold, arrivingEdge)) {
                long long bottleneck = LLONG_MAX;
                for (int at = sink; at != source; at = tailOf(arrivingEdge[at]))
                    bottleneck = min(bottleneck, edges_[arrivingEdge[at]].capacity);
                for (int at = sink; at != source; at = tailOf(arrivingEdge[at]))
                    push(arrivingEdge[at], bottleneck);
                total += bottleneck;
            }
        }
        return total;                                        // 8
    }

private:
    bool findFatPath(int source, int sink, long long threshold, vector<int>& arrivingEdge) {
        vector<char> seen(vertexCount(), 0);
        vector<int> stack{source};
        seen[source] = 1;
        while (!stack.empty()) {
            const int at = stack.back(); stack.pop_back();
            for (int id : adjacency_[at]) {
                const int next = edges_[id].to;
                if (edges_[id].capacity >= threshold && !seen[next]) {
                    seen[next] = 1;
                    arrivingEdge[next] = id;
                    if (next == sink) return true;
                    stack.push_back(next);
                }
            }
        }
        return false;
    }
};
```

**Complexity. `O(E² lg C)`.**

*Why (parts d–f of the problem).* When the inner loop for a given `K` finishes, no augmenting path of capacity `≥ K` remains, so the min cut of the residual network is `< K·|E|` — every one of its at most `|E|` edges has residual capacity `< K`. After halving, the remaining flow is `< 2K|E|`, and each augmentation moves `≥ K`, so the inner loop runs `O(E)` times per threshold. There are `lg C + 1` thresholds and each augmentation costs `O(E)`.

**When scaling beats BFS.** `O(E² lg C)` versus `O(VE²)`: scaling wins on **dense graphs with modest capacities** (`lg C ≪ V`), which is the common case. The same "scale the numbers, not the structure" idea gives the polynomial min-cost-flow algorithms and the FPTAS for knapsack in [M20 *(planned)*](INDEX.md#module-map).

### A12 Minimum cut, path cover and project selection

*Pseudocode: §9 (CLRS Problems 24-1, 24-2, 24-3).*

```cpp
// ------------------------------------------------------------- MINIMUM CUT
// Theorem 24.6, part (2) => (3), turned into three lines of code. After a
// maximum flow, S = everything reachable from s in the residual graph, and the
// original edges from S to T are a minimum cut. They are all SATURATED, which is
// a free self-check.
static vector<pair<int,int>> minimumCutEdges(const AppendixNetwork& network, int source,
                                             const vector<pair<int,int>>& originalEdges) {
    const vector<char> sourceSide = network.residualReachable(source);
    vector<pair<int,int>> cut;
    for (const auto& [from, to] : originalEdges)
        if (sourceSide[from] && !sourceSide[to]) cut.push_back({from, to});
    return cut;
}

// -------------------------------------------- MINIMUM PATH COVER OF A DAG (24-2)
// Left copy x_i = "vertex i's outgoing slot", right copy y_j = "vertex j's
// incoming slot", one bipartite edge per DAG edge. A matching is a consistent
// choice of successor for some vertices, and each matched edge glues two path
// fragments into one:
//        minimum number of paths  =  n  -  |maximum matching|
// Part (b) of the problem: this FAILS on cyclic graphs, because the matching may
// close a cycle instead of forming a path.
static int minimumPathCoverSize(int n, const vector<pair<int,int>>& dagEdges) {
    vector<vector<int>> adjacency(n);
    for (const auto& [from, to] : dagEdges) adjacency[from].push_back(to);
    HopcroftKarpLiteral matcher(n, n, adjacency);
    return n - matcher.solve();
}

// --------------------------------- PROJECT SELECTION / MAX-WEIGHT CLOSURE (24-3)
//     s -> cost_k          capacity cost[k]     (what hiring the expert costs)
//     cost_k -> profit_i   capacity INF         (job i REQUIRES expert k)
//     profit_i -> t        capacity profit[i]   (revenue given up by declining i)
//
// Part (a) of the problem is the INF edges doing their job: no finite cut can put
// profit_i on the source side while leaving a required cost_k on the sink side.
// That is the logical implication "accept the job => hire the expert", encoded as
// a capacity. Then
//     maximum net revenue = sum(profit) - capacity of a minimum cut,
// and the SOURCE SIDE OF THE CUT IS THE ANSWER -- no reconstruction pass.
static long long maximumNetRevenue(const vector<long long>& cost,
                                   const vector<long long>& profit,
                                   const vector<vector<int>>& prerequisites,
                                   vector<char>* keptOut = nullptr) {
    const int costCount = (int)cost.size(), profitCount = (int)profit.size();
    const int source = costCount + profitCount, sink = source + 1;
    const long long INF = (long long)1e18;     // NOT LLONG_MAX: these get summed

    DinicLiteral network(sink + 1);
    long long totalProfit = 0;
    for (int k = 0; k < costCount; ++k) network.addEdge(source, k, cost[k]);
    for (int i = 0; i < profitCount; ++i) {
        network.addEdge(costCount + i, sink, profit[i]);
        totalProfit += profit[i];
        for (int k : prerequisites[i]) network.addEdge(k, costCount + i, INF);
    }
    const long long minimumCut = network.maxFlow(source, sink);
    if (keptOut) *keptOut = network.residualReachable(source);
    return totalProfit - minimumCut;
}
```

**Complexity.** Minimum cut: `O(V + E)` after the flow. Path cover: one bipartite matching, `O(E√V)`. Project selection: one max-flow on `O(n + m)` vertices and `O(n + m + r)` edges, where `r = Σ|Rᵢ|`.

**The pattern behind 24-3 is worth naming: maximum-weight closure.** *Choose a subset of items; some choices force others; each item carries a profit or a cost.* Every such problem is a minimum cut, with `∞` edges encoding the implications. Image segmentation, open-pit mine planning, "which features do we build given their dependencies", and maximum-density subgraph are all this one construction. **Recognising the shape is the skill; the code is nine lines.**

**Problem 24-1 (the escape problem)** is the same file with a different graph: split every grid vertex with capacity 1, capacity-1 grid edges, supersource to the `m` starts, every boundary vertex to the supersink; an escape exists iff the max flow is `m`. Once vertex splitting is a reflex, that problem takes two minutes.

### A13 Karger's contraction algorithm

*Pseudocode: §10 (Skiena 8.6, CLRS Problem 24-7).*

```cpp
// KARGER-MIN-CUT(G)
// 1  while G has more than 2 vertices
// 2      pick an edge (x,y) uniformly at random
// 3      G = G / (x,y)                     // contract
// 4  return the number of edges between the two remaining vertices
//
// GLOBAL minimum cut -- no s, no t. Contraction merges two vertices into one,
// keeping parallel edges (this is a MULTIGRAPH) and dropping self-loops.
//
// The multigraph is never built: UNION-FIND over the original vertices IS the
// contraction. "Merge x and y" is one union; "is this edge now a self-loop?" is
// find(x) == find(y). One of the cleanest uses of M10 that has nothing to do
// with connectivity.
class KargerContraction {
public:
    KargerContraction(int vertexCount, vector<pair<int,int>> edges)
        : vertexCount_(vertexCount), edges_(move(edges)) {}

    int run(mt19937& rng) const {
        vector<int> parent(vertexCount_);
        iota(parent.begin(), parent.end(), 0);
        int remaining = vertexCount_;                             // 1

        // "Pick a uniformly random edge" (line 2) is implemented as ONE uniformly
        // random permutation, scanned left to right. Same distribution, and --
        // unlike redraw-until-not-a-self-loop -- it terminates on a DISCONNECTED
        // graph instead of spinning forever. A disconnected graph has global
        // minimum cut 0, which is what the guard below reports.
        vector<int> order(edges_.size());
        iota(order.begin(), order.end(), 0);
        shuffle(order.begin(), order.end(), rng);

        for (int index : order) {
            if (remaining == 2) break;
            const auto& [from, to] = edges_[index];               // 2
            const int rootFrom = find(parent, from), rootTo = find(parent, to);
            if (rootFrom == rootTo) continue;    // already merged: a self-loop
            parent[rootFrom] = rootTo;                            // 3  contract
            --remaining;
        }
        if (remaining > 2) return 0;             // disconnected: the cut is empty

        int crossing = 0;                                         // 4
        for (const auto& [from, to] : edges_)
            if (find(parent, from) != find(parent, to)) ++crossing;
        return crossing;
    }

    // One run succeeds with probability Theta(1/n^2), so repeat n^2 ln n times
    // for failure probability about 1/n. This is MONTE CARLO: always fast,
    // sometimes wrong -- but wrong only in ONE DIRECTION, since every value it
    // reports is the size of a genuine cut.
    int solve(unsigned seed = 20260904) const {
        if (vertexCount_ < 2 || edges_.empty()) return 0;
        mt19937 rng(seed);
        const double suggested =
            (double)vertexCount_ * vertexCount_ * log(max(2, vertexCount_));
        const long long trials = (long long)min(suggested, 100000.0) + 1;
        int best = (int)edges_.size();
        for (long long attempt = 0; attempt < trials; ++attempt)
            best = min(best, run(rng));
        return best;
    }

private:
    int vertexCount_;
    vector<pair<int,int>> edges_;

    static int find(vector<int>& parent, int x) {
        while (x != parent[x]) { parent[x] = parent[parent[x]]; x = parent[x]; }
        return x;                                       // path halving, M10 A2
    }
};
```

**Complexity. `Θ(1/n²)` success per trial; `O(rmn)` for `r` trials** (`O(nm)` per trial with a live edge list; the rejection-sampling version above is `O(m)` *expected* per contraction).

**The probability calculation, which is the reason this algorithm is famous.** If the minimum cut has `k` edges, every vertex has degree `≥ k` — otherwise isolating that vertex would be a smaller cut — so `|E| ≥ kn/2`. A uniformly random edge therefore lies in that specific cut with probability at most `k/(kn/2) = 2/n`. Surviving all `n − 2` contractions:

```
Π_{i=1}^{n−2} ( 1 − 2/(n−i+1) )  =  (n−2)/n · (n−3)/(n−1) · (n−4)/(n−2) · … · 2/4 · 1/3
                                 =  2 / (n(n−1))   =   Θ(1/n²)
```

**Skiena: *"The product cancels magically."*** It telescopes with a two-step offset — every numerator returns as a denominator two factors later — leaving `2·1` over `n(n−1)`.

`Θ(1/n²)` is a *lower* bound on success, and repetition converts it: `r = n² ln n` trials fail with probability `(1 − 1/n²)^{n² ln n} ≈ e^{−ln n} = 1/n`. **Karger–Stein** does better by noticing the early contractions are nearly safe: recurse twice on `n/√2` vertices, giving `Õ(n²)` overall.

**Path halving in `find` is the M10 one-pass compression**, reused verbatim. It is `const`-unfriendly (a query that mutates), which is why `find` takes `parent` by non-const reference — the same wrinkle called out in [M10](M10-union-find.md) toolkit §4.


---

*Next: [M17 — Combinatorial Search and Backtracking](M17-backtracking.md) (Skiena 9) — when there is no clever algorithm and you must search the space anyway: the backtracking template, pruning, and knowing when to stop.*
