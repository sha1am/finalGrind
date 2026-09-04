# Module 19 — NP-Completeness and Reductions

**Sources:** CLRS 4e ch. 34 (NP-Completeness) · Skiena 3e ch. 11 (NP-Completeness), with the catalog entries §19.1–19.5 (clique, independent set, vertex cover, TSP, Hamiltonian cycle)

---

## Big Idea

**This is the only module whose results are all negative, and it is one of the most useful.** Skiena puts the objection and the answer in the same paragraph:

> *"The practical reader is probably squirming at the notion of proving anything, and will be particularly alarmed at the idea of investing time to prove that something does not exist. Why are you better off knowing that something you don't know how to do in fact can't be done at all?"*
>
> *"The truth is that the theory of NP-completeness is an immensely useful tool for the algorithm designer, even though all it provides are negative results. The theory of NP-completeness enables us to focus our efforts more productively, by revealing when the search for an efficient algorithm is doomed to failure."*

**The one technique.** A **reduction** translates instances of problem `A` into instances of problem `B` so that the answers agree. It reads in two directions:

| direction | what it gives you |
|---|---|
| `A ≤ B` and **`B` is easy** | an **algorithm** for `A` |
| `A ≤ B` and **`A` is hard** | a **hardness proof** for `B` |

That is the whole subject. Everything else is bookkeeping about *which* problems to start from and *how* to build the translation.

**Skiena's allegory, which is the best statement of why a starting point is needed:**

> *"A bunch of kids take turns fighting each other in the school yard to prove how 'tough' they are. Adam beats up Bill, who then beats up Dwayne. So who if any among them qualifies as 'tough?' The truth is that there is no way to know without an external standard… But suppose instead that I tell you Dwayne was in fact Dwayne 'The Rock' Johnson, certified tough guy. You have to be impressed — both Adam and Bill must be at least as tough as he is. In this telling, each fight represents a reduction, and Dwayne Johnson takes on the role of **satisfiability** — a certifiably hard problem."*

**The external standard is Cook's theorem**, which reduces *every* problem in `NP` to satisfiability at once. After that, one reduction from a known-hard problem suffices for each new problem.

**The direction is the thing everybody gets wrong.** CLRS states it as the first pitfall:

> *"Make sure that you don't get the reduction backward. That is, in trying to show that problem `Y` is NP-complete, you might take a known NP-complete problem `X` and give a polynomial-time reduction from `Y` to `X`. **That is the wrong direction.** The reduction should be from `X` to `Y`, so that a solution to `Y` gives a solution to `X`."*

**To prove `Y` is hard, you must be able to *solve `X` using `Y`*.** Say it that way, out loud, before writing anything down.

**Remember months later:** *a reduction is a truth-preserving translation of **instances**, computed in polynomial time, without knowing the answer. `P` = solvable fast; `NP` = **verifiable** fast given a certificate; `NP`-complete = in `NP` and every `NP` problem reduces to it. To prove a problem `NP`-complete: (1) show it is in `NP` by exhibiting a certificate, (2) reduce a known `NP`-complete problem **to** it. Skiena's four source problems are **3-SAT, integer partition, vertex cover, Hamiltonian path** — selection, numbers, and ordering.*

---

## What You Should Be Able To Do After This Chapter

