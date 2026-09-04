# Algorithms Notes — Skiena (TADM 3e) + CLRS (4e), with C++ from Weiss (4e)

Start at **[INDEX.md](INDEX.md)** — module map, CLRS↔Skiena crosswalk, study order, and the C++ conventions used throughout.

---

## What is in this archive

23 markdown files: `INDEX.md`, `README.md`, `RENAME-PASS-STATUS.md`, and modules **`M01`–`M20`**. Every module is a unified synthesis of Skiena and CLRS on one topic, with **all implementation code in C++17**.

**Coverage as of this build:** foundations and asymptotics, divide & conquer, randomization, sorting, every core data structure (lists, hashing, search trees, B-trees, augmentation), amortized analysis, union-find, dynamic programming, greedy, the full graph sequence (traversal, MST, shortest paths, network flow and matching), backtracking and branch-and-bound, string matching and suffix structures, `NP`-completeness, and approximation algorithms and heuristic search.

**Still to be written:** M21–M27 — number theory, linear programming, FFT and matrix operations, parallel and online algorithms, machine learning, computational geometry, and the master cheat sheet. The INDEX carries the full roadmap with status markers, and every forward reference in the notes points at it rather than at a missing file.

---

## Verification state

| | |
|---|---|
| **Every code block compiles** | **40 translation units** — a body TU and an appendix TU per module — all verified under `g++ -std=c++17 -Wall -Wextra`. Illustrative fragments were rewritten into real compilable functions rather than left as snippets. |
| **Every algorithm is behaviourally checked** | Each implementation is run against a brute-force oracle on randomized inputs, and the result is recorded in the `*Verified:*` line beneath it — including the counts, the worst observed approximation ratios, and the bugs the testing actually caught. |
| **All links resolve** | **703** internal links checked, **0 broken**. |
| **Links under every pseudocode block** | **149** `→ C++ implementation:` links connect each pseudocode block in the notes to a runnable, heavily commented translation. |
| **`using namespace std;` everywhere** | Every block assumes the prelude `#include <bits/stdc++.h>` + `using namespace std;`. No `std::` prefixes anywhere. |
| **Meaningful identifiers throughout** | Every module has had the variable-naming pass — see [RENAME-PASS-STATUS.md](RENAME-PASS-STATUS.md). Conventional names are kept (`i, j, k`, `n, m`, `u, v`, `lo, hi, mid`); cryptic ones are not. Pseudocode citations in comments are left intact, so each block still documents its correspondence with the book. |
| **Practice sections** | Every module has a *Practice — where to drill this module* table: specific problems by number and title, plus CSES and Codeforces tag pages. **Every LeetCode slug was verified against live search**, not written from memory. |
| **C++ Toolkit per module** | A primer on the C++ features that module's code leans on, grounded in Mark Allen Weiss, *Data Structures and Algorithm Analysis in C++*, 4th ed., cited by section and page. |

### Per-module code coverage

| Module | `→ C++ implementation:` links | appendix code blocks |
|---|---|---|
| M01 Foundations | 6 | 6 |
| M02 Asymptotics | 6 | 6 |
| M03 Divide & Conquer | 5 | 5 |
| M04 Randomization | 5 | 5 |
| M05 Sorting | 10 | 11 |
| M06 Elementary Data Structures | 3 | 3 |
| M07 Hashing | 9 | 7 |
| M08 Search Trees | 17 | 18 |
| M09 Amortized Analysis | 3 | 3 |
| M10 Union-Find | 5 | 7 |
| M11 Dynamic Programming | 11 | 11 |
| M12 Greedy | 2 | 2 |
| M13 Graph Traversal | 4 | 5 |
| M14 Minimum Spanning Trees | 3 | 4 |
| M15 Shortest Paths | 6 | 7 |
| M16 Network Flow & Matching | 12 | 14 |
| M17 Backtracking & Branch and Bound | 9 | 11 |
| M18 String Matching & Suffix Structures | 10 | 12 |
| M19 NP-Completeness & Reductions | 10 | 12 |
| M20 Coping With Hard Problems | 13 | 13 |
| **Total** | **149** | **162** |

---

## Body code vs appendix code

They are deliberately different, and comparing them is the point:

- **Body implementations** are the *practical* version — what you would actually write, 0-indexed, using the STL where it helps.
- **Appendix implementations** are *literal translations of the pseudocode*, line for line, keeping the book's indexing and structure, with comments explaining both the algorithm and the C++ decision behind each line.

Where the two differ in behaviour, the notes say so explicitly — that gap is usually where the interesting engineering lives.

---

## How to use these notes

1. Read a module's **Big Idea** and **What You Should Be Able To Do**.
2. Work through the body, following each `→ C++ implementation:` link when you want to see the pseudocode become code.
3. Read the **C++ Toolkit** once per module — it explains the language features that module's code depends on.
4. Drill the **Practice** table.
5. Revise from the **One-Page Recall** section at the end, not from the whole module. Re-read the **Recognition Patterns** table, attempt the self-test, and only then open the section you failed.

---

## Sources

| Book | Used for |
|---|---|
| Steven S. Skiena, *The Algorithm Design Manual*, 3rd ed. | intuition, modelling, pattern recognition, war stories, implementation pragmatics, counterexample hunting |
| Cormen, Leiserson, Rivest, Stein, *Introduction to Algorithms*, 4th ed. | formal definitions, invariants, proofs, recurrences, rigorous complexity |
| Mark Allen Weiss, *Data Structures and Algorithm Analysis in C++*, 4th ed. | **the C++ language teaching only** — cited as `[Weiss §1.5.3, p.25]` |

Citations look like `[CLRS §2.1, p.17]` and `[Skiena §1.3, p.11]` so you can go back to the source quickly. Anything not supported by either algorithms book is quarantined under an explicit **Outside / Engineering Context** heading.
