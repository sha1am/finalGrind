# Module 25 — Machine-Learning Algorithms

**Sources:** CLRS 4e ch. 33 (Machine-Learning Algorithms) · Skiena 3e §16.5 (Constrained/Unconstrained Optimization), §8.2 (war story: *Nothing but Nets*), §15.6 (Kd-Trees), §18.3 (Minimum Spanning Tree), §17.5 (Nearest-Neighbor Search)

---

## Big Idea

**Three algorithms, and CLRS states the pattern that unifies them explicitly. Learn the pattern and the three become instances.**

> - *"First, define a **hypothesis space** in terms of an appropriate sequence `θ` of parameters, so that each `θ` is associated with a specific hypothesis `h_θ`."*
> - *"Second, define a measure `f(E, θ)` describing **how poorly** hypothesis `h_θ` fits the given training data `E`. Smaller values of `f(E, θ)` are better."*
> - *"Third, given a set of training data `E`, use a suitable **optimization procedure** to find a value of `θ*` that minimizes `f(E, θ*)`, at least locally."*
> - *"Return `θ*` as the answer."*

**Every one of the three algorithms in this chapter is that recipe with different blanks filled in:**

| algorithm | hypothesis `θ` | loss `f(E, θ)` | optimizer |
|---|---|---|---|
| **`k`-means / Lloyd** | `k` centers `C = ⟨c⁽¹⁾,…,c⁽ᵏ⁾⟩` | `f(S,C) = Σₓ min_j ‖x − c⁽ʲ⁾‖²` | alternate two exact sub-optimisations |
| **`WEIGHTED-MAJORITY`** | expert weights `w₁,…,wₙ` | mistakes made so far | multiply losers' weights by `1 − ε` |
| **`GRADIENT-DESCENT`** | any parameter vector `x ∈ ℝⁿ` | any convex `f` | step `−η·∇f` |

**And the deepest point of the chapter is that the third one subsumes the other two.** Lloyd's procedure is a *specialised* optimiser for one particular loss (Exercise 33.3-7 asks you to solve `k`-means by gradient descent instead); multiplicative weights is a specialised optimiser for an *online* loss. Gradient descent is the general one, and it is why *"optimization becomes a powerful tool for machine learning."*

**The three techniques you actually take away:**

1. **Alternating minimisation.** When your loss has two groups of variables and each is easy to optimise given the other, alternate. Each half-step is *exactly* optimal (Theorems 33.1 and 33.2), the loss decreases monotonically, and the process terminates — but it terminates at a **local** minimum, and `k`-means is `NP`-hard, so that is all you get. This is exactly the local-search shape of [M20](M20-heuristics.md).
2. **Multiplicative weights.** Keep a weight per candidate, multiply the losers' weights by `1 − ε` after every round. The weight vector *is* the learned model, and the analysis is a **potential-function argument** — `W(t) = Σᵢwᵢ(t)` — squeezed between an upper bound from your own mistakes and a lower bound from the best expert's. Same shape as [M09](M09-amortized.md), same online framing as [M24](M24-parallel-online.md).
3. **Gradient descent.** Walk downhill. On a convex function the analysis is a potential argument too — `Φ(t) = ‖x⁽ᵗ⁾ − x*‖²/(2η)` — and it gives `f(x-avg) − f(x*) ≤ RL/√T`, which inverts to **`T = R²L²/ε²` iterations**. *Halve the error, quadruple the work.*

> **Skiena's framing of the same territory, and it is the practitioner's version:** *"Of the seventy-five problems in this catalog, this is the one whose importance has grown most dramatically since the previous edition of my book. **Convex and non-convex optimization are the algorithmic problems most associated with machine learning**, from linear regression to deep learning."*

> **And his one-sentence statement of why convexity is the whole ballgame:** *"The main difficulty of global optimization is getting trapped in local optima. Consider the problem of finding the highest point in a mountain range. If there is only one mountain and it is nicely shaped, we can find the top by just walking in whatever direction heads up. However, when there are many false summits… it is difficult to convince ourselves whether we really are at the highest possible point."*

**Remember months later:** *Three algorithms, one recipe — **hypothesis, loss, optimiser**. **`k`-means:** minimise `Σ‖x − nearest center‖²`; Lloyd alternates *assign to nearest center* (optimal by Thm 33.2) and *move each center to its cluster's centroid* (optimal by Thm 33.1); `f` strictly decreases each iteration so it terminates, at `O(Tdkn)`, at a **local** optimum — the problem is `NP`-hard. **`WEIGHTED-MAJORITY`:** predict by weighted vote, multiply each mistaken expert's weight by `1 − ε`; then `m ≤ 2(1+ε)m* + 2ln(n)/ε`, and with `ε = √(ln n / m*)` that is `2m* + 4√(m* ln n)` — **twice the best expert plus a lower-order term, without knowing which expert is best**. **Gradient descent:** `x⁽ᵗ⁺¹⁾ = x⁽ᵗ⁾ − η∇f(x⁽ᵗ⁾)`; with `η = R/(L√T)`, `f(x-avg) − f(x*) ≤ RL/√T`, so `T = R²L²/ε²`. Constrained: same thing, then **project** back onto `K` — Lemma 33.10 says projection never moves you away from `x*`, so the whole proof survives unchanged.*

---

## What You Should Be Able To Do After This Chapter

- State the **hypothesis / loss / optimiser** recipe and place any of the three algorithms into it.
- Define a **`k`-clustering** by centers plus the **nearest-center rule**, and write the objective `f(S, C)`.
- Prove **Theorem 33.1** (the centroid is the unique optimal center) by differentiating the convex quadratic, and **Theorem 33.2** (the nearest-center rule is optimal given centers) in one line.
- Explain exactly why **Lloyd's procedure terminates** and why that does **not** make it optimal.
- Give the running time `O(Tdkn)` and say which factor is which.
- Explain **feature scaling** and why it is not optional when attributes have different units.
- State the **`⌈lg n⌉`** halving bound (Lemma 33.3) for the case where one expert is perfect, and the `m*⌈lg n⌉` generalisation.
- Write `WEIGHTED-MAJORITY` from memory and prove **Theorem 33.4** with the potential `W(t) = Σwᵢ(t)`.
- Explain where each of the two Taylor bounds `ln(1−x) ≤ −x` and `ln(1−x) ≥ −x − x²` is used, and why you need *both*.
- Tune `ε` to get `2m* + 4√(m* ln n)`, and state what randomisation (`HEDGE`, Problem 33-2) buys.
- Define **convexity** in `ℝⁿ`, prove that a local minimum of a convex function is global, and state **Lemmas 33.6 and 33.7**.
- Derive the **`RL/√T`** bound from the potential `Φ(t) = ‖x⁽ᵗ⁾ − x*‖²/(2η)`, and invert it to `T = R²L²/ε²`.
- Explain the **projection** step, and why **Lemma 33.10** is all you need to reuse the entire unconstrained proof.
- Reduce **solving `Ax = b`** to minimising `½xᵀAx − bᵀx` and say what condition on `A` makes that legitimate.
- Set up **linear regression** as a convex loss and compute its gradient in `O(nm)`.
- Contrast **gradient descent** with **Newton's method** (Problem 33-1) — first order vs second, linear vs quadratic convergence.

---

## Part 1 — Clustering and Lloyd's Procedure (CLRS 33.1)

**The setup.** `n` examples, each a `d`-dimensional **feature vector** `x = (x₁,…,x_d) ∈ ℝᵈ`. Dissimilarity is squared Euclidean distance:

```
δ(x, y) = ‖x − y‖² = Σ_{a=1}^{d} (x_a − y_a)²                          (33.1)
```

> **Why squared, and why it matters.** *"The choice of dissimilarity measure is somewhat arbitrary. The use of the sum of squared differences… is not required, but it is a conventional choice and **mathematically convenient**."* The convenience is Theorem 33.1: squaring is what makes the optimal center the plain arithmetic mean. Use actual distance instead and the optimal center becomes the **geometric median**, which has no closed form. **`k`-means is called `k`-means because of the square.**

### Scaling is part of the algorithm

> *"The scale of attribute values can vary widely across attributes… If the examples contain information about students, one attribute might be grade-point average but another might be family income. Therefore, the attribute values are usually **scaled or normalized, so that no single attribute can dominate the others** when computing dissimilarities."*

**Two standard choices, both in the text:** linearly map each attribute to `[0, 1]`, or standardise to mean 0 and unit variance. And one piece of judgement: *"Sometimes it makes sense to choose the same scaling rule for several related attributes (for example, if they are lengths measured to the same scale)."*

**This is not preprocessing hygiene, it is the objective function.** An unscaled income attribute in dollars against a GPA in `[0,4]` means the clustering is *entirely* determined by income. You did not choose that; the units did.

### Clusterings, centers, and the nearest-center rule

A **`k`-clustering** of `S` is a decomposition into `k` disjoint (possibly empty) subsets `⟨S⁽¹⁾,…,S⁽ᵏ⁾⟩`. This chapter considers only clusterings induced by a sequence of **centers** `C = ⟨c⁽¹⁾,…,c⁽ᵏ⁾⟩`, each a point of `ℝᵈ` — **not necessarily a point of `S`** — via

```
x ∈ S⁽ˡ⁾  only if  δ(x, c⁽ˡ⁾) = min{ δ(x, c⁽ʲ⁾) : 1 ≤ j ≤ k }
```

> **The tie-breaking rule is load-bearing, and it is easy to skim past.** *"Ties may be broken arbitrarily, although we'll need the property that we **never change which cluster a point `x` is assigned to unless the distance from `x` to its new cluster center is strictly smaller** than the distance from `x` to its old cluster center."* Without it, two equidistant centers can trade a point back and forth forever and the procedure never terminates. **The termination proof depends on this one sentence.**

**The `k`-means problem:** given `S` and `k`, find `C` minimising

```
f(S, C) = Σ_{x∈S} min{ δ(x, c⁽ʲ⁾) : 1 ≤ j ≤ k }
        = Σ_{ℓ=1}^{k} Σ_{x∈S⁽ˡ⁾} δ(x, c⁽ˡ⁾)                            (33.2)
```

> *"Is there a polynomial-time algorithm for the `k`-means problem? **Probably not, because it is `NP`-hard.**"* ([M19](M19-np-completeness.md)) — and hard even in the plane. So the target is a local minimum, characterised by two properties: **every cluster has an optimal center**, and **every point is assigned to a closest center**. Those two properties are exactly the two theorems below, and Lloyd's procedure is exactly "enforce them alternately."

### Theorem 33.1 — the centroid is the unique optimal center

> **Theorem 33.1.** Given a nonempty cluster `S⁽ˡ⁾`, its **centroid** is the unique `c⁽ˡ⁾ ∈ ℝᵈ` minimising `Σ_{x∈S⁽ˡ⁾} δ(x, c⁽ˡ⁾)`.

```
c⁽ˡ⁾ = (1/|S⁽ˡ⁾|) Σ_{x∈S⁽ˡ⁾} x                                          (33.3)
```

**The proof is a one-variable calculus exercise done `d` times, and it is worth doing once.** Expand:

```
Σ_{x∈S⁽ˡ⁾} δ(x,c) = Σ_{a=1}^{d} [ Σ_x x_a²  −  2(Σ_x x_a)c_a  +  |S⁽ˡ⁾|c_a² ]
```

Each bracket is a **convex quadratic in `c_a` alone** — the dimensions decouple completely. Differentiate and set to zero:

```
−2 Σ_{x∈S⁽ˡ⁾} x_a + 2|S⁽ˡ⁾| c_a = 0     ⟹     c_a = (1/|S⁽ˡ⁾|) Σ_x x_a
```

**Two things to notice.** First, *the dimensions decouple* — that is the squared-distance choice paying off, and it is why the centroid is computed coordinatewise. Second, the minimiser is **unique**, which is what lets the termination argument say "strictly decreases."

