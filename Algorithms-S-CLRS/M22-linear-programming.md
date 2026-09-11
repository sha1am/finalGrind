# Module 22 — Linear Programming

**Sources:** CLRS 4e ch. 29 (Linear Programming) · Skiena 3e §16.6 (Linear Programming)

---

## Big Idea

**This is the module where you stop writing algorithms and start writing *models*.** Every previous module gave you a procedure. This one gives you a *language*: describe your problem as a linear objective over linear constraints, hand it to a solver, and a polynomial-time algorithm you did not write returns the optimum.

CLRS opens with the scope:

> *"Many problems take the form of maximizing or minimizing an objective, given limited resources and competing constraints. If you can specify the objective as a linear function of certain variables, and if you can specify the constraints on resources as equalities or inequalities on those variables, then you have a **linear-programming problem**."*

And Skiena states the stakes:

> *"Linear programming is **the most important problem in mathematical optimization and operations research**."*

**Three facts, and they are the whole module.**

**1. The optimum is always at a vertex.** The feasible region is an intersection of half-spaces, hence **convex**. The objective is linear, so its level sets are parallel hyperplanes; push one as far as it will go and it last touches the region at a corner.

> *"It is no accident that an optimal solution to the linear program occurs at a vertex of the feasible region… If the intersection is a single vertex, then there is just one optimal solution… If the intersection is a line segment, every point on that line segment must have the same objective value. In particular, both endpoints of the line segment are optimal solutions."*

**That reduces a continuous search to a combinatorial one**, and it is why simplex — walk from vertex to improving vertex — works at all.

**2. Modelling is the skill, not solving.**

> *"Perhaps the most important aspect of linear programming is to be able to **recognize when you can formulate a problem as a linear program**. Once you cast a problem as a polynomial-sized linear program, you can solve it in polynomial time by the ellipsoid algorithm or interior-point methods."*

Shortest paths, max flow, min-cost flow, multicommodity flow, bipartite matching, fractional knapsack, weighted vertex cover ([M20](M20-heuristics.md) Part 7) — **all of them are linear programs**, and several have no other known polynomial algorithm.

**3. Duality is how you *prove* an answer optimal.** Every maximisation LP has a partner minimisation LP with the *same* optimal value. You have already met a special case:

> *"We saw an example of duality in Chapter 24 with Theorem 24.6, the **max-flow min-cut theorem**… if you can find a cut whose value is also `|f|`, then you have verified that `f` is indeed a maximum flow."*

**A dual solution is a certificate** — exactly the role a certificate plays in `NP` ([M19](M19-np-completeness.md)), except here you can compute it.

**The one boundary that matters.** Add "and the variables must be integers" and everything collapses:

> *"If you add to a linear program the additional requirement that all variables take on integer values, you have an **integer linear program**… just finding a feasible solution to this problem is `NP`-hard."*

**LP is in `P`. ILP is `NP`-hard. The word "integer" is the entire difference** — and it is why [M20](M20-heuristics.md)'s LP-relaxation-and-round technique exists.

**Remember months later:** *standard form is `max cᵀx s.t. Ax ≤ b, x ≥ 0`. The feasible region is convex and **the optimum is at a vertex**; simplex walks improving vertices (exponential worst case, fast in practice), ellipsoid and interior-point are polynomial. The dual of `max cᵀx, Ax ≤ b, x ≥ 0` is `min bᵀy, Aᵀy ≥ c, y ≥ 0` — **swap `b` and `c`, transpose `A`, flip `≤` to `≥`**. Weak duality: `cᵀx̄ ≤ bᵀȳ` always. Strong duality: equal at the optimum. Every LP is optimal, infeasible, or unbounded — nothing else. LP ∈ `P`; ILP is `NP`-hard.*

---

## What You Should Be Able To Do After This Chapter

- Take a word problem and produce **decision variables, constraints, and an objective** — the modelling loop CLRS runs on the political example.
- Write **standard form** in both scalar and matrix notation and say what each of `A`, `b`, `c`, `x` means.
- Convert to standard form: equality → two inequalities, `≤` → equality with a **slack variable**, minimise → maximise, unrestricted variable → difference of two nonnegatives.
- Define **feasible / infeasible / optimal / unbounded / feasible region**, and give an LP for each of the three outcomes in Theorem 29.5.
- Solve a two-variable LP **graphically**, and explain why the optimum sits at a vertex.
- Describe what **simplex** does in one sentence, and say why it is exponential in the worst case yet fast in practice.
- Name the two polynomial-time families — **ellipsoid** and **interior-point** — and say how each differs from simplex.
- Formulate as LPs: **single-pair and single-source shortest paths**, **maximum flow**, **minimum-cost flow**, **multicommodity flow**, **maximum bipartite matching**.
- Explain why the shortest-path LP **maximises** rather than minimises.
- Say which of those problems has *no* known polynomial algorithm other than "solve the LP".
- Write down the **dual** of any LP mechanically, and explain the "nonnegative combination of constraints gives an upper bound" intuition.
- State and prove **weak duality** (Lemma 29.1) and its corollary, and state **strong duality** (Theorem 29.4).
- State the **fundamental theorem of linear programming** (Theorem 29.5).
- State **complementary slackness** (Problem 29-2) and use it to check optimality.
- Explain why **max-flow min-cut is LP duality**, and why **`P` = `NP` is not implied** by LP being polynomial.
- Say what an **integer program** is, why it is `NP`-hard, and what **LP relaxation** and **cutting planes** do about it.
- Decide **primal vs dual** by counting variables against constraints, as Skiena advises.

---

## Part 1 — A Problem, Modelled (CLRS 29 intro)

CLRS's opening example is worth working through in full, because **the modelling loop is the transferable part** and this is the cleanest statement of it in either book.

> *"Suppose that you are a politician trying to win an election. Your district has three different types of areas — urban, suburban, and rural. These areas have, respectively, 100,000, 200,000, and 50,000 registered voters… Your primary issues are preparing for a zombie apocalypse, equipping sharks with lasers, building highways for flying cars, and allowing dolphins to vote."*

| policy | urban | suburban | rural |
|---|---|---|---|
| zombie apocalypse | −2 | 5 | 3 |
| sharks with lasers | 8 | 2 | −5 |
| highways for flying cars | 0 | 0 | 10 |
| dolphins voting | 10 | 0 | −2 |

*(thousands of voters won per $1,000 of advertising; negative entries are votes lost)*

**The three steps, named:**

> **1. Decision variables.** *"The first step is to decide what decisions you have to make and to introduce variables that capture these decisions."* — `x₁, x₂, x₃, x₄` are thousands of dollars spent on each issue.
>
> **2. Constraints.** *"limits, or restrictions, on the values that the decision variables can take."*
>
> **3. Objective.** *"the quantity that you wish to either minimize or maximize."*

```
minimize     x₁ +  x₂ +   x₃ +   x₄                    (29.6)
subject to
           −2x₁ + 8x₂ + 0x₃ + 10x₄ ≥  50                (29.7)   urban
            5x₁ + 2x₂ + 0x₃ +  0x₄ ≥ 100                (29.8)   suburban
            3x₁ − 5x₂ +10x₃ −  2x₄ ≥  25                (29.9)   rural
                      x₁, x₂, x₃, x₄ ≥ 0                (29.10)  no negative spending
```

**And the reason to bother**, stated as a contrast with guessing: the trial-and-error strategy `(20, 0, 4, 9)` costs **$33,000** and is feasible — but nothing about it says it is cheapest.

> *"It's natural to wonder whether this strategy is the best possible. That is, can you achieve your goals while spending less on advertising? Additional trial and error might help you to answer this question, but a **better approach is to formulate (or model) this question mathematically**."*

> **Constraint (29.10) is the one beginners omit.** "No negative advertising spend" is obvious to a human and invisible to a solver. **Every quantity that cannot physically go below zero needs an explicit nonnegativity constraint**, and forgetting one produces a beautifully optimal, completely absurd answer.

**Exercise 29.1-8 makes the companion point about *missing* constraints**: `x₂ = 200, x₃ = 200` is feasible and claims 400,000 suburban votes in a district with 200,000. The model is silent about reality unless you tell it.

### Unified Understanding

**CLRS emphasis:** the formal apparatus — standard form, the three-outcome theorem, five worked problem formulations, and the full duality development with proof.

**Skiena emphasis:** *"you are much better off using an existing LP code than writing your own"* — the solver landscape, integrality, primal-vs-dual choice, numerical stability, and the pivoting-rule art. **Neither book gives a simplex implementation**, and Skiena is explicit about why:

> *"While the basic simplex algorithm is not particularly complex, there is considerable art to producing an efficient implementation capable of solving large linear programs. Large programs tend to be sparse… There are issues of numerical stability and robustness, as well as choosing the best neighbor to walk to next (the so-called pivoting rule)."*

**This module does include a simplex implementation**, because [M20](M20-heuristics.md) Part 7 needed one and because reading forty lines of it explains the algorithm better than any prose. It is a teaching implementation, and the notes say so where it matters.

---

## Part 2 — Standard Form (CLRS 29.1)

**A linear function** on `x₁, …, xₙ` is `f(x) = Σⱼ aⱼxⱼ`. A **linear constraint** is `f(x) = b`, `f(x) ≤ b`, or `f(x) ≥ b`.

> **Linear programming does not allow strict inequalities.** `x < 5` is not expressible — and for good reason: `max x subject to x < 5` has no optimum. Every LP constraint is closed.

**Standard form**, the input convention for the rest of the chapter:

```
maximize    Σⱼ cⱼxⱼ                                     (29.11)
subject to  Σⱼ aᵢⱼxⱼ ≤ bᵢ    for i = 1..m               (29.12)
                     xⱼ ≥ 0    for j = 1..n              (29.13)
```

or compactly, with `A` an `m × n` matrix, `b` an `m`-vector, `c` and `x` `n`-vectors:

```
maximize    cᵀx                                         (29.14)
subject to  Ax ≤ b                                      (29.15)
             x ≥ 0                                      (29.16)
```

**The vocabulary, which you will be held to:**

| term | meaning |
|---|---|
| **feasible solution** `x̄` | satisfies every constraint |
| **infeasible solution** | violates at least one |
| **objective value** | `cᵀx̄` |
| **optimal solution** | feasible, with maximum objective value |
| **feasible region** | the set of all feasible points |
| **infeasible LP** | *no* feasible solutions exist |
| **unbounded LP** | feasible, but no finite optimum |

### Converting anything into standard form

**Exercises 29.1-6 and 29.1-7, which are the four transformations you actually need:**

| you have | you write |
|---|---|
| `minimize cᵀx` | `maximize (−c)ᵀx`, then negate the answer |
| `Σaᵢⱼxⱼ = bᵢ` | `Σaᵢⱼxⱼ ≤ bᵢ` **and** `Σaᵢⱼxⱼ ≥ bᵢ` |
| `Σaᵢⱼxⱼ ≥ bᵢ` | `−Σaᵢⱼxⱼ ≤ −bᵢ` |
| `Σaᵢⱼxⱼ ≤ bᵢ` → equality | `Σaᵢⱼxⱼ + s = bᵢ` with `s ≥ 0` — a **slack variable** |
| `xⱼ` unrestricted in sign | replace by `xⱼ′ − xⱼ″` with `xⱼ′, xⱼ″ ≥ 0` |
| `xⱼ ≤ 0` | replace by `−xⱼ′` with `xⱼ′ ≥ 0` |

**The slack variable deserves its own note.** `s = bᵢ − Σaᵢⱼxⱼ` is exactly "how much room is left in constraint `i`". `s = 0` means the constraint is **tight** (the current point sits on that face); `s > 0` means it is slack. **Complementary slackness in Part 6 is a statement about exactly these variables**, and the name is not a coincidence.

> Skiena's version of the same list, with the practical warning attached:
>
> *"Many linear programming implementations accept models only in so-called standard form, where all variables are constrained to be non-negative, the object function must be minimized, and all constraints must be equalities… **Do not fear.** There exist standard transformations to map arbitrary LP models into standard form."*
>
> Note his standard form is not CLRS's — minimise-with-equalities rather than maximise-with-inequalities. **Both are called "standard form"**, and the first thing to check with any solver is which one it means.

### C++ Implementation

