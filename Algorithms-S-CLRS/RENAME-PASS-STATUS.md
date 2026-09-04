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
| M12 | `a`→`activities`/`jobs`, `idx`→`order`, `q`/`Q`→`ready`, `x`/`y`→`smallest`/`secondSmallest`, `nd`→`current`, `ch`/`fx`/`fy`→`ch`/`leftFreq`/`rightFreq`, `req`→`requests`, `C`→`frequencies`, `h`→`tree` |
| M13 | `g`/`g_`→`graph`/`graph_`, `s`→`source`, `r`→`result`/`finished`, `stk`→`pending`, `q`/`Q`→`frontier`/`ready`, `pi`→`parent`, `d`/`f`→`discovery`/`finish`, `out`/`out_`→`result`/`result_`, `c`→`componentId` |
| M14 | `g`→`graph`, `r`→`result`, `e`→`allEdges`/`link`/`candidate`, `x`→`edge`, `ds`→`components`, `p_`→`parent_`, `a`/`b` in union-find→`rootX`/`rootY`, `ra`/`rb`→`rootX`/`rootY`, `ed`→`edge`, `h`→`negated`, `Q`→`frontier`, `k`→`bestKey` |
| M15 | `g`→`graph`, `s`→`source`, `r`→`result`, `d`→`dist`, `pi`→`parent`, `x`→`at`, `W`→`weight`, `D`→`distance`, `h`→`potential`, `gp`/`gh`/`bf`→`augmented`/`reweighted`/`bellman`, `du`→`knownDist`, `pq`→`frontier`, `cs`→`constraints`, `v0`→`superSource` |

M08's body and appendix were additionally re-verified behaviourally after the
rename (randomized B-tree / red-black / order-statistic invariant checks) because
the rotation and B-tree split were rewritten by hand rather than mechanically.

## Remaining

**None.** M01–M20 have all had the pass.

M12–M15 were additionally re-verified behaviourally after the rename, because
M14's two union-find classes were rewritten by hand rather than mechanically
(`find`'s path-compression loop and `unite`'s union-by-rank direction both
change shape when `a`/`b` become `rootX`/`rootY`, and getting the attachment
direction backwards is silent — it still produces a correct MST, just a slower
one). The checks: greedy activity selection against a `2ⁿ` search on 3 000
instances; Huffman encode/decode round-trip on 500 alphabets; Kruskal, Prim
(heap), Prim (dense) and Borůvka agreeing on the MST weight over 3 000 random
graphs; and Dijkstra, Bellman–Ford and Floyd–Warshall agreeing on every
source-to-`v` distance over 2 000 random digraphs. Zero disagreements.

Then: re-run the whole-tree compile + link check, rebuild the zip, re-sync to the project.

## Tooling (session scratchpad, `bin/`)

- `rename.py FILE < map.json` — renames inside ```cpp blocks, code only, never in
  comments or string literals. Reports per-rule hit counts and flags no-op rules.
- `compile_md.py FILE` — extracts top-level cpp fences into a body TU and an
  appendix TU, compiles both with `-fsyntax-only`.
- `links.py DIR` — validates every markdown link and reports duplicate anchors.