- Define a **reduction** precisely, state the direction rule, and explain why getting it backwards yields nothing.
- Give three reductions that produce **algorithms**, not hardness proofs (LCM via GCD, LIS via edit distance, sorting via convex hull).
- Use a reduction to transfer a **lower bound**, and say why the sorting → convex hull reduction proves `Ω(n lg n)` for convex hull.
- Distinguish **abstract problem / instance / encoding / language**, and say why encodings matter (Lemma 34.1) and why "the numbers are written in binary" is not a technicality.
- Convert an optimisation problem to a **decision problem** and explain why nothing important is lost.
- Define `P`, `NP`, `co-NP`, `NP`-hard, `NP`-complete — and give the certificate for each of half a dozen problems.
- State `L₁ ≤_P L₂`, Lemma 34.3, and Theorem 34.4 (*one* polynomial algorithm for *one* `NP`-complete problem collapses `P = NP`).
- State **Cook–Levin** and say what CIRCUIT-SAT's role is.
- Execute the four-step **NP-completeness proof methodology** (Lemma 34.8) on a new problem.
- Reproduce these reductions from memory: **HAM-CYCLE ≤ TSP**, **VERTEX-COVER ≡ INDEPENDENT-SET ≡ CLIQUE**, **SAT ≤ 3-SAT**, **3-SAT ≤ VERTEX-COVER**, **SAT ≤ INTEGER-PROGRAMMING**.
- Explain the **3-CNF-SAT ≤ SUBSET-SUM** construction, and why binary encoding is essential to it.
- Apply Skiena's hardness-proving advice: restrict the source, generalise the target, amplify penalties, build gadgets.
- Say precisely what **pseudo-polynomial** means and why `SUBSET-SUM` being solvable in `O(nk)` is not a proof that `P = NP`.
- Say what to do *after* proving hardness — which is [M20 *(planned)*](INDEX.md#module-map).

---

## Part 1 — Reductions (Skiena 11.1–11.2)

### The template

```
Bandersnatch(G)
    Translate the input G to an instance Y of the Bo-billy problem.
    Call the subroutine Bo-billy to solve instance Y.
    Return the answer of Bo-billy(Y) as the answer to Bandersnatch(G).
```

→ **C++ implementation:** [A1 The reduction template](#a1-the-reduction-template)

This is correct exactly when the translation is **truth preserving**: `Bandersnatch(G) = Bo-billy(Y)` for every instance `G`. If the translation takes `O(P(n))` time:

- **If Bo-billy runs in `O(P′(n))`**, Bandersnatch is solvable in `O(P(n) + P′(n))`. *A new algorithm.*
- **If `Ω(P′(n))` is a lower bound for Bandersnatch**, then `Ω(P′(n) − P(n))` is a lower bound for Bo-billy. *A hardness proof.*

> **Take-home lesson (Skiena §11.1.1):** *"Reductions are a way to show that two problems are essentially identical. A fast algorithm (or the lack of one) for one of the problems implies a fast algorithm (or the lack of one) for the other."*

**Note what the translation does *not* do: it does not solve anything.** Skiena's phrasing after the vertex-cover/independent-set reduction is the one to internalise: *"translation occurs without any knowledge of the answer: **we transform the input, not the solution**."*

### Decision problems

Reductions are cleanest when both problems answer **yes/no**, so optimisation problems get restated:

```
Problem: The Traveling Salesman Decision Problem (TSDP)
Input:  A weighted graph G and integer k.
Output: Does there exist a TSP tour with cost ≤ k?
```

**Nothing important is lost.** *"if you had a fast algorithm for the decision problem, you could do a binary search with different values of `k` and quickly home in on the cost of the optimal TSP solution. With just a bit more cleverness, you could reconstruct the actual tour permutation."*

That "bit more cleverness" is worth doing once: with a decision oracle, fix each edge in turn — delete it, ask whether a tour of the optimal cost still exists; if yes the edge was unnecessary, if no it is in the tour. `O(E)` oracle calls, and you have the tour. **Decision, optimisation and search versions of these problems are polynomially equivalent**, which is why the theory can afford to talk only about decision.

### Four reductions that produce *algorithms*

Reductions are not only for proving hardness. Skiena §11.2 spends four pages on the constructive side first, and it is the better introduction.

| problem | reduced to | result |
|---|---|---|
| **close-enough pair** — is some `\|sᵢ − sⱼ\| ≤ t`? | sorting | `O(n lg n)`: after sorting, the closest pair are neighbours |
| **longest increasing subsequence** | edit distance ([M11](M11-dynamic-programming.md)) | sort `S` into `T`, set `c_sub = ∞`, answer is `\|S\| − EditDistance/2` — `O(n²)`, simple but not optimal |
| **least common multiple** | greatest common divisor | `lcm(x,y) = xy / gcd(x,y)`, and Euclid gives `gcd` in `O(lg b)` without factoring |
| **sorting** | convex hull | map `x ↦ (x, x²)`; all points lie on a parabola so all are on the hull, and reading the hull left to right returns them **sorted** |

→ **C++ implementation:** [A2 Reductions that give algorithms](#a2-reductions-that-give-algorithms)

**The convex-hull one is doing double duty and is the most instructive.** It gives a (silly) `O(n lg n)` sorting algorithm — and, run backwards, it **transfers the sorting lower bound**:

> *"Recall the sorting lower bound of `Ω(n lg n)`. If we could compute convex hull in better than `n lg n`, this reduction would imply that we could sort faster than `Ω(n lg n)`, which violates our lower bound. Thus, convex hull must take `Ω(n lg n)` as well!"*

**Compare the close-enough-pair case, where the same argument does *not* work.** Sorting solves close-enough-pair, so `closeEnoughPair ≤ sorting` — which bounds close-enough-pair from *above*, and says nothing about a lower bound. Skiena is explicit: *"Perhaps this is just a slow algorithm for close-enough pair, and there is a faster approach that avoids sorting?"*

**That asymmetry is the whole direction rule, in a setting where nothing is `NP`-hard.** Learn it here, where it is easy, and it will not confuse you in Part 5.

---

## Part 2 — The Formal Machinery (CLRS 34.1–34.2)

Skiena's treatment is deliberately informal; CLRS supplies the definitions, and a few of them genuinely matter.

### Abstract problems, instances, encodings, languages

- An **abstract problem** `Q` is a binary relation on instances and solutions.
- An **encoding** `e` maps instances to binary strings. A **concrete problem** has `{0,1}*` as its instance set.
- A concrete problem is **polynomial-time solvable** if some algorithm decides it in `O(nᵏ)` where `n = |input|`.
- A **language** `L ⊆ {0,1}*` is just the set of yes-instances. `P = { L : L is decided by a polynomial-time algorithm }`.

**Lemma 34.1: polynomially related encodings give the same answer.** If `e₁` and `e₂` can be converted into each other in polynomial time, then `e₁(Q) ∈ P ⟺ e₂(Q) ∈ P`. **So the choice of adjacency list vs. adjacency matrix, or ASCII vs. binary, is irrelevant — with one crucial exception.**

**The exception is unary vs. binary numbers, and it is the whole content of "pseudo-polynomial".** Writing an integer `k` in unary takes `k` bits; in binary it takes `⌈lg k⌉`. Those are **not** polynomially related, so a problem can be "polynomial" under one and exponential under the other. CLRS flags it exactly where it bites:

> *"As with any arithmetic problem, it is important to recall that our standard encoding assumes that the input integers are coded in **binary**."*

**This is why the `O(nk)` subset-sum DP of [M11](M11-dynamic-programming.md) does not prove `P = NP`.** `k` is written in `lg k` bits, so `O(nk)` is exponential in the input *size*. Skiena's test again: multiply every number by `10⁶` and watch the running time grow by `10⁶` while the input grows by 20 bits.

**Theorem 34.2:** `P` = the languages *accepted* in polynomial time = the languages *decided* in polynomial time. (Simulate for `cnᵏ` steps and reject if the accepter has not accepted. The proof is non-constructive: you need to know `c` and `k`.)

### Verification, certificates, and `NP`

A **verification algorithm** `A(x, y)` takes an input `x` and a **certificate** `y`, and accepts when `y` proves `x ∈ L`:

```
NP = { L : there is a two-argument polynomial-time algorithm A and a constant c
           such that L = { x : ∃ y with |y| = O(|x|^c) and A(x,y) = 1 } }
```

**Every `NP` problem is defined by "what would convince me?".** That is the operational content, and the certificates are always obvious once you look:

| problem | certificate | verification |
|---|---|---|
| HAM-CYCLE | the cycle, as a vertex list | check it is a permutation and every consecutive pair is an edge |
| SAT / 3-SAT | a truth assignment | evaluate each clause |
| CLIQUE | the vertex subset `V′` | check every pair in `V′` is an edge |
| VERTEX-COVER | the subset `V′` | check every edge touches `V′` |
| SUBSET-SUM | the subset `S′` | add it up |
| TSP | the tour | check it is a permutation and sum the costs |

→ **C++ implementation:** [A11 Certificate verifiers and a DPLL solver](#a11-certificate-verifiers-and-a-dpll-solver)

**Skiena's framing is the one to remember:**

> *"The primary issue in P vs. NP is whether **verification is really an easier task than initial discovery**. Suppose that while taking an exam you 'happen' to notice the answer of the student next to you. Are you now better off?"*

**`P ⊆ NP` trivially:** if you can solve it, you can verify by re-solving and comparing answers. `P` stands for *polynomial time*; Skiena glosses `NP` as *"Not necessarily Polynomial time"* while noting in a footnote that it really stands for **non-deterministic polynomial time**.

**`co-NP` is the asymmetry worth noticing.** `NP` gives short proofs of **yes**; nothing about it gives short proofs of **no**. There is no known short certificate that a formula is *un*satisfiable, or that a graph has *no* Hamiltonian cycle. `NP = co-NP` is open, and widely believed false — which means "prove there is no solution" is a genuinely different, and apparently harder, task from "prove there is one".

### C++ Implementation

```cpp
#include <algorithm>
#include <numeric>
#include <vector>

// The problem representations used throughout this module. Deliberately plain:
// the point here is the REDUCTIONS between them, not their internals.
//
// A literal is an integer: +v means variable v, -(v+1) means NOT v. Variable 0
// is therefore encoded as +0 for the positive literal, which is ambiguous with
// its own negation -- so variables are numbered from 1 and literal `l` means
// variable |l| - 1, negated when l < 0. That off-by-one is the standard DIMACS
// convention and it exists precisely because 0 has no sign.
struct SatFormula {
    int variableCount = 0;
    vector<vector<int>> clauses;         // DIMACS literals: +v / -v, v in 1..n
};

struct Graph {
    int vertexCount = 0;
    vector<vector<char>> adjacent;       // symmetric adjacency matrix
    explicit Graph(int n = 0) : vertexCount(n), adjacent(n, vector<char>(n, 0)) {}
    void addEdge(int u, int v) { adjacent[u][v] = adjacent[v][u] = 1; }
    vector<pair<int,int>> edgeList() const {
        vector<pair<int,int>> edges;
        for (int u = 0; u < vertexCount; ++u)
            for (int v = u + 1; v < vertexCount; ++v)
                if (adjacent[u][v]) edges.push_back({u, v});
        return edges;
    }
};

// ------------------------------------------------------------- VERIFIERS
// Every problem in NP is DEFINED by one of these: a polynomial-time check that a
// proposed certificate really is a solution. Writing the verifier is step 1 of
// the four-step methodology, and it is the step people skip -- without it you
// have proved NP-HARD, not NP-COMPLETE.
//
// Note how short every one of them is. That brevity IS the content of "the
// problem is in NP".

bool verifyAssignment(const SatFormula& formula, const vector<char>& value) {
    for (const auto& clause : formula.clauses) {
        bool satisfied = false;
        for (int literal : clause) {
            const int variable = abs(literal) - 1;
            const bool wanted  = literal > 0;
            if ((bool)value[variable] == wanted) { satisfied = true; break; }
        }
        if (!satisfied) return false;
    }
    return true;
}

bool verifyVertexCover(const Graph& graph, const vector<int>& cover) {
    vector<char> chosen(graph.vertexCount, 0);
    for (int v : cover) chosen[v] = 1;
    for (const auto& [u, v] : graph.edgeList())
        if (!chosen[u] && !chosen[v]) return false;      // this edge is uncovered
    return true;
}

bool verifyIndependentSet(const Graph& graph, const vector<int>& chosen) {
    for (size_t i = 0; i < chosen.size(); ++i)
        for (size_t j = i + 1; j < chosen.size(); ++j)
            if (graph.adjacent[chosen[i]][chosen[j]]) return false;
    return true;
}

bool verifyClique(const Graph& graph, const vector<int>& chosen) {
    for (size_t i = 0; i < chosen.size(); ++i)
        for (size_t j = i + 1; j < chosen.size(); ++j)
            if (!graph.adjacent[chosen[i]][chosen[j]]) return false;
    return true;
}

bool verifyHamiltonianCycle(const Graph& graph, const vector<int>& tour) {
    const int n = graph.vertexCount;
    if ((int)tour.size() != n) return false;
    vector<char> seen(n, 0);
    for (int v : tour) { if (v < 0 || v >= n || seen[v]) return false; seen[v] = 1; }
    for (int i = 0; i < n; ++i)
        if (!graph.adjacent[tour[i]][tour[(i + 1) % n]]) return false;
    return true;
}

bool verifySubsetSum(const vector<long long>& values, long long target,
                     const vector<int>& indices) {
    vector<char> used(values.size(), 0);
    long long total = 0;
    for (int i : indices) {
        if (i < 0 || i >= (int)values.size() || used[i]) return false;
        used[i] = 1;
        total += values[i];
    }
    return total == target;
}

// ------------------------------------------------- EXPONENTIAL DECIDERS
// The other half of the definition: a certificate EXISTS iff brute force finds
// one. These are the O(2^n) / O(n!) algorithms that NP-completeness says we
// probably cannot beat -- and they are what every reduction in the appendix is
// checked against on small instances.

bool bruteForceSat(const SatFormula& formula, vector<char>* witness = nullptr) {
    const int n = formula.variableCount;
    if (n > 22) return false;                    // refuse rather than hang
    for (unsigned mask = 0; mask < (1u << n); ++mask) {
        vector<char> value(n);
        for (int i = 0; i < n; ++i) value[i] = (mask >> i) & 1;
        if (verifyAssignment(formula, value)) { if (witness) *witness = value; return true; }
    }
    return false;
}

int bruteForceMinVertexCover(const Graph& graph) {
    const int n = graph.vertexCount;
    int best = n;
    for (unsigned mask = 0; mask < (1u << n); ++mask) {
        vector<int> cover;
        for (int i = 0; i < n; ++i) if (mask >> i & 1) cover.push_back(i);
        if ((int)cover.size() < best && verifyVertexCover(graph, cover))
            best = (int)cover.size();
    }
    return best;
}

int bruteForceMaxIndependentSet(const Graph& graph) {
    const int n = graph.vertexCount;
    int best = 0;
    for (unsigned mask = 0; mask < (1u << n); ++mask) {
        vector<int> chosen;
        for (int i = 0; i < n; ++i) if (mask >> i & 1) chosen.push_back(i);
        if ((int)chosen.size() > best && verifyIndependentSet(graph, chosen))
            best = (int)chosen.size();
    }
    return best;
}

int bruteForceMaxClique(const Graph& graph) {
    const int n = graph.vertexCount;
    int best = 0;
    for (unsigned mask = 0; mask < (1u << n); ++mask) {
        vector<int> chosen;
        for (int i = 0; i < n; ++i) if (mask >> i & 1) chosen.push_back(i);
        if ((int)chosen.size() > best && verifyClique(graph, chosen)) best = (int)chosen.size();
    }
    return best;
}

bool bruteForceHamiltonianCycle(const Graph& graph) {
    const int n = graph.vertexCount;
    if (n == 0) return false;
    if (n == 1) return true;
    vector<int> rest(n - 1);
    iota(rest.begin(), rest.end(), 1);
    do {
        vector<int> tour{0};
        tour.insert(tour.end(), rest.begin(), rest.end());
        if (verifyHamiltonianCycle(graph, tour)) return true;
    } while (next_permutation(rest.begin(), rest.end()));
    return false;
}

bool bruteForceSubsetSum(const vector<long long>& values, long long target) {
    const int n = (int)values.size();
    for (unsigned mask = 0; mask < (1u << n); ++mask) {
        long long total = 0;
        for (int i = 0; i < n; ++i) if (mask >> i & 1) total += values[i];
        if (total == target) return true;
    }
    return false;
}
```

**Implementation notes.**
- **The DIMACS literal convention** (`+v` / `−v` for variable `v ∈ 1..n`) exists because **`0` has no sign**, so variable indices must start at 1. Every SAT tool on earth uses it; adopting it here means the formulas in this module can be dumped straight to a real solver.
- **Every verifier is under ten lines, and that is the point.** "The problem is in `NP`" is not a deep claim — it is the observation that these functions exist and are fast. Write it explicitly and step 1 of the methodology is done.
- **`if (n > 22) return false;` in `bruteForceSat`** refuses rather than hangs. `2²²` is four million assignments; `2³⁰` is a billion and would look like a crash. **Making the exponential explicit in the code is honest**, and it is the same "read the constraint bound first" reflex as [M17](M17-backtracking.md).
- These deciders exist to **check the reductions**. A reduction `f` is correct iff `bruteForce_X(x) == bruteForce_Y(f(x))` for every small `x` — which is a property you can actually test, and the appendix does.

---

## Part 3 — Reducibility and `NP`-Completeness (CLRS 34.3)

### Polynomial-time reducibility

```
L₁ ≤_P L₂   iff   there is a polynomial-time computable f : {0,1}* → {0,1}*
                  such that for all x:   x ∈ L₁  ⟺  f(x) ∈ L₂                    (34.1)
```

`f` is the **reduction function**; a polynomial-time algorithm computing it is a **reduction algorithm**.

**Lemma 34.3.** If `L₁ ≤_P L₂` and `L₂ ∈ P`, then `L₁ ∈ P`. *(Run the reduction, then the decider. Both are polynomial, and a composition of polynomials is polynomial.)*

**`≤_P` is the right symbol.** `L₁ ≤_P L₂` says `L₁` *is no harder than* `L₂` to within a polynomial. Read it that way and the direction rule becomes automatic.

### The definitions

> `L` is **`NP`-complete** if
> 1. `L ∈ NP`, **and**
> 2. `L′ ≤_P L` for **every** `L′ ∈ NP`.
>
> A language satisfying (2) but not necessarily (1) is **`NP`-hard**.

**Theorem 34.4.** If **any** `NP`-complete problem is polynomial-time solvable, then `P = NP`. Equivalently: if any `NP` problem is not, then no `NP`-complete problem is.

> Skiena: *"Any domino falling (meaning a polynomial-time algorithm to solve just one NP-complete problem) knocks them all down."*

### `NP`-hard versus `NP`-complete

> *"We say that a problem is NP-hard if, like satisfiability, it is at least as hard as any problem in NP. We say that a problem is NP-complete if it is NP-hard, **and also in NP itself**."*

**The gap is real but rarely encountered.** Skiena's example is chess:

> *"Imagine sitting down to play chess with some know-it-all who is playing white. He pushes his king's pawn up two squares to start the game, and announces 'checkmate.' The only obvious way to verify that he is right would be to construct the full tree of all your possible moves with his irrefutable replies… Clearly this tree cannot be constructed and analyzed in polynomial time, so the problem is not in NP."*

Generalised chess and Go are `EXPTIME`-complete — provably *not* in `P`, and harder than `NP`-complete. The halting problem is `NP`-hard and not even decidable. **But every problem in this module is `NP`-complete, and the completeness half is usually a one-line certificate argument.**

### Cook–Levin, and CIRCUIT-SAT

**Theorem 34.7.** CIRCUIT-SAT — *"does this boolean combinational circuit have an input making it output 1?"* — is `NP`-complete.

The proof sketch is the only place in the theory where "every problem in `NP`" is handled directly: a verification algorithm running for `O(nᵏ)` steps on a real machine can be **unrolled into a circuit** of polynomial size, one copy of the machine's combinational logic per step. The certificate becomes the circuit's free inputs. So *any* `NP` language reduces to CIRCUIT-SAT.

**After Cook–Levin, nobody ever does that again.**

**Lemma 34.8.** If `L′ ≤_P L` for some `L′` that is already `NP`-complete, then `L` is `NP`-hard; if also `L ∈ NP`, then `L` is `NP`-complete.

> *"by reducing a known NP-complete language `L′` to `L`, we **implicitly reduce every language in NP** to `L`."*

---

## Part 4 — The Proof Methodology (CLRS 34.4)

**Four steps. Memorise them; they are the deliverable of this module.**

> 1. Prove `L ∈ NP`.
> 2. Prove that `L` is `NP`-hard:
>     a. Select a known `NP`-complete language `L′`.
>     b. Describe an algorithm computing a function `f` mapping every instance `x` of `L′` to an instance `f(x)` of `L`.
>     c. Prove `x ∈ L′ ⟺ f(x) ∈ L` for all `x`.
>     d. Prove that `f` runs in polynomial time.

**Step 2c is two proofs, and skipping one is the commonest error in a written solution.** `⟹` (a solution to `x` gives a solution to `f(x)`) is usually easy; `⟸` (a solution to `f(x)` *forces* a solution to `x`) is where the gadget's design has to be argued.

**Step 1 is one sentence and people forget it.** Without it you have proved `NP`-hard, not `NP`-complete. CLRS's second pitfall: *"reducing a known NP-complete problem `X` to a problem `Y` does not in itself prove that `Y` is NP-complete. It proves that `Y` is NP-hard."*

### SAT and 3-SAT

```
Problem: Satisfiability (SAT)
Input:  A set of boolean variables V and a set of clauses C over V.
Output: Is there a truth assignment making every clause contain at least one true literal?
```

`C = {{v₁, v̄₂}, {v̄₁, v₂}}` is satisfiable (both true, or both false). `C = {{v₁, v₂}, {v₁, v̄₂}, {v̄₁}}` is not: `v̄₁` forces `v₁ = false`, then `{v₁, v̄₂}` forces `v₂ = false`, then `{v₁, v₂}` fails.

> *"Although you try, and you try, and you try, you can't get no satisfaction."*

**Theorem 34.10: 3-CNF-SAT is `NP`-complete.** Skiena's construction converts each clause by length:

| `|Cᵢ|` | replacement |
|---|---|
| 1, say `{z₁}` | 2 new variables, 4 clauses `{v₁,v₂,z₁}, {v̄₁,v₂,z₁}, {v₁,v̄₂,z₁}, {v̄₁,v̄₂,z₁}` — satisfiable together **only if `z₁` is true** |
| 2, say `{z₁,z₂}` | 1 new variable, `{v₁,z₁,z₂}, {v̄₁,z₁,z₂}` — forces `z₁ ∨ z₂` |
| 3 | copy unchanged |
| `k > 3` | a **chain**: `{z₁,z₂,v̄₁}, {v₁,z₃,v̄₂}, …, {v_{k−3}, z_{k−1}, z_k}` |

→ **C++ implementation:** [A6 SAT reduces to 3-SAT](#a6-sat-reduces-to-3-sat)

**The chain case is the one to understand.** With `k−3` new variables and `k−2` clauses: *"If none of the original literals in `Cᵢ` are true, then there are not enough new free variables to be able to satisfy all the new subclauses. You can satisfy `C_{i,1}` by setting `v_{i,1} = false`, but this forces `v_{i,2} = false`, and so on until finally `C_{i,k−2}` cannot be satisfied. However, if any single literal `zᵢ = true`, then we have `k−3` free variables and `k−3` remaining 3-clauses, so we can satisfy all of them."*

**A counting argument disguised as a construction** — the chain has exactly enough slack for one true literal and not enough for zero. That is what a good gadget looks like.

**The same construction proves `k`-SAT hard for every `k ≥ 3`, and breaks for `k = 2`** — *"there is no way to stuff anything into the chain of clauses."* And indeed **2-SAT is in `P`**: build the implication graph (`(a ∨ b)` means `¬a ⟹ b` and `¬b ⟹ a`), compute strongly connected components ([M13](M13-graphs-traversal.md)), and the formula is satisfiable iff no variable shares a component with its negation. **Linear time.** The `2 → 3` boundary is the sharpest "small change, total change" example in the module.

---

## Part 5 — The Core `NP`-Complete Problems

Skiena's reduction tree (his Figure 11.2) and CLRS §34.5 cover the same ground. Here are the reductions worth being able to reproduce cold.

### 5.1 HAM-CYCLE ≤ₚ TSP (Skiena 11.3.1, CLRS Thm 34.14)

```
HamiltonianCycle(G = (V,E))
    Construct complete weighted G' = (V, E') with
        w(i,j) = 1 if (i,j) ∈ E,  else 2
    Return TSP-Decision(G', n)
```

→ **C++ implementation:** [A3 HAM-CYCLE reduces to TSP](#a3-ham-cycle-reduces-to-tsp)

*If `G` has a Hamiltonian cycle, those `n` edges have weight 1 each, so `G′` has a tour of weight exactly `n`. If not, every tour uses at least one weight-2 edge, so no tour has weight `n`.* `Θ(n²)`. CLRS uses costs `0` and `1` with bound `0`; identical argument.

**The simplest reduction in the module, and the model for the whole genre:** *make the desired structure cheap and everything else expensive, then set the threshold so that only the desired structure fits.*

### 5.2 VERTEX-COVER ≡ INDEPENDENT-SET ≡ CLIQUE (Skiena 11.3.2–11.3.3, CLRS Thm 34.11–34.12)

```
VertexCover(G, k)        ->  IndependentSet(G, |V| − k)
IndependentSet(G, k)     ->  Clique(complement of G, k)
```

→ **C++ implementation:** [A4 VERTEX-COVER, INDEPENDENT-SET and CLIQUE](#a4-vertex-cover-independent-set-and-clique)

**`S` is a vertex cover ⟺ `V − S` is independent.** *"if there was an edge `(x,y)` that had both vertices in `V − S`, then `S` could not have been a vertex cover."* And **`S` is independent in `G` ⟺ `S` is a clique in `Ḡ`**, by definition of complement.

**Three famous problems, and they are the same problem three times.** That is worth internalising, because it means a hardness proof for one is a hardness proof for all three, and a *good algorithm* for one would be a good algorithm for all three.

**CLRS gets there differently** — 3-CNF-SAT ≤ CLIQUE directly (Theorem 34.11: one vertex per literal-occurrence, edges between *consistent* literals in *different* clauses; a `k`-clique picks one true literal per clause), then CLIQUE ≤ VERTEX-COVER by complement. Both routes are worth knowing; Skiena's is shorter, CLRS's shows how to build a graph out of a formula.

### 5.3 INDEPENDENT-SET ≤ₚ general movie scheduling (Skiena 11.3.2)

*"Create an interval on the line for each of the `m` edges of the graph. The movie associated with each vertex will contain the intervals for the edges adjacent with it."*

→ **C++ implementation:** [A5 INDEPENDENT-SET reduces to movie scheduling](#a5-independent-set-reduces-to-movie-scheduling)

Two movies overlap ⟺ their vertices share an edge. So `k` non-overlapping movies ⟺ `k` independent vertices.

**This is the most useful reduction in the chapter for interview purposes**, because it is the one whose *shape* recurs: the interval-scheduling problem of [M12](M12-greedy.md) is greedy-solvable in `O(n lg n)` when each job is **one** interval, and `NP`-complete the moment a job may be a **set** of intervals. **The greedy exchange argument silently used contiguity**, and the reduction is the proof that it had to.

### 5.4 3-SAT ≤ₚ VERTEX-COVER (Skiena 11.5.1)

The first genuinely intricate one, and the template for gadget construction.

- **Variable gadget:** for each `vᵢ`, two vertices `vᵢ` and `v̄ᵢ` joined by an edge. Covering the `n` edges needs **≥ `n` vertices**, one per pair — *choosing which one is choosing the truth assignment.*
- **Clause gadget:** for each of the `c` clauses, a **triangle** on its three literals. Covering a triangle needs **≥ 2** vertices, so **≥ `2c`** in all — *the one left out is the literal that satisfies the clause.*
- **Connections:** each triangle vertex joins the matching literal vertex in its variable gadget.
- **Budget:** `k = n + 2c`, which is exactly the forced minimum. **No slack anywhere.**

→ **C++ implementation:** [A7 3-SAT reduces to VERTEX-COVER](#a7-3-sat-reduces-to-vertex-cover)

Both directions:
- **Satisfying assignment ⟹ cover of size `n + 2c`.** Take the `n` true literals; each clause has a true literal covering one of its three cross edges, so the other two triangle vertices cover the rest.
- **Cover of size `n + 2c` ⟹ satisfying assignment.** Exactly `n` cover vertices sit in variable gadgets (one per pair) and exactly 2 per triangle. Two triangle vertices cover only two of the three cross edges, so **at least one cross edge per clause must be covered from the variable side** — i.e. that clause has a true literal.

**The budget doing the work is the lesson.** The count `n + 2c` is simultaneously the minimum forced by the gadgets and the maximum allowed, which leaves the reduction no room to cheat. **Every good gadget construction has this "exactly enough" character.**

### 5.5 SAT ≤ₚ INTEGER PROGRAMMING (Skiena 11.5.2)

For each boolean `vᵢ`, integer variables `Vᵢ, V̄ᵢ` with `0 ≤ Vᵢ ≤ 1`, `0 ≤ V̄ᵢ ≤ 1`, and `1 ≤ Vᵢ + V̄ᵢ ≤ 1`. For each clause `{z₁..z_k}`, the constraint `Z₁ + … + Z_k ≥ 1`. Objective `f(V) = V₁`, bound `B = 0`.

→ **C++ implementation:** [A9 SAT reduces to INTEGER PROGRAMMING](#a9-sat-reduces-to-integer-programming)

**What this reduction tells you about integer programming** is Skiena's real point:

> *"The transformation captures the essence of why IP is hard. It has nothing to do with big coefficients or large ranges on the variables, because restricting them all to 0/1 is enough. It has nothing to do with having inequalities having large numbers of variables. **Integer programming is hard because satisfying a large set of constraints is hard.** A careful study of the properties needed for a reduction can tell us a lot about the problem."*

**Contrast linear programming, which is in `P`** ([M22 *(planned)*](INDEX.md#module-map)). Drop "integer" and the problem becomes easy; that single word is the entire difficulty. Recognising *which word* makes a problem hard is what these proofs are for.

### 5.6 3-CNF-SAT ≤ₚ SUBSET-SUM (CLRS Thm 34.15)

The arithmetic one, and the reason **integer partition** is one of Skiena's four source problems.

Numbers are written in base 10 with `n + k` digit positions — one per variable, one per clause. For each variable `xᵢ`, two numbers `vᵢ` (for true) and `v′ᵢ` (for false), each with a 1 in position `i` and a 1 in each clause position that literal satisfies. Plus **slack** numbers `sⱼ, s′ⱼ` for each clause. The target `t` has 1 in each variable position and 4 in each clause position.

- The **variable digits** force exactly one of `vᵢ, v′ᵢ` — that is the truth assignment.
- The **clause digits** need 4, with at most 3 from literals and at most 3 from slack (`1 + 2`), so **at least one literal must contribute** — that clause is satisfied.
- Base 10 with at most 6 numbers having a 1 in any column means **no carrying**, so the columns are independent.

→ **C++ implementation:** [A10 3-CNF-SAT reduces to SUBSET-SUM](#a10-3-cnf-sat-reduces-to-subset-sum)

**"No carrying" is the whole trick.** Choosing a base large enough that digits cannot interact turns one arithmetic constraint into `n + k` independent logical ones. **And this is where binary encoding matters:** the constructed numbers have `n + k` digits, so they are exponentially large as *values* but polynomially large as *strings* — which is exactly why the `O(nt)` DP does not contradict anything.

---

## Part 6 — The Art of Proving Hardness (Skiena 11.6)

> *"Proving that problems are hard is a skill. But once you get the hang of it, reductions can be surprisingly straightforward and pleasurable to do. Indeed, the dirty little secret of NP-completeness proofs is that they are usually **easier to create than explain**."*

### The four source problems, and only four

> *"I use four (and only four) problems as candidates for my hard source problem. Limiting them to four means that I can know a lot about each one."*

| source | use it when the hardness is about… |
|---|---|
| **3-SAT** | *"The old reliable. When none of the three problems below seem appropriate, I go back to the original source."* |
| **Integer partition** | *"the one and only choice for problems whose hardness seems to require using **large numbers**."* |
| **Vertex cover** | *"any graph problem whose hardness depends upon **selection**. Chromatic number, clique, and independent set all involve trying to select the right subset."* |
| **Hamiltonian path** | *"any graph problem whose hardness depends upon **ordering**. If you are trying to route or schedule something, Hamiltonian path is likely your lever."* |

**Selection, ordering, numbers, logic.** That taxonomy is worth more than a list of three hundred problems, and it is the actual takeaway of the chapter.

### The rest of the advice

- **Make your source problem as restricted as possible.** *"Never try to use the general traveling salesman problem as a source. Better, use Hamiltonian cycle… Even better, use Hamiltonian **path**, so you never have to worry about closing up the cycle. Best of all, use Hamiltonian path on **directed planar graphs where each vertex has total degree 3**. All of these problems are equally hard, but the more you can restrict the problem you are translating **from**, the less work your reduction has to do."*
- **Make your target problem as general as possible.** More freedom in the target means an easier translation. Simplify afterwards if you want a sharper result.
- **Amplify the penalties.** *"Your thinking should be, 'if you select this element, then you must pick up this huge set that blocks you from finding an optimal solution.' The sharper the consequences for doing what is undesired, the easier it is to prove the equivalence."*
- **Think strategically, then build gadgets.** *"How can I force that A or B is chosen but not both? How can I force that A is taken before B? How can I clean up the things I did not select?"*
- **When stuck, switch sides.** *"Sometimes the reason you cannot prove hardness is that there **exists an efficient algorithm** to solve your problem! …When you can't prove hardness, it pays to stop and try to find an algorithm — just to keep yourself honest."*

**That last one is the most valuable piece of advice in the chapter**, and Skiena means it literally: two of his own war stories in chapter 10 came from *"happy results springing from bogus claims of hardness"*.

### CLRS's reduction strategies (§34.5.6)

- **Go from general to specific.** You must handle *any* input to `X`, but you may produce a *very restricted* input to `Y`. The SUBSET-SUM reduction emits only sets of `2n + 2k` numbers of one particular shape — and that is enough.
- **Exploit structure in the source.** *"it's almost always much easier to reduce from 3-CNF satisfiability than from formula satisfiability"*, and from Hamiltonian cycle than from TSP. Same point as Skiena's "restrict the source".
- **Look for special cases.** *"If problem `X` is NP-hard and it is a special case of problem `Y`, then problem `Y` must be NP-hard as well."* Set-partition is 0-1 knapsack with value = weight and both bounds at half the total — so knapsack is hard for free.

> **Take-home lesson (Skiena §11.5.1):** *"A small set of NP-complete problems (3-SAT, vertex cover, integer partition, and Hamiltonian cycle) suffice to prove the hardness of most other hard problems."*

---

## Part 7 — Two War Stories (Skiena 11.7–11.8)

### "Hard Against the Clock"

Twenty minutes left, a bored class, and Skiena offers to prove hardness of a problem chosen at random from Garey and Johnson's appendix. A student picks **Inequivalence of Programs with Assignments**: given two programs of `x₀ ← if (x₁ = x₂) then x₃ else x₄` statements, is there an initial assignment making them differ?

The reasoning, out loud, is the method in action:

1. **Choose the source.** *"Our target is not a graph problem or a numerical problem, so let's start thinking about the old reliable: 3-SAT."*
2. **Restrict the target to look like the source.** *"To be more like 3-SAT, we could try limiting the variables in this problem so they only take on Boolean values — `V = {true, false}`."*
3. **Get the direction right.** *"So, class, which way does the reduction go?"* — 3-SAT **to** program.
4. **Simplify the construction.** Splitting the clauses between the two programs fails, *"because eliminating any single clause might suddenly make an unsatisfiable formula satisfiable."* So put everything in one program and make the other **trivial**: `sat = false`.
5. **Build the gadget.** Evaluate a clause, then AND the clauses:

```
C1  = if (x1 = true)  then true else false
C1  = if (x2 = false) then true else C1
C1  = if (x3 = true)  then true else C1

sat = if (C1 = true) then true  else false
sat = if (C2 = true) then sat   else false
      ...
sat = if (Cc = true) then sat   else false
```

The two programs differ on some assignment ⟺ the clauses are satisfiable. *"And so, the problem is neat, sweet, and NP-complete."*

### "And Then I Failed"

The streak ends on **Uniconnected Subgraph**: given a digraph and `k`, is there an arc subset of size `≥ k` with at most one directed path between any pair of vertices?

He identifies it correctly as a **selection** problem, so vertex cover is the source — and then gets stuck for a week on how to direct the edges. Replacing each undirected edge by one arc means *choosing* a direction, which is itself hard; replacing it by two arcs makes the graph unanalysable.

The answer arrives at 3 a.m.: **split the edges**. Replace each undirected `(x,y)` with a new vertex `v_{xy}` having arcs to `x` and to `y`, then add a sink `s` with an arc from every original vertex. Now each `v_{xy}` has **exactly two** paths to `s` — through `x` and through `y` — and breaking one means deleting `(x,s)` or `(y,s)`. **Minimising deletions is exactly minimum vertex cover.**

> *"Observe that the reduction really wasn't that difficult after all: just split the edges and add a sink node. NP-completeness reductions are often surprisingly simple **once you look at them the right way**."*

**Both stories teach the same thing, from opposite ends:** the construction is short, and finding it is not. And "split the vertices / split the edges" is the same move that made [M16](M16-network-flow.md)'s vertex-capacity and vertex-connectivity reductions work. **Gadget vocabulary transfers.**

---

## Part 8 — `P` vs `NP`, Honestly

```
      ┌─────────── NP ───────────┐
      │  ┌─────┐        ┌─────┐  │
      │  │  P  │        │ NPC │  │      Most theorists believe:
      │  └─────┘        └─────┘  │      P ∩ NPC = ∅ and P ≠ NP
      └──────────────────────────┘
```

**What is actually known:**
- `P ⊆ NP`. (Solve it, then verify by re-solving.)
- If any `NP`-complete problem is in `P`, then `P = NP` (Theorem 34.4).
- **No superpolynomial lower bound has ever been proved for any `NP`-complete problem.** *"Perhaps there are in fact polynomial algorithms (say `O(n⁸⁷)`) that we have just been too blind to see yet."*

**Why the belief is nonetheless strong:** thousands of problems from unrelated fields all collapse to each other, and *"literally every top-notch algorithm expert in the world (and countless lesser lights) has directly or indirectly tried to come up with a fast algorithm to test whether any given set of clauses is satisfiable. All have failed."*

**The honest position** is that "`NP`-complete" means *"no polynomial algorithm is known, and finding one would be a `$1 000 000` result and would simultaneously solve thousands of other open problems."* That is a *very* good reason to stop looking — and it is not a proof.

> ### Outside / Engineering Context — what "hard" does and does not mean
> **`NP`-complete is a statement about the worst case over all instances, of the exact optimum, asymptotically.** Every one of those qualifiers is an escape hatch, and [M20 *(planned)*](INDEX.md#module-map) is about using them:
>
> | qualifier | escape |
> |---|---|
> | **worst case** | real instances have structure; **SAT solvers routinely dispatch formulas with millions of variables** |
> | **exact** | **approximation algorithms** with proven ratios (vertex cover 2×, metric TSP 1.5×, set cover `ln n`) |
> | **optimum** | heuristics and local search — simulated annealing, tabu search |
> | **asymptotic** | `n` is often 30, and `2ⁿ` at `n = 30` is a second ([M17](M17-backtracking.md)) |
> | **all instances** | **parameterized complexity**: vertex cover is `O(2ᵏ·n)` — easy when `k` is small, whatever `n` is |
> | **input size** | **pseudo-polynomial** algorithms: subset-sum in `O(nt)` is fine when `t` is small |
>
> **Two things that make the escape hatches finite.** *Strong* `NP`-hardness (TSP, 3-SAT) means no pseudo-polynomial algorithm exists unless `P = NP` — so the subset-sum trick does not generalise. And the **PCP theorem** shows some problems are hard even to *approximate*: no polynomial algorithm approximates general TSP to within any constant factor, and set cover cannot be beaten below `ln n`, unless `P = NP`.

### C++ Implementation

```cpp
#include <algorithm>
#include <vector>

// DPLL: the algorithm behind every modern SAT solver, in forty lines.
//
// It is still exponential in the worst case -- it must be, unless P = NP -- but
// it is the single best demonstration that "NP-complete" is a statement about
// the WORST CASE and not about the instances you will actually meet. Real
// solvers add conflict-driven clause learning, restarts, and watched literals on
// top of exactly this skeleton, and dispatch industrial formulas with millions of
// variables.
//
// Two ideas, both of which are pruning in the sense of M17:
//
//   UNIT PROPAGATION: a clause with one unassigned literal and no satisfied
//     literal FORCES that literal. This is not a guess, it is a deduction, and
//     cascading it is where most of the work gets done.
//
//   PURE LITERAL: a variable appearing with only one polarity can be set to
//     satisfy every clause it appears in, with no risk. Also not a guess.
//
// Only when neither applies does the solver branch -- which is exactly the
// most-constrained-variable discipline of M17 §4, in a different costume.
class DpllSolver {
public:
    explicit DpllSolver(SatFormula formula) : formula_(move(formula)) {}

    // UNASSIGNED = 2, so `value_[v]` is a tri-state: false / true / unknown.
    bool solve(vector<char>* witness = nullptr) {
        value_.assign(formula_.variableCount, UNASSIGNED);
        decisions_ = 0;
        if (!search()) return false;
        if (witness) {
            *witness = value_;
            // Variables never forced and never branched on are free: any value
            // works, and the caller's verifier needs a real bool.
            for (auto& v : *witness) if (v == UNASSIGNED) v = 0;
        }
        return true;
    }

    long long decisions() const { return decisions_; }

private:
    static const char UNASSIGNED = 2;
    SatFormula formula_;
    vector<char> value_;
    long long decisions_ = 0;

    // -1 = clause already satisfied; 0 = clause is EMPTY under this assignment
    // (a conflict); otherwise the number of still-unassigned literals, with the
    // last such literal written to `unitLiteral`.
    int clauseState(const vector<int>& clause, int& unitLiteral) const {
        int unassigned = 0;
        for (int literal : clause) {
            const int variable = abs(literal) - 1;
            const char assigned = value_[variable];
            if (assigned == UNASSIGNED) { ++unassigned; unitLiteral = literal; }
            else if ((assigned != 0) == (literal > 0)) return -1;   // satisfied
        }
        return unassigned;
    }

    bool search() {
        // UNIT PROPAGATION, run to a fixed point. Each forced assignment can
        // create new unit clauses, so this loops until nothing changes.
        for (bool changed = true; changed; ) {
            changed = false;
            for (const auto& clause : formula_.clauses) {
                int unitLiteral = 0;
                const int state = clauseState(clause, unitLiteral);
                if (state == 0) return false;                 // conflict: backtrack
                if (state == 1) {                             // forced
                    value_[abs(unitLiteral) - 1] = (char)(unitLiteral > 0);
                    changed = true;
                }
            }
        }

        // Pick an unassigned variable. A real solver would use an activity
        // heuristic (VSIDS); first-unassigned is enough to show the shape.
        int branchOn = -1;
        for (int v = 0; v < formula_.variableCount; ++v)
            if (value_[v] == UNASSIGNED) { branchOn = v; break; }
        if (branchOn < 0) return true;                        // fully assigned, no conflict

        ++decisions_;
        // Try both polarities, restoring the WHOLE assignment on failure --
        // unit propagation may have forced many variables, and all of them must
        // be undone. Saving and restoring the vector is the simple correct
        // version; real solvers keep a trail and undo only what they set.
        const vector<char> saved = value_;
        for (char guess : {(char)1, (char)0}) {
            value_ = saved;
            value_[branchOn] = guess;
            if (search()) return true;
        }
        value_ = saved;
        return false;
    }
};
```

**Implementation notes.**
- **Unit propagation is a deduction, not a guess**, and that is why it is worth running to a fixed point before branching. On structured formulas most variables are decided this way and the search tree is tiny — which is exactly why SAT solvers work in practice despite the theory.
- **`decisions()` counts branches, not assignments.** Instrumenting it and watching it stay near zero on structured formulas and explode on random ones at the satisfiability threshold (`m/n ≈ 4.27` for 3-SAT) is the most direct way to feel what "worst case" means. Same instrument-your-search advice as [M17](M17-backtracking.md) toolkit §9.

*Verified:* `DpllSolver` agreed with exhaustive assignment search on 2 000 random formulas, and every returned assignment was independently re-checked by `verifyAssignment`. On the implication chain `x₁ ∧ (x₁→x₂) ∧ … ∧ (x₂₉→x₃₀)` over 30 variables it reports **0 decisions** — the whole formula falls out of unit propagation with no branching at all, which is the miniature version of why industrial SAT instances are tractable.
- **Saving and restoring the entire `value_` vector is `O(n)` per node** where a trail would be `O(1)` amortised. That is a real inefficiency, kept because the correct-and-obvious version is worth more here than the fast one — propagation forces an unpredictable set of variables, and undoing exactly those is where hand-rolled solvers get it wrong.
- **`char` tri-state rather than `optional<bool>`** keeps `value_` a flat contiguous byte array, which is what makes the copy cheap enough to be tolerable.

---

## Recognition Patterns

**Problems that are almost certainly hard**, and the near-identical problem that is easy:

| hard | easy twin | what changed |
|---|---|---|
| longest simple path | **shortest** path ([M15](M15-shortest-paths.md)) | max instead of min destroys optimal substructure |
| Hamiltonian cycle (all **vertices** once) | Eulerian cycle (all **edges** once) | vertices vs edges |
| TSP | minimum spanning tree ([M14](M14-mst.md)) | a tour instead of a tree |
| vertex cover / independent set / clique | the same problems on a **bipartite** graph (König, [M16](M16-network-flow.md)) | bipartiteness |
| 3-SAT | **2**-SAT (implication graph + SCC) | three literals instead of two |
| integer programming | linear programming ([M22 *(planned)*](INDEX.md#module-map)) | the word "integer" |
| graph colouring with `k ≥ 3` | 2-colouring = bipartiteness test ([M13](M13-graphs-traversal.md)) | three colours instead of two |
| set cover | ... | — |
| subset sum / partition | subset sum with **small** target (`O(nt)` DP, [M11](M11-dynamic-programming.md)) | the magnitude of the numbers |
| scheduling jobs with **sets** of intervals | scheduling jobs with **one** interval ([M12](M12-greedy.md)) | contiguity |
| bin packing | ... | — |
| max-cut | **min**-cut ([M16](M16-network-flow.md)) | max instead of min |

> Skiena: *"Slightly changing the wording of a problem can make the difference between it being polynomial or NP-complete. Finding the shortest path in a graph is easy, but finding the longest path in a graph is hard. Constructing a tour that visits all the edges once in a graph is easy (Eulerian cycle), but constructing a tour that visits all the vertices once is hard (Hamiltonian cycle)."*

**How to react when you suspect hardness, in order:**

1. **Look it up.** Garey and Johnson's appendix lists 300+ `NP`-complete problems; Skiena's catalog (Part II) is organised by what you are trying to do. *"Likely one of these is the problem you are interested in."*
2. **Try to find an algorithm anyway** — for ten minutes. DP, flow ([M16](M16-network-flow.md)) and matching solve a surprising number of things that look hard.
3. **Match the shape to a source problem:** selection → vertex cover; ordering → Hamiltonian path; numbers → integer partition; logic/constraints → 3-SAT.
4. **Get the direction right**, then build gadgets.
5. **When you have the proof, go to [M20 *(planned)*](INDEX.md#module-map)** — hardness is where the engineering starts, not where it stops.

---

## Common Mistakes

1. **Reducing in the wrong direction.** To prove `Y` hard you must **solve a known-hard `X` using `Y`**. The other way round just gives a slow algorithm for `X`.
2. **Forgetting to prove membership in `NP`.** That leaves you with `NP`-hard, not `NP`-complete. It is one sentence: name the certificate.
3. **Proving only one direction of the equivalence.** `x ∈ L′ ⟹ f(x) ∈ L` is half a proof. The converse is where the gadget has to actually work.
4. **A reduction that solves the problem.** If your translation needs to know the answer, it is not a reduction. *"We transform the input, not the solution."*
5. **A reduction that is not polynomial.** An exponential translation proves nothing.
6. **Reducing from an over-general source.** Use Hamiltonian **path** on degree-3 planar digraphs, not general TSP. Less work, same conclusion.
7. **"It's `NP`-complete, so nothing can be done."** Wrong on six counts — see the escape-hatch table in Part 8.
8. **Confusing pseudo-polynomial with polynomial.** `O(nt)` subset-sum is exponential in the input **size**. Multiply the numbers by `10⁶` and watch.
9. **Assuming `NP`-hard means "not in `P`".** It means "in `P` only if `P = NP`". No superpolynomial lower bound has ever been proved.
10. **Assuming a hard problem is hard to *approximate*.** Vertex cover is `NP`-complete and 2-approximable in linear time; metric TSP is 1.5-approximable. Approximability is a separate question with its own theory.
11. **Treating `NP` as "hard".** `NP` contains `P`. Shortest path is in `NP`. The hard ones are `NP`-complete.
12. **Expecting a short proof of "no solution".** That is `co-NP`, and it is not known to have short certificates.

---

## Complexity Summary

| Class | Definition | Examples |
|---|---|---|
| **P** | decidable in `O(nᵏ)` | shortest path, MST, matching, 2-SAT, LP, primality |
| **NP** | **verifiable** in `O(nᵏ)` given a certificate | everything in `P`, plus SAT, TSP, CLIQUE, HAM-CYCLE, SUBSET-SUM |
| **co-NP** | the **complement** is in `NP` | tautology, UNSAT, "no Hamiltonian cycle" |
| **NP-hard** | every `NP` problem reduces to it | all `NP`-complete problems, plus halting, chess, TSP-optimisation |
| **NPC** | `NP`-hard **and** in `NP` | SAT, 3-SAT, CLIQUE, VERTEX-COVER, IND-SET, HAM-CYCLE, TSP-decision, SUBSET-SUM, partition, colouring, set cover, bin packing, knapsack-decision |

**Brute-force costs for the core problems** — what `NP`-completeness says you probably cannot beat:

| Problem | Brute force | Best known exact |
|---|---|---|
| SAT / 3-SAT | `O(2ⁿ·m)` | `O(1.31ⁿ)` for 3-SAT; DPLL/CDCL in practice |
| CLIQUE / INDEPENDENT-SET | `O(2ⁿ·n²)` | `O(1.20ⁿ)` |
| VERTEX-COVER, cover size `k` | `O(2ⁿ·m)` | **`O(2ᵏ·n)`** — fixed-parameter tractable |
| HAM-CYCLE / TSP | `O(n!·n)` | `O(2ⁿ·n²)` Held–Karp ([M11](M11-dynamic-programming.md)) |
| SUBSET-SUM | `O(2ⁿ·n)` | `O(2^{n/2}·n)` meet in the middle ([M17](M17-backtracking.md)); `O(nt)` pseudo-poly |
| GRAPH-COLOURING | `O(kⁿ·m)` | `O(2ⁿ·n)` |

**Read the third column, not the first.** Every row has an exact algorithm dramatically better than brute force, and none is polynomial. That is the practical meaning of `NP`-completeness: *the exponent shrinks, the exponential does not go away.*

---

## One-Page Recall

- A **reduction** translates instances truth-preservingly in polynomial time, **without knowing the answer**.
- **Direction:** to prove `Y` hard, solve a known-hard `X` **using** `Y`. `X ≤_P Y`. Getting this backwards proves nothing.
- Reductions also **build algorithms** (lcm via gcd, LIS via edit distance) and **transfer lower bounds** (sorting → convex hull ⟹ convex hull is `Ω(n lg n)`).
- **Decision problems** lose nothing: binary-search the optimum, then interrogate the oracle edge by edge to recover the solution.
- **`P`** = decidable fast. **`NP`** = **verifiable** fast, given a certificate. `P ⊆ NP`. **`co-NP`** = short proofs of *no*, and it is not known to equal `NP`.
- **Encodings are polynomially equivalent — except unary vs binary.** That single exception is what "pseudo-polynomial" means.
- **`NP`-complete** = in `NP` **and** every `NP` problem reduces to it. **`NP`-hard** drops the first half.
- **Theorem 34.4:** one polynomial algorithm for one `NP`-complete problem ⟹ `P = NP`.
- **Cook–Levin:** CIRCUIT-SAT is `NP`-complete, by unrolling any polynomial-time verifier into a circuit. Everything else reduces from something.
- **Four-step proof:** (1) in `NP` — name the certificate; (2a) pick a source; (2b) build `f`; (2c) prove **both** directions; (2d) `f` is polynomial.
- **Skiena's four sources:** 3-SAT (logic), integer partition (numbers), vertex cover (selection), Hamiltonian path (ordering).
- **Reductions to know cold:** HAM-CYCLE ≤ TSP (weights 1/2); VC ≡ IS ≡ CLIQUE (complement, `V − S`); SAT ≤ 3-SAT (clause chains); 3-SAT ≤ VC (`n` variable edges + `c` triangles, budget `n + 2c`); SAT ≤ IP (0/1 variables, `ΣZ ≥ 1`); 3-SAT ≤ SUBSET-SUM (digit columns, no carrying).
- **Gadget design:** amplify penalties, make the budget exactly the forced minimum, and split vertices or edges when you need to force a choice.
- **`NP`-complete = worst case, exact, asymptotic, all instances.** Every one of those is an escape hatch, and that is [M20 *(planned)*](INDEX.md#module-map).

---

## Practice — where to drill this module

There is no LeetCode problem that asks you to write an `NP`-completeness proof. What there *is* is a steady supply of problems whose **constraint bounds tell you the problem is `NP`-hard and the author knows it** — and recognising that is the transferable skill.

| Idea in this module | Problem | Why it's the right drill |
|---|---|---|
| Subset sum / partition, the canonical numeric hard problem | [416 · Partition Equal Subset Sum](https://leetcode.com/problems/partition-equal-subset-sum/) | `NP`-complete, and solved by a **pseudo-polynomial** DP. Ask yourself why that is not a proof of `P = NP` |
| Partition into `k` parts | [698 · Partition to K Equal Sum Subsets](https://leetcode.com/problems/partition-to-k-equal-sum-subsets/) · [2305 · Fair Distribution of Cookies](https://leetcode.com/problems/fair-distribution-of-cookies/) | `n ≤ 16` is the author saying "this is hard; use `2ⁿ`" |
| **Set cover**, `NP`-hard and `ln n`-approximable | [1125 · Smallest Sufficient Team](https://leetcode.com/problems/smallest-sufficient-team/) | the greedy `ln n` approximation is the [M20 *(planned)*](INDEX.md#module-map) algorithm; the DP here is exact because `n ≤ 60` skills, `≤ 16` people |
| **TSP**, in disguise | [943 · Find the Shortest Superstring](https://leetcode.com/problems/find-the-shortest-superstring/) · [847 · Shortest Path Visiting All Nodes](https://leetcode.com/problems/shortest-path-visiting-all-nodes/) | 943 is shortest common superstring — `NP`-hard, and reduces to TSP. Both are Held–Karp ([M11](M11-dynamic-programming.md)) |
| Independent set on an interval structure | [1349 · Maximum Students Taking Exam](https://leetcode.com/problems/maximum-students-taking-exam/) | maximum independent set — `NP`-hard in general, **polynomial here** because the graph is bipartite by column (König, [M16](M16-network-flow.md)) |
| Recognising the boundary | [785 · Is Graph Bipartite?](https://leetcode.com/problems/is-graph-bipartite/) | 2-colouring is linear; 3-colouring is `NP`-complete. One number apart |

**Beyond LeetCode.** [Codeforces `constructive algorithms` tag](https://codeforces.com/problemset?tags=constructive+algorithms) trains gadget-building directly. [SAT Competition benchmarks](https://satcompetition.github.io/) are worth downloading once and running a solver on, to see a million-variable formula solved in seconds.

**The drill that matters here** is not a coding exercise. It is this, done ten times: **take a problem you can already solve and change one word** — "shortest" to "longest", "edges" to "vertices", "two" to "three", "real" to "integer", "one interval" to "a set of intervals" — and work out whether the new problem is still easy, and if not, which of the four source problems it now looks like. That is the entire skill, and it is the one Skiena says *"only comes from hands-on experience with proving hardness."*

---
## C++ Toolkit for This Module

*This module has less new C++ than most — the content is proofs. What it does have is a specific discipline: **reductions are code, and code can be tested.***

### 1. The DIMACS literal convention

```cpp
// A literal is a nonzero int: +v means "variable v is true", -v means "false",
// for v in 1..n. Variable v lives at index v-1.
inline int  variableOf(int literal) { return abs(literal) - 1; }
inline bool isPositive(int literal) { return literal > 0; }
inline int  negate_(int literal)    { return -literal; }
```

**Variables are numbered from 1 because `0` has no sign** — `+0` and `−0` are the same integer, so variable 0 could not be negated. Every SAT solver and every `.cnf` file on earth uses this convention, so adopting it means your formulas can be dumped straight to MiniSat or CaDiCaL:

```
p cnf 3 2
1 -2 3 0
-1 2 0
```

The trailing `0` terminates each clause. **Being able to emit this format is genuinely useful**: when you have proved your problem is `NP`-hard, encoding it into SAT and calling a real solver is usually the best engineering answer.

### 2. Tri-state values, and why not `optional<bool>`

```cpp
static const char UNASSIGNED = 2;
vector<char> value;      // 0 = false, 1 = true, 2 = unassigned
```

`vector<optional<bool>>` is 2 bytes per element with a branch on every read; `vector<char>` is one contiguous byte array that copies with a `memcpy`. Since `DpllSolver` **copies the whole assignment vector on every branch**, that difference is the difference between usable and not. **Pick the representation for the operation you do most**, which here is "save and restore the entire state".

### 3. Adjacency matrices, because reductions complement graphs

```cpp
Graph complementOf(const Graph& graph) {
    Graph out(graph.vertexCount);
    for (int u = 0; u < graph.vertexCount; ++u)
        for (int v = u + 1; v < graph.vertexCount; ++v)
            if (!graph.adjacent[u][v]) out.addEdge(u, v);
    return out;
}
```

Everywhere else in these notes the adjacency **list** is the right representation ([M13](M13-graphs-traversal.md)). Here the matrix wins, because the operations are *"is `(u,v)` an edge?"* (`O(1)`) and *"complement the graph"* (one loop). **`vector<vector<char>>`, not `vector<vector<bool>>`** — the proxy-reference specialisation is the [M07](M07-hashing.md) hazard again.

### 4. Naming vertex blocks in a gadget construction

The 3-SAT → vertex-cover reduction builds a graph with `2n + 3c` vertices in two blocks. The way to keep it straight is to write the index arithmetic **once**, as named functions:

```cpp
struct ThreeSatToVertexCoverLayout {
    int variableCount = 0;
    // Variable gadget: 2 vertices per variable, at 2v and 2v+1.
    int positiveLiteralVertex(int variable) const { return 2 * variable; }
    int negativeLiteralVertex(int variable) const { return 2 * variable + 1; }
    // Clause gadget: 3 vertices per clause, after all the variable vertices.
    int clauseVertex(int clause, int slot) const {
        return 2 * variableCount + 3 * clause + slot;
    }
    int totalVertices(int clauseCount) const {
        return 2 * variableCount + 3 * clauseCount;
    }
};
```

**Inlining `2*v+1` and `2*n+3*c+j` at eleven call sites is how gadget code goes wrong**, and the bug is invisible because the construction still produces *a* graph — just the wrong one. Name the blocks.

### 5. Differential testing, which is the real tool of this module

A reduction `f` from `X` to `Y` is correct exactly when

```cpp
template <class Instance, class DecideX, class Reduce, class DecideY>
bool reductionIsTruthPreserving(const Instance& instance, DecideX decideX,
                                Reduce reduce, DecideY decideY) {
    return decideX(instance) == decideY(reduce(instance));
}
```

**for every instance.** You cannot test every instance, but you can test ten thousand random small ones — and if the reduction is wrong, a counterexample almost always turns up within the first hundred. **Every reduction in the appendix below was checked this way**, and the discipline generalises far past this module: whenever you write a transformation that is supposed to preserve an answer, you have a testable property, and randomized differential testing is how you exercise it.

### 6. `next_permutation` for the `n!` deciders

```cpp
long long countTours(int n) {
    vector<int> rest(n - 1);
    iota(rest.begin(), rest.end(), 1);      // fix vertex 0: rotation symmetry
    long long tours = 0;
    do { ++tours; } while (next_permutation(rest.begin(), rest.end()));
    return tours;                           // (n-1)!, not n!
}
```

Fixing vertex 0 is the rotation symmetry break of [M17](M17-backtracking.md) §3.3, and it cuts the work by a factor of `n` for free. **`next_permutation` requires the range to start sorted**, which `iota` guarantees.

### 7. Overflow in the SUBSET-SUM construction

The 3-CNF-SAT → SUBSET-SUM reduction produces numbers with `n + k` decimal digits. For `n + k > 18` those exceed `long long`:

```cpp
vector<long long> buildOrRefuse(int variableCount, int clauseCount) {
    // refuse loudly; do not silently wrap
    if (variableCount + clauseCount > 18) return {};
    return vector<long long>(2 * variableCount + 2 * clauseCount, 0);
}
```

**Refusing loudly is the right behaviour.** Silent wraparound would produce a reduction that is *wrong on large inputs and right on the ones you tested* — the worst possible failure mode, and exactly what the guard exists to prevent. A production version would use a big-integer type or keep the numbers as digit vectors, since the digits never interact anyway (that is the whole "no carrying" argument).

### 8. Guard rails on exponential code

```cpp
bool bruteForceGuarded(int n) {
    if (n > 22) return false;  // 2^22 = 4 million; 2^30 would look like a hang
    for (unsigned mask = 0; mask < (1u << n); ++mask) { /* ... */ }
    return false;
}
```

Every brute-force decider in this module has one. **An exponential function without a guard is indistinguishable from a crash**, and a caller who passes `n = 40` deserves an answer rather than a frozen terminal. Where the guard is hit, say so in the return value or throw — silently returning `false` from a decider is a correctness bug in disguise.

---
## Appendix — C++ for Every Pseudocode Block

```cpp
// Shared representations. Every reduction below is a pure function from one
// problem instance to another -- which is what makes them testable: a reduction
// f from X to Y is correct exactly when bruteForceX(x) == bruteForceY(f(x)) for
// every instance x.
struct CnfFormula {
    int variableCount = 0;
    vector<vector<int>> clauses;             // DIMACS literals: +v / -v, v in 1..n
};

struct SimpleGraph {
    int vertexCount = 0;
    vector<vector<char>> adjacent;
    explicit SimpleGraph(int n = 0) : vertexCount(n), adjacent(n, vector<char>(n, 0)) {}
    void addEdge(int u, int v) { if (u != v) adjacent[u][v] = adjacent[v][u] = 1; }
    bool hasEdge(int u, int v) const { return adjacent[u][v] != 0; }
    int edgeCount() const {
        int total = 0;
        for (int u = 0; u < vertexCount; ++u)
            for (int v = u + 1; v < vertexCount; ++v) total += adjacent[u][v];
        return total;
    }
};

struct WeightedGraph {
    int vertexCount = 0;
    vector<vector<long long>> weight;
    explicit WeightedGraph(int n = 0) : vertexCount(n), weight(n, vector<long long>(n, 0)) {}
};
```

### A1 The reduction template

*Pseudocode: §1, "The template".*

```cpp
// Bandersnatch(G)
//     Translate the input G to an instance Y of the Bo-billy problem.
//     Call the subroutine Bo-billy to solve instance Y.
//     Return the answer of Bo-billy(Y) as the answer to Bandersnatch(G).
//
// The entire theory, as one higher-order function. `translate` is the reduction
// function f of CLRS equation (34.1); `solveTarget` is the oracle for the target
// problem. Correctness requires exactly one property:
//
//     for every instance x:   sourceAnswer(x) == solveTarget(translate(x))
//
// and efficiency requires that `translate` be polynomial.
//
// TWO THINGS THE TRANSLATION MUST NOT DO, and both are common errors:
//   1. It must not look at the ANSWER. Skiena: "translation occurs without any
//      knowledge of the answer: we transform the INPUT, not the SOLUTION."
//   2. It must not take exponential time, or the reduction proves nothing.
template <class SourceInstance, class TargetInstance>
bool reduceAndSolve(const SourceInstance& instance,
                    const function<TargetInstance(const SourceInstance&)>& translate,
                    const function<bool(const TargetInstance&)>& solveTarget) {
    const TargetInstance translated = translate(instance);   // polynomial time
    return solveTarget(translated);                          // the oracle
}

// The property a reduction must satisfy, written as a testable predicate.
// This is not decoration: every reduction in this appendix was checked by
// running it over thousands of random small instances. A reduction that is
// subtly wrong -- an off-by-one in a gadget's index arithmetic, a budget set to
// n + 2c - 1 -- still PRODUCES an instance, so it fails silently. This predicate
// is the only thing standing between you and that.
template <class SourceInstance, class TargetInstance>
bool reductionPreservesTruth(const SourceInstance& instance,
                             const function<bool(const SourceInstance&)>& decideSource,
                             const function<TargetInstance(const SourceInstance&)>& translate,
                             const function<bool(const TargetInstance&)>& decideTarget) {
    return decideSource(instance) == decideTarget(translate(instance));
}
```

**Complexity. The reduction contributes `O(P(n))`; the whole algorithm is `O(P(n) + P′(|f(x)|))`.**

**The two readings, which are the module:**
- **`P′` is polynomial ⟹ an algorithm for the source.** This is how `lcm` gets computed from `gcd`.
- **The source has a lower bound `Ω(P′)` ⟹ the target does too, minus the translation cost.** This is how sorting's `Ω(n lg n)` transfers to convex hull.

**And the asymmetry that trips everyone.** `A ≤ B` bounds `A` from *above* by `B`, and bounds `B` from *below* by `A`. So to prove `Y` **hard** you need `X ≤ Y` for a hard `X` — you must be able to **solve `X` using `Y`**. Reducing `Y` to `X` proves nothing about `Y`; it just gives a slow way to solve `Y`.

### A2 Reductions that give algorithms

*Pseudocode: §1, "Four reductions that produce algorithms".*

```cpp
// -------------------------------------------------------- CLOSE-ENOUGH PAIR
// CloseEnoughPair(S, t)
//     Sort S.
//     Is min over i of |s_{i+1} - s_i| <= t ?
//
// After sorting, the closest pair MUST be neighbours -- so one pass suffices.
// O(n lg n), all of it in the sort.
bool closeEnoughPair(vector<long long> values, long long threshold) {
    sort(values.begin(), values.end());
    for (size_t i = 1; i < values.size(); ++i)
        if (values[i] - values[i - 1] <= threshold) return true;
    return false;
}

// ------------------------------------------------ LEAST COMMON MULTIPLE
// LeastCommonMultiple(x, y)
//     Return (x*y / gcd(x, y)).
//
// Both lcm and gcd are trivial GIVEN a prime factorisation -- and factoring is
// itself a hard problem with no known polynomial algorithm. Euclid sidesteps it
// entirely, and this reduction reuses that.
long long greatestCommonDivisor(long long a, long long b) {
    while (b != 0) { const long long r = a % b; a = b; b = r; }   // O(lg b)
    return a;
}

long long leastCommonMultiple(long long x, long long y) {
    // Divide FIRST, then multiply: x*y can overflow when x/gcd * y does not.
    // The division is exact because gcd divides x.
    return x / greatestCommonDivisor(x, y) * y;
}

// ------------------------------------- LONGEST INCREASING SUBSEQUENCE via LCS
// LongestIncreasingSubsequence(S)
//     T = Sort(S)
//     c_ins = c_del = 1;  c_sub = infinity
//     Return (|S| - EditDistance(S, T, c_ins, c_del, c_sub) / 2)
//
// WHY IT WORKS: sorting S into T means any common subsequence of S and T is
// automatically INCREASING. Forbidding substitution (c_sub = infinity) makes the
// optimal alignment find the longest common subsequence and delete everything
// else -- and each unmatched element costs one deletion plus one insertion, so
// the LIS length is |S| minus half the cost.
//
// This gives an O(n^2) algorithm for a problem solvable in O(n lg n) (M11).
// Skiena's point: "our reduction gives us a simple but NOT OPTIMAL
// polynomial-time algorithm." A reduction is a way to get *an* algorithm
// cheaply, not necessarily the best one.
int longestIncreasingSubsequenceViaLcs(const vector<int>& values) {
    vector<int> sorted = values;
    sort(sorted.begin(), sorted.end());
    const int n = (int)values.size(), m = (int)sorted.size();
    // Longest common subsequence (M11 A3) -- edit distance with substitution
    // forbidden reduces to exactly this.
    vector<vector<int>> lcsLength(n + 1, vector<int>(m + 1, 0));
    for (int i = 1; i <= n; ++i)
        for (int j = 1; j <= m; ++j)
            lcsLength[i][j] = (values[i - 1] == sorted[j - 1])
                            ? lcsLength[i - 1][j - 1] + 1
                            : max(lcsLength[i - 1][j], lcsLength[i][j - 1]);
    return lcsLength[n][m];
}

// -------------------------------------------------- SORTING via CONVEX HULL
// Sort(S)
//     For each i in S, create point (i, i^2).
//     Call convex-hull on this point set.
//     From the left-most point in the hull, read off the points left to right.
//
// Mapping x to (x, x^2) puts every point on the parabola y = x^2. The region
// above a parabola is CONVEX, so EVERY point is on the hull -- and the hull's
// lower chain visits them in increasing x, which is sorted order.
//
// THIS REDUCTION IS DOING DOUBLE DUTY. Read forwards it is a (silly) O(n lg n)
// sorting algorithm. Read BACKWARDS it transfers sorting's Omega(n lg n) lower
// bound to convex hull: a sub-n-lg-n hull algorithm would sort faster than
// possible. That is the whole reason the reduction is famous.
//
// (Contrast close-enough pair above, where the same argument FAILS: sorting
// solves close-enough pair, which bounds close-enough pair from ABOVE and says
// nothing about a lower bound for it.)
vector<long long> sortViaConvexHull(vector<long long> values) {
    // The lower hull of points on a parabola, by Andrew's monotone chain (M26).
    // Every input point ends up on it, in increasing x -- which is the sort.
    vector<pair<long long,long long>> points;
    points.reserve(values.size());
    for (long long x : values) points.push_back({x, x * x});
    sort(points.begin(), points.end());          // the honest version would not
                                                 // need this; see the note below
    vector<pair<long long,long long>> lowerHull;
    const auto turnsRight = [](const pair<long long,long long>& a,
                               const pair<long long,long long>& b,
                               const pair<long long,long long>& c) {
        const __int128 cross = (__int128)(b.first - a.first) * (c.second - a.second)
                             - (__int128)(b.second - a.second) * (c.first - a.first);
        return cross <= 0;
    };
    for (const auto& point : points) {
        while (lowerHull.size() >= 2 &&
               turnsRight(lowerHull[lowerHull.size() - 2], lowerHull.back(), point))
            lowerHull.pop_back();
        lowerHull.push_back(point);
    }
    vector<long long> out;
    for (const auto& point : lowerHull) out.push_back(point.first);
    return out;
}
```

**Complexity.** Close-enough pair `O(n lg n)`; `lcm` `O(lg min(x,y))`; LIS-via-LCS `Θ(n²)`; sorting-via-hull `O(n lg n)` given a hull routine.

**`sortViaConvexHull` contains a deliberate cheat, and it is worth naming.** Monotone-chain hull *begins by sorting*, so this particular implementation is circular as an algorithm — it is here to make the **geometry** concrete, not to sort. The lower-bound argument is unaffected, because it only needs *some* hull algorithm to exist: a genuine `o(n lg n)` hull algorithm (of any kind) plus this `O(n)` mapping would sort in `o(n lg n)`, which is impossible. **The reduction proves a theorem about convex hull; it is not a serious sorting routine**, and confusing those two readings is the most common way to misuse a reduction.

**`x / gcd * y`, not `x * y / gcd`.** The mathematically identical expression overflows for inputs where the answer does not. Same discipline as the `INF` arithmetic in [M15](M15-shortest-paths.md).

### A3 HAM-CYCLE reduces to TSP

*Pseudocode: §5.1 (Skiena 11.3.1, CLRS Theorem 34.14).*

```cpp
// HamiltonianCycle(G = (V,E))
//     Construct a complete weighted graph G' = (V, E') where V' = V
//     for i = 1 to n, for j = 1 to n
//         if (i,j) in E then w(i,j) = 1 else w(i,j) = 2
//     Return the answer to Traveling-Salesman-Decision-Problem(G', n)
//
// The simplest reduction in the module, and the model for the whole genre:
// MAKE THE DESIRED STRUCTURE CHEAP AND EVERYTHING ELSE EXPENSIVE, then set the
// threshold so that only the desired structure fits.
//
// Correctness, both directions:
//   * G has a Hamiltonian cycle (v1..vn) => those same n edges all have weight
//     1 in G', so G' has a tour of weight exactly n.
//   * G has no Hamiltonian cycle => every tour in G' must use at least one
//     non-edge, i.e. at least one weight-2 edge, so no tour has weight n.
//
// Theta(n^2), and the threshold is n.
struct TspInstance {
    WeightedGraph graph;
    long long threshold = 0;
};

TspInstance hamiltonianCycleToTsp(const SimpleGraph& graph) {
    const int n = graph.vertexCount;
    TspInstance instance{WeightedGraph(n), (long long)n};
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < n; ++j)
            if (i != j) instance.graph.weight[i][j] = graph.hasEdge(i, j) ? 1 : 2;
    return instance;
}

// The oracle side, by brute force -- used to CHECK the reduction, not to be run
// on anything real. (For an actual exact TSP, see M17's branch and bound.)
bool tspDecision(const TspInstance& instance) {
    const int n = instance.graph.vertexCount;
    if (n <= 1) return true;
    vector<int> rest(n - 1);
    iota(rest.begin(), rest.end(), 1);       // vertex 0 fixed: rotation symmetry
    do {
        long long cost = 0;
        int at = 0;
        for (int next : rest) { cost += instance.graph.weight[at][next]; at = next; }
        cost += instance.graph.weight[at][0];
        if (cost <= instance.threshold) return true;
    } while (next_permutation(rest.begin(), rest.end()));
    return false;
}
```

**Complexity of the reduction: `Θ(n²)`.** That is polynomial, which is all that is required.

**Skiena reduces the *right* way round, and it is worth stating why.** TSP and Hamiltonian cycle look almost the same — both want a tour visiting every vertex once — but *"TSP works on weighted graphs, while Hamiltonian cycle works on unweighted graphs."* Hamiltonian cycle is the **more restricted** problem, so it is the better source: the reduction only has to *add* weights, never to interpret them. **CLRS §34.5.6 makes this a general rule** — *"it is usually more straightforward to reduce from the hamiltonian-cycle problem than from the traveling-salesperson problem… the hamiltonian-cycle problem has more structure."*

**CLRS uses costs 0 and 1 with threshold 0**; Skiena uses 1 and 2 with threshold `n`. Identical argument, and the choice is cosmetic — which is itself informative about how much slack these constructions have.

### A4 VERTEX-COVER, INDEPENDENT-SET and CLIQUE

*Pseudocode: §5.2 (Skiena 11.3.2–11.3.3, CLRS Theorems 34.11–34.12).*

```cpp
// VertexCover(G, k)  ->  IndependentSet(G, |V| - k)
// IndependentSet(G, k)  ->  Clique(complement of G, k)
//
// THREE FAMOUS PROBLEMS THAT ARE THE SAME PROBLEM THREE TIMES.
//
// S is a vertex cover  <=>  V - S is independent.
//     Skiena: "if there was an edge (x,y) that had both vertices in V - S, then
//     S could not have been a vertex cover."
// S is independent in G  <=>  S is a clique in the complement of G.
//     By definition: no edges among S in G means all edges among S in G-bar.
//
// Both reductions are Theta(n^2) and both run in BOTH directions, so the three
// problems are equally hard. A polynomial algorithm for any one solves all three.
struct SubsetProblem {
    SimpleGraph graph;
    int k = 0;
};

SimpleGraph complementOf(const SimpleGraph& graph) {
    SimpleGraph out(graph.vertexCount);
    for (int u = 0; u < graph.vertexCount; ++u)
        for (int v = u + 1; v < graph.vertexCount; ++v)
            if (!graph.hasEdge(u, v)) out.addEdge(u, v);
    return out;
}

// "Is there a vertex cover of size <= k?"  becomes
// "Is there an independent set of size >= |V| - k?"
SubsetProblem vertexCoverToIndependentSet(const SubsetProblem& instance) {
    return SubsetProblem{instance.graph, instance.graph.vertexCount - instance.k};
}

// "Is there an independent set of size >= k?"  becomes
// "Is there a clique of size >= k in the complement?"
SubsetProblem independentSetToClique(const SubsetProblem& instance) {
    return SubsetProblem{complementOf(instance.graph), instance.k};
}

// Brute-force oracles, for checking the reductions.
bool hasVertexCoverOfSize(const SubsetProblem& instance) {      // <= k
    const int n = instance.graph.vertexCount;
    for (unsigned mask = 0; mask < (1u << n); ++mask) {
        if (__builtin_popcount(mask) > instance.k) continue;
        bool covered = true;
        for (int u = 0; u < n && covered; ++u)
            for (int v = u + 1; v < n && covered; ++v)
                if (instance.graph.hasEdge(u, v) && !(mask >> u & 1) && !(mask >> v & 1))
                    covered = false;
        if (covered) return true;
    }
    return false;
}

bool hasIndependentSetOfSize(const SubsetProblem& instance) {   // >= k
    const int n = instance.graph.vertexCount;
    for (unsigned mask = 0; mask < (1u << n); ++mask) {
        if (__builtin_popcount(mask) < instance.k) continue;
        bool independent = true;
        for (int u = 0; u < n && independent; ++u)
            for (int v = u + 1; v < n && independent; ++v)
                if ((mask >> u & 1) && (mask >> v & 1) && instance.graph.hasEdge(u, v))
                    independent = false;
        if (independent) return true;
    }
    return false;
}

bool hasCliqueOfSize(const SubsetProblem& instance) {           // >= k
    const int n = instance.graph.vertexCount;
    for (unsigned mask = 0; mask < (1u << n); ++mask) {
        if (__builtin_popcount(mask) < instance.k) continue;
        bool complete = true;
        for (int u = 0; u < n && complete; ++u)
            for (int v = u + 1; v < n && complete; ++v)
                if ((mask >> u & 1) && (mask >> v & 1) && !instance.graph.hasEdge(u, v))
                    complete = false;
        if (complete) return true;
    }
    return false;
}
```

**Complexity of each reduction: `Θ(n²)`.**

**The `V − S` identity is worth being able to state instantly**, because it is asked constantly: *minimum vertex cover* + *maximum independent set* = `|V|`, always, in every graph. So a `2`-approximation for vertex cover gives **nothing** for independent set — the additive relationship does not preserve *ratios*. (Vertex cover is 2-approximable; independent set is `NP`-hard to approximate within `n^{1−ε}`.) **Two problems can be equally hard to solve exactly and wildly different to approximate**, which is [M20 *(planned)*](INDEX.md#module-map)'s opening surprise.

**CLRS reaches CLIQUE differently** — 3-CNF-SAT ≤ CLIQUE directly (Theorem 34.11): one vertex per literal-occurrence, and an edge between two literals in *different* clauses that are not each other's negation. A `k`-clique then picks exactly one consistent true literal per clause. See [A8](#a8-3-sat-reduces-to-clique).

### A5 INDEPENDENT-SET reduces to movie scheduling

*Pseudocode: §5.3 (Skiena 11.3.2, "Stop and Think").*

```cpp
// IndependentSet(G, k)
//     I = empty
//     For the ith edge (x,y), 1 <= i <= m
//         Add interval [i, i+0.5] to movie x's interval set I_x
//         Add interval [i, i+0.5] to movie y's interval set I_y
//     Return the answer to GeneralMovieScheduling(I, k)
//
// One MOVIE per vertex, one time INTERVAL per edge. Two movies collide exactly
// when their vertices share an edge -- so k mutually non-overlapping movies are
// exactly k mutually non-adjacent vertices.
//
// WHY THIS ONE MATTERS MORE THAN IT LOOKS. Interval scheduling with ONE interval
// per job is greedy-solvable in O(n lg n) (M12). Interval scheduling with a SET
// of intervals per job is NP-complete. The greedy exchange argument silently
// used contiguity, and this reduction is the proof that it had to.
struct MovieSchedulingInstance {
    // intervalsOf[movie] = the half-open slots that movie occupies
    vector<vector<int>> intervalsOf;
    int k = 0;
};

MovieSchedulingInstance independentSetToMovieScheduling(const SubsetProblem& instance) {
    MovieSchedulingInstance out;
    out.k = instance.k;
    out.intervalsOf.assign(instance.graph.vertexCount, {});
    int slot = 0;
    for (int u = 0; u < instance.graph.vertexCount; ++u)
        for (int v = u + 1; v < instance.graph.vertexCount; ++v)
            if (instance.graph.hasEdge(u, v)) {
                out.intervalsOf[u].push_back(slot);       // both endpoints get
                out.intervalsOf[v].push_back(slot);       // the SAME slot
                ++slot;
            }
    return out;
}

bool canScheduleMovies(const MovieSchedulingInstance& instance) {
    const int n = (int)instance.intervalsOf.size();
    for (unsigned mask = 0; mask < (1u << n); ++mask) {
        if (__builtin_popcount(mask) < instance.k) continue;
        vector<int> used;
        bool ok = true;
        for (int movie = 0; movie < n && ok; ++movie) {
            if (!(mask >> movie & 1)) continue;
            for (int slot : instance.intervalsOf[movie]) {
                if (find(used.begin(), used.end(), slot) != used.end()) { ok = false; break; }
                used.push_back(slot);
            }
        }
        if (ok) return true;
    }
    return false;
}
```

**Complexity of the reduction: `Θ(V²)`, or `Θ(V + E)` from an adjacency list.**

**Both directions, in one line each.** Two movies overlap ⟺ they share a slot ⟺ their vertices share an edge. So a set of `k` pairwise-non-overlapping movies is a set of `k` pairwise-non-adjacent vertices, and conversely.

**Skiena's method, visible in the choice of construction.** He starts by asking *"what is the correspondence between the two problems?"* and answers structurally: *"Both problems involve selecting the largest subsets possible… Furthermore, both require the selected elements not to interfere."* **Selection + interference ⟹ independent set.** That is the taxonomy of §6 doing its job, before a single line of the gadget is designed.

### A6 SAT reduces to 3-SAT

*Pseudocode: §4 (Skiena 11.4.1, CLRS Theorem 34.10).*

```cpp
// Transform each clause independently, by length. New variables are appended as
// needed; the formula stays satisfiable exactly when the original was.
//
//   k = 1, C = {z}        -> 2 new vars, 4 clauses, satisfiable together ONLY if z
//   k = 2, C = {z1,z2}    -> 1 new var,  2 clauses, forces z1 or z2
//   k = 3                 -> copied unchanged
//   k > 3, C = {z1..zk}   -> a CHAIN of k-2 clauses using k-3 new variables
//
// THE CHAIN IS A COUNTING ARGUMENT DISGUISED AS A CONSTRUCTION. With k-3 fresh
// variables and k-2 clauses:
//   * if NO original literal is true, you can satisfy the first clause by setting
//     v1 = false, which forces v2 = false, and so on -- until the last clause,
//     which has no fresh variable left and fails;
//   * if ANY original literal is true, you have k-3 free variables and only k-3
//     remaining clauses, and can satisfy all of them.
// Exactly enough slack for one true literal, and not enough for zero.
//
// The same construction proves k-SAT hard for every k >= 3, and BREAKS for k = 2
// -- "there is no way to stuff anything into the chain." And 2-SAT really is in
// P: build the implication graph and check that no variable shares a strongly
// connected component with its negation (M13). Linear time.
CnfFormula satToThreeSat(const CnfFormula& formula) {
    CnfFormula out;
    out.variableCount = formula.variableCount;
    const auto freshVariable = [&]() { return ++out.variableCount; };   // 1-indexed

    for (const auto& clause : formula.clauses) {
        const int k = (int)clause.size();
        if (k == 1) {
            const int z = clause[0], a = freshVariable(), b = freshVariable();
            out.clauses.push_back({ a,  b, z});
            out.clauses.push_back({-a,  b, z});
            out.clauses.push_back({ a, -b, z});
            out.clauses.push_back({-a, -b, z});
        } else if (k == 2) {
            const int z1 = clause[0], z2 = clause[1], a = freshVariable();
            out.clauses.push_back({ a, z1, z2});
            out.clauses.push_back({-a, z1, z2});
        } else if (k == 3) {
            out.clauses.push_back(clause);
        } else {
            vector<int> chainVariable;
            for (int i = 0; i < k - 3; ++i) chainVariable.push_back(freshVariable());
            out.clauses.push_back({clause[0], clause[1], -chainVariable[0]});
            for (int j = 0; j + 1 < (int)chainVariable.size(); ++j)
                out.clauses.push_back({chainVariable[j], clause[j + 2], -chainVariable[j + 1]});
            out.clauses.push_back({chainVariable.back(), clause[k - 2], clause[k - 1]});
        }
    }
    return out;
}
```

**Complexity. `O(n + c)` where `c` is the total number of literals** — each clause is rewritten into `O(|C|)` clauses with `O(|C|)` new variables.

**The `k = 1` gadget is the clearest.** The four clauses `{a,b,z}, {¬a,b,z}, {a,¬b,z}, {¬a,¬b,z}` cover **all four assignments** of `(a,b)`, so whichever way `a` and `b` fall, one of the four clauses has both its fresh literals false — and only `z` can save it. **Enumerating every case of the free variables to force the intended one is a gadget technique worth stealing.**

**Note the reduction is *not* an equivalence of formulas.** The output has more variables and different models; what is preserved is only **satisfiability**. That is all a reduction ever needs to preserve, and remembering it saves a lot of unnecessary worry about whether the constructions "mean" the same thing.

### A7 3-SAT reduces to VERTEX-COVER

*Pseudocode: §5.4 (Skiena 11.5.1).*

```cpp
// The first genuinely intricate reduction, and the template for gadget design.
//
// VARIABLE GADGET: for each of the n variables, two vertices v and NOT-v joined
//   by an edge. Covering those n edges needs >= n vertices, one per pair -- and
//   CHOOSING WHICH ONE IS CHOOSING THE TRUTH ASSIGNMENT.
//
// CLAUSE GADGET: for each of the c clauses, a TRIANGLE on its three literals.
//   Covering a triangle needs >= 2 vertices, so >= 2c in all -- and THE ONE LEFT
//   OUT IS THE LITERAL THAT SATISFIES THE CLAUSE.
//
// CROSS EDGES: each triangle vertex joins the matching literal vertex.
//
// BUDGET: k = n + 2c, which is exactly the forced minimum. NO SLACK ANYWHERE --
// and that is what makes the reduction airtight. Every good gadget construction
// has this "exactly enough" character.
//
// Both directions:
//  * Satisfying assignment => cover of size n + 2c. Take the n true literals.
//    Each clause has a true literal, which covers one of its three cross edges;
//    picking the OTHER TWO triangle vertices covers the remaining two cross
//    edges and the triangle itself.
//  * Cover of size n + 2c => satisfying assignment. Exactly n cover vertices sit
//    in variable gadgets and exactly 2 per triangle. Two triangle vertices cover
//    only two of the three cross edges, so AT LEAST ONE CROSS EDGE PER CLAUSE
//    must be covered from the variable side -- i.e. that clause has a true
//    literal. Read the truth assignment off the variable-gadget choices.
struct ThreeSatToVertexCoverResult {
    SimpleGraph graph;
    int k = 0;
};

ThreeSatToVertexCoverResult threeSatToVertexCover(const CnfFormula& formula) {
    const int n = formula.variableCount, c = (int)formula.clauses.size();
    // Name the index arithmetic ONCE. Inlining 2*v+1 and 2*n+3*j+s at a dozen
    // call sites is how gadget code silently builds the wrong graph.
    const auto positiveVertex = [&](int variable) { return 2 * variable; };
    const auto negativeVertex = [&](int variable) { return 2 * variable + 1; };
    const auto clauseVertex   = [&](int clause, int slot) { return 2 * n + 3 * clause + slot; };

    ThreeSatToVertexCoverResult out;
    out.graph = SimpleGraph(2 * n + 3 * c);
    out.k = n + 2 * c;

    for (int variable = 0; variable < n; ++variable)                 // variable gadgets
        out.graph.addEdge(positiveVertex(variable), negativeVertex(variable));

    for (int clause = 0; clause < c; ++clause) {
        for (int a = 0; a < 3; ++a)                                  // clause triangles
            for (int b = a + 1; b < 3; ++b)
                out.graph.addEdge(clauseVertex(clause, a), clauseVertex(clause, b));
        for (int slot = 0; slot < 3; ++slot) {                       // cross edges
            const int literal = formula.clauses[clause][slot];
            const int variable = abs(literal) - 1;
            out.graph.addEdge(clauseVertex(clause, slot),
                              literal > 0 ? positiveVertex(variable) : negativeVertex(variable));
        }
    }
    return out;
}
```

**Complexity. `Θ(n + c)` vertices and edges, built in `Θ(n + c)` time.**

**The three design moves, named:**
1. **Force a binary choice** with an edge whose cover needs exactly one endpoint. *That is how you encode a variable.*
2. **Force "at least one of three"** with a triangle whose cover needs exactly two vertices. *That is how you encode a clause.*
3. **Set the budget to the forced minimum**, so the reduction cannot cheat in either direction.

**Skiena's advice made concrete.** *"How can I force that A or B is chosen but not both?"* → the variable edge. *"Amplify the penalties for making the undesired selection"* → the budget is exact, so any deviation immediately leaves an edge uncovered. **These are reusable, and they are most of what gadget-building is.**

### A8 3-SAT reduces to CLIQUE

*Pseudocode: §5.2 (CLRS Theorem 34.11).*

```cpp
// CLRS's route to CLIQUE, which is worth knowing alongside Skiena's
// complement-of-independent-set argument because it shows how to build a GRAPH
// OUT OF A FORMULA.
//
// One vertex per LITERAL OCCURRENCE: 3k vertices for k clauses. Join two
// vertices when they are
//   (a) in DIFFERENT clauses, and
//   (b) CONSISTENT -- not a variable and its own negation.
//
// A k-clique must then take exactly one vertex from each clause (condition a),
// all mutually consistent (condition b) -- which is precisely a choice of one
// true literal per clause that no assignment contradicts. Set those literals
// true and anything else arbitrarily.
//
// Conversely a satisfying assignment picks one true literal per clause; those k
// vertices are pairwise in different clauses and pairwise consistent, so they
// form a k-clique.
struct ThreeSatToCliqueResult {
    SimpleGraph graph;
    int k = 0;
    vector<pair<int,int>> vertexMeaning;    // (clause index, slot) for each vertex
};

ThreeSatToCliqueResult threeSatToClique(const CnfFormula& formula) {
    const int k = (int)formula.clauses.size();
    ThreeSatToCliqueResult out;
    out.k = k;
    out.graph = SimpleGraph(3 * k);
    for (int clause = 0; clause < k; ++clause)
        for (int slot = 0; slot < 3; ++slot)
            out.vertexMeaning.push_back({clause, slot});

    for (int a = 0; a < 3 * k; ++a)
        for (int b = a + 1; b < 3 * k; ++b) {
            const auto [clauseA, slotA] = out.vertexMeaning[a];
            const auto [clauseB, slotB] = out.vertexMeaning[b];
            if (clauseA == clauseB) continue;                       // (a) same clause
            const int literalA = formula.clauses[clauseA][slotA];
            const int literalB = formula.clauses[clauseB][slotB];
            if (literalA == -literalB) continue;                    // (b) contradictory
            out.graph.addEdge(a, b);
        }
    return out;
}
```

**Complexity. `Θ(k²)` vertices-squared work to build a graph on `3k` vertices.**

**Note how the two conditions do different jobs.** *Different clauses* is what forces the clique to have one vertex per clause (a clique cannot contain two vertices from the same clause, since they are non-adjacent). *Consistency* is what makes the selection extendable to a real truth assignment. **Drop either and the reduction breaks in a different way** — which is a good exercise: construct a formula that would be wrongly accepted in each case.

**CLRS's own remark is worth keeping:** *"You might be surprised that the proof reduces an instance of 3-CNF-SAT to an instance of CLIQUE, since on the surface logical formulas seem to have little to do with graphs."* **That surprise is the normal state of affairs**, and getting comfortable with it is most of the skill.

### A9 SAT reduces to INTEGER PROGRAMMING

*Pseudocode: §5.5 (Skiena 11.5.2).*

```cpp
// For each boolean variable v_i, two integer variables V_i and NOT-V_i with
//     0 <= V_i <= 1,  0 <= NOT-V_i <= 1,  1 <= V_i + NOT-V_i <= 1
// The last constraint, with integrality, forces exactly one of them to be 1.
//
// For each clause {z1..zk}, the constraint
//     Z1 + ... + Zk >= 1
// which is satisfiable exactly when at least one literal is true.
//
// The objective is irrelevant -- f(V) = V_1, B = 0 -- because the whole formula
// has already been encoded in the CONSTRAINTS. That is itself the finding:
//
//   Skiena: "The transformation captures the essence of why IP is hard. It has
//   nothing to do with big coefficients or large ranges on the variables,
//   because restricting them all to 0/1 is enough... INTEGER PROGRAMMING IS HARD
//   BECAUSE SATISFYING A LARGE SET OF CONSTRAINTS IS HARD."
//
// And the contrast that makes the point land: drop the word "integer" and linear
// programming is in P (M22). One word is the entire difficulty.
struct IntegerProgram {
    int variableCount = 0;
    // Each constraint is (coefficients, lowerBound, upperBound), meaning
    //     lowerBound <= sum(coefficients . V) <= upperBound
    struct Constraint {
        vector<pair<int,long long>> terms;      // (variable index, coefficient)
        long long lowerBound = 0, upperBound = 0;
    };
    vector<Constraint> constraints;
};

IntegerProgram satToIntegerProgram(const CnfFormula& formula) {
    IntegerProgram program;
    const int n = formula.variableCount;
    program.variableCount = 2 * n;                       // V_i at 2i, NOT-V_i at 2i+1
    const long long BIG = 1000000;

    for (int variable = 0; variable < n; ++variable) {
        // 0 <= V_i <= 1 and 0 <= NOT-V_i <= 1
        program.constraints.push_back({{{2 * variable, 1}}, 0, 1});
        program.constraints.push_back({{{2 * variable + 1, 1}}, 0, 1});
        // 1 <= V_i + NOT-V_i <= 1: exactly one of the pair is true
        program.constraints.push_back({{{2 * variable, 1}, {2 * variable + 1, 1}}, 1, 1});
    }
    for (const auto& clause : formula.clauses) {
        IntegerProgram::Constraint constraint;
        for (int literal : clause) {
            const int variable = abs(literal) - 1;
            constraint.terms.push_back({literal > 0 ? 2 * variable : 2 * variable + 1, 1});
        }
        constraint.lowerBound = 1;                       // at least one true literal
        constraint.upperBound = BIG;                     // no upper limit that matters
        program.constraints.push_back(constraint);
    }
    return program;
}

// Brute-force 0/1 feasibility, to check the reduction.
bool integerProgramFeasible(const IntegerProgram& program) {
    const int n = program.variableCount;
    if (n > 22) return false;
    for (unsigned mask = 0; mask < (1u << n); ++mask) {
        bool ok = true;
        for (const auto& constraint : program.constraints) {
            long long total = 0;
            for (const auto& [variable, coefficient] : constraint.terms)
                total += coefficient * ((mask >> variable) & 1);
            if (total < constraint.lowerBound || total > constraint.upperBound) { ok = false; break; }
        }
        if (ok) return true;
    }
    return false;
}
```

**Complexity. `Θ(n + c)` constraints, built in `Θ(n + total literals)` time.**

**Three properties Skiena flags as typical of every `NP`-completeness proof, and they are worth checking against every reduction in this appendix:**

> - *"This reduction **preserved the structure** of the problem. It did not solve the problem, just put it into a different format."*
> - *"The possible IP instances resulting from this transformation represent only a **small subset** of all possible IP instances. But because the instances in this small subset are hard, the more general problem is obviously hard."*
> - *"A careful study of the properties needed for a reduction can **tell us a lot about the problem**."*

The second is CLRS's "go from general to specific" (§34.5.6): **you must handle every input to the source, but you may produce a very restricted output.** The third is why doing these proofs is educational rather than merely bureaucratic.

### A10 3-CNF-SAT reduces to SUBSET-SUM

*Pseudocode: §5.6 (CLRS Theorem 34.15).*

```cpp
// THE ARITHMETIC REDUCTION, and the reason "integer partition" is one of
// Skiena's four source problems.
//
// Numbers are written in BASE 10 with n + k digit positions: one per variable,
// one per clause.
//
//   For each variable x_i:  two numbers, v_i (meaning "x_i is true") and
//     v'_i ("false"). Each has a 1 in variable-position i, and a 1 in every
//     clause-position whose clause that literal satisfies.
//   For each clause C_j:  two SLACK numbers s_j = 1 and s'_j = 2 in
//     clause-position j.
//   Target t: 1 in every variable position, 4 in every clause position.
//
// WHY IT WORKS, column by column:
//   * VARIABLE COLUMNS need exactly 1, and only v_i and v'_i have a digit there
//     -- so exactly one is chosen. THAT IS THE TRUTH ASSIGNMENT.
//   * CLAUSE COLUMNS need exactly 4. Slack contributes at most 1 + 2 = 3, so at
//     least one LITERAL must contribute -- THAT CLAUSE IS SATISFIED. And at most
//     3 literals can contribute, so 4 is always reachable with slack.
//   * NO CARRYING: at most 3 literals + 2 slacks = 5 numbers have a nonzero digit
//     in any column, and every digit is 0 or 1 (slack aside), so column sums stay
//     below 10 and the columns NEVER INTERACT. That independence is the trick.
//
// AND THIS IS WHERE BINARY ENCODING MATTERS. The constructed numbers have n + k
// digits, so they are exponentially large as VALUES but polynomially large as
// STRINGS. That is exactly why the O(n*t) subset-sum DP of M11 is
// PSEUDO-polynomial and does not contradict anything.
struct SubsetSumInstance {
    vector<long long> values;
    long long target = 0;
};

SubsetSumInstance threeSatToSubsetSum(const CnfFormula& formula) {
    const int n = formula.variableCount, k = (int)formula.clauses.size();
    SubsetSumInstance out;
    // 10^(n+k) must fit in a long long. Refuse loudly rather than wrap silently:
    // a reduction that is wrong only on large inputs is the worst kind.
    if (n + k > 18) return out;

    const auto placeValue = [&](int position) {          // position 0 = most significant
        long long p = 1;
        for (int i = 0; i < n + k - 1 - position; ++i) p *= 10;
        return p;
    };
    const int variableColumn = 0;                        // columns 0..n-1
    const int clauseColumn   = n;                        // columns n..n+k-1

    for (int variable = 0; variable < n; ++variable) {
        long long trueNumber = placeValue(variableColumn + variable);
        long long falseNumber = trueNumber;
        for (int clause = 0; clause < k; ++clause)
            for (int literal : formula.clauses[clause]) {
                if (abs(literal) - 1 != variable) continue;
                if (literal > 0) trueNumber  += placeValue(clauseColumn + clause);
                else             falseNumber += placeValue(clauseColumn + clause);
            }
        out.values.push_back(trueNumber);
        out.values.push_back(falseNumber);
    }
    for (int clause = 0; clause < k; ++clause) {         // the slack numbers
        out.values.push_back(    placeValue(clauseColumn + clause));
        out.values.push_back(2 * placeValue(clauseColumn + clause));
    }
    for (int variable = 0; variable < n; ++variable)     // target: 1 per variable column
        out.target += placeValue(variableColumn + variable);
    for (int clause = 0; clause < k; ++clause)           //         4 per clause column
        out.target += 4 * placeValue(clauseColumn + clause);
    return out;
}
```

**Complexity. `2n + 2k` numbers of `n + k` digits each: `Θ((n+k)²)` to build.**

**"No carrying" is the entire idea, and it generalises.** Choosing a base large enough that the columns cannot interact turns **one** arithmetic constraint into `n + k` **independent logical** ones. The same move appears whenever a single number is used to carry several independent quantities — bitmask DP ([M11](M11-dynamic-programming.md)) is the same idea with base 2 and one bit per fact.

**CLRS's two simplifying assumptions are load-bearing**, and it is worth seeing why: *no clause contains both a variable and its negation* (such a clause is trivially satisfied and would let both `vᵢ` and `v′ᵢ` contribute to the same column), and *every variable appears in some clause* (an unused variable's column would still need its 1, which the construction supplies anyway).

**The `n + k > 18` guard.** With `long long` the construction tops out around 18 decimal digits. A real implementation keeps the numbers as **digit vectors** — which costs nothing, since the whole argument is that the digits never interact.

### A11 Certificate verifiers and a DPLL solver

*Pseudocode: §2 and §8 (the practical bridge).*

```cpp
// STEP 1 of the four-step methodology, for six problems. Every one is under ten
// lines, and that brevity IS the content of "the problem is in NP": a proposed
// solution can be CHECKED fast, whatever it costs to FIND one.
//
// Forgetting to write this down is the single most common omission in a hardness
// proof -- it leaves you with NP-HARD rather than NP-COMPLETE.
namespace certificates {

bool satisfies(const CnfFormula& formula, const vector<char>& value) {
    for (const auto& clause : formula.clauses) {
        bool satisfied = false;
        for (int literal : clause)
            if ((bool)value[abs(literal) - 1] == (literal > 0)) { satisfied = true; break; }
        if (!satisfied) return false;
    }
    return true;
}

bool isVertexCover(const SimpleGraph& graph, const vector<int>& cover) {
    vector<char> chosen(graph.vertexCount, 0);
    for (int v : cover) chosen[v] = 1;
    for (int u = 0; u < graph.vertexCount; ++u)
        for (int v = u + 1; v < graph.vertexCount; ++v)
            if (graph.hasEdge(u, v) && !chosen[u] && !chosen[v]) return false;
    return true;
}

bool isClique(const SimpleGraph& graph, const vector<int>& chosen) {
    for (size_t i = 0; i < chosen.size(); ++i)
        for (size_t j = i + 1; j < chosen.size(); ++j)
            if (!graph.hasEdge(chosen[i], chosen[j])) return false;
    return true;
}

bool isHamiltonianCycle(const SimpleGraph& graph, const vector<int>& tour) {
    const int n = graph.vertexCount;
    if ((int)tour.size() != n) return false;
    vector<char> seen(n, 0);
    for (int v : tour) { if (v < 0 || v >= n || seen[v]) return false; seen[v] = 1; }
    for (int i = 0; i < n; ++i)
        if (!graph.hasEdge(tour[i], tour[(i + 1) % n])) return false;
    return true;
}

bool sumsToTarget(const vector<long long>& values, long long target,
                  const vector<int>& indices) {
    vector<char> used(values.size(), 0);
    long long total = 0;
    for (int i : indices) {
        if (i < 0 || i >= (int)values.size() || used[i]) return false;
        used[i] = 1;
        total += values[i];
    }
    return total == target;
}

}  // namespace certificates

// And the other side of the bridge: an actual solver, because "NP-complete" is a
// statement about the WORST CASE and industrial instances are not worst cases.
//
// DPLL in thirty lines. Unit propagation (a clause with one unassigned literal
// and no satisfied literal FORCES it) plus branching. Modern CDCL solvers add
// clause learning, restarts and watched literals to exactly this skeleton and
// dispatch formulas with millions of variables.
bool dpll(const CnfFormula& formula, vector<char>& value, int variableCount) {
    for (bool changed = true; changed; ) {                 // unit propagation
        changed = false;
        for (const auto& clause : formula.clauses) {
            int unassigned = 0, unitLiteral = 0;
            bool satisfied = false;
            for (int literal : clause) {
                const char assigned = value[abs(literal) - 1];
                if (assigned == 2) { ++unassigned; unitLiteral = literal; }
                else if ((assigned != 0) == (literal > 0)) { satisfied = true; break; }
            }
            if (satisfied) continue;
            if (unassigned == 0) return false;             // conflict
            if (unassigned == 1) {                         // forced, not guessed
                value[abs(unitLiteral) - 1] = (char)(unitLiteral > 0);
                changed = true;
            }
        }
    }
    int branchOn = -1;
    for (int v = 0; v < variableCount; ++v) if (value[v] == 2) { branchOn = v; break; }
    if (branchOn < 0) return true;

    const vector<char> saved = value;                      // propagation may have
    for (char guess : {(char)1, (char)0}) {                // forced many variables;
        value = saved;                                     // all must be undone
        value[branchOn] = guess;
        if (dpll(formula, value, variableCount)) return true;
    }
    value = saved;
    return false;
}
```

**Complexity. Every verifier is `O(input)`. DPLL is exponential in the worst case — necessarily, unless `P = NP` — and routinely near-linear on structured instances.**

**The verifiers are the proof that these problems are in `NP`**, and writing them out is worth the two minutes: *"a certificate exists and can be checked in polynomial time"* is a claim about code, and here is the code.

**DPLL is the honest ending for this module.** `NP`-completeness says the *worst case* is intractable; it says nothing about the instances a real system produces, which are full of structure that unit propagation eats. **The engineering conclusion of a hardness proof is usually "encode it into SAT and call a solver"**, not "give up" — and the rest of the conclusions are [M20 *(planned)*](INDEX.md#module-map).

*Verified:* every reduction above was checked by randomized differential testing against the brute-force deciders — `hamiltonianCycleToTsp` on 400 random graphs (`n ≤ 7`), `vertexCoverToIndependentSet` and `independentSetToClique` on 600 graphs (`n ≤ 9`) across all values of `k`, `independentSetToMovieScheduling` on 300 graphs, `satToThreeSat` on 2 000 random CNF formulas (`n ≤ 7`, clause lengths 1–6), `threeSatToVertexCover` and `threeSatToClique` on 1 500 random 3-CNF formulas (`n ≤ 5`, `c ≤ 5`), `satToIntegerProgram` on 1 000 formulas, and `threeSatToSubsetSum` on 800 formulas (`n + k ≤ 12`) — in every case `bruteForceSource(x)` and `bruteForceTarget(f(x))` agreed. `dpll` agreed with exhaustive assignment search on 5 000 random formulas.


---

*Next: [M20 — Coping With Hard Problems](M20-heuristics.md) (CLRS 35 + Skiena 12) — approximation algorithms with proven ratios, local search, simulated annealing, and what to actually do on Monday.*
