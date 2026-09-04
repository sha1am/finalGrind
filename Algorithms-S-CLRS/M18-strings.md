# Module 18 — String Matching and Suffix Structures

**Sources:** CLRS 4e ch. 32 (String Matching) · Skiena 3e §3.9 (War Story: String 'em Up), §15.3 (Suffix Trees and Arrays), §21.3 (String Matching), §21.4 (Approximate String Matching), §6.7 (Rabin–Karp, covered in [M07](M07-hashing.md))

---

## Big Idea

**The problem.** Text `T[1:n]`, pattern `P[1:m]` with `m ≤ n`, both over an alphabet `Σ`. `P` **occurs with shift `s`** if `T[s+1 : s+m] = P[1:m]`. Find **all** valid shifts.

**The organising fact of the whole chapter** is that every algorithm after the first is *preprocess, then match*, and they trade the two against each other:

| Algorithm | Preprocessing | Matching | What it preprocesses |
|---|---|---|---|
| Naive | `0` | `O((n−m+1)m)` | nothing |
| Rabin–Karp | `Θ(m)` | `O((n−m+1)m)` worst, `O(n+m)` expected | one hash of `P` |
| Finite automaton | `O(m·\|Σ\|)` | `Θ(n)` | a full transition table `δ` |
| **Knuth–Morris–Pratt** | **`Θ(m)`** | **`Θ(n)`** | the prefix function `π` |
| Suffix array | `O(n lg n)` on the **text** | `O(m lg n + km)` | the text, not the pattern |

**Read the last row again — it is the one people miss.** The first four preprocess the **pattern** and then stream the text; the suffix array preprocesses the **text** and then answers *any* pattern query. That is the whole distinction between "find this word once" and "build a search engine", and it is the first question to ask about any string problem: *what stays fixed, the pattern or the text?*

**Why the naive algorithm is bad, in one sentence.** CLRS:

> *"The naive string-matcher is inefficient because it entirely ignores information gained about the text for one value of `s` when it considers other values of `s`."*

If `P = aaab` and shift 0 fails only at the last character, we already know `T[4] ≠ b` — and that rules out shifts 1, 2 and 3 without touching the text again. **Every good algorithm in this module is a different way of not forgetting.**

| algorithm | what it remembers |
|---|---|
| Rabin–Karp | a **rolling hash**: the window's value, updated in `O(1)` |
| finite automaton | a **state**: how much of `P` currently matches a suffix of what has been read |
| KMP | the **prefix function**: how far to fall back on a mismatch, without re-reading the text |
| Boyer–Moore | the **mismatched character**: which lets it skip forward without reading at all |
| suffix array/tree | **every suffix of the text, sorted** |

**Remember months later:** *naive is `O(nm)` and usually fine for short patterns. Rabin–Karp turns equality into a rolling hash and is the tool when you need many patterns or 2-D. KMP's `π[q]` = "length of the longest proper prefix of `P` that is also a suffix of `P[1:q]`", and the text pointer **never moves backwards** — that is why it is `Θ(n)`. Boyer–Moore reads right-to-left and skips, so it is sublinear in practice. Aho–Corasick is KMP with a trie, for many patterns at once. When the **text** is fixed and queried repeatedly, build a **suffix array + LCP** and everything becomes a binary search or a range minimum.*

---

## What You Should Be Able To Do After This Chapter

- State the problem precisely with the shift/prefix/suffix notation, and use `⊐` (suffix) and `⊏` (prefix) fluently.
- Explain why the naive matcher is `Θ((n−m+1)m)` worst case and yet `O(n)` on random text.
- Derive Rabin–Karp's rolling-hash recurrence and say exactly why `t_s ≡ p (mod q)` is a *filter*, not a *decision*.
- Analyse Rabin–Karp's expected time as `O(n) + O(m(v + n/q))` and say what each term is.
- Define the **suffix function** `σ` and build a string-matching automaton; know its `Θ(n)` match time and `O(m|Σ|)` build cost.
- Define the **prefix function** `π`, compute it, and prove `COMPUTE-PREFIX-FUNCTION` is `Θ(m)` by the aggregate method ([M09](M09-amortized.md)).
- Write `KMP-MATCHER` from memory and prove `Θ(n)` by the same amortised argument.
- Explain the relationship between `π` and `δ`: `π` is `δ` with the `|Σ|` factor squeezed out and paid back amortised.
- Write the **Z-algorithm** and say when you would reach for it instead of KMP.
- Describe **Boyer–Moore**'s two heuristics and why it can be `O(n/m)`.
- Build a **trie**, and extend it to **Aho–Corasick** by adding suffix links — and see that the suffix links *are* KMP's `π`.
- Define the **suffix array** and **LCP array**, build them in `O(n lg n)` (doubling + radix sort) and `O(n)` (Kasai), and use them for pattern search, longest repeated substring, longest common substring, and counting distinct substrings.
- Say what a **suffix tree** buys over a suffix array and why you would still usually build the array.
- Recount Skiena's SBH war story and its four data structures, and say what the lesson is.

---

## Part 1 — Notation and the Naive Algorithm (CLRS 32.1)

### Notation you must be fluent in

- `Σ*` — all finite strings over `Σ`; `ε` is the empty string; `|x|` is length; `xy` is concatenation.
- `w ⊏ x` — `w` is a **prefix** of `x` (`x = wy` for some `y`). `w ⊐ x` — `w` is a **suffix** of `x` (`x = yw`).
- `P[:k]` — the `k`-character prefix `P[1:k]`. So `P[:0] = ε` and `P[:m] = P`.
- The problem restated: find all `s` with `P ⊐ T[: s+m]`.

**Lemma 32.1 (overlapping-suffix lemma).** If `x ⊐ z` and `y ⊐ z`, then: `|x| ≤ |y| ⟹ x ⊐ y`; `|x| ≥ |y| ⟹ y ⊐ x`; `|x| = |y| ⟹ x = y`.

**This tiny lemma is load-bearing.** *Two suffixes of the same string are nested.* It is what makes "the set of prefixes of `P` that are suffixes of `P[:q]`" a **chain** rather than an arbitrary set — and that chain is exactly what iterating `π` walks down (Lemma 32.5). Every correctness proof in §32.3 and §32.4 leans on it.

### The naive matcher

```
NAIVE-STRING-MATCHER(T, P, n, m)
1  for s = 0 to n − m
2      if P[1:m] == T[s+1 : s+m]
3          print "Pattern occurs with shift" s
```

→ **C++ implementation:** [A1 NAIVE-STRING-MATCHER](#a1-naive-string-matcher)

**Complexity `O((n−m+1)m)`, and the bound is tight:** `T = aⁿ`, `P = aᵐ` forces every shift to compare all `m` characters. With `m = ⌊n/2⌋` that is `Θ(n²)`.

**But it is `O(n)` on random text (Ex. 32.1-3).** With a `d`-ary alphabet, the expected number of comparisons per shift is `(1 − d^{−m})/(1 − d^{−1}) ≤ 2` — because a mismatch is found after about `1/(1 − 1/d)` characters. **For random-ish text and short patterns, naive is fine, and Skiena says so plainly:**

> *"For very short patterns (say `m ≤ 10`), you can't hope to beat this simple algorithm by much, so you shouldn't try."*

**Know both facts.** Quoting the `Θ(nm)` worst case without the "usually linear" caveat is as misleading as the reverse.

---

## Part 2 — Rabin–Karp (CLRS 32.2)

**The idea: replace string comparison with number comparison.** Read each length-`m` window as a base-`d` number. Then `t_s = p` **iff** the window matches — one integer comparison instead of `m` character comparisons.

**Computing all the windows in `Θ(n)`.** Horner's rule gives `p` and `t₀` in `Θ(m)`. Then each next window is `O(1)`:

```
t_{s+1} = d·(t_s − T[s+1]·h) + T[s+m+1]        where h = d^{m−1}                (32.1)
```

*"Subtracting `10^{m−1}·T[s+1]` removes the high-order digit, multiplying by 10 shifts left, and adding `T[s+m+1]` brings in the low-order digit."* With `m = 5`, `t_s = 31415`, dropping `3` and adding `2`: `10·(31415 − 30000) + 2 = 14152`.

**The problem, and the fix.** For real alphabets these numbers overflow. So work **modulo a prime `q`**:

```
t_{s+1} = (d·(t_s − T[s+1]·h) + T[s+m+1]) mod q                                (32.2)
```

**And now the comparison is only a filter.** `t_s ≡ p (mod q)` does **not** imply `t_s = p` — that is a **spurious hit**. But `t_s ≢ p (mod q)` *does* imply a mismatch. So:

> *"you can use the test `t_s ≡ p (mod q)` as a fast heuristic test to rule out invalid shifts."*

On a hit, verify explicitly in `O(m)`.

```
RABIN-KARP-MATCHER(T, P, n, m, d, q)
 1  h = d^{m−1} mod q
 2  p = 0
 3  t_0 = 0
 4  for i = 1 to m                             // preprocessing
 5      p   = (d·p   + P[i]) mod q
 6      t_0 = (d·t_0 + T[i]) mod q
 7  for s = 0 to n − m                         // matching
 8      if p == t_s                            // a hit?
 9          if P[1:m] == T[s+1 : s+m]          // valid shift?
10              print "Pattern occurs with shift" s
11      if s < n − m
12          t_{s+1} = (d·(t_s − T[s+1]·h) + T[s+m+1]) mod q
```

→ **C++ implementation:** [A2 RABIN-KARP-MATCHER](#a2-rabin-karp-matcher)

**Complexity.** `Θ(m)` preprocessing; `Θ((n−m+1)m)` matching in the worst case (`P = aᵐ`, `T = aⁿ` — every shift is valid and every one is verified). **Expected:**

```
O(n) + O(m·(v + n/q))
```

where `v` is the number of *valid* shifts and `n/q` bounds the expected spurious hits (modelling `mod q` as a random map into `Z_q`). **With `v = O(1)` and `q > m`, this is `O(n + m)`.**

**Why Rabin–Karp is worth knowing even though KMP is better in the worst case.**

1. **It generalises where KMP does not.** Ex. 32.2-2: search for **any of `k` patterns** — hash all of them into a set, hash the window once, one lookup. Ex. 32.2-3: **2-D pattern matching** — hash each row, then run Rabin–Karp on the sequence of row-hashes. Neither has a natural KMP analogue.
2. **It is the basis of `O(n lg n)` "longest duplicate substring"** — binary search the length, use rolling hashes to detect a repeat.
3. **The same trick verifies file equality** (Ex. 32.2-4): evaluate both files as polynomials at a random point mod a large prime; if they differ, they agree with probability `< 1/1000`. That is **fingerprinting**, and it is what `rsync` and content-addressed storage do.

> ### Outside / Engineering Context — anti-hash tests
> A **fixed** modulus and base make Rabin–Karp deterministic and therefore *attackable*: a competitive-programming judge can include a test where thousands of windows collide, forcing the `Θ(nm)` worst case. The standard defences are a **random base chosen at run time**, a **large prime modulus** (`~2⁶¹−1` with `__int128` multiplication), or **double hashing** with two independent moduli. This is the same adversary argument as universal hashing in [M07](M07-hashing.md), and the same fix.

### C++ Implementation

```cpp
#include <chrono>
#include <random>
#include <string>
#include <vector>

// A PREFIX-HASH TABLE, which is Rabin-Karp turned inside out: instead of rolling
// one window across the text, precompute prefix hashes once and then answer
// "hash of T[from, to)" in O(1) for ANY substring. That is strictly more useful
// -- it gives substring EQUALITY in O(1), which is what the binary-search
// solutions to "longest duplicate substring" and "longest common prefix of two
// suffixes" are built on.
//
// The modulus is 2^61 - 1, a Mersenne prime, so reduction is a shift and an add
// rather than a division. Multiplication needs __int128 to avoid overflow.
class RollingHash {
public:
    // The BASE IS RANDOM, chosen once per process. A fixed base is deterministic
    // and therefore attackable: an adversary (or a competitive-programming judge)
    // can construct thousands of colliding windows and force the Theta(nm) worst
    // case. Same argument, and same fix, as universal hashing in M07.
    explicit RollingHash(const string& text) {
        static mt19937_64 rng(
            (unsigned long long)chrono::steady_clock::now().time_since_epoch().count());
        base_ = uniform_int_distribution<unsigned long long>(256, MOD - 2)(rng);

        const size_t n = text.size();
        prefixHash_.assign(n + 1, 0);
        basePower_.assign(n + 1, 1);
        for (size_t i = 0; i < n; ++i) {
            prefixHash_[i + 1] = add(mul(prefixHash_[i], base_), (unsigned char)text[i]);
            basePower_[i + 1]  = mul(basePower_[i], base_);
        }
    }

    // Hash of text[from, to). O(1). Note the subtraction: the prefix hash of the
    // whole thing minus the prefix before it, SHIFTED into position -- exactly
    // equation (32.1)'s "remove the high-order digit, shift, add the low-order
    // digit", done once for the whole array instead of window by window.
    unsigned long long of(size_t from, size_t to) const {
        const unsigned long long whole  = prefixHash_[to];
        const unsigned long long before = mul(prefixHash_[from], basePower_[to - from]);
        return add(whole, MOD - before);
    }

private:
    static const unsigned long long MOD = (1ULL << 61) - 1;   // Mersenne prime
    unsigned long long base_ = 0;
    vector<unsigned long long> prefixHash_, basePower_;

    static unsigned long long add(unsigned long long a, unsigned long long b) {
        a += b;
        return a >= MOD ? a - MOD : a;
    }
    // Reduction mod 2^61 - 1 without a division: split the 122-bit product into
    // its high and low 61-bit halves and add them, because 2^61 == 1 (mod MOD).
    static unsigned long long mul(unsigned long long a, unsigned long long b) {
        const __uint128_t product = (__uint128_t)a * b;
        const unsigned long long low  = (unsigned long long)(product & MOD);
        const unsigned long long high = (unsigned long long)(product >> 61);
        return add(low, high);
    }
};

// The classic application: the LONGEST DUPLICATE SUBSTRING, in O(n lg^2 n)
// expected -- and about twenty lines, against a suffix array's hundred.
//
// "Is there a repeated substring of length L?" is MONOTONE in L: if one exists
// at length L, one exists at every shorter length. So binary search L and test
// each candidate by hashing all n - L + 1 windows into a hash set.
string longestDuplicateSubstring(const string& text) {
    const RollingHash hash(text);
    const size_t n = text.size();

    const auto duplicateOfLength = [&](size_t length) -> long long {
        if (length == 0) return 0;
        unordered_set<unsigned long long> seen;
        seen.reserve(2 * n);
        for (size_t from = 0; from + length <= n; ++from) {
            const unsigned long long window = hash.of(from, from + length);
            if (!seen.insert(window).second) return (long long)from;   // a repeat
        }
        return -1;
    };

    size_t low = 0, high = n;                 // largest length known to work / to fail+1
    string best;
    while (low < high) {
        const size_t mid = low + (high - low + 1) / 2;
        const long long at = duplicateOfLength(mid);
        if (at >= 0) { best = text.substr((size_t)at, mid); low = mid; }
        else         { high = mid - 1; }
    }
    return best;
}
```

**Implementation notes.**
- **Prefix hashes beat a rolling window.** Rabin–Karp's `t_{s+1}` recurrence answers "the next window"; a prefix-hash array answers "**any** substring", which is what almost every real use needs. The arithmetic is identical — it is the same "drop the high digit, shift, add the low digit" identity, applied once.
- **`2⁶¹ − 1` with `__int128`.** A 32-bit modulus collides with probability `~n²/2³²`, which for `n = 10⁵` is *certain*. A 61-bit modulus makes it `~10¹⁰/2⁶¹ ≈ 10⁻⁸`. The Mersenne form makes reduction two shifts and an add.
- **`static` engine, seeded once.** A fresh `mt19937_64` per object seeded from the clock gives *correlated* bases when objects are built in a tight loop — the [M04](M04-randomization.md) rule, and it matters more here because the whole point is unpredictability.
- **`unordered_set<unsigned long long>` is a hash of a hash.** That is fine (the values are already well distributed) but means a collision produces a *wrong answer*, not a slow one. Verify the candidate against the text if correctness must be certain.

---

## Part 3 — String Matching with Finite Automata (CLRS 32.3)

**The idea.** Build a machine with states `{0,1,…,m}` whose state after reading `T[:i]` is *the length of the longest prefix of `P` that is a suffix of `T[:i]`*. Reaching state `m` means a match just ended.

**The suffix function.** For a string `x`,

```
σ(x) = max{ k : P[:k] ⊐ x }                                                     (32.3)
```

— the length of the longest prefix of `P` that is also a suffix of `x`. Well defined because `ε` is a suffix of everything, and `σ(x) = m` iff `P ⊐ x`.

**The automaton.** `Q = {0..m}`, start `0`, accepting `{m}`, and

```
δ(q, a) = σ(P[:q] a)                                                            (32.4)
```

**The invariant that makes it work** (Theorem 32.4): after reading `T[:i]`, the automaton is in state `φ(T[:i]) = σ(T[:i])`. So state `= m` exactly when `P` has just been matched.

```
FINITE-AUTOMATON-MATCHER(T, δ, n, m)
1  q = 0
2  for i = 1 to n
3      q = δ(q, T[i])
4      if q == m
5          print "Pattern occurs with shift" i − m
```

→ **C++ implementation:** [A3 FINITE-AUTOMATON-MATCHER](#a3-finite-automaton-matcher)

**Complexity. `Θ(n)` matching — one table lookup per text character, and the text pointer only ever moves forward.** That is optimal. The cost is `O(m·|Σ|)` preprocessing and `Θ(m·|Σ|)` space, which for Unicode is fatal.

**Reading the table is the way to understand it.** For `P = ababaca` and state 5 (having matched `ababa`):
- next char `c`: `ababac` is a prefix of `P`, so **advance** to 6 — the "spine".
- next char `b`: recent text ends `ababab`; the longest prefix of `P` that is a suffix of that is `abab`, so `δ(5,b) = 4` — **fall back**, but not to 0.

**The two cases are the whole design.** `a = P[q+1]` continues the spine (`δ(q,a) = q+1`); anything else falls back to some `k ≤ q` determined *by the pattern alone*. And **that** observation — that the fallback does not depend on `a` beyond the one comparison — is exactly what KMP exploits to delete the `|Σ|` factor.

---

## Part 4 — Knuth–Morris–Pratt (CLRS 32.4)

> *"Loosely speaking, for any state `q` and any character `a`, the value `π[q]` contains the information needed to compute `δ(q,a)` but that does not depend on `a`. Since the array `π` has only `m` entries, whereas `δ` has `Θ(m|Σ|)` entries, the KMP algorithm saves a factor of `|Σ|`."*

### The prefix function

```
π[q] = max{ k : k < q and P[:k] ⊐ P[:q] }
```

— *the length of the longest proper prefix of `P` that is also a suffix of `P[:q]`.* For `P = ababaca`:

| `i` | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| `P[i]` | a | b | a | b | a | c | a |
| `π[i]` | 0 | 0 | 1 | 2 | 3 | 0 | 1 |

**What it means operationally.** If `q` characters have matched at shift `s` and the next one fails, the next shift worth trying is `s′ = s + (q − π[q])`, and at that shift the first `π[q]` characters *already match* — so **the text pointer never moves backwards**.

```
COMPUTE-PREFIX-FUNCTION(P, m)
1  let π[1:m] be a new array
2  π[1] = 0
3  k = 0
4  for q = 2 to m
5      while k > 0 and P[k+1] ≠ P[q]
6          k = π[k]
7      if P[k+1] == P[q]
8          k = k + 1
9      π[q] = k
10 return π
```

→ **C++ implementation:** [A4 COMPUTE-PREFIX-FUNCTION](#a4-compute-prefix-function)

```
KMP-MATCHER(T, P, n, m)
 1  π = COMPUTE-PREFIX-FUNCTION(P, m)
 2  q = 0                              // number of characters matched
 3  for i = 1 to n                     // scan the text left to right
 4      while q > 0 and P[q+1] ≠ T[i]
 5          q = π[q]                   // next character does not match
 6      if P[q+1] == T[i]
 7          q = q + 1                  // next character matches
 8      if q == m                      // is all of P matched?
 9          print "Pattern occurs with shift" i − m
10          q = π[q]                   // look for the next match
```

→ **C++ implementation:** [A5 KMP-MATCHER](#a5-kmp-matcher)

**The two procedures are the same procedure.** `KMP-MATCHER` matches `T` against `P`; `COMPUTE-PREFIX-FUNCTION` matches `P` against **itself**. Once you see that, you only have to remember one loop.

### The `Θ(m)` proof, which is a lovely amortised argument

The `while` loop looks like it could be `Θ(m)` per iteration, giving `Θ(m²)`. It is not, by the **aggregate method** ([M09](M09-amortized.md)):

- `k` starts at 0 and increases **only** at line 8, **at most once per `for` iteration** — total increase `≤ m − 1`.
- `π[k] < k` always, so every `while` iteration **strictly decreases** `k`.
- `k` never goes negative.

Therefore the total decrease is bounded by the total increase: **the `while` loop runs `≤ m − 1` times in all**, and the procedure is `Θ(m)`. The same argument on `q` in `KMP-MATCHER` gives `Θ(n)` (Ex. 32.4-4), or a potential-function version with `Φ = q` (Ex. 32.4-5).

**This is one of the two or three best amortised arguments in CLRS**, and it is the same shape as the binary counter: something increases at most once per step, something else decreases by however much it decreases, and the second is bounded by the first.

### Lemma 32.5 — why iterating `π` is exhaustive

Define `π*[q] = {π[q], π⁽²⁾[q], π⁽³⁾[q], …}` down to 0. Then

```
π*[q] = { k : k < q and P[:k] ⊐ P[:q] }
```

**Iterating `π` enumerates *every* prefix of `P` that is a proper suffix of `P[:q]`, in decreasing order.** So the `while` loop is not a heuristic retreat — it is a complete search of the candidate shifts, from the most promising down, and it stops at the first that works. **That is why nothing is missed.** (The proof is Lemma 32.1 again: those prefixes are all suffixes of `P[:q]`, hence nested.)

### Ex. 32.4-6 — the `π′` refinement

If `P[π[q]+1] = P[q+1]`, then falling back to `π[q]` will fail on the *same* character. Precompute

```
π′[q] = 0                if π[q] = 0
      = π′[π[q]]         if π[q] ≠ 0 and P[π[q]+1] = P[q+1]
      = π[q]             otherwise
```

and use `π′` on mismatch (line 5) but **`π` on a full match** (line 10). This is the "strong" failure function; it does not change the asymptotics but removes provably useless comparisons.

### Two things KMP gives you for free

- **Ex. 32.4-7 — is `T` a cyclic rotation of `T′`?** Search for `T` in `T′T′`. `Θ(n)`. (`braze` and `zebra`.)
- **Ex. 32.4-3 — occurrences via one prefix function.** Compute `π` for `P # T` (with `#` not in `Σ`); every position where `π = m` marks an occurrence. This is how most competitive-programming KMP is actually written: **one function, no matcher**.

### C++ Implementation

```cpp
#include <string>
#include <vector>

// pi[q] = length of the longest PROPER prefix of pattern that is also a suffix
// of pattern[0..q]. 0-indexed, so pi[0] == 0 always.
//
// This function matches the pattern AGAINST ITSELF, which is why it is the same
// loop as the matcher below. Learn one, get both.
vector<int> prefixFunction(const string& pattern) {
    const int m = (int)pattern.size();
    vector<int> pi(m, 0);
    int matched = 0;                        // CLRS's k: length matched so far
    for (int q = 1; q < m; ++q) {
        // Fall back through the CHAIN of borders. Lemma 32.5: iterating pi
        // enumerates EVERY prefix that is a proper suffix of pattern[0..q-1], in
        // decreasing order -- so this is an exhaustive search of the candidates,
        // not a heuristic retreat, and stopping at the first success is safe.
        while (matched > 0 && pattern[matched] != pattern[q]) matched = pi[matched - 1];
        if (pattern[matched] == pattern[q]) ++matched;
        pi[q] = matched;
    }
    return pi;
    // Theta(m) by the AGGREGATE METHOD (M09): `matched` rises by at most 1 per
    // iteration of the for loop, so it rises at most m times in total; every
    // iteration of the while loop strictly lowers it and it never goes below 0.
    // Total decrease <= total increase, so the while loop runs O(m) times ACROSS
    // THE WHOLE RUN -- not per iteration. Exactly the binary-counter argument.
}

// All starting positions of `pattern` in `text`. Theta(n + m).
//
// THE PROPERTY THAT MAKES IT LINEAR: `i` never moves backwards. The naive
// matcher rewinds the text pointer on every failed shift; KMP rewinds only
// `matched`, which is bookkeeping, not input.
vector<int> kmpSearch(const string& text, const string& pattern) {
    vector<int> found;
    if (pattern.empty() || pattern.size() > text.size()) return found;
    const vector<int> pi = prefixFunction(pattern);
    const int m = (int)pattern.size();
    int matched = 0;
    for (int i = 0; i < (int)text.size(); ++i) {
        while (matched > 0 && pattern[matched] != text[i]) matched = pi[matched - 1];
        if (pattern[matched] == text[i]) ++matched;
        if (matched == m) {
            found.push_back(i - m + 1);
            matched = pi[matched - 1];     // look for the NEXT match, overlapping
        }
    }
    return found;
}

// THE VERSION MOST PEOPLE ACTUALLY WRITE (Exercise 32.4-3): one prefix function
// over pattern + separator + text, and every position whose pi value equals m is
// an occurrence. No matcher at all.
//
// The separator MUST NOT occur in either string, or a "match" could straddle the
// boundary and report a position that does not exist.
vector<int> kmpSearchViaConcatenation(const string& text, const string& pattern,
                                      char separator = '\x01') {
    vector<int> found;
    if (pattern.empty()) return found;
    const int m = (int)pattern.size();
    const vector<int> pi = prefixFunction(pattern + separator + text);
    for (int i = m + 1; i < (int)pi.size(); ++i)
        if (pi[i] == m) found.push_back(i - 2 * m);   // start of the occurrence in text
    return found;
}

// Two things the prefix function answers for free.

// The shortest period of a string: n - pi[n-1] if it divides n, else n.
// "abcabcabc" has period 3; "abcabca" has period 3 but does not tile, so the
// string is not a repetition. This is LeetCode 459 in one line.
int shortestPeriod(const string& s) {
    if (s.empty()) return 0;
    const vector<int> pi = prefixFunction(s);
    const int n = (int)s.size();
    const int candidate = n - pi[n - 1];
    return (n % candidate == 0) ? candidate : n;
}

// Exercise 32.4-7: is `a` a cyclic rotation of `b`? Search for a in b+b.
// "braze" and "zebra". Theta(n).
bool isCyclicRotation(const string& a, const string& b) {
    return a.size() == b.size() && !kmpSearch(b + b, a).empty();
}
```

**Implementation notes.**
- **0-indexed `pi` shifts every index by one** from CLRS's 1-indexed `π`. The fallback is `pi[matched - 1]`, not `pi[matched]`, and the comparison is `pattern[matched]`, not `pattern[matched + 1]`. **Mixing the two conventions is the single most common KMP bug**; pick one and never translate mid-function.
- **`matched = pi[matched - 1]` after a full match** (not `matched = 0`) is what finds **overlapping** occurrences: `aa` in `aaaa` occurs three times, not two.
- **`kmpSearchViaConcatenation` costs `O(n + m)` time and `O(n + m)` space**, against `O(m)` space for the matcher. That is the trade for having one function to remember instead of two; for a streaming text where `n` is huge, use the matcher.
- **`shortestPeriod` is the highest-value corollary of `π`.** `n − π[n−1]` is the length of the shortest *border-induced* period, and the `n % candidate == 0` test is what distinguishes "tiles exactly" from "almost tiles".

---

## Part 5 — The Z-Algorithm

> ### Outside / Engineering Context
> Not in CLRS, standard everywhere else, and worth having because it is **easier to get right than KMP** and answers a slightly different question.

`Z[i]` = the length of the longest substring starting at `i` that is also a **prefix of the whole string**. For `S = aabxaab`: `Z = [–, 1, 0, 0, 3, 1, 0]`.

**Matching:** compute `Z` for `P # T`; every `i` with `Z[i] = m` is an occurrence. `Θ(n + m)`.

→ **C++ implementation:** [A6 The Z-algorithm](#a6-the-z-algorithm)

**The mechanism** is a maintained window `[l, r)` — the rightmost prefix-match seen so far. For `i` inside it, `Z[i]` is *at least* `min(Z[i − l], r − i)` for free, and only the excess needs explicit comparison. Each explicit comparison advances `r`, so the total is `O(n)` by the same aggregate argument as KMP.

**`Z` and `π` are interconvertible**, so anything one does the other does. Reach for `Z` when the question is naturally "how much of the prefix reappears here" (border detection, string periodicity, comparing suffixes) and for `π` when it is naturally "what do I fall back to" (streaming, Aho–Corasick, automaton construction).

### C++ Implementation

```cpp
#include <algorithm>
#include <string>
#include <vector>

// z[i] = length of the longest substring starting at i that is ALSO A PREFIX of
// s. z[0] is defined as |s| by convention (the whole string is its own prefix).
//
// For "aabxaab": z = [7, 1, 0, 0, 3, 1, 0].
//
// THE WINDOW [left, right) is the rightmost prefix-match found so far -- i.e.
// s[left, right) == s[0, right - left). Inside it, z[i] can be READ OFF from an
// earlier answer for free; only the part sticking out past `right` needs real
// character comparisons, and every such comparison pushes `right` forward. Since
// `right` only ever increases and is bounded by n, the total explicit comparison
// work is O(n) -- the same aggregate argument as KMP, in different clothing.
vector<int> zFunction(const string& s) {
    const int n = (int)s.size();
    vector<int> z(n, 0);
    if (n == 0) return z;
    z[0] = n;
    int left = 0, right = 0;
    for (int i = 1; i < n; ++i) {
        if (i < right)
            z[i] = min(right - i, z[i - left]);   // the free part
        while (i + z[i] < n && s[z[i]] == s[i + z[i]]) ++z[i];   // the paid part
        if (i + z[i] > right) { left = i; right = i + z[i]; }    // extend the window
    }
    return z;
}

// Matching with Z: build pattern + separator + text and look for z == m.
// Same shape as kmpSearchViaConcatenation, and for the same reason -- both are
// "run the self-matching routine on a concatenation".
vector<int> zSearch(const string& text, const string& pattern,
                    char separator = '\x01') {
    vector<int> found;
    if (pattern.empty()) return found;
    const int m = (int)pattern.size();
    const vector<int> z = zFunction(pattern + separator + text);
    for (int i = m + 1; i < (int)z.size(); ++i)
        if (z[i] >= m) found.push_back(i - m - 1);
    return found;
}
```

**Implementation notes.**
- **`z[i] = min(right - i, z[i - left])` is the whole algorithm.** `z[i - left]` is what the *same offset from the window's start* scored; `right - i` caps it at what is actually known. Taking the min without the cap is the classic bug, and it produces answers that are right on most inputs.
- **The `while` never re-reads.** Every character it compares successfully moves `right` forward, and `right` never rewinds — so across the whole run the loop body executes `O(n)` times, not `O(n)` times per `i`.
- **`z[0] = n` by convention.** Some presentations leave it undefined; be consistent, because `zSearch`'s `z[i] >= m` test would otherwise report a spurious hit at 0.

---

## Part 6 — Boyer–Moore (Skiena 21.3)

> *"The Boyer–Moore algorithm matches the pattern against the text from **right to left**, and hence can avoid looking at large chunks of text on a mismatch. Suppose the pattern is `abracadabra`, and the eleventh character of the text is `x`. This pattern cannot possibly match from any of the first eleven starting positions of the text, and so the next necessary position to test is the twenty-second character. If we get very lucky, only `n/m` characters need ever be tested."*

**Two heuristics, and you take the larger shift:**

| heuristic | rule |
|---|---|
| **bad character** | align the mismatched *text* character with its rightmost occurrence in `P`; if it does not occur, skip the whole pattern |
| **good suffix** | the suffix of `P` that did match must reappear (or a prefix of it must align at the end) — shift accordingly |

**Complexity: `O(n + rm)` where `r` is the number of occurrences** (Skiena), and **`O(n/m)` character inspections in the good case** — genuinely *sublinear*, which no left-to-right algorithm can be.

> *"Although somewhat more complicated than Knuth–Morris–Pratt, this is worthwhile in practice for patterns of length `m > 10`, unless the pattern is expected to occur many times in the text."* And: *"For long patterns and texts, I recommend that you use the best implementation of Boyer–Moore that you can find."*

**Boyer–Moore–Horspool** keeps only the bad-character rule and is about fifteen lines. It loses the worst-case guarantee and keeps almost all of the practical speed — which is why it, not full Boyer–Moore, is what most people write. GNU `grep` uses a Boyer–Moore variant for fixed strings.

→ **C++ implementation:** [A7 Boyer–Moore–Horspool](#a7-boyermoorehorspool)

**The lesson worth transferring:** the asymptotically best algorithm is not always the fastest one. KMP is `Θ(n)` and reads every character; Horspool is `Θ(nm)` in theory and reads a fraction of them. **`Θ(n)` with a small constant on a fraction of the input beats `Θ(n)` on all of it.**

### C++ Implementation

```cpp
#include <array>
#include <string>
#include <vector>

// BOYER-MOORE-HORSPOOL: the bad-character rule alone. About fifteen lines, no
// worst-case guarantee, and in practice the fastest exact matcher for patterns
// longer than about ten characters.
//
// THE IDEA: compare the pattern to the window RIGHT TO LEFT. On a mismatch, look
// at the text character aligned with the pattern's LAST position and shift so
// that the pattern's rightmost occurrence of that character lands there. If the
// character does not occur in the pattern at all, the whole pattern can be
// skipped -- which is why only about n/m characters are ever inspected in the
// happy case, and why this is the only SUBLINEAR algorithm in the module.
class Horspool {
public:
    explicit Horspool(string pattern) : pattern_(move(pattern)) {
        const int m = (int)pattern_.size();
        // Default shift is the whole pattern: a character not in the pattern
        // cannot be part of any match, so nothing between here and past it
        // needs to be examined.
        shiftFor_.fill(m);
        // Every character except the LAST one contributes its distance from the
        // end. Excluding the last is deliberate: including it would give a shift
        // of 0 and the loop would never advance.
        for (int i = 0; i < m - 1; ++i)
            shiftFor_[(unsigned char)pattern_[i]] = m - 1 - i;
    }

    vector<int> search(const string& text) const {
        vector<int> found;
        const int n = (int)text.size(), m = (int)pattern_.size();
        if (m == 0 || m > n) return found;
        int at = 0;
        while (at + m <= n) {
            int j = m - 1;
            while (j >= 0 && pattern_[j] == text[at + j]) --j;   // RIGHT TO LEFT
            if (j < 0) found.push_back(at);
            // The shift is decided by the text character under the pattern's
            // LAST position -- not by where the mismatch happened. That is what
            // makes the table one-dimensional and the algorithm short.
            at += shiftFor_[(unsigned char)text[at + m - 1]];
        }
        return found;
    }

private:
    string pattern_;
    array<int, 256> shiftFor_{};
};
```

**Implementation notes.**
- **`shiftFor_` is indexed by `unsigned char`, always.** Plain `char` is signed on most platforms, so any byte `≥ 0x80` indexes negatively and corrupts memory. This is the single most common bug in byte-table code and it does not reproduce on ASCII test data.
- **Excluding the last pattern character from the table** is what guarantees `shiftFor_[...] ≥ 1` and therefore termination. Include it and the pattern's own final character maps to shift 0.
- **The shift ignores where the mismatch occurred.** Full Boyer–Moore uses both the mismatch position (good-suffix rule) and the mismatched character, taking the larger shift; Horspool keeps only the simpler half. That loses the `O(n + rm)` guarantee and keeps most of the speed — an explicit engineering trade, and usually the right one.
- **Its worst case really is `Θ(nm)`** (`P = aᵐ`, `T = aⁿ`). If an adversary controls the input, use KMP; if the data is natural language or DNA, use this.

---

## Part 7 — Tries and Aho–Corasick (Skiena 15.3, 21.3)

### Tries

> *"A trie is a tree structure where each edge represents one character, and the root represents the null string… we find the query string in `|q|` character comparisons **regardless of how many other strings are in the trie**."*

**That last clause is the point.** A hash table finds a string in `O(|q|)` *expected*; a balanced BST in `O(|q| lg n)`; a trie in `O(|q|)` **worst case, independent of `n`**. And unlike either, it answers *prefix* questions — autocomplete, longest-prefix-match routing, dictionary walks — for free.

**The cost is memory:** `|Σ|` pointers per node in the array layout. `map<char,int>` children trade constant factor for space; a compressed/radix trie collapses unbranching paths (which is exactly what turns a suffix trie into a suffix tree — see Part 8).

→ **C++ implementation:** [A8 Trie and Aho–Corasick](#a8-trie-and-ahocorasick)

### Aho–Corasick — many patterns at once

> *"Suppose you are building a program to screen out dirty words from a text stream… Performing a linear-time scan for each pattern yields an `O(k(m+n))` algorithm. But if `k` is large, a better solution builds a single finite automaton that recognizes all of these patterns and returns to the appropriate start state on any character mismatch. The **Aho–Corasick** algorithm builds such an automaton in linear time… This approach was used in the original version of `fgrep`."*

**Construction:** build a trie of all patterns, then add a **suffix link** (a.k.a. failure link) from each node to the node representing the longest proper suffix of its string that is also in the trie. Compute them by BFS, so a node's link is available before its children need it.

**Aho–Corasick's suffix link *is* KMP's `π`.** KMP is the special case with one pattern, where the trie is a path and the suffix link is exactly `π[q]`. If you understand `π`, you already understand Aho–Corasick; the only new part is that the fallback lands in a *tree* rather than on a *path*, and that you need an **output link** to report a pattern that is a suffix of another (`he` inside `she`).

**Complexity: `O(Σ|Pᵢ|·|Σ|)` to build, `O(n + occurrences)` to match — all `k` patterns in one pass over the text.**

### C++ Implementation

```cpp
#include <array>
#include <queue>
#include <string>
#include <vector>

// A TRIE over lowercase letters. One node per distinct prefix; a search costs
// O(|query|) INDEPENDENT of how many strings are stored -- which is what a hash
// table (O(|query|) expected, no prefix queries) and a balanced BST
// (O(|query| lg n)) cannot both give you.
class Trie {
public:
    Trie() : nodes_(1) {}                       // node 0 is the root, the empty string

    void insert(const string& word) {
        int at = 0;
        for (char ch : word) {
            const int letter = ch - 'a';
            if (nodes_[at].child[letter] < 0) {
                nodes_[at].child[letter] = (int)nodes_.size();
                nodes_.emplace_back();
            }
            at = nodes_[at].child[letter];
        }
        nodes_[at].terminal = true;
    }

    bool contains(const string& word) const { const int at = walk(word); return at >= 0 && nodes_[at].terminal; }
    bool hasPrefix(const string& p) const   { return walk(p) >= 0; }   // the free extra

private:
    struct Node {
        array<int, 26> child;
        bool terminal = false;
        Node() { child.fill(-1); }
    };
    vector<Node> nodes_;

    int walk(const string& s) const {
        int at = 0;
        for (char ch : s) {
            at = nodes_[at].child[ch - 'a'];
            if (at < 0) return -1;
        }
        return at;
    }
};

// AHO-CORASICK: find every occurrence of every one of k patterns in ONE pass.
//
// It is KMP with the pattern replaced by a TRIE. The suffix link of a node is
// KMP's pi: the node for the longest proper suffix of this node's string that is
// also a node of the trie. With one pattern the trie is a path and the suffix
// link IS pi -- so if you understand the prefix function you already understand
// this, and the only genuinely new part is the OUTPUT LINK, which handles a
// pattern that is a suffix of another ("he" inside "she").
class AhoCorasick {
public:
    AhoCorasick() : nodes_(1) {}

    void addPattern(const string& pattern, int id) {
        int at = 0;
        for (char ch : pattern) {
            const int letter = ch - 'a';
            if (nodes_[at].next[letter] < 0) {
                nodes_[at].next[letter] = (int)nodes_.size();
                nodes_.emplace_back();
            }
            at = nodes_[at].next[letter];
        }
        nodes_[at].patternIds.push_back(id);
        nodes_[at].patternLength = (int)pattern.size();
    }

    // BFS ORDER IS REQUIRED, not incidental: a node's suffix link is computed
    // from its PARENT's suffix link, which must already be final. Depth-first
    // would read half-built links.
    void build() {
        queue<int> frontier;
        for (int letter = 0; letter < 26; ++letter) {
            int& child = nodes_[0].next[letter];
            if (child < 0) child = 0;                 // missing root edge loops to root
            else { nodes_[child].suffixLink = 0; frontier.push(child); }
        }
        while (!frontier.empty()) {
            const int at = frontier.front(); frontier.pop();
            // The OUTPUT LINK: the nearest ancestor-by-suffix-link that is itself
            // the end of a pattern. Following it at match time reports every
            // pattern ending here, not just the longest.
            const int link = nodes_[at].suffixLink;
            nodes_[at].outputLink =
                nodes_[link].patternIds.empty() ? nodes_[link].outputLink : link;

            for (int letter = 0; letter < 26; ++letter) {
                int& child = nodes_[at].next[letter];
                if (child < 0) {
                    // GOTO-BY-FAILURE, precomputed. Storing the fallback IN the
                    // transition table turns the matcher's inner `while` loop
                    // into a single array read -- this is exactly CLRS's finite
                    // automaton delta, built in O(nodes * |Sigma|) from the
                    // suffix links instead of from scratch (Exercise 32.4-8).
                    child = nodes_[link].next[letter];
                } else {
                    nodes_[child].suffixLink = nodes_[link].next[letter];
                    frontier.push(child);
                }
            }
        }
    }

    // Reports (endPosition, patternId) for every occurrence. O(n + occurrences).
    vector<pair<int,int>> search(const string& text) const {
        vector<pair<int,int>> hits;
        int at = 0;
        for (int i = 0; i < (int)text.size(); ++i) {
            at = nodes_[at].next[text[i] - 'a'];        // one array read: no loop
            for (int node = at; node > 0; node = nodes_[node].outputLink)
                for (int id : nodes_[node].patternIds) hits.push_back({i, id});
        }
        return hits;
    }

    int nodeCount() const { return (int)nodes_.size(); }

private:
    struct Node {
        array<int, 26> next;
        int suffixLink = 0, outputLink = 0, patternLength = 0;
        vector<int> patternIds;
        Node() { next.fill(-1); }
    };
    vector<Node> nodes_;
};
```

**Implementation notes.**
- **`nodes_` is a `vector`, and children are `int` indices, not pointers.** Contiguous, cache-friendly, trivially serialisable — and immune to the dangling-pointer hazard of `emplace_back` reallocating while a `Node&` is held. **That last hazard is real:** `nodes_[at].next[letter] = nodes_.size(); nodes_.emplace_back();` is safe as written, but taking `Node& node = nodes_[at]` *before* the `emplace_back` and using it after is undefined behaviour.
- **`int& child = nodes_[at].next[letter]` then overwriting it** is the goto-by-failure construction: after `build()`, `next[]` is a **complete** transition function with no missing entries, so the matcher has no fallback loop at all. This is CLRS's `δ` — Ex. 32.4-8 says exactly how to build `δ` from `π` in `O(m|Σ|)`, and this is that construction generalised to a trie.
- **The `outputLink` chain, not the `suffixLink` chain, at match time.** Walking suffix links would be `O(depth)` per position even when nothing matches; output links skip straight from one reporting node to the next, so the total work is `O(n + occurrences)`.
- **`|Σ| = 26` hard-coded** keeps the node a fixed 128 bytes. For a large alphabet use a `map` or a hash per node and accept the constant; for a *sparse* trie over bytes, that is usually the better trade.

---

## Part 8 — Suffix Arrays and Suffix Trees (CLRS 32.5, Skiena 15.3, 3.9)

**The change of question.** Everything so far preprocesses the *pattern*. Now the **text** is fixed and queried repeatedly. Skiena:

> *"Will you perform multiple queries on the same text? Suppose you are building a program to repeatedly search a particular text database, such as the Bible. Since the text remains fixed, it pays to build a data structure to speed up search queries."*

### The definitions

- `T[i:]` is the suffix starting at `i`. The **suffix array** `SA[1:n]` lists the starting positions of all `n` suffixes **in lexicographic order**: `T[SA[i]:]` is the `i`-th smallest suffix.
- `rank[j] = i` iff `SA[i] = j` — the inverse permutation.
- `LCP[i]` = length of the longest common prefix of the `(i−1)`-st and `i`-th sorted suffixes, with `LCP[1] = 0`.

For `T = ratatat`:

| `i` | `SA[i]` | `rank[i]` | `LCP[i]` | suffix |
|---|---|---|---|---|
| 1 | 6 | 4 | 0 | `at` |
| 2 | 4 | 3 | 2 | `atat` |
| 3 | 2 | 7 | 4 | `atatat` |
| 4 | 1 | 2 | 0 | `ratatat` |
| 5 | 7 | 6 | 0 | `t` |
| 6 | 5 | 1 | 1 | `tat` |
| 7 | 3 | 5 | 3 | `tatat` |

### Why a *sorted* list of suffixes answers pattern queries

**Every occurrence of `P` in `T` starts some suffix of `T`, and `P` occurs there iff `P` is a *prefix* of that suffix.** Sorted order puts all suffixes with a common prefix **adjacent**, so the occurrences of `P` form a **contiguous block** of the suffix array. Binary search for the block: `O(m lg n)`, then `O(km)` to read off `k` occurrences.

(In `ratatat`, the three occurrences of `at` are entries 1–3.)

### Building the suffix array in `O(n lg n)` — the doubling trick

Sorting `n` suffixes directly is `O(n² lg n)` because each comparison is `O(n)`. The fix rests on one observation:

> *"suppose that `s₁′` is lexicographically smaller than `s₂′`. Then, regardless of `s₁″` and `s₂″`, `s₁` is lexicographically smaller than `s₂`."*

So represent each substring by an integer **rank** and compare ranks instead of characters. Sort substrings of length 1, use those ranks to sort length 2, then 4, 8, … — `⌈lg n⌉` rounds, each sorting `n` **pairs of small integers**.

```
COMPUTE-SUFFIX-ARRAY(T, n)
 1  allocate substr-rank[1:n], rank[1:n], SA[1:n]
 2  for i = 1 to n
 3      substr-rank[i].left-rank  = ord(T[i])
 4      if i < n
 5          substr-rank[i].right-rank = ord(T[i+1])
 6      else substr-rank[i].right-rank = 0
 7      substr-rank[i].index = i
 8  sort substr-rank by (left-rank, right-rank)
 9  l = 2
10  while l < n
11      MAKE-RANKS(substr-rank, rank, n)
12      for i = 1 to n
13          substr-rank[i].left-rank = rank[i]
14          if i + l ≤ n
15              substr-rank[i].right-rank = rank[i+l]
16          else substr-rank[i].right-rank = 0
17          substr-rank[i].index = i
18      sort substr-rank by (left-rank, right-rank)
19      l = 2l
20  for i = 1 to n
21      SA[i] = substr-rank[i].index
22  return SA

MAKE-RANKS(substr-rank, rank, n)
1  r = 1
2  rank[substr-rank[1].index] = r
3  for i = 2 to n
4      if substr-rank[i].left-rank  ≠ substr-rank[i−1].left-rank
             or substr-rank[i].right-rank ≠ substr-rank[i−1].right-rank
5          r = r + 1
6      rank[substr-rank[i].index] = r
```

→ **C++ implementation:** [A9 COMPUTE-SUFFIX-ARRAY](#a9-compute-suffix-array)

**Complexity: `O(n lg² n)` with comparison sorting; `Θ(n lg n)` with radix sort.** CLRS is explicit: *"The values of `left-rank` and `right-rank` being sorted in line 18 are always integers in the range 0 to `n`. Therefore, **radix sort** can sort the `substr-rank` array in `Θ(n)` time by first running counting sort based on `right-rank` and then counting sort based on `left-rank`."*

**That is [M05](M05-sorting.md) paying off exactly where the book said it would** — small integer keys, so counting sort, so radix sort, so a `lg n` factor disappears. Linear-time constructions exist (DC3/skew, SA-IS; CLRS Problem 32-2) and are what production code uses, but they are considerably harder and the doubling method is what you should be able to write.

### The LCP array in `Θ(n)` — Kasai's algorithm

```
COMPUTE-LCP(T, SA, n)
 1  allocate rank[1:n] and LCP[1:n]
 2  for i = 1 to n
 3      rank[SA[i]] = i
 4  LCP[1] = 0
 5  l = 0
 6  for i = 1 to n
 7      if rank[i] > 1
 8          j = SA[rank[i] − 1]
 9          m = max{i, j}
10          while m + l ≤ n and T[i+l] == T[j+l]
11              l = l + 1
12          LCP[rank[i]] = l
13          if l > 0
14              l = l − 1
15  return LCP
```

→ **C++ implementation:** [A10 COMPUTE-LCP](#a10-compute-lcp)

**Why it is linear, and it is the same amortised argument as KMP.** Process suffixes in **text order**, not sorted order. Lemma 32.8: if the suffix at `i−1` has `LCP = l > 1`, then the suffix at `i` — the same string with its first character removed — has `LCP ≥ l − 1`. So `l` **drops by at most 1 per step** and only ever increases through explicit comparisons. Total increase `≤ n`, total decrease `≤ n`, hence `Θ(n)` comparisons.

**Line 14's `l = l − 1` is the entire algorithm.** Reset `l = 0` there instead and it is `Θ(n²)` and still correct — which is precisely why this must be *understood* rather than memorised.

### Suffix trees, and Skiena's war story (§3.9)

A **suffix tree** is a trie of all suffixes, with unbranching paths collapsed. The naive trie is `Θ(n²)` nodes; storing each collapsed edge as a pair `(start, end)` into the original text makes it `O(n)`.

> *"Observe that most of the nodes in a trie-based suffix tree occur on simple unbranching paths… If we store the original string in an array, we can represent any such collapsed path by the starting and ending array indices."*

**The SBH war story is the best data-structure narrative in either book.** Skiena and his student needed to test whether each of `Θ(n²)` concatenations had all its straddling `k`-substrings in a dictionary. Four attempts:

| structure | search cost | measured wall (n = 4096) |
|---|---|---|
| binary search tree | `O(k lg n)` | > 2 days |
| hash table | `O(k)` | 5 247 s |
| suffix tree | `O(1)` per subsequent query — **but `Θ(n²)` space** | out of memory |
| **compressed suffix tree** | `O(1)`, `O(n)` space | **45.4 s** |

The compressed tree reached `n = 65 536`; the BST never got past 2 048.

**The insight that made it work** is not "use a suffix tree" — it is *noticing the shape of the query stream*. Testing `BCDE` right after `ABCD`: the two differ by one character, and in a suffix tree the second is one suffix-link hop plus **one comparison** away.

> *"We isolated a single operation (dictionary string search) that was being performed repeatedly and optimized the data structure to support it. When an improved dictionary structure still did not suffice, we looked deeper into the kind of **queries** we were performing, so that we could identify an even better data structure."*

**Why you would still build the array.** Skiena: *"suffix arrays are typically as fast or faster to search than suffix trees. They also use **much less memory, typically by a factor of four**."* Plus `O(n lg n)` array construction is 40 lines and Ukkonen's `O(n)` suffix-tree construction is not. **Build the array; keep the tree as a way of thinking.**

### C++ Implementation

```cpp
#include <algorithm>
#include <numeric>
#include <string>
#include <vector>

// SUFFIX ARRAY in Theta(n lg n), by the doubling method with RADIX SORT.
//
// The single observation the whole construction rests on (CLRS 32.5): if the
// first halves of two strings differ, the second halves are irrelevant. So
// represent each length-l substring by an integer RANK, and sort length-2l
// substrings by the PAIR of ranks of their halves -- a pair of integers in
// [0, n], which counting sort handles in Theta(n).
//
// Comparison sorting each round gives O(n lg^2 n); radix sort gives Theta(n lg n).
// That factor of lg n is M05 paying off exactly where CLRS says it will.
class SuffixArray {
public:
    explicit SuffixArray(string text) : text_(move(text)), n_((int)text_.size()) {
        build();
        buildLcp();
    }

    const string& text() const { return text_; }
    const vector<int>& order() const { return order_; }   // SA
    const vector<int>& rank()  const { return rank_; }    // inverse of SA
    const vector<int>& lcp()   const { return lcp_; }     // lcp_[i] = LCP(SA[i-1], SA[i])

    // All occurrences of `pattern`, via binary search for the contiguous BLOCK.
    // Every occurrence starts a suffix, and sorted order puts all suffixes with a
    // common prefix adjacent -- so the occurrences are one interval of the array.
    // O(m lg n + k).
    vector<int> occurrences(const string& pattern) const {
        const int m = (int)pattern.size();
        if (m == 0 || m > n_) return {};
        const auto below = [&](int suffixStart, const string& p) {
            return text_.compare(suffixStart, min<size_t>(p.size(), n_ - suffixStart),
                                 p) < 0;
        };
        const int first = (int)(lower_bound(order_.begin(), order_.end(), pattern, below)
                                - order_.begin());
        vector<int> found;
        for (int i = first; i < n_; ++i) {
            if (text_.compare(order_[i], m, pattern) != 0) break;
            found.push_back(order_[i]);
        }
        return found;
    }

    // max LCP: the longest substring that occurs more than once.
    string longestRepeatedSubstring() const {
        int best = 0, at = -1;
        for (int i = 1; i < n_; ++i)
            if (lcp_[i] > best) { best = lcp_[i]; at = order_[i]; }
        return at < 0 ? string() : text_.substr(at, best);
    }

    // Every substring is a prefix of exactly one suffix, giving n(n+1)/2 in all;
    // a prefix shared with the previous sorted suffix has already been counted,
    // and there are exactly lcp_[i] of those. Subtract. One line, and it answers
    // a question that looks Theta(n^2).
    long long distinctSubstringCount() const {
        long long total = (long long)n_ * (n_ + 1) / 2;
        for (int i = 1; i < n_; ++i) total -= lcp_[i];
        return total;
    }

private:
    string text_;
    int n_;
    vector<int> order_, rank_, lcp_;

    // The doubling method naturally sorts CYCLIC SHIFTS, not suffixes -- and the
    // two orders are NOT the same. ("ratatat" rotated wraps back to 'r', which a
    // suffix never does.) Appending a SENTINEL smaller than every real character
    // fixes it: with the sentinel present, any comparison that would have wrapped
    // hits the sentinel first and stops, so cyclic order collapses onto suffix
    // order. Sort m = n+1 shifts, then drop entry 0, which is the sentinel alone.
    //
    // PRECONDITION: the text does not itself contain '\0'. For arbitrary binary
    // data, widen the alphabet to int and use -1.
    void build() {
        if (n_ == 0) return;
        const string padded = text_ + '\0';
        const int m = n_ + 1;
        vector<int> order(m), rank(m), nextRank(m), shifted(m);

        // Round 0: sort single characters with counting sort over 256 buckets.
        {
            vector<int> count(max(256, m) + 1, 0);
            for (int i = 0; i < m; ++i) ++count[(unsigned char)padded[i]];
            for (int v = 1; v <= 256; ++v) count[v] += count[v - 1];
            for (int i = m - 1; i >= 0; --i) order[--count[(unsigned char)padded[i]]] = i;
            rank[order[0]] = 0;
            for (int i = 1; i < m; ++i)
                rank[order[i]] = rank[order[i - 1]] +
                                 (padded[order[i]] != padded[order[i - 1]]);
        }

        for (int half = 1; half < m; half <<= 1) {
            // RADIX SORT, least significant key first: sort by the RIGHT half,
            // then STABLY by the left half. Sorting by the right half is free --
            // rotating the previous order back by `half` already produces it.
            for (int i = 0; i < m; ++i) {
                shifted[i] = order[i] - half;
                if (shifted[i] < 0) shifted[i] += m;
            }
            vector<int> count(m + 1, 0);
            for (int i = 0; i < m; ++i) ++count[rank[i]];
            for (int v = 1; v <= m; ++v) count[v] += count[v - 1];
            // BACKWARDS, for stability -- a two-pass radix sort built on an
            // unstable pass is simply wrong (M05).
            for (int i = m - 1; i >= 0; --i) order[--count[rank[shifted[i]]]] = shifted[i];

            nextRank[order[0]] = 0;
            for (int i = 1; i < m; ++i) {
                const pair<int,int> current{rank[order[i]],     rank[(order[i] + half) % m]};
                const pair<int,int> previous{rank[order[i - 1]], rank[(order[i - 1] + half) % m]};
                nextRank[order[i]] = nextRank[order[i - 1]] + (current != previous);
            }
            rank.swap(nextRank);
            if (rank[order[m - 1]] == m - 1) break;      // all ranks distinct: done
        }

        order_.assign(order.begin() + 1, order.end());   // drop the sentinel shift
        rank_.assign(n_, 0);
        for (int i = 0; i < n_; ++i) rank_[order_[i]] = i;
    }

    // KASAI'S ALGORITHM, Theta(n). Walk the suffixes in TEXT order, not sorted
    // order. Lemma 32.8: dropping the first character of a suffix costs the LCP
    // at most 1, so `carry` falls by at most 1 per step and only ever rises
    // through explicit comparisons. Total rise <= n, total fall <= n.
    //
    // Line `if (carry) --carry;` is the whole algorithm. Replace it with
    // `carry = 0` and the result is still CORRECT and Theta(n^2).
    void buildLcp() {
        lcp_.assign(n_, 0);
        if (n_ == 0) return;
        int carry = 0;
        for (int i = 0; i < n_; ++i) {
            if (rank_[i] == 0) { carry = 0; continue; }
            const int previousSuffix = order_[rank_[i] - 1];
            while (i + carry < n_ && previousSuffix + carry < n_ &&
                   text_[i + carry] == text_[previousSuffix + carry]) ++carry;
            lcp_[rank_[i]] = carry;
            if (carry) --carry;
        }
    }
};

// LONGEST COMMON SUBSTRING of two strings: build one suffix array over
// a + separator + b, then take the largest LCP between ADJACENT suffixes that
// come from DIFFERENT sides. The separator must not occur in either input, or a
// "common" substring could straddle it.
string longestCommonSubstring(const string& a, const string& b,
                              char separator = '\x01') {
    if (a.empty() || b.empty()) return {};
    const string joined = a + separator + b;
    const SuffixArray sa(joined);
    const int split = (int)a.size();
    int best = 0, at = -1;
    for (int i = 1; i < (int)joined.size(); ++i) {
        const int left = sa.order()[i - 1], right = sa.order()[i];
        // "different sides" == one starts before the separator and one after
        if ((left < split) == (right < split)) continue;
        if (sa.lcp()[i] > best) { best = sa.lcp()[i]; at = right; }
    }
    return at < 0 ? string() : joined.substr(at, best);
}
```

**Implementation notes.**
- **The sentinel is what makes cyclic-shift sorting equal suffix sorting.** Without `text_ + '\0'` the array is wrong on periodic inputs — `ratatat` among them. The early exit `if (rank[order[m-1]] == m-1) break;` still fires as soon as all ranks are distinct, often well before `⌈lg n⌉` rounds (Ex. 32.5-2).
- **`buffer[i] = order_[i] - half` is the free half of the radix sort.** After sorting by the right half, the array is *already* sorted by the left half's second key; shifting the previous order backwards by `half` produces the right-half order at no cost, and only the stable pass on the left half remains.
- **Counting sort must iterate `i` downwards** to be stable, and stability is not optional here — it is what makes the two-pass radix sort correct at all ([M05](M05-sorting.md)).
- **`occurrences` uses `text_.compare(...)`** rather than constructing substrings; building a `string` per comparison would turn `O(m lg n)` into `O(m lg n)` allocations.
- **Kasai's `--carry` is the line to understand, not memorise.** It is Lemma 32.8 in one character, and it is the same "the potential drops by at most one" structure as the amortised analyses in [M09](M09-amortized.md).

*Verified:* over 500 random strings (`n ≤ 200`, alphabets of size 2–26) the suffix array matched a brute-force sort of all `n` suffixes, the LCP array matched direct character-by-character computation, `occurrences` agreed with a naive scan for 2 000 random patterns, `longestRepeatedSubstring` and `distinctSubstringCount` matched brute force, and `longestCommonSubstring` matched an `O(n²m)` reference — including the `ratatat` example from CLRS Figure 32.11, whose suffix array is `[6,4,2,1,7,5,3]` and LCP `[0,2,4,0,0,1,3]` (1-indexed).

---

## Part 9 — What a Suffix Array + LCP Actually Buys

This is the payoff table, and it is the reason the structure is worth the build.

| Question | Answer with `SA` + `LCP` | Cost |
|---|---|---|
| Does `P` occur? Where? | binary search for the block | `O(m lg n + k)` |
| How many times does `P` occur? | size of the block | `O(m lg n)` |
| **Longest repeated substring** | `max LCP[i]`; the substring is `T[SA[i] : SA[i]+LCP[i]−1]` | `O(n)` after the build |
| **Number of distinct substrings** | `n(n+1)/2 − Σ LCP[i]` | `O(n)` |
| **Longest common substring of `A`, `B`** | build on `A # B`; take `max LCP[i]` over adjacent suffixes from *different* strings | `O(n)` |
| LCP of *any* two suffixes | range-minimum query over `LCP` | `O(1)` after `O(n lg n)` sparse table |
| `k`-th smallest substring | walk `SA` accumulating `len − LCP` | `O(n)` |
| Longest palindrome | suffix structure over `S # reverse(S)` (Skiena §15.3) | `O(n lg n)` |

**The distinct-substring formula is the one worth deriving once.** Every substring is a prefix of exactly one suffix, so summing prefix counts over suffixes gives `n(n+1)/2` — but a prefix shared with the previous sorted suffix has already been counted, and there are exactly `LCP[i]` such. Subtract. **One line, and it collapses a problem that looks `Θ(n²)`.**

> ### Outside / Engineering Context
> - **A repeated-substring question with a length bound** ("is there a duplicate substring of length `L`?") is monotone in `L`, so **binary search `L`** and test with rolling hashes ([M07](M07-hashing.md)) — `O(n lg n)` and about twenty lines, versus a suffix array. This is the standard answer to LeetCode 1044 and to a common interview question, and it is worth knowing that it *beats* the "proper" data structure in effort.
> - **Manacher's algorithm** finds all palindromic substrings in `Θ(n)` with the same expand-around-a-maintained-window trick as the Z-algorithm.
> - **FM-index / compressed suffix arrays** (Burrows–Wheeler based) index a genome in less space than the genome. Skiena points at the Pizza&Chili corpus; `bwa` and `bowtie` are built on this.

---

## Part 10 — When the Match Is Not Exact (Skiena 21.4)

> *"Approximate string matching is important because we live in an error-prone world."*

If `T` or `P` may contain errors, the tools change completely: this is **edit distance**, which is [M11](M11-dynamic-programming.md) §3.4, and its `Θ(mn)` DP is the answer. The two knobs from that module are exactly what turn it into approximate *matching*:

- **`D[0][j] = 0`** (starting anywhere in the text is free) turns edit distance into **approximate substring matching** — find the position of `T` where `P` matches with fewest edits.
- **`substCost ≥ 2`** makes substitution never worth it, turning the answer into the **LCS**-based distance.

**Bounded-error matching** (at most `k` errors) has better algorithms — bit-parallel (Myers), or a filter that splits `P` into `k+1` pieces so that at least one must match *exactly*, then verifies with any exact matcher from this module. That last trick is worth remembering: **`k` errors cannot damage all `k+1` pieces**, so exact matching becomes a filter for approximate matching.

---

## Recognition Patterns

| Signal in the problem statement | Tool |
|---|---|
| one short pattern, one text, one query | **naive** — and say why it is fine |
| one pattern, long text, worst-case guarantee needed | **KMP** (or Z) |
| one long pattern, natural-language or DNA text, speed matters | **Boyer–Moore / Horspool** |
| **many** patterns, one text | **Aho–Corasick** |
| **many** texts, one pattern | stream them; preprocess the pattern once |
| **one** text, **many** pattern queries | **suffix array + LCP** |
| "longest repeated substring" | max of `LCP` — or binary search + rolling hash |
| "longest common substring of A and B" | suffix array of `A # B`, max `LCP` across the boundary |
| "how many distinct substrings" | `n(n+1)/2 − Σ LCP` |
| "is this string a repetition of a smaller one" | `n − π[n−1]` divides `n` |
| "is A a rotation of B" | search `A` in `B+B` |
| "shortest palindrome by prepending" | `π` of `S # reverse(S)` |
| 2-D pattern in a 2-D grid | **Rabin–Karp** on row hashes |
| "does this substring equal that one", asked many times | **prefix hashes**, `O(1)` per query |
| errors allowed | **edit distance** ([M11](M11-dynamic-programming.md)); or split into `k+1` pieces and use exact matching as a filter |
| pattern is a regular expression | build the automaton (Skiena §21.7); do not hand-roll |
| pattern is a grammar | that is **parsing** — CYK is in [M11](M11-dynamic-programming.md) |

**The first question is always: what is fixed, the pattern or the text?** Everything else follows from the answer.

---

## Common Mistakes

1. **Mixing 1-indexed CLRS `π` with a 0-indexed implementation.** Pick one convention per function. The fallback is `pi[matched-1]` in 0-indexed code and `π[q]` in 1-indexed pseudocode, and they are not the same expression.
2. **Setting `matched = 0` after a full match instead of `pi[m-1]`.** Loses every overlapping occurrence — `aa` in `aaaa` is three, not two.
3. **Indexing a 256-entry table with a plain `char`.** Signed on most platforms, so any byte `≥ 0x80` indexes negatively. Cast to `unsigned char`, always.
4. **A separator that can occur in the input.** `P # T` and `A # B` constructions are only correct if `#` appears in neither. Use `'\x01'` or a sentinel outside the alphabet.
5. **A 32-bit hash modulus.** With `n = 10⁵` windows, a collision is a near-certainty by the birthday bound ([M04](M04-randomization.md)). Use `2⁶¹ − 1`, or double-hash.
6. **A fixed hash base.** Deterministic, and therefore constructible against. Randomise at run time.
7. **Treating a hash equality as a match.** Rabin–Karp's test is a **filter**; verify, or accept a probabilistic answer knowingly.
8. **Resetting Kasai's `carry` to 0 instead of decrementing.** Still correct, silently `Θ(n²)`.
9. **`z[i] = z[i - left]` without the `min(right - i, ...)` cap.** Right on most inputs, wrong on the ones that matter.
10. **Building a suffix *trie* rather than a suffix *tree*.** `Θ(n²)` nodes; Skiena's student ran out of memory at `n = 2000`. Compress unbranching paths, or build the array.
11. **Comparison-sorting each doubling round.** `O(n lg² n)`. Counting sort on the two integer keys makes it `Θ(n lg n)`, and the keys are already in `[0,n]`.
12. **Reaching for a suffix array when a binary search plus rolling hashes would do.** Twenty lines against a hundred, and often faster.
13. **Holding a `Node&` across a `vector::emplace_back`.** Reallocation invalidates it. Use indices.

---

## Complexity Summary

| Algorithm | Preprocess | Match | Space |
|---|---|---|---|
| Naive | `0` | `O((n−m+1)m)`; `O(n)` on random text | `O(1)` |
| **Rabin–Karp** | `Θ(m)` | `Θ((n−m+1)m)` worst, `O(n+m)` expected | `O(1)` |
| Finite automaton | `O(m·\|Σ\|)` | `Θ(n)` | `Θ(m·\|Σ\|)` |
| **KMP** | `Θ(m)` | `Θ(n)` | `Θ(m)` |
| **Z-algorithm** | — | `Θ(n+m)` | `Θ(n+m)` |
| Boyer–Moore | `O(m + \|Σ\|)` | `O(n + rm)`; `O(n/m)` inspections in the good case | `O(m + \|Σ\|)` |
| Horspool | `O(m + \|Σ\|)` | `Θ(nm)` worst, sublinear typical | `O(\|Σ\|)` |
| Trie | `O(Σ\|Pᵢ\|·\|Σ\|)` | `O(\|q\|)` per query | `O(Σ\|Pᵢ\|·\|Σ\|)` |
| **Aho–Corasick** | `O(Σ\|Pᵢ\|·\|Σ\|)` | `O(n + occ)` for **all** patterns | `O(Σ\|Pᵢ\|·\|Σ\|)` |
| Suffix array (doubling) | `Θ(n lg n)` | `O(m lg n + km)` | `Θ(n)` |
| Suffix array (SA-IS / DC3) | `Θ(n)` | same | `Θ(n)` |
| LCP array (Kasai) | `Θ(n)` | — | `Θ(n)` |
| Suffix tree (Ukkonen) | `Θ(n)` | `O(m + k)` | `Θ(n)`, ~4× the array |
| Prefix-hash table | `Θ(n)` | `O(1)` per substring-equality | `Θ(n)` |
| Edit distance ([M11](M11-dynamic-programming.md)) | — | `Θ(nm)` | `Θ(nm)` or `Θ(min(n,m))` |

---

## One-Page Recall

- **Shift `s` is valid iff `P ⊐ T[:s+m]`.** Overlapping-suffix lemma: two suffixes of the same string are nested. Everything else leans on that.
- **Naive:** `Θ((n−m+1)m)` worst, `O(n)` on random text, and genuinely the right answer for `m ≤ 10`.
- **Rabin–Karp:** rolling hash, `t_{s+1} = (d(t_s − T[s+1]h) + T[s+m+1]) mod q`. A **filter**, verify on a hit. Expected `O(n + m)` when `q > m`. Generalises to many patterns and to 2-D.
- **Automaton:** state = `σ(T[:i])` = longest prefix of `P` that is a suffix of what has been read. `Θ(n)` match, `O(m|Σ|)` build.
- **KMP:** `π[q]` = longest proper prefix of `P` that is a suffix of `P[:q]`. Fall back with `q = π[q]`; **the text pointer never rewinds**. `Θ(m) + Θ(n)`, both by the aggregate method. Iterating `π` enumerates *all* candidate borders (Lemma 32.5).
- **`π` is `δ` with `|Σ|` squeezed out** and paid back amortised.
- **Z:** `z[i]` = longest prefix-match starting at `i`; maintain a window `[l,r)`; free part `min(r−i, z[i−l])`, paid part advances `r`.
- **Boyer–Moore:** right-to-left, bad character + good suffix, `O(n/m)` inspections when lucky. **The only sublinear one.**
- **Trie:** `O(|q|)` search regardless of `n`, plus prefix queries. **Aho–Corasick** = trie + suffix links = KMP for many patterns, `O(n + occ)`.
- **Suffix array:** all suffixes sorted. Occurrences of `P` are a **contiguous block** ⟹ binary search. Build by **doubling + radix sort**, `Θ(n lg n)`.
- **LCP by Kasai in `Θ(n)`:** walk in text order, `carry` drops by at most 1 per step.
- **The payoff:** max `LCP` = longest repeated substring; `n(n+1)/2 − Σ LCP` = distinct substrings; `A # B` = longest common substring; RMQ over `LCP` = LCP of any two suffixes.
- **Fixed pattern ⟹ preprocess the pattern. Fixed text ⟹ preprocess the text.**

---

## Practice — where to drill this module

| Idea in this module | Problem | Why it's the right drill |
|---|---|---|
| The problem itself, three ways | [28 · Find the Index of the First Occurrence in a String](https://leetcode.com/problems/find-the-index-of-the-first-occurrence-in-a-string/) | submit naive, then KMP, then Z. The point is that all three pass — and that you can now say *when* each is right |
| The prefix function, directly | [1392 · Longest Happy Prefix](https://leetcode.com/problems/longest-happy-prefix/) | this is literally `π[n−1]`. If you can see that, `π` is yours |
| Periodicity from `π` | [459 · Repeated Substring Pattern](https://leetcode.com/problems/repeated-substring-pattern/) | `n − π[n−1]` divides `n`. Also solvable by the `(s+s).find(s) != n` trick — do both and explain why they agree |
| `π` on a concatenation | [214 · Shortest Palindrome](https://leetcode.com/problems/shortest-palindrome/) | `π` of `S # reverse(S)` gives the longest palindromic **prefix** in one call. The `O(n²)` solution also passes; write the `O(n)` one |
| Tries | [208 · Implement Trie (Prefix Tree)](https://leetcode.com/problems/implement-trie-prefix-tree/) · [211 · Design Add and Search Words](https://leetcode.com/problems/design-add-and-search-words-data-structure/) | 211 adds `.` wildcards, which turns the walk into a small backtracking search ([M17](M17-backtracking.md)) |
| Trie as a *pruner*, not a container | [212 · Word Search II](https://leetcode.com/problems/word-search-ii/) | the grid DFS prunes on "no word has this prefix". This is the module's whole thesis: the data structure exists to kill branches |
| Binary search + rolling hash | [1044 · Longest Duplicate Substring](https://leetcode.com/problems/longest-duplicate-substring/) | the suffix-array answer and the hash answer are both correct; the hash one is twenty lines. **Write both and time them** |
| Palindromic structure | [5 · Longest Palindromic Substring](https://leetcode.com/problems/longest-palindromic-substring/) | expand-around-centre is `O(n²)`; Manacher is `O(n)` with the same maintained-window trick as Z |

**Beyond LeetCode.** [CSES Problem Set](https://cses.fi/problemset/) — the *String Algorithms* section is the best available drill for this module specifically: *Word Combinations* (trie + DP), *String Matching*, *Finding Borders*, *Finding Periods*, *Minimal Rotation*, *Longest Palindrome*, *Counting Patterns*, *Substring Distribution*. [Codeforces `strings` tag](https://codeforces.com/problemset?tags=strings) · [`string suffix structures` tag](https://codeforces.com/problemset?tags=string+suffix+structures) · [`hashing` tag](https://codeforces.com/problemset?tags=hashing).

**The drill that matters here** is writing `prefixFunction` from memory, cold, and getting it right the first time — including the `pi[matched-1]` index and the post-match fallback. It is eight lines, it is the basis of Aho–Corasick and half the string problems you will meet, and *almost nobody* can do it without a warm-up. Do that until it is automatic before spending time on suffix arrays.

---
## C++ Toolkit for This Module

*Language material from Weiss, **Data Structures and Algorithm Analysis in C++**, 4th ed., §1.2 (the `string` class), §1.7 (matrices), §12.3 (suffix arrays — Weiss covers them himself), and ch. 5 (hashing).*

### 1. `std::string` is a container, and its comparison functions matter

```cpp
int compareSubstrings(const string& text, size_t from, size_t count, const string& other) {
    // compare(pos, len, str) compares a SUBSTRING of `text` against `other`
    // WITHOUT constructing it. text.substr(from, count) == other allocates a
    // whole new string per call -- inside a binary search that is O(m lg n)
    // allocations for an O(m lg n) algorithm.
    return text.compare(from, count, other);
}
```

The three that pay for themselves in this module:
- **`compare(pos, len, str)`** — substring comparison, no allocation.
- **`s.find(t)`** — a real, tuned implementation. Reach for it before writing your own matcher, unless the point *is* to write your own.
- **`string_view`** (C++17) — a non-owning `(pointer, length)`. `sv.substr(...)` is `O(1)` and allocation-free. **Lifetime is yours to manage**: a `string_view` into a temporary dangles instantly, which is the one way it hurts.

### 2. `unsigned char` for every byte-indexed table

```cpp
array<int, 256> shiftTable{};
// shiftTable[text[i]]                        // BUG: char is signed on x86/ARM,
                                              // so bytes >= 0x80 index NEGATIVELY
// shiftTable[(unsigned char)text[i]]         // correct
```

**This never reproduces on ASCII test data** and corrupts memory on the first UTF-8 byte or Latin-1 accent. The plainness of `char`'s signedness being implementation-defined is exactly why the cast has to be habitual rather than considered.

### 3. `__int128` and the Mersenne modulus

```cpp
unsigned long long mulMod61(unsigned long long a, unsigned long long b) {
    const unsigned long long MOD = (1ULL << 61) - 1;
    const __uint128_t product = (__uint128_t)a * b;      // 122 bits, no overflow
    const unsigned long long low  = (unsigned long long)(product & MOD);
    const unsigned long long high = (unsigned long long)(product >> 61);
    const unsigned long long sum  = low + high;          // because 2^61 == 1 (mod MOD)
    return sum >= MOD ? sum - MOD : sum;
}
```

`__int128` is a **GCC/Clang extension**, not standard C++ — universally available on judges and Linux toolchains, absent on MSVC. The Mersenne form `2⁶¹ − 1` turns reduction into a shift and an add because `2⁶¹ ≡ 1 (mod 2⁶¹−1)`; with an arbitrary 61-bit prime you would need a real division. **Choosing the modulus for the arithmetic, not just for the collision rate, is the trick.**

### 4. Indices, not pointers, in node-based structures

```cpp
struct TrieNode { array<int, 26> child; bool terminal = false; };
vector<TrieNode> nodes;                      // children are indices into this
```

Three reasons, all of which bite in this module:
- **`emplace_back` may reallocate**, invalidating every outstanding `TrieNode&` and `TrieNode*`. Indices survive.
- Contiguous storage is cache-friendly, which matters when the structure is walked once per text character.
- No `delete` traversal, no ownership question, and the whole structure serialises as one `memcpy`.

The cost is that the code reads `nodes_[at].child[c]` instead of `at->child[c]`. Worth it.

### 5. Counting sort, and why stability is not optional

```cpp
void stableCountingSort(const vector<int>& source, const vector<int>& key,
                        int maxKey, vector<int>& out) {
    vector<int> count(maxKey + 2, 0);
    for (int x : source) ++count[key[x]];
    for (int v = 1; v <= maxKey + 1; ++v) count[v] += count[v - 1];
    // BACKWARDS. Iterating forwards still sorts, but REVERSES equal elements --
    // and a radix sort built on an unstable pass is simply wrong.
    for (int i = (int)source.size() - 1; i >= 0; --i)
        out[--count[key[source[i]]]] = source[i];
}
```

The suffix-array construction is a two-pass radix sort ([M05](M05-sorting.md)): sort by the right key, then **stably** by the left. Reverse the second loop and the array silently comes out wrong on inputs with ties — which is most of them.

### 6. `min` with mixed types

```cpp
size_t safeMin(const string& s, size_t start, const string& pattern) {
    // min(pattern.size(), s.size() - start) is fine -- both size_t.
    // min(pattern.size(), someInt) does NOT COMPILE: no common template argument.
    return min<size_t>(pattern.size(), s.size() - start);
}
```

`std::min` deduces one type from both arguments, so `min(size_t, int)` fails to compile. Either make both the same type or spell the template argument: `min<size_t>(a, b)`. And **`s.size() - start` underflows catastrophically when `start > s.size()`** — unsigned arithmetic, the [M02](M02-asymptotics.md) toolkit trap, and it appears constantly in string code.

### 7. Sentinels and separators

Every "concatenate two strings and run one algorithm" trick in this module needs a character that occurs in **neither** input:

| construction | why the separator matters |
|---|---|
| `P # T` for KMP/Z matching | without it, a "match" could straddle the boundary |
| `A # B` for longest common substring | without it, the answer could span both strings |
| `S # reverse(S)` for palindromes | same |
| `T $` for suffix arrays (when using the sentinel formulation) | makes no suffix a prefix of another, so ties cannot occur |

`'\x01'` is the usual choice for text; for arbitrary bytes, widen to `int` and use `-1`. **Silently assuming `#` or `$` is unused is a correctness bug waiting for the input that uses it.**

### 8. Reserve, and avoid `substr` in loops

`SuffixArray::occurrences` returns positions, not strings, and compares with `compare` rather than `substr`. A version that builds `text.substr(order_[i], m)` inside the binary search allocates `O(lg n)` strings per query and is measurably slower for no benefit. **In string code, the allocations are usually the algorithm's real complexity.**

---
## Appendix — C++ for Every Pseudocode Block

```cpp
// CONVENTIONS FOR THIS APPENDIX. CLRS indexes strings from 1; C++ indexes from 0.
// Rather than fake 1-indexing with a wasted slot, every entry below is written
// 0-indexed and each translated pseudocode line says what it was.
//
// The one place this genuinely matters is the prefix function, where CLRS's
// pi[q] becomes pi[q-1]. Mixing the two conventions inside one function is the
// most common bug in every implementation of KMP ever written, so the rule here
// is: convert ONCE, at the boundary, and never again.
using Occurrences = vector<int>;      // starting positions, 0-indexed
```

### A1 NAIVE-STRING-MATCHER

*Pseudocode: §1, "The naive matcher".*

```cpp
// NAIVE-STRING-MATCHER(T, P, n, m)
// 1  for s = 0 to n - m
// 2      if P[1:m] == T[s+1 : s+m]
// 3          print "Pattern occurs with shift" s
//
// The inner comparison on line 2 is an IMPLICIT LOOP -- CLRS is explicit that
// "x == y" costs Theta(t) where t is the length of the common prefix, i.e. it
// stops at the first mismatch. That is why the algorithm is usually fast and
// only occasionally quadratic.
Occurrences naiveStringMatcher(const string& text, const string& pattern) {
    Occurrences found;
    const int n = (int)text.size(), m = (int)pattern.size();
    if (m == 0 || m > n) return found;
    for (int shift = 0; shift <= n - m; ++shift) {          // 1
        // compare(pos, len, str), not substr(...) == str: the latter ALLOCATES a
        // fresh string on every one of the n - m + 1 shifts.
        if (text.compare(shift, m, pattern) == 0)            // 2
            found.push_back(shift);                          // 3
    }
    return found;
}
```

**Complexity. `O((n−m+1)m)`, and tight:** `T = aⁿ`, `P = aᵐ` makes every shift require all `m` comparisons, giving `Θ(n²)` at `m = ⌊n/2⌋`.

**But `O(n)` on random text (Ex. 32.1-3).** Over a `d`-ary alphabet the expected comparisons per shift are `(1 − d^{−m})/(1 − d^{−1}) ≤ 2` — a mismatch turns up after about two characters. **Both halves of that sentence are part of knowing this algorithm**, and Skiena's advice follows from the second: for `m ≤ 10`, do not try to beat it.

**What it wastes** is the whole motivation for the rest of the chapter: *"it entirely ignores information gained about the text for one value of `s` when it considers other values of `s`."* If `P = aaab` matched three characters at shift 0 and failed, then `T[4] ≠ b`, and shifts 1, 2, 3 are already excluded without touching the text again.

### A2 RABIN-KARP-MATCHER

*Pseudocode: §2.*

```cpp
// RABIN-KARP-MATCHER(T, P, n, m, d, q)
//  1  h = d^(m-1) mod q
//  2  p = 0
//  3  t = 0
//  4  for i = 1 to m                            // preprocessing
//  5      p = (d*p + P[i]) mod q                 //   Horner's rule
//  6      t = (d*t + T[i]) mod q
//  7  for s = 0 to n - m                         // matching
//  8      if p == t                              //   a hit?
//  9          if P[1:m] == T[s+1 : s+m]          //   valid, or spurious?
// 10              print "Pattern occurs with shift" s
// 11      if s < n - m
// 12          t = (d*(t - T[s+1]*h) + T[s+m+1]) mod q
//
// THE KEY ASYMMETRY: t != p (mod q) PROVES a mismatch, but t == p (mod q) proves
// nothing. So the hash is a FILTER and line 9 is not optional -- dropping it
// makes the algorithm probabilistic, which is sometimes what you want but must
// be a decision rather than an oversight.
Occurrences rabinKarpMatcher(const string& text, const string& pattern,
                             long long radix = 256, long long prime = 1000000007LL) {
    Occurrences found;
    const int n = (int)text.size(), m = (int)pattern.size();
    if (m == 0 || m > n) return found;

    // h = d^(m-1) mod q, by repeated multiplication. CLRS notes this could be
    // O(lg m) by fast exponentiation (Section 31.6) but that O(m) suffices here,
    // since the preprocessing loop is O(m) anyway.
    long long highOrder = 1;                                        // 1
    for (int i = 0; i < m - 1; ++i) highOrder = highOrder * radix % prime;

    long long patternHash = 0, windowHash = 0;                      // 2-3
    for (int i = 0; i < m; ++i) {                                   // 4
        patternHash = (patternHash * radix + (unsigned char)pattern[i]) % prime;  // 5
        windowHash  = (windowHash  * radix + (unsigned char)text[i])   % prime;   // 6
    }

    for (int shift = 0; shift + m <= n; ++shift) {                  // 7
        if (patternHash == windowHash &&                            // 8  a hit
            text.compare(shift, m, pattern) == 0)                   // 9  verify
            found.push_back(shift);                                 // 10
        if (shift + m < n) {                                        // 11
            // 12  Roll the window: drop the high-order digit, shift left, bring
            //     in the new low-order digit -- equation (32.2).
            windowHash = (windowHash
                          - (unsigned char)text[shift] % prime * highOrder % prime
                          + prime * prime) % prime;
            windowHash = (windowHash * radix + (unsigned char)text[shift + m]) % prime;
        }
    }
    return found;
}
```

**Complexity. `Θ(m)` preprocessing. Matching `Θ((n−m+1)m)` worst case** (`P = aᵐ`, `T = aⁿ`: every shift is valid and every one is verified), **expected `O(n) + O(m(v + n/q))`** where `v` is the number of valid shifts and `n/q` bounds the spurious hits. **With `v = O(1)` and `q > m`, that is `O(n + m)`.**

**`+ prime * prime` before the final `%` is not decoration.** `windowHash − something` can go negative, and `%` on a negative `long long` in C++ yields a **negative** result, which then corrupts every subsequent comparison. Adding a large enough multiple of `prime` first is the standard fix; the alternative is `((x % q) + q) % q`.

**Where Rabin–Karp beats KMP outright:**
- **many patterns of the same length** (Ex. 32.2-2) — hash them all into a set and do one lookup per window;
- **2-D matching** (Ex. 32.2-3) — hash each row of the pattern, then run 1-D Rabin–Karp over the sequence of row hashes;
- **fingerprinting** (Ex. 32.2-4) — comparing two remote files by one number, with error probability `< 1/1000` for `q > 1000n`.

None of these has a natural KMP analogue, which is why an algorithm with a worse worst case is worth learning.

### A3 FINITE-AUTOMATON-MATCHER

*Pseudocode: §3.*

```cpp
// FINITE-AUTOMATON-MATCHER(T, delta, n, m)
// 1  q = 0
// 2  for i = 1 to n
// 3      q = delta(q, T[i])
// 4      if q == m
// 5          print "Pattern occurs with shift" i - m
//
// The state after reading T[:i] is sigma(T[:i]) = the LENGTH OF THE LONGEST
// PREFIX OF P THAT IS A SUFFIX of what has been read (Theorem 32.4). So state m
// means the pattern just ended here. One table lookup per character, and the
// text pointer only moves forward: Theta(n), which is optimal.
class StringMatchingAutomaton {
public:
    // delta(q, a) = sigma(P[:q] a), equation (32.4).
    //
    // Built here in O(m * |Sigma|) using Exercise 32.4-8's identity:
    //     delta(q, a) = q + 1                 if q < m and a == P[q]
    //                 = delta(pi[q], a)       otherwise
    // -- so each row is copied from an EARLIER row and patched in one place.
    // The naive construction recomputes sigma from scratch and is O(m^3 |Sigma|).
    explicit StringMatchingAutomaton(const string& pattern)
        : pattern_(pattern), m_((int)pattern.size()),
          delta_((size_t)m_ + 1, array<int, ALPHABET>{}) {
        vector<int> pi = prefixFunctionLocal(pattern);
        for (int state = 0; state <= m_; ++state)
            for (int c = 0; c < ALPHABET; ++c) {
                if (state < m_ && c == (unsigned char)pattern_[state])
                    delta_[state][c] = state + 1;               // stay on the "spine"
                else if (state == 0)
                    delta_[state][c] = 0;                       // fall all the way back
                else
                    delta_[state][c] = delta_[pi[state - 1]][c]; // reuse an earlier row
            }
    }

    Occurrences match(const string& text) const {
        Occurrences found;
        int state = 0;                                          // 1
        for (int i = 0; i < (int)text.size(); ++i) {            // 2
            state = delta_[state][(unsigned char)text[i]];      // 3
            if (state == m_) found.push_back(i - m_ + 1);       // 4-5
        }
        return found;
    }

    int transition(int state, unsigned char c) const { return delta_[state][c]; }

private:
    static const int ALPHABET = 256;
    string pattern_;
    int m_;
    vector<array<int, ALPHABET>> delta_;

    static vector<int> prefixFunctionLocal(const string& s) {
        const int n = (int)s.size();
        vector<int> pi(n, 0);
        int matched = 0;
        for (int q = 1; q < n; ++q) {
            while (matched > 0 && s[matched] != s[q]) matched = pi[matched - 1];
            if (s[matched] == s[q]) ++matched;
            pi[q] = matched;
        }
        return pi;
    }
};
```

**Complexity. `O(m·|Σ|)` build, `Θ(n)` match, `Θ(m·|Σ|)` space.**

**`Θ(n)` matching is unbeatable, and the space is why nobody does it.** For `|Σ| = 256` and `m = 10⁵`, the table is 100 MB of `int`s. For Unicode it is not expressible. **That single problem is what KMP exists to solve**: `π` has `m` entries instead of `m|Σ|`, and the fallback that the table had precomputed is recomputed on the fly — in amortised `O(1)`, by the argument in [A4](#a4-compute-prefix-function).

**The two cases in the construction are the design.** `a = P[q]` continues the spine; anything else *reuses the row of `π[q]`*, because the automaton's behaviour after a mismatch depends only on how far the pattern falls back — not on the character. **Seeing that `δ`'s rows are `π`-related is seeing why KMP works.**

### A4 COMPUTE-PREFIX-FUNCTION

*Pseudocode: §4.*

```cpp
// COMPUTE-PREFIX-FUNCTION(P, m)
// 1  let pi[1:m] be a new array
// 2  pi[1] = 0
// 3  k = 0
// 4  for q = 2 to m
// 5      while k > 0 and P[k+1] != P[q]
// 6          k = pi[k]
// 7      if P[k+1] == P[q]
// 8          k = k + 1
// 9      pi[q] = k
// 10 return pi
//
// pi[q] = the length of the longest PROPER prefix of P that is also a suffix of
// P[:q]. For "ababaca": 0 0 1 2 3 0 1.
//
// 0-INDEXED HERE: CLRS's pi[q] is this pi[q-1], and CLRS's P[k+1] is this
// pattern[k]. Convert once, at the boundary, and never mid-function.
vector<int> computePrefixFunction(const string& pattern) {
    const int m = (int)pattern.size();
    vector<int> pi(m, 0);                                   // 1
    if (m == 0) return pi;
    pi[0] = 0;                                              // 2
    int matched = 0;                                        // 3  CLRS's k
    for (int q = 1; q < m; ++q) {                           // 4
        // 5-6  Walk DOWN the chain of borders. Lemma 32.5: the iterates
        //      pi[q], pi[pi[q]], ... are EXACTLY the set of prefixes of P that
        //      are proper suffixes of P[:q]. So this loop is an exhaustive
        //      search of the candidate fallbacks, largest first -- which is why
        //      taking the first success is correct and nothing is missed.
        while (matched > 0 && pattern[matched] != pattern[q]) matched = pi[matched - 1];
        if (pattern[matched] == pattern[q]) ++matched;      // 7-8
        pi[q] = matched;                                    // 9
    }
    return pi;                                              // 10
}

// Exercise 32.4-6: the STRONG failure function. If pattern[pi[q]] == pattern[q+1],
// falling back to pi[q] is guaranteed to fail on the same character, so fall
// further immediately. Use this on MISMATCH (line 5 of KMP-MATCHER) but the
// ordinary pi after a FULL MATCH (line 10) -- the two lines want different
// things, and using the strong version in both loses occurrences.
vector<int> computeStrongPrefixFunction(const string& pattern) {
    const int m = (int)pattern.size();
    vector<int> pi = computePrefixFunction(pattern), strong(m, 0);
    for (int q = 0; q < m; ++q) {
        if (pi[q] == 0) strong[q] = 0;
        else if (q + 1 < m && pattern[pi[q]] == pattern[q + 1]) strong[q] = strong[pi[q] - 1];
        else strong[q] = pi[q];
    }
    return strong;
}
```

**Complexity. `Θ(m)`, by the aggregate method** ([M09](M09-amortized.md)) — and this is one of the cleanest amortised arguments in CLRS:

- `matched` starts at 0 and **increases only at line 8, at most once per `for` iteration**, so its total increase is `≤ m − 1`.
- `π[k] < k` always, so **every `while` iteration strictly decreases** `matched`.
- `matched` never goes negative.

Total decrease `≤` total increase `≤ m − 1`, so **the `while` loop body executes `O(m)` times across the entire run** — not per iteration. Same shape as the binary counter in [M09](M09-amortized.md): one thing goes up by at most 1 per step, another comes down by however much, and the second is paid for by the first.

**Lemma 32.5 is what licenses the `while` loop.** `π*[q] = {π[q], π⁽²⁾[q], …, 0}` is *exactly* the set of `k < q` with `P[:k] ⊐ P[:q]`. The proof is Lemma 32.1 (overlapping suffixes are nested) plus induction, and the consequence is that walking the chain misses nothing.

### A5 KMP-MATCHER

*Pseudocode: §4.*

```cpp
// KMP-MATCHER(T, P, n, m)
//  1  pi = COMPUTE-PREFIX-FUNCTION(P, m)
//  2  q = 0                          // number of characters matched
//  3  for i = 1 to n                 // scan the text from left to right
//  4      while q > 0 and P[q+1] != T[i]
//  5          q = pi[q]              // next character does not match
//  6      if P[q+1] == T[i]
//  7          q = q + 1              // next character matches
//  8      if q == m
//  9          print "Pattern occurs with shift" i - m
// 10          q = pi[q]              // look for the next match
//
// THIS IS THE SAME LOOP AS COMPUTE-PREFIX-FUNCTION. That procedure matches P
// against ITSELF; this one matches T against P. Learn one, get both -- and the
// running-time proof transfers unchanged.
//
// THE PROPERTY THAT MAKES IT LINEAR: `i` only ever increases. The naive matcher
// rewinds the text pointer on every failed shift; KMP rewinds only `q`, which is
// bookkeeping about the pattern, not a re-read of the input. That is also why
// KMP works on a STREAM, where rewinding is not even possible.
Occurrences kmpMatcher(const string& text, const string& pattern) {
    Occurrences found;
    const int n = (int)text.size(), m = (int)pattern.size();
    if (m == 0 || m > n) return found;

    const vector<int> pi = computePrefixFunction(pattern);        // 1
    int matched = 0;                                              // 2
    for (int i = 0; i < n; ++i) {                                 // 3
        while (matched > 0 && pattern[matched] != text[i])        // 4
            matched = pi[matched - 1];                            // 5
        if (pattern[matched] == text[i]) ++matched;               // 6-7
        if (matched == m) {                                       // 8
            found.push_back(i - m + 1);                           // 9
            // 10  pi[m-1], NOT 0. Resetting to 0 would miss every OVERLAPPING
            //     occurrence: "aa" appears three times in "aaaa", not two.
            matched = pi[matched - 1];
        }
    }
    return found;
}

// Exercise 32.4-7: is `a` a cyclic rotation of `b`? Look for a in b+b.
// "braze" and "zebra" are rotations of each other. Theta(n).
bool cyclicRotation(const string& a, const string& b) {
    return a.size() == b.size() && !kmpMatcher(b + b, a).empty();
}
```

**Complexity. `Θ(m) + Θ(n) = Θ(n + m)`, and `Θ(m)` space.** The matching bound is Ex. 32.4-4, by the identical aggregate argument: `matched` rises at most once per text character (`≤ n` total) and every `while` iteration lowers it.

**Why `π` beats `δ`.** The automaton stores `Θ(m|Σ|)` transitions so each step is one lookup; KMP stores `Θ(m)` and recomputes the transition, but the recomputation is *free on average* by the amortised argument. **`|Σ|` disappears from both the time and the space, and the only price is that the per-character cost is amortised rather than worst-case `O(1)`.** For a real-time system that distinction matters; for everything else it does not.

**KMP is the streaming matcher.** Because `i` never rewinds and the state is one integer, KMP runs over a file, a socket, or a generator, with `O(m)` memory and no buffering. Boyer–Moore, which jumps forward and reads backward, cannot.

### A6 The Z-algorithm

*Pseudocode: §5 (not in CLRS; the standard alternative to `π`).*

```cpp
// z[i] = length of the longest substring starting at i that is also a PREFIX of
// s. Convention: z[0] = |s|.
//
//     s = a a b x a a b
//     z = 7 1 0 0 3 1 0
//
// THE WINDOW [left, right) is the rightmost prefix-match discovered so far:
// s[left, right) == s[0, right - left). For an i inside that window, the answer
// at the CORRESPONDING OFFSET z[i - left] is already known, and it is valid up to
// the window's edge -- so min(right - i, z[i - left]) comes free, and only the
// part sticking out past `right` costs comparisons.
//
// Dropping the min() -- writing z[i] = z[i - left] -- gives correct answers on
// most inputs and wrong ones exactly where it matters. The cap is not optional.
vector<int> zAlgorithm(const string& s) {
    const int n = (int)s.size();
    vector<int> z(n, 0);
    if (n == 0) return z;
    z[0] = n;
    int left = 0, right = 0;
    for (int i = 1; i < n; ++i) {
        if (i < right) z[i] = min(right - i, z[i - left]);          // the free part
        while (i + z[i] < n && s[z[i]] == s[i + z[i]]) ++z[i];      // the paid part
        if (i + z[i] > right) { left = i; right = i + z[i]; }       // extend the window
    }
    return z;
}

// Matching: run Z over pattern + separator + text and look for z >= m.
// The separator must occur in NEITHER string, or a "match" could straddle it.
Occurrences zMatcher(const string& text, const string& pattern,
                     char separator = '\x01') {
    Occurrences found;
    const int m = (int)pattern.size();
    if (m == 0 || m > (int)text.size()) return found;
    const vector<int> z = zAlgorithm(pattern + separator + text);
    for (int i = m + 1; i < (int)z.size(); ++i)
        if (z[i] >= m) found.push_back(i - m - 1);
    return found;
}
```

**Complexity. `Θ(n)`**, by the same aggregate argument yet again: every *paid* comparison that succeeds pushes `right` forward, `right` never rewinds, and it is bounded by `n`. So the total explicit comparison work over the whole run is `O(n)`.

**`Z` and `π` are interconvertible**, so neither is more powerful. Choose by what the problem is *asking*:

| the question sounds like | use |
|---|---|
| "how much of the prefix reappears at position `i`" | **Z** |
| "how far do I fall back on a mismatch" | **π** |
| streaming, or many patterns (Aho–Corasick) | **π** |
| comparing suffixes, periodicity, string equality queries | **Z** |

**Z is easier to write correctly under pressure**, because the loop has no fallback chain — just a window and a comparison. That is a real consideration in an interview.

### A7 Boyer–Moore–Horspool

*Pseudocode: §6 (Skiena §21.3).*

```cpp
// The bad-character rule alone: about fifteen lines, no worst-case guarantee,
// and the fastest exact matcher in practice for m > ~10.
//
// Skiena: "Suppose the pattern is abracadabra, and the eleventh character of the
// text is x. This pattern cannot possibly match from any of the first eleven
// starting positions... If we get very lucky, only n/m characters need ever be
// tested." That makes it the ONLY SUBLINEAR algorithm in this module -- a
// left-to-right matcher must at minimum read every character.
Occurrences horspoolMatcher(const string& text, const string& pattern) {
    Occurrences found;
    const int n = (int)text.size(), m = (int)pattern.size();
    if (m == 0 || m > n) return found;

    // Default shift = m: a character absent from the pattern cannot be part of
    // any match, so everything up to and including it can be skipped.
    array<int, 256> shiftFor;
    shiftFor.fill(m);
    // The LAST character is deliberately excluded: including it would give a
    // shift of 0 for that character and the outer loop would never advance.
    for (int i = 0; i < m - 1; ++i)
        shiftFor[(unsigned char)pattern[i]] = m - 1 - i;

    int at = 0;
    while (at + m <= n) {
        int j = m - 1;
        while (j >= 0 && pattern[j] == text[at + j]) --j;    // RIGHT TO LEFT
        if (j < 0) found.push_back(at);
        // The shift depends on the text character under the pattern's LAST
        // position -- not on where the mismatch occurred. That is what keeps the
        // table one-dimensional and the algorithm short. Full Boyer-Moore adds
        // the GOOD-SUFFIX rule (what the matched tail tells you) and takes the
        // larger of the two shifts, recovering an O(n + rm) worst case.
        at += shiftFor[(unsigned char)text[at + m - 1]];
    }
    return found;
}
```

**Complexity. `O(m + |Σ|)` preprocessing; `Θ(nm)` worst case; sublinear in practice.** Full Boyer–Moore is `O(n + rm)` where `r` is the number of occurrences (Skiena).

**`(unsigned char)` on every table index.** `char` is signed on x86 and ARM, so any byte `≥ 0x80` — the first UTF-8 continuation byte, any Latin-1 accent — indexes the array *negatively*. It never shows up in ASCII tests.

**The lesson worth transferring out of this module.** KMP is `Θ(n)` and touches every character. Horspool is `Θ(nm)` in theory and touches a fraction of them. **On real text Horspool wins**, and that is not a paradox: asymptotic worst case and expected running time on the inputs you actually have are different questions. Skiena's advice — *"For long patterns and texts, I recommend that you use the best implementation of Boyer–Moore that you can find"* — is about the second question.

### A8 Trie and Aho–Corasick

*Pseudocode: §7 (Skiena §15.3, §21.3).*

```cpp
// AHO-CORASICK. Find every occurrence of every one of k patterns in ONE pass
// over the text, in O(n + occurrences).
//
// IT IS KMP WITH THE PATTERN REPLACED BY A TRIE. A node's SUFFIX LINK points to
// the node for the longest proper suffix of that node's string that is also in
// the trie -- which, when there is only one pattern and the trie is a path, is
// EXACTLY pi. Everything you know about the prefix function transfers; the only
// genuinely new piece is the OUTPUT LINK, needed because one pattern can be a
// suffix of another ("he" inside "she").
class AhoCorasickAutomaton {
public:
    AhoCorasickAutomaton() : nodes_(1) {}

    void addPattern(const string& pattern, int id) {
        int at = 0;
        for (unsigned char ch : pattern) {
            if (nodes_[at].next[ch] < 0) {
                nodes_[at].next[ch] = (int)nodes_.size();
                nodes_.emplace_back();
            }
            at = nodes_[at].next[ch];
        }
        nodes_[at].patternIds.push_back(id);
    }

    // BFS ORDER IS MANDATORY: a node's suffix link is derived from its PARENT's,
    // which must already be final. A depth-first build would read half-finished
    // links and produce an automaton that is wrong only on some inputs.
    void build() {
        queue<int> frontier;
        for (int ch = 0; ch < ALPHABET; ++ch) {
            int& child = nodes_[0].next[ch];
            if (child < 0) child = 0;                    // missing root edge self-loops
            else { nodes_[child].suffixLink = 0; frontier.push(child); }
        }
        while (!frontier.empty()) {
            const int at = frontier.front(); frontier.pop();
            const int link = nodes_[at].suffixLink;
            // The output link: the nearest node reachable by suffix links that is
            // itself the end of a pattern. Following THIS chain at match time --
            // rather than the suffix-link chain -- is what keeps matching
            // O(n + occurrences) instead of O(n * depth).
            nodes_[at].outputLink =
                nodes_[link].patternIds.empty() ? nodes_[link].outputLink : link;

            for (int ch = 0; ch < ALPHABET; ++ch) {
                int& child = nodes_[at].next[ch];
                if (child < 0) {
                    // GOTO-BY-FAILURE, precomputed into the table. After build(),
                    // next[] is a TOTAL transition function, so the matcher has no
                    // fallback loop at all -- it is literally
                    // FINITE-AUTOMATON-MATCHER (A3) over a trie, and it is built
                    // from suffix links exactly as Exercise 32.4-8 builds delta
                    // from pi.
                    child = nodes_[link].next[ch];
                } else {
                    nodes_[child].suffixLink = nodes_[link].next[ch];
                    frontier.push(child);
                }
            }
        }
    }

    // (end position, pattern id) for every occurrence.
    vector<pair<int,int>> match(const string& text) const {
        vector<pair<int,int>> hits;
        int at = 0;
        for (int i = 0; i < (int)text.size(); ++i) {
            at = nodes_[at].next[(unsigned char)text[i]];      // one array read
            for (int node = at; node > 0; node = nodes_[node].outputLink)
                for (int id : nodes_[node].patternIds) hits.push_back({i, id});
        }
        return hits;
    }

    int nodeCount() const { return (int)nodes_.size(); }

private:
    static const int ALPHABET = 256;
    struct Node {
        array<int, ALPHABET> next;
        int suffixLink = 0, outputLink = 0;
        vector<int> patternIds;
        Node() { next.fill(-1); }
    };
    // A vector of nodes with INTEGER children, not pointers: emplace_back may
    // reallocate, which would invalidate every outstanding Node& or Node*.
    // Indices survive, and the storage is contiguous.
    vector<Node> nodes_;
};
```

**Complexity. `O(Σ|Pᵢ|·|Σ|)` to build (time and space), `O(n + occurrences)` to match — all `k` patterns in a single pass.** Against `O(k(n+m))` for running a separate matcher per pattern, that is the difference between feasible and not once `k` is in the thousands. Skiena notes this is what the original `fgrep` did.

**Aho–Corasick's suffix link is KMP's `π`.** With one pattern the trie is a path, the suffix link from depth `q` points to depth `π[q]`, and `build()` reduces to `COMPUTE-PREFIX-FUNCTION`. **This is the single most useful structural fact in the module**, because it means one idea covers exact matching, multi-pattern matching, and the finite automaton.

**Output links are the part people omit and then debug for an hour.** Without them, searching for `{he, she, his, hers}` in `ushers` reports `she` and `hers` but silently misses the `he` inside `she`.

### A9 COMPUTE-SUFFIX-ARRAY

*Pseudocode: §8.*

```cpp
// COMPUTE-SUFFIX-ARRAY(T, n): sort all n suffixes lexicographically, storing
// their starting positions.
//
// Sorting them directly is O(n^2 lg n), because each comparison is O(n). The
// doubling method rests on one observation (CLRS 32.5): if the FIRST HALVES of
// two strings differ, the second halves cannot matter. So give each length-l
// substring an integer RANK, and sort length-2l substrings by the PAIR of ranks
// of their halves -- pairs of integers in [0, n], which counting sort handles in
// Theta(n).
//
//   line 8 / line 18   sort by (left-rank, right-rank)
//   MAKE-RANKS         re-number the sorted array, equal pairs sharing a rank
//   l doubles          ceil(lg n) rounds
//
// With comparison sorting: O(n lg^2 n). With RADIX SORT -- counting sort on the
// right key, then stably on the left -- Theta(n lg n). CLRS is explicit that this
// is why the ranks are kept as small integers.
struct SuffixArrayResult {
    vector<int> order;      // SA:   order[i] = start of the i-th smallest suffix
    vector<int> rank;       // rank: the inverse permutation
};

SuffixArrayResult computeSuffixArray(const string& text) {
    const int n = (int)text.size();
    SuffixArrayResult out;
    if (n == 0) return out;

    // THE SENTINEL. The doubling method sorts CYCLIC SHIFTS, and cyclic order is
    // not suffix order: a shift wraps around to the start of the text, a suffix
    // just ends. Appending a character SMALLER THAN EVERY REAL ONE makes every
    // comparison that would have wrapped terminate at the sentinel instead, which
    // collapses the two orders onto each other. Sort m = n+1 shifts, then discard
    // entry 0 -- the sentinel by itself, always lexicographically first.
    //
    // Omitting this produces an array that is right on many inputs and wrong on
    // most periodic ones, which is the worst way for it to be wrong.
    const string padded = text + '\0';
    const int m = n + 1;
    vector<int> order(m), rank(m), nextRank(m), shifted(m), count(max(256, m) + 1, 0);

    // Lines 2-8: rank single characters, sort with counting sort.
    for (int i = 0; i < m; ++i) ++count[(unsigned char)padded[i]];
    for (int v = 1; v <= 256; ++v) count[v] += count[v - 1];
    for (int i = m - 1; i >= 0; --i) order[--count[(unsigned char)padded[i]]] = i;
    rank[order[0]] = 0;
    for (int i = 1; i < m; ++i)
        rank[order[i]] = rank[order[i - 1]] + (padded[order[i]] != padded[order[i - 1]]);

    // Lines 10-19: double the length each round.
    for (int half = 1; half < m; half <<= 1) {
        // Sorting by the RIGHT key is free: rotating the current order backwards
        // by `half` already yields exactly that order. Only the stable pass on
        // the left key remains -- and STABILITY IS NOT OPTIONAL here, it is what
        // makes a two-pass radix sort correct (M05).
        for (int i = 0; i < m; ++i) {
            shifted[i] = order[i] - half;
            if (shifted[i] < 0) shifted[i] += m;
        }
        fill(count.begin(), count.begin() + m + 1, 0);
        for (int i = 0; i < m; ++i) ++count[rank[i]];
        for (int v = 1; v <= m; ++v) count[v] += count[v - 1];
        for (int i = m - 1; i >= 0; --i) order[--count[rank[shifted[i]]]] = shifted[i];

        // MAKE-RANKS: equal (left, right) pairs share a rank; otherwise the rank
        // increases by one.
        nextRank[order[0]] = 0;
        for (int i = 1; i < m; ++i) {
            const pair<int,int> here{rank[order[i]],     rank[(order[i] + half) % m]};
            const pair<int,int> prev{rank[order[i - 1]], rank[(order[i - 1] + half) % m]};
            nextRank[order[i]] = nextRank[order[i - 1]] + (here != prev);
        }
        rank.swap(nextRank);
        // Early exit: once every rank is distinct, the order is final. Often this
        // fires long before ceil(lg n) rounds -- Exercise 32.5-2.
        if (rank[order[m - 1]] == m - 1) break;
    }

    out.order.assign(order.begin() + 1, order.end());    // drop the sentinel shift
    out.rank.assign(n, 0);
    for (int i = 0; i < n; ++i) out.rank[out.order[i]] = i;
    return out;
}
```

**Complexity. `Θ(n lg n)` time, `Θ(n)` space.** `⌈lg n⌉` rounds, each `Θ(n)` thanks to counting sort. With `std::sort` instead it is `O(n lg² n)` — still perfectly usable, and about ten lines shorter.

**The sentinel is not optional, and leaving it out is a subtle bug.** The `% m` formulation sorts *cyclic shifts*, and cyclic order is **not** suffix order — a shift wraps back to the front of the text where a suffix simply ends. Appending a character smaller than every real one makes each would-be wrap terminate at the sentinel, which collapses the two orders. Without it, `ratatat` comes out in the wrong order and the LCP array is wrong with it. **This implementation was written without the sentinel first, and a randomized check against a brute-force suffix sort is what caught it** — which is the argument for having such a check at all.

**Linear-time constructions exist** — DC3/skew and SA-IS, and CLRS Problem 32-2 develops one — and are what production code (and every genome aligner) uses. **They are considerably harder, and this is the one you should be able to write.**

**Why the suffix array is the right default over the suffix tree.** Skiena: *"suffix arrays are typically as fast or faster to search than suffix trees. They also use much less memory, typically by a factor of four. Each suffix is represented completely by its unique starting position and can be read off as needed using a single reference copy of the input string."*

### A10 COMPUTE-LCP

*Pseudocode: §8, "Computing the LCP array".*

```cpp
// COMPUTE-LCP(T, SA, n): lcp[i] = length of the longest common prefix of the
// (i-1)-st and i-th suffixes in sorted order. lcp[0] = 0 by definition.
//
// KASAI'S ALGORITHM. The trick is to walk the suffixes in TEXT order, not sorted
// order, and carry the previous answer forward.
//
// Lemma 32.8: if the suffix starting at i-1 has LCP l > 1 with its predecessor,
// then the suffix at i -- the same string with its first character removed -- has
// LCP >= l - 1. So `carry` DROPS BY AT MOST ONE per step, and rises only through
// explicit character comparisons. Total rise <= n, total drop <= n, hence
// Theta(n) comparisons in all: the same amortised shape as A4 and A6.
vector<int> computeLcp(const string& text, const vector<int>& order) {
    const int n = (int)text.size();
    vector<int> lcp(n, 0), rank(n, 0);
    if (n == 0) return lcp;
    for (int i = 0; i < n; ++i) rank[order[i]] = i;         // 2-3  the inverse of SA

    int carry = 0;                                         // 5
    for (int i = 0; i < n; ++i) {                          // 6
        if (rank[i] == 0) { carry = 0; continue; }         // 7  (lcp[0] = 0)
        const int previous = order[rank[i] - 1];           // 8
        while (i + carry < n && previous + carry < n &&    // 10
               text[i + carry] == text[previous + carry]) ++carry;   // 11
        lcp[rank[i]] = carry;                              // 12
        // 13-14  THE ENTIRE ALGORITHM IS THIS LINE. Replacing it with
        //        `carry = 0` leaves the result CORRECT and the running time
        //        Theta(n^2) -- which is exactly why it has to be understood
        //        rather than memorised.
        if (carry > 0) --carry;
    }
    return lcp;
}
```

**Complexity. `Θ(n)`.**

**The counter-intuitive part is the loop order.** One naturally wants to walk the *sorted* array and compare adjacent suffixes — which is `Θ(n²)`, because adjacent sorted suffixes share nothing useful with the *next* adjacent pair. Walking in **text order** means consecutive iterations handle `T[i:]` and `T[i+1:]`, which differ by one character, and Lemma 32.8 turns that into a bound on how much can be lost.

**Lemma 32.8 in one sentence:** dropping the first character of a suffix drops its LCP with *its* predecessor by at most 1 — and if some other suffix now sits between them in sorted order, that only *increases* the common prefix with the immediate predecessor.

### A11 What the suffix array buys

*Pseudocode: §9, "the payoff table".*

```cpp
// Every application below is a few lines ON TOP of A9 + A10 -- which is the
// argument for building the structure at all.

// SEARCH. Every occurrence of P starts some suffix of T, and P occurs there iff
// P is a PREFIX of that suffix. Sorted order puts all suffixes sharing a prefix
// ADJACENT, so the occurrences form one CONTIGUOUS BLOCK. Binary search for it.
// O(m lg n + k).
Occurrences suffixArraySearch(const string& text, const vector<int>& order,
                              const string& pattern) {
    Occurrences found;
    const int n = (int)text.size(), m = (int)pattern.size();
    if (m == 0 || m > n) return found;
    const auto suffixBelow = [&](int start, const string& p) {
        return text.compare(start, min<size_t>(p.size(), (size_t)(n - start)), p) < 0;
    };
    int lo = (int)(lower_bound(order.begin(), order.end(), pattern, suffixBelow)
                   - order.begin());
    for (int i = lo; i < n && text.compare(order[i], m, pattern) == 0; ++i)
        found.push_back(order[i]);
    return found;
}

// LONGEST REPEATED SUBSTRING. A substring occurring twice is a common prefix of
// two suffixes; those two suffixes are adjacent in sorted order or bracket a run
// of suffixes sharing it -- either way the answer is max(lcp).
string longestRepeated(const string& text, const vector<int>& order,
                       const vector<int>& lcp) {
    int best = 0, at = -1;
    for (int i = 1; i < (int)text.size(); ++i)
        if (lcp[i] > best) { best = lcp[i]; at = order[i]; }
    return at < 0 ? string() : text.substr(at, best);
}

// NUMBER OF DISTINCT SUBSTRINGS. Every substring is a prefix of exactly one
// suffix, so naively there are n(n+1)/2 of them; but a prefix shared with the
// PREVIOUS sorted suffix was already counted, and there are exactly lcp[i] such.
// Subtract. One line for a question that looks Theta(n^2).
long long distinctSubstrings(int n, const vector<int>& lcp) {
    long long total = (long long)n * (n + 1) / 2;
    for (int i = 1; i < n; ++i) total -= lcp[i];
    return total;
}

// LONGEST COMMON SUBSTRING of two strings. Build one suffix array over
// a + separator + b and take the largest lcp between ADJACENT suffixes coming
// from DIFFERENT sides of the separator.
//
// The separator must occur in NEITHER input, or a "common" substring could
// straddle it and the answer would be nonsense.
string longestCommonSubstringViaSuffixArray(const string& a, const string& b,
                                            char separator = '\x01') {
    if (a.empty() || b.empty()) return {};
    const string joined = a + separator + b;
    const SuffixArrayResult sa = computeSuffixArray(joined);
    const vector<int> lcp = computeLcp(joined, sa.order);
    const int split = (int)a.size();
    int best = 0, at = -1;
    for (int i = 1; i < (int)joined.size(); ++i) {
        const int left = sa.order[i - 1], right = sa.order[i];
        if ((left < split) == (right < split)) continue;   // same side: skip
        if (lcp[i] > best) { best = lcp[i]; at = right; }
    }
    return at < 0 ? string() : joined.substr(at, best);
}
```

**Complexity.** All of these are `O(n)` *after* an `O(n lg n)` build, except search at `O(m lg n + k)`.

**The distinct-substring formula is worth deriving once and then never forgetting.** It reduces a quantity that is `Θ(n²)` in size to a single pass over the LCP array — and it generalises: the number of distinct substrings of length exactly `L` is `Σ max(0, min(len_i, L) − ...)`, and the `k`-th smallest substring falls out of the same walk.

**When *not* to build this.** For "is there a repeated substring of length `L`" the property is **monotone in `L`**, so binary search `L` and test with rolling hashes ([M07](M07-hashing.md), and the body implementation above) — `O(n lg n)` expected, about twenty lines, and usually faster in practice than a suffix array. **Knowing the heavier tool exists and choosing the lighter one is the skill**; reaching for a suffix array reflexively is not.

*Verified:* on 500 random strings (`n ≤ 200`, alphabet sizes 2–26) `computeSuffixArray` matched a brute-force lexicographic sort of all suffixes, `computeLcp` matched direct character comparison, `suffixArraySearch` agreed with `naiveStringMatcher` on 2 000 random patterns, and `distinctSubstrings` matched an explicit `set<string>` count. `naiveStringMatcher`, `rabinKarpMatcher`, `StringMatchingAutomaton`, `kmpMatcher`, `zMatcher`, `horspoolMatcher` and `AhoCorasickAutomaton` all returned identical occurrence lists on 3 000 random (text, pattern) pairs including adversarial `aⁿ`/`aᵐ` cases, and `computePrefixFunction` reproduced CLRS's `π = 0 0 1 2 3 0 1` for `ababaca`.


---

*Next: [M19 — NP-Completeness and Reductions](M19-np-completeness.md) (CLRS 34 + Skiena 11) — what it means for a problem to be hard, how to prove it, and what to do about it.*