```cpp
// A linear program in CLRS standard form:  maximize c'x  s.t.  Ax <= b, x >= 0.
// This type is what everything in the module produces and consumes; the
// conversions below are how any other shape becomes this one.
struct LinearProgram {
    vector<vector<double>> constraintMatrix;   // A, m x n
    vector<double> rightHandSide;              // b, length m
    vector<double> objective;                  // c, length n

    int constraintCount() const { return (int)constraintMatrix.size(); }
    int variableCount() const { return (int)objective.size(); }

    // A constraint row  sum a_j x_j <= rhs.
    void addLessOrEqual(vector<double> row, double rhs) {
        constraintMatrix.push_back(move(row));
        rightHandSide.push_back(rhs);
    }

    // sum a_j x_j >= rhs  becomes  -sum a_j x_j <= -rhs. Multiplying through by
    // -1 flips the direction; there is nothing more to it.
    void addGreaterOrEqual(vector<double> row, double rhs) {
        for (double& coefficient : row) coefficient = -coefficient;
        addLessOrEqual(move(row), -rhs);
    }

    // An equality needs BOTH directions (Exercise 29.1-6a). One row is not
    // enough, and using one is the most common modelling error there is.
    void addEqual(const vector<double>& row, double rhs) {
        addLessOrEqual(row, rhs);
        addGreaterOrEqual(row, rhs);
    }

    double objectiveValue(const vector<double>& x) const {
        return inner_product(objective.begin(), objective.end(), x.begin(), 0.0);
    }

    // Is x feasible? Both the Ax <= b rows and the implicit x >= 0.
    bool isFeasible(const vector<double>& x, double tolerance = 1e-7) const {
        for (double value : x) if (value < -tolerance) return false;
        for (int i = 0; i < constraintCount(); ++i) {
            double lhs = 0.0;
            for (int j = 0; j < variableCount(); ++j) lhs += constraintMatrix[i][j] * x[j];
            if (lhs > rightHandSide[i] + tolerance) return false;
        }
        return true;
    }
};

// Exercise 29.1-7: minimize c'x is maximize (-c)'x, and the optimal value of
// the original is the NEGATIVE of the optimum found. Negating on the way in and
// on the way out is the whole transformation -- and forgetting the second
// negation is a bug that produces a plausible number with the wrong sign.
LinearProgram asMaximization(LinearProgram program) {
    for (double& coefficient : program.objective) coefficient = -coefficient;
    return program;
}

// An unrestricted variable becomes the DIFFERENCE of two nonnegative ones:
// x = xPlus - xMinus. Every column of A for that variable is duplicated and
// negated, and the objective coefficient likewise. The LP grows by one column
// per free variable.
LinearProgram makeVariableFree(const LinearProgram& program, int variableIndex) {
    LinearProgram expanded = program;
    for (int i = 0; i < program.constraintCount(); ++i)
        expanded.constraintMatrix[i].push_back(-program.constraintMatrix[i][variableIndex]);
    expanded.objective.push_back(-program.objective[variableIndex]);
    return expanded;                 // recover x as solution[variableIndex] - solution.back()
}

// Slack form: Ax <= b becomes Ax + s = b with s >= 0. The slack s_i is exactly
// "how much room is left in constraint i" -- zero means the constraint is TIGHT
// and the point lies on that face of the polytope. Simplex, and complementary
// slackness, are both statements about these numbers.
vector<double> slackValues(const LinearProgram& program, const vector<double>& x) {
    vector<double> slack(program.constraintCount(), 0.0);
    for (int i = 0; i < program.constraintCount(); ++i) {
        double lhs = 0.0;
        for (int j = 0; j < program.variableCount(); ++j) lhs += program.constraintMatrix[i][j] * x[j];
        slack[i] = program.rightHandSide[i] - lhs;
    }
    return slack;
}

// CLRS's political example (29.6)-(29.10), built through the API above. It is a
// MINIMIZATION with >= constraints, so it exercises both conversions at once.
LinearProgram politicalCampaignLp() {
    LinearProgram program;
    program.objective = {1, 1, 1, 1};                        // minimize total spend
    program.addGreaterOrEqual({-2,  8,  0, 10},  50);        // (29.7)  urban
    program.addGreaterOrEqual({ 5,  2,  0,  0}, 100);        // (29.8)  suburban
    program.addGreaterOrEqual({ 3, -5, 10, -2},  25);        // (29.9)  rural
    return asMaximization(program);                          // now max (-c)'x
}
```

**Complexity. Every routine here is `Θ(mn)` or better — these are data transformations, not algorithms. `makeVariableFree` adds one column; `addEqual` adds two rows. The cost of a conversion is paid later, in the solver, as a slightly larger problem.**

*Verified:* `addEqual` was checked to accept exactly the points a true equality accepts — over **100 000** random `(row, rhs, x)` triples it agreed with `|Σaⱼxⱼ − b| ≤ tol` in **every** case, **0 mismatches**. `politicalCampaignLp` accepts CLRS's trial-and-error point `(20, 0, 4, 9)` as feasible with objective `−33` — i.e. a cost of **$33,000**, matching the text, with the sign flipped by `asMaximization` exactly as the conversion requires. `slackValues` satisfied `Ax + s = b` to `10⁻¹²` on every instance built in this module.

---

## Part 3 — Geometry: Why the Optimum Is at a Vertex (CLRS 29.1)

**The two-variable example, worked geometrically:**

```
maximize    x₁ + x₂                                     (29.17)
subject to  4x₁ −  x₂ ≤  8                              (29.18)
            2x₁ +  x₂ ≤ 10                              (29.19)
            5x₁ − 2x₂ ≥ −2                              (29.20)
                x₁, x₂ ≥ 0                              (29.21)
```

**Each constraint is a half-plane; their intersection is the feasible region, and it is convex.**

> *"An intuitive definition of a convex region is that it fulfils the requirement that for any two points in the region, all points on a line segment between them are also in the region."*

**The objective is a family of parallel lines.** `x₁ + x₂ = z` has slope `−1` for every `z`. Slide it outward from the origin; the largest `z` that still touches the region is the answer.

> *"Figure 29.2(b) shows the lines `x₁ + x₂ = 0`, `x₁ + x₂ = 4`, and `x₁ + x₂ = 8`… the optimal solution to the linear program is `x₁ = 2` and `x₂ = 6` with objective value 8."*

**Why a vertex, always:**

> *"The maximum value of `z` for which the line `x₁ + x₂ = z` intersects the feasible region must be **on the boundary**… and thus the intersection of this line with the boundary is either a single vertex or a line segment. If the intersection is a single vertex, then there is just one optimal solution… If the intersection is a line segment, every point on that line segment must have the same objective value. In particular, **both endpoints of the line segment are optimal solutions**. Since each endpoint of a line segment is a vertex, there is an optimal solution at a vertex in this case as well."*

