# Variable-naming pass — status

**Status: complete. M01–M27, all 27 modules.**
Last audited and re-verified: **2026-09-14**.

Goal: every C++ identifier in every module carries a name an interviewer would
respect.

## The standard

**Conventional names are kept.** A short name that is *the* name for its role in
its domain is clearer than a long one, not worse:

| kept | role |
|---|---|
| `i, j, k` | loop indices |
| `n, m` | sizes / dimensions |
| `u, v` | graph vertices |
| `lo, hi, mid` | binary-search bounds |
| `A, B, C` | matrices, in a matrix-multiply context |
| `r, c` | row and column of a grid |
| `p, q` | points in geometry; the two primes in RSA |
| `t, T` | time step and horizon, in online and gradient-descent analysis |
| `d` | dimension, or a gcd |
| `x, y` | coordinates, and the Bézout coefficients |

**Cryptic names are renamed.** A single letter that stands for nothing, or an
abbreviation only the author can expand, becomes a word.

**Renames are applied to code only.** The `// 1  x = L.head` pseudocode citations
in comments are left intact, so each block still documents its correspondence
with CLRS/Skiena.

**Appendix code is exempt where the book's names are the point.** Appendix blocks
are literal translations of pseudocode; where CLRS names a parameter `p`, `q` or
`r` (`P-MERGE`, `P-MERGE-SORT`), the translation keeps it, because the
line-for-line correspondence is the reason the appendix exists. Body code — the
practical version — does not get that exemption.

---

## M01–M15 — retroactive rename pass

These modules were written before the standard was settled and were renamed
afterwards.

| Module | Highlights of the renaming |
|---|---|
| M01 | `nearestNeighborTour`, `closestPairTour`, `dist`→`euclidean`, 1-indexed merge/insertion sort |
| M02 | selection sort, string match, matrix multiply, fast power, harmonic sums |
| M03 | binary search, max-subarray, closest pair, bignum, Karatsuba, Strassen |
| M04 | hiring problem, permute-by-sorting, reservoir sampling, `randomInt` |
| M05 | heaps, quicksort/partition, counting/radix/bucket sort, `randomizedSelect` |
| M06 | list nodes, sentinel vs plain list |
| M07 | direct-address / chained / open-addressing tables, universal hash, Rabin–Karp, Bloom filter |
| M08 | BST + red-black + order-statistic + interval + B-tree: `x/y/z/w/p/c/n/t` → `node`, `replacement`, `target`, `sibling`, `parent`, `children`, `keyCount`, `MinDegree`, `pivot`/`newParent`, `fullChild`/`newSibling` |
| M09 | `s_`→`stack_`, `a_`→`bits_`, `v_`→`elements_`, `n_`→`count_`, merge helpers |
| M10 | `p_`→`parent_`, `sets_`→`componentCount_`, `rx/ry`→`rootX/rootY`, `off_`→`offsetToParent_`, offline LCA / offline minimum |
| M11 | DP tables named for what they hold: `r`→`bestRevenue`, `m`→`minCost`, `s`→`splitAt`, `c`→`lcsLen`, `D`→`dist`, `L`→`lisLenEndingAt`, `T`→`reachable`, `M`→`minMaxSum`/`chart`, `e/w/r`→`expectedCost`/`weight`/`rootCandidate` |
| M12 | `a`→`activities`/`jobs`, `idx`→`order`, `q`/`Q`→`ready`, `x`/`y`→`smallest`/`secondSmallest`, `nd`→`current`, `ch`/`fx`/`fy`→`ch`/`leftFreq`/`rightFreq`, `req`→`requests`, `C`→`frequencies`, `h`→`tree` |
| M13 | `g`/`g_`→`graph`/`graph_`, `s`→`source`, `r`→`result`/`finished`, `stk`→`pending`, `q`/`Q`→`frontier`/`ready`, `pi`→`parent`, `d`/`f`→`discovery`/`finish`, `out`/`out_`→`result`/`result_`, `c`→`componentId` |
| M14 | `g`→`graph`, `r`→`result`, `e`→`allEdges`/`link`/`candidate`, `x`→`edge`, `ds`→`components`, `p_`→`parent_`, `a`/`b` in union-find→`rootX`/`rootY`, `ra`/`rb`→`rootX`/`rootY`, `ed`→`edge`, `h`→`negated`, `Q`→`frontier`, `k`→`bestKey` |
| M15 | `g`→`graph`, `s`→`source`, `r`→`result`, `d`→`dist`, `pi`→`parent`, `x`→`at`, `W`→`weight`, `D`→`distance`, `h`→`potential`, `gp`/`gh`/`bf`→`augmented`/`reweighted`/`bellman`, `du`→`knownDist`, `pq`→`frontier`, `cs`→`constraints`, `v0`→`superSource` |

M08's body and appendix were additionally re-verified behaviourally after the
rename (randomized B-tree / red-black / order-statistic invariant checks) because
the rotation and B-tree split were rewritten by hand rather than mechanically.

M12–M15 were re-verified behaviourally too, because M14's two union-find classes
were rewritten by hand (`find`'s path-compression loop and `unite`'s
union-by-rank direction both change shape when `a`/`b` become `rootX`/`rootY`,
and getting the attachment direction backwards is silent — it still produces a
correct MST, just a slower one). The checks: greedy activity selection against a
`2ⁿ` search on 3 000 instances; Huffman encode/decode round-trip on 500
alphabets; Kruskal, Prim (heap), Prim (dense) and Borůvka agreeing on the MST
weight over 3 000 random graphs; and Dijkstra, Bellman–Ford and Floyd–Warshall
agreeing on every source-to-`v` distance over 2 000 random digraphs. Zero
disagreements.

---