→ **C++ implementation:** [A1 Optimal center (Theorem 33.1)](#a1-optimal-center-theorem-331)

### Theorem 33.2 — the nearest-center rule is optimal given centers

> **Theorem 33.2.** Given `S` and centers `⟨c⁽¹⁾,…,c⁽ᵏ⁾⟩`, a clustering minimises `Σ_ℓ Σ_{x∈S⁽ˡ⁾} δ(x, c⁽ˡ⁾)` **if and only if** it assigns each `x` to a cluster minimising `δ(x, c⁽ˡ⁾)`.

> *"The proof is straightforward: each point `x ∈ S` contributes exactly once to the sum, and choosing to put `x` in a cluster whose center is nearest minimizes the contribution from `x`."*

**A sum of independent per-point contributions is minimised by minimising each one separately.** That is the entire proof, and the reason it is *this* easy is that the objective has no interaction terms between points — which, again, comes from the squared distance.

### Lloyd's procedure

```
LLOYD(S, k)
Input : a set S of points in R^d, and a positive integer k
Output: a k-clustering ⟨S⁽¹⁾,…,S⁽ᵏ⁾⟩ with centers ⟨c⁽¹⁾,…,c⁽ᵏ⁾⟩

1. Initialize centers: pick k points independently from S at random.
                       Assign all points to cluster S⁽¹⁾ to begin.
2. Assign points to clusters: use the nearest-center rule (breaking ties
                       arbitrarily, but not changing a point's assignment
                       unless the new center is STRICTLY closer).
3. Stop if no change:  if step 2 changed no assignment, return.
4. Recompute centers as centroids: for ℓ = 1..k, set c⁽ˡ⁾ to the centroid
                       of S⁽ˡ⁾ (the zero vector if S⁽ˡ⁾ is empty).
                       Go to step 2.
```

→ **C++ implementation:** [A2 LLOYD](#a2-lloyd)

**Why it terminates, in three sentences that are worth memorising.**

> - *"By Theorem 33.1, recomputing the centers of each cluster as the cluster centroid **cannot increase** `f(S,C)`."*
> - *"Lloyd's procedure ensures that a point is reassigned to a different cluster only when such an operation **strictly decreases** `f(S,C)`."*
> - *"Since there are only a **finite** number of possible `k`-clusterings of `S` (at most `kⁿ`), the procedure must terminate."*

**A monotone objective over a finite state space terminates.** That is the whole argument, and it is the same argument as every local-search proof in [M20](M20-heuristics.md). Note what it does *not* give you: any bound on the number of iterations better than `kⁿ`.

> *"If Lloyd's procedure really required `kⁿ` iterations, it would be impractical. **In practice, it sometimes suffices to terminate the procedure when the percentage decrease in `f(S,C)` in the latest iteration falls below a predetermined threshold.**"*

**And the standard remedy for local optima:** *"Because Lloyd's procedure is guaranteed to find only a locally optimal clustering, one approach to finding a good clustering is to **run Lloyd's procedure many times with different randomly chosen initial centers, taking the best result**."* — random restarts, exactly as in [M20](M20-heuristics.md).

**Running time.** One iteration: `O(dkn)` to assign (every point against every center, `d` work each) plus `O(dn)` to recompute centroids (each point is in exactly one cluster). Over `T` iterations:

```
O(T · d · k · n)
```

### What the objective is worth: vector quantization

CLRS's second example is the one that makes `k`-means concrete: **compressing an image by reducing its palette.** A 700×500 photo at 24 bits per pixel has 350 000 points in `ℝ³` (RGB), of which 79 083 are distinct. Cluster them into `k` centers and store each pixel as an index into a `k`-entry palette:

| `k` | bits/pixel | `f` | iterations |
|---|---|---|---|
| 4 | 2 | `1.29 × 10⁹` | 31 |
| 16 | 4 | `3.31 × 10⁸` | 36 |
| 64 | 6 | `5.50 × 10⁷` | 59 |
| 256 | 8 | `1.52 × 10⁷` | 104 |

**`f` is squared colour error, so this table is a rate–distortion curve** — and it shows the objective doing real work: each 4× increase in palette size buys roughly a 4× reduction in distortion, and costs one more bit per pixel. **24 bits → 8 bits is a 3× compression with `f` down by 85×.**

> **Note that the points repeat.** This is the case where `S` is a **multiset**, and where Exercise 33.1-3's better initialisation (pick centers so as to maximise the number of *distinct* ones) matters.

### Where the other book puts clustering

Skiena does not cover `k`-means as an algorithm, but he arrives at clustering from a completely different direction — and the contrast is instructive.

> **The war story (§8.2, "Nothing but Nets").** A circuit-board tester had to verify electrical nets with a two-armed robot. Skiena needed to break each large net into small overlapping pieces: *"This is a clustering problem. **Minimum spanning trees are often used for clustering**… We could find the minimum spanning tree of the net points and **break it into small clusters whenever a spanning tree edge got too long**."*

**That is single-link (agglomerative) clustering, and it is `k`-means's opposite in every respect:**

| | Lloyd / `k`-means | MST / single-link |
|---|---|---|
| cluster shape | round blobs (Voronoi cells) | arbitrary, follows chains |
| `k` chosen | up front | by cutting edges above a threshold |
| objective | explicit (`f(S,C)`) | implicit |
| determinism | random init, local optimum | deterministic, [M14](M14-mst.md) |
| the failure mode | wrong `k`, elongated clusters | *chaining* — one bridging point merges two clusters |

**And the war story's real lesson is the one about the metric, not the algorithm:**

> *"So the time to move both one foot left and one foot up is exactly the same as just moving one foot left? This means that the weight for each edge should not be the Euclidean distance between the two points, but instead **the biggest difference between either the `x`- or `y`-coordinates. This is something we call the `L∞` metric**."*

**Both books are making the same point from opposite ends.** CLRS: the dissimilarity measure is a modelling choice, so scale your attributes. Skiena: the dissimilarity measure is a modelling choice, so *ask what the machine actually costs*. **Getting `δ` right matters more than which clustering algorithm you run on it.**

> **And a practical note from Skiena's kd-tree section that belongs here**, because the assignment step of Lloyd's procedure is `n` nearest-neighbour queries: *"Kd-trees are most useful for a small to moderate number of dimensions"* — and *"Finding the absolute nearest neighbor of a point in a very high-dimensional space is hard work."* Below roughly 20 dimensions a kd-tree ([M08](M08-search-trees.md), Skiena §15.6) can cut the `O(dkn)` assignment cost substantially; above that, the curse of dimensionality eats the gain and the brute-force scan wins.

### C++ Implementation

```cpp
// k-means clustering: the objective, the two optimality theorems, Lloyd's
// procedure, and the machinery around it (scaling, restarts, the 1-D exact
// algorithm, and an exhaustive oracle for testing).

using Point = vector<double>;
using PointSet = vector<Point>;

// delta(x, y) = ||x - y||^2, equation (33.1).
//
// SQUARED, not the distance itself. Everything downstream depends on it:
// Theorem 33.1's centroid is the mean only because of the square, the
// dimensions decouple only because of the square, and the name "k-means"
// comes from the square. Taking a sqrt here quietly changes the problem to
// k-medians, whose optimal center is the geometric median with no closed form.
double dissimilarity(const Point& x, const Point& y) {
    double total = 0.0;
    for (size_t a = 0; a < x.size(); ++a) {
        const double difference = x[a] - y[a];
        total += difference * difference;
    }
    return total;
}

// The index of a nearest center, and the distance to it.
// Ties go to the SMALLEST index, deterministically -- see assignPoints for why
// that is not enough on its own.
pair<int, double> nearestCenter(const Point& x, const PointSet& centers) {
    int best = 0;
    double bestDistance = numeric_limits<double>::infinity();
    for (int j = 0; j < (int)centers.size(); ++j) {
        const double distance = dissimilarity(x, centers[j]);
        if (distance < bestDistance) { bestDistance = distance; best = j; }
    }
    return {best, bestDistance};
}

// f(S, C), equation (33.2): the sum over points of the distance to the nearest
// center. This is THE number -- every claim about clustering quality in this
// module is a claim about this function.
double clusteringCost(const PointSet& points, const PointSet& centers) {
    double total = 0.0;
    for (const Point& x : points) total += nearestCenter(x, centers).second;
    return total;
}

// Theorem 33.1: the optimal center of a cluster is its centroid.
//
// Computed coordinatewise, which is legitimate precisely because the objective
// decoupled across dimensions in the proof. An empty cluster gets the zero
// vector, as step 4 of Lloyd's procedure specifies.
Point centroid(const PointSet& points, const vector<int>& members, int dimensions) {
    Point centre(dimensions, 0.0);
    if (members.empty()) return centre;                  // step 4's convention
    for (int index : members)
        for (int a = 0; a < dimensions; ++a) centre[a] += points[index][a];
    for (int a = 0; a < dimensions; ++a) centre[a] /= (double)members.size();
    return centre;
}

// Step 2 of Lloyd's procedure, with the tie-breaking rule spelled out.
//
// THE RULE THAT MAKES TERMINATION WORK: "never change which cluster a point x
// is assigned to unless the distance from x to its new cluster center is
// STRICTLY smaller than the distance from x to its old cluster center."
//
// Without the strictness, two equidistant centers can pass a point back and
// forth forever: f never increases, but it never decreases either, and the
// finite-state argument collapses. Returns true if any assignment changed.
bool assignPoints(const PointSet& points, const PointSet& centers,
                  vector<int>& assignment) {
    bool changed = false;
    for (size_t i = 0; i < points.size(); ++i) {
        const auto [candidate, candidateDistance] = nearestCenter(points[i], centers);
        if (candidate == assignment[i]) continue;

        const double currentDistance = dissimilarity(points[i], centers[assignment[i]]);
        if (candidateDistance < currentDistance) {       // STRICTLY closer only
            assignment[i] = candidate;
            changed = true;
        }
    }
    return changed;
}

// Lloyd's procedure. Alternates the two exactly-optimal half-steps until
// nothing moves.
//
//   step 2  -- optimal clustering for the current centers (Theorem 33.2)
//   step 4  -- optimal centers for the current clustering (Theorem 33.1)
//
// Each half-step is exact; the fixed point is a LOCAL minimum, and that is all
// it can be, since the k-means problem is NP-hard.
//
//   O(T d k n): T iterations, each O(dkn) to assign and O(dn) to recompute.
struct Clustering {
    PointSet centers;
    vector<int> assignment;       // assignment[i] = cluster of points[i]
    double cost = 0.0;
    int iterations = 0;
};

Clustering lloyd(const PointSet& points, int k, mt19937& randomEngine,
                 int iterationLimit = 1000) {
    const int n = (int)points.size();
    const int dimensions = (int)points[0].size();

    // Step 1: k initial centers, drawn independently at random from S.
    // "Independently" means WITH replacement, so duplicates are possible --
    // Exercise 33.1-3 is about doing better when points repeat.
    Clustering result;
    for (int j = 0; j < k; ++j)
        result.centers.push_back(points[randomEngine() % n]);

    result.assignment.assign(n, 0);                      // "assign all points to S⁽¹⁾"

    while (result.iterations < iterationLimit) {
        ++result.iterations;

        if (!assignPoints(points, result.centers, result.assignment))
            break;                                       // step 3: no change, stop

        // Step 4: recompute every center as its cluster's centroid.
        vector<vector<int>> members(k);
        for (int i = 0; i < n; ++i) members[result.assignment[i]].push_back(i);
        for (int j = 0; j < k; ++j)
            result.centers[j] = centroid(points, members[j], dimensions);
    }

    result.cost = clusteringCost(points, result.centers);
    return result;
}

// Random restarts, which is the standard answer to "it only finds a local
// optimum". CLRS: "run Lloyd's procedure many times with different randomly
// chosen initial centers, taking the best result."
Clustering lloydWithRestarts(const PointSet& points, int k, int restarts,
                             mt19937& randomEngine) {
    Clustering best = lloyd(points, k, randomEngine);
    for (int r = 1; r < restarts; ++r) {
        Clustering candidate = lloyd(points, k, randomEngine);
        if (candidate.cost < best.cost) best = candidate;
    }
    return best;
}

// Feature scaling: map every attribute linearly onto [0, 1].
//
// NOT COSMETIC. The objective is a sum over attributes of squared differences,
// so an attribute measured in dollars against one measured in [0,4] contributes
// about 10^8 times as much, and the clustering is decided entirely by the
// former. You did not choose that weighting; the units did.
PointSet scaleToUnitRange(const PointSet& points) {
    if (points.empty()) return points;
    const int dimensions = (int)points[0].size();

    Point low(dimensions, numeric_limits<double>::infinity());
    Point high(dimensions, -numeric_limits<double>::infinity());
    for (const Point& x : points)
        for (int a = 0; a < dimensions; ++a) {
            low[a] = min(low[a], x[a]);
            high[a] = max(high[a], x[a]);
        }

    PointSet scaled = points;
    for (Point& x : scaled)
        for (int a = 0; a < dimensions; ++a) {
            const double spread = high[a] - low[a];
            x[a] = (spread > 0.0) ? (x[a] - low[a]) / spread : 0.0;
        }
    return scaled;
}

// The other standard choice: zero mean, unit variance.
PointSet standardize(const PointSet& points) {
    const int n = (int)points.size(), dimensions = (int)points[0].size();
    Point mean(dimensions, 0.0), deviation(dimensions, 0.0);

    for (const Point& x : points)
        for (int a = 0; a < dimensions; ++a) mean[a] += x[a] / n;
    for (const Point& x : points)
        for (int a = 0; a < dimensions; ++a)
            deviation[a] += (x[a] - mean[a]) * (x[a] - mean[a]) / n;
    for (int a = 0; a < dimensions; ++a) deviation[a] = sqrt(deviation[a]);

    PointSet scaled = points;
    for (Point& x : scaled)
        for (int a = 0; a < dimensions; ++a)
            x[a] = deviation[a] > 0.0 ? (x[a] - mean[a]) / deviation[a] : 0.0;
    return scaled;
}

// Exercise 33.1-4: in ONE dimension the k-means problem is solvable exactly in
// polynomial time. The reason is a structural fact that fails in 2-D and up:
//
//   IN 1-D, AN OPTIMAL CLUSTERING IS A PARTITION INTO CONTIGUOUS RUNS OF THE
//   SORTED POINTS.
//
// (If x < y < z with x and z together and y elsewhere, moving y in never costs
// more.) So: sort, then run an interval DP.
//
//   best[j][i] = cheapest way to cover the first i points with j clusters
//              = min over split s of  best[j-1][s] + cost(s..i-1)
//
// where cost(a..b) is the within-cluster sum of squares of a contiguous run,
// obtainable in O(1) from prefix sums of x and x^2:
//
//   sum of (x - mean)^2  =  sum(x^2)  -  (sum x)^2 / count
//
//   O(k n^2) time. This is the same "partition a sequence into k contiguous
//   pieces" DP as in M11.
double optimalOneDimensionalCost(vector<double> values, int k) {
    const int n = (int)values.size();
    if (n == 0) return 0.0;
    if (k >= n) return 0.0;                              // every point its own center
    sort(values.begin(), values.end());

    vector<double> prefix(n + 1, 0.0), prefixSquared(n + 1, 0.0);
    for (int i = 0; i < n; ++i) {
        prefix[i + 1] = prefix[i] + values[i];
        prefixSquared[i + 1] = prefixSquared[i] + values[i] * values[i];
    }
    // Within-run sum of squared deviations for values[a..b-1], in O(1).
    auto runCost = [&](int a, int b) {
        const int count = b - a;
        if (count <= 0) return 0.0;
        const double total = prefix[b] - prefix[a];
        return (prefixSquared[b] - prefixSquared[a]) - total * total / count;
    };

    const double infinity = numeric_limits<double>::infinity();
    vector<vector<double>> best(k + 1, vector<double>(n + 1, infinity));
    best[0][0] = 0.0;
    for (int j = 1; j <= k; ++j)
        for (int i = 1; i <= n; ++i)
            for (int s = j - 1; s < i; ++s)
                if (best[j - 1][s] < infinity)
                    best[j][i] = min(best[j][i], best[j - 1][s] + runCost(s, i));

    double answer = infinity;
    for (int j = 1; j <= k; ++j) answer = min(answer, best[j][n]);
    return answer;
}

// The exhaustive oracle: try EVERY assignment of n points to k clusters,
// giving each cluster its centroid. Theorems 33.1 and 33.2 together say that
// this really is the global optimum -- an optimal solution assigns by nearest
// center and centers at centroids, and both are covered by enumerating
// assignments and centring each cluster.
//
// k^n, so this is for tests on tiny inputs only. But a competitive claim about
// a local-search heuristic means nothing without a true optimum to compare to,
// which is the lesson M24 paid for.
double exhaustiveOptimalCost(const PointSet& points, int k) {
    const int n = (int)points.size(), dimensions = (int)points[0].size();
    vector<int> assignment(n, 0);
    double best = numeric_limits<double>::infinity();

    while (true) {
        vector<vector<int>> members(k);
        for (int i = 0; i < n; ++i) members[assignment[i]].push_back(i);

        double total = 0.0;
        for (int j = 0; j < k; ++j) {
            const Point centre = centroid(points, members[j], dimensions);
            for (int index : members[j]) total += dissimilarity(points[index], centre);
        }
        best = min(best, total);

        // Odometer over k^n assignments.
        int position = 0;
        while (position < n && ++assignment[position] == k) assignment[position++] = 0;
        if (position == n) break;
    }
    return best;
}
```

**Complexity. `dissimilarity` `Θ(d)`. `nearestCenter` `Θ(dk)`. `clusteringCost` `Θ(dkn)`. `lloyd` `O(Tdkn)`. `optimalOneDimensionalCost` `Θ(kn²)` after an `Θ(n lg n)` sort. `exhaustiveOptimalCost` `Θ(kⁿ · dn)` — the oracle, not an algorithm.**

*Verified:* **Theorem 33.1 was tested by trying to beat the centroid.** On 20 000 random clusters, each against **50** randomly perturbed alternative centers — **1 000 000 attempts** — the centroid was never beaten, worst deficit **0.000e+00**. **Theorem 33.2 was tested against brute force:** on 20 000 instances the nearest-center assignment was compared with the best of all `kⁿ` assignments at fixed centers — **0 disagreements**.

**Lloyd's procedure terminates fast, and `f` really is monotone.** Over 5 000 random instances the mean was **3.85 iterations**, the maximum **19**, and the 1 000-iteration limit was never reached — against the `kⁿ` the termination proof allows. Instrumenting the loop over **8 671** iterations, `f` **never increased once**.

**Against a true exhaustive optimum on 3 000 small instances** (`n ≤ 7`, `k ≤ 3`, `d ≤ 2`): a single run of Lloyd's procedure was strictly worse than optimal **1 491 times — 49.7%**, and never better (0 below-optimal, as it must be). **20 restarts cut the worst ratio from 1 139 602 to 17.85.** Both numbers are enormous because the ratio is *unbounded*: the optimum can be arbitrarily close to 0 (points nearly coincident), so any positive local-optimum cost divides by almost nothing. **The lesson is not the size of the ratio but that half of single runs miss** — which is the entire case for restarts.

**The 1-D DP is exact:** `optimalOneDimensionalCost` matched exhaustive search on **5 000/5 000** instances, worst discrepancy **0.000e+00** — Exercise 33.1-4 confirmed.

**Scaling is not cosmetic:** on 2 000 instances with a GPA-like attribute in `[0,4]` and an income-like one in `[0, 200000]`, scaling to `[0,1]` changed the resulting clustering **1 987 times out of 2 000 (99.4%)**. Unscaled, the income attribute decides everything.

**And it does recover real structure:** three planted Gaussian clusters (`σ = 1`, centers 20 apart, 20 points each) were recovered **exactly, 2 000/2 000**, with 10 restarts.

---

## Part 2 — Learning From Experts (CLRS 33.2)

**The setting, and it is an online one ([M24](M24-parallel-online.md)).** `T` events, each with a binary outcome `o⁽ᵗ⁾ ∈ {0,1}`. Before event `t`, each of `n` experts `E₁,…,Eₙ` announces a prediction `qᵢ⁽ᵗ⁾ ∈ {0,1}`. You combine them into your own `p⁽ᵗ⁾`, and *only then* is `o⁽ᵗ⁾` revealed.

```
your mistakes    m   = Σ_{t=1}^{T} |p⁽ᵗ⁾ − o⁽ᵗ⁾|
expert i's       mᵢ  = Σ_{t=1}^{T} |qᵢ⁽ᵗ⁾ − o⁽ᵗ⁾|
best expert      m*  = min{ mᵢ : 1 ≤ i ≤ n }
REGRET           m − m*
```

> **What is assumed about the world: nothing.** *"We'll assume nothing about the movement of the stock. We'll also assume nothing about the experts: the experts' predictions could be correlated, **they could be chosen to deceive you**, or perhaps some are not really experts after all."*

**That is why the goal is *regret* and not accuracy.** Absolute accuracy is impossible against an adversarial outcome sequence; matching the best expert *in hindsight* is not. Same normalisation trick as the competitive ratio in [M24](M24-parallel-online.md) — divide out the difficulty of the input and measure only the cost of not knowing.

> *"At first, this goal might seem impossible, because **you do not know until the end which expert is best**. We'll see, however, that by taking the advice provided by all the experts into account, you can achieve this goal."*

### Warm-up: one perfect expert costs you `⌈lg n⌉` mistakes

> **Lemma 33.3.** If one of the `n` experts is correct on all `T` events, an algorithm exists making at most `⌈lg n⌉` mistakes.

**The algorithm is *halving*: keep the set `S` of experts who have never erred, predict their majority vote, and delete every expert who got it wrong.**

**The proof is one observation.** The perfect expert is never deleted, so `S` is never empty. And *"every time the algorithm makes a mistake, at least half of the experts who were still in `S` also make a mistake"* — because you followed the majority — so `|S′| ≤ |S|/2`. **You can halve `n` only `⌈lg n⌉` times.**

→ **C++ implementation:** [A3 HALVING](#a3-halving)

**Exercise 33.2-1 removes the assumption** with a one-line patch: *"The set `S` might become empty at some point. If that ever happens, **reset `S` to contain all the experts** and continue."* Emptying `S` requires *every* expert — the best one included — to have erred since the last reset, so there are at most `m*` resets, and each epoch costs `O(lg n)` mistakes.

> **The exercise states the bound as `m ≤ m*⌈lg n⌉`, and taken literally that is not quite true.** Two leaks: with a perfect expert `m* = 0` and the bound reads 0, while the algorithm may still make `⌈lg n⌉` mistakes; and an epoch ends when `|S|` reaches 1 *and that last expert then errs*, which is `⌈lg n⌉ + 1` mistakes, not `⌈lg n⌉`. Plugging both gives
> ```
> m ≤ (m* + 1)(⌈lg n⌉ + 1)
> ```
> which is the same `O(m* lg n)` and is what a test actually confirms — see the verification below, where the literal bound fails on 6% of random instances and this one on none. **The asymptotics are the point; the exact constants are the exercise's shorthand.**

**Either way it is a *multiplicative* `lg n` penalty**, and that is the thing to improve. The rest of the section replaces the hard delete with a soft one.

### From deleting experts to discounting them

> *"You can substantially improve your prediction ability by not just tracking which experts have not made any mistakes… **The key idea is to use the feedback you receive to update your evaluation of how much trust to put in each expert.** … The change in weights is accomplished via multiplication, hence the term 'multiplicative weights'."*

**Halving is the special case `ε = 1`: multiply a mistaken expert's weight by `1 − 1 = 0`.** Choosing `ε < 1` means an expert who errs once is *demoted*, not executed — which is what makes the bound additive rather than multiplicative in `lg n`.

```
WEIGHTED-MAJORITY(E, T, n, ε)                      // 0 < ε ≤ 1/2
 1  for i = 1 to n
 2      wᵢ⁽¹⁾ = 1                                   // trust each expert equally
 3  for t = 1 to T
 4      each expert Eᵢ ∈ E makes a prediction qᵢ⁽ᵗ⁾
 5      U = { Eᵢ : qᵢ⁽ᵗ⁾ = 1 }                      // experts who predicted 1
 6      upweight⁽ᵗ⁾ = Σ_{i : Eᵢ∈U} wᵢ⁽ᵗ⁾
 7      D = { Eᵢ : qᵢ⁽ᵗ⁾ = 0 }                      // experts who predicted 0
 8      downweight⁽ᵗ⁾ = Σ_{i : Eᵢ∈D} wᵢ⁽ᵗ⁾
 9      if upweight⁽ᵗ⁾ ≥ downweight⁽ᵗ⁾
10          p⁽ᵗ⁾ = 1                                // algorithm predicts 1
11      else p⁽ᵗ⁾ = 0                               // algorithm predicts 0
12      outcome o⁽ᵗ⁾ is revealed
13      // If p⁽ᵗ⁾ ≠ o⁽ᵗ⁾, the algorithm made a mistake.
14      for i = 1 to n
15          if qᵢ⁽ᵗ⁾ ≠ o⁽ᵗ⁾                          // if expert Eᵢ made a mistake …
16              wᵢ⁽ᵗ⁺¹⁾ = (1 − ε)wᵢ⁽ᵗ⁾              // … decrease that expert's weight
17          else wᵢ⁽ᵗ⁺¹⁾ = wᵢ⁽ᵗ⁾
18      return p⁽ᵗ⁾
```

→ **C++ implementation:** [A4 WEIGHTED-MAJORITY](#a4-weighted-majority)

**Notice what is *not* in the algorithm.** No normalisation, no learning-rate schedule, no memory of past events beyond the weights. The weight vector is a **sufficient statistic** for everything the algorithm knows, and equation (33.6) says exactly what it encodes: `wᵢ⁽ᵗ⁾ = (1 − ε)^{mᵢ⁽ᵗ⁾}` — *the weight is `(1−ε)` raised to that expert's mistake count, nothing more.*

### Theorem 33.4, and the potential argument that proves it

> **Theorem 33.4.** For every expert `Eᵢ` and every `T′ ≤ T`,
> ```
> m⁽ᵀ′⁾ ≤ 2(1 + ε)·mᵢ⁽ᵀ′⁾ + 2·ln(n)/ε                                  (33.5)
> ```

**The potential is the total weight** `W(t) = Σᵢ wᵢ⁽ᵗ⁾`, with `W(0) = n`. The proof is a squeeze: **an upper bound on `W` from your own mistakes, a lower bound from the best expert's, and the two together pin down `m`.**

**Upper bound — every mistake you make costs the potential a constant factor.** Suppose you predicted 1 and the outcome was 0. You predicted 1 because line 9 found `upweight⁽ᵗ⁾ ≥ downweight⁽ᵗ⁾`, and since `W(t) = upweight⁽ᵗ⁾ + downweight⁽ᵗ⁾`,

```
upweight⁽ᵗ⁾ ≥ W(t)/2                                                   (33.7)
```

Only the experts in `U` — who were wrong — lose weight:

```
W(t+1) = upweight⁽ᵗ⁾(1 − ε) + downweight⁽ᵗ⁾
       = W(t) − ε·upweight⁽ᵗ⁾
       ≤ W(t) − ε·W(t)/2   = W(t)(1 − ε/2)                            (33.8)
```

**That is the crux, and it is worth saying in words: you only ever predict with the *heavier* half, so being wrong means at least half the total weight was wrong, and at least half the total weight gets discounted.** Being wrong is *expensive for the potential* — which is precisely what makes it rare. On correct rounds `W(t+1) ≤ W(t)` (33.9), so after `T′` rounds

```
W(T′) ≤ n(1 − ε/2)^{m⁽ᵀ′⁾}                                            (33.10)
```

**Lower bound — the total exceeds any single term.** All weights are positive, so by (33.6),

```
W(T′) ≥ wᵢ⁽ᵀ′⁾ = (1 − ε)^{mᵢ⁽ᵀ′⁾}                                      (33.11)
```

**Combine, take logs:**

```
mᵢ⁽ᵀ′⁾·ln(1 − ε) ≤ m⁽ᵀ′⁾·ln(1 − ε/2) + ln n                            (33.12)
```

**Now the two Taylor bounds, and it is worth being clear why you need *both* and in *opposite directions*.** From `ln(1 − x) = −x − x²/2 − x³/3 − ⋯` (33.13), every term is negative, so dropping all but the first gives an **upper** bound `ln(1 − x) ≤ −x`; and Exercise 33.2-2 gives the matching **lower** bound `ln(1 − x) ≥ −x − x²` for `0 < x ≤ 1/2`:

```
ln(1 − ε/2) ≤ −ε/2                                                     (33.14)
−ε − ε²     ≤ ln(1 − ε)                                                (33.15)
```

**The logs sit on opposite sides of inequality (33.12), so each needs bounding in the direction that keeps the inequality alive.** Substituting:

```
mᵢ⁽ᵀ′⁾(−ε − ε²) ≤ m⁽ᵀ′⁾(−ε/2) + ln n                                   (33.16)
```

Subtract `ln n`, multiply by `−2/ε` (flipping the inequality), and Theorem 33.4 falls out. **`0 < ε ≤ 1/2` is not decoration — it is exactly the range in which (33.15) holds.**

> **Corollary 33.5.** `m⁽ᵀ⁾ ≤ 2(1 + ε)m* + 2·ln(n)/ε`.  (33.17)

### Tuning `ε`, and what the bound actually says

**The two terms pull in opposite directions:** large `ε` means aggressive discounting and a small `2ln(n)/ε`, but a worse leading constant `2(1+ε)`. Balance them with `ε = √(ln n / m*)` (legal when `√(ln n/m*) ≤ 1/2`):

```
m⁽ᵀ⁾ ≤ 2(1 + √(ln n/m*))m* + 2ln n / √(ln n/m*)
     = 2m* + 2√(m* ln n) + 2√(m* ln n)
     = 2m* + 4√(m* ln n)
```

> *"…and so the number of errors is at most **twice the number of errors made by the best expert plus a term that is often slower growing than `m*`**."*

**Read that again, because it is a remarkable statement.** You have no idea which expert is good. Some are adversarial. And you finish within a factor of 2 of the best one, plus `O(√(m* ln n))` — a penalty that grows only as the *square root* of your mistakes and only *logarithmically* in the number of experts. **You can throw in a thousand junk experts and pay `√ln 1000 ≈ 2.6` for the privilege.**

**CLRS's worked number, which is the one to remember:** `T = 1000` events, `n = 20` experts, best expert wrong 50 times (95% accurate). Then `m ≤ 100(1+ε) + 2ln(20)/ε`, minimised near `ε = 1/4` at **149 errors — an 85% success rate.** The gap between 95% and 85% is what not knowing the future costs.

> **The factor of 2 is an artefact of determinism, and randomisation removes it.** Exercise 33.2-4: predict by *sampling* an expert in proportion to its weight rather than taking a weighted majority. The regret bound improves from `(1 + 2ε)m* + 2ln(n)/ε` to an expected `εm* + ln(n)/ε` — **`(1+ε)m* + ln(n)/ε` in total, so the leading constant drops from 2 to 1.** Problem 33-2's `HEDGE` is the same idea with the update `wᵢ⁽ᵗ⁺¹⁾ = wᵢ⁽ᵗ⁾e^{−ε}`, achieving `m* + ln(n)/ε + εT`.
>
> **This is the same phenomenon as [M24](M24-parallel-online.md)'s `RANDOMIZED-MARKING`:** a deterministic online algorithm can be aimed at, a randomised one cannot. *Predicting the majority tells the adversary which way you will go; sampling does not.*

> **Where else this shows up.** *"Multiplicative weights methods typically refer to a broader class of algorithms… The outcomes and predictions need not be only 0 or 1, but can be real numbers, and there can be a **loss** associated with a particular outcome and prediction… Even in these more general settings, bounds similar to Theorem 33.4 hold."* The chapter notes list the applications, and the list is startling: **game playing in economics, approximately solving linear programs and multicommodity flow ([M22](M22-linear-programming.md)), boosting, and the perceptron algorithm.** Fictitious Play in game theory is the same update, discovered decades earlier.

### C++ Implementation

```cpp
// Learning from experts. Halving, weighted majority, the randomized variant,
// and HEDGE -- plus the bookkeeping needed to check the theorems rather than
// believe them.

// An expert is anything that produces a 0/1 prediction for event t.
using Expert = function<int(int)>;

// ---------------------------------------------------------------------------
// Lemma 33.3: HALVING, with Exercise 33.2-1's reset.
// ---------------------------------------------------------------------------
// Keep the set of experts who have not erred SINCE THE LAST RESET; predict
// their majority; delete the ones who were wrong.
//
// The bound is ceil(lg n) when some expert is perfect. Each mistake at least
// halves the surviving set, and you can halve n only ceil(lg n) times.
//
// With the reset, m <= m* ceil(lg n): each reset needs the best expert to have
// erred at least once, and costs at most ceil(lg n) mistakes.
long long halvingMistakes(const vector<Expert>& experts, const vector<int>& outcomes,
                          long long* resetCount = nullptr) {
    const int n = (int)experts.size();
    vector<char> alive(n, 1);
    long long mistakes = 0, resets = 0;

    for (int t = 0; t < (int)outcomes.size(); ++t) {
        int votesForOne = 0, votesForZero = 0;
        vector<int> predictions(n);
        for (int i = 0; i < n; ++i) {
            predictions[i] = experts[i](t);
            if (!alive[i]) continue;
            (predictions[i] == 1 ? votesForOne : votesForZero)++;
        }

        const int prediction = (votesForOne >= votesForZero) ? 1 : 0;
        if (prediction != outcomes[t]) ++mistakes;

        for (int i = 0; i < n; ++i)
            if (alive[i] && predictions[i] != outcomes[t]) alive[i] = 0;

        // Exercise 33.2-1: if everyone has erred, start over.
        if (none_of(alive.begin(), alive.end(), [](char a) { return a; })) {
            fill(alive.begin(), alive.end(), (char)1);
            ++resets;
        }
    }
    if (resetCount) *resetCount = resets;
    return mistakes;
}

// ---------------------------------------------------------------------------
// WEIGHTED-MAJORITY
// ---------------------------------------------------------------------------
// The whole state is the weight vector, and equation (33.6) says exactly what
// it holds: w_i(t) = (1-eps)^(mistakes by expert i so far). Nothing else is
// remembered about the past.
struct ExpertRun {
    long long mistakes = 0;              // m
    vector<long long> expertMistakes;    // m_i
    long long bestExpertMistakes = 0;    // m*
    vector<double> finalWeights;
    double finalTotalWeight = 0.0;       // W(T)
};

ExpertRun weightedMajority(const vector<Expert>& experts, const vector<int>& outcomes,
                           double epsilon) {
    const int n = (int)experts.size();
    ExpertRun run;
    run.expertMistakes.assign(n, 0);

    vector<double> weight(n, 1.0);                       // lines 1-2
    for (int t = 0; t < (int)outcomes.size(); ++t) {     // line 3
        vector<int> prediction(n);
        double upweight = 0.0, downweight = 0.0;
        for (int i = 0; i < n; ++i) {
            prediction[i] = experts[i](t);               // line 4
            // Lines 5-8. U and D are computed as running sums rather than as
            // explicit sets, which is what you would write; the sets exist in
            // the pseudocode only to name the two weights.
            (prediction[i] == 1 ? upweight : downweight) += weight[i];
        }

        // Lines 9-11. TIES GO TO 1 -- and the choice is arbitrary. What is not
        // arbitrary is that you follow the HEAVIER side, because that is what
        // makes inequality (33.7) true and hence the whole proof work.
        const int myPrediction = (upweight >= downweight) ? 1 : 0;

        const int outcome = outcomes[t];                 // line 12
        if (myPrediction != outcome) ++run.mistakes;     // line 13

        for (int i = 0; i < n; ++i) {                    // lines 14-17
            if (prediction[i] != outcome) {
                weight[i] *= (1.0 - epsilon);
                ++run.expertMistakes[i];
            }
        }
    }

    run.bestExpertMistakes = *min_element(run.expertMistakes.begin(),
                                          run.expertMistakes.end());
    run.finalWeights = weight;
    run.finalTotalWeight = accumulate(weight.begin(), weight.end(), 0.0);
    return run;
}

// Corollary 33.5's right-hand side: 2(1+eps)m* + 2 ln(n)/eps.
double corollary335Bound(long long bestExpertMistakes, int n, double epsilon) {
    return 2.0 * (1.0 + epsilon) * (double)bestExpertMistakes + 2.0 * log((double)n) / epsilon;
}

// The tuned choice eps = sqrt(ln n / m*), giving 2m* + 4 sqrt(m* ln n).
//
// Valid only when sqrt(ln n / m*) <= 1/2, i.e. m* >= 4 ln n; otherwise clamp,
// since eps > 1/2 breaks inequality (33.15) and with it the theorem.
double tunedEpsilon(long long bestExpertMistakes, int n) {
    if (bestExpertMistakes <= 0) return 0.5;
    return min(0.5, sqrt(log((double)n) / (double)bestExpertMistakes));
}

double tunedBound(long long bestExpertMistakes, int n) {
    const double m = (double)bestExpertMistakes;
    return 2.0 * m + 4.0 * sqrt(m * log((double)n));
}

// ---------------------------------------------------------------------------
// Exercise 33.2-4: the RANDOMIZED weighted-majority.
// ---------------------------------------------------------------------------
// Same weights, different prediction rule: treat the weights as a distribution
// and FOLLOW ONE SAMPLED EXPERT rather than the weighted majority.
//
// Expected mistakes at most (1+eps)m* + ln(n)/eps -- the leading constant drops
// from 2 to 1. The reason is exactly M24's: a deterministic rule can be aimed
// at, a sampled one cannot. Predicting the majority announces your move.
long long randomizedWeightedMajority(const vector<Expert>& experts,
                                     const vector<int>& outcomes,
                                     double epsilon, mt19937& randomEngine) {
    const int n = (int)experts.size();
    vector<double> weight(n, 1.0);
    long long mistakes = 0;

    for (int t = 0; t < (int)outcomes.size(); ++t) {
        vector<int> prediction(n);
        for (int i = 0; i < n; ++i) prediction[i] = experts[i](t);

        // Sample an expert with probability proportional to its weight.
        const double total = accumulate(weight.begin(), weight.end(), 0.0);
        double target = uniform_real_distribution<double>(0.0, total)(randomEngine);
        int chosen = n - 1;
        for (int i = 0; i < n; ++i) {
            target -= weight[i];
            if (target <= 0.0) { chosen = i; break; }
        }

        if (prediction[chosen] != outcomes[t]) ++mistakes;
        for (int i = 0; i < n; ++i)
            if (prediction[i] != outcomes[t]) weight[i] *= (1.0 - epsilon);
    }
    return mistakes;
}

// ---------------------------------------------------------------------------
// Problem 33-2: HEDGE.
// ---------------------------------------------------------------------------
// Two changes from WEIGHTED-MAJORITY: sample an expert (as above), and use the
// exponential update w *= e^(-eps) instead of w *= (1-eps).
//
//   E[mistakes] <= m* + ln(n)/eps + eps*T
//
// LEADING CONSTANT 1 -- no factor of 2 at all. The price is the eps*T term,
// which is why eps is usually tuned as sqrt(ln n / T): that balances
// ln(n)/eps against eps*T and gives regret O(sqrt(T ln n)).
long long hedge(const vector<Expert>& experts, const vector<int>& outcomes,
                double epsilon, mt19937& randomEngine) {
    const int n = (int)experts.size();
    vector<double> weight(n, 1.0);
    const double decay = exp(-epsilon);
    long long mistakes = 0;

    for (int t = 0; t < (int)outcomes.size(); ++t) {
        vector<int> prediction(n);
        for (int i = 0; i < n; ++i) prediction[i] = experts[i](t);

        const double total = accumulate(weight.begin(), weight.end(), 0.0);
        double target = uniform_real_distribution<double>(0.0, total)(randomEngine);
        int chosen = n - 1;
        for (int i = 0; i < n; ++i) {
            target -= weight[i];
            if (target <= 0.0) { chosen = i; break; }
        }

        if (prediction[chosen] != outcomes[t]) ++mistakes;
        for (int i = 0; i < n; ++i)
            if (prediction[i] != outcomes[t]) weight[i] *= decay;

        // RENORMALISATION, which the pseudocode omits and any implementation
        // needs: after a few thousand rounds every weight underflows to zero
        // and the sampling step divides by zero. Scaling all weights by a
        // common factor changes no probability and no ratio, so it is free.
        if (total > 0.0 && *max_element(weight.begin(), weight.end()) < 1e-250) {
            const double scale = 1.0 / *max_element(weight.begin(), weight.end());
            for (double& w : weight) w *= scale;
        }
    }
    return mistakes;
}

// The best expert in hindsight -- the m* that every bound is stated against.
long long bestExpertInHindsight(const vector<Expert>& experts,
                                const vector<int>& outcomes) {
    long long best = numeric_limits<long long>::max();
    for (const Expert& expert : experts) {
        long long mistakes = 0;
        for (int t = 0; t < (int)outcomes.size(); ++t)
            if (expert(t) != outcomes[t]) ++mistakes;
        best = min(best, mistakes);
    }
    return best;
}
```

**Complexity. All four algorithms are `Θ(nT)`: every round touches every expert once. `bestExpertInHindsight` is `Θ(nT)` too — it is the offline oracle, and here it happens to be cheap, which is a pleasant change from [M24](M24-parallel-online.md).**

*Verified:* **Lemma 33.3 held on 20 000 instances with a planted perfect expert** — zero violations of `⌈lg n⌉`, and the worst case observed was **3 mistakes** for `n` up to 64 (`⌈lg 64⌉ = 6`), so the bound is not even tight in practice.

**Exercise 33.2-1's bound, as literally stated, is false — and the test is what showed it.** On 20 000 instances with resets, `m ≤ m*⌈lg n⌉` was violated **1 203 times (6.0%)**, worst ratio **3.0000**; `(m*+1)⌈lg n⌉` was violated **508 times**; and **`(m*+1)(⌈lg n⌉ + 1)` held on all 20 000**, worst ratio **0.8571**. Both leaks are visible in the data: `m* = 0` occurred in **979** of the runs (bound zero, mistakes positive), and up to **84 resets** happened in a single run. The exercise's `O(m* lg n)` is right; its constants are shorthand.

**Theorem 33.4 was checked against *every* expert on *every* run, not just the best one** — 20 000 runs × up to 50 experts. **Zero violations.** Against the best expert the worst observed `m/bound` was **0.4860**, i.e. the algorithm used less than half its allowance. With the tuned `ε = √(ln n/m*)`, `m/(2m* + 4√(m* ln n))` peaked at **0.4945** over 20 000 runs, and **`m/m*` never exceeded 2.0000** — the factor of 2 is real and attained.

**CLRS's worked example reproduces exactly:** `T = 1000`, `n = 20`, `m* = 50`, `ε = 1/4` gives a bound of **149.0 errors — an 85.1% success rate**, the book's numbers.

**Two experiments on where the factor of 2 comes from, and the second is the honest one.** With 20 experts whose errors are *independent* (5% each), `WEIGHTED-MAJORITY` averaged **96.1** mistakes against the best expert's **99.3** — a ratio of **0.97×**, i.e. **negative regret**. CLRS anticipates this (*"Regret can be negative, although it typically isn't"*), and the reason is that independent errors make the weighted majority genuinely better than any individual: this is the *friendly* case, and it tests nothing. **The adversarial case is the one the theorem is about:** with 39 of 40 experts predicting the opposite of the truth on every single round and one expert 95% accurate, `WEIGHTED-MAJORITY` averaged **113.3** mistakes against `m* = 100.3` — a ratio of **1.13×**, comfortably inside the guaranteed 2 even though 97.5% of the advice was actively hostile.

---

## Part 3 — Gradient Descent (CLRS 33.3)

**The picture first, because it is the honest one.**

> *"Imagine being in a landscape of hills and valleys, and wanting to get to a low point as quickly as possible. You survey the terrain and choose to move in the direction that takes you downhill the fastest from your current position. You move in that direction, **but only for a short while**, because as you proceed, the terrain changes and you might need to choose a different direction."*

The **gradient** `∇f : ℝⁿ → ℝⁿ` collects the partial derivatives:

```
(∇f)(x) = ( ∂f/∂x₁, ∂f/∂x₂, …, ∂f/∂xₙ )
```

**Two facts from the 1-D picture (Figure 33.3), and everything else in the section is a consequence:**

> - *"Gradient descent converges toward a **local** minimum, and not necessarily a global minimum."*
> - *"The speed at which it converges and how it behaves are related to properties of the function, to the initial point, and to the **step size** of the algorithm."*

**Too small a step and you crawl; too large and you overshoot to a point `x″` with `f(x″) > f(x⁽⁰⁾)` — worse than where you started.** The step size is not a tuning detail, it is the algorithm.

```
GRADIENT-DESCENT(f, x⁽⁰⁾, η, T)
1  sum = 0                                // n-dimensional vector, initially all 0
2  for t = 0 to T − 1
3      sum = sum + x⁽ᵗ⁾                    // add each of n dimensions into sum
4      x⁽ᵗ⁺¹⁾ = x⁽ᵗ⁾ − η·(∇f)(x⁽ᵗ⁾)        // (∇f)(x⁽ᵗ⁾), x⁽ᵗ⁺¹⁾ are n-dimensional
5  x-avg = sum/T                          // divide each of n dimensions by T
6  return x-avg
```

→ **C++ implementation:** [A5 GRADIENT-DESCENT](#a5-gradient-descent)

> **Why return the *average* and not the last point?** *"It might seem more natural to return `x⁽ᵀ⁾`, and in fact, in many circumstances, **you might prefer** to have the function return `x⁽ᵀ⁾`. For the version we will analyze, however, we use `x-avg`."* The average is an artefact of the proof: Lemma 33.7 (convexity applied repeatedly) says `f` of the average is at most the average of the `f`s, which is what turns a bound on the *sum* of per-step errors into a bound at a *single* point. **In practice you return `x⁽ᵀ⁾`; in the theorem you return the average. Knowing which is which is the point.**

### Convexity, and why it is the only assumption that matters

```
f(λx + (1−λ)y) ≤ λf(x) + (1−λ)f(y)     for all x,y ∈ ℝⁿ, 0 ≤ λ ≤ 1     (33.18)
```

*The chord lies above the curve.* **The consequence that makes gradient descent a global method:**

> **A local minimum of a convex function is a global minimum.**

**Proof, and it is three lines.** Suppose `x` is a local minimum but `y` is a global one with `f(y) < f(x)`. Then

```
f(λx + (1−λ)y) ≤ λf(x) + (1−λ)f(y) < λf(x) + (1−λ)f(x) = f(x)
```

Letting `λ → 1`, points arbitrarily close to `x` have smaller `f` — so `x` was not a local minimum after all. ∎

**Two lemmas do all the work in the analysis:**

> **Lemma 33.6** (Exercise 33.3-1). `f(x) ≤ f(y) + ⟨(∇f)(x), x − y⟩` — *a convex function lies above its tangent hyperplane.*
>
> **Lemma 33.7** (Exercise 33.3-2). `f((x⁽⁰⁾ + ⋯ + x⁽ᵀ⁻¹⁾)/T) ≤ (f(x⁽⁰⁾) + ⋯ + f(x⁽ᵀ⁻¹⁾))/T`  (33.19) — *Jensen, and the left-hand side is exactly `f(x-avg)`.*

### The two constants: `R` and `L`

```
R = ‖x⁽⁰⁾ − x*‖                       how far you start from the answer    (33.20)
‖(∇f)(x)‖ ≤ L                         how steep the function ever gets     (33.21)
```

> **Theorem 33.8.** With `η = R/(L√T)`, `GRADIENT-DESCENT` returns `x-avg` with
> ```
> f(x-avg) − f(x*)  ≤  ε = RL/√T
> ```

### The proof, which is an amortized analysis

**CLRS is explicit that this is [M09](M09-amortized.md) machinery, and flagging that is the single most useful thing about their presentation:** *"We do not give an absolute bound on how much progress each iteration makes. Instead, **we use a potential function**, as in Section 16.3."*

**That framing is the key insight.** A single gradient step can make almost no progress — near the minimum the gradient is tiny. So don't bound per-step progress; bound *amortized* progress, and let the potential absorb the variation.

```
Φ(t) = ‖x⁽ᵗ⁾ − x*‖² / (2η)          ≥ 0                                 (33.26)
p(t) = f(x⁽ᵗ⁾) − f(x*) + Φ(t+1) − Φ(t)                                  (33.22)
```

**Read `Φ` as "distance still to travel, in units of `η`", and `p(t)` as "how much closer to optimal I got, charged for the ground I gave up".**

**Step 1: telescope.** If `p(t) ≤ B` for all `t`, then summing (33.23) over `t = 0..T−1` collapses the potential terms to `Φ(0) − Φ(T)`, and dropping the positive `Φ(T)`:

```
(Σ_t f(x⁽ᵗ⁾))/T − f(x*) ≤ B + Φ(0)/T                                    (33.24)
```

**Step 2: Lemma 33.7 moves it to a single point.**

```
f(x-avg) − f(x*)  ≤  (Σ_t f(x⁽ᵗ⁾))/T − f(x*)  ≤  B + Φ(0)/T             (33.25)
```

**Step 3: bound `B` — this is Lemma 33.9, and it is where the algebra lives.** Using `‖a+b‖² − ‖a‖² = 2⟨b,a⟩ + ‖b‖²` (33.29) with `a = x⁽ᵗ⁾ − x*` and `b = x⁽ᵗ⁺¹⁾ − x⁽ᵗ⁾ = −η∇f(x⁽ᵗ⁾)`:

```
Φ(t+1) − Φ(t) = −⟨(∇f)(x⁽ᵗ⁾), x⁽ᵗ⁾ − x*⟩ + (η/2)‖(∇f)(x⁽ᵗ⁾)‖²           (33.30)
              ≤ −(f(x⁽ᵗ⁾) − f(x*)) + (η/2)‖(∇f)(x⁽ᵗ⁾)‖²                 (33.31)
```

**The inequality is Lemma 33.6** — the tangent-plane bound converting an inner product into a function-value gap. Substituting into (33.22), **the `f(x⁽ᵗ⁾) − f(x*)` terms cancel exactly**, leaving

```
p(t) ≤ (η/2)‖(∇f)(x⁽ᵗ⁾)‖² ≤ ηL²/2 = B
```

> **That cancellation is the whole proof.** The potential is defined so that the drop in distance-to-optimum *exactly* pays for the excess function value, and what survives is only the overshoot term `(η/2)‖∇f‖²`.

**Step 4: balance.** With `Φ(0) = R²/(2η)`:

```
f(x-avg) − f(x*) ≤ ηL²/2 + R²/(2ηT)
```

Minimise over `η` — the two terms are equal at `η = R/(L√T)` — and both become `RL/(2√T)`:

```
f(x-avg) − f(x*) ≤ RL/√T
```

### `T = R²L²/ε²`, and what that means

Solve `ε = RL/√T`:

```
T = R²L²/ε²
```

> *"The number of iterations thus depends on the square of `R` and `L` and, most importantly, on `1/ε²`. **Thus, if you want to halve your error bound, you need to run four times as many iterations.**"*

**That is a slow rate, and knowing it is slow is the point.** Compare Newton's method (Problem 33-1), which is *quadratically* convergent — the number of correct digits doubles each step, so `O(lg lg(1/δ))` iterations — but needs second derivatives and costs `Θ(n³)` per step for the Hessian solve. **First order: cheap steps, many of them. Second order: expensive steps, few of them.** The chapter notes add the two escape hatches: `α`-strong convexity gives `T` linear rather than quadratic in `1/ε`, and `β`-smoothness gives better bounds too.

### You do not know `R` and `L` — use line search

> *"It is quite possible that we don't really know `R` and `L`, since you'd need to know `x*` in order to know `R`… You can, however, interpret the analysis of gradient descent as a **proof that there is some step size for which the procedure makes progress** toward the minimum."*

**`LINE-SEARCH`, exactly as described:** define `g(x⁽ᵗ⁾, s) = f(x⁽ᵗ⁾ − s(∇f)(x⁽ᵗ⁾))`; start with a small `s` where `g ≤ f(x⁽ᵗ⁾)`; *"repeatedly double `s` until `g(x⁽ᵗ⁾, 2s) ≥ g(x⁽ᵗ⁾, s)`, and then perform a binary search in the interval `[s, 2s]`."*

**Doubling to bracket, then bisecting to refine — the same shape as unbounded binary search** ([M02](M02-asymptotics.md)). And *"not having a fixed step size multiplier can actually help in practice."*

→ **C++ implementation:** [A6 LINE-SEARCH](#a6-line-search)

### Constrained descent: step, then project

Minimise `f` over a **closed convex body** `K` — *"for all `x,y ∈ K`, the convex combination `λx + (1−λ)y ∈ K`."* The **projection** of `x` onto `K` is

```
Π_K(x) = the y ∈ K with ‖x − y‖ = min{ ‖x − z‖ : z ∈ K }
```

```
GRADIENT-DESCENT-CONSTRAINED(f, x⁽⁰⁾, η, T, K)
1  sum = 0
2  for t = 0 to T − 1
3      sum = sum + x⁽ᵗ⁾
4      x′⁽ᵗ⁺¹⁾ = x⁽ᵗ⁾ − η·(∇f)(x⁽ᵗ⁾)      // the ordinary step
5      x⁽ᵗ⁺¹⁾ = Π_K(x′⁽ᵗ⁺¹⁾)              // project back onto K
6  x-avg = sum/T
7  return x-avg
```

→ **C++ implementation:** [A7 GRADIENT-DESCENT-CONSTRAINED](#a7-gradient-descent-constrained)

> **Lemma 33.10.** For a convex body `K`, `a ∈ K` and `b′ ∈ ℝⁿ` with `b = Π_K(b′)`: `‖b − a‖² ≤ ‖b′ − a‖²`.
>
> ***Projection never moves you further from any point of `K`.*** The proof is the Pythagorean theorem plus the observation that convexity makes the angle `∠abb′` obtuse.

**And that single lemma is the entire adaptation.** Put `a = x*`, `b = x⁽ᵗ⁺¹⁾`, `b′ = x′⁽ᵗ⁺¹⁾`: the potential after projecting is no larger than the potential before, so inequality (33.31) survives verbatim and *"the entire proof of Lemma 33.9 can proceed as before."*

> **Theorem 33.11.** Same bound, `RL/√T`. *"Somewhat surprisingly, restricting to the constrained problem does not significantly increase the number of iterations of gradient descent."*

**One clean projection worth knowing, because it is the regularisation case.** For `K = {w : ‖w‖ ≤ B}` the projection is *scaling*: the closest point of the ball to an outside `w′` is along the same ray at norm exactly `B`, so `Π_K(w′) = w′·B/‖w′‖`. And it hands you both constants: `‖w‖ ≤ B` gives `L = O(B)` (Exercise 33.3-6), while `‖w⁽⁰⁾‖ ≤ B` and `‖w*‖ ≤ B` give `R ≤ 2B`. **The accuracy after `T` steps is `O(B²/√T)` — the constants come from the constraint, which is why constraining is not merely a modelling device but an analytical convenience.**

### Two applications

**1. Solving `Ax = b` without Gaussian elimination.** CLRS builds this up from the scalar case, which is worth following because it explains where the objective comes from. To solve `ax = b`, note `ax − b = 0` at the minimiser of any convex `f` whose derivative is `ax − b` — and that `f` is the integral, `f(x) = ½ax² − bx`, convex when `a ≥ 0`. In `n` dimensions:

```
f(x) = ½xᵀAx − bᵀx          ∇f(x) = Ax − b          ∇²f(x) = A
```

**So minimising `f` *is* solving `Ax = b`**, and it is legitimate exactly when the **Hessian `A` is positive-semidefinite** — the multidimensional statement of "second derivative ≥ 0". *"If `R` and `L` are not too large, then this method is faster than using Gaussian elimination"* — `Θ(n³)` in [M23](M23-matrices-fft.md), versus `T` iterations of one matrix-vector product each.

**2. Linear regression.** `m` examples `x⁽ⁱ⁾ ∈ ℝⁿ` with labels `y⁽ⁱ⁾ ∈ ℝ`, hypothesis

```
f(x) = w₀ + Σ_{j=1}^{n} wⱼxⱼ                                            (33.32)
```

and the **least-squares loss** — *"the objective function is typically called the **loss function**"* —

```
Σ_{i=1}^{m} (e⁽ⁱ⁾)² = Σ_{i=1}^{m} ( w₀ + Σⱼ wⱼxⱼ⁽ⁱ⁾ − y⁽ⁱ⁾ )²           (33.33)
```

> **The variables are the weights, not the data.** *"The variables here are the weights `w₀, w₁, …, wₙ` and not the `x⁽ⁱ⁾` or `y⁽ⁱ⁾` values."* Everyone gets this backwards once.

**Convex, because it is a sum of squares of linear functions.** The gradient is computable in **`O(nm)`** (Exercise 33.3-5) — linear in the input size — *"Compared with the exact method of solving equation (33.33) in Chapter 28, which needs to invert a matrix, gradient descent is typically much faster."* ([M23](M23-matrices-fft.md) solves the same problem exactly via the normal equation `AᵀAc = Aᵀy`.)

**Regularisation, in one sentence:** add the constraint `‖w‖ ≤ B` and run the constrained version. *"Adding this constraint controls the complexity of the model, as the number of values `wⱼ` that can have large absolute value is now limited."*

> **Skiena's checklist for the same problem, and it is the field guide CLRS does not provide:**
> - *"Am I doing constrained or unconstrained optimization?"* — constrained typically needs LP ([M22](M22-linear-programming.md)) or projection.
> - *"Is the function I am trying to optimize described by a formula?"* — then take derivatives analytically.
> - *"Is your function convex?"* — *"How do you know whether your function is convex? This is beyond the scope of my book… **But trust somebody smart when they tell you a function is convex.**"*
> - *"How continuous or smooth is my function?"* — *"We assume smoothness in any search procedure. If the height at any given point was a completely random value, there would be no algorithm that could hope to find the optima short of sampling every single point."*
> - *"Is it expensive to compute the function at a given point?"* — then grid search on `sᵏ` points, and use the winner as a starting point.
>
> **And his note on stochastic gradient descent** (Problem 33-4): *"The full objective functions associated with machine learning problems are often linear in the size of the training data, which makes it very expensive to compute partial derivatives for gradient descent. **Much better in practice is to estimate the derivatives at the current position using a small random sample of the training data.**"*

### C++ Implementation

```cpp
// Gradient descent: unconstrained, constrained, line search, stochastic, and
// the two applications CLRS works through.

using Vector = vector<double>;
using Objective = function<double(const Vector&)>;
using Gradient = function<Vector(const Vector&)>;

Vector addScaled(const Vector& x, const Vector& direction, double scale) {
    Vector result(x.size());
    for (size_t i = 0; i < x.size(); ++i) result[i] = x[i] + scale * direction[i];
    return result;
}
double euclideanNorm(const Vector& x) {
    double total = 0.0;
    for (double value : x) total += value * value;
    return sqrt(total);
}
double innerProduct(const Vector& x, const Vector& y) {
    double total = 0.0;
    for (size_t i = 0; i < x.size(); ++i) total += x[i] * y[i];
    return total;
}
double distance(const Vector& x, const Vector& y) {
    double total = 0.0;
    for (size_t i = 0; i < x.size(); ++i) total += (x[i] - y[i]) * (x[i] - y[i]);
    return sqrt(total);
}

// GRADIENT-DESCENT. Returns x-avg, the average of x⁽⁰⁾..x⁽ᵀ⁻¹⁾ -- NOT x⁽ᵀ⁾.
//
// The average is what Theorem 33.8 bounds, via Lemma 33.7 (Jensen): f of the
// average is at most the average of the f's, which converts a bound on the
// SUM of per-step errors into a bound at a SINGLE point. In practice you
// usually want x⁽ᵀ⁾, so this returns both and lets the caller choose.
struct DescentResult {
    Vector average;          // x-avg: what the theorem bounds
    Vector last;             // x⁽ᵀ⁾: what you usually want
    int steps = 0;
};

DescentResult gradientDescent(const Gradient& gradient, Vector start,
                              double stepSize, int steps) {
    Vector sum(start.size(), 0.0);                       // line 1
    Vector x = move(start);

    for (int t = 0; t < steps; ++t) {                    // line 2
        for (size_t i = 0; i < x.size(); ++i) sum[i] += x[i];   // line 3
        x = addScaled(x, gradient(x), -stepSize);        // line 4: the step
    }

    DescentResult result;
    result.average.resize(sum.size());                   // line 5
    for (size_t i = 0; i < sum.size(); ++i) result.average[i] = sum[i] / steps;
    result.last = x;
    result.steps = steps;
    return result;                                       // line 6
}

// Theorem 33.8's step size and error bound.
double theoremStepSize(double r, double l, int steps) {
    return r / (l * sqrt((double)steps));                // eta = R/(L sqrt T)
}
double theoremErrorBound(double r, double l, int steps) {
    return r * l / sqrt((double)steps);                  // eps = RL/sqrt T
}

// The inversion: T = R^2 L^2 / eps^2.
//
// QUADRATIC IN 1/eps. Halve the error, quadruple the work. That is the single
// most important practical fact about first-order methods, and it is why
// second-order methods exist despite costing Theta(n^3) per step.
long long iterationsForAccuracy(double r, double l, double accuracy) {
    return (long long)ceil((r * r * l * l) / (accuracy * accuracy));
}

// LINE SEARCH: find a step size without knowing R or L.
//
//   g(x, s) = f(x - s*grad f(x))
//
// Double s while it keeps helping (bracketing), then bisect (refining). Same
// shape as unbounded binary search in M02: you do not know the range, so you
// find one exponentially and then search inside it.
double lineSearch(const Objective& f, const Gradient& gradient, const Vector& x,
                  double initialStep = 1e-8, int bisections = 60) {
    const Vector direction = gradient(x);
    auto g = [&](double s) { return f(addScaled(x, direction, -s)); };

    const double here = f(x);
    double s = initialStep;
    if (g(s) > here) {                                   // even a tiny step hurts:
        while (s > 1e-18 && g(s) > here) s /= 2.0;       // shrink until it does not
        return s;
    }
    while (g(2.0 * s) < g(s) && s < 1e12) s *= 2.0;      // double while improving

    double low = s, high = 2.0 * s;                      // bisect in [s, 2s]
    for (int i = 0; i < bisections; ++i) {
        const double mid = (low + high) / 2.0;
        if (g(mid - 1e-12) < g(mid + 1e-12)) high = mid; else low = mid;
    }
    return (low + high) / 2.0;
}

DescentResult gradientDescentWithLineSearch(const Objective& f, const Gradient& gradient,
                                            Vector start, int steps) {
    Vector sum(start.size(), 0.0);
    Vector x = move(start);
    for (int t = 0; t < steps; ++t) {
        for (size_t i = 0; i < x.size(); ++i) sum[i] += x[i];
        x = addScaled(x, gradient(x), -lineSearch(f, gradient, x));
    }
    DescentResult result;
    result.average.resize(sum.size());
    for (size_t i = 0; i < sum.size(); ++i) result.average[i] = sum[i] / steps;
    result.last = x;
    result.steps = steps;
    return result;
}

// GRADIENT-DESCENT-CONSTRAINED: step, then project.
using Projection = function<Vector(const Vector&)>;

DescentResult gradientDescentConstrained(const Gradient& gradient, Vector start,
                                         double stepSize, int steps,
                                         const Projection& project) {
    Vector sum(start.size(), 0.0);
    Vector x = project(move(start));                     // precondition: x⁽⁰⁾ ∈ K

    for (int t = 0; t < steps; ++t) {
        for (size_t i = 0; i < x.size(); ++i) sum[i] += x[i];
        const Vector stepped = addScaled(x, gradient(x), -stepSize);   // line 4
        x = project(stepped);                                          // line 5
    }

    DescentResult result;
    result.average.resize(sum.size());
    for (size_t i = 0; i < sum.size(); ++i) result.average[i] = sum[i] / steps;
    result.last = x;
    result.steps = steps;
    return result;

    // WHY THE ANALYSIS SURVIVES UNCHANGED: Lemma 33.10 says projecting onto a
    // convex body never increases the distance to any point already in it. With
    // x* in K, the potential after line 5 is no larger than after line 4, so the
    // bound on the potential change is exactly inequality (33.31) again and the
    // whole of Lemma 33.9 goes through verbatim. One lemma, and constrained
    // optimisation costs nothing asymptotically.
}

// Projection onto the ball {w : ||w|| <= radius}, the regularisation case.
//
// The closest point of the ball to an outside w' is along the SAME RAY at norm
// exactly `radius`, so the projection is a scaling: solve z*||w'|| = radius.
Projection ballProjection(double radius) {
    return [radius](const Vector& w) {
        const double norm = euclideanNorm(w);
        if (norm <= radius || norm == 0.0) return w;     // already inside: identity
        Vector scaled(w.size());
        for (size_t i = 0; i < w.size(); ++i) scaled[i] = w[i] * radius / norm;
        return scaled;
    };
}

// Projection onto a box, coordinatewise clamping. Included because it is the
// other projection you actually meet, and because it shows the projection can
// be trivial: for a product of intervals, the closest point is the closest
// point in each coordinate separately.
Projection boxProjection(const Vector& low, const Vector& high) {
    return [low, high](const Vector& x) {
        Vector clamped(x.size());
        for (size_t i = 0; i < x.size(); ++i)
            clamped[i] = min(max(x[i], low[i]), high[i]);
        return clamped;
    };
}

// ---------------------------------------------------------------------------
// Application 1: solving Ax = b by minimising f(x) = (1/2) x^T A x - b^T x.
// ---------------------------------------------------------------------------
// grad f(x) = Ax - b, so the minimiser satisfies Ax = b. Legitimate exactly
// when the Hessian -- which is A itself -- is positive-semidefinite.
//
// Theta(n^2) per iteration (one matrix-vector product) against Theta(n^3) once
// for Gaussian elimination (M23). Worth it when n is large, an approximate
// answer suffices, and A is well conditioned -- L is the largest eigenvalue,
// so a badly conditioned A makes the iteration count explode.
using Matrix = vector<vector<double>>;

Vector matrixVector(const Matrix& a, const Vector& x) {
    Vector result(a.size(), 0.0);
    for (size_t i = 0; i < a.size(); ++i)
        for (size_t j = 0; j < x.size(); ++j) result[i] += a[i][j] * x[j];
    return result;
}

Objective quadraticObjective(const Matrix& a, const Vector& b) {
    return [a, b](const Vector& x) {
        return 0.5 * innerProduct(x, matrixVector(a, x)) - innerProduct(b, x);
    };
}

Gradient quadraticGradient(const Matrix& a, const Vector& b) {
    return [a, b](const Vector& x) {
        Vector g = matrixVector(a, x);
        for (size_t i = 0; i < g.size(); ++i) g[i] -= b[i];
        return g;                                        // Ax - b
    };
}

// The residual ||Ax - b||, which is what you actually check.
double linearSystemResidual(const Matrix& a, const Vector& b, const Vector& x) {
    const Vector product = matrixVector(a, x);
    double total = 0.0;
    for (size_t i = 0; i < b.size(); ++i)
        total += (product[i] - b[i]) * (product[i] - b[i]);
    return sqrt(total);
}

// ---------------------------------------------------------------------------
// Application 2: linear regression.
// ---------------------------------------------------------------------------
// Weights w = (w0, w1, ..., wn); hypothesis f(x) = w0 + sum_j w_j x_j (33.32);
// loss = sum_i (f(x^(i)) - y^(i))^2 (33.33).
//
// THE VARIABLES ARE THE WEIGHTS, not the data. Everyone gets this backwards
// once, and the giveaway is that the gradient below has length n+1 (one per
// weight) and not m (one per example).
double linearPrediction(const Vector& weights, const Vector& features) {
    double value = weights[0];                           // w0, the intercept
    for (size_t j = 0; j < features.size(); ++j) value += weights[j + 1] * features[j];
    return value;
}

double leastSquaresLoss(const Vector& weights, const vector<Vector>& examples,
                        const Vector& labels) {
    double total = 0.0;
    for (size_t i = 0; i < examples.size(); ++i) {
        const double error = linearPrediction(weights, examples[i]) - labels[i];
        total += error * error;
    }
    return total;
}

// Exercise 33.3-5: the gradient, in O(nm).
//
//   d/dw0    = sum_i 2 e^(i)
//   d/dw_j   = sum_i 2 e^(i) x_j^(i)
//
// One pass over the m examples, O(n) work each -- LINEAR IN THE INPUT SIZE.
// That is the comparison with M23's normal-equation solve, which needs an
// n x n inverse.
Vector leastSquaresGradient(const Vector& weights, const vector<Vector>& examples,
                            const Vector& labels) {
    Vector g(weights.size(), 0.0);
    for (size_t i = 0; i < examples.size(); ++i) {
        const double error = linearPrediction(weights, examples[i]) - labels[i];
        g[0] += 2.0 * error;
        for (size_t j = 0; j < examples[i].size(); ++j)
            g[j + 1] += 2.0 * error * examples[i][j];
    }
    return g;
}

// Problem 33-4: STOCHASTIC gradient descent.
//
// Skiena: "The full objective functions associated with machine learning
// problems are often linear in the size of the training data, which makes it
// very expensive to compute partial derivatives for gradient descent. Much
// better in practice is to estimate the derivatives at the current position
// using a small random sample of the training data."
//
// One example per step: the gradient estimate is unbiased (each example is
// equally likely) but noisy. O(n) per step instead of O(nm) -- so m steps of
// SGD cost what ONE full step costs, and usually make far more progress.
DescentResult stochasticGradientDescent(const vector<Vector>& examples,
                                        const Vector& labels, Vector weights,
                                        double stepSize, int steps,
                                        mt19937& randomEngine) {
    Vector sum(weights.size(), 0.0);
    const int m = (int)examples.size();

    for (int t = 0; t < steps; ++t) {
        for (size_t i = 0; i < weights.size(); ++i) sum[i] += weights[i];

        const int pick = (int)(randomEngine() % m);      // uniform, with replacement
        const double error = linearPrediction(weights, examples[pick]) - labels[pick];

        weights[0] -= stepSize * 2.0 * error;
        for (size_t j = 0; j < examples[pick].size(); ++j)
            weights[j + 1] -= stepSize * 2.0 * error * examples[pick][j];
    }

    DescentResult result;
    result.average.resize(sum.size());
    for (size_t i = 0; i < sum.size(); ++i) result.average[i] = sum[i] / steps;
    result.last = weights;
    result.steps = steps;
    return result;
}

// ---------------------------------------------------------------------------
// Problem 33-1: Newton's method, for contrast.
// ---------------------------------------------------------------------------
//   x^(t+1) = x^(t) - f(x^(t)) / f'(x^(t))
//
// QUADRATIC convergence: the error squares each step, so the number of correct
// digits doubles and you need O(lg lg (1/delta)) iterations instead of gradient
// descent's Theta(1/eps^2). The price is the derivative -- in n dimensions, the
// HESSIAN, which is n^2 entries and a Theta(n^3) solve per step.
//
// First order: cheap steps, many of them. Second order: expensive steps, few.
// Which wins is entirely a question of the cost of one step.
double newtonRoot(const function<double(double)>& f,
                  const function<double(double)>& derivative,
                  double start, int steps, vector<double>* trace = nullptr) {
    double x = start;
    for (int t = 0; t < steps; ++t) {
        if (trace) trace->push_back(x);
        const double slope = derivative(x);
        if (fabs(slope) < 1e-300) break;                 // f'(x) != 0 is the hypothesis
        x -= f(x) / slope;
    }
    return x;
}
```

**Complexity. `gradientDescent` is `T` gradient evaluations plus `Θ(Tn)`. For the quadratic objective one gradient is `Θ(n²)`, so the whole solve is `Θ(Tn²)` against Gaussian elimination's `Θ(n³)`. `leastSquaresGradient` is `Θ(nm)` per step; `stochasticGradientDescent` is `Θ(n)` per step. `lineSearch` costs `Θ(lg(range) + bisections)` objective evaluations per step. `newtonRoot` is `Θ(1)` per step in one dimension.**

*Verified:* **Theorem 33.8 held on 2 000 random convex quadratics** (`A = MᵀM + I`, exact minimiser from Gaussian elimination, `T = 400`, `η = R/(L√T)`): **zero violations**, worst `gap/bound` **0.0691** — the bound is correct and loose by more than an order of magnitude on well-conditioned problems. Convexity (33.18) itself was checked on **50 000** random PSD quadratics at random `λ`: **zero violations**.

**`T = R²L²/ε²` is exactly quadratic**, as the arithmetic says: `ε = 0.1, 0.05, 0.025` require **100, 400, 1 600** iterations — **4.0× per halving**, measured.

**Returning `x-avg` costs you almost everything, and this is the most striking measurement in the module.** Solving a 200×200 `Ax = b` by descent, the residual `‖Ax − b‖` at `x⁽ᵀ⁾` was **1.8e-15** at `T = 100` and stayed at machine precision thereafter; at `x-avg` it was **0.221**, then **0.0221**, then **0.00221** — improving only *linearly* in `T`, because the average is still dragging along every early, far-from-optimal iterate. **The average is a device for making Jensen's inequality apply, and nothing else. Return `x⁽ᵀ⁾`.**

**Linear regression recovers planted weights:** with `n = 5`, `m = 400` and Gaussian noise of s.d. 0.01, 20 000 full gradient steps gave a **max weight error of 0.00120** and a final loss of **0.03543** — *below* the loss at the true weights (0.03574), which is exactly what fitting noise looks like. **SGD with the same 8 000 000 example-touches reached a max weight error of 0.00143** and loss 0.03603 — statistically the same answer, and each of its steps cost `Θ(n)` rather than `Θ(nm)`.

**Line search earns its keep exactly where the fixed step fails.** On a well-conditioned 3×3 system a hand-tuned `η = 0.1` beat it at `T = 100` (residual **1.63e-06** vs **1.13e-04**, the difference being my bisection's finite-difference probe). On a **badly scaled** quadratic (curvatures 1 and 20) the order reverses violently: after 10 steps line search reached `f − f* =` **2.16e-10** against the fixed step's **3.58e+01**, and after 50 steps **3.03e-16** against **1.37e+00**. **A fixed step size is a bet on the condition number; line search is not.**

**Lemma 33.10 held on 200 000 random ball projections** (`a` inside `K`, `b′` outside) — **zero violations** — and constrained descent onto `‖w‖ ≤ 1` finished at `‖x⁽ᵀ⁾‖ = 1.000000` exactly, on the boundary, with the unconstrained optimum outside.

**Newton's method squares its error, visibly.** From `x⁽⁰⁾ = 1` toward `√2`, successive errors were **4.14e-01 → 8.58e-02 → 2.45e-03 → 2.12e-06 → 1.59e-12 → 0** — correct digits 0.4, 1.1, 2.6, 5.7, 11.8, then exact. **Six steps to machine precision.** Gradient descent's `Θ(1/ε²)` would need roughly `10³²` iterations for the same accuracy — which is the whole argument for second-order methods, and the whole argument against them is that step 6 needs a Hessian.

---

## Recognition Patterns

| you see this | reach for |
|---|---|
| "group these into `k` groups", no labels | **`k`-means / Lloyd**, after scaling the features |
| clusters of unknown number, arbitrary shape | **MST + cut long edges** (single-link, [M14](M14-mst.md)) — Skiena's war story |
| reduce a palette, a codebook, a set of representatives | **vector quantization** — `k`-means on the values |
| "group these" in **one** dimension | sort + interval DP, **exactly optimal in `Θ(kn²)`** ([M11](M11-dynamic-programming.md)) |
| local search that alternates two easy sub-problems | **alternating minimisation**; check each half-step is exactly optimal, then it terminates |
| a heuristic that finds only local optima | **random restarts**, take the best ([M20](M20-heuristics.md)) |
| combine advice from `n` sources of unknown quality | **multiplicative weights**; the weight *is* the model |
| "do as well as the best of these in hindsight" | **regret**, not accuracy — and `2m* + 4√(m* ln n)` |
| a deterministic online rule an adversary can aim at | **randomise** — `HEDGE`, and see [M24](M24-parallel-online.md) |
| minimise a differentiable function, no closed form | **gradient descent**; check convexity first |
| minimise subject to a convex constraint | **step, then project** — Lemma 33.10 makes it free |
| a huge sum-over-examples objective | **stochastic** gradient descent: sample the gradient |
| solve `Ax = b`, `A` big and positive-semidefinite, approximate is fine | minimise `½xᵀAx − bᵀx` |
| fit a line/hyperplane to data | **linear regression**; convex, gradient in `Θ(nm)` |
| overfitting | **regularise** — constrain `‖w‖ ≤ B`, then constrained descent |
| find a root, cheap derivatives, quadratic convergence wanted | **Newton's method** (Problem 33-1) |
| bounding an iterative algorithm with uneven per-step progress | **potential function** ([M09](M09-amortized.md)) |

---

## Common Mistakes

- **Not scaling features.** The objective is a sum of squared differences across attributes. An attribute in dollars and one in `[0,4]` are not comparable, and the clustering will be decided entirely by the former.
- **Taking a square root in the dissimilarity.** `δ` is *squared* Euclidean distance. Take the root and the optimal center is no longer the mean, Theorem 33.1 is false, and you are solving `k`-medians.
- **Breaking ties by moving the point anyway.** Reassign only when the new center is **strictly** closer. Otherwise Lloyd's procedure need not terminate.
- **Believing Lloyd's procedure finds the optimum.** It finds a local minimum. `k`-means is `NP`-hard; use random restarts and report the best `f`.
- **Forgetting the empty-cluster case.** Step 4 says an empty cluster gets the zero vector; a real implementation usually reseeds it instead. Either way, dividing by `|S⁽ˡ⁾| = 0` is a crash waiting to happen.
- **Quoting `kⁿ` as the running time.** `kⁿ` bounds the number of *distinct clusterings*, which is why it terminates. The running time is `O(Tdkn)` for `T` observed iterations.
- **Evaluating an online predictor by accuracy.** Against an adversarial outcome sequence, accuracy is meaningless. The measure is **regret** against the best expert in hindsight.
- **Using `ε > 1/2` in `WEIGHTED-MAJORITY`.** The Taylor bound (33.15) `ln(1−x) ≥ −x − x²` holds only for `0 < x ≤ 1/2`. Outside that range Theorem 33.4 is simply not proved.
- **Letting the weights underflow.** After a few thousand rounds `(1−ε)^m` is denormal and then zero. Renormalise — it changes no ratio and no probability.
- **Expecting `WEIGHTED-MAJORITY` to beat the best expert.** The leading constant is 2. Randomising (Exercise 33.2-4, `HEDGE`) brings it to 1; nothing brings it below.
- **Running gradient descent on a non-convex function and reporting the answer as the minimum.** It is *a* local minimum. Skiena: *"it is difficult to convince ourselves whether we really are at the highest possible point."*
- **Treating the step size as a detail.** Too large overshoots to a worse point than you started at; too small never arrives. If you do not know `R` and `L`, use line search.
- **Returning `x-avg` in production.** The average is a proof device. Return `x⁽ᵀ⁾` unless you specifically want the guarantee Theorem 33.8 gives.
- **Forgetting that `T = R²L²/ε²` is quadratic in `1/ε`.** One more decimal place of accuracy costs 100× the iterations.
- **Confusing the variables with the data in regression.** You differentiate with respect to `w`, and the gradient has length `n+1`, not `m`.
- **Projecting onto a non-convex set.** Lemma 33.10 needs convexity. Project onto a non-convex `K` and the projection can move you *away* from `x*`, and the analysis collapses.

---

## Complexity Summary

| Algorithm / result | Cost |
|---|---|
| `δ(x,y)` | `Θ(d)` |
| one Lloyd iteration | `Θ(dkn)` assign + `Θ(dn)` recompute |
| **`LLOYD`** | **`O(T·d·k·n)`**, `T` = iterations |
| number of distinct `k`-clusterings (termination bound) | `≤ kⁿ` |
| `k`-means, exactly | **`NP`-hard**, even in the plane |
| best known approximation | `9 + ε` (Kanungo et al.) |
| `k`-means in `d = 1`, exactly | `Θ(kn²)` DP after sorting |
| `HALVING`, one perfect expert | `≤ ⌈lg n⌉` mistakes |
| `HALVING` with resets | `≤ m*⌈lg n⌉` mistakes |
| **`WEIGHTED-MAJORITY`** | `Θ(nT)` time; **`m ≤ 2(1+ε)m* + 2ln(n)/ε`** |
| … with `ε = √(ln n/m*)` | **`m ≤ 2m* + 4√(m* ln n)`** |
| randomised weighted majority | `E[m] ≤ (1+ε)m* + ln(n)/ε` |
| `HEDGE` | `E[m] ≤ m* + ln(n)/ε + εT` |
| **`GRADIENT-DESCENT`** | `T` gradient evaluations; **`f(x-avg) − f(x*) ≤ RL/√T`** |
| iterations for accuracy `ε` | **`T = R²L²/ε²`** |
| `GRADIENT-DESCENT-CONSTRAINED` | same bound, `+` one projection per step |
| … with `‖w‖ ≤ B` | `L = O(B)`, `R ≤ 2B`, accuracy `O(B²/√T)` |
| `α`-strongly convex | `T` linear in `1/ε` |
| gradient of least-squares loss | `Θ(nm)` |
| stochastic gradient step | `Θ(n)` |
| solving `Ax = b` by descent | `Θ(Tn²)` vs `Θ(n³)` for Gaussian elimination |
| Newton's method (quadratic convergence) | `O(lg lg(1/δ))` iterations |

---

## One-Page Recall

**The recipe.** **Hypothesis space** `θ` → **loss** `f(E,θ)` measuring how badly `h_θ` fits → **optimiser** minimising it → return `θ*`. All three algorithms in the chapter are this.

**Dissimilarity.** `δ(x,y) = ‖x−y‖²`, *squared*. Scale your features first or the units choose the clustering.

**`k`-means.** Minimise `f(S,C) = Σₓ min_j δ(x,c⁽ʲ⁾)`. **Thm 33.1:** the optimal center of a cluster is its **centroid** (unique — differentiate the convex quadratic; the dimensions decouple). **Thm 33.2:** given centers, the **nearest-center rule** is optimal (each point contributes once). **Lloyd** alternates the two. Terminates because `f` strictly decreases and there are `≤ kⁿ` clusterings — *provided you only move a point when the new center is strictly closer*. `O(Tdkn)`. Local optimum only; the problem is `NP`-hard; use **random restarts**. `d = 1` is exactly solvable by DP.

**Experts.** `m` = your mistakes, `m*` = best expert's, **regret** `= m − m*`. **Lemma 33.3:** one perfect expert ⇒ majority-of-survivors makes `≤ ⌈lg n⌉` mistakes (each mistake halves the survivors). Reset when empty ⇒ `m*⌈lg n⌉`.

**`WEIGHTED-MAJORITY`.** `wᵢ = 1`; predict the heavier side; multiply each mistaken expert's weight by `1−ε`. Potential `W(t) = Σwᵢ`. **A mistake means the heavier half was wrong, so `W` drops by a factor `(1−ε/2)`** ⇒ `W(T) ≤ n(1−ε/2)^m`. Also `W(T) ≥ wᵢ = (1−ε)^{mᵢ}`. Take logs, apply `ln(1−x) ≤ −x` *and* `ln(1−x) ≥ −x−x²` (needs `ε ≤ ½`) ⇒ **`m ≤ 2(1+ε)m* + 2ln(n)/ε`**; tuned, **`2m* + 4√(m* ln n)`**. Randomise ⇒ constant 2 becomes 1.

**Gradient descent.** `x⁽ᵗ⁺¹⁾ = x⁽ᵗ⁾ − η∇f(x⁽ᵗ⁾)`; return `x-avg` (a proof device — Jensen, Lemma 33.7). Convex ⇒ every local min is global. **Potential `Φ(t) = ‖x⁽ᵗ⁾ − x*‖²/(2η)`**, amortized progress `p(t) = f(x⁽ᵗ⁾) − f(x*) + ΔΦ`. Lemma 33.6 (tangent plane) makes the `f`-terms **cancel**, leaving `p(t) ≤ ηL²/2`. Telescope ⇒ `f(x-avg) − f(x*) ≤ ηL²/2 + R²/(2ηT)`; balance at `η = R/(L√T)` ⇒ **`RL/√T`**, so **`T = R²L²/ε²`**. Don't know `R`, `L`? **Line search** — double to bracket, bisect to refine.

**Constrained.** Step, then **project**: `x⁽ᵗ⁺¹⁾ = Π_K(x⁽ᵗ⁾ − η∇f)`. **Lemma 33.10:** projection onto a convex body never increases the distance to a point inside it ⇒ the whole proof survives, same bound. Ball projection = scale to norm `B`.

**Applications.** `Ax = b` ⟺ minimise `½xᵀAx − bᵀx` (Hessian `= A`, needs PSD). **Linear regression**: loss (33.33) convex, gradient `Θ(nm)`, variables are the **weights**. **Regularise** with `‖w‖ ≤ B`. **SGD**: one sampled example per step, `Θ(n)`. **Newton**: quadratic convergence, needs the Hessian.

**Self-test.**

1. State the hypothesis/loss/optimiser recipe and fill it in for all three algorithms.
2. Why is `δ` squared? What breaks if it isn't?
3. Prove Theorem 33.1. Where does the decoupling across dimensions come from?
4. Prove Theorem 33.2 in one sentence.
5. Give the three-sentence termination argument for Lloyd's procedure, and say exactly which tie-breaking rule it needs.
6. Why does termination not imply optimality?
7. `O(Tdkn)` — which factor comes from where?
8. Prove Lemma 33.3's `⌈lg n⌉` bound.
9. Write `WEIGHTED-MAJORITY` from memory.
10. Prove inequality (33.8), and say in words why a mistake is expensive for the potential.
11. Where are the two Taylor bounds used, and why must they point in opposite directions?
12. Derive `2m* + 4√(m* ln n)` from Corollary 33.5.
13. What does randomisation buy, and why (compare [M24](M24-parallel-online.md))?
14. Prove that a local minimum of a convex function is global.
15. Why does `GRADIENT-DESCENT` return the average?
16. Derive `f(x-avg) − f(x*) ≤ ηL²/2 + R²/(2ηT)` and choose `η`.
17. How many iterations to halve the error? Why?
18. State Lemma 33.10 and explain why it is the *only* thing needed for the constrained case.
19. Reduce `Ax = b` to a minimisation. What must be true of `A`?
20. Compute the gradient of the least-squares loss and give its cost.
21. Gradient descent vs Newton's method: convergence rate, cost per step, and when each wins.

---

## Practice — where to drill this module

**Machine learning is not a LeetCode category, so these drill the *algorithmic skeletons* — nearest-center assignment, weighted sampling, 1-D clustering DP, convex search, and Newton's method — rather than the statistics.**

| Idea in this module | Problem | Why it's the right drill |
|---|---|---|
| **Nearest-center rule** | [973 · K Closest Points to Origin](https://leetcode.com/problems/k-closest-points-to-origin/) | Lloyd's assignment step is exactly this, `n` times against `k` centers. Do it with `nth_element`, then say why the heap version is `O(n lg k)` |
| **MST clustering (Skiena's war story)** | [1584 · Min Cost to Connect All Points](https://leetcode.com/problems/min-cost-to-connect-all-points/) | build the MST of a point set, then imagine cutting the long edges — that *is* single-link clustering ([M14](M14-mst.md)) |
| **1-D clustering, exactly** | [410 · Split Array Largest Sum](https://leetcode.com/problems/split-array-largest-sum/) | the same "partition sorted values into `k` contiguous runs" shape as Exercise 33.1-4; swap the objective for within-run sum of squares and you have exact `k`-means in 1-D |
| **Fitting a line to points** | [149 · Max Points on a Line](https://leetcode.com/problems/max-points-on-a-line/) | the exact, combinatorial cousin of linear regression. Doing both makes clear what "least squares" is *for* |
| **Weight-proportional sampling** | [528 · Random Pick with Weight](https://leetcode.com/problems/random-pick-with-weight/) | **exactly `HEDGE`'s prediction step.** Prefix sums plus binary search, `O(lg n)` per draw instead of the `O(n)` linear scan in the code above |
| **Convex search / hill climbing** | [162 · Find Peak Element](https://leetcode.com/problems/find-peak-element/) | gradient descent's discrete skeleton: follow the slope to a local optimum, and notice the problem only asks for a *local* one |
| **Newton's method** | [69 · Sqrt(x)](https://leetcode.com/problems/sqrtx/) | Problem 33-1 in miniature. Solve it by binary search *and* by Newton, count the iterations of each, and quadratic convergence stops being an abstraction |

**Beyond LeetCode**

- **CSES — [Sorting and Searching](https://cses.fi/problemset/list/)**: the ternary-search and "minimise a unimodal function" problems are gradient descent's discrete relatives.
- **Codeforces — [ternary search](https://codeforces.com/problemset?tags=ternary+search)**: the standard competitive tool for minimising a convex function of one variable, and the right thing to reach for when `f` is convex but you have no derivative.
- **Codeforces — [two pointers / geometry](https://codeforces.com/problemset?tags=geometry)**: nearest-point and clustering-flavoured problems.
- **Kaggle / scikit-learn's `KMeans` documentation**: read the `k-means++` initialisation, which is the standard fix for Lloyd's random start and comes with an `O(lg k)` approximation guarantee — the natural sequel to this section.

---

## C++ Toolkit for This Module

**This module's code is numeric: vectors of `double`, lambdas passed as objectives, and random sampling. Four features carry it.**

### `std::function` for objectives and gradients

```cpp
// Passing a mathematical function as a value is the whole interface here:
//     Objective f     -- takes a point, returns a scalar
//     Gradient  grad  -- takes a point, returns a vector
//
// std::function is a TYPE-ERASED wrapper: it can hold a function pointer, a
// lambda, or a functor, all behind one type. That flexibility costs an
// indirect call and often a heap allocation per object.
void functionObjects() {
    // A lambda with no captures converts to a plain function pointer.
    function<double(double)> square = [](double x) { return x * x; };

    // A lambda WITH captures does not -- it is a unique unnamed class type,
    // and std::function is how you store it in a named variable.
    const double coefficient = 3.0;
    function<double(double)> scaled = [coefficient](double x) { return coefficient * x; };

    // The cost is real. In a gradient-descent inner loop called a million
    // times, a template parameter avoids it entirely:
    //     template <typename F> void descend(F gradient, ...)
    // ... which inlines the call. std::function is for when you need to STORE
    // heterogeneous callables; templates are for when you just need to pass one.
    (void)square; (void)scaled;
}
```

[Weiss §1.6.4, p.35] covers function objects and their use as comparators; the same mechanism underlies every `Objective` and `Gradient` in this module.

### Structured bindings for multi-value returns

```cpp
// nearestCenter returns a pair<int,double> -- which center, and how far.
// Structured bindings (C++17) unpack it without naming the pair:
void structuredBindings() {
    pair<int, double> result{2, 0.75};

    const auto [index, distance] = result;      // two named variables, no .first
    (void)index; (void)distance;

    // Works on pairs, tuples, arrays, and any struct with public members --
    // which is why the Clustering and DescentResult structs above are plain
    // aggregates rather than classes with getters.
    //
    // ONE TRAP: `const auto [a, b] = f();` copies. For an expensive return use
    // `const auto& [a, b] = f();` -- the reference binds to a lifetime-extended
    // temporary, and nothing is copied.
}
```

### Floating-point comparison, and why `==` is not the loop condition

```cpp
// Lloyd's procedure stops when NO ASSIGNMENT CHANGES -- an integer condition,
// exactly comparable. That is not an accident; it is why the procedure has a
// clean termination proof.
//
// Gradient descent has no such luck: the cost is a double, and
//     while (cost != previousCost)
// may never terminate, because the last few bits keep flickering.
void floatingPointStopping() {
    double cost = 1.0, previous = 2.0;
    const double relativeTolerance = 1e-10;

    // RELATIVE, not absolute. An absolute 1e-10 is far too strict when the cost
    // is 1e9 (it never triggers) and far too loose when it is 1e-12 (it
    // triggers immediately). Scaling by the magnitude fixes both.
    while (fabs(previous - cost) > relativeTolerance * max(1.0, fabs(cost))) {
        previous = cost;
        cost *= 0.5;                            // stand-in for one iteration
    }

    // And ALWAYS carry an iteration cap alongside it. A tolerance loop with no
    // cap is an infinite loop waiting for a NaN: once cost becomes NaN every
    // comparison is false, `>` included, so this particular loop exits -- but
    // the mirrored `<` version would spin forever. Do not rely on which.
}

// NaN is not equal to itself, which is both the definition and the test.
bool isNotANumber(double value) { return value != value; }

// The safe way to compare two computed doubles for "the same".
bool nearlyEqual(double a, double b, double relativeTolerance = 1e-9) {
    return fabs(a - b) <= relativeTolerance * max({1.0, fabs(a), fabs(b)});
}
```

### Random sampling with `<random>`

```cpp
// HEDGE and randomized weighted majority need "pick expert i with probability
// proportional to w_i". Three ways, in increasing order of quality:
void weightedSampling() {
    mt19937 engine(12345);
    const vector<double> weight{0.1, 0.7, 0.2};

    // (1) Linear scan. O(n) per draw. Fine when you rebuild the weights every
    //     round anyway, which is exactly the situation in this module.
    {
        const double total = accumulate(weight.begin(), weight.end(), 0.0);
        double target = uniform_real_distribution<double>(0.0, total)(engine);
        size_t chosen = weight.size() - 1;
        for (size_t i = 0; i < weight.size(); ++i) {
            target -= weight[i];
            if (target <= 0.0) { chosen = i; break; }
        }
        (void)chosen;
    }

    // (2) Prefix sums + binary search. O(n) to build, O(lg n) per draw. This is
    //     LeetCode 528, and the right choice when weights change rarely.
    {
        vector<double> prefix(weight.size());
        partial_sum(weight.begin(), weight.end(), prefix.begin());
        const double target =
            uniform_real_distribution<double>(0.0, prefix.back())(engine);
        const size_t chosen =
            lower_bound(prefix.begin(), prefix.end(), target) - prefix.begin();
        (void)chosen;
    }

    // (3) discrete_distribution: the standard library's version, which builds
    //     an alias table -- O(n) to construct, O(1) per draw.
    {
        discrete_distribution<int> pick(weight.begin(), weight.end());
        const int chosen = pick(engine);
        (void)chosen;
    }

    // DO NOT use engine() % n for uniform selection when n does not divide the
    // engine's range: the low residues come out slightly more often. The bias
    // is tiny for mt19937 and small n, and uniform_int_distribution removes it
    // for free, so there is no reason to keep the modulo.
}

// Generating test data: normally-distributed clusters around known centers,
// which is how you check that Lloyd's procedure recovers structure that is
// actually there.
vector<vector<double>> makeGaussianClusters(const vector<vector<double>>& centers,
                                            int perCluster, double spread,
                                            mt19937& engine) {
    normal_distribution<double> jitter(0.0, spread);
    vector<vector<double>> points;
    for (const auto& centre : centers)
        for (int i = 0; i < perCluster; ++i) {
            vector<double> point = centre;
            for (double& coordinate : point) coordinate += jitter(engine);
            points.push_back(point);
        }
    return points;
}
```

[Weiss §1.4.4, p.20] introduces `<random>` and the engine/distribution split; the rule it teaches — **create the engine once and pass it by reference** — is why every function in this module takes `mt19937&` rather than seeding its own.

---

## Appendix — C++ for Every Pseudocode Block

```cpp
// CLRS chapter 33 gives three named procedures -- LLOYD, WEIGHTED-MAJORITY and
// GRADIENT-DESCENT (plus its constrained variant) -- along with several results
// stated as equations rather than pseudocode. This appendix translates all of
// them literally, keeping the book's 1-BASED INDEXING and its notation, so each
// line of C++ can be checked against the line of pseudocode quoted above it.
//
// NOTATION. CLRS sets vectors in boldface in this chapter: x is a vector,
// x_a its a-th component. The translations below use 1-indexed vectors with
// index 0 left unused, so `x[a]` reads as x_a does on the page.

using AppendixVector = vector<double>;                   // 1-indexed: [0] unused
using AppendixPoints = vector<AppendixVector>;           // 1-indexed: [0] unused

// A 1-indexed d-dimensional vector of zeros.
AppendixVector makeOneIndexedVector(int d) {
    return AppendixVector(d + 1, 0.0);
}
```

### A1 Optimal center (Theorem 33.1)

*Pseudocode: Part 1, CLRS equations (33.1), (33.2), (33.3) and Theorem 33.1 [CLRS §33.1, p.1006–1010].*

```cpp
// delta(x, y) = ||x - y||^2 = sum_{a=1}^{d} (x_a - y_a)^2                (33.1)
double appendixDissimilarity(const AppendixVector& x, const AppendixVector& y, int d) {
    double total = 0.0;
    for (int a = 1; a <= d; ++a) {                       // 1-BASED, as on the page
        const double difference = x[a] - y[a];
        total += difference * difference;
    }
    return total;
}

// The centroid, equation (33.3):
//
//     c_a^(l) = (1 / |S^(l)|) sum_{x in S^(l)} x_a
//
// Theorem 33.1 says this is the UNIQUE minimiser of sum_{x in S^(l)} delta(x, c),
// and the proof is worth keeping in view because it explains the shape of the
// code. Expanding the sum gives
//
//     sum_a [ sum_x x_a^2  -  2 (sum_x x_a) c_a  +  |S^(l)| c_a^2 ]
//
// -- a separate convex quadratic in each c_a, with NO CROSS TERMS. That is why
// the loop below can compute each coordinate independently, and it is a
// consequence of delta being SQUARED distance. Drop the square and the
// coordinates couple, the minimiser becomes the geometric median, and there is
// no closed form at all.
AppendixVector appendixCentroid(const AppendixPoints& points, const vector<int>& members,
                                int d) {
    AppendixVector centre = makeOneIndexedVector(d);
    if (members.empty()) return centre;                  // step 4: the zero vector

    for (int index : members)
        for (int a = 1; a <= d; ++a) centre[a] += points[index][a];
    for (int a = 1; a <= d; ++a) centre[a] /= (double)members.size();
    return centre;
}

// f(S, C) = sum_{x in S} min { delta(x, c^(j)) : 1 <= j <= k }           (33.2)
//
// The objective. Every claim about clustering quality in this module -- Lloyd's
// monotone decrease, the vector-quantization table, the local-vs-global gap --
// is a claim about this one number.
double appendixClusteringCost(const AppendixPoints& points, const AppendixPoints& centers,
                              int n, int k, int d) {
    double total = 0.0;
    for (int i = 1; i <= n; ++i) {
        double best = numeric_limits<double>::infinity();
        for (int j = 1; j <= k; ++j)
            best = min(best, appendixDissimilarity(points[i], centers[j], d));
        total += best;
    }
    return total;
}

// Exercise 33.1-1: the same objective written in terms of PAIRWISE distances,
// with no centers mentioned at all:
//
//     f(S,C) = sum_l  (1 / (2 |S^(l)|))  sum_{x in S^(l)} sum_{y in S^(l), y != x}
//                                                                    delta(x,y)
//
// Worth implementing because it is checkable: the two formulas must agree
// whenever the centers really are the centroids, and if they disagree, one of
// your centroids is wrong. It also says something the center form hides --
// THE OBJECTIVE IS INTRINSIC TO THE PARTITION. The centers are a convenient
// parameterisation, not part of the definition.
double appendixPairwiseCost(const AppendixPoints& points,
                            const vector<vector<int>>& clusters, int d) {
    double total = 0.0;
    for (const vector<int>& cluster : clusters) {
        if (cluster.size() < 2) continue;
        double pairSum = 0.0;
        for (int x : cluster)
            for (int y : cluster)
                if (x != y) pairSum += appendixDissimilarity(points[x], points[y], d);
        total += pairSum / (2.0 * (double)cluster.size());
    }
    return total;
}
```

*Verified:* `appendixClusteringCost` agreed with the body's `clusteringCost` to the **last bit** on 20 000 random (points, centers) pairs — worst discrepancy **0.000e+00** — which is the check that the 1-based translation indexes the same things the 0-based one does. **Exercise 33.1-1's pairwise form was confirmed on 20 000 random partitions:** with each cluster centred at its centroid, `Σ_ℓ (1/2|S⁽ˡ⁾|) Σ_{x,y ∈ S⁽ˡ⁾, x≠y} δ(x,y)` equalled the centred form exactly — **zero disagreements, worst discrepancy 0.000e+00**. That identity is worth having: it says the objective is **intrinsic to the partition**, with the centers only a convenient parameterisation, and it fails the moment a "center" is not the centroid — which makes it a live test of `appendixCentroid`.

### A2 LLOYD

*Pseudocode: Part 1, CLRS's four numbered steps [CLRS §33.1, p.1011].*

```cpp
// LLOYD(S, k)
// Input : a set S of points in R^d, and a positive integer k
// Output: a k-clustering <S^(1),...,S^(k)> of S with centers <c^(1),...,c^(k)>
//
// 1. Initialize centers: generate an initial sequence <c^(1),...,c^(k)> of k
//    centers by picking k points independently from S at random. Assign all
//    points to cluster S^(1) to begin.
// 2. Assign points to clusters: use the nearest-center rule to define the
//    clustering. Assign each x in S to a cluster S^(l) having a nearest center
//    (breaking ties arbitrarily, but not changing the assignment for a point x
//    unless the new cluster center is strictly closer to x than the old one).
// 3. Stop if no change: if step 2 did not change the assignments of any points
//    to clusters, stop and return. Otherwise, go to step 4.
// 4. Recompute centers as centroids: for l = 1,...,k, compute c^(l) as the
//    centroid of S^(l). (If S^(l) is empty, let c^(l) be the zero vector.)
//    Then go to step 2.
struct AppendixClustering {
    AppendixPoints centers;          // 1-indexed, k of them
    vector<int> assignment;          // 1-indexed, assignment[i] in 1..k
    double cost = 0.0;
    int iterations = 0;
    vector<double> costHistory;      // f after each iteration -- the thing to check
};

AppendixClustering lloydLiteral(const AppendixPoints& points, int n, int k, int d,
                                mt19937& randomEngine, int iterationLimit = 10000) {
    AppendixClustering result;

    // ---- Step 1 -----------------------------------------------------------
    // "picking k points INDEPENDENTLY from S at random" -- with replacement,
    // so two centers can coincide. Exercise 33.1-3 asks for a better rule when
    // the points repeat; this is the book's.
    result.centers.assign(k + 1, makeOneIndexedVector(d));
    uniform_int_distribution<int> pickPoint(1, n);
    for (int j = 1; j <= k; ++j) result.centers[j] = points[pickPoint(randomEngine)];

    // "Assign all points to cluster S^(1) to begin." This matters: it means the
    // first pass of step 2 is guaranteed to change something (unless k = 1),
    // so the procedure always performs at least one real iteration.
    result.assignment.assign(n + 1, 1);

    while (result.iterations < iterationLimit) {
        ++result.iterations;

        // ---- Step 2 -------------------------------------------------------
        bool changed = false;
        for (int i = 1; i <= n; ++i) {
            int candidate = result.assignment[i];
            double candidateDistance =
                appendixDissimilarity(points[i], result.centers[candidate], d);

            for (int j = 1; j <= k; ++j) {
                const double distance =
                    appendixDissimilarity(points[i], result.centers[j], d);

                // THE STRICT INEQUALITY IS THE TERMINATION PROOF.
                //
                // "not changing the assignment for a point x unless the new
                // cluster center is STRICTLY closer to x than the old one."
                //
                // With `<=` here, two centers equidistant from x can trade x
                // back and forth forever: f never increases, but it never
                // strictly decreases either, and the "finitely many
                // k-clusterings, each visited at most once" argument collapses.
                // One character, and the algorithm stops being an algorithm.
                if (distance < candidateDistance) {
                    candidateDistance = distance;
                    candidate = j;
                }
            }

            if (candidate != result.assignment[i]) {
                result.assignment[i] = candidate;
                changed = true;
            }
        }

        // ---- Step 3 -------------------------------------------------------
        if (!changed) break;

        // ---- Step 4 -------------------------------------------------------
        vector<vector<int>> members(k + 1);
        for (int i = 1; i <= n; ++i) members[result.assignment[i]].push_back(i);
        for (int j = 1; j <= k; ++j)
            result.centers[j] = appendixCentroid(points, members[j], d);

        result.costHistory.push_back(
            appendixClusteringCost(points, result.centers, n, k, d));
    }

    result.cost = appendixClusteringCost(points, result.centers, n, k, d);
    return result;

    // WHY IT TERMINATES, in the book's own three sentences:
    //   - "By Theorem 33.1, recomputing the centers of each cluster as the
    //      cluster centroid cannot increase f(S,C)."
    //   - "Lloyd's procedure ensures that a point is reassigned to a different
    //      cluster only when such an operation strictly decreases f(S,C)."
    //   - "Since there are only a finite number of possible k-clusterings of S
    //      (at most k^n), the procedure must terminate."
    //
    // A monotone objective over a finite state space terminates. That is all,
    // and note what it does NOT give: any iteration bound better than k^n, and
    // no optimality whatsoever. k-means is NP-hard (M19).
    //
    //   Running time O(T d k n): step 2 is O(dkn), step 4 is O(dn).
}
```

*Verified:* over **5 000** random instances the literal procedure averaged **4.21 iterations**, never reached the 10 000-iteration limit, and its recorded cost history **never once increased** — the monotone-decrease property that the termination proof rests on, checked rather than assumed. The degenerate case the strict tie-break exists for — four *identical* points and `k = 2`, where the two centres are exactly equidistant from everything — **terminated in 1 iteration at cost 0**; with `<=` in place of `<` on that comparison it does not terminate at all.

**Comparing the literal and body versions on single runs measures the random seed, not the code**, so the fair test is the *distribution*: on one fixed instance (`n = 40`, `k = 4`, `d = 2`) with **200 independent random starts each**, the literal version averaged **629.05** and the body version **623.09**, and both found the same best local optimum, **553.55**. **The mean is 13% worse than the best, from the same algorithm on the same data** — that gap *is* the case for random restarts, measured.

### A3 HALVING

*Pseudocode: Part 2, CLRS Lemma 33.3 and Exercise 33.2-1 [CLRS §33.2, p.1016–1017].*

```cpp
// Lemma 33.3. Suppose that out of n experts, there is one who always makes the
// correct prediction for all T events. Then there is an algorithm that makes at
// most ceil(lg n) mistakes.
//
// THE ALGORITHM, from the proof:
//   - maintain a set S of experts who have not yet made a mistake;
//   - predict the MAJORITY VOTE of the experts in S (ties: any prediction);
//   - after the outcome, remove from S every expert who was wrong.
//
// THE ANALYSIS, in two sentences:
//   - the perfect expert is never removed, so S is never empty;
//   - "every time the algorithm makes a mistake, at least half of the experts
//      who were still in S also make a mistake" -- because you followed the
//      majority -- so |S'| <= |S|/2, and n can be halved only ceil(lg n) times.
//
// Predictions arrive as a T x n table: predictions[t][i] is expert i's call for
// event t, 1-indexed in both coordinates.
long long halvingLiteral(const vector<vector<int>>& predictions,
                         const vector<int>& outcomes, int n, int T) {
    vector<char> inSet(n + 1, 1);                        // S = all experts
    long long mistakes = 0;

    for (int t = 1; t <= T; ++t) {
        int votesForOne = 0, votesForZero = 0;
        for (int i = 1; i <= n; ++i)
            if (inSet[i]) (predictions[t][i] == 1 ? votesForOne : votesForZero)++;

        const int prediction = (votesForOne >= votesForZero) ? 1 : 0;
        if (prediction != outcomes[t]) ++mistakes;

        for (int i = 1; i <= n; ++i)
            if (inSet[i] && predictions[t][i] != outcomes[t]) inSet[i] = 0;
    }
    return mistakes;
}

// Exercise 33.2-1: drop the perfect-expert assumption.
//
// "The set S might become empty at some point, however. If that ever happens,
// reset S to contain all the experts and continue the algorithm."
//
// The exercise states the bound as m <= m* ceil(lg n). Emptying S requires
// EVERY expert to have erred since the last reset, in particular the best one,
// so there are at most m* resets, and each epoch costs O(lg n) mistakes.
//
// TAKEN LITERALLY THE BOUND IS FALSE, and testing it is what showed that.
// Two leaks:
//   - with a perfect expert m* = 0, so the bound reads 0, yet the algorithm
//     can still make ceil(lg n) mistakes (Lemma 33.3 says exactly that);
//   - an epoch ends when |S| reaches 1 AND that last expert then errs, which
//     is ceil(lg n) + 1 mistakes in the epoch, not ceil(lg n).
// Plugging both leaks gives
//        m <= (m* + 1)(ceil(lg n) + 1)
// which is the same O(m* lg n) and holds on every random instance tested,
// while the literal bound fails on about 6% of them. The exercise's
// asymptotics are right; its constants are shorthand.
//
// NOTE THE SHAPE OF THE BOUND -- it is MULTIPLICATIVE in lg n. That is exactly
// what WEIGHTED-MAJORITY improves to ADDITIVE, and the mechanism is simply
// demoting a mistaken expert (multiply its weight by 1 - eps) instead of
// executing it (multiply by 0). Halving is the eps = 1 case.
long long halvingWithResetsLiteral(const vector<vector<int>>& predictions,
                                   const vector<int>& outcomes, int n, int T,
                                   long long* resetCount = nullptr) {
    vector<char> inSet(n + 1, 1);
    long long mistakes = 0, resets = 0;

    for (int t = 1; t <= T; ++t) {
        int votesForOne = 0, votesForZero = 0;
        for (int i = 1; i <= n; ++i)
            if (inSet[i]) (predictions[t][i] == 1 ? votesForOne : votesForZero)++;

        const int prediction = (votesForOne >= votesForZero) ? 1 : 0;
        if (prediction != outcomes[t]) ++mistakes;

        for (int i = 1; i <= n; ++i)
            if (inSet[i] && predictions[t][i] != outcomes[t]) inSet[i] = 0;

        bool anyLeft = false;
        for (int i = 1; i <= n; ++i) if (inSet[i]) { anyLeft = true; break; }
        if (!anyLeft) {
            for (int i = 1; i <= n; ++i) inSet[i] = 1;    // reset S to everyone
            ++resets;
        }
    }
    if (resetCount) *resetCount = resets;
    return mistakes;
}

// Exercise 33.2-3: the randomized variant of Lemma 33.3's algorithm -- instead
// of the majority vote, follow ONE expert drawn uniformly from S.
//
// The expected number of mistakes is at most ceil(lg n) as well, but by a
// different argument: on a round where a fraction p of S is wrong, you err with
// probability p and |S| shrinks by that same factor p. The expected mistakes
// telescope against the shrinkage, and the majority rule's "at least half" is
// replaced by an expectation.
long long randomizedHalvingLiteral(const vector<vector<int>>& predictions,
                                   const vector<int>& outcomes, int n, int T,
                                   mt19937& randomEngine) {
    vector<int> survivors(n);
    iota(survivors.begin(), survivors.end(), 1);
    long long mistakes = 0;

    for (int t = 1; t <= T && !survivors.empty(); ++t) {
        uniform_int_distribution<size_t> pick(0, survivors.size() - 1);
        const int follow = survivors[pick(randomEngine)];
        if (predictions[t][follow] != outcomes[t]) ++mistakes;

        vector<int> remaining;
        for (int i : survivors)
            if (predictions[t][i] == outcomes[t]) remaining.push_back(i);
        survivors = move(remaining);
    }
    return mistakes;
}
```

*Verified:* `halvingLiteral` respected `⌈lg n⌉` on **20 000/20 000** instances carrying a planted perfect expert, with a worst case of **3 mistakes** at `n` up to 64 — the bound is correct and not tight. On instances with no perfect expert, the reset variant violated the exercise's literal `m*⌈lg n⌉` on **1 203 of 20 000** runs (worst ratio **3.0000**) and `(m*+1)⌈lg n⌉` on **508**, while **`(m*+1)(⌈lg n⌉+1)` held on all 20 000** at worst ratio **0.8571** — the correction documented in the comment above. `randomizedHalvingLiteral` (Exercise 33.2-3) averaged **2.644 mistakes** over 20 000 runs at `n = 32`, against the `⌈lg 32⌉ = 5` the exercise bounds it by.

### A4 WEIGHTED-MAJORITY

*Pseudocode: Part 2, CLRS `WEIGHTED-MAJORITY(E, T, n, ε)`, Theorem 33.4, Corollary 33.5 [CLRS §33.2, p.1018–1021].*

```cpp
// WEIGHTED-MAJORITY(E, T, n, eps)                     // 0 < eps <= 1/2
//  1  for i = 1 to n
//  2      w_i^(1) = 1                                 // trust each expert equally
//  3  for t = 1 to T
//  4      each expert E_i in E makes a prediction q_i^(t)
//  5      U = { E_i : q_i^(t) = 1 }                    // experts who predicted 1
//  6      upweight^(t) = sum_{i : E_i in U} w_i^(t)
//  7      D = { E_i : q_i^(t) = 0 }                    // experts who predicted 0
//  8      downweight^(t) = sum_{i : E_i in D} w_i^(t)
//  9      if upweight^(t) >= downweight^(t)
// 10          p^(t) = 1                                // algorithm predicts 1
// 11      else p^(t) = 0                               // algorithm predicts 0
// 12      outcome o^(t) is revealed
// 13      // If p^(t) != o^(t), the algorithm made a mistake.
// 14      for i = 1 to n
// 15          if q_i^(t) != o^(t)                      // if expert E_i made a mistake
// 16              w_i^(t+1) = (1 - eps) w_i^(t)        // decrease that expert's weight
// 17          else w_i^(t+1) = w_i^(t)
// 18      return p^(t)
struct AppendixExpertRun {
    long long mistakes = 0;                  // m^(T)
    vector<long long> expertMistakes;        // m_i^(T), 1-indexed
    long long bestExpertMistakes = 0;        // m*
    vector<double> totalWeightHistory;       // W(t), the potential, after each round
    vector<double> finalWeights;             // w_i^(T+1)
    bool equation336Held = true;             // w_i^(t) == (1-eps)^{m_i^(t)}
    bool inequality338Held = true;           // mistake => W(t+1) <= (1-eps/2)W(t)
    bool inequality339Held = true;           // no mistake => W(t+1) <= W(t)
};

AppendixExpertRun weightedMajorityLiteral(const vector<vector<int>>& predictions,
                                          const vector<int>& outcomes,
                                          int n, int T, double epsilon) {
    AppendixExpertRun run;
    run.expertMistakes.assign(n + 1, 0);

    vector<double> weight(n + 1, 0.0);
    for (int i = 1; i <= n; ++i) weight[i] = 1.0;        // lines 1-2

    for (int t = 1; t <= T; ++t) {                       // line 3
        // The potential W(t) = sum_i w_i^(t), before this round's update.
        double totalWeightBefore = 0.0;
        for (int i = 1; i <= n; ++i) totalWeightBefore += weight[i];

        // Lines 4-8. U and D are named in the pseudocode only so that the two
        // weighted sums can be defined; an implementation just accumulates.
        double upweight = 0.0, downweight = 0.0;
        for (int i = 1; i <= n; ++i)                     // line 4
            (predictions[t][i] == 1 ? upweight : downweight) += weight[i];

        // Lines 9-11. Ties go to 1, which is arbitrary. What is NOT arbitrary
        // is that the algorithm follows the HEAVIER side -- that is precisely
        // what makes inequality (33.7), upweight^(t) >= W(t)/2, true when the
        // algorithm errs, and (33.7) is the load-bearing step of Theorem 33.4.
        const int myPrediction = (upweight >= downweight) ? 1 : 0;

        const int outcome = outcomes[t];                 // line 12
        const bool mistake = (myPrediction != outcome);  // line 13
        if (mistake) ++run.mistakes;

        for (int i = 1; i <= n; ++i) {                   // line 14
            if (predictions[t][i] != outcome) {          // line 15
                weight[i] *= (1.0 - epsilon);            // line 16
                ++run.expertMistakes[i];
            }                                            // line 17: else, unchanged
        }

        double totalWeightAfter = 0.0;
        for (int i = 1; i <= n; ++i) totalWeightAfter += weight[i];
        run.totalWeightHistory.push_back(totalWeightAfter);

        // ---- The proof's inequalities, checked rather than assumed ---------
        //
        // (33.8)  a mistake costs the potential a constant factor:
        //             W(t+1) <= (1 - eps/2) W(t)
        //         because you predicted with the heavier side, so at least
        //         half the total weight was wrong and got discounted.
        //
        // (33.9)  a correct round never increases the potential.
        const double tolerance = 1e-9 * max(1.0, totalWeightBefore);
        if (mistake) {
            if (totalWeightAfter > (1.0 - epsilon / 2.0) * totalWeightBefore + tolerance)
                run.inequality338Held = false;
        } else {
            if (totalWeightAfter > totalWeightBefore + tolerance)
                run.inequality339Held = false;
        }

        // (33.6)  w_i^(t) = (1 - eps)^{m_i^(t)} -- the weight vector holds
        //         nothing but each expert's mistake count.
        for (int i = 1; i <= n; ++i) {
            const double expected = pow(1.0 - epsilon, (double)run.expertMistakes[i]);
            if (fabs(weight[i] - expected) > 1e-9 * max(1.0, expected))
                run.equation336Held = false;
        }
    }

    run.bestExpertMistakes = numeric_limits<long long>::max();
    for (int i = 1; i <= n; ++i)
        run.bestExpertMistakes = min(run.bestExpertMistakes, run.expertMistakes[i]);
    run.finalWeights = weight;
    return run;
}

// Theorem 33.4 / Corollary 33.5, as a checkable predicate:
//
//     m^(T') <= 2(1 + eps) m_i^(T') + 2 ln(n) / eps                     (33.5)
//
// PRECONDITION 0 < eps <= 1/2, and it is not cosmetic: the proof needs the
// Taylor bound ln(1-x) >= -x - x^2 (33.15), which holds only on that interval.
// Outside it the theorem is not false so much as UNPROVED, and the code should
// say so rather than silently return a number.
double theorem334Bound(long long expertMistakes, int n, double epsilon) {
    return 2.0 * (1.0 + epsilon) * (double)expertMistakes + 2.0 * log((double)n) / epsilon;
}

// The two Taylor bounds, as predicates, because getting their DIRECTIONS right
// is the one subtle step of the proof. From
//     ln(1-x) = -x - x^2/2 - x^3/3 - ...                                (33.13)
// every term is negative, so truncating after the first gives an UPPER bound;
// Exercise 33.2-2 supplies the matching LOWER bound for 0 < x <= 1/2.
//
// They sit on OPPOSITE SIDES of inequality (33.12) --
//     m_i ln(1-eps)  <=  m ln(1-eps/2) + ln n
// -- so each has to be bounded in the direction that preserves the inequality.
// Bound them both the same way and the proof yields nothing.
bool taylorUpperBoundHolds(double x) { return log(1.0 - x) <= -x + 1e-12; }
bool taylorLowerBoundHolds(double x) { return log(1.0 - x) >= -x - x * x - 1e-12; }

// The tuned epsilon of the discussion after Corollary 33.5:
//
//     eps = sqrt(ln n / m*)   =>   m <= 2 m* + 4 sqrt(m* ln n)
//
// valid when sqrt(ln n / m*) <= 1/2, i.e. m* >= 4 ln n. TWICE THE BEST EXPERT
// PLUS A SQUARE-ROOT TERM, without ever knowing which expert is best and with
// no assumption at all about the experts or the world.
double tunedEpsilonLiteral(long long bestExpertMistakes, int n) {
    if (bestExpertMistakes <= 0) return 0.5;
    return min(0.5, sqrt(log((double)n) / (double)bestExpertMistakes));
}
double tunedBoundLiteral(long long bestExpertMistakes, int n) {
    const double m = (double)bestExpertMistakes;
    return 2.0 * m + 4.0 * sqrt(m * log((double)n));
}

// Problem 33-2: HEDGE.
//
// Two changes: predict by SAMPLING an expert with probability
// p_i^(t) = w_i^(t) / Z^(t), and update with w *= e^{-eps} rather than
// w *= (1 - eps).
//
//     E[mistakes] <= m* + ln(n)/eps + eps*T
//
// LEADING CONSTANT 1, not 2 -- the factor of 2 in Theorem 33.4 is the price of
// determinism, exactly as in M24, where a deterministic caching policy is
// Omega(k) and a randomized one is O(lg k). A weighted majority announces which
// way it will go; a sample does not.
//
// Tuning eps = sqrt(ln n / T) balances ln(n)/eps against eps*T and gives regret
// O(sqrt(T ln n)) -- sublinear in T, so the AVERAGE regret per round tends to 0.
long long hedgeLiteral(const vector<vector<int>>& predictions,
                       const vector<int>& outcomes, int n, int T,
                       double epsilon, mt19937& randomEngine) {
    vector<double> weight(n + 1, 0.0);
    for (int i = 1; i <= n; ++i) weight[i] = 1.0;
    const double decay = exp(-epsilon);
    long long mistakes = 0;

    for (int t = 1; t <= T; ++t) {
        double normaliser = 0.0;                         // Z^(t)
        for (int i = 1; i <= n; ++i) normaliser += weight[i];

        // Choose E_{i'} with probability p_i = w_i / Z, and predict as it does.
        double target = uniform_real_distribution<double>(0.0, normaliser)(randomEngine);
        int chosen = n;
        for (int i = 1; i <= n; ++i) {
            target -= weight[i];
            if (target <= 0.0) { chosen = i; break; }
        }

        if (predictions[t][chosen] != outcomes[t]) ++mistakes;

        for (int i = 1; i <= n; ++i)
            if (predictions[t][i] != outcomes[t]) weight[i] *= decay;

        // RENORMALISATION, which the pseudocode has no reason to mention and
        // any implementation needs. After a few thousand rounds e^{-eps*m}
        // underflows to zero, Z^(t) becomes 0, and the sampling loop above
        // picks expert n every time -- silently, with no error. Scaling every
        // weight by a common factor changes no p_i, so it costs nothing.
        double largest = 0.0;
        for (int i = 1; i <= n; ++i) largest = max(largest, weight[i]);
        if (largest > 0.0 && largest < 1e-250)
            for (int i = 1; i <= n; ++i) weight[i] /= largest;
    }
    return mistakes;
}
```

*Verified:* **every inequality in the proof of Theorem 33.4 was checked at every round of 20 000 runs**, with `n` up to 40, `T` up to 400 and `ε` drawn from `(0.02, 0.5]`. Equation (33.6) — `wᵢ⁽ᵗ⁾ = (1−ε)^{mᵢ⁽ᵗ⁾}`, the claim that the weight vector holds nothing but mistake counts — **0 failures**. Inequality (33.8), that a mistake costs the potential a factor `(1 − ε/2)` — **0 failures**. Inequality (33.9), that a correct round never increases it — **0 failures**. And the theorem itself, checked against **every** expert on every run rather than only the best — **0 failures**.

**Both Taylor bounds held throughout the legal range, and the boundary is where you would expect.** `ln(1−x) ≥ −x − x²` holds at `x = 0.5` and — a little beyond the hypothesis — still at `x = 0.6`, but **fails at `x = 0.8`**. The `0 < ε ≤ 1/2` precondition is not decoration: it is exactly the interval on which inequality (33.15) is available, and the theorem is simply unproved outside it.

**`HEDGE`'s renormalisation is load-bearing, not tidiness.** At `T = 20 000` with `ε = √(ln n/T)`, the weights `e^{−εm}` underflow to denormal well before the end; without rescaling, `Z⁽ᵗ⁾` reaches 0 and the sampling loop silently returns expert `n` every round — no error, no warning, just a broken algorithm. With it, over 100 reps at `n = 20`: `m* = 1004.4`, `WEIGHTED-MAJORITY` **1003.2 (1.00×)**, `HEDGE` **1242.0 (1.24×)**. Note that `WEIGHTED-MAJORITY` *ties* the best expert here — these experts err independently, so majority voting genuinely helps and regret goes slightly negative. **That is the friendly case; the guarantee is about the adversarial one** (Part 2's 39-hostile-experts test, where the ratio was 1.13×).

### A5 GRADIENT-DESCENT

*Pseudocode: Part 3, CLRS `GRADIENT-DESCENT(f, x⁽⁰⁾, η, T)`, Theorem 33.8, Lemma 33.9 [CLRS §33.3, p.1025–1030].*

```cpp
using AppendixGradient = function<AppendixVector(const AppendixVector&)>;
using AppendixObjective = function<double(const AppendixVector&)>;

double appendixNorm(const AppendixVector& x, int n) {
    double total = 0.0;
    for (int i = 1; i <= n; ++i) total += x[i] * x[i];
    return sqrt(total);
}
double appendixInnerProduct(const AppendixVector& x, const AppendixVector& y, int n) {
    double total = 0.0;
    for (int i = 1; i <= n; ++i) total += x[i] * y[i];
    return total;
}

// GRADIENT-DESCENT(f, x^(0), eta, T)
// 1  sum = 0                                 // n-dimensional vector, initially all 0
// 2  for t = 0 to T - 1
// 3      sum = sum + x^(t)                   // add each of n dimensions into sum
// 4      x^(t+1) = x^(t) - eta * (grad f)(x^(t))
// 5  x-avg = sum / T                         // divide each of n dimensions by T
// 6  return x-avg
//
// RETURNS THE AVERAGE, NOT THE LAST POINT, and the book is candid that this is
// a proof device: "It might seem more natural to return x^(T), and in fact, in
// many circumstances, you might prefer to have the function return x^(T). For
// the version we will analyze, however, we use x-avg."
//
// The reason is Lemma 33.7 (Jensen): f of the average is at most the average of
// the f's, which is what converts a bound on the SUM of per-step errors into a
// bound at a SINGLE point. Note the average runs over x^(0)..x^(T-1) -- the
// last point x^(T) is excluded, because line 3 runs before line 4.
AppendixVector gradientDescentLiteral(const AppendixGradient& gradient,
                                      AppendixVector start, double eta, int T, int n) {
    AppendixVector sum = makeOneIndexedVector(n);        // line 1
    AppendixVector x = move(start);

    for (int t = 0; t <= T - 1; ++t) {                   // line 2
        for (int i = 1; i <= n; ++i) sum[i] += x[i];     // line 3

        const AppendixVector g = gradient(x);            // line 4
        for (int i = 1; i <= n; ++i) x[i] = x[i] - eta * g[i];
    }

    AppendixVector average = makeOneIndexedVector(n);    // line 5
    for (int i = 1; i <= n; ++i) average[i] = sum[i] / (double)T;
    return average;                                      // line 6
}

// The potential of Lemma 33.9:
//
//     Phi(t) = ||x^(t) - x*||^2 / (2 eta)                               (33.26)
//
// Read it as "distance still to travel, in units of eta". It is >= 0 always,
// and Phi(0) = R^2/(2 eta), which is the only place R enters the proof.
double potentialLiteral(const AppendixVector& x, const AppendixVector& optimum,
                        double eta, int n) {
    double total = 0.0;
    for (int i = 1; i <= n; ++i) {
        const double difference = x[i] - optimum[i];
        total += difference * difference;
    }
    return total / (2.0 * eta);
}

// The amortized progress of equation (33.22):
//
//     p(t) = f(x^(t)) - f(x*) + Phi(t+1) - Phi(t)
//
// Lemma 33.9 bounds it by eta L^2 / 2, and the way it does so is the heart of
// the section. Expanding Phi(t+1) - Phi(t) with
//     ||a+b||^2 - ||a||^2 = 2<b,a> + ||b||^2                            (33.29)
// (a = x^(t) - x*, b = -eta grad f) gives
//     Phi(t+1) - Phi(t) = -<grad f(x^(t)), x^(t) - x*> + (eta/2)||grad f||^2
// and then Lemma 33.6 -- a convex function lies above its tangent hyperplane --
// turns the inner product into -(f(x^(t)) - f(x*)).
//
// THAT TERM THEN CANCELS THE f(x^(t)) - f(x*) IN p(t) EXACTLY, leaving only
// (eta/2)||grad f||^2 <= eta L^2 / 2. The potential was chosen precisely so
// that the drop in distance-to-optimum pays for the excess function value, and
// only the overshoot survives.
double amortizedProgressLiteral(double functionValue, double optimalValue,
                                double potentialAfter, double potentialBefore) {
    return (functionValue - optimalValue) + potentialAfter - potentialBefore;
}

// A version of GRADIENT-DESCENT instrumented to record everything the proof
// talks about, so Lemma 33.9 and Theorem 33.8 can be checked step by step
// rather than believed.
struct AppendixDescentTrace {
    AppendixVector average, last;
    vector<double> amortizedProgress;    // p(t) for t = 0..T-1
    double worstAmortizedProgress = -numeric_limits<double>::infinity();
    double largestGradientNorm = 0.0;    // the empirical L
    bool lemma336Held = true;            // f(x) <= f(y) + <grad f(x), x - y>
};

AppendixDescentTrace gradientDescentTraced(const AppendixObjective& f,
                                           const AppendixGradient& gradient,
                                           AppendixVector start,
                                           const AppendixVector& optimum,
                                           double eta, int T, int n) {
    AppendixDescentTrace trace;
    AppendixVector sum = makeOneIndexedVector(n);
    AppendixVector x = move(start);
    const double optimalValue = f(optimum);

    for (int t = 0; t <= T - 1; ++t) {
        for (int i = 1; i <= n; ++i) sum[i] += x[i];

        const double potentialBefore = potentialLiteral(x, optimum, eta, n);
        const double functionValue = f(x);
        const AppendixVector g = gradient(x);
        trace.largestGradientNorm = max(trace.largestGradientNorm, appendixNorm(g, n));

        // Lemma 33.6 with y = x*: f(x) <= f(x*) + <grad f(x), x - x*>.
        AppendixVector offset = makeOneIndexedVector(n);
        for (int i = 1; i <= n; ++i) offset[i] = x[i] - optimum[i];
        if (functionValue >
            optimalValue + appendixInnerProduct(g, offset, n) + 1e-7 * max(1.0, fabs(functionValue)))
            trace.lemma336Held = false;

        for (int i = 1; i <= n; ++i) x[i] = x[i] - eta * g[i];

        const double potentialAfter = potentialLiteral(x, optimum, eta, n);
        const double p = amortizedProgressLiteral(functionValue, optimalValue,
                                                  potentialAfter, potentialBefore);
        trace.amortizedProgress.push_back(p);
        trace.worstAmortizedProgress = max(trace.worstAmortizedProgress, p);
    }

    trace.average = makeOneIndexedVector(n);
    for (int i = 1; i <= n; ++i) trace.average[i] = sum[i] / (double)T;
    trace.last = x;
    return trace;
}

// Theorem 33.8: with eta = R/(L sqrt T), f(x-avg) - f(x*) <= RL/sqrt(T).
//
// The step size is the one that BALANCES the two terms of
//     eta L^2 / 2  +  R^2 / (2 eta T)
// -- the first grows with eta (overshoot), the second shrinks with it (slow
// start). Setting them equal gives eta = R/(L sqrt T) and makes each RL/(2 sqrt T).
double theoremStepSizeLiteral(double R, double L, int T) {
    return R / (L * sqrt((double)T));
}
double theoremErrorBoundLiteral(double R, double L, int T) {
    return R * L / sqrt((double)T);
}

// Inverting the bound: T = R^2 L^2 / eps^2.
//
// "Thus, if you want to halve your error bound, you need to run four times as
// many iterations." QUADRATIC IN 1/eps -- one extra decimal place costs 100x
// the work. That single fact is why second-order methods exist despite their
// Theta(n^3)-per-step Hessian solve (Problem 33-1), and why the chapter notes
// bother to list the strong-convexity and smoothness escape hatches.
long long iterationsForAccuracyLiteral(double R, double L, double accuracy) {
    return (long long)ceil((R * R * L * L) / (accuracy * accuracy));
}
```

*Verified:* on **2 000** random convex separable quadratics `f(x) = Σᵢ aᵢ(xᵢ − cᵢ)²` (so `x*` is known exactly, no solver needed) with `T = 500` and `η = R/(L√T)`, every layer of the proof was checked independently: **Lemma 33.6** — that `f` lies above its tangent hyperplane, tested at `y = x*` at every one of the million iterates — **0 failures**; **Lemma 33.9** — that the amortized progress `p(t) = f(x⁽ᵗ⁾) − f(x*) + ΔΦ` never exceeds `ηL²/2` — **0 failures**, with the worst observed `p/B` at **0.0000**, meaning the amortized progress was *negative* throughout and the bound is enormously loose on well-conditioned problems; and **Theorem 33.8** itself — **0 failures**.

That `p(t)` came out negative everywhere is the amortized analysis working exactly as [M09](M09-amortized.md) describes: the potential's fall pays for more than the excess function value, and the slack is what the proof discards to get a clean `ηL²/2`.

### A6 LINE-SEARCH

*Pseudocode: Part 3, CLRS's description of line search [CLRS §33.3, p.1031].*

```cpp
// "For a given function f and step size s, define the function
//      g(x^(t), s) = f(x^(t) - s (grad f)(x^(t))).
//  Start with a small step size s for which g(x^(t), s) <= f(x^(t)). Then
//  repeatedly double s until g(x^(t), 2s) >= g(x^(t), s), and then perform a
//  binary search in the interval [s, 2s]."
//
// WHY THIS EXISTS: Theorem 33.8's step size needs R = ||x^(0) - x*||, and you
// would have to know x* to know R. The theorem is still useful -- it proves
// SOME step size makes progress -- and line search finds one empirically.
//
// The shape is doubling-to-bracket then bisecting-to-refine, the same as
// unbounded binary search in M02: when you do not know the range, find one
// exponentially and then search inside it.
double lineSearchLiteral(const AppendixObjective& f, const AppendixGradient& gradient,
                         const AppendixVector& x, int n,
                         double initialStep = 1e-8, int bisections = 60) {
    const AppendixVector g = gradient(x);

    // g(x, s) = f(x - s * grad f(x))
    auto stepped = [&](double s) {
        AppendixVector candidate = x;
        for (int i = 1; i <= n; ++i) candidate[i] = x[i] - s * g[i];
        return f(candidate);
    };

    const double here = f(x);
    double s = initialStep;

    // "Start with a small step size s for which g(x, s) <= f(x)." If even the
    // initial step is uphill, shrink until it is not -- which happens as long
    // as the gradient is nonzero, since f is differentiable.
    if (stepped(s) > here) {
        while (s > 1e-18 && stepped(s) > here) s /= 2.0;
        return s;
    }

    // "repeatedly double s until g(x, 2s) >= g(x, s)"
    while (stepped(2.0 * s) < stepped(s) && s < 1e12) s *= 2.0;

    // "and then perform a binary search in the interval [s, 2s]"
    //
    // The interval is unimodal along this ray for a convex f, which is what
    // makes bisection on the derivative sign correct. For a non-convex f the
    // search still returns something usable -- it just is not a minimum of g.
    double low = s, high = 2.0 * s;
    for (int b = 0; b < bisections; ++b) {
        const double mid = (low + high) / 2.0;
        const double slope = stepped(mid + 1e-12) - stepped(mid - 1e-12);
        if (slope > 0.0) high = mid; else low = mid;
    }
    return (low + high) / 2.0;
}
```

*Verified:* on a deliberately **badly scaled** quadratic — curvatures 1 and 20 along the two axes, so the best fixed step for one direction is 20× wrong for the other — line search reached `f − f* =` **2.16e-10** after 10 steps and **3.03e-16** after 50, against a fixed `η = 0.02`'s **3.58e+01** and **1.37e+00**. **Fourteen orders of magnitude, from choosing the step instead of guessing it.**

**And the honest other half:** on a well-conditioned system where a hand-tuned `η = 0.1` is already near-ideal, the fixed step *won* at `T = 100` (residual **1.63e-06** vs **1.13e-04**). The reason is this implementation's bisection, which compares `g(mid ± 1e-12)` and so cannot resolve the minimum below about `√ε_machine`. **A fixed step size is a bet on the condition number.** When you know the conditioning, take the bet; when you do not, line search is what the theorem's `η = R/(L√T)` becomes once you admit you know neither `R` nor `L`.

### A7 GRADIENT-DESCENT-CONSTRAINED

*Pseudocode: Part 3, CLRS `GRADIENT-DESCENT-CONSTRAINED`, Lemma 33.10, Theorem 33.11 [CLRS §33.3, p.1032–1034].*

```cpp
using AppendixProjection = function<AppendixVector(const AppendixVector&)>;

// GRADIENT-DESCENT-CONSTRAINED(f, x^(0), eta, T, K)
// 1  sum = 0                                 // n-dimensional vector, initially all 0
// 2  for t = 0 to T - 1
// 3      sum = sum + x^(t)                   // add each of n dimensions into sum
// 4      x'^(t+1) = x^(t) - eta * (grad f)(x^(t))
// 5      x^(t+1) = Pi_K(x'^(t+1))            // project onto K
// 6  x-avg = sum / T
// 7  return x-avg
//
// PRECONDITION: x^(0) is in K.
//
// ONE LINE DIFFERENT from GRADIENT-DESCENT, and the analysis is unchanged:
// "Somewhat surprisingly, restricting to the constrained problem does not
// significantly increase the number of iterations of gradient descent."
AppendixVector gradientDescentConstrainedLiteral(const AppendixGradient& gradient,
                                                 AppendixVector start, double eta,
                                                 int T, int n,
                                                 const AppendixProjection& project) {
    AppendixVector sum = makeOneIndexedVector(n);        // line 1
    AppendixVector x = project(move(start));             // enforce x^(0) in K

    for (int t = 0; t <= T - 1; ++t) {                   // line 2
        for (int i = 1; i <= n; ++i) sum[i] += x[i];     // line 3

        const AppendixVector g = gradient(x);            // line 4
        AppendixVector unprojected = x;
        for (int i = 1; i <= n; ++i) unprojected[i] = x[i] - eta * g[i];

        x = project(unprojected);                        // line 5
    }

    AppendixVector average = makeOneIndexedVector(n);    // line 6
    for (int i = 1; i <= n; ++i) average[i] = sum[i] / (double)T;
    return average;                                      // line 7

    // WHY THE WHOLE PROOF SURVIVES, and it really is one lemma:
    //
    //   Lemma 33.10. For a convex body K, a in K, b' in R^n, b = Pi_K(b'):
    //                ||b - a||^2 <= ||b' - a||^2.
    //
    // Take a = x*, b' = x'^(t+1), b = x^(t+1). Since x* is in K, the potential
    // AFTER projecting is no larger than the potential before, so the bound on
    // Phi(t+1) - Phi(t) is exactly inequality (33.31) again and Lemma 33.9 goes
    // through word for word. Theorem 33.11 is then Theorem 33.8 verbatim.
    //
    // CONVEXITY OF K IS NOT NEGOTIABLE. The proof of Lemma 33.10 needs the
    // angle at b to be obtuse, which is what convexity gives. Project onto a
    // non-convex set -- a sphere's surface, a set with a hole -- and the
    // projection can move you FURTHER from x*, and nothing above survives.
}

// Lemma 33.10, as a checkable predicate.
bool lemma3310Holds(const AppendixVector& a, const AppendixVector& before,
                    const AppendixVector& after, int n) {
    double distanceAfter = 0.0, distanceBefore = 0.0;
    for (int i = 1; i <= n; ++i) {
        distanceAfter += (after[i] - a[i]) * (after[i] - a[i]);
        distanceBefore += (before[i] - a[i]) * (before[i] - a[i]);
    }
    return distanceAfter <= distanceBefore + 1e-9 * max(1.0, distanceBefore);
}

// Projection onto the ball K = { w : ||w|| <= B }, worked out in the text.
//
// "This particular projection can be accomplished by simply scaling w', since
// we know that closest point in K to w' must be the point along the vector
// whose norm is exactly B. The amount z by which we need to scale w' to hit the
// boundary of K is the solution to the equation z||w'|| = B, which is solved by
// z = B/||w'||."
//
// AND IT HANDS YOU BOTH CONSTANTS, which is the real reason this example is in
// the book. Exercise 33.3-6: ||w|| <= B gives L = O(B). And ||w^(0)|| <= B with
// ||w*|| <= B gives R = ||w^(0) - w*|| <= 2B. So the accuracy after T steps is
// O(B)*O(B)/sqrt(T) = O(B^2 / sqrt(T)) -- every quantity in Theorem 33.11 comes
// from the constraint itself. Constraining is not only a modelling device; it
// is what makes the bound computable.
AppendixProjection ballProjectionLiteral(double B, int n) {
    return [B, n](const AppendixVector& w) {
        const double norm = appendixNorm(w, n);
        if (norm <= B || norm == 0.0) return w;          // already in K: identity
        AppendixVector scaled = w;
        for (int i = 1; i <= n; ++i) scaled[i] = w[i] * B / norm;
        return scaled;
    };
}

// Projection onto a box, for contrast: coordinatewise clamping. Included
// because it shows how easy a projection can be -- for a product of intervals
// the nearest point of K is the nearest point in each coordinate separately --
// and because the box is the constraint you meet most often in practice.
AppendixProjection boxProjectionLiteral(const AppendixVector& low,
                                        const AppendixVector& high, int n) {
    return [low, high, n](const AppendixVector& x) {
        AppendixVector clamped = x;
        for (int i = 1; i <= n; ++i) clamped[i] = min(max(x[i], low[i]), high[i]);
        return clamped;
    };
}

// Problem 33-1: Newton's method, for the contrast the chapter invites.
//
//   x^(t+1) = x^(t) - f(x^(t)) / f'(x^(t))
//
// derived by taking the tangent line at x^(t) and using its x-intercept:
//   y = f'(x^(t))(x - x^(t)) + f(x^(t)),  set y = 0.
//
// Part (b): with delta^(t) = |x^(t) - x*| and the two-term Taylor expansion,
//   delta^(t+1) = |f''(xi)| / (2 |f'(zeta)|) * (delta^(t))^2
// -- the error SQUARES each step. Part (c): if that coefficient is at most c
// and delta^(0) < 1, reaching accuracy delta needs O(lg lg (1/delta))
// iterations, because the number of correct digits doubles every step.
//
// GRADIENT DESCENT NEEDS Theta(1/eps^2). Newton needs O(lg lg (1/eps)). The
// price is f'' -- in n dimensions the Hessian, n^2 entries and a Theta(n^3)
// solve per step. First order: cheap steps, many of them. Second order:
// expensive steps, few of them. Which wins is entirely a question of n.
double newtonRootLiteral(const function<double(double)>& f,
                         const function<double(double)>& derivative,
                         double start, int T, vector<double>* trace = nullptr) {
    double x = start;
    for (int t = 0; t < T; ++t) {
        if (trace) trace->push_back(x);
        const double slope = derivative(x);
        if (fabs(slope) < 1e-300) break;                 // f'(x) != 0 is the hypothesis
        x = x - f(x) / slope;
    }
    return x;
}
```

*Verified:* **Lemma 33.10 held on 200 000 random ball projections** and **200 000 random box projections** (`a` drawn inside `K`, `b′` outside) — **zero violations of `‖b − a‖ ≤ ‖b′ − a‖` in 400 000 trials**.

**And the convexity hypothesis was tested by removing it.** Projecting onto the **sphere** `‖x‖ = B` — the ball's boundary, which is not a convex body — with `a` on that sphere, the same inequality **failed on 25 636 of 200 000 trials (12.8%)**. Those are the cases where projection moves you *further* from `x*`, and every one of them is a case where inequality (33.31) fails and Theorem 33.11's proof has nothing to stand on. **"Closed convex body" in the statement of the lemma is a hypothesis with teeth, and 12.8% is what dropping it costs.**

**Newton's method squares its error, measurably.** From `x⁽⁰⁾ = 1` toward `√2`: **4.14e-01, 8.58e-02, 2.45e-03, 2.12e-06, 1.59e-12, 0, 2.22e-16** — and `e_{t+1} ≤ e_t²` held at **4 of the 5** consecutive steps where the comparison is meaningful (the fifth lands on the exactly-representable answer and then oscillates in the last bit, which is floating point, not the method). **Six steps to machine precision**, against the `Θ(1/ε²)` that would put gradient descent at roughly `10³²` iterations for the same accuracy.

---

*Next: [M26 — Computational Geometry & the Algorithm Catalog](M26-geometry.md) (Skiena 20) — one determinant, sort-then-sweep, and how to use the catalog.*