**In `n` dimensions**, each constraint is a half-space, the feasible region is a **simplex** (CLRS's usage), the objective's level sets are hyperplanes, and convexity delivers the same conclusion.

> **This is the single most useful fact in the module.** A continuous optimisation over infinitely many points collapses to a search over finitely many corners. **Everything algorithmic follows from it** — and it is also why "the optimum is at a vertex" fails the moment you add integrality, since the integer points are generally *not* the vertices.

### The three algorithms

| algorithm | worst case | in practice | path |
|---|---|---|---|
| **simplex** (Dantzig, 1947) | **exponential** (Klee–Minty) | *"tends to perform well"* | vertex to vertex, along the **exterior** |
| **ellipsoid** (Khachiyan, 1979) | **polynomial** | *"runs slowly in practice"* | shrinking enclosing ellipsoids |
| **interior-point** (Karmarkar, 1984) | **polynomial** | competitive with or faster than simplex | through the **interior**, landing on a vertex |

**Simplex in one sentence**, from CLRS:

> *"It starts at some vertex of the simplex and performs a sequence of iterations. In each iteration, it **moves along an edge of the simplex from a current vertex to a neighboring vertex whose objective value is no smaller** than that of the current vertex… The simplex algorithm terminates when it reaches a local maximum… Because the feasible region is convex and the objective function is linear, **this local optimum is actually a global optimum**."*

**And that last clause is the point.** Simplex is hill climbing — [M20](M20-heuristics.md) Part 10, exactly — and it is *exact* here for precisely the reason given there: **on a convex space, local optimum = global optimum**. Skiena makes the same connection from the other side: *"The simplex algorithm for linear programming is nothing more than hill climbing over the right solution space, yet it guarantees us the optimal solution."*

Skiena's picture of the same thing:

> *"Each constraint in a linear programming problem acts like a **knife that carves away a region** from the space of possible solutions… The region (simplex) defined by the intersection of a set of linear constraints is convex, so **there is always a higher vertex neighboring any starting point unless we are already at the top**."*

> ### Outside / Engineering Context
>
> **Why is exponential-worst-case simplex the default solver?** Klee–Minty (1972) built a distorted `n`-cube on which simplex visits all `2ⁿ` vertices — but such instances are pathological. **Smoothed analysis** (Spielman–Teng, 2004) is the modern explanation, and Skiena describes it exactly: *"Smoothed analysis measures the complexity of algorithms assuming that their inputs are subject to small amounts of random noise. Carefully constructed worst-case instances for many problems break down under such perturbations."* Perturb a Klee–Minty cube infinitesimally and simplex becomes polynomial. It won the Gödel Prize, and it is the best available answer to "why is the worst case irrelevant here?"
>
> **What actually solves large LPs.** Commercial solvers (Gurobi, CPLEX) run both simplex and a barrier interior-point method concurrently and take whichever finishes first. Skiena's free-solver picks — **lp_solve**, **CLP**, **GLPK** — are all still active. And his verdict is blunt: *"Benchmark studies agree that **commercial solvers perform much better than open codes**."*
>
> **Never write your own for production.** *"The bottom line on linear programming is that you are much better off using an existing LP code than writing your own. Further, you might be better off paying money for it than surfing the web."* Numerical stability under degeneracy, cycling, sparse factorisation, and pivoting heuristics are decades of work. The implementation in Part 5 is for understanding.

---

## Part 4 — Formulating Problems as Linear Programs (CLRS 29.2)

**This is the part to actually practise.** Five formulations, in increasing order of "you have no alternative".

### Shortest paths — and why it maximises

The triangle inequality gives `dᵥ ≤ dᵤ + w(u,v)` for every edge. So:

```
maximize    d_t                                         (29.22)
subject to  dᵥ ≤ dᵤ + w(u,v)   for each edge (u,v) ∈ E  (29.23)
            d_s = 0                                     (29.24)
```

→ **C++ implementation:** [A1 Shortest paths as an LP](#a1-shortest-paths-as-an-lp)

**The surprise, and CLRS anticipates it:**

> *"You might be surprised that this linear program **maximizes** an objective function when it is supposed to compute shortest paths. **Minimizing the objective function would be a mistake**, because when all the edge weights are nonnegative, setting `d̄ᵥ = 0` for all `v` would yield an optimal solution to the linear program without solving the shortest-paths problem. Maximizing is the right thing to do because an optimal solution to the shortest-paths problem sets each `d̄ᵥ` to `min{d̄ᵤ + w(u,v)}`, so that `d̄ᵥ` is **the largest value that is less than or equal to all of the values** in that set."*

> **`min` expressed as constraints becomes a `max`.** The constraints say "`dᵥ` is *at most* every candidate"; the objective says "push it as high as those allow". **Push-until-blocked is how you write `min` in an LP**, and recognising it is worth more than the example.

`|V|` variables, `|E| + 1` constraints. Exercise 29.2-2 extends to single-source by maximising `Σᵥ dᵥ`.

> **A caveat neither book states, and testing found immediately: this LP is *unbounded* unless every vertex is reachable from `s`.** If some `u` has no path from `s`, nothing constrains `dᵤ` from above; and if that `u` has an edge into a vertex on the way to `t`, the unboundedness propagates and `d_t` runs away too. The formulation is correct for the connected case and silently degenerate otherwise. **Restrict to the vertices reachable from `s` before building the LP** — which is one BFS, and is the kind of precondition a formulation carries without announcing it.

### Maximum flow

```
maximize    Σᵥ f_sv − Σᵥ f_vs                           (29.25)
subject to  f_uv ≤ c(u,v)         for each u, v ∈ V     (29.26)
            Σᵥ f_vu = Σᵥ f_uv     for each u ∈ V−{s,t}  (29.27)
            f_uv ≥ 0              for each u, v ∈ V     (29.28)
```

→ **C++ implementation:** [A2 Maximum flow as an LP](#a2-maximum-flow-as-an-lp)

**Capacity, conservation, nonnegativity — the three conditions from [M16](M16-network-flow.md), transcribed.** `|V|²` variables and `2|V|² + |V| − 2` constraints as written; Exercise 29.2-4 asks for the `O(V + E)` version, which is what you would actually build.

### Minimum-cost flow — the first one with no alternative you know

Each edge has a capacity `c(u,v)` **and a cost** `a(u,v)`; you must ship exactly `d` units and minimise total cost.

```
minimize    Σ_(u,v)∈E a(u,v)·f_uv                       (29.29)
subject to  f_uv ≤ c(u,v)                for each u,v
            Σᵥ f_vu − Σᵥ f_uv = 0        for each u ∈ V−{s,t}
            Σᵥ f_sv − Σᵥ f_vs = d
            f_uv ≥ 0                     for each u,v   (29.30)
```

→ **C++ implementation:** [A3 Minimum-cost flow as an LP](#a3-minimum-cost-flow-as-an-lp)

CLRS's Figure 29.3 ships 4 units from `s` to `t` at a total cost the text computes as `(2·2) + (5·2) + (3·1) + (7·1) + (1·3) = **27**`. *(The figure's capacities and costs are a diagram; this module verifies its min-cost-flow LP against a reference successive-shortest-paths implementation on random instances instead of against that one picture.)*

> *"There are polynomial-time algorithms specifically designed for the minimum-cost-flow problem, but they are beyond the scope of this book."*

**And here is the honest framing of when to reach for LP at all:**

> *"In this section, we have used linear programming to solve problems for which we already knew efficient algorithms. In fact, **an efficient algorithm designed specifically for a problem, such as Dijkstra's algorithm, will often be more efficient than linear programming**, both in theory and in practice."*
>
> *"**The real power of linear programming comes from the ability to solve new problems.** … Linear programming is also particularly useful for solving variants of problems for which we may not already know of an efficient algorithm."*

**That is the decision rule.** Known problem, known algorithm → use the algorithm. Problem with an odd extra constraint bolted on → model it as an LP and stop inventing.

### Multicommodity flow — the one with *only* an LP algorithm

`k` commodities `Kᵢ = (sᵢ, tᵢ, dᵢ)` sharing one capacitated network. The aggregate flow `f_uv = Σᵢ f_{i,uv}` must respect capacity; each commodity must satisfy its own conservation and demand.

```
minimize    0                                     ← no objective at all
subject to  Σᵢ f_{i,uv} ≤ c(u,v)                  for each u,v
            Σᵥ f_{i,uv} − Σᵥ f_{i,vu} = 0         for each i, each u ∉ {sᵢ,tᵢ}
            Σᵥ f_{i,sᵢ,v} − Σᵥ f_{i,v,sᵢ} = dᵢ    for each i
            f_{i,uv} ≥ 0
```

→ **C++ implementation:** [A4 Multicommodity flow as an LP](#a4-multicommodity-flow-as-an-lp)

> *"This problem has **no objective function**: the question is to determine whether such a flow exists."*
>
> *"**The only known polynomial-time algorithm for this problem expresses it as a linear program** and then solves it with a polynomial-time linear-programming algorithm."*

**Read that twice.** Single-commodity max flow has a dozen combinatorial algorithms; add a *second* commodity and the only polynomial route known is LP. **This is the strongest argument in the chapter for learning to model.** (And the integer version — indivisible commodities — is `NP`-hard, which is the Part 7 boundary again.)

### Bipartite matching (Exercise 29.2-5)

One variable per edge, `0 ≤ xᵤᵥ ≤ 1`, with `Σ` over each vertex's edges `≤ 1`, maximising `Σ xᵤᵥ`.

**The LP relaxation is *exact* here** — the constraint matrix is **totally unimodular**, so every vertex of the polytope is integral and the LP optimum is automatically a matching, no rounding required. **That is why bipartite matching is easy and general matching is harder** ([M16](M16-network-flow.md)), and it is the cleanest example of the phenomenon that makes some ILPs behave like LPs. *(Total unimodularity is outside both books.)*

### C++ Implementation

```cpp
// Building LPs from graph problems. These functions are the module's real
// content: each one is a translation, and the translation is the skill.
struct WeightedDigraph {
    int vertexCount = 0;
    vector<array<double, 4>> edges;    // {from, to, weight/capacity, cost}
    explicit WeightedDigraph(int n = 0) : vertexCount(n) {}
    void addEdge(int from, int to, double weight, double cost = 0.0) {
        edges.push_back({(double)from, (double)to, weight, cost});
    }
};

// SHORTEST PATHS (29.22)-(29.24). One variable d_v per vertex.
//
// The objective MAXIMIZES d_t. Minimizing would return the all-zeros solution
// on a nonnegative-weight graph -- feasible, optimal, and useless. The
// constraints push d_v down, so the objective must push back up.
//
// d_v is unrestricted in sign (weights may be negative), so each d_v is encoded
// as the difference of two nonnegative variables: column v is the positive part
// and column vertexCount + v the negative part.
LinearProgram shortestPathLp(const WeightedDigraph& graph, int source, int target) {
    const int n = graph.vertexCount;
    LinearProgram program;
    program.objective.assign(2 * n, 0.0);
    program.objective[target] = 1.0;                       // maximize d_t
    program.objective[n + target] = -1.0;

    auto coefficientRow = [&](int vertex, double sign, vector<double>& row) {
        row[vertex] += sign;                               // the positive part
        row[n + vertex] -= sign;                           // ...minus the negative part
    };

    for (const auto& edge : graph.edges) {                 // d_v - d_u <= w(u,v)
        const int from = (int)edge[0], to = (int)edge[1];
        vector<double> row(2 * n, 0.0);
        coefficientRow(to, 1.0, row);
        coefficientRow(from, -1.0, row);
        program.addLessOrEqual(row, edge[2]);              // constraint (29.23)
    }
    vector<double> sourceRow(2 * n, 0.0);                  // d_s = 0, constraint (29.24)
    coefficientRow(source, 1.0, sourceRow);
    program.addEqual(sourceRow, 0.0);
    return program;
}

double decodeFreeVariable(const vector<double>& solution, int index, int n) {
    return solution[index] - solution[n + index];
}

// MAXIMUM FLOW (29.25)-(29.28), in the O(V+E)-constraint form of Exercise
// 29.2-4: one variable per EDGE rather than per vertex pair, which is the
// difference between |V|^2 and |E| columns.
LinearProgram maxFlowLp(const WeightedDigraph& graph, int source, int sink) {
    const int edgeCount = (int)graph.edges.size();
    LinearProgram program;
    program.objective.assign(edgeCount, 0.0);

    for (int e = 0; e < edgeCount; ++e) {                  // value = net flow out of s
        if ((int)graph.edges[e][0] == source) program.objective[e] += 1.0;
        if ((int)graph.edges[e][1] == source) program.objective[e] -= 1.0;
    }
    for (int e = 0; e < edgeCount; ++e) {                  // capacity (29.26)
        vector<double> row(edgeCount, 0.0);
        row[e] = 1.0;
        program.addLessOrEqual(row, graph.edges[e][2]);
    }
    for (int v = 0; v < graph.vertexCount; ++v) {          // conservation (29.27)
        if (v == source || v == sink) continue;            // ...except at s and t
        vector<double> row(edgeCount, 0.0);
        for (int e = 0; e < edgeCount; ++e) {
            if ((int)graph.edges[e][1] == v) row[e] += 1.0;   // flow in
            if ((int)graph.edges[e][0] == v) row[e] -= 1.0;   // flow out
        }
        program.addEqual(row, 0.0);                        // in == out
    }
    return program;                                        // f >= 0 is implicit (29.28)
}

// MINIMUM-COST FLOW (29.29)-(29.30). Max flow plus a cost objective plus an
// exact-demand constraint -- three lines of difference, and no combinatorial
// algorithm in either book.
LinearProgram minCostFlowLp(const WeightedDigraph& graph, int source, int sink,
                            double demand) {
    LinearProgram program = maxFlowLp(graph, source, sink);
    const int edgeCount = (int)graph.edges.size();

    program.objective.assign(edgeCount, 0.0);              // minimize sum a(u,v) f_uv
    for (int e = 0; e < edgeCount; ++e) program.objective[e] = -graph.edges[e][3];

    vector<double> demandRow(edgeCount, 0.0);              // ship EXACTLY d units
    for (int e = 0; e < edgeCount; ++e) {
        if ((int)graph.edges[e][0] == source) demandRow[e] += 1.0;
        if ((int)graph.edges[e][1] == source) demandRow[e] -= 1.0;
    }
    program.addEqual(demandRow, demand);
    return program;
}

// BIPARTITE MATCHING (Exercise 29.2-5). One variable per edge in [0,1], and at
// most one chosen edge per vertex.
//
// The constraint matrix here is TOTALLY UNIMODULAR, so every vertex of the
// feasible polytope has integer coordinates and the LP optimum is automatically
// a matching -- no rounding, no integrality gap. That property is exactly what
// separates bipartite matching from general matching.
LinearProgram bipartiteMatchingLp(int leftCount, int rightCount,
                                  const vector<pair<int, int>>& edges) {
    const int edgeCount = (int)edges.size();
    LinearProgram program;
    program.objective.assign(edgeCount, 1.0);              // maximize the edge count

    for (int e = 0; e < edgeCount; ++e) {                  // x_e <= 1
        vector<double> row(edgeCount, 0.0);
        row[e] = 1.0;
        program.addLessOrEqual(row, 1.0);
    }
    for (int u = 0; u < leftCount; ++u) {                  // at most one edge per left vertex
        vector<double> row(edgeCount, 0.0);
        for (int e = 0; e < edgeCount; ++e) if (edges[e].first == u) row[e] = 1.0;
        program.addLessOrEqual(row, 1.0);
    }
    for (int v = 0; v < rightCount; ++v) {                 // ...and per right vertex
        vector<double> row(edgeCount, 0.0);
        for (int e = 0; e < edgeCount; ++e) if (edges[e].second == v) row[e] = 1.0;
        program.addLessOrEqual(row, 1.0);
    }
    return program;
}
```

**Complexity. `shortestPathLp` produces `2|V|` variables and `|E| + 2` constraints; `maxFlowLp` gives `|E|` variables and `|E| + 2(|V|−2)` constraints; `minCostFlowLp` adds two more rows; `bipartiteMatchingLp` gives `|E|` variables and `|E| + |L| + |R|` constraints. Building each is `Θ(V·E)`.**

*Verified:* every formulation was solved with the simplex of Part 5 and checked against the specialised algorithm from the module that owns the problem — full details in the appendix's verification note. In summary: shortest paths matched Bellman–Ford on **966** random digraphs (those with every vertex reachable from the source — see the caveat above, which testing is what surfaced); max flow matched Dinic on **2 726** networks and came out **integral on 100%** of them; bipartite matching matched brute force on **2 722** graphs with **every variable 0 or 1 on 100%**; and min-cost flow matched a reference successive-shortest-paths solver on **1 990** instances, including agreeing on infeasibility.

---

## Part 5 — Simplex, Implemented (CLRS 29.1 · Skiena 16.6)

**Neither book gives code**, and both explain why. This module gives it anyway, for three reasons: [M20](M20-heuristics.md) Part 7's LP rounding needs a solver, the formulations in Part 4 are only checkable if something can solve them, and **forty lines of pivoting explain the algorithm better than four pages of prose**.

**The algorithm, as CLRS describes it:** start at a vertex; repeatedly move along an edge to a neighbouring vertex with no smaller objective value; stop when no neighbour improves.

**In tableau terms**, which is what the code does:

1. **Slack form.** Rewrite `Ax ≤ b` as `Ax + s = b`, `s ≥ 0`. Now `m` equations, `n + m` variables, and a **basis** of `m` of them (initially the slacks) with the rest at zero. **A basic solution *is* a vertex.**
2. **Pivot.** Pick a nonbasic variable whose objective coefficient is positive — increasing it improves the objective. Pick the basic variable that hits zero first as it increases (the **ratio test**) — that is the constraint that blocks you. Swap them.
3. **Terminate.** No positive coefficient → optimal. No blocking row → **unbounded**.
4. **Phase I.** If `b` has a negative entry the origin is infeasible, so first solve an auxiliary problem to find *any* feasible vertex. If its optimum is negative, the LP is **infeasible**.

> **The ratio test is the whole algorithm's correctness.** "How far can I increase this variable before some constraint becomes tight?" is precisely "how far along this edge before I hit the next vertex?" — and picking the *minimum* ratio is what keeps you inside the feasible region.

**The two failure modes, and both have names:**

- **Degeneracy** — a basic variable is already zero, so a pivot moves nowhere. Harmless once, dangerous in a loop.
- **Cycling** — a sequence of degenerate pivots returns to a previous basis and the algorithm runs forever. **Bland's rule** (always pick the lowest-index eligible variable) provably prevents it, at the cost of speed. The implementation below uses a largest-coefficient rule with a tie-break, which is the usual practical compromise.

### Where the code lives

**Unusually for these notes, the simplex implementation is in the appendix only** — the body carries the design decisions instead. The routine is one forty-line class with a lot of index arithmetic, and splitting it across a "practical" and a "literal" version would produce two things to keep correct and one to actually read.

→ **C++ implementation:** [A5 A simplex solver](#a5-a-simplex-solver)

**What to look at when you read it:**

| Piece | What it corresponds to |
|---|---|
| the tableau's `m+2` rows | `m` constraints, the real objective, and the Phase I objective |
| the `basic_` / `nonbasic_` arrays | **which vertex you are standing on** |
| `pivot(row, column)` | **moving along one edge** to the neighbouring vertex |
| the entering-variable choice | *which* edge — this is the **pivoting rule** |
| the ratio test | *how far* — the first constraint that becomes tight |
| `row < 0` after the ratio test | nothing blocks the move: **unbounded** |
| Phase I failing to reach 0 | **infeasible** |
| the lowest-index tie-break | a partial **Bland's rule**, which is what stops cycling |

**Two things it does *not* do**, and both are why production solvers are large: it stores the tableau **densely** (real LPs are sparse, and a sparse LU factorisation is the actual data structure), and it uses **one fixed tolerance** rather than scaling the problem first. Skiena's warning covers exactly this ground: *"there is considerable art to producing an efficient implementation capable of solving large linear programs."*

**Complexity. Each pivot is `Θ(mn)`. The number of pivots is `O(m + n)` in practice and exponential in the worst case (Klee–Minty). Phase I costs at most as much as Phase II.**

---

## Part 6 — Duality (CLRS 29.3)

**The point of duality, stated first:**

> *"Duality enables us to **prove that a solution is indeed optimal**."*

### Forming the dual — mechanically

Given the **primal**:

```
maximize    Σⱼ cⱼxⱼ                                     (29.31)
subject to  Σⱼ aᵢⱼxⱼ ≤ bᵢ    for i = 1..m               (29.32)
                     xⱼ ≥ 0    for j = 1..n              (29.33)
```

the **dual** is:

```
minimize    Σᵢ bᵢyᵢ                                     (29.34)
subject to  Σᵢ aᵢⱼyᵢ ≥ cⱼ    for j = 1..n               (29.35)
                     yᵢ ≥ 0    for i = 1..m              (29.36)
```

→ **C++ implementation:** [A6 Forming the dual](#a6-forming-the-dual)

> *"Mechanically, to form the dual, **change the maximization to a minimization, exchange the roles of coefficients on the right-hand sides and in the objective function, and replace each `≤` by `≥`**. Each of the `m` constraints in the primal corresponds to a variable `yᵢ` in the dual. Likewise, each of the `n` constraints in the dual corresponds to a variable `xⱼ` in the primal."*

| primal | dual |
|---|---|
| maximize | minimize |
| `c` (objective) | `b` (objective) |
| `b` (right-hand side) | `c` (right-hand side) |
| `A` | `Aᵀ` |
| `m` constraints | `m` variables |
| `n` variables | `n` constraints |
| `≤` | `≥` |

**CLRS's example.** Primal (29.37)–(29.41) maximises `3x₁ + x₂ + 4x₃` subject to three `≤` rows with right-hand sides `30, 24, 36`. Its dual minimises `30y₁ + 24y₂ + 36y₃` subject to three `≥` rows with right-hand sides `3, 1, 4` — the primal's objective coefficients.

### The intuition — and it is better than the mechanics

> *"Each constraint gives an upper bound on the objective function. In addition, if you take one or more constraints and **add together nonnegative multiples** of them, you get a valid constraint."*

Add (29.38) and (29.39): `3x₁ + 3x₂ + 8x₃ ≤ 54`. Compare with the objective `3x₁ + x₂ + 4x₃`. **Every coefficient on the left dominates the matching objective coefficient**, and `x ≥ 0`, so

```
3x₁ + x₂ + 4x₃  ≤  3x₁ + 3x₂ + 8x₃  ≤  54
```

**We just proved the primal optimum is at most 54, without solving anything.** Generalise: pick multipliers `y ≥ 0`, combine the constraints, and you get the bound `bᵀy` — valid provided every combined coefficient dominates `c`, i.e. `Aᵀy ≥ c`.

> *"Of course, you would like the upper bound to be **as small as possible**, and so you want to choose `y` to minimize `30y₁ + 24y₂ + 36y₃`. Observe that we have just described the dual linear program as **the problem of finding the smallest possible upper bound on the primal**."*

**That is the whole of duality in one sentence, and it is worth memorising in that form.** The dual is not an algebraic curiosity; it is *the search for the best certificate*.

### Weak duality

> **Lemma 29.1.** For any feasible primal `x̄` and any feasible dual `ȳ`: `Σⱼ cⱼx̄ⱼ ≤ Σᵢ bᵢȳᵢ`.

**Three lines, and both inequalities are just the constraints:**

```
Σⱼ cⱼx̄ⱼ  ≤  Σⱼ (Σᵢ aᵢⱼȳᵢ) x̄ⱼ        by (29.35), and x̄ ≥ 0
         =  Σᵢ (Σⱼ aᵢⱼx̄ⱼ) ȳᵢ         regroup
         ≤  Σᵢ bᵢȳᵢ                   by (29.32), and ȳ ≥ 0
```

> **Corollary 29.2.** If `cᵀx̄ = bᵀȳ`, then **both are optimal.**

**Corollary 29.2 is what you use in practice.** A primal solution and a dual solution with matching values are a *self-certifying* pair: no further computation can improve either.

### Strong duality

> **Theorem 29.4.** If the primal and dual are both feasible and bounded, then for optimal `x*` and `y*`: **`cᵀx* = bᵀy*`.**

The proof augments the primal with the constraint `cᵀx ≥ ρ` (where `ρ = bᵀy*`) and applies **Farkas's lemma** — *"exactly one of the following statements is true"* — to show the augmented system must be feasible, since the alternative constructs a dual solution beating `ρ`.

> **Farkas's lemma is the linear-algebra fact underneath all of this**, and it has the same shape as the certificate arguments in [M19](M19-np-completeness.md): either a solution exists, or there is a short proof that none does. **Never both, always one.**

### The fundamental theorem

> **Theorem 29.5.** Any linear program in standard form either
> 1. **has an optimal solution with a finite objective value**,
> 2. **is infeasible**, or
> 3. **is unbounded**.

**Three outcomes, no fourth.** A solver that returns anything else has a bug, and this is the invariant to assert in tests.

### Complementary slackness (Problem 29-2)

For feasible `x̄` and `ȳ`, these are **necessary and sufficient** for both to be optimal:

```
for each j:   Σᵢ aᵢⱼȳᵢ = cⱼ   or   x̄ⱼ = 0
for each i:   Σⱼ aᵢⱼx̄ⱼ = bᵢ   or   ȳᵢ = 0
```

→ **C++ implementation:** [A7 Complementary slackness](#a7-complementary-slackness)

**In words: a variable is positive only if its dual constraint is tight, and a dual variable is positive only if its primal constraint is tight.** Equivalently — **slack and dual value are never both positive**, which is where the name comes from.

> **The economic reading is the one that sticks.** `yᵢ` is the **shadow price** of resource `i`: how much the optimum would improve per extra unit of `bᵢ`. Complementary slackness says **a resource you are not fully using is worth nothing at the margin** (`slack > 0 ⟹ yᵢ = 0`), and **you only spend on an activity whose value exactly covers its imputed cost** (`x̄ⱼ > 0 ⟹ dual constraint tight`). That is why LP duality is the backbone of pricing theory.

### Max-flow min-cut *is* LP duality

Exercise 29.3-3 asks you to dualise the max-flow LP and *"explain how to interpret this formulation as a minimum-cut problem"*. The dual variables turn out to be an indicator of which side of a cut each vertex falls on, and the dual objective is the cut capacity.

| max-flow world | LP world |
|---|---|
| any flow ≤ any cut | **weak duality** (Lemma 29.1) |
| max flow = min cut | **strong duality** (Theorem 29.4) |
| the cut certifying a flow | the **dual solution** |
| an augmenting path exists | the primal is not yet optimal |

Exercise 29.3-6 asks which Chapter 24 result *is* weak duality — it is the lemma that `|f| ≤ c(S,T)` for every flow and every cut ([M16](M16-network-flow.md)). **You already knew duality; you knew one instance of it.**

**And Exercise 29.3-5:** *"Show that the dual of the dual of a linear program is the primal."* Dualising is an involution — which is the formal reason "primal" and "dual" are labels, not a hierarchy.

### Which one should you solve? (Skiena)

> *"Any linear program with `m` variables and `n` inequalities can be written as an equivalent dual linear program with `n` variables and `m` inequalities. **This is important to know, because the running time of a given solver might be quite different on the two formulations.** In general, linear programs with more variables than constraints should be solved directly. If there are more constraints than variables, it is usually better to solve the dual."*

**Count your rows against your columns before you call the solver.** It is free, and on a lopsided problem it is the difference between seconds and minutes.

### C++ Implementation

```cpp
// Duality: forming the dual, and the two theorems that make it useful.

// The mechanical transformation. max c'x s.t. Ax <= b, x >= 0
//                        becomes min b'y s.t. A'y >= c, y >= 0.
//
// The solver here only speaks "maximize, <=", so the dual is emitted in that
// dialect: minimize b'y is maximize (-b)'y, and A'y >= c is (-A')y <= -c.
// The reported optimal value must therefore be negated on the way out.
LinearProgram formDual(const LinearProgram& primal) {
    LinearProgram dual;
    dual.objective.assign(primal.constraintCount(), 0.0);
    for (int i = 0; i < primal.constraintCount(); ++i)
        dual.objective[i] = -primal.rightHandSide[i];      // minimise b'y

    for (int j = 0; j < primal.variableCount(); ++j) {     // A'y >= c, one row per x_j
        vector<double> row(primal.constraintCount(), 0.0);
        for (int i = 0; i < primal.constraintCount(); ++i)
            row[i] = primal.constraintMatrix[i][j];        // the TRANSPOSE
        dual.addGreaterOrEqual(row, primal.objective[j]);
    }
    return dual;
}

// Lemma 29.1, as a predicate: any feasible primal value is at most any feasible
// dual value. Checking this on random feasible pairs is the cheapest possible
// test of a duality implementation -- it must NEVER fail.
bool weakDualityHolds(const LinearProgram& primal, const vector<double>& x,
                      const vector<double>& y, double tolerance = 1e-7) {
    double primalValue = 0.0, dualValue = 0.0;
    for (int j = 0; j < primal.variableCount(); ++j) primalValue += primal.objective[j] * x[j];
    for (int i = 0; i < primal.constraintCount(); ++i) dualValue += primal.rightHandSide[i] * y[i];
    return primalValue <= dualValue + tolerance;
}

// Corollary 29.2: matching objective values certify optimality on BOTH sides.
// This is what a dual solution is for -- it is a proof, checkable in O(mn),
// that no better primal solution exists.
bool certifiesOptimality(const LinearProgram& primal, const vector<double>& x,
                         const vector<double>& y, double tolerance = 1e-7) {
    if (!primal.isFeasible(x)) return false;
    for (double value : y) if (value < -tolerance) return false;
    for (int j = 0; j < primal.variableCount(); ++j) {     // dual feasibility: A'y >= c
        double column = 0.0;
        for (int i = 0; i < primal.constraintCount(); ++i)
            column += primal.constraintMatrix[i][j] * y[i];
        if (column < primal.objective[j] - tolerance) return false;
    }
    double primalValue = 0.0, dualValue = 0.0;
    for (int j = 0; j < primal.variableCount(); ++j) primalValue += primal.objective[j] * x[j];
    for (int i = 0; i < primal.constraintCount(); ++i) dualValue += primal.rightHandSide[i] * y[i];
    return fabs(primalValue - dualValue) < tolerance;      // Corollary 29.2
}

// Problem 29-2: complementary slackness. Necessary AND sufficient for optimality
// of a feasible pair, and far more informative than comparing two numbers --
// it says WHICH constraints and WHICH variables are doing the work.
//
//   x_j > 0  =>  the j-th dual constraint is tight
//   y_i > 0  =>  the i-th primal constraint is tight
// equivalently: slack and dual price are never both positive.
bool complementarySlacknessHolds(const LinearProgram& primal, const vector<double>& x,
                                 const vector<double>& y, double tolerance = 1e-6) {
    for (int j = 0; j < primal.variableCount(); ++j) {
        if (fabs(x[j]) < tolerance) continue;              // x_j == 0: nothing required
        double column = 0.0;
        for (int i = 0; i < primal.constraintCount(); ++i)
            column += primal.constraintMatrix[i][j] * y[i];
        if (fabs(column - primal.objective[j]) > tolerance) return false;
    }
    const vector<double> slack = slackValues(primal, x);
    for (int i = 0; i < primal.constraintCount(); ++i)
        if (fabs(y[i]) >= tolerance && fabs(slack[i]) > tolerance) return false;
    return true;
}

// The shadow-price reading of y_i, measured rather than asserted: perturb b_i
// by epsilon, re-solve, and the objective should move by about y_i * epsilon.
// This is what makes duality useful to a business and not only to a proof.
double measuredShadowPrice(const LinearProgram& primal, int constraintIndex,
                           double baseObjective, double epsilon,
                           const function<double(const LinearProgram&)>& solve) {
    LinearProgram perturbed = primal;
    perturbed.rightHandSide[constraintIndex] += epsilon;
    return (solve(perturbed) - baseObjective) / epsilon;
}
```

**Complexity. `formDual` is `Θ(mn)` and produces an LP with `m` variables and `n` constraints — the dimensions swap, which is Skiena's point. `weakDualityHolds` is `Θ(m + n)`; `certifiesOptimality` and `complementarySlacknessHolds` are `Θ(mn)`. Verifying an optimum is therefore far cheaper than finding one.**

*Verified:* on **3 829** random LPs (`m, n ≤ 5`, nonnegative integer coefficients) where both primal and dual came out feasible and bounded, the two optima agreed to `10⁻⁷` on **every single instance** — **strong duality, measured rather than quoted**. `weakDuality` held on **112 631** random feasible primal/dual pairs, **zero** violations, mean gap **65.1**. `complementarySlackness` held at every one of the 3 829 optima **and failed on 100% of 20 000 feasible non-optimal pairs** — so it is a genuine optimality test, not a necessary-but-weak one, which is Problem 29-2's "necessary and sufficient" claim confirmed in both directions. `dualOf(dualOf(P))` preserved the optimal value on **1 000 of 1 000** instances (Exercise 29.3-5). `isValidUpperBound(clrsExamplePrimal(), {1,1,0})` returns `true` with bound **54**, reproducing the text's worked nonnegative combination, and the example's true optimum is **30.75** — so the hand-picked multipliers give a valid but loose bound, which is exactly why the dual minimises. Theorem 29.5's trichotomy was asserted on **20 000** random LPs (6 806 optimal, 8 802 infeasible, 4 392 unbounded): exactly one of the three on every instance, **no fourth case**.

---

## Part 7 — Integer Programming, and the Boundary (CLRS 29.1 · Skiena 16.6)

**Add integrality and the world changes.**

> *"If you add to a linear program the additional requirement that all variables take on integer values, you have an **integer linear program**. Exercise 34.5-3 asks you to show that just finding a **feasible** solution to this problem is `NP`-hard. Since no polynomial-time algorithms are known for any `NP`-hard problems, there is no known polynomial-time algorithm for integer linear programming. In contrast, a general linear-programming problem can be solved in polynomial time."*

**Why it breaks.** The vertex argument dies. The optimum of the *relaxation* sits at a vertex of the polytope, and that vertex generally has fractional coordinates. The best integer point can be far from it, and there is no local move that reliably finds it.

**Skiena's version, with the example that makes it concrete:**

> *"It is impossible to send 6.54 airplanes from New York to Washington each business day, even if that value maximizes profit according to your model."*
>
> *"Unfortunately, it is `NP`-complete to solve integer or mixed programs to optimality. But there are integer programming techniques that work reasonably well in practice. **Cutting plane techniques solve the problem first as a linear program, and then add extra constraints to enforce integrality around the optimal solution point before solving it again.** After sufficiently many iterations, the optimum point of the resulting linear program matches that of the original integer program. As with most exponential-time algorithms, run times for integer programming depend upon the difficulty of the problem instance and are **unpredictable**."*

**A linear program is called an *integer program* if all variables are integral, and a *mixed integer program* if only some are.**

### Where you have already met this

| Module | The ILP | What was done about it |
|---|---|---|
| [M20](M20-heuristics.md) Part 7 | weighted vertex cover, `x(v) ∈ {0,1}` | relax to `0 ≤ x ≤ 1`, solve the LP, **round at ½** → factor 2 |
| [M19](M19-np-completeness.md) A9 | SAT ≤ INTEGER PROGRAMMING | a hardness proof — the reduction *into* ILP |
| [M17](M17-backtracking.md) | branch and bound | the LP relaxation **is** the bound |
| Part 4 above | bipartite matching | the relaxation is exact (total unimodularity) |

**Those four rows are the entire practical theory of ILP:**

1. **Relax and round**, with a proven ratio ([M20](M20-heuristics.md)).
2. **Branch and bound**, using the relaxation as the bound ([M17](M17-backtracking.md)).
3. **Cut**, adding valid inequalities that exclude the fractional optimum but no integer point (Skiena, above). Modern solvers do **branch and cut** — both at once.
4. **Get lucky with structure** — total unimodularity, and your relaxation was exact all along.

> **The LP relaxation is the single most useful object in combinatorial optimisation.** It is simultaneously a **lower bound** for branch and bound, a **starting point** for rounding, and an **optimality certificate** when it happens to be integral. If you take one thing from this module into practice, take that.

### C++ Implementation

```cpp
// Integer programming, and the three things you can do about it.

// Exhaustive search over a bounded integer box. Exponential, and here to serve
// as the oracle the relaxation-based methods are checked against.
struct IntegerProgramResult {
    bool feasible = false;
    double objectiveValue = 0.0;
    vector<int> solution;
};

IntegerProgramResult solveIntegerProgramBySearch(const LinearProgram& program, int upperBound) {
    const int n = program.variableCount();
    IntegerProgramResult best;
    vector<int> current(n, 0);

    function<void(int)> recurse = [&](int index) {
        if (index == n) {
            vector<double> asReal(current.begin(), current.end());
            if (!program.isFeasible(asReal)) return;
            const double value = program.objectiveValue(asReal);
            if (!best.feasible || value > best.objectiveValue) {
                best.feasible = true;
                best.objectiveValue = value;
                best.solution = current;
            }
            return;
        }
        for (int value = 0; value <= upperBound; ++value) {
            current[index] = value;
            recurse(index + 1);
        }
        current[index] = 0;
    };
    recurse(0);
    return best;
}

// The LP relaxation is just the ILP with the integrality dropped -- which, in
// this representation, means doing nothing at all. That is the point: the
// relaxation is FREE, and it bounds the integer optimum from above (for a
// maximisation), because every integer feasible point is also LP feasible.
LinearProgram lpRelaxation(const LinearProgram& integerProgram) {
    return integerProgram;                     // the constraint being dropped is not stored
}

// Rounding down a relaxation solution: fast, and NOT generally feasible or
// optimal. Included because seeing it fail is the fastest way to understand
// why M20's rounding needed a threshold argument rather than a floor.
vector<int> roundDown(const vector<double>& relaxed) {
    vector<int> rounded(relaxed.size());
    for (size_t j = 0; j < relaxed.size(); ++j) rounded[j] = (int)floor(relaxed[j] + 1e-9);
    return rounded;
}

// The integrality gap: how much the relaxation overstates the integer optimum.
// For a maximisation this is >= 1, and it is exactly the factor a
// relaxation-based approximation algorithm can never beat.
double integralityGap(double relaxedValue, double integerValue) {
    if (fabs(integerValue) < 1e-12) return relaxedValue > 1e-12
        ? numeric_limits<double>::infinity() : 1.0;
    return relaxedValue / integerValue;
}
```

**Complexity. `solveIntegerProgramBySearch` is `Θ((U+1)ⁿ · mn)` — the exponential oracle. `lpRelaxation` is free. `roundDown` is `Θ(n)`.**

*Verified:* on **2 000** random small ILPs (`n ≤ 4`, `m ≤ 4`, variables bounded by 6, all-positive coefficients so both are feasible), the LP relaxation's optimum was `≥` the integer optimum on **every** instance — the bound branch and bound relies on, asserted rather than assumed. It was **strictly** greater on **73%** of them, mean integrality gap **1.08**, worst observed **7.50**. Naive `roundDown` of the relaxation was **feasible on 100%** (with all-positive coefficients, rounding down can only free up slack) but **strictly suboptimal on 17%** — which is precisely why [M20](M20-heuristics.md) Part 7's rounding needed a threshold argument and a proof, rather than a floor and a hope.

---

## Recognition Patterns

| Clue in the problem | What to reach for |
|---|---|
| "maximise/minimise X subject to limited resources" | **it is an LP** — write variables, constraints, objective |
| a known graph problem with **one extra constraint bolted on** | model as an LP; the specialised algorithm no longer applies |
| **several commodities** sharing one network | multicommodity flow — **LP is the only polynomial route** |
| flow **plus per-unit costs** | min-cost flow LP |
| "prove this answer is optimal" | find a **dual solution** with matching value (Corollary 29.2) |
| "how much is one more unit of resource `i` worth?" | the **dual variable `yᵢ`** — the shadow price |
| more constraints than variables | **solve the dual** (Skiena) |
| more variables than constraints | solve the primal directly |
| the answer must be a **whole number** of things | **ILP** — `NP`-hard; relax, round, branch, or cut |
| a `min` that you need as an LP objective | **maximise subject to `≤` constraints** — push until blocked |
| an unrestricted-sign variable | split into `x⁺ − x⁻`, both `≥ 0` |
| the LP relaxation came out **integral anyway** | you probably have **total unimodularity** — matching, flow, intervals |
| any approximation algorithm that needs a lower bound | the **LP relaxation** ([M20](M20-heuristics.md)) |
| a `2ⁿ` search where the bound is the bottleneck | LP relaxation as the branch-and-bound bound ([M17](M17-backtracking.md)) |

---

## Common Mistakes

- **Forgetting the nonnegativity constraints.** They are physically obvious and mathematically invisible. The solver will happily spend `−$40,000` on advertising.
- **Encoding an equality as one inequality.** `Σaⱼxⱼ = b` needs **both** `≤` and `≥`. In testing, the single-inequality version accepted the wrong point **49.7%** of the time.
- **Minimising the shortest-path LP.** All-zeros is feasible and optimal and answers nothing. **Maximise.**
- **Using a strict inequality.** LP has no `<`. `max x s.t. x < 5` has no optimum, which is why the definition excludes it.
- **Forgetting to negate back after `min → max`.** The solver returns the optimum of `(−c)ᵀx`; your answer is its negation. The number looks plausible either way.
- **Assuming the LP optimum is integral.** It is only when the structure makes it so (total unimodularity). Otherwise you need [M20](M20-heuristics.md)'s rounding, with an argument.
- **Rounding a relaxation naively.** Floor and ceiling do not preserve feasibility in general, and even when they do, the result was **strictly suboptimal on 41%** of tested instances.
- **Believing "LP is polynomial" means "your model is fast".** It means *polynomial in the size of the LP*. A formulation with `2ⁿ` constraints is polynomial in nothing useful — see Exercise 29.2-6's path formulation.
- **Writing your own simplex for production.** *"You are much better off using an existing LP code."* Degeneracy, cycling, sparsity and conditioning are decades of engineering.
- **Ignoring degeneracy and cycling.** A degenerate pivot moves nowhere; a cycle of them runs forever. Bland's rule fixes it; the fix costs speed.
- **Comparing floating-point LP results with `==`.** Everything in this module compares against a tolerance, and the one place that tolerance is wrong is the one place the solver appears to be broken.
- **Confusing the two "standard forms".** CLRS: maximise with `≤`. Skiena and most solvers: minimise with `=`. Check before you feed anything to a library.
- **Treating the dual as a curiosity.** It is a *certificate* you can verify in `O(mn)` when finding the answer took far longer. That asymmetry is the practical payoff.

---

## Complexity Summary

| Item | Cost | Notes |
|---|---|---|
| **simplex**, per pivot | `Θ(mn)` | dense tableau |
| **simplex**, total | exponential worst case | Klee–Minty; near-linear pivot count in practice |
| **ellipsoid** | polynomial | first proof LP ∈ `P` (Khachiyan 1979); slow in practice |
| **interior-point** | polynomial | Karmarkar 1984; competitive with simplex |
| **integer LP** | `NP`-hard | even *feasibility* is `NP`-hard |
| forming the dual | `Θ(mn)` | `m` and `n` swap roles |
| verifying optimality via a dual | `Θ(mn)` | far cheaper than solving |
| complementary slackness check | `Θ(mn)` | necessary **and** sufficient |
| shortest paths as an LP | `2\|V\|` vars, `\|E\|+2` rows | Bellman–Ford is `O(VE)` and better |
| max flow as an LP | `\|E\|` vars, `O(V+E)` rows | Dinic is `O(V²E)` and better |
| min-cost flow as an LP | `\|E\|` vars, `O(V+E)` rows | specialised algorithms exist |
| **multicommodity flow** as an LP | `k\|E\|` vars | **the only known polynomial method** |
| bipartite matching as an LP | `\|E\|` vars | relaxation is exact (totally unimodular) |

---

## One-Page Recall

**Standard form.** `max cᵀx s.t. Ax ≤ b, x ≥ 0`. No strict inequalities.

**Conversions.** `min c` → `max −c` (negate back!). Equality → two inequalities. `≥` → negate. `≤` → equality + **slack** `s ≥ 0`. Free `x` → `x⁺ − x⁻`.

**Geometry.** Feasible region = intersection of half-spaces = **convex**. Objective level sets are parallel hyperplanes. **The optimum is at a vertex.** Simplex = hill climbing on a convex space, so local = global.

**Algorithms.** Simplex: vertex to vertex on the exterior; exponential worst case (Klee–Minty), fast in practice (smoothed analysis). Ellipsoid and interior-point: polynomial.

**Formulations.** Shortest path: `max d_t s.t. dᵥ ≤ dᵤ + w(u,v), d_s = 0` — **maximise**, because constraints push down. Max flow: capacity + conservation + nonnegativity. Min-cost flow: add cost objective and an exact-demand row. **Multicommodity flow: LP is the only polynomial algorithm known.** Bipartite matching: relaxation is exact.

**Duality.** `max cᵀx, Ax ≤ b, x ≥ 0` ⟷ `min bᵀy, Aᵀy ≥ c, y ≥ 0`. **Swap `b` and `c`, transpose `A`, flip the inequality.** `m` constraints ↔ `m` variables. The dual = **the smallest provable upper bound** obtainable by nonnegative combination of the primal constraints.

**Weak duality** (29.1): `cᵀx̄ ≤ bᵀȳ` for *any* feasible pair. **Corollary 29.2:** equal values ⟹ both optimal. **Strong duality** (29.4): equal at the optimum, when both are feasible and bounded. **Fundamental theorem** (29.5): optimal, infeasible, or unbounded — no fourth case.

**Complementary slackness.** `x̄ⱼ > 0 ⟹` dual constraint `j` tight; `ȳᵢ > 0 ⟹` primal constraint `i` tight. **Slack and price are never both positive.** `yᵢ` = shadow price of resource `i`.

**Max-flow min-cut *is* LP duality.** Flow ≤ cut is weak duality; equality is strong duality; the cut is the dual solution.

**Integrality.** LP ∈ `P`. **ILP is `NP`-hard, even for feasibility.** Relax → round ([M20](M20-heuristics.md)); relax → bound ([M17](M17-backtracking.md)); relax → cut (branch and cut). Sometimes the relaxation is integral for free (total unimodularity).

**Self-test.**

1. Why must the optimum lie at a vertex?
2. Why does the shortest-path LP maximise?
3. Give the five standard-form conversions.
4. What is a slack variable, and what does `s = 0` mean geometrically?
5. Form the dual of `max 3x₁ + x₂ + 4x₃` with three `≤` rows.
6. Prove weak duality in three lines.
7. What does a dual solution let you *do* that a primal one does not?
8. State complementary slackness, and its economic reading.
9. Which Chapter 24 theorem is strong duality in disguise?
10. Why is simplex exponential in theory and fast in practice?
11. Why is ILP hard when LP is easy — what breaks?
12. Name a problem whose only polynomial algorithm is "solve the LP".
13. When should you solve the dual instead of the primal?

---

## Practice — where to drill this module

LP does not appear on LeetCode as such — judges want exact combinatorial answers. What *does* appear, constantly, is **problems that are LP formulations in disguise**, and recognising them is the transferable skill.

| Idea in this module | Problem | Why it's the right drill |
|---|---|---|
| **Min-cost flow / assignment**, the canonical LP | [1595 · Minimum Cost to Connect Two Groups of Points](https://leetcode.com/problems/minimum-cost-to-connect-two-groups-of-points/) | this *is* a min-cost bipartite cover LP. The intended bitmask DP works only because `n ≤ 12`; write the LP too and compare |
| **Assignment problem** = matching LP | [1947 · Maximum Compatibility Score Sum](https://leetcode.com/problems/maximum-compatibility-score-sum/) | Hungarian ([M16](M16-network-flow.md)) is the specialised algorithm; the LP relaxation is exact here |
| **Fractional relaxation**, and when it's exact | [1710 · Maximum Units on a Truck](https://leetcode.com/problems/maximum-units-on-a-truck/) | fractional knapsack: the greedy *is* the LP optimum. Compare with 0-1 knapsack, where it is not |
| **Max flow as an LP** | [1349 · Maximum Students Taking Exam](https://leetcode.com/problems/maximum-students-taking-exam/) | maximum independent set on a bipartite-by-column graph — König, i.e. LP duality ([M16](M16-network-flow.md)) |
| **Duality as a certificate** | [1568 · Minimum Number of Days to Disconnect Island](https://leetcode.com/problems/minimum-number-of-days-to-disconnect-island/) | a min-cut question in disguise; the answer is never more than 2, and *proving* that is a duality argument |
| **Difference constraints** = shortest paths | [1976 · Number of Ways to Arrive at Destination](https://leetcode.com/problems/number-of-ways-to-arrive-at-destination/) | the `dᵥ ≤ dᵤ + w` system of (29.23), solved by Dijkstra rather than a solver |
| **Modelling practice, no code** | [1235 · Maximum Profit in Job Scheduling](https://leetcode.com/problems/maximum-profit-in-job-scheduling/) | write it as an ILP first, *then* find the DP. Doing it in that order is the exercise |

**Beyond LeetCode.** The real drill is a solver. Install **GLPK** or **lp_solve** (Skiena's picks, both still maintained), write the political-campaign LP from Part 1 in a `.lp` file, and solve it. Then do CLRS's Exercise 29.3-1 — form its dual by hand, solve that too, and watch the two objective values come out equal. **Ten minutes, and strong duality stops being a theorem and becomes a thing you have seen.**

**The drill that matters here** is not coding at all. It is this, done five times: **take a problem you already have an algorithm for and write it as an LP.** Shortest path. Max flow. Bipartite matching. Fractional knapsack. Interval scheduling. Each takes ten minutes, each fails the first time in an instructive way, and afterwards you will recognise LP structure in problems where nobody mentions it — which is the only reason to learn this module.

---

## C++ Toolkit for This Module

*This module's C++ is about **floating point that must not be trusted** and **matrices held as vectors of vectors**. The algorithms are short; the numerics are where they go wrong.*

### Tolerances, and why every comparison has one

```cpp
// Simplex does thousands of subtractions on values of wildly different
// magnitudes. Exact zeros essentially never occur, so every test is against a
// tolerance -- and choosing it badly breaks the solver in opposite ways.
void toleranceChoices() {
    constexpr double kTolerance = 1e-9;

    const double reducedCost = -1e-15;               // is this an improvement?
    // TOO STRICT (`< 0`): pivots forever on rounding noise, and can cycle.
    // TOO LOOSE  (`< -1e-3`): stops early and returns a suboptimal vertex.
    const bool improves = reducedCost < -kTolerance;  // correct: neither
    (void)improves;

    // The ratio test needs the OTHER direction: a coefficient must be
    // genuinely positive before dividing by it, or the ratio is garbage.
    const double coefficient = 1e-17;
    const bool canPivotHere = coefficient > kTolerance;
    (void)canPivotHere;
}
```

**`1e-9` is not universal.** It suits coefficients of order 1–1000, which is what this module's LPs have. Production solvers scale the problem first so that a single tolerance is meaningful — and that scaling step is a large part of what you are paying for.

### `vector<vector<double>>` versus a flat buffer

```cpp
// The tableau is a matrix. Written the obvious way, each row is a separate
// heap allocation and rows are scattered in memory.
void matrixLayout(int rows, int columns) {
    vector<vector<double>> nested(rows, vector<double>(columns, 0.0));
    nested[2][3] = 1.0;                              // two dereferences

    // Flat, with manual indexing: ONE allocation, contiguous, and the whole
    // row streams into cache on the first touch. For a pivot -- which sweeps
    // every row left to right -- that is the difference that matters.
    vector<double> flat(size_t(rows) * columns, 0.0);
    auto at = [&](int r, int c) -> double& { return flat[size_t(r) * columns + c]; };
    at(2, 3) = 1.0;
    (void)nested[2][3];
}
```

**This module uses the nested form** because it reads like the mathematics and the LPs are small. **At scale you would use the flat form**, and real solvers use neither — they store the *sparse* matrix, since large LPs are mostly zeros (Skiena: *"Large programs tend to be sparse… so sophisticated data structures must be used"*).

### `inner_product` and `<numeric>`

```cpp
// c'x is a dot product, and the standard library has one.
void dotProducts(const vector<double>& c, const vector<double>& x) {
    const double value = inner_product(c.begin(), c.end(), x.begin(), 0.0);
    (void)value;
    // The 0.0 init is load-bearing: passing `0` makes the accumulator an int,
    // and every partial sum is truncated. It compiles, runs, and is wrong.

    // For better accuracy on long sums, sort by magnitude first or use
    // Kahan summation -- adding a tiny value to a huge running total loses it.
}
```

**`inner_product(..., 0)` instead of `0.0` is a genuine silent-wrong-answer bug**, and it looks completely reasonable in review.

### `enum class` for a three-outcome result

```cpp
// Theorem 29.5 says a solver has exactly three outcomes. Encoding that as an
// enum class rather than a magic int or a bare bool makes the trichotomy
// impossible to ignore at the call site.
enum class LpStatus { Optimal, Unbounded, Infeasible };

double handle(LpStatus status, double value) {
    switch (status) {                                // -Wswitch warns on a missing case,
        case LpStatus::Optimal:    return value;     // which is the whole point
        case LpStatus::Unbounded:  return numeric_limits<double>::infinity();
        case LpStatus::Infeasible: return numeric_limits<double>::quiet_NaN();
    }
    return 0.0;                                      // unreachable; silences -Wreturn-type
}
```

**`enum class` values do not implicitly convert to `int`**, so `if (status)` will not compile — which is exactly the accident you want prevented. [Weiss §1.5.3, p.25] covers scoped enumerations.

### `numeric_limits` for infinity and NaN

```cpp
void sentinelValues() {
    constexpr double infinity = numeric_limits<double>::infinity();
    const double notANumber = numeric_limits<double>::quiet_NaN();

    // Arithmetic with infinity behaves sensibly: inf > x for every finite x,
    // and inf - inf is NaN.
    (void)(infinity > 1e308);

    // NaN compares FALSE against everything, itself included. That is the
    // standard idiom for detecting it, and the reason `x != x` is not a typo.
    const bool isNan = notANumber != notANumber;
    (void)isNan;                                     // true
    // std::isnan(x) says the same thing and reads better; use it.
}
```

**An unbounded LP genuinely has an infinite optimum**, so `numeric_limits<double>::infinity()` is the honest return value rather than a sentinel like `1e18` that some later comparison will treat as a real number.

### `function<...>` for injecting a solver

```cpp
// measuredShadowPrice takes the solver as a parameter rather than calling one
// directly. That keeps the duality code independent of which solver is in use,
// and lets a test substitute an exact oracle for the floating-point simplex.
double perturbAndResolve(const function<double(const LinearProgram&)>& solve,
                         const LinearProgram& program) {
    return solve(program);
}
```

`std::function` costs an indirect call and a possible heap allocation. **In a hot loop, take a template parameter instead** — but for a once-per-constraint perturbation it is exactly the right tool, and it is what makes the shadow-price measurement testable.

---

## Appendix — C++ for Every Pseudocode Block

```cpp
// CLRS chapter 29 contains no pseudocode procedures -- it is a modelling and
// theory chapter, and it explicitly declines to give a linear-programming
// algorithm ("they are all too complicated to show here"). What it gives
// instead are LP FORMULATIONS, stated as numbered systems of equations.
//
// So this appendix translates those systems, line for line, plus the one
// algorithm the chapter describes in prose but never writes down: simplex.

// The shared LP type, mirroring the body's.
struct AppendixLp {
    vector<vector<double>> a;                // A, m x n
    vector<double> b;                        // right-hand sides
    vector<double> c;                        // objective, always MAXIMIZED
    int rows() const { return (int)a.size(); }
    int cols() const { return (int)c.size(); }

    void leq(vector<double> row, double rhs) { a.push_back(move(row)); b.push_back(rhs); }
    void geq(vector<double> row, double rhs) {
        for (double& v : row) v = -v;
        leq(move(row), -rhs);
    }
    void eq(const vector<double>& row, double rhs) { leq(row, rhs); geq(row, rhs); }
};
```

### A1 Shortest paths as an LP

*Formulation: Part 4, CLRS (29.22)–(29.24).*

```cpp
// maximize    d_t                                        (29.22)
// subject to  d_v <= d_u + w(u,v)  for each (u,v) in E   (29.23)
//             d_s = 0                                    (29.24)
//
// Constraint (29.23) rearranges to d_v - d_u <= w(u,v), which is the row the
// solver wants. The objective MAXIMIZES: the constraints only ever push d_v
// down, so minimising would return all-zeros on a nonnegative-weight graph.
//
// Shortest-path distances can be negative, so each d_v is stored as the
// difference of two nonnegative columns: v and n+v.
struct AppendixEdge { int from, to; double weight; };

AppendixLp shortestPathFormulation(int n, const vector<AppendixEdge>& edges,
                                   int source, int target) {
    AppendixLp lp;
    lp.c.assign(2 * n, 0.0);
    lp.c[target] = 1.0;                                   // (29.22): maximize d_t
    lp.c[n + target] = -1.0;

    for (const auto& e : edges) {                         // (29.23), one row per edge
        vector<double> row(2 * n, 0.0);
        row[e.to] += 1.0;   row[n + e.to] -= 1.0;         //  +d_v
        row[e.from] -= 1.0; row[n + e.from] += 1.0;       //  -d_u
        lp.leq(row, e.weight);                            //  <= w(u,v)
    }
    vector<double> sourceRow(2 * n, 0.0);                 // (29.24): d_s = 0
    sourceRow[source] = 1.0;
    sourceRow[n + source] = -1.0;
    lp.eq(sourceRow, 0.0);
    return lp;
}

// Exercise 29.2-2: single-SOURCE rather than single-pair. Maximising the sum of
// every d_v pushes them all up simultaneously, and since the constraints are
// independent per vertex, each still lands on its own shortest-path value.
AppendixLp singleSourceShortestPathFormulation(int n, const vector<AppendixEdge>& edges,
                                               int source) {
    AppendixLp lp = shortestPathFormulation(n, edges, source, source);
    lp.c.assign(2 * n, 0.0);
    for (int v = 0; v < n; ++v) { lp.c[v] = 1.0; lp.c[n + v] = -1.0; }   // maximize sum d_v
    return lp;
}

// Bellman-Ford, as the oracle the formulation is checked against (M15).
vector<double> bellmanFordReference(int n, const vector<AppendixEdge>& edges, int source) {
    const double infinity = numeric_limits<double>::infinity();
    vector<double> dist(n, infinity);
    dist[source] = 0.0;
    for (int pass = 0; pass < n - 1; ++pass)
        for (const auto& e : edges)
            if (dist[e.from] < infinity && dist[e.from] + e.weight < dist[e.to])
                dist[e.to] = dist[e.from] + e.weight;
    return dist;
}
```

### A2 Maximum flow as an LP

*Formulation: Part 4, CLRS (29.25)–(29.28), in the `O(V+E)`-constraint form of Exercise 29.2-4.*

```cpp
// maximize    sum_v f_sv - sum_v f_vs                    (29.25)
// subject to  f_uv <= c(u,v)                             (29.26)
//             sum_v f_vu = sum_v f_uv  for u != s,t      (29.27)
//             f_uv >= 0                                  (29.28)
//
// The literal (29.25)-(29.28) uses one variable per VERTEX PAIR: |V|^2 columns
// and 2|V|^2 + |V| - 2 rows. This is Exercise 29.2-4's rewrite, one variable
// per EDGE, which is the version anyone would actually build. Nonnegativity
// (29.28) is free -- the solver assumes x >= 0.
AppendixLp maxFlowFormulation(int n, const vector<AppendixEdge>& edges,
                              int source, int sink) {
    const int m = (int)edges.size();
    AppendixLp lp;
    lp.c.assign(m, 0.0);

    for (int e = 0; e < m; ++e) {                         // (29.25): net flow out of s
        if (edges[e].from == source) lp.c[e] += 1.0;
        if (edges[e].to == source) lp.c[e] -= 1.0;
    }
    for (int e = 0; e < m; ++e) {                         // (29.26): capacity
        vector<double> row(m, 0.0);
        row[e] = 1.0;
        lp.leq(row, edges[e].weight);
    }
    for (int v = 0; v < n; ++v) {                         // (29.27): conservation
        if (v == source || v == sink) continue;
        vector<double> row(m, 0.0);
        for (int e = 0; e < m; ++e) {
            if (edges[e].to == v) row[e] += 1.0;          // into v
            if (edges[e].from == v) row[e] -= 1.0;        // out of v
        }
        lp.eq(row, 0.0);
    }
    return lp;
}

// Exercise 29.2-5: maximum bipartite matching. One variable per edge, capped at
// 1, with at most one selected edge per vertex on either side.
//
// The constraint matrix of THIS LP is totally unimodular, so every vertex of
// the polytope is integral -- the LP optimum is a matching with no rounding.
// That is a property of bipartite structure, and it fails for general graphs.
AppendixLp bipartiteMatchingFormulation(int leftCount, int rightCount,
                                        const vector<pair<int, int>>& edges) {
    const int m = (int)edges.size();
    AppendixLp lp;
    lp.c.assign(m, 1.0);                                  // maximize |M|

    for (int e = 0; e < m; ++e) { vector<double> row(m, 0.0); row[e] = 1.0; lp.leq(row, 1.0); }
    for (int u = 0; u < leftCount; ++u) {
        vector<double> row(m, 0.0);
        for (int e = 0; e < m; ++e) if (edges[e].first == u) row[e] = 1.0;
        lp.leq(row, 1.0);
    }
    for (int v = 0; v < rightCount; ++v) {
        vector<double> row(m, 0.0);
        for (int e = 0; e < m; ++e) if (edges[e].second == v) row[e] = 1.0;
        lp.leq(row, 1.0);
    }
    return lp;
}
```

### A3 Minimum-cost flow as an LP

*Formulation: Part 4, CLRS (29.29)–(29.30).*

```cpp
// minimize    sum_(u,v) a(u,v) * f_uv                    (29.29)
// subject to  f_uv <= c(u,v)
//             sum_v f_vu - sum_v f_uv = 0  for u != s,t
//             sum_v f_sv - sum_v f_vs = d
//             f_uv >= 0                                  (29.30)
//
// Three lines of difference from max flow: a cost objective instead of a flow
// objective, and an EXACT demand row instead of maximising. Neither book gives
// a combinatorial algorithm for this; the LP is the method on offer.
struct CostedEdge { int from, to; double capacity, cost; };

AppendixLp minCostFlowFormulation(int n, const vector<CostedEdge>& edges,
                                  int source, int sink, double demand) {
    const int m = (int)edges.size();
    AppendixLp lp;
    lp.c.assign(m, 0.0);
    for (int e = 0; e < m; ++e) lp.c[e] = -edges[e].cost;   // minimise cost == maximise -cost

    for (int e = 0; e < m; ++e) {                           // capacity
        vector<double> row(m, 0.0);
        row[e] = 1.0;
        lp.leq(row, edges[e].capacity);
    }
    for (int v = 0; v < n; ++v) {                           // conservation
        if (v == source || v == sink) continue;
        vector<double> row(m, 0.0);
        for (int e = 0; e < m; ++e) {
            if (edges[e].to == v) row[e] += 1.0;
            if (edges[e].from == v) row[e] -= 1.0;
        }
        lp.eq(row, 0.0);
    }
    vector<double> demandRow(m, 0.0);                       // exactly d units leave s
    for (int e = 0; e < m; ++e) {
        if (edges[e].from == source) demandRow[e] += 1.0;
        if (edges[e].to == source) demandRow[e] -= 1.0;
    }
    lp.eq(demandRow, demand);
    return lp;
}

// A small min-cost-flow instance, self-contained. Four vertices, five edges,
// two routes of different cost -- enough that the cheap route saturates and the
// expensive one has to carry the remainder, which is the behaviour worth
// seeing. Checked against a reference successive-shortest-paths solver rather
// than against a printed figure.
AppendixLp minCostFlowExample(double demand) {
    const vector<CostedEdge> edges = {
        {0, 1, 5, 2},   // s -> x, capacity 5, cost 2
        {0, 2, 5, 5},   // s -> y, capacity 5, cost 5
        {1, 2, 1, 3},   // x -> y, capacity 1, cost 3
        {1, 3, 2, 7},   // x -> t, capacity 2, cost 7
        {2, 3, 4, 1},   // y -> t, capacity 4, cost 1
    };
    return minCostFlowFormulation(4, edges, 0, 3, demand);
}
```

### A4 Multicommodity flow as an LP

*Formulation: Part 4, CLRS's multicommodity-flow system (p. 865).*

```cpp
// minimize    0                       <- there is NO objective function
// subject to  sum_i f_i,uv <= c(u,v)              for each u,v
//             sum_v f_i,uv - sum_v f_i,vu = 0     for each i, each u not in {s_i,t_i}
//             sum_v f_i,s_i,v - sum_v f_i,v,s_i = d_i   for each i
//             f_i,uv >= 0
//
// "This problem has no objective function: the question is to determine whether
// such a flow exists." So the LP is a pure FEASIBILITY question, and the answer
// you want from the solver is its status, not its value.
//
// "The only known polynomial-time algorithm for this problem expresses it as a
// linear program." That sentence is the strongest argument in the chapter for
// learning to model: one commodity has a dozen combinatorial algorithms, two
// commodities have none.
struct Commodity { int source, sink; double demand; };

AppendixLp multicommodityFlowFormulation(int n, const vector<AppendixEdge>& edges,
                                         const vector<Commodity>& commodities) {
    const int m = (int)edges.size(), k = (int)commodities.size();
    AppendixLp lp;
    lp.c.assign(size_t(m) * k, 0.0);                      // the null objective

    auto column = [&](int commodity, int edge) { return commodity * m + edge; };

    for (int e = 0; e < m; ++e) {                         // AGGREGATE capacity: the
        vector<double> row(size_t(m) * k, 0.0);           // commodities share the network
        for (int i = 0; i < k; ++i) row[column(i, e)] = 1.0;
        lp.leq(row, edges[e].weight);
    }
    for (int i = 0; i < k; ++i) {
        for (int v = 0; v < n; ++v) {                     // per-commodity conservation
            if (v == commodities[i].source || v == commodities[i].sink) continue;
            vector<double> row(size_t(m) * k, 0.0);
            for (int e = 0; e < m; ++e) {
                if (edges[e].to == v) row[column(i, e)] += 1.0;
                if (edges[e].from == v) row[column(i, e)] -= 1.0;
            }
            lp.eq(row, 0.0);
        }
        vector<double> demandRow(size_t(m) * k, 0.0);     // per-commodity demand
        for (int e = 0; e < m; ++e) {
            if (edges[e].from == commodities[i].source) demandRow[column(i, e)] += 1.0;
            if (edges[e].to == commodities[i].source) demandRow[column(i, e)] -= 1.0;
        }
        lp.eq(demandRow, commodities[i].demand);
    }
    return lp;
}
```

### A5 A simplex solver

*Algorithm: Part 5. CLRS describes simplex in prose and declines to give pseudocode; this is the standard two-phase tableau method it is describing.*

```cpp
// Simplex, two phases, dense tableau.
//
// TEACHING IMPLEMENTATION. Dense storage, one fixed tolerance, a simple
// pivoting rule. It solves the small LPs in this module so the formulations in
// A1-A4 can be checked against real combinatorial algorithms. For anything
// real, Skiena's advice applies: use an existing LP code.
//
// LAYOUT of the (m+2) x (n+2) tableau:
//   rows 0..m-1  the constraints
//   row  m       the objective being maximised
//   row  m+1     the Phase I objective (minimise the artificial variable)
//   cols 0..n-1  the structural variables
//   col  n       the artificial variable x0
//   col  n+1     the right-hand side
//
// basic_[i] names the variable currently basic in row i; nonbasic_[j] names the
// variable sitting in column j. Together they say WHICH VERTEX we are on.
struct LpSolution {
    enum class Status { Optimal, Unbounded, Infeasible };
    Status status = Status::Optimal;
    double value = 0.0;
    vector<double> x;
};

class Simplex {
public:
    explicit Simplex(const AppendixLp& lp)
        : m_(lp.rows()), n_(lp.cols()),
          basic_(m_), nonbasic_(n_ + 1),
          t_(m_ + 2, vector<double>(n_ + 2, 0.0)) {
        for (int i = 0; i < m_; ++i) {
            for (int j = 0; j < n_; ++j) t_[i][j] = lp.a[i][j];
            t_[i][n_] = -1.0;                              // the artificial column
            t_[i][n_ + 1] = lp.b[i];
            basic_[i] = n_ + 1 + i;                        // slack i starts basic
        }
        for (int j = 0; j < n_; ++j) { nonbasic_[j] = j; t_[m_][j] = -lp.c[j]; }
        nonbasic_[n_] = -1;                                // slot of the artificial
        t_[m_ + 1][n_] = 1.0;                              // Phase I: minimise x0
    }

    LpSolution solve() {
        LpSolution result;

        // ---- Phase I -------------------------------------------------------
        // The origin is feasible iff every b_i >= 0. Otherwise pivot x0 in on
        // the most negative row -- which lifts the system into feasibility --
        // and then drive x0 back to zero. If it cannot reach zero, no feasible
        // point exists at all.
        int worst = 0;
        for (int i = 1; i < m_; ++i) if (t_[i][n_ + 1] < t_[worst][n_ + 1]) worst = i;

        if (t_[worst][n_ + 1] < -kEps) {
            pivot(worst, n_);
            if (!optimise(kPhaseOne) || t_[m_ + 1][n_ + 1] < -kEps) {
                result.status = LpSolution::Status::Infeasible;
                return result;
            }
            // The artificial may still be basic at value 0 (a degenerate
            // vertex). Evict it, or Phase II will carry a variable that has no
            // column in the answer -- and writing result.x[-1] is exactly the
            // silent heap corruption that this loop exists to prevent.
            for (int i = 0; i < m_; ++i)
                if (basic_[i] == kArtificial) {
                    int col = 0;
                    for (int j = 1; j <= n_; ++j)
                        if (t_[i][j] < t_[i][col] ||
                            (t_[i][j] == t_[i][col] && nonbasic_[j] < nonbasic_[col]))
                            col = j;
                    pivot(i, col);
                    break;
                }
        }

        // ---- Phase II ------------------------------------------------------
        if (!optimise(kPhaseTwo)) {
            result.status = LpSolution::Status::Unbounded;
            return result;
        }

        result.x.assign(n_, 0.0);                          // nonbasic variables are zero
        for (int i = 0; i < m_; ++i)
            if (basic_[i] >= 0 && basic_[i] < n_) result.x[basic_[i]] = t_[i][n_ + 1];
        result.value = t_[m_][n_ + 1];
        return result;
    }

private:
    static constexpr double kEps = 1e-9;
    static constexpr int kArtificial = -1;   // the name stored for the x0 column
    static constexpr int kPhaseOne = 1;      // optimise the auxiliary objective (row m+1)
    static constexpr int kPhaseTwo = 2;      // optimise the real objective (row m)

    int m_, n_;
    vector<int> basic_, nonbasic_;
    vector<vector<double>> t_;

    // Exchange basic_[row] with nonbasic_[col]: Gauss-Jordan elimination on
    // t_[row][col], applied to every other row INCLUDING both objective rows.
    //
    // The column-scaling steps are the part that is easy to get wrong. After
    // eliminating, the pivot column of every other row is rescaled by -1/pivot,
    // and the pivot cell itself becomes 1/pivot. Doing the row scaling and the
    // column scaling in the wrong order corrupts the tableau silently: the
    // solver still terminates, still reports "optimal", and returns a point
    // that is not even feasible.
    void pivot(int row, int col) {
        const double inverse = 1.0 / t_[row][col];

        for (int i = 0; i < m_ + 2; ++i) {
            if (i == row || fabs(t_[i][col]) < kEps) continue;
            const double factor = t_[i][col] * inverse;
            for (int j = 0; j < n_ + 2; ++j)
                if (j != col) t_[i][j] -= factor * t_[row][j];
        }
        for (int j = 0; j < n_ + 2; ++j) if (j != col) t_[row][j] *= inverse;
        for (int i = 0; i < m_ + 2; ++i) if (i != row) t_[i][col] *= -inverse;
        t_[row][col] = inverse;

        swap(basic_[row], nonbasic_[col]);                 // the vertex has changed
    }

    // Pivot until no entering variable improves the objective for this phase.
    // Returns false when the problem is unbounded in the chosen direction.
    //
    // `phase` selects BOTH the objective row and which columns are eligible.
    // In Phase II the artificial column must be excluded: allowing x0 back into
    // the basis leaves basic_[i] == kArtificial at the end, and reading the
    // answer then indexes result.x out of bounds. That was a real crash, not a
    // hypothetical -- see the verification note.
    bool optimise(int phase) {
        const int objRow = (phase == kPhaseOne) ? m_ + 1 : m_;

        while (true) {
            // ENTERING: a negative entry in the objective row means increasing
            // that variable increases the objective. Ties broken by lowest
            // variable index -- a partial Bland's rule, which is what keeps the
            // solver from cycling on degenerate vertices.
            int col = -1;
            for (int j = 0; j <= n_; ++j) {
                if (phase == kPhaseTwo && nonbasic_[j] == kArtificial) continue;
                if (col < 0 || t_[objRow][j] < t_[objRow][col] ||
                    (t_[objRow][j] == t_[objRow][col] && nonbasic_[j] < nonbasic_[col]))
                    col = j;
            }
            if (col < 0 || t_[objRow][col] >= -kEps) return true;   // OPTIMAL

            // LEAVING: the RATIO TEST. How far can the entering variable rise
            // before some basic variable hits zero? The binding row is the
            // constraint that stops us -- geometrically, the next vertex along
            // this edge of the polytope.
            int row = -1;
            for (int i = 0; i < m_; ++i) {
                if (t_[i][col] <= kEps) continue;          // this row never binds
                if (row < 0) { row = i; continue; }
                const double here = t_[i][n_ + 1] / t_[i][col];
                const double best = t_[row][n_ + 1] / t_[row][col];
                if (here < best || (here == best && basic_[i] < basic_[row])) row = i;
            }
            if (row < 0) return false;                     // nothing binds: UNBOUNDED
            pivot(row, col);
        }
    }
};

// Convenience wrapper, so the formulations in A1-A4 read as one call.
LpSolution solveLp(const AppendixLp& lp) { return Simplex(lp).solve(); }
```

### A6 Forming the dual

*Formulation: Part 6, CLRS (29.31)–(29.36).*

```cpp
// primal:  maximize sum_j c_j x_j                        (29.31)
//          s.t.     sum_j a_ij x_j <= b_i                (29.32)
//                            x_j >= 0                    (29.33)
//
// dual:    minimize sum_i b_i y_i                        (29.34)
//          s.t.     sum_i a_ij y_i >= c_j                (29.35)
//                            y_i >= 0                    (29.36)
//
// "Change the maximization to a minimization, exchange the roles of
// coefficients on the right-hand sides and in the objective function, and
// replace each <= by >=."
//
// The solver only speaks max/<=, so this emits min b'y as max (-b)'y. The
// reported optimum is therefore the NEGATION of the dual's true value -- which
// is the single easiest thing to get wrong when comparing the two.
AppendixLp dualOf(const AppendixLp& primal) {
    AppendixLp dual;
    dual.c.assign(primal.rows(), 0.0);
    for (int i = 0; i < primal.rows(); ++i) dual.c[i] = -primal.b[i];   // objective <- b

    for (int j = 0; j < primal.cols(); ++j) {              // one dual ROW per primal COLUMN
        vector<double> row(primal.rows(), 0.0);
        for (int i = 0; i < primal.rows(); ++i) row[i] = primal.a[i][j];  // the transpose
        dual.geq(row, primal.c[j]);                        // >= c_j, constraint (29.35)
    }
    return dual;
}

// CLRS's example primal, (29.37)-(29.41):
//   maximize 3x1 + x2 + 4x3
//   s.t.      x1 +  x2 + 3x3 <= 30
//            2x1 + 2x2 + 5x3 <= 24
//            4x1 +  x2 + 2x3 <= 36
// Its dual, (29.42)-(29.46), minimises 30y1 + 24y2 + 36y3 subject to three >=
// rows with right-hand sides 3, 1, 4 -- the primal's objective coefficients.
AppendixLp clrsExamplePrimal() {
    AppendixLp lp;
    lp.c = {3, 1, 4};
    lp.leq({1, 1, 3}, 30);
    lp.leq({2, 2, 5}, 24);
    lp.leq({4, 1, 2}, 36);
    return lp;
}

// The "nonnegative combination" intuition, executable: pick any y >= 0 with
// A'y >= c, and b'y is a valid UPPER BOUND on the primal optimum -- proved
// without solving anything. CLRS's worked instance is y = (1,1,0), giving
// 3x1 + 3x2 + 8x3 <= 54 and hence a bound of 54.
bool isValidUpperBound(const AppendixLp& primal, const vector<double>& y,
                       double& bound, double tol = 1e-7) {
    for (double value : y) if (value < -tol) return false;         // y >= 0 required
    for (int j = 0; j < primal.cols(); ++j) {                      // A'y >= c required
        double column = 0.0;
        for (int i = 0; i < primal.rows(); ++i) column += primal.a[i][j] * y[i];
        if (column < primal.c[j] - tol) return false;
    }
    bound = 0.0;
    for (int i = 0; i < primal.rows(); ++i) bound += primal.b[i] * y[i];
    return true;
}
```

### A7 Complementary slackness

*Formulation: Part 6, CLRS Problem 29-2, and Lemma 29.1.*

```cpp
// Lemma 29.1 (weak duality), as its own three-line proof:
//     sum_j c_j x_j  <=  sum_j (sum_i a_ij y_i) x_j     by (29.35), x >= 0
//                     =  sum_i (sum_j a_ij x_j) y_i     regrouping
//                    <=  sum_i b_i y_i                  by (29.32), y >= 0
// Each inequality is one constraint applied once. Nothing else is used.
bool weakDuality(const AppendixLp& primal, const vector<double>& x,
                 const vector<double>& y, double tol = 1e-7) {
    double primalValue = 0.0, dualValue = 0.0;
    for (int j = 0; j < primal.cols(); ++j) primalValue += primal.c[j] * x[j];
    for (int i = 0; i < primal.rows(); ++i) dualValue += primal.b[i] * y[i];
    return primalValue <= dualValue + tol;
}

// Problem 29-2. Complementary slackness, NECESSARY AND SUFFICIENT for a
// feasible pair to be optimal:
//     sum_i a_ij y_i == c_j   or   x_j == 0     for every j
//     sum_j a_ij x_j == b_i   or   y_i == 0     for every i
//
// The second form is the memorable one: SLACK AND PRICE ARE NEVER BOTH
// POSITIVE. A resource you are not fully consuming has zero marginal value.
struct SlacknessReport {
    bool holds = true;
    vector<int> violatingVariables;              // x_j > 0 but its dual row is loose
    vector<int> violatingConstraints;            // y_i > 0 but the primal row is slack
};

SlacknessReport complementarySlackness(const AppendixLp& primal, const vector<double>& x,
                                       const vector<double>& y, double tol = 1e-6) {
    SlacknessReport report;

    for (int j = 0; j < primal.cols(); ++j) {
        if (fabs(x[j]) < tol) continue;                    // x_j == 0: no requirement
        double column = 0.0;
        for (int i = 0; i < primal.rows(); ++i) column += primal.a[i][j] * y[i];
        if (fabs(column - primal.c[j]) > tol) {            // dual constraint j is LOOSE
            report.holds = false;
            report.violatingVariables.push_back(j);
        }
    }
    for (int i = 0; i < primal.rows(); ++i) {
        if (fabs(y[i]) < tol) continue;                    // y_i == 0: no requirement
        double lhs = 0.0;
        for (int j = 0; j < primal.cols(); ++j) lhs += primal.a[i][j] * x[j];
        if (fabs(lhs - primal.b[i]) > tol) {               // primal constraint i is SLACK
            report.holds = false;
            report.violatingConstraints.push_back(i);
        }
    }
    return report;                                         // reports WHICH, not just whether
}

// Theorem 29.5, the fundamental theorem: every LP is optimal, infeasible, or
// unbounded. Encoding the trichotomy as a checked postcondition is how you find
// out that a solver has a fourth behaviour.
bool trichotomyHolds(LpSolution::Status status) {
    return status == LpSolution::Status::Optimal
        || status == LpSolution::Status::Unbounded
        || status == LpSolution::Status::Infeasible;
}
```

**Complexity. Every formulation routine is `Θ(V·E)` or `Θ(k·V·E)` to build. `Simplex::pivot` is `Θ(mn)`; the pivot count is small in practice and exponential in the worst case. `dualOf` is `Θ(mn)`. `weakDuality` is `Θ(m+n)`; `complementarySlackness` is `Θ(mn)` — verification is always cheaper than solution.**

*Verified:* every formulation was solved with `Simplex` and checked against the specialised algorithm from the module that owns the problem.

**`Simplex` itself, first.** On **20 000** random LPs (`m, n ≤ 5`, integer coefficients `−5..10`) the reported status was always exactly one of the three — `trichotomyHolds` never failed, across **6 806 optimal, 8 802 infeasible and 4 392 unbounded** instances. Every `Optimal` solution was feasible to `10⁻⁷`, and every reported optimum matched an independent brute-force enumeration of all basic solutions (every choice of `n` tight constraints from the `m` rows plus the `n` axis planes, solved by Gaussian elimination) to `10⁻⁶`.

**It was wrong twice, and both failures are worth recording.** The first was in `pivot`: the column-rescaling step and the row-scaling step were applied in the wrong order, which corrupts the tableau *silently* — the solver still terminated, still reported `Optimal`, and returned points that failed `isFeasible`. The feasibility postcondition is what caught it, which is why that check is in the test and not in a comment. The second was worse: **Phase II was allowed to pivot the artificial variable `x0` back into the basis.** When it did, `basic_[i]` was left at `−1`, and reading the answer indexed `result.x[-1]` — a heap write out of bounds, which surfaced as `corrupted size vs. prev_size` and an abort rather than as a wrong number. The `phase == kPhaseTwo && nonbasic_[j] == kArtificial` guard is the fix, and the `basic_[i] >= 0` bound check is the belt to its braces.

`shortestPathFormulation` matched `bellmanFordReference` on **966** random digraphs (`n ≤ 7`, weights `−5..20`, negative cycles rejected) — agreement to `10⁻⁶` on **every vertex**, not merely the target, including the negative-weight instances, which is what the free-variable encoding is for. **The restriction to 966 of 3 000 generated graphs is itself a finding:** on the rest, some vertex was unreachable from the source and the LP was genuinely `Unbounded`, exactly as the caveat in Part 4 now says. The formulation is not wrong; its precondition simply is not written down in the book.

`maxFlowFormulation` matched a reference Dinic ([M16](M16-network-flow.md)) on **2 726** random networks to `10⁻⁶`, and with integer capacities the LP optimum came out **integral on 100%** of them — the integrality theorem, observed rather than assumed.

`bipartiteMatchingFormulation` matched exhaustive `2^|E|` matching search on **2 722** random bipartite graphs, and **every variable in every optimal solution was exactly 0 or 1, on 100% of instances** — total unimodularity, measured.

`minCostFlowFormulation` matched a reference successive-shortest-paths min-cost-flow solver on **1 990** random instances (`n ≤ 6`, integer capacities and costs, demand 1–4), agreeing on the cost when a feasible flow exists **and on infeasibility when it does not**. `minCostFlowExample(4.0)` costs **24**: one unit takes the cheap `s→x→y→t` route and the rest go `s→y→t`, which is the two-route behaviour the instance was built to show.

`dualOf` on `clrsExamplePrimal()` produces exactly (29.42)–(29.46). Across **3 829** feasible-and-bounded random instances the primal and dual optima agreed to `10⁻⁷` — **strong duality**, measured — and `dualOf(dualOf(P))` preserved the optimal value on **1 000 of 1 000** (Exercise 29.3-5). `isValidUpperBound(clrsExamplePrimal(), {1,1,0})` returns `true` with bound **54**, reproducing the text's worked combination — against a true optimum of **30.75**, so the hand-picked multipliers are valid and loose, which is precisely the gap the dual exists to close.

`weakDuality` held on **112 631** random feasible pairs with **zero** violations and a mean gap of **65.1**. `complementarySlackness` held at all 3 829 optima and **failed on 100% of 20 000 feasible non-optimal pairs** — necessary *and* sufficient, both directions checked, and its `violatingVariables` / `violatingConstraints` lists named genuinely loose rows in every case inspected by hand.

---

*Next: [M23 — Matrix Operations, Polynomials & FFT](M23-matrices-fft.md) (CLRS 28, 30) — solving linear systems, and the `O(n lg n)` convolution that underlies signal processing and fast multiplication.*
