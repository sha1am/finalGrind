# Variable-naming pass — status

Goal: every C++ identifier in every module carries a name an interviewer would
respect. Conventional names are kept (`i, j, k` indices; `n, m` sizes;
`u, v` graph vertices; `lo, hi, mid`; `A, B, C` in a matrix-multiply context);
cryptic ones are renamed.

Renames are applied to **code only** — the `// 1  x = L.head` pseudocode
citations in comments are left intact, so each block still documents its
correspondence with CLRS/Skiena.

## Done (compiles clean under `g++ -std=c++17 -Wall -Wextra`)

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

M08's body and appendix were additionally re-verified behaviourally after the
rename (randomized B-tree / red-black / order-statistic invariant checks) because
the rotation and B-tree split were rewritten by hand rather than mechanically.

## Remaining

| Module | Identifiers to fix |
|---|---|
| M12 greedy | `a, t, x, ch, nd, idx, q, Q, h` |
| M13 traversal | `g, r, stk, q, c, d, pi` (keep `u`/`v`) |
| M14 MST | `e, g, r, x, b, a, c, p_` |
| M15 shortest paths | `r` (the `PathResult`), `d`, `g`, `pi`, `x`, `a` |

Then: re-run the whole-tree compile + link check, rebuild the zip, re-sync to the project.

## Tooling (session scratchpad, `bin/`)

- `rename.py FILE < map.json` — renames inside ```cpp blocks, code only, never in
  comments or string literals. Reports per-rule hit counts and flags no-op rules.
- `compile_md.py FILE` — extracts top-level cpp fences into a body TU and an
  appendix TU, compiles both with `-fsyntax-only`.
- `links.py DIR` — validates every markdown link and reports duplicate anchors.