## M16–M27 — written to the standard, then audited

These modules were written after the standard was settled, so there was no bulk
rename to do. Every one was audited identifier by identifier on 2026-09-14: all
declarations were extracted from every ```cpp block, and each name of two
characters or fewer was read in context and judged against the table above.

**Three names failed the audit and were renamed:**

| Module | Rename | Why it failed |
|---|---|---|
| M22 | `t_` → `tableau_` (35 code sites, plus one comment) | A one-letter member on the simplex class. `t` stands for "tableau" and for nothing else in the module, so the word costs nothing and the letter explains nothing. The comment above `pivot()` described the member by name and was updated with it — the code-only rule protects *pseudocode citations*, not a comment naming the code's own field. |
| M24 | `r` → `row` in the `block` lambda of the parallel matrix multiply (2 sites) | Paired with `col` in the same parameter list. Half-abbreviated is worse than either choice made consistently. |
| M25 | `r` → `radius`, `l` → `lipschitz` in `theoremStepSize`, `theoremErrorBound`, `iterationsForAccuracy` (14 sites) | Theorem 33.8 is stated with **`R`** and **`L`**; lowercased into parameters they read as a generic pair, and the adjacent comment `eta = R/(L sqrt T)` no longer visibly referred to them. |

**Everything else in M16–M27 was accepted, with the reason recorded:**

| Module | Short names kept | Why they are the right names |
|---|---|---|
| M16 | `at`, `to`, `id`, `l` / `r` | `at` is the current vertex and `to` an edge's head — words, not abbreviations. `l`/`r` are the two sides of a bipartite graph, anchored by `matchOfLeft_` / `matchOfRight_`, and are to bipartite matching what `u`/`v` are to graphs. |
| M17 | `at`, `r` / `c` | `at` is the current search state; `r`/`c` are Sudoku grid coordinates. |
| M18 | `at`, `q` | `at` is the position in the automaton or trie; `q` is CLRS's own state variable in `KMP-MATCHER`. |
| M19 | `z1`, `z2` | Literals of a 3-CNF clause, named exactly as the reduction's comment writes them. |
| M20 | `at`, `d`, `s`, `t` | `at` is the current vertex; `d` a gcd; `s` a sample index; `t` a swap temporary. |
| M21 | `p`, `q`, `d`, `m1`/`m2`, `r1`/`r2`, `x0` | Standard number-theory notation: the RSA primes, the private exponent, the CRT moduli and residues, the base solution. Renaming these would make the code *harder* to check against the book. |
| M22 | `lp` | The linear program itself — a two-letter abbreviation everyone in the subject reads instantly. |
| M23 | `lu`, `xs`, `ys` | The LU factor, and the sample vectors of a polynomial. |
| M24 | `p`, `q`, `r`, `p1..p3`, `q1..q3`, `r1`/`r2` | CLRS's `P-MERGE` and `P-MERGE-SORT` parameter names, preserved **in the appendix only**, where line-for-line correspondence is the point. |
| M25 | `t`, `T`, `d` | The time step, the horizon and the dimension — the notation of CLRS 33 and of the online-learning literature generally. |
| M26 | `p`, `p1..p4`, `ax`/`bx`/`cx`, `a2`/`b2`/`c2` | Points, and the coordinate and squared-length components of the geometric predicates. The determinant expansions are checkable against the book only while the names match it. |
| M27 | — | Cross-module; its six blocks reuse the names of the modules they summarize. |

---

## Verification after the pass

Re-run on 2026-09-14, after the three renames above:

| Check | Result |
|---|---|
| Whole-tree compile | **53 translation units** (a body TU and an appendix TU per module, M27 body only) — all clean under `g++ -std=c++17 -Wall -Wextra -fsyntax-only`. **0 errors.** **2 warnings, both deliberate:** `danger()` in M09 holds a pointer across a reallocation (`-Wunused-variable`) and `theDiscardedFutureTrap()` in M24 drops an `async` future (`-Wunused-result`) — in both the warning *is* the lesson the example teaches. A third, `-Wcomment` on M08's `leftRotate` diagram, was real: two art lines ended in `\`, so each silently swallowed the line below it. That diagram is now a block comment. |
| Link and anchor check | **791 internal links** and every heading anchor they target — **0 broken**. The **361** external links (LeetCode, CSES, Codeforces) are not checked by the tool. |
| `*Verified:*` records | **183** across the 27 modules. |
| Project re-sync | Every file changed by this pass was written back to the `Algorithms-Skiena-CLRS` project, so the project copies match the local folder. |

The four edited modules (M08, M22, M24, M25) were recompiled individually
immediately after each edit, before the whole-tree run.

## Tooling (session scratchpad, `bin/`)

- `rename.py FILE [LO HI] < map.json` — renames inside ```cpp blocks, code only,
  never in comments or string literals; optional line range. Reports per-rule hit
  counts and flags no-op rules.
- `compile_md.py FILE OUTDIR` — extracts top-level cpp fences into a body TU and
  an appendix TU, compiles both with `-fsyntax-only -Wall -Wextra`.
- `audit_names.py FILE...` — extracts every declared identifier from the cpp
  blocks and flags any of two characters or fewer that is not on the kept list,
  with occurrence counts. This is what produced the M16–M27 audit above.
- `links.py DIR` — validates every markdown link against GitHub's heading-slug
  rules and reports duplicate anchors.

> **Note on duplicate anchors.** `links.py` reports 119 duplicate headings
> (`#problem`, `#c-implementation`, `#recognition-pattern` and friends recur
> within a module by design). These are not broken links: GitHub disambiguates
> them by appending `-1`, `-2`, … in document order, and every link in the
> archive already targets the correct suffixed form. The count is informational.
