# Algorithms — Unified Notes from Skiena (TADM 3e) + CLRS (4e)

**Audience:** working backend engineer targeting SDE-2 / Senior SWE interviews and competitive programming.
**Assumed background:** solid programming, basic data structures, basic C++.
**All implementation code is C++17.**

---

## How these notes are built

Two books, one set of notes. Every topic is written once, as a **Unified Understanding**, drawing from
whichever book explains it best:

| Source | What it contributes |
|---|---|
| **Skiena — The Algorithm Design Manual, 3e** | Intuition, problem modeling, pattern recognition, "which algorithm do I actually reach for", war stories, implementation pragmatics, counterexample hunting |
| **CLRS — Introduction to Algorithms, 4e** | Formal definitions, loop invariants, recurrence solving, proofs, rigorous complexity, theoretical depth |

Where the books genuinely diverge in emphasis, that is called out explicitly as
**Skiena emphasis** / **CLRS emphasis**. Anything not supported by either book is quarantined
under **### Outside / Engineering Context**.

Page references look like `[CLRS §2.1, p.17]` and `[Skiena §1.3, p.11]` so you can go back to the source fast.

---

## Module map

### Part I — Foundations

| # | Module | Primary sources |
|---|---|---|
| [M01](M01-foundations.md) | Foundations of Algorithm Design | CLRS 1–2 · Skiena 1 |
| [M02](M02-asymptotics.md) | Asymptotics & the Analysis Toolkit | CLRS 3 + App. A · Skiena 2 |
| [M03](M03-divide-conquer.md) | Divide & Conquer and Recurrences | CLRS 4 · Skiena 5 |
| [M04](M04-randomization.md) | Randomization & Probabilistic Analysis | CLRS 5 · Skiena 6 |

### Part II — Sorting and Data Structures

| # | Module | Primary sources |
|---|---|---|
| [M05](M05-sorting.md) | Sorting & Order Statistics | CLRS 6–9 · Skiena 4 |
| [M06](M06-elementary-ds.md) | Elementary Data Structures | CLRS 10 · Skiena 3.1–3.3, 3.5, 3.8 |
| [M07](M07-hashing.md) | Hashing | CLRS 11 · Skiena 3.7, 6 |
| [M08](M08-search-trees.md) | Search Trees & Augmentation | CLRS 12, 13, 17, 18 · Skiena 3.4 |
| [M09](M09-amortized.md) | Amortized Analysis | CLRS 16 |
| [M10](M10-union-find.md) | Disjoint Sets / Union-Find | CLRS 19 · Skiena 8.1.3 |

### Part III — Design Techniques

| # | Module | Primary sources |
|---|---|---|
| [M11](M11-dynamic-programming.md) | Dynamic Programming | CLRS 14 · Skiena 10 |
| [M12](M12-greedy.md) | Greedy Algorithms | CLRS 15 · Skiena (throughout) |

### Part IV — Graphs

| # | Module | Primary sources |
|---|---|---|
| [M13](M13-graph-traversal.md) | Graph Representation & Traversal | CLRS 20 · Skiena 7 |
| [M14](M14-mst.md) | Minimum Spanning Trees | CLRS 21 · Skiena 8.1 |
| [M15](M15-shortest-paths.md) | Shortest Paths | CLRS 22–23 · Skiena 8.3–8.4 |
| [M16](M16-flow-matching.md) | Network Flow & Matching | CLRS 24–25 · Skiena 8.5 |

### Part V — Search, Strings, Intractability

| # | Module | Primary sources |
|---|---|---|
| [M17](M17-combinatorial-search.md) | Combinatorial Search & Backtracking | Skiena 9 |
| [M18](M18-strings.md) | String Matching & Suffix Structures | CLRS 32 · Skiena 3.9, 21 |
| [M19](M19-np-completeness.md) | NP-Completeness & Reductions | CLRS 34 · Skiena 11 |
| [M20](M20-hard-problems.md) | Coping With Hard Problems | CLRS 35 · Skiena 12 |

### Part VI — Specialized Topics

| # | Module | Primary sources |
|---|---|---|
| [M21](M21-number-theory.md) | Number-Theoretic Algorithms | CLRS 31 |
| [M22](M22-linear-programming.md) | Linear Programming | CLRS 29 · Skiena 13.6 |
| [M23](M23-matrix-fft.md) | Matrix Operations, Polynomials & FFT | CLRS 28, 30 |
| [M24](M24-parallel-online.md) | Parallel & Online Algorithms | CLRS 26–27 |
| [M25](M25-ml-algorithms.md) | Machine-Learning Algorithms | CLRS 33 |
| [M26](M26-geometry-catalog.md) | Geometry & the Algorithm Catalog | Skiena 13, Part II |

### Part VII — Revision

| # | Module | |
|---|---|---|
| [M27](M27-cheatsheet.md) | Master Cheat Sheet & Recognition Playbook | cross-module |

---

## CLRS ↔ Skiena crosswalk

Use this when you want to read the *books* rather than the notes, and want the matching chapter in the other book.

| Topic | CLRS 4e | Skiena 3e |
|---|---|---|
| What is an algorithm; correctness | Ch. 1, §2.1 | Ch. 1 |
| Counterexamples, heuristics vs algorithms | — (implicit) | §1.1–1.3 |
| Modeling with combinatorial objects | — | §1.5 |
| RAM model | §2.2 | §2.1 |
| Loop invariants | §2.1 | §1.4 (as induction) |
| Asymptotic notation | Ch. 3 | §2.2–2.4 |
| Summations, logarithms | App. A | §2.6–2.8 |
| Divide & conquer, recurrences | Ch. 4 | Ch. 5 |
| Master theorem | §4.5 | §5.5 |
| Randomized analysis, indicator RVs | Ch. 5 | §4.6.2, Ch. 6 |
| Heaps / priority queues | §6 | §3.5, §4.3 |
| Quicksort | Ch. 7 | §4.6 |
| Linear-time sorting, lower bound | Ch. 8 | §4.7 |
| Selection / medians | Ch. 9 | §17.3 (catalog) |
| Arrays, lists, stacks, queues | Ch. 10 | §3.1–3.2 |
| Hashing | Ch. 11 | §3.7, Ch. 6 |
| BSTs | Ch. 12 | §3.4 |
| Balanced trees | Ch. 13 (RB) | §3.4.3 (survey) |
| Augmenting structures | Ch. 17 | §3.8 |
| B-trees | Ch. 18 | §3.4.3 (mention) |
| Dynamic programming | Ch. 14 | Ch. 10 |
| Greedy | Ch. 15 | §1.2, Ch. 8 (MST) |
| Amortized analysis | Ch. 16 | §3.1.1 (dynamic arrays) |
| Union-Find | Ch. 19 | §8.1.3 |
| BFS/DFS, topological sort, SCC | Ch. 20 | Ch. 7 |
| MST | Ch. 21 | §8.1–8.2 |
| Shortest paths | Ch. 22–23 | §8.3–8.4 |
| Network flow | Ch. 24–25 | §8.5 |
| Backtracking / branch & bound | — | Ch. 9 |
| String matching | Ch. 32 | §3.9, Ch. 21 |
| NP-completeness | Ch. 34 | Ch. 11 |
| Approximation / heuristics | Ch. 35 | Ch. 12 |
| Number theory, RSA | Ch. 31 | §16.x (catalog) |
| Linear programming | Ch. 29 | §13.6 |
| FFT, matrix ops | Ch. 28, 30 | §16.x (catalog) |
| Parallel, online | Ch. 26–27 | — |
| Machine learning | Ch. 33 | — |
| Computational geometry | — | Ch. 20 (catalog) |
| "How to design algorithms" | — | Ch. 13 |

**Notable coverage gaps to be aware of:**

- **Only in CLRS:** amortized analysis as a formal technique, red-black trees in full, B-trees, van-Emde-Boas-style augmentation, matrix operations, linear programming internals, FFT, number theory / RSA, parallel algorithms, online algorithms, ML algorithms, the formal Cook–Levin machinery.
- **Only in Skiena:** counterexample-hunting methodology, problem modeling, backtracking as a first-class technique, simulated annealing and local search, the war stories, the 75-problem catalog, and the "how to design algorithms" decision procedure.

---

## Suggested study order

**If you are preparing for interviews (12–14 weeks):**

1. M02 → M03 (analysis machinery — everything else depends on it)
2. M05 → M06 → M07 → M08 → M09 → M10 (data structures, the interview bread and butter)
3. M11 → M12 (DP and greedy — the highest-yield technique modules)
4. M13 → M14 → M15 (graphs)
5. M18 (strings), M17 (backtracking)
6. M16 (flow), M19 (NP-completeness) — appear in senior interviews as "is this even tractable?"
7. M27 (cheat sheet) — revise weekly from here once modules are done
8. M01, M04, M20–M26 as depth/breadth passes

**If you are studying for mastery:** front to back.

---

## How to revise

Each module ends with three revision aids:

- **Chapter-in-one-page** — the compressed version.
- **Recognition table** — problem clue → technique.
- **Self-test questions** — if you can answer these without the notes, the module is done.

Do not re-read modules linearly. Re-read the recognition tables, then attempt the self-test,
then only open the section you failed.
