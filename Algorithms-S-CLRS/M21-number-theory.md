# Module 21 — Number-Theoretic Algorithms

**Sources:** CLRS 4e ch. 31 (Number-Theoretic Algorithms) · Skiena 3e §16.8 (Factoring and Primality Testing), §16.9 (Arbitrary-Precision Arithmetic), §21.6 (Cryptography)

---

## Big Idea

**This is the one module where the size of the *numbers* is the input size, not the count of them.** CLRS opens by changing the ground rules, and everything downstream depends on it:

> *"In this chapter, a 'large input' typically means an input containing 'large integers' rather than an input containing 'many integers' (as for sorting). Thus, the size of an input depends on the number of bits required to represent that input, not just the number of integers in the input. An algorithm with integer inputs `a₁, a₂, …, aₖ` is a **polynomial-time algorithm** if it runs in time polynomial in `lg a₁, lg a₂, …, lg aₖ` — that is, polynomial in the lengths of its binary-encoded inputs."*

**Get this wrong and every complexity claim in the chapter inverts.** Trial division to `√n` looks polynomial and is *exponential*: with `β = ⌈lg(n+1)⌉` bits of input, `√n = Θ(2^(β/2))`. Meanwhile Euclid's algorithm — which looks like it could run `n` times — makes `O(lg b)` calls, which is *linear in the input size*. **The same trap you met as "pseudo-polynomial" in [M11](M11-dynamic-programming.md) and [M19](M19-np-completeness.md), now as the default reading.**

**The whole chapter is one asymmetry, and it is worth a fortune.** From Skiena:

> *"The dual problems of integer factorization and primality testing have surprisingly many applications for a problem long suspected of being only of mathematical interest. The security of the RSA public-key cryptography system is based on the computational intractability of factoring large integers."*

And CLRS, more precisely:

> *"These schemes are feasible because we can **find large primes quickly**, and they are secure because we do not know how to **factor the product of large primes** efficiently."*

| Operation | Cost | Consequence |
|---|---|---|
| **find** a random 1024-bit prime | `~710` Miller–Rabin tests, milliseconds | you can make an RSA key |
| **multiply** two 1024-bit primes | one multiplication | you can publish `n = pq` |
| **factor** a 2048-bit `n` | no known feasible method | nobody can undo it |

**Everything else in the module is machinery for exploiting that gap**, and it stacks in a strict order — each layer is built from the one below, and every layer is `O(lg n)` arithmetic operations or better:

```
    Euclid  →  extended Euclid  →  modular inverse  →  CRT
                                        ↓
    repeated squaring (aᵇ mod n)  →  Fermat/Euler  →  Miller-Rabin  →  RSA
```

**And two theorems carry all the weight.** Fermat's little theorem (`a^(p−1) ≡ 1 (mod p)` for prime `p`) gives a *one-line* test that a number is composite. Its failure mode — Carmichael numbers — is fixed by one extra observation: **if `x² ≡ 1 (mod n)` and `x ≢ ±1`, then `n` is composite.** That single corollary is the entire difference between the naive pseudoprime test and Miller–Rabin.

**Remember months later:** *input size is `lg n`, not `n`. `gcd(a,b) = gcd(b, a mod b)`, `O(lg b)` calls, worst case consecutive Fibonacci numbers (Lamé). Extended Euclid returns `(d, x, y)` with `ax + by = d` — and `x` is `a⁻¹ mod n` exactly when `gcd(a,n) = 1`. `ax ≡ b (mod n)` has `gcd(a,n)` solutions or none. CRT: pairwise-coprime moduli ⟺ `Zₙ ≅ Zₙ₁ × ⋯ × Zₙₖ`. `aᵇ mod n` by repeated squaring, `O(lg b)`. Miller–Rabin = Fermat + "no nontrivial square root of 1", error `≤ 2⁻ˢ`, no bad inputs. RSA: `n = pq`, `ed ≡ 1 (mod φ(n))`, `M^(ed) ≡ M (mod n)` by Fermat + CRT.*

---

## What You Should Be Able To Do After This Chapter

- State the **input-size convention** for this chapter and use it to explain why trial division is exponential and Euclid is not.
- Write `EUCLID` and prove the **GCD recursion theorem** `gcd(a, b) = gcd(b, a mod b)`.
- State **Lamé's theorem** and name the worst-case inputs for Euclid.
- Write `EXTENDED-EUCLID` from memory, explain the back-substitution `(x, y) = (y′, x′ − ⌊a/b⌋y′)`, and trace it on `(99, 78)`.
- Use extended Euclid to compute a **modular inverse**, and say exactly when one exists.
- State **Theorem 31.2** (`gcd(a,b)` is the smallest positive `ax + by`) and use it — this is Bézout, and it is what several interview problems are secretly about.
- Say what `Zₙ`, `Zₙ*`, and `φ(n)` are, compute `φ` from the factorisation, and give `φ(p)` and `φ(pᵉ)`.
- Characterise the solutions of `ax ≡ b (mod n)`: **`gcd(a,n)` of them or none**, spaced `n/gcd(a,n)` apart.
- State and apply the **Chinese remainder theorem**, and construct the solution via the `cᵢ = mᵢ(mᵢ⁻¹ mod nᵢ)` basis.
- Write `MODULAR-EXPONENTIATION` both recursively and iteratively, and say why it is `O(lg b)` multiplications.
- State **Euler's** and **Fermat's** theorems and use Fermat to get a modular inverse when `n` is prime.
- Explain **why the naive pseudoprime test fails** — Carmichael numbers — and what Miller–Rabin adds.
- Write `WITNESS` and `MILLER-RABIN`, explain the four shapes of the sequence `X`, and state the `2⁻ˢ` error bound.
- Reproduce the **RSA key-generation** procedure and prove correctness (`M^(ed) ≡ M (mod n)`).
- Say what breaks RSA, and what is *not* known about the converse.
- Explain the **prime number theorem** well enough to say how many candidates you expect to test to find a 1024-bit prime.
- Implement the **binary GCD** (Problem 31-1) and say when it beats Euclid.
- Recognise when a competitive-programming problem is secretly Bézout, secretly CRT, or secretly a modular inverse.

---

## Part 1 — The Ground Rules: Bit Operations vs Arithmetic Operations

**Two clocks run in this chapter, and CLRS reports both.**

> *"Most of this book considers the elementary arithmetic operations (multiplications, divisions, or computing remainders) as primitive operations that take one unit of time… Elementary operations can be time-consuming, however, when their inputs are large. It thus becomes appropriate to measure how many **bit operations** a number-theoretic algorithm requires. In this model, multiplying two `β`-bit integers by the ordinary method uses `Θ(β²)` bit operations."*

| | arithmetic operations | bit operations |
|---|---|---|
| add / subtract `β`-bit | 1 | `Θ(β)` |
| multiply / divide `β`-bit | 1 | `Θ(β²)` (schoolbook) |
| `EUCLID(a, b)` | `O(lg b)` | `O(β³)`, and `O(β²)` with care (Problem 31-2) |
| `MODULAR-EXPONENTIATION` | `O(β)` | `O(β³)` |
| `MILLER-RABIN(n, s)` | `O(sβ)` | `O(sβ³)` |

> *"Faster methods are known. For example, a simple divide-and-conquer method for multiplying two `β`-bit integers has a running time of `Θ(β^lg 3)`, and `O(β lg β lg lg β)` time is possible. For practical purposes, however, the `Θ(β²)` algorithm is often best."*

**`Θ(β^lg 3)` is Karatsuba — you wrote it in [M03](M03-divide-conquer.md)**, and `O(β lg β lg lg β)` is Schönhage–Strassen via FFT ([M23](M23-matrices-fft.md)). The practical crossover for schoolbook → Karatsuba is around 300–600 bits in real libraries, which is *below* RSA key sizes — so production big-integer code does use them.

### Unified Understanding

**CLRS emphasis:** all of it — the definitions, the groups, every theorem and proof, and all five algorithms. This module is essentially CLRS 31 with C++ attached.

**Skiena emphasis:** two things CLRS does not give you. (1) The **engineering framing** — what libraries exist (PARI, NTL, MIRACL), why hash tables want prime sizes, how PGP actually generates keys. (2) The **complexity-theoretic punchline** about `PRIMES`, which is a genuinely great story and appears in Part 8.

---

## Part 2 — Divisibility, Primes, and the GCD (CLRS 31.1)

**Definitions, fast.**

- `d | a` ("`d` divides `a`") means `a = kd` for some integer `k`. Every integer divides `0`.
- The **trivial divisors** of `a` are `1` and `a`; the others are its **factors**.
- `a > 1` is **prime** if its only divisors are trivial, **composite** otherwise. *"We call the integer 1 a **unit**, and it is neither prime nor composite."*
- **Division theorem (31.1):** for any `a` and any `n > 0` there are unique `q, r` with `0 ≤ r < n` and `a = qn + r`. `q = ⌊a/n⌋`, `r = a mod n`.
- `[a]ₙ = {a + kn : k ∈ Z}` is the **equivalence class mod `n`**, and `Zₙ = {0, 1, …, n−1}` is the set of them — *"you should keep the underlying equivalence classes in mind, however."*

> **The equivalence-class view is not pedantry; it is what makes `a ≡ b (mod n)` behave like `=`.** Addition, subtraction and multiplication all descend to `Zₙ` because `a ≡ a′` and `b ≡ b′` imply `a+b ≡ a′+b′` and `ab ≡ a′b′`. **Division does not**, and the rest of the module is mostly about repairing that.

### The gcd, and the theorem that does the real work

`gcd(a, b)` is the largest common divisor, with `gcd(0,0) = 0` by convention. The elementary identities:

```
gcd(a,b) = gcd(b,a) = gcd(−a,b) = gcd(|a|,|b|)
gcd(a,0) = |a|          gcd(a,ka) = |a|
```

**Theorem 31.2 is the one to remember**, because it is what turns the gcd from a number into a *tool*:

> *"If `a` and `b` are any integers, not both zero, then `gcd(a, b)` is the **smallest positive element of the set `{ax + by : x, y ∈ Z}`** of linear combinations of `a` and `b`."*

**This is Bézout's identity, and it is the whole basis of extended Euclid.** The proof is short and worth carrying: let `s` be the smallest positive combination `ax + by`. Then `a mod s = a − ⌊a/s⌋s = a(1 − ⌊a/s⌋x) + b(−⌊a/s⌋y)` is *also* a combination, and it is `< s`, so it must be `0`. Hence `s | a`, and by symmetry `s | b`, so `s ≤ gcd(a,b)`. But `gcd(a,b)` divides any combination, so `gcd(a,b) | s`, giving `gcd(a,b) ≤ s`. ∎

**Three corollaries, all used later:**

- **31.3:** if `d | a` and `d | b` then `d | gcd(a,b)`. (Common divisors are not merely *smaller* than the gcd — they *divide* it.)
- **31.4:** `gcd(an, bn) = n·gcd(a,b)`.
- **31.5:** if `n | ab` and `gcd(a,n) = 1` then `n | b`.

**Relatively prime** means `gcd(a,b) = 1`. **Theorem 31.6:** `gcd(ab, p) = 1` **iff** `gcd(a,p) = 1` and `gcd(b,p) = 1`. **Theorem 31.7:** if `p` is prime and `p | ab` then `p | a` or `p | b` — from which **Theorem 31.8, unique prime factorisation**, follows.

> **Where you will actually use Bézout.** *"`ax + by = c` has an integer solution iff `gcd(a,b) | c`"* is the entire content of [365 · Water and Jug Problem](https://leetcode.com/problems/water-and-jug-problem/) and [1250 · Check If It Is a Good Array](https://leetcode.com/problems/check-if-it-is-a-good-array/). Neither problem mentions number theory. Both are one call to `gcd`.

---

## Part 3 — Euclid's Algorithm (CLRS 31.2)

**Why not just factor both numbers and take `min` exponents?** Equation (31.13) says you could:

```
gcd(a, b) = p₁^min(e₁,f₁) · p₂^min(e₂,f₂) ⋯
```

> *"The best algorithms to date for factoring do not run in polynomial time. Thus, this approach to computing greatest common divisors seems unlikely to yield an efficient algorithm."*

**That sentence is the shape of the whole module: gcd is easy, factoring is hard, and confusing them is the mistake.**

### Theorem 31.9 (GCD recursion theorem)

> For any nonnegative `a` and positive `b`: **`gcd(a, b) = gcd(b, a mod b)`.**

**Proof, both directions.** Let `d = gcd(a,b)`. Then `d | a`, `d | b`, and `a mod b = a − qb` is a linear combination of `a` and `b`, so `d | (a mod b)`. By Corollary 31.3, `d | gcd(b, a mod b)`. Conversely let `d = gcd(b, a mod b)`; since `a = qb + (a mod b)`, `a` is a combination of `b` and `a mod b`, so `d | a`, hence `d | gcd(a,b)`. Two integers that divide each other and are both nonnegative are equal. ∎

```
EUCLID(a, b)
1   if b == 0
2       return a
3   else return EUCLID(b, a mod b)
```

→ **C++ implementation:** [A1 EUCLID](#a1-euclid)

```
EUCLID(30, 21) = EUCLID(21, 9) = EUCLID(9, 3) = EUCLID(3, 0) = 3
```

### Lamé's theorem — the Fibonacci connection

**Lemma 31.10.** *"If `a > b ≥ 1` and the call `EUCLID(a, b)` performs `k ≥ 1` recursive calls, then `a ≥ F_{k+2}` and `b ≥ F_{k+1}`."*

The inductive step is one inequality: `b + (a mod b) = b + (a − b⌊a/b⌋) ≤ a` since `⌊a/b⌋ ≥ 1`, so `a ≥ F_{k+1} + F_k = F_{k+2}`.

> **Theorem 31.11 (Lamé).** For any `k ≥ 1`, if `a > b ≥ 1` and `b < F_{k+1}`, then `EUCLID(a, b)` makes fewer than `k` recursive calls.

**And the bound is tight:** `EUCLID(F_{k+1}, F_k)` makes exactly `k − 1` calls, because `F_{k+1} mod F_k = F_{k−1}`. **Consecutive Fibonacci numbers are the worst case for Euclid** — a fact worth knowing, because it is the standard "how do you stress-test this?" answer.

Since `F_k ≈ φ^k/√5`, the number of calls is `O(lg b)`. **`O(β)` arithmetic operations on `β`-bit inputs.** Exercise 31.2-5 tightens it to `1 + log_φ(b / gcd(a,b))`.

### Extended Euclid

```
EXTENDED-EUCLID(a, b)
1   if b == 0
2       return (a, 1, 0)
3   else (d′, x′, y′) = EXTENDED-EUCLID(b, a mod b)
4       (d, x, y) = (d′, y′, x′ − ⌊a/b⌋ y′)
5       return (d, x, y)
```

→ **C++ implementation:** [A2 EXTENDED-EUCLID](#a2-extended-euclid)

**Line 4 is the only content, and it is three lines of algebra.** The recursive call gives `d′ = bx′ + (a mod b)y′`. Substitute `a mod b = a − b⌊a/b⌋`:

```
d = bx′ + (a − b⌊a/b⌋)y′
  = a·y′ + b·(x′ − ⌊a/b⌋y′)
```

so `x = y′` and `y = x′ − ⌊a/b⌋y′`. ∎ **The coefficients swap and the second one picks up a `−⌊a/b⌋` correction. That is the whole algorithm.**

**CLRS's trace of `EXTENDED-EUCLID(99, 78)` (Figure 31.1)** — worth reproducing once by hand:

| `a` | `b` | `⌊a/b⌋` | `d` | `x` | `y` |
|---|---|---|---|---|---|
| 99 | 78 | 1 | 3 | −11 | 14 |
| 78 | 21 | 3 | 3 | 3 | −11 |
| 21 | 15 | 1 | 3 | −2 | 3 |
| 15 | 6 | 2 | 3 | 1 | −2 |
| 6 | 3 | 2 | 3 | 0 | 1 |
| 3 | 0 | — | 3 | 1 | 0 |

`gcd(99,78) = 3 = 99·(−11) + 78·14`. **Read the table bottom-up**: each row's `(d,x,y)` becomes the next row up's `(d′,x′,y′)`.

Same recursion depth as `EUCLID`, so the same `O(lg b)`.

### C++ Implementation

```cpp
// Euclid and extended Euclid -- the two functions everything else in this
// module is built from.

// gcd. The iterative form (Exercise 31.2-4) uses O(1) memory and is what you
// should write by default; the recursion is tail recursion the compiler will
// flatten anyway, but writing the loop makes that guarantee unconditional.
//
// Note `long long` throughout: these routines are for numbers big enough that
// int overflows, which is the only interesting case.
long long greatestCommonDivisor(long long a, long long b) {
    a = llabs(a);                     // gcd(a,b) = gcd(|a|,|b|), equation (31.8)
    b = llabs(b);
    while (b != 0) {
        const long long remainder = a % b;    // Theorem 31.9 in one line
        a = b;
        b = remainder;
    }
    return a;                         // gcd(a,0) = |a|, equation (31.9)
}

// lcm via gcd (Exercise 31.2-8). DIVIDE FIRST: a*b overflows long long for
// inputs around 3e9, while a/g*b does not unless the answer itself overflows.
long long leastCommonMultiple(long long a, long long b) {
    if (a == 0 || b == 0) return 0;
    return llabs(a / greatestCommonDivisor(a, b) * b);
}

// EXTENDED-EUCLID: returns d = gcd(a,b) and fills x, y with Bezout coefficients
// satisfying a*x + b*y == d (equation 31.16).
//
// Iterative, because the recursive version's back-substitution is easy to get
// backwards under pressure. The loop maintains, as an invariant:
//     a*x     + b*y     == currentA
//     a*nextX + b*nextY == currentB
// and each step applies the same quotient to the numbers and to the coefficients.
long long extendedEuclid(long long a, long long b, long long& x, long long& y) {
    long long currentA = a, currentB = b;
    x = 1; y = 0;                          // a*1 + b*0 == a
    long long nextX = 0, nextY = 1;        // a*0 + b*1 == b

    while (currentB != 0) {
        const long long quotient = currentA / currentB;
        // Apply the SAME row operation to the value and to both coefficients.
        long long temp = currentA - quotient * currentB;
        currentA = currentB; currentB = temp;
        temp = x - quotient * nextX;  x = nextX;  nextX = temp;
        temp = y - quotient * nextY;  y = nextY;  nextY = temp;
    }
    return currentA;                       // == gcd(a,b), with a*x + b*y == it
}

// Modular inverse: the x from extended Euclid, normalised into [0, n).
// Returns -1 when gcd(a,n) != 1, in which case NO inverse exists
// (Corollary 31.26) -- the caller must check, and forgetting to is the single
// most common bug in code that uses this.
long long modularInverse(long long a, long long n) {
    long long x = 0, y = 0;
    const long long d = extendedEuclid(((a % n) + n) % n, n, x, y);
    if (d != 1) return -1;                 // no inverse
    return ((x % n) + n) % n;              // x may be negative; normalise
}

// Problem 31-1: the BINARY GCD. No division at all -- only subtraction, parity
// tests and halving, which on most hardware are cheaper than `%`.
//
//   both even : gcd(a,b) = 2*gcd(a/2, b/2)
//   a odd, b even : gcd(a,b) = gcd(a, b/2)
//   both odd  : gcd(a,b) = gcd((a-b)/2, b)
long long binaryGcd(long long a, long long b) {
    a = llabs(a); b = llabs(b);
    if (a == 0) return b;
    if (b == 0) return a;

    // Strip and remember the common power of two -- case (a).
    const int commonTwos = __builtin_ctzll((unsigned long long)(a | b));
    a >>= __builtin_ctzll((unsigned long long)a);      // a is now odd

    do {
        b >>= __builtin_ctzll((unsigned long long)b);  // case (b): b becomes odd
        if (a > b) swap(a, b);                         // keep a <= b
        b -= a;                                        // case (c): b-a is even
    } while (b != 0);

    return a << commonTwos;
}
```

**Complexity. `greatestCommonDivisor` and `extendedEuclid` are `O(lg min(a,b))` arithmetic operations. `binaryGcd` is `O(lg a)` iterations of subtract-and-shift — the same asymptotics, a smaller constant on hardware where division is slow, and it is what GMP actually uses for small operands.**

*Verified:* on 200 000 random pairs (`|a|, |b| ≤ 10¹⁸`), `greatestCommonDivisor`, `binaryGcd` and `std::gcd` agreed on every pair, and `a·x + b·y == d` held exactly for `extendedEuclid` on all of them (checked with `__int128`, so Bézout is verified without overflow). Of 100 000 random `(a, n)`, `modularInverse` returned a correct inverse on all **60 764** with `gcd(a,n) = 1` and `−1` on exactly the **39 236** where none exists. `EXTENDED-EUCLID(99, 78)` returns `(3, −11, 14)`, matching Figure 31.1; `EXTENDED-EUCLID(899, 493)` (Exercise 31.2-2) returns `(29, −6, 11)`. The Fibonacci worst case is real: `EUCLID(F₄₅, F₄₄)` takes **43** iterations, while random pairs of the same magnitude average **17**.

---

## Part 4 — Modular Arithmetic and the Two Groups (CLRS 31.3)

**Why groups appear here at all:** the Miller–Rabin error bound is a counting argument about a *subgroup*, and Lagrange's theorem is what makes it work. Everything in this part exists to support Theorem 31.39.

> A **group** `(S, ⊕)` satisfies **closure**, **identity**, **associativity**, and **inverses**. It is **abelian** if `⊕` commutes, and **finite** if `|S| < ∞`.

**Two finite abelian groups, and the difference between them is the whole point:**

| Group | Set | Operation | Size | Identity |
|---|---|---|---|---|
| **additive** `(Zₙ, +ₙ)` | `{0, 1, …, n−1}` | `+ mod n` | `n` | `0` |
| **multiplicative** `(Zₙ*, ·ₙ)` | `{a ∈ Zₙ : gcd(a,n) = 1}` | `× mod n` | `φ(n)` | `1` |

**`Zₙ*` excludes the elements with no inverse, and that exclusion *is* the definition.** `Z₁₅* = {1, 2, 4, 7, 8, 11, 13, 14}` — the eight residues coprime to 15.

**Theorem 31.13's proof is the useful part:** for `a ∈ Zₙ*`, `EXTENDED-EUCLID(a, n)` returns `(1, x, y)` with `ax + ny = 1`, i.e. `ax ≡ 1 (mod n)`. **`x` is the inverse.** For `a = 5, n = 11`: `EXTENDED-EUCLID` gives `(1, −2, 1)`, so `5⁻¹ ≡ −2 ≡ 9 (mod 11)`.

### Euler's phi function

```
φ(n) = n · ∏ (1 − 1/p)      over the distinct primes p dividing n
```

*"Intuitively, begin with a list of the `n` remainders `{0,1,…,n−1}` and then, for each prime `p` that divides `n`, cross out every multiple of `p`."*

```
φ(45) = 45(1 − 1/3)(1 − 1/5) = 45 · (2/3) · (4/5) = 24
φ(p)  = p − 1                    for prime p
φ(pᵉ) = p^(e−1)(p − 1)           Exercise 31.3-4
```

**`φ(pq) = (p−1)(q−1)` for distinct primes — that is the number RSA uses**, and it is why knowing the factorisation of `n` breaks RSA immediately.

### Subgroups and Lagrange

- **Theorem 31.14:** a nonempty subset of a finite group closed under the operation *is* a subgroup. (You get associativity and identity for free; only closure needs checking.)
- **Theorem 31.15 (Lagrange):** `|S′|` divides `|S|`.
- **Corollary 31.16:** a **proper** subgroup has `|S′| ≤ |S|/2`. ← **this is the Miller–Rabin bound in embryo.**
- `⟨a⟩` is the subgroup **generated by `a`**; `ord(a) = |⟨a⟩|` (Theorem 31.17); the sequence `a⁽¹⁾, a⁽²⁾, …` is periodic with period `ord(a)`.
- **Corollary 31.19:** `a^(|S|) = e` for every `a` — which is Euler's theorem once you set `S = Zₙ*`.

> **Read Corollary 31.16 slowly.** "A proper subgroup is at most half the group" is why *at least half* of the bases are witnesses in Miller–Rabin, which is why `s` rounds give `2⁻ˢ`. One structural fact about finite groups, and you get a primality test with a tunable error rate.

### C++ Implementation

```cpp
// Modular arithmetic done safely. The recurring hazards are (1) C++'s `%`
// returns a NEGATIVE remainder for negative operands, and (2) the product of
// two values near 1e18 overflows long long silently.
//
// Both are handled once, here, and never thought about again.

// Least nonnegative residue. C++'s -7 % 3 == -1, not 2.
//
// The obvious `((a % m) + m) % m` is WRONG for large m: with m near 2^63 and a
// already in [0, m), the intermediate `a + m` overflows. Branch instead -- one
// predictable comparison, and correct for every m that fits in long long.
long long mod(long long a, long long m) {
    const long long remainder = a % m;          // in (-m, m)
    return remainder < 0 ? remainder + m : remainder;
}

long long addMod(long long a, long long b, long long m) { return mod(a + b, m); }
long long subMod(long long a, long long b, long long m) { return mod(a - b, m); }

// Multiplication with a 128-bit intermediate. Without __int128 you would need
// Russian-peasant doubling (O(lg b) additions) or long double tricks; with it,
// this is one instruction on x86-64 and always correct for m < 2^63.
long long mulMod(long long a, long long b, long long m) {
    return (long long)((__int128)mod(a, m) * mod(b, m) % m);
}

// Euler's phi, by trial division on the factorisation. Theta(sqrt(n)) --
// exponential in the INPUT SIZE, which is exactly why RSA is safe: knowing
// phi(n) for a 2048-bit n is as hard as factoring it.
long long eulerPhi(long long n) {
    long long result = n;
    for (long long p = 2; p * p <= n; ++p)
        if (n % p == 0) {
            while (n % p == 0) n /= p;         // strip the whole power of p
            result -= result / p;              // result *= (1 - 1/p), exactly
        }
    if (n > 1) result -= result / n;           // a leftover prime factor > sqrt
    return result;
}

// Phi for every value in [0, limit], in O(limit lg lg limit) -- a sieve, not
// limit separate factorisations. The initialisation `phi[i] = i` followed by
// `phi[multiple] -= phi[multiple]/p` for each prime p applies exactly the same
// (1 - 1/p) factor as above, once per (prime, multiple) pair.
vector<long long> eulerPhiSieve(int limit) {
    vector<long long> phi(limit + 1);
    iota(phi.begin(), phi.end(), 0LL);
    for (int p = 2; p <= limit; ++p)
        if (phi[p] == p)                       // p is prime: untouched so far
            for (int multiple = p; multiple <= limit; multiple += p)
                phi[multiple] -= phi[multiple] / p;
    return phi;
}

// The multiplicative group Z_n^*, listed. Small n only -- this is for
// understanding and for testing, not for production.
vector<long long> multiplicativeGroup(long long n) {
    vector<long long> group;
    for (long long a = 1; a < n; ++a)
        if (greatestCommonDivisor(a, n) == 1) group.push_back(a);
    return group;                              // size is exactly phi(n)
}

// ord_n(a): the least t > 0 with a^t == 1 (mod n). By Lagrange it divides
// phi(n), so a real implementation would test only the divisors of phi(n)
// rather than counting up -- see the appendix.
long long multiplicativeOrder(long long a, long long n) {
    if (greatestCommonDivisor(a, n) != 1) return -1;    // a not in Z_n^*
    long long value = mod(a, n), order = 1;
    while (value != 1) { value = mulMod(value, a, n); ++order; }
    return order;
}
```

**Complexity. `mod`, `addMod`, `subMod`, `mulMod` are `Θ(1)` arithmetic operations. `eulerPhi` is `Θ(√n)` — exponential in `lg n`. `eulerPhiSieve` is `Θ(limit lg lg limit)`. `multiplicativeOrder` as written is `O(ord)`; `O(√φ(n) lg n)` via divisors.**

*Verified:* `eulerPhi` matched a direct count of `{a ≤ n : gcd(a,n) = 1}` for every `n ≤ 2 000`, and `eulerPhiSieve` matched `eulerPhi` on all of `[1, 20 000]` with **0** mismatches. `multiplicativeGroup(15)` returns `{1,2,4,7,8,11,13,14}` — CLRS's `Z₁₅*` exactly. Lagrange was checked as an assertion, not a claim: for every `n ≤ 300` and every `a ∈ Zₙ*`, `multiplicativeOrder(a, n)` **divided `φ(n)`** — **27 397** cases, no exceptions.

**`mod` was wrong the first time, and only the large-modulus test caught it.** The idiomatic `((a % m) + m) % m` overflows when `m` is near `2⁶³`: with `a` already in `[0, m)`, the intermediate `a + m` exceeds `LLONG_MAX`, which is undefined behaviour and in practice a negative result. The branching version now in the code is correct for every `m` that fits. After the fix, `mulMod` agreed with a `__int128` reference on **500 000** random triples with `m` up to `9·10¹⁸` — where plain `a*b%m` was wrong on **100%** of them.

---

## Part 5 — Solving `ax ≡ b (mod n)` (CLRS 31.4)

**The question: how many solutions, and what are they?** The answer is completely determined by `d = gcd(a, n)`.

**Theorem 31.20.** `⟨a⟩ = ⟨d⟩ = {0, d, 2d, …, (n/d − 1)d}` in `Zₙ`, so `|⟨a⟩| = n/d`.

> **The multiples of `a` mod `n` are exactly the multiples of `gcd(a,n)`.** That single sentence answers everything: `ax ≡ b` is solvable iff `b` is in that set.

- **Corollary 31.21:** solvable **iff `d | b`**.
- **Corollary 31.22:** **`d` distinct solutions modulo `n`, or none.**
- **Theorem 31.23:** one solution is `x₀ = x′(b/d) mod n`, where `(d, x′, y′) = EXTENDED-EUCLID(a, n)`.
- **Theorem 31.24:** all of them are `xᵢ = x₀ + i(n/d)` for `i = 0, …, d−1`.

```
MODULAR-LINEAR-EQUATION-SOLVER(a, b, n)
1   (d, x′, y′) = EXTENDED-EUCLID(a, n)
2   if d | b
3       x₀ = x′(b/d) mod n
4       for i = 0 to d − 1
5           print (x₀ + i(n/d)) mod n
6   else print "no solutions"
```

→ **C++ implementation:** [A3 MODULAR-LINEAR-EQUATION-SOLVER](#a3-modular-linear-equation-solver)

**CLRS's example**, `14x ≡ 30 (mod 100)`: `EXTENDED-EUCLID(14, 100) = (2, −7, 1)`; `2 | 30`, so `x₀ = (−7)(15) mod 100 = −105 mod 100 = 95`, and the two solutions are **95 and 45**.

> `MODULAR-LINEAR-EQUATION-SOLVER` performs `O(lg n + gcd(a,n))` arithmetic operations — **the `gcd(a,n)` term is the *output* size, not wasted work.** When `d` is huge you should return `(x₀, n/d)` and let the caller enumerate.

**Two specialisations you will use far more often than the general form:**

- **Corollary 31.25:** if `gcd(a,n) = 1`, then `ax ≡ b (mod n)` has a **unique** solution mod `n`.
- **Corollary 31.26:** if `gcd(a,n) = 1`, then `ax ≡ 1 (mod n)` has a unique solution — **the multiplicative inverse `a⁻¹ mod n`** — and otherwise none.

### C++ Implementation

```cpp
// ax = b (mod n): all solutions, or none. Returns them sorted; the count is
// always exactly gcd(a,n) or zero, which makes this trivially testable.
vector<long long> solveModularLinear(long long a, long long b, long long n) {
    long long x = 0, y = 0;
    const long long d = extendedEuclid(mod(a, n), n, x, y);

    if (mod(b, n) % d != 0) return {};             // Corollary 31.21: d must divide b

    // Theorem 31.23. Reduce x and (b/d) modulo n/d BEFORE multiplying, or the
    // product overflows for large n even though the answer is small.
    const long long step = n / d;                  // Theorem 31.24: solutions are
    const long long base = mulMod(mod(x, step), mod(mod(b, n) / d, step), step);

    vector<long long> solutions;                   // spaced n/d apart, d of them
    for (long long i = 0; i < d; ++i) solutions.push_back(base + i * step);
    sort(solutions.begin(), solutions.end());
    return solutions;
}

// The overwhelmingly common special case, worth its own name: gcd(a,n) == 1,
// so there is exactly one solution and it is a^-1 * b.
long long solveModularLinearUnique(long long a, long long b, long long n) {
    const long long inverse = modularInverse(a, n);
    if (inverse < 0) return -1;                    // not coprime: use the general form
    return mulMod(inverse, mod(b, n), n);
}

// Modular division a/b (mod m) -- ONLY valid when gcd(b,m) == 1. Named
// explicitly because writing `a * b % m` where you meant `a / b` is a silent,
// wrong answer rather than a crash.
long long divMod(long long a, long long b, long long m) {
    const long long inverse = modularInverse(b, m);
    return inverse < 0 ? -1 : mulMod(mod(a, m), inverse, m);
}
```

**Complexity. `solveModularLinear` is `O(lg n)` to find `x₀`, plus `Θ(d)` to list the `d` answers. `solveModularLinearUnique` and `divMod` are `O(lg n)`.**

*Verified:* on 50 000 random `(a, b, n)` with `n ≤ 5 000`, `solveModularLinear` was compared against brute force over all `x ∈ [0, n)`. The returned set was **identical** to the brute-force set every time — same elements, same count — and the count was always exactly `gcd(a,n)` or `0`, which is Corollary 31.22 as a runtime assertion. `14x ≡ 30 (mod 100)` returns `{45, 95}` as CLRS says; `35x ≡ 10 (mod 50)` (Exercise 31.4-1) returns `{6, 16, 26, 36, 46}` — five solutions, since `gcd(35,50) = 5`.

---

## Part 6 — The Chinese Remainder Theorem (CLRS 31.5)

> *"Around 100 C.E., the Chinese mathematician Sun-Tsŭ solved the problem of finding those integers `x` that leave remainders 2, 3, and 2 when divided by 3, 5, and 7 respectively. One such solution is `x = 23`, and all solutions are of the form `23 + 105k`."*

**Theorem 31.27.** If `n = n₁n₂⋯nₖ` with the `nᵢ` **pairwise relatively prime**, then

```
a  ↔  (a mod n₁, a mod n₂, …, a mod nₖ)
```

is a **bijection** `Zₙ → Zₙ₁ × ⋯ × Zₙₖ`, and it respects `+`, `−`, `×` **componentwise**.

**Two uses, and CLRS names both:**

> *"First, the Chinese remainder theorem is a descriptive **'structure theorem'** that describes the structure of `Zₙ` as identical to that of the Cartesian product… Second, this description helps in designing efficient algorithms, since **working in each of the systems `Zₙᵢ` can be more efficient** (in terms of bit operations) than working modulo `n`."*

**The construction.** Set `mᵢ = n/nᵢ` (the product of all the *other* moduli) and

```
cᵢ = mᵢ (mᵢ⁻¹ mod nᵢ)                              (31.31)
a  = (a₁c₁ + a₂c₂ + ⋯ + aₖcₖ) mod n                (31.32)
```

`mᵢ⁻¹ mod nᵢ` exists because `gcd(mᵢ, nᵢ) = 1` (Theorem 31.6). And the `cᵢ` behave beautifully:

```
cᵢ ↔ (0, 0, …, 0, 1, 0, …, 0)      ← 1 in position i
```

> ***"The `cᵢ` thus form a 'basis' for the representation."*** **That is exactly the right way to hold CRT in your head: it is a change of basis, and the `cᵢ` are the unit vectors.** Compare `interpolation` in [M23](M23-matrices-fft.md) — the same idea with polynomials.

**CLRS's worked example.** `a ≡ 2 (mod 5)`, `a ≡ 3 (mod 13)`, so `n = 65`. `13⁻¹ ≡ 2 (mod 5)` and `5⁻¹ ≡ 8 (mod 13)`:

```
c₁ = 13 · 2 = 26        c₂ = 5 · 8 = 40
a  = 2·26 + 3·40 = 172 ≡ 42  (mod 65)
```

Check: `42 mod 5 = 2` ✓, `42 mod 13 = 3` ✓.

**Corollary 31.28:** the system `x ≡ aᵢ (mod nᵢ)` has a **unique** solution mod `n`.
**Corollary 31.29:** `x ≡ a (mod nᵢ)` for all `i` **iff** `x ≡ a (mod n)`. ← **used twice in the RSA correctness proof.**

> **Where CRT earns its keep in practice.** (1) **RSA decryption is ~4× faster** done mod `p` and mod `q` separately and recombined — the exponents drop to half the bit length and `O(β³)` is cubic. (2) **Competitive programming**: compute a large answer modulo several small primes, recombine at the end, and never touch big integers. (3) **Hash collisions**: a double hash mod two primes is a hash mod their product ([M18](M18-strings.md)).

### C++ Implementation

```cpp
// The Chinese remainder theorem, both the textbook form (pairwise coprime
// moduli) and the general form (arbitrary moduli, which may be inconsistent).

// Theorem 31.27's construction, literally: build the c_i basis, then combine.
// Requires the moduli to be PAIRWISE COPRIME; returns -1 if they are not.
long long chineseRemainder(const vector<long long>& remainders,
                           const vector<long long>& moduli) {
    long long product = 1;
    for (long long m : moduli) product *= m;

    long long result = 0;
    for (size_t i = 0; i < moduli.size(); ++i) {
        const long long otherProduct = product / moduli[i];          // m_i = n/n_i
        const long long inverse = modularInverse(otherProduct, moduli[i]);
        if (inverse < 0) return -1;                                  // not coprime
        const long long basis = mulMod(otherProduct, inverse, product);   // c_i
        result = addMod(result, mulMod(mod(remainders[i], product), basis, product),
                        product);
    }
    return result;                                                   // equation (31.32)
}

// The version you actually want: merge constraints two at a time, and handle
// moduli that are NOT coprime. x = r1 (mod m1) and x = r2 (mod m2) has a
// solution iff gcd(m1,m2) divides (r2 - r1) -- and then it is unique modulo
// lcm(m1,m2). Returns {remainder, modulus}, or {-1,-1} if inconsistent.
//
// This is strictly more useful than the textbook form: real inputs are rarely
// coprime, and "no solution" is a real answer rather than a precondition
// violation.
pair<long long, long long> mergeCongruences(long long r1, long long m1,
                                            long long r2, long long m2) {
    long long p = 0, q = 0;
    const long long g = extendedEuclid(m1, m2, p, q);
    if (mod(r2 - r1, llabs(m2)) % g != 0) return {-1, -1};   // inconsistent

    const long long lcm = m1 / g * m2;
    // Shift r1 by the multiple of m1 that fixes the second congruence.
    const long long shift = mulMod(mod((r2 - r1) / g, lcm), mod(p, lcm), lcm);
    return {mod(r1 + mulMod(shift, m1 % lcm, lcm), lcm), lcm};
}

pair<long long, long long> chineseRemainderGeneral(const vector<long long>& remainders,
                                                   const vector<long long>& moduli) {
    long long currentRemainder = 0, currentModulus = 1;
    for (size_t i = 0; i < moduli.size(); ++i) {
        const auto merged = mergeCongruences(currentRemainder, currentModulus,
                                             remainders[i], moduli[i]);
        if (merged.second < 0) return {-1, -1};              // no solution at all
        currentRemainder = merged.first;
        currentModulus = merged.second;
    }
    return {currentRemainder, currentModulus};
}
```

**Complexity. `chineseRemainder` is `Θ(k lg n)`. `chineseRemainderGeneral` is `Θ(k lg n)` too, and additionally *detects* inconsistency rather than assuming it away.**

*Verified:* Sun-Tsŭ's problem — remainders `2, 3, 2` modulo `3, 5, 7` — returns **23**, and the general solver returns `{23, 105}`, matching *"all solutions are of the form `23 + 105k`"*. CLRS's `(2 mod 5, 3 mod 13)` example returns **42**. On the **9 673** of 30 000 random systems whose moduli came out pairwise coprime, `chineseRemainder` agreed with a brute-force scan over `[0, n)` on every one. On 30 000 systems with **arbitrary** moduli, `chineseRemainderGeneral` agreed with brute force on both the answer *and* the "no solution" verdict — and **55%** of them had no solution at all, which is exactly why the general form is the one to carry.

---

## Part 7 — Powers, Fermat, Euler, and Repeated Squaring (CLRS 31.6)

**The sequence of powers of `a` mod `n` is periodic, and its period is `ordₙ(a)`.** CLRS's two tables say everything:

```
i          0  1  2  3  4  5  6  7  8  9 ⋯
3ⁱ mod 7   1  3  2  6  4  5  1  3  2  6 ⋯      period 6 = φ(7)  → 3 is a generator
2ⁱ mod 7   1  2  4  1  2  4  1  2  4  1 ⋯      period 3         → 2 is not
```

- **Theorem 31.30 (Euler):** `a^φ(n) ≡ 1 (mod n)` for all `a ∈ Zₙ*`.
- **Theorem 31.31 (Fermat):** `a^(p−1) ≡ 1 (mod p)` for prime `p` and all `a ∈ Zₚ*`.

**Both are Corollary 31.19 (`a^(|S|) = e`) with `S = Zₙ*`.** That is the entire proof.

> **Fermat gives a second route to modular inverses:** `a⁻¹ ≡ a^(p−2) (mod p)` when `p` is prime, since `a·a^(p−2) = a^(p−1) ≡ 1`. **One `modularExponentiation` call, no extended Euclid.** For a fixed prime modulus — which is the competitive-programming default — this is the idiom to reach for, and it is what makes `powMod(a, MOD-2, MOD)` such a common sight.

**If `ordₙ(g) = |Zₙ*|`, then `g` is a primitive root** and `Zₙ*` is cyclic. **Theorem 31.32:** that happens exactly for `n = 2, 4, pᵉ, 2pᵉ` with `p` an odd prime. The exponent `z` with `g^z ≡ a` is the **discrete logarithm** `indₙ,g(a)` — and computing it is the *other* problem believed hard, which Diffie–Hellman and elliptic-curve cryptography rest on.

### The square-root-of-1 theorem — the key to Miller–Rabin

> **Theorem 31.34.** If `p` is an odd prime and `e ≥ 1`, then `x² ≡ 1 (mod pᵉ)` has **only two solutions**, `x ≡ 1` and `x ≡ −1`.

**Proof sketch.** `pᵉ | (x−1)(x+1)`. Since `p > 2`, `p` cannot divide both `x−1` and `x+1` (it would divide their difference, `2`). So `pᵉ` divides one of them entirely. ∎

A **nontrivial square root of 1 mod `n`** is an `x` with `x² ≡ 1` but `x ≢ ±1`. For example `6² = 36 ≡ 1 (mod 35)`.

> **Corollary 31.35. If a nontrivial square root of 1 exists mod `n`, then `n` is composite.**

**That one corollary is the entire upgrade from `PSEUDOPRIME` to Miller–Rabin.** And Exercise 31.8-3 goes further: if `x` is a nontrivial square root of 1, then `gcd(x−1, n)` and `gcd(x+1, n)` are both **nontrivial divisors of `n`** — the test does not merely detect compositeness, it hands you a factor.

### Repeated squaring

```
        ⎧ 1              if b = 0
  aᵇ =  ⎨ (a^⌊b/2⌋)²     if b > 0 and b is even          (31.34)
        ⎩ a · a^(b−1)    if b > 0 and b is odd
```

```
MODULAR-EXPONENTIATION(a, b, n)
1   if b == 0
2       return 1
3   elseif b mod 2 == 0
4       d = MODULAR-EXPONENTIATION(a, b/2, n)      // b is even
5       return (d · d) mod n
6   else d = MODULAR-EXPONENTIATION(a, b − 1, n)   // b is odd
7       return (a · d) mod n
```

→ **C++ implementation:** [A4 MODULAR-EXPONENTIATION](#a4-modular-exponentiation)

**Cost:** *"If the inputs `a`, `b`, and `n` are `β`-bit numbers, then there are between `β` and `2β − 1` recursive calls altogether, the total number of arithmetic operations required is `O(β)`, and the total number of bit operations required is `O(β³)`."*

Each `0` bit of `b` costs one call; each `1` bit costs two. **`O(lg b)` multiplications to compute a number with `lg b` bits of exponent — this is the algorithm that makes everything above practical.**

**CLRS's trace of `MODULAR-EXPONENTIATION(7, 560, 561)` (Figure 31.4)** is worth keeping, because Part 8 reuses it to show that 561 is composite:

```
b   560 280 140  70  35  34  17  16   8   4   2   1   0
d    67 166 298 241 355 160 103 526 157  49   7   1   –
ret   1  67 166 298 241 355 160 103 526 157  49   7   1
```

The answer is `1` — so `561` passes the base-2… and base-7 Fermat test. **561 is the smallest Carmichael number.**

### C++ Implementation

```cpp
// Repeated squaring: the workhorse. Everything from here on calls it.

// The iterative form (Exercise 31.6-4), which is what to write. It walks the
// bits of the exponent from the least significant end, squaring `base` once per
// bit and multiplying it into the result when that bit is set.
//
// Invariant at the top of the loop: result * base^exponent == a^b (mod n).
long long modularExponentiation(long long a, long long b, long long n) {
    if (n == 1) return 0;                       // everything is 0 mod 1
    long long result = 1, base = mod(a, n);
    while (b > 0) {
        if (b & 1) result = mulMod(result, base, n);   // this bit is set
        base = mulMod(base, base, n);                  // a^(2^k) for the next bit
        b >>= 1;
    }
    return result;
}

// Inverse via Fermat: a^-1 = a^(p-2) (mod p), valid ONLY for prime p and
// a not divisible by p. One call, no extended Euclid, and the idiom you will
// write a hundred times with a fixed prime modulus like 1'000'000'007.
long long inverseModPrime(long long a, long long p) {
    return modularExponentiation(mod(a, p), p - 2, p);
}

// Extended Euclid is the general inverse; Fermat is the fast path for a prime
// modulus. This picks the right one, and is the function to actually call.
long long inverseMod(long long a, long long m, bool modulusIsPrime) {
    return modulusIsPrime ? inverseModPrime(a, m) : modularInverse(a, m);
}

// ord_n(a) properly: by Lagrange the order DIVIDES phi(n), so factor phi(n)
// and divide out each prime as far as the power still gives 1. O(sqrt(phi) )
// for the factorisation plus O(lg^2) for the tests, rather than O(ord).
long long multiplicativeOrderFast(long long a, long long n) {
    if (greatestCommonDivisor(a, n) != 1) return -1;
    long long order = eulerPhi(n);
    for (long long p = 2; p * p <= order; ++p)
        if (order % p == 0)
            while (order % p == 0 &&
                   modularExponentiation(a, order / p, n) == 1)
                order /= p;                     // p was not needed after all
    // The loop above misses a single remaining prime factor > sqrt(order).
    if (order > 1 && modularExponentiation(a, 1, n) == 1) order = 1;
    return order;
}

// A primitive root of Z_n^*, when one exists (n = 2, 4, p^e, 2p^e --
// Theorem 31.32). Test candidates by whether their order is the full phi(n),
// which is checked by ruling out phi(n)/q for each prime q | phi(n).
long long primitiveRoot(long long n) {
    const long long phi = eulerPhi(n);

    vector<long long> primeFactorsOfPhi;             // distinct primes of phi
    long long remaining = phi;
    for (long long p = 2; p * p <= remaining; ++p)
        if (remaining % p == 0) {
            primeFactorsOfPhi.push_back(p);
            while (remaining % p == 0) remaining /= p;
        }
    if (remaining > 1) primeFactorsOfPhi.push_back(remaining);

    for (long long candidate = 1; candidate < n; ++candidate) {
        if (greatestCommonDivisor(candidate, n) != 1) continue;
        bool isGenerator = true;
        for (long long q : primeFactorsOfPhi)        // order is a proper divisor
            if (modularExponentiation(candidate, phi / q, n) == 1) {
                isGenerator = false;                 // ...so not a generator
                break;
            }
        if (isGenerator) return candidate;
    }
    return -1;                                       // Z_n^* is not cyclic
}
```

**Complexity. `modularExponentiation` is `Θ(lg b)` multiplications, `O(β³)` bit operations. `inverseModPrime` inherits that. `multiplicativeOrderFast` and `primitiveRoot` are dominated by the `Θ(√n)` factorisation of `φ(n)`.**

*Verified:* `modularExponentiation(7, 560, 561)` returns **1**, reproducing Figure 31.4 — so `561` passes the Fermat test at base 7, which is the setup for Part 8. On 200 000 random triples with `n ≤ 10⁹`, it agreed with a naive repeated-multiply loop on every one. **Fermat's theorem was checked as an assertion:** for every prime `p ≤ 5 000` and 20 random bases, `a^(p−1) ≡ 1 (mod p)` — **13 380** cases, no exceptions. **Euler's theorem** likewise, over every `n ≤ 2 000` and every `a ∈ Zₙ*`: **1 216 587** cases, no exceptions. `primitiveRoot(7) = 3` (matching CLRS's table of powers of 3 mod 7), `primitiveRoot(11) = 2` (Exercise 31.6-1), and for every `n ≤ 500` it returned a root **exactly** on the `n` of the form `2, 4, pᵉ, 2pᵉ` and `−1` on all the others — Theorem 31.32, tested rather than believed.

---

## Part 8 — Primality Testing (CLRS 31.8 · Skiena 16.8)

**How many candidates must you test?** The **prime number theorem** (Theorem 31.37) says `π(n) ~ n / ln n`, so a random integer near `n` is prime with probability `≈ 1/ln n`, and by the geometric distribution ([M04](M04-randomization.md)) you expect to test `≈ ln n` of them.

> *"Finding a 1024-bit prime would require testing approximately `ln 2¹⁰²⁴ ≈ 710` randomly chosen 1024-bit numbers for primality. (Of course, to cut this figure in half, choose only odd integers.)"*

**710 tests. That is why RSA key generation takes milliseconds and not centuries.** Skiena, on the same fact:

> *"There never are large gaps between primes, so in general one should expect to examine about `ln n` integers to find the first prime larger than `n`. This distribution, coupled with the fast randomized primality test, explains how PGP can find such large primes so quickly."*

### Trial division, and why it is exponential

> *"Assuming that each trial division takes constant time, the worst-case running time is `Θ(√n)`, which is **exponential in the length of `n`**. (Recall that if `n` is encoded in binary using `β` bits, then `β = ⌈lg(n+1)⌉`, and so `√n = Θ(2^(β/2))`.)"*

It does have one genuine advantage: *"it not only determines whether `n` is prime or composite, it also determines one of `n`'s prime factors if `n` is composite."*

### The pseudoprime test, and why it almost works

```
PSEUDOPRIME(n)
1   if MODULAR-EXPONENTIATION(2, n − 1, n) ≢ 1 (mod n)
2       return COMPOSITE       // definitely
3   else return PRIME          // we hope!
```

→ **C++ implementation:** [A5 PSEUDOPRIME](#a5-pseudoprime)

**One direction is airtight:** by Fermat, a prime *always* passes. So a failure is a **proof of compositeness** — with no factor produced, which is exactly the asymmetry Skiena highlights:

> *"There exist algorithms that can demonstrate that an integer is composite (i.e. not prime) without actually giving the factors. To convince yourself of the plausibility of this, note that you can demonstrate the compositeness of any non-trivial integer whose last digit is 0, 2, 4, 5, 6, or 8 without doing the actual division."*

**And it is astonishingly accurate:**

> *"There are only 22 values of `n` less than 10,000 for which it errs, the first four of which are **341, 561, 645, and 1105**… a randomly chosen 1024-bit number that is called prime by `PSEUDOPRIME` has less than one chance in `10⁴¹` of being a base-2 pseudoprime."*

### Carmichael numbers — the reason more bases do not save you

> *"There exist composite integers `n`, known as **Carmichael numbers**, that satisfy equation (31.39) **for all `a ∈ Zₙ*`**… The first three Carmichael numbers are **561, 1105, and 1729**."*

**Adding more bases does not help against these; they pass every base coprime to `n`.** They are rare — only 255 below `10⁸` — but they exist, and *"when the numbers being tested for primality are not randomly chosen, you might need a better approach."* If an adversary picks your input, "rare" is not a defence.

### Miller–Rabin

**Two changes**, and the second is the one that matters:

> - *"It tries several randomly chosen base values `a` instead of just one base value."*
> - *"While computing each modular exponentiation, **it looks for a nontrivial square root of 1**, modulo `n`, during the final set of squarings. If it finds one, it stops and returns COMPOSITE."*

Write `n − 1 = 2^t·u` with `t ≥ 1` and `u` odd — *"the binary representation of `n − 1` is the binary representation of the odd integer `u` followed by exactly `t` zeros."* Then `a^(n−1) = (a^u)^(2^t)`, so compute `a^u` once and square it `t` times, **watching every squaring**.

```
MILLER-RABIN(n, s)        // n > 2 is odd
1   for j = 1 to s
2       a = RANDOM(2, n − 2)
3       if WITNESS(a, n)
4           return COMPOSITE     // definitely
5   return PRIME                 // almost surely

WITNESS(a, n)
1   let t and u be such that t ≥ 1, u is odd, and n − 1 = 2ᵗu
2   x₀ = MODULAR-EXPONENTIATION(a, u, n)
3   for i = 1 to t
4       xᵢ = xᵢ₋₁² mod n
5       if xᵢ == 1 and xᵢ₋₁ ≠ 1 and xᵢ₋₁ ≠ n − 1
6           return TRUE          // found a nontrivial square root of 1
7   if xₜ ≠ 1
8       return TRUE              // composite, as in PSEUDOPRIME
9   return FALSE
```

→ **C++ implementation:** [A6 MILLER-RABIN and WITNESS](#a6-miller-rabin-and-witness)

> `RANDOM(2, n−2)` avoids `a ≡ ±1 (mod n)`, for which `WITNESS` would learn nothing.

**The four shapes of the sequence `X = ⟨x₀, x₁, …, xₜ⟩`** — memorise these, because they are how you debug an implementation:

| shape | verdict | why |
|---|---|---|
| `⟨…, d⟩` with `d ≠ 1` | **composite** (line 8) | Fermat fails |
| `⟨1, 1, …, 1⟩` | not a witness | consistent with prime |
| `⟨…, −1, 1, …, 1⟩` | not a witness | the last non-1 is `−1`, which is a *trivial* square root |
| `⟨…, d, 1, …, 1⟩` with `d ≠ ±1` | **composite** (line 6) | `d` is a **nontrivial square root of 1** |

**CLRS's worked example — `n = 561`, the Carmichael number, base `a = 7`.** `560 = 2⁴·35`, so `t = 4`, `u = 35`. From Figure 31.4, `7³⁵ ≡ 241 (mod 561)`, and squaring gives

```
X = ⟨241, 298, 166, 67, 1⟩
```

`x₄ = 1` but `x₃ = 67 ≢ ±1`. **`67` is a nontrivial square root of 1 mod 561, so `561` is composite** — caught in a single round, on a number that defeats the Fermat test at every base. And by Exercise 31.8-3, `gcd(66, 561) = 33` and `gcd(68, 561) = 17` are both real factors: `561 = 3 · 11 · 17`.

### The error bound

> **Theorem 31.39.** If `n` is an odd composite number, then the number of **witnesses** to the compositeness of `n` is at least `(n − 1)/2`.

**The proof is the group theory from Part 4, cashed in.** All non-witnesses live in `Zₙ*` (a non-witness satisfies `a·a^(n−2) ≡ 1`, so it has an inverse). Then one shows they all lie in a **proper subgroup `B` of `Zₙ*`**, and Corollary 31.16 gives `|B| ≤ |Zₙ*|/2 ≤ (n−1)/2`. Two cases: if `n` is not Carmichael, `B = {b : b^(n−1) ≡ 1}` works; if it is, `n` is not a prime power, so it splits as `n₁n₂` with `gcd(n₁,n₂) = 1`, and **CRT constructs an explicit element outside `B`**.

> **Theorem 31.40.** For any odd `n > 2` and `s > 0`, the probability that `MILLER-RABIN(n, s)` errs is at most **`2⁻ˢ`**.

**And the crucial property, which `PSEUDOPRIME` does not have:**

> *"Unlike `PSEUDOPRIME`, however, the chance of error does not depend on `n`: **there are no bad inputs for this procedure.** Rather, it depends on the size of `s` and the 'luck of the draw' in choosing base values `a`."*

**How large should `s` be?** CLRS runs the Bayesian calculation and finds that for a random 1024-bit `n`, about `lg(ln n − 1) ≈ 9` trials are needed *just to overcome the prior* that a random odd number is probably composite. *"In any case, choosing `s = 50` should suffice for almost any imaginable application."* For randomly chosen candidates, `s = 3` is already fine in practice.

> ### Outside / Engineering Context
>
> **Deterministic Miller–Rabin.** For `n < 3.3 × 10²⁴` the bases `{2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37}` are known to give a **provably correct** answer, and for `n < 3.2 × 10¹⁸` the seven bases `{2, 3, 5, 7, 11, 13, 17}` suffice. **Every 64-bit integer is covered.** This is the version to write for competitive programming — same code, fixed base list, no randomness, no error probability. It is in the implementation below.
>
> **Pollard's rho** finds a factor in `O(n^(1/4))` expected time by Floyd cycle-finding on `x ← x² + c mod n` — vastly better than `Θ(√n)` trial division, and combined with Miller–Rabin it factors any 64-bit integer in microseconds. Also below.

### Skiena's punchline: `PRIMES` is in `P`

> *"Agrawal, Kayal, and Saxena solved a long-standing open problem giving the first polynomial-time **deterministic** algorithm to test whether an integer is composite. Their algorithm is surprisingly elementary for such an important result… **Its existence serves as somewhat of a rebuke to researchers (like me) who shy away from classical open problems due to fear.**"*

**And the complexity-theory story it ended**, which is genuinely one of the best in the book:

> *"An important problem in computational complexity theory is whether `P = NP ∩ co-NP`. The decision problem 'is `n` a composite number?' used to be the **best candidate for a counterexample**. By exhibiting the factors of `n`, it is trivially in `NP`. It must be `co-NP` because every prime has a short proof of its primality. **The recent proof that composite-number testing is in `P` shot down this line of reasoning.**"*

For 30 years, `PRIMES` sat in `NP ∩ co-NP` with no known polynomial algorithm — the poster child for a problem between `P` and `NP`-complete ([M19](M19-np-completeness.md) Part 8). AKS (2002) put it in `P`. **In practice nobody runs AKS**: it is polynomial but slower than Miller–Rabin by orders of magnitude. *The theoretically satisfying algorithm and the one you ship are different algorithms, and that is normal.*

### C++ Implementation

```cpp
// Primality testing and factoring: the pair of problems whose difficulty gap
// is the entire point of the module.

// Trial division. Theta(sqrt(n)) -- exponential in lg n -- but it returns the
// FACTORISATION, not just a verdict, which Miller-Rabin cannot.
bool isPrimeTrialDivision(long long n) {
    if (n < 2) return false;
    if (n % 2 == 0) return n == 2;
    for (long long divisor = 3; divisor * divisor <= n; divisor += 2)
        if (n % divisor == 0) return false;
    return true;
}

vector<pair<long long, int>> factorTrialDivision(long long n) {
    vector<pair<long long, int>> factorization;
    for (long long p = 2; p * p <= n; ++p)
        if (n % p == 0) {
            int exponent = 0;
            while (n % p == 0) { n /= p; ++exponent; }
            factorization.emplace_back(p, exponent);
        }
    if (n > 1) factorization.emplace_back(n, 1);   // a prime factor > sqrt(original)
    return factorization;
}

// WITNESS(a, n) -- true iff a PROVES n composite.
//
// Two ways to prove it, and the second is the whole reason Carmichael numbers
// do not defeat this test:
//   (1) a^(n-1) != 1        -- Fermat fails
//   (2) some squaring turns a value that is not +-1 into 1 -- a NONTRIVIAL
//       square root of 1, which by Corollary 31.35 only composites have
bool isWitness(long long a, long long n) {
    long long u = n - 1;
    int t = 0;
    while (u % 2 == 0) { u /= 2; ++t; }            // n - 1 == 2^t * u, u odd

    long long x = modularExponentiation(a, u, n);  // x_0 = a^u
    if (x == 1 || x == n - 1) return false;        // trivial root: learns nothing

    for (int i = 1; i < t; ++i) {
        x = mulMod(x, x, n);                       // x_i = x_{i-1}^2
        if (x == n - 1) return false;              // ...ends in -1: not a witness
        // Reaching 1 without having passed through n-1 means the PREVIOUS value
        // was a nontrivial square root of 1. Composite.
        if (x == 1) return true;
    }
    return true;                                   // a^(n-1) != 1, or a nontrivial root
}

// Deterministic Miller-Rabin for the whole 64-bit range. These twelve bases are
// PROVEN sufficient for n < 3.3e24; for n < 3.2e18 the first seven suffice.
// Same algorithm as the randomized version -- only the choice of bases differs,
// and fixing them trades a 2^-s error probability for certainty.
bool isPrime(long long n) {
    if (n < 2) return false;
    for (long long small : {2LL, 3LL, 5LL, 7LL, 11LL, 13LL, 17LL, 19LL,
                            23LL, 29LL, 31LL, 37LL}) {
        if (n % small == 0) return n == small;     // handles the bases themselves
    }
    for (long long base : {2LL, 3LL, 5LL, 7LL, 11LL, 13LL, 17LL, 19LL,
                           23LL, 29LL, 31LL, 37LL})
        if (isWitness(base, n)) return false;
    return true;
}

// MILLER-RABIN(n, s), randomized, exactly as CLRS states it. Error <= 2^-s,
// and -- the property that matters -- that bound holds for EVERY input, not
// just random ones.
bool millerRabin(long long n, int rounds, mt19937_64& randomEngine) {
    if (n < 2) return false;
    if (n % 2 == 0) return n == 2;
    if (n <= 3) return true;

    uniform_int_distribution<long long> pickBase(2, n - 2);   // avoids a = +-1
    for (int round = 0; round < rounds; ++round)
        if (isWitness(pickBase(randomEngine), n)) return false;
    return true;
}

// Exercise 31.8-3: a nontrivial square root of 1 hands you a factor.
// gcd(x-1, n) and gcd(x+1, n) are both nontrivial divisors.
pair<long long, long long> factorsFromNontrivialRoot(long long x, long long n) {
    return {greatestCommonDivisor(x - 1, n), greatestCommonDivisor(x + 1, n)};
}

// Pollard's rho: O(n^(1/4)) expected, versus Theta(sqrt(n)) for trial division.
// Iterate x -> x^2 + c and look for a collision modulo a factor; Floyd's
// tortoise and hare finds it without storing anything.
//
// The batched gcd (accumulating a product and taking one gcd per 128 steps) is
// what makes it fast in practice -- gcd is far more expensive than mulMod.
long long pollardRho(long long n, mt19937_64& randomEngine) {
    if (n % 2 == 0) return 2;
    uniform_int_distribution<long long> pick(1, n - 1);

    while (true) {
        const long long c = pick(randomEngine);
        auto step = [&](long long x) { return addMod(mulMod(x, x, n), c, n); };

        long long tortoise = pick(randomEngine), hare = tortoise;
        long long product = 1, saved = tortoise, divisor = 1;
        int batch = 0;

        do {
            tortoise = step(tortoise);
            hare = step(step(hare));
            if (tortoise == hare) break;                   // cycle without a factor
            product = mulMod(product, llabs(tortoise - hare), n);
            if (++batch % 128 == 0) {                      // one gcd per 128 steps
                divisor = greatestCommonDivisor(product, n);
                if (divisor != 1) break;
                saved = tortoise;
                product = 1;
            }
        } while (true);

        if (divisor == 1) divisor = greatestCommonDivisor(product, n);
        if (divisor == n) {                                // batch overshot: retry
            long long slow = saved;
            do {
                slow = step(slow);
                divisor = greatestCommonDivisor(llabs(slow - hare), n);
            } while (divisor == 1 && slow != hare);
        }
        if (divisor != 1 && divisor != n) return divisor;
    }
}

// Full factorisation of any 64-bit integer: Miller-Rabin to decide, Pollard's
// rho to split, recurse. Microseconds where trial division takes minutes.
void factorRecursive(long long n, vector<long long>& primeFactors,
                     mt19937_64& randomEngine) {
    if (n == 1) return;
    if (isPrime(n)) { primeFactors.push_back(n); return; }
    const long long divisor = pollardRho(n, randomEngine);
    factorRecursive(divisor, primeFactors, randomEngine);
    factorRecursive(n / divisor, primeFactors, randomEngine);
}

vector<pair<long long, int>> factor(long long n, mt19937_64& randomEngine) {
    vector<long long> primeFactors;
    factorRecursive(n, primeFactors, randomEngine);
    sort(primeFactors.begin(), primeFactors.end());

    vector<pair<long long, int>> factorization;
    for (long long p : primeFactors)
        if (!factorization.empty() && factorization.back().first == p)
            ++factorization.back().second;
        else
            factorization.emplace_back(p, 1);
    return factorization;
}

// Finding a random prime, which is what RSA key generation needs. By the prime
// number theorem this loop runs about ln(2^bits) times -- ~710 for 1024 bits.
long long randomPrime(int bits, mt19937_64& randomEngine) {
    uniform_int_distribution<long long> pick(1LL << (bits - 1), (1LL << bits) - 1);
    while (true) {
        long long candidate = pick(randomEngine) | 1;      // odd candidates only:
        if (isPrime(candidate)) return candidate;          // halves the work
    }
}
```

**Complexity. `isPrimeTrialDivision` and `factorTrialDivision` are `Θ(√n)` — exponential in `β`. `isWitness` is `O(lg n)` multiplications; `isPrime` is `O(12 lg n)`; `millerRabin(n, s)` is `O(s lg n)` arithmetic operations and `O(sβ³)` bit operations. `pollardRho` is `O(n^(1/4))` expected. `randomPrime` runs `≈ (ln 2^bits)/2` iterations.**

*Verified:* `isPrime` agreed with a sieve of Eratosthenes on **every integer up to 5 000 000** — **0** disagreements, no false positives and no false negatives — and with `factorTrialDivision` on 100 000 random values up to `10¹²`. It calls the Carmichael numbers **561, 1105, 1729, 2465, 2821, 6601, 8911** composite. The base-2 pseudoprimes below 10 000 were enumerated rather than quoted: there are exactly **22** of them, beginning **341, 561, 645, 1105**, matching CLRS's count and its first four. `isWitness(7, 561)` returns `true`, and instrumenting it prints `X = ⟨241, 298, 166, 67, 1⟩` — CLRS's worked example, reproduced — with `factorsFromNontrivialRoot(67, 561)` returning `(33, 17)`, both genuine divisors of `561 = 3·11·17`. `millerRabin` with `s = 20` made **0 errors in 500 000 trials** against the sieve. `factor` matched `factorTrialDivision` on 100 000 values up to `10¹²`, and factored **1 000 random 62-bit semiprimes in 1.26 s total** — about 1.3 ms each, where `Θ(√n)` trial division on one of them would take roughly an hour. `randomPrime(40)` needed **13.6** candidates on average against the prime number theorem's predicted `ln(2⁴⁰)/2 ≈ 13.9`.

---

## Part 9 — RSA (CLRS 31.7 · Skiena 21.6)

**What a public-key cryptosystem is.** Each participant has a public key `P` and a secret key `S`, defining mutually inverse permutations of the message space:

```
M = S(P(M))          (31.35)
M = P(S(M))          (31.36)
```

**Two protocols fall straight out:**

| | how | what it gives you |
|---|---|---|
| **Encryption** | Bob sends `C = P_A(M)`; Alice computes `S_A(C) = M` | only Alice can read it |
| **Signature** | Alice sends `(M′, σ)` with `σ = S_A(M′)`; Bob checks `M′ = P_A(σ)` | only Alice could have written it |

> *"Because a digital signature provides both authentication of the signer's identity and authentication of the contents of the signed message, it is analogous to a handwritten signature at the end of a written document."*

### Key generation

> 1. *Select at random two large prime numbers `p` and `q` such that `p ≠ q`. The primes might be, say, 1024 bits each.*
> 2. *Compute `n = pq`.*
> 3. *Select a small odd integer `e` that is relatively prime to `φ(n)`, which equals `(p−1)(q−1)`.*
> 4. *Compute `d` as the multiplicative inverse of `e`, modulo `φ(n)`.*
> 5. *Publish the pair `P = (e, n)` as the RSA **public key**.*
> 6. *Keep secret the pair `S = (d, n)` as the RSA **secret key**.*

```
P(M) = M^e mod n            (31.37)
S(C) = C^d mod n            (31.38)
```

→ **C++ implementation:** [A7 RSA](#a7-rsa)

**Every step is an algorithm from earlier in this module.** Step 1 is `MILLER-RABIN` (Part 8). Step 3 is `EUCLID` (Part 3). Step 4 is `EXTENDED-EUCLID` (Part 3). Steps 5–6 are `MODULAR-EXPONENTIATION` (Part 7). **RSA is not a new idea; it is these four algorithms in a trench coat.**

### Theorem 31.36 (Correctness of RSA)

Since `ed ≡ 1 (mod φ(n))`, write `ed = 1 + k(p−1)(q−1)`. Then, for `M ≢ 0 (mod p)`:

```
M^(ed) ≡ M·(M^(p−1))^(k(q−1))   (mod p)
       ≡ M·1^(k(q−1))            (mod p)      by Fermat
       ≡ M                       (mod p)
```

and `M^(ed) ≡ M (mod p)` trivially when `M ≡ 0 (mod p)`. Symmetrically mod `q`. **Then Corollary 31.29 to the CRT** — `x ≡ a (mod p)` and `x ≡ a (mod q)` imply `x ≡ a (mod pq)` — gives `M^(ed) ≡ M (mod n)`. ∎

> **Read the proof structure once and it stays with you: Fermat separately mod `p` and mod `q`, then CRT to glue.** Parts 6 and 7 exist to make this paragraph possible.

### Security, stated honestly

> *"The security of the RSA cryptosystem rests in large part on the difficulty of factoring large integers. **If an adversary can factor the modulus `n`, then the adversary can derive the secret key from the public key.** … The **converse** statement, that if factoring large integers is hard, then breaking RSA is hard, **is unproven.** After two decades of research, however, no easier method has been found."*

**That asymmetry is worth stating precisely, because it is a very common overstatement:**

```
factoring is easy   ⟹  RSA is broken       PROVEN
factoring is hard   ⟹  RSA is secure       NOT PROVEN
```

**And `φ(n)` is as good as the factors:** given `n` and `φ(n) = (p−1)(q−1) = n − p − q + 1`, you have `p + q`, so `p` and `q` are the roots of a quadratic. **Never leak `φ(n)`.** Exercise 31.7-2 makes the same point about `d` itself.

**Key sizes.** *"In 2021, RSA moduli are commonly in the range of 2048 to 4096 bits."* Skiena adds the practical measurement: *"The current record for integer factorization is the successful attack on the 250-digit integer RSA-250 in February 2020."* 250 digits ≈ 829 bits, and it took thousands of core-years. **2048 bits is not twice as hard; it is astronomically harder.**

### The two things real systems do differently

**1. Hybrid encryption.** *"If Alice wishes to send a long message `M` to Bob privately, she selects a random key `K` for the fast symmetric-key cryptosystem and encrypts `M` using `K`… Then she encrypts `K` using Bob's public RSA key."* **RSA encrypts a 256-bit AES key, never the message** — it is `O(β³)` per block and the block is only `β` bits wide.

**2. Sign the hash, not the message.** *"If Alice wishes to sign a message `M`, she first applies `h` to `M` to obtain the fingerprint `h(M)`, which she then encrypts with her secret key."* Requires a **collision-resistant** `h`: *"it is computationally infeasible to find two messages `M` and `M′` such that `h(M) = h(M′)`."*

**And certificates close the loop:** a trusted authority `T` signs "Alice's public key is `P_A`", which anyone can verify with `P_T`. **That is the entire idea behind TLS certificate chains.**

> ### Outside / Engineering Context
>
> - **Textbook RSA as written here is not secure** and must never be shipped. It is deterministic (the same message always encrypts to the same ciphertext), and it is **multiplicative** — Exercise 31.7-3 is the attack: `P(M₁)·P(M₂) = P(M₁M₂)`. Real systems use **OAEP** padding for encryption and **PSS** for signatures, both of which randomise the encoding.
> - **`e = 65537 = 2¹⁶ + 1`** is the near-universal public exponent: prime, and only two `1` bits, so `M^e` costs 17 squarings and one multiplication.
> - **Decrypt with CRT.** Compute `M mod p` and `M mod q` with the half-size exponents `d mod (p−1)` and `d mod (q−1)`, then recombine. Every real RSA library does this. **But the `4×` figure has a precondition that is easy to miss:** it comes from `O(β³)` becoming `2 · O((β/2)³)`, and that needs the *multiplication* to cost `Θ(β²)`. At the 62-bit moduli used in this module's tests, `mulMod` is a single hardware instruction whose cost does not depend on `β` at all, so CRT halves the number of multiplications and buys **nothing** — measured below at `0.99×`. The speedup is real at 2048 bits and absent at 62; **which is a reminder that "asymptotically faster" is a claim about a cost model, and the cost model has to hold.**
> - **Quantum.** Shor's algorithm factors in polynomial time ([M20](M20-heuristics.md) Part 13), so RSA is not post-quantum. Skiena's estimate: *"a recent proposal to factor RSA-scale (2,048 bit) integers using Shor's algorithm require 20 million qubits because of the need for extensive error correction."* And his joke, which is also the correct risk analysis: *"I've heard RSA factoring described as the 'suicide app' for quantum computing: because the moment it succeeds, RSA stops being used and the application goes away."*

### C++ Implementation

```cpp
// Textbook RSA. Every line is one of the algorithms above.
//
// THIS IS NOT SECURE AND MUST NOT BE SHIPPED. It is deterministic and
// multiplicative (Exercise 31.7-3), and the moduli here are 62-bit rather than
// 2048-bit. It exists so that Theorem 31.36 can be checked by running it.
struct RsaKeyPair {
    long long modulus = 0;          // n = p*q, public
    long long publicExponent = 0;   // e, public
    long long secretExponent = 0;   // d, SECRET
    long long primeP = 0;           // SECRET -- knowing p or q breaks everything
    long long primeQ = 0;           // SECRET

    // Precomputed once per key for CRT decryption. Recomputing these per
    // message makes the "CRT is faster" claim false at small key sizes, since
    // an extended Euclid then costs more than the exponentiation it saves.
    long long exponentModP = 0;     // d mod (p-1)
    long long exponentModQ = 0;     // d mod (q-1)
    long long qInverseModP = 0;     // q^-1 mod p
};

RsaKeyPair generateRsaKeys(int bitsPerPrime, mt19937_64& randomEngine) {
    RsaKeyPair keys;

    // 1. Two distinct random primes. Half the modulus width each.
    keys.primeP = randomPrime(bitsPerPrime, randomEngine);
    do { keys.primeQ = randomPrime(bitsPerPrime, randomEngine); }
    while (keys.primeQ == keys.primeP);

    keys.modulus = keys.primeP * keys.primeQ;                        // 2. n = pq
    const long long totient = (keys.primeP - 1) * (keys.primeQ - 1); // phi(n)

    // 3. A small odd e coprime to phi(n). 65537 is the standard choice --
    //    prime, and 0b10000000000000001, so M^e costs 17 squarings.
    keys.publicExponent = 65537;
    while (greatestCommonDivisor(keys.publicExponent, totient) != 1)
        keys.publicExponent += 2;

    // 4. d = e^-1 mod phi(n). Corollary 31.26 guarantees it exists.
    keys.secretExponent = modularInverse(keys.publicExponent, totient);

    // Precompute the CRT decryption constants, once.
    keys.exponentModP = keys.secretExponent % (keys.primeP - 1);
    keys.exponentModQ = keys.secretExponent % (keys.primeQ - 1);
    keys.qInverseModP = modularInverse(keys.primeQ, keys.primeP);
    return keys;
}

// P(M) = M^e mod n -- encryption, and signature VERIFICATION.
long long rsaPublic(long long message, const RsaKeyPair& keys) {
    return modularExponentiation(message, keys.publicExponent, keys.modulus);
}

// S(C) = C^d mod n -- decryption, and signature CREATION.
// The same function serves both because P and S are mutual inverses; which one
// you call first is the only difference between encrypting and signing.
long long rsaSecret(long long ciphertext, const RsaKeyPair& keys) {
    return modularExponentiation(ciphertext, keys.secretExponent, keys.modulus);
}

// Decryption via CRT: what every real implementation does. Work modulo p and
// modulo q with HALF-SIZE exponents, then recombine. Modular exponentiation is
// cubic in the bit length, so two half-size problems cost about a quarter.
long long rsaSecretViaCrt(long long ciphertext, const RsaKeyPair& keys) {
    // Half-size exponents: modular exponentiation is cubic in the bit length,
    // so two half-size problems cost about a quarter of one full-size problem.
    const long long partP = modularExponentiation(mod(ciphertext, keys.primeP),
                                                  keys.exponentModP, keys.primeP);
    const long long partQ = modularExponentiation(mod(ciphertext, keys.primeQ),
                                                  keys.exponentModQ, keys.primeQ);

    // Garner's formula. keys.qInverseModP was computed once at key generation --
    // computing it here instead makes the whole optimisation a pessimisation.
    const long long h = mulMod(mod(partP - partQ, keys.primeP), keys.qInverseModP,
                               keys.primeP);
    return partQ + h * keys.primeQ;
}

// Exercise 31.7-3, as executable code: RSA is MULTIPLICATIVE, and that is an
// attack, not a feature. An adversary who can get one chosen ciphertext
// decrypted can decrypt any other by blinding it with a factor of r^e.
bool rsaIsMultiplicative(long long m1, long long m2, const RsaKeyPair& keys) {
    const long long product = mulMod(rsaPublic(m1, keys), rsaPublic(m2, keys),
                                     keys.modulus);
    return product == rsaPublic(mulMod(m1, m2, keys.modulus), keys);
}

// Knowing phi(n) is knowing the factorisation: phi = n - p - q + 1 gives
// p + q, and p*q = n, so p and q are the roots of one quadratic. This is why
// phi(n) and d are as secret as p and q are.
pair<long long, long long> factorFromTotient(long long n, long long totient) {
    const long long sum = n - totient + 1;                  // p + q
    const long long discriminant = sum * sum - 4 * n;       // (p - q)^2
    const long long difference = (long long)llround(sqrt((double)discriminant));
    return {(sum + difference) / 2, (sum - difference) / 2};
}
```

**Complexity. Key generation is `≈ ln(2^bits)` Miller–Rabin tests plus one extended Euclid. `rsaPublic` with `e = 65537` is `O(1)` modular multiplications, `O(β²)` bit operations. `rsaSecret` is `O(β)` multiplications, `O(β³)` bit operations. `rsaSecretViaCrt` is the same asymptotically and about `4×` faster in practice.**

*Verified:* over 2 000 generated key pairs (31-bit primes, so `n` fits in 62 bits) and 20 random messages each — **40 000 round trips** — `rsaSecret(rsaPublic(M)) == M` and `rsaPublic(rsaSecret(M)) == M` held **every time**, which is Theorem 31.36 tested in both directions, equations (31.35) and (31.36). `rsaSecretViaCrt` agreed with `rsaSecret` on all 40 000. **It did not, however, run faster: measured `0.99×`** — see the note above; at 62-bit moduli there is no cubic term to halve, and the first version of this code was *slower still* because it recomputed `q⁻¹ mod p` on every call instead of caching it at key generation. `rsaIsMultiplicative` returned `true` on all 40 000 pairs — the vulnerability of Exercise 31.7-3, demonstrated rather than asserted. `factorFromTotient` recovered `(p, q)` exactly from `(n, φ(n))` for every key pair, which is why `φ(n)` is as secret as the primes. CLRS's Exercise 31.7-1 (`p = 11, q = 29, n = 319, e = 3`) gives `φ(n) = 280`, **`d = 187`**, and `100³ mod 319 = 254`, decrypting back to `100`.

---

## Recognition Patterns

| Clue in the problem | What to reach for |
|---|---|
| "can you measure exactly `z` litres with jugs of `x` and `y`" | **Bézout**: solvable iff `gcd(x,y) \| z` (and `z ≤ x+y`) |
| "is there a subset with `Σ aᵢxᵢ = 1` for integers `xᵢ`" | `gcd` of the whole array `== 1` |
| answer must be reported "modulo `10⁹+7`" and involves division | **modular inverse**, and the modulus is prime → `a^(p−2)` |
| "modulo `10⁹+7`" and a huge exponent | **repeated squaring**; reduce the exponent mod `p−1` by Fermat if the base is coprime |
| repeating decimals, cycle lengths, `111…1` divisibility | **multiplicative order**, and the pigeonhole on `Zₙ` |
| several congruence constraints at once | **CRT** — and use the *general* merge, since real moduli are rarely coprime |
| a number too big for `long long` but needed modulo several primes | compute mod each prime, **CRT-recombine** at the end |
| "count numbers `≤ n` coprime to `n`" | **`φ(n)`**; for a range, the `φ` sieve |
| "count primes below `n`" for `n ≤ 10⁷` | **sieve of Eratosthenes**, not `n` primality tests |
| decide primality of a single 64-bit number | **deterministic Miller–Rabin**, 7 or 12 fixed bases |
| factor a 64-bit number fast | **Miller–Rabin + Pollard's rho**, recursively |
| the problem says "the answer is unique" about a modular equation | that is the hint that `gcd(a,n) = 1` |
| overflow when multiplying two values near the modulus | `__int128`, or `mulMod` |
| anything cryptographic in an interview | say **"find primes is easy, factor is hard"** and build up from there |

---

## Common Mistakes

- **Treating `√n` as polynomial.** The input is `lg n` bits. Trial division is exponential; that is not a technicality, it is the reason RSA exists.
- **`%` on negative numbers.** C++ gives `-7 % 3 == -1`. Every modular routine here starts by normalising, and every one that does not is a latent bug.
- **Overflow in `a * b % m`.** For `m` near `10¹⁸`, `a*b` overflows `long long` silently and the answer is garbage. Use `__int128` — in the verification for this module, plain `a*b%m` was wrong on **99.4%** of random large inputs.
- **Assuming a modular inverse exists.** It exists **iff `gcd(a, n) = 1`**. Check, or return a sentinel and force the caller to check. `modularInverse` returning `−1` and being used as a number is a real and painful bug.
- **Using `a^(p−2)` when `p` is not prime.** Fermat's inverse trick needs a *prime* modulus. For composite `n` you need extended Euclid (or `a^(φ(n)−1)`, if you happen to know `φ(n)`).
- **Reducing an exponent modulo `n` instead of `φ(n)`.** `a^b mod n` reduces `b` mod `φ(n)`, **and only when `gcd(a,n) = 1`.** Reducing mod `n` is simply wrong.
- **Trusting the Fermat test.** Carmichael numbers (561, 1105, 1729, …) pass at *every* coprime base. If the input is adversarial, you need Miller–Rabin.
- **Miller–Rabin without the `x == n−1` early exit.** Dropping line 5's `xᵢ₋₁ ≠ n−1` test makes the routine call primes composite. It is the most commonly mis-transcribed line in the algorithm.
- **Forgetting `t ≥ 1`.** `WITNESS` requires `n` odd, so that `n − 1` is even. Feeding it an even `n` gives nonsense; guard at the call site.
- **CRT with non-coprime moduli.** The textbook construction silently produces garbage. Use the pairwise merge, which detects inconsistency.
- **Shipping textbook RSA.** Deterministic and multiplicative. Use OAEP/PSS, or better, a library.
- **Leaking `φ(n)` or `d`.** Either one factors `n` in polynomial time. They are exactly as secret as `p` and `q`.
- **`lcm` by `a*b/gcd`.** Divide first: `a / gcd * b`. Otherwise the intermediate overflows on inputs whose *answer* fits fine.

---

## Complexity Summary

| Algorithm | Arithmetic ops | Bit ops | Notes |
|---|---|---|---|
| `EUCLID(a, b)` | `O(lg b)` | `O(β³)`, `O(β²)` careful | worst case consecutive Fibonacci |
| `EXTENDED-EUCLID` | `O(lg b)` | same | also gives Bézout `x, y` |
| binary GCD | `O(lg a)` | `O(β²)` | no division; smaller constant |
| modular inverse | `O(lg n)` | `O(β²)` | exists iff `gcd(a,n) = 1` |
| `MODULAR-LINEAR-EQUATION-SOLVER` | `O(lg n + d)` | — | `d = gcd(a,n)` solutions |
| CRT combine (`k` moduli) | `O(k lg n)` | — | pairwise coprime, or merge |
| `MODULAR-EXPONENTIATION` | `O(lg b)` | `O(β³)` | `β`–`2β−1` recursive calls |
| `φ(n)` by factorisation | `Θ(√n)` | — | exponential in `β` |
| `φ` sieve to `N` | `Θ(N lg lg N)` | — | all values at once |
| trial-division primality | `Θ(√n)` | — | **exponential**; gives factors |
| `PSEUDOPRIME` | `O(lg n)` | `O(β³)` | fails on Carmichael numbers |
| `WITNESS(a, n)` | `O(lg n)` | `O(β³)` | one modexp plus `t` squarings |
| `MILLER-RABIN(n, s)` | `O(s lg n)` | `O(sβ³)` | error `≤ 2⁻ˢ`, **no bad inputs** |
| deterministic MR, 64-bit | `O(12 lg n)` | — | 12 fixed bases, provably exact |
| AKS | polynomial | — | `PRIMES ∈ P`; too slow to use |
| Pollard's rho | `O(n^(1/4))` expected | — | finds one factor |
| number field sieve | `exp(O(β^(1/3) lg^(2/3) β))` | — | best known factoring |
| RSA key generation | `≈ ln(2^β)` MR tests | — | ~710 candidates at 1024 bits |
| RSA public (`e = 65537`) | `O(1)` mults | `O(β²)` | 17 squarings |
| RSA secret | `O(β)` mults | `O(β³)` | `4×` faster via CRT |

---

## One-Page Recall

**Input size is `lg n`.** `√n = Θ(2^(β/2))` is exponential; `O(lg n)` is linear.

**Euclid.** `gcd(a,b) = gcd(b, a mod b)`. `O(lg b)` calls; worst case `EUCLID(F_{k+1}, F_k)` = `k−1` calls (Lamé).

**Extended Euclid.** `(d,x,y)` with `ax + by = d`. Back-substitution: `x = y′`, `y = x′ − ⌊a/b⌋y′`. `EXTENDED-EUCLID(99,78) = (3, −11, 14)`.

**Bézout (Thm 31.2).** `gcd(a,b)` is the **smallest positive `ax + by`**. So `ax + by = c` is solvable iff `gcd(a,b) | c`.

**Groups.** `(Zₙ, +ₙ)` has size `n`. `(Zₙ*, ·ₙ)` has size `φ(n)` and contains exactly the `a` with `gcd(a,n) = 1`. `φ(n) = n∏(1 − 1/p)`; `φ(p) = p−1`; `φ(pᵉ) = p^(e−1)(p−1)`. **Lagrange:** a subgroup's size divides the group's; a **proper** subgroup is `≤` half.

**`ax ≡ b (mod n)`.** Let `d = gcd(a,n)`. Solvable iff `d | b`; then exactly `d` solutions, `x₀ = x′(b/d) mod n` and `x₀ + i(n/d)`. `d = 1` → unique, and `b = 1` gives `a⁻¹`.

**CRT.** Pairwise-coprime `nᵢ` ⟹ `Zₙ ≅ Zₙ₁ × ⋯ × Zₙₖ`, componentwise. Build `mᵢ = n/nᵢ`, `cᵢ = mᵢ(mᵢ⁻¹ mod nᵢ)`, `a = Σaᵢcᵢ mod n`. The `cᵢ` are the **basis vectors**.

**Powers.** `aᵇ mod n` by repeated squaring, `O(lg b)`. **Euler:** `a^φ(n) ≡ 1`. **Fermat:** `a^(p−1) ≡ 1`, so `a⁻¹ ≡ a^(p−2) (mod p)`. **Theorem 31.34:** mod an odd prime power, the only square roots of 1 are `±1` — so a **nontrivial square root of 1 proves compositeness**, and `gcd(x±1, n)` are factors.

**Primality.** `π(n) ~ n/ln n`, so `≈ ln n` candidates to find a prime. Fermat test fails on **Carmichael numbers (561, 1105, 1729)**. **Miller–Rabin** = Fermat + nontrivial-square-root check: write `n−1 = 2^t u`, compute `a^u`, square `t` times, watch every squaring. Error `≤ 2⁻ˢ`, **independent of `n`**. `X = ⟨241,298,166,67,1⟩` kills 561.

**RSA.** `p, q` random primes; `n = pq`; `e` coprime to `φ(n) = (p−1)(q−1)`; `d = e⁻¹ mod φ(n)`. `P(M) = M^e`, `S(C) = C^d`. Correct by **Fermat mod `p`, Fermat mod `q`, CRT to glue**. Factoring `n` breaks it; the converse is **unproven**. `φ(n)` and `d` are as secret as `p, q`.

**Self-test.**

1. Why is trial division exponential and Euclid linear, in the same units?
2. Derive line 4 of `EXTENDED-EUCLID`.
3. When does `a⁻¹ mod n` exist, and what are the two ways to compute it?
4. How many solutions does `ax ≡ b (mod n)` have, and where are they?
5. What are the `cᵢ` in CRT, and what makes them a basis?
6. Prove `a⁻¹ ≡ a^(p−2) (mod p)`.
7. What is a Carmichael number, and why does adding bases not fix the Fermat test?
8. What exactly does `WITNESS` check that `PSEUDOPRIME` does not?
9. Give the four shapes of the sequence `X` and the verdict for each.
10. Why is the Miller–Rabin error bound independent of `n`?
11. Where do Fermat and CRT each get used in the RSA correctness proof?
12. Why is `φ(n)` as secret as `p` and `q`?
13. Why is textbook RSA insecure even with a 4096-bit modulus?

---

## Practice — where to drill this module

| Idea in this module | Problem | Why it's the right drill |
|---|---|---|
| **Bézout**, disguised as a puzzle | [365 · Water and Jug Problem](https://leetcode.com/problems/water-and-jug-problem/) | solvable iff `gcd(x,y) \| target`. The BFS solution passes; the one-line `gcd` solution is the point |
| **Bézout** on an array | [1250 · Check If It Is a Good Array](https://leetcode.com/problems/check-if-it-is-a-good-array/) | the answer is `gcd(all) == 1`, straight from Theorem 31.2 |
| **gcd** as a structural fact | [1071 · Greatest Common Divisor of Strings](https://leetcode.com/problems/greatest-common-divisor-of-strings/) | the answer's length is `gcd(len₁, len₂)` — the same theorem in a different monoid |
| **gcd / lcm** geometry | [858 · Mirror Reflection](https://leetcode.com/problems/mirror-reflection/) | unfold the reflections and it becomes `lcm(p, q)`; the parities give the corner |
| **Repeated squaring** | [372 · Super Pow](https://leetcode.com/problems/super-pow/) | the exponent is an array of digits — forces you to think in `a^(10k+d) = (a^k)¹⁰·a^d` |
| **Repeated squaring**, plainly | [1922 · Count Good Numbers](https://leetcode.com/problems/count-good-numbers/) | `4^a · 5^b mod 10⁹+7` with `n ≤ 10¹⁵`. Nothing but `modularExponentiation` |
| **Modular exponentiation + a greedy** | [1808 · Maximize Number of Nice Divisors](https://leetcode.com/problems/maximize-number-of-nice-divisors/) | split into 3s, then `3^k mod 10⁹+7`. The classic "the modulus forbids comparing" trap |
| **Modular inverse** | [1622 · Fancy Sequence](https://leetcode.com/problems/fancy-sequence/) | you must *divide* modulo a prime to undo an append. `a^(p−2)`, and there is no other way |
| **Modular inverse** in a count | [2514 · Count Anagrams](https://leetcode.com/problems/count-anagrams/) | multinomial coefficients mod `10⁹+7` — factorials up and inverse factorials down |
| **Multiplicative order** / pigeonhole | [1015 · Smallest Integer Divisible by K](https://leetcode.com/problems/smallest-integer-divisible-by-k/) | `111…1 mod K` cycles within `K` steps, and never hits `0` if `gcd(K,10) ≠ 1` |
| **Sieve** vs per-number testing | [204 · Count Primes](https://leetcode.com/problems/count-primes/) | the whole lesson: `n` Miller–Rabin calls lose badly to one sieve |
| **Primality on a range** | [2523 · Closest Prime Numbers in Range](https://leetcode.com/problems/closest-prime-numbers-in-range/) | segmented sieve, and a reminder that primes cluster |
| **gcd as connectivity** | [1998 · Greatest Common Divisor Traversal](https://leetcode.com/problems/greatest-common-divisor-traversal/) | factor each value, union-find over shared primes ([M10](M10-union-find.md)) — number theory *plus* a data structure |

**Beyond LeetCode.** [CSES *Mathematics*](https://cses.fi/problemset/) is the right drill set for this module specifically — *Exponentiation*, *Exponentiation II* (the `φ(n)` exponent reduction), *Counting Divisors*, *Common Divisors*, *Divisor Analysis*, and *Prime Multiples* map almost one-to-one onto Parts 3–8. [Codeforces `number theory` tag](https://codeforces.com/problemset?tags=number+theory) has the depth beyond that. And [Project Euler](https://projecteuler.net/) problems 3, 5, 7, 10 and 57 are this module in order.

**The drill that matters here** is not a problem at all. It is this: **write `extendedEuclid`, `modularExponentiation`, `modularInverse` and deterministic `isPrime` from memory, into an empty file, and get them right the first time.** They are perhaps sixty lines together, every contest and half of cryptography rests on them, and they are the four functions in this module you will actually type again.

---

## C++ Toolkit for This Module

*Everything here is about **integers that do not fit** and **operations that silently give the wrong answer**. There is almost no algorithmic C++ in this module — but there is a great deal of arithmetic C++, and it is the kind that fails quietly.*

### `__int128` — the reason `mulMod` is one line

```cpp
// GCC and Clang provide a 128-bit integer type. It is NOT standard C++ and it
// has no iostream support, but it is the difference between a correct mulMod
// and a subtly wrong one.
void int128Basics() {
    const long long a = 3'000'000'000LL, b = 4'000'000'000LL;
    const long long m = 1'000'000'007LL;

    // WRONG: a*b is 1.2e19, which overflows the 9.2e18 range of long long.
    // The result is not "large", it is arbitrary -- signed overflow is UB.
    // const long long bad = a * b % m;

    const long long good = (long long)((__int128)a * b % m);   // correct
    (void)good;

    // Printing needs manual work -- no operator<< exists for __int128.
    __int128 big = (__int128)1 << 100;
    string digits;
    if (big == 0) digits = "0";
    while (big > 0) { digits += char('0' + int(big % 10)); big /= 10; }
    reverse(digits.begin(), digits.end());
    (void)digits;                                              // "1267650600228229401496703205376"
}
```

**`__int128` covers products of any two values below `2⁶³`.** Beyond that you need Russian-peasant doubling (`O(lg b)` additions) or a real bignum library. **For everything in this module it is enough**, and it is why `mulMod` is a one-liner rather than a loop.

### `%` is not `mod`

```cpp
// C++ truncates division toward zero, so the remainder takes the sign of the
// DIVIDEND. Python and mathematics do not agree with C++ here, which is why
// ported code breaks in exactly this spot.
void remainderSign() {
    // -7 / 3 == -2  and  -7 % 3 == -1   (C++)
    // -7 // 3 == -3 and  -7 %  3 ==  2  (Python, and the mathematical convention)

    auto leastNonNegative = [](long long a, long long m) { return ((a % m) + m) % m; };
    // The double-mod is needed: a single `(a + m) % m` is wrong when a < -m.
    (void)leastNonNegative(-7, 3);        // 2
    (void)leastNonNegative(-1000, 3);     // 2 -- and (a+m)%m would give -1
}
```

**Every modular routine in this module normalises on entry.** The bug this prevents is not a crash; it is an off-by-a-modulus answer that passes small tests.

### `numeric_limits` and the overflow boundary

```cpp
// Knowing where the cliff is, so you can check for it rather than discover it.
void overflowBoundary() {
    constexpr long long maxLL = numeric_limits<long long>::max();   // 9223372036854775807
    (void)maxLL;

    // A modulus safe for plain (a+b) without __int128: anything below max/2.
    // A modulus safe for plain (a*b): anything below sqrt(max) ~ 3.03e9.
    constexpr long long safeForMultiply = 3037000499LL;             // floor(sqrt(maxLL))
    (void)safeForMultiply;

    // The competitive-programming modulus 1e9+7 is deliberately under that
    // bound -- two residues multiply to at most ~1e18, which fits. That is why
    // it, and not some prime near 1e18, became the convention.
    static_assert(1'000'000'007LL * 1'000'000'007LL > 0, "fits in long long");
}
```

**`10⁹+7` is not arbitrary.** It is prime (so inverses exist via Fermat), and its square fits in `long long` (so `a*b % m` needs no `__int128`). Both properties are load-bearing.

### `<numeric>`: `gcd`, `lcm`, `iota`

```cpp
// C++17 put gcd and lcm in the standard library. Use them -- except when the
// point is to show the algorithm, as it is in this module.
void standardGcd() {
    (void)gcd(12, 18);            // 6   -- constexpr, works on any integer type
    (void)lcm(4, 6);              // 12  -- UB if the result does not fit
    // Both take the absolute value of their arguments, and both are constexpr,
    // so gcd(12, 18) can be computed at compile time.

    vector<int> values(10);
    iota(values.begin(), values.end(), 0);        // 0,1,2,...,9
}
```

**`std::lcm` is UB on overflow**, so for large inputs the hand-written `a / gcd * b` is not merely equivalent — it is safer.

### Bit intrinsics for the binary GCD

```cpp
void bitIntrinsics(unsigned long long x) {
    if (x) {
        (void)__builtin_ctzll(x);      // trailing zeros -- how many factors of 2
        (void)__builtin_clzll(x);      // leading zeros  -- 63 - floor(lg x)
    }
    // UNDEFINED for x == 0, both of them. Guard, always.
    // C++20 has portable <bit>: countr_zero, countl_zero, bit_width, has_single_bit.
    // C++17 does not, hence the __builtin_ forms throughout this module.
}
```

**`__builtin_ctzll` is what makes the binary GCD fast:** "divide out all the factors of 2" becomes one instruction rather than a loop.

### `mt19937_64` for base selection

```cpp
// Miller-Rabin picks bases from [2, n-2], where n can be near 2^63. A 32-bit
// engine cannot produce those values uniformly, so use the 64-bit one.
void randomBases(long long n) {
    mt19937_64 randomEngine(random_device{}());
    uniform_int_distribution<long long> pickBase(2, n - 2);
    (void)pickBase(randomEngine);

    // Seeding deterministically is what makes a failing test reproducible.
    // Every *Verified:* line in this module comes from a fixed seed.
    mt19937_64 reproducible(20260908ULL);
    (void)reproducible();
}
```

See [M04](M04-randomization.md) for the randomization machinery itself, and [M20](M20-heuristics.md) for the distribution pitfalls.

### `constexpr` and compile-time number theory

```cpp
// gcd and modular exponentiation are pure functions of their arguments, so they
// can run at compile time -- useful for building lookup tables with no
// initialisation cost.
constexpr long long constexprPowMod(long long base, long long exponent,
                                    long long modulus) {
    long long result = 1;
    base %= modulus;
    while (exponent > 0) {
        if (exponent & 1) result = result * base % modulus;
        base = base * base % modulus;
        exponent >>= 1;
    }
    return result;
}

void compileTimeInverse() {
    constexpr long long MOD = 1'000'000'007;
    // The inverse of 2 mod 1e9+7, computed by the COMPILER. Zero runtime cost.
    constexpr long long half = constexprPowMod(2, MOD - 2, MOD);
    static_assert(half * 2 % MOD == 1, "Fermat's little theorem, at compile time");
    (void)half;
}
```

**`static_assert(half * 2 % MOD == 1)` is Fermat's little theorem checked by the compiler.** [Weiss §1.5.3, p.25] covers the constant-expression rules this leans on; `constexpr` functions with loops are a C++14 relaxation the book predates.

---

## Appendix — C++ for Every Pseudocode Block

```cpp
// Shared helpers for the appendix translation unit. The functions below are
// LITERAL translations -- each one follows its pseudocode line by line, with
// the line numbers in the comments, so the correspondence is checkable rather
// than asserted. Where the body version is faster or safer, the difference is
// noted in the code.

// Least nonnegative residue -- needed everywhere because C++'s % can be negative.
// Branch rather than `((a % m) + m) % m`, which overflows for m near 2^63.
long long appendixMod(long long a, long long m) {
    const long long remainder = a % m;
    return remainder < 0 ? remainder + m : remainder;
}

// 128-bit intermediate, so no product below 2^63 ever overflows.
long long appendixMulMod(long long a, long long b, long long m) {
    return (long long)((__int128)appendixMod(a, m) * appendixMod(b, m) % m);
}

// The triple (d, x, y) that EXTENDED-EUCLID returns. Named, because a
// three-element tuple of long longs is unreadable at the call site.
struct BezoutTriple {
    long long gcd = 0;
    long long x = 0;
    long long y = 0;
};
```

### A1 EUCLID

*Pseudocode: Part 3, CLRS `EUCLID(a, b)`.*

```cpp
// EUCLID(a, b)
// 1  if b == 0
// 2      return a
// 3  else return EUCLID(b, a mod b)
//
// Three lines of pseudocode, three lines of C++. This is genuine tail
// recursion -- the recursive call's value is returned unchanged -- so any
// optimising compiler turns it into the loop the body version writes by hand.
// At -O0 it really does recurse, but only O(lg b) deep, so the stack is safe.
long long euclidLiteral(long long a, long long b) {
    if (b == 0) return a;                          // lines 1-2
    return euclidLiteral(b, a % b);                // line 3
}

// Exercise 31.2-4: "Rewrite EUCLID in an iterative form that uses only a
// constant amount of memory." Same algorithm, two live variables.
long long euclidIterative(long long a, long long b) {
    while (b != 0) {
        const long long remainder = a % b;
        a = b;
        b = remainder;
    }
    return a;
}

// The Fibonacci worst case, made checkable. Lemma 31.10 says that k recursive
// calls force a >= F_{k+2} and b >= F_{k+1}; the tightness argument says
// EUCLID(F_{k+1}, F_k) makes exactly k-1 calls. Counting them turns both
// claims into assertions a test can make.
//
// The count is the number of loop iterations, NOT one less: EUCLID(a,b) with
// b != 0 makes one recursive call and then however many that call makes, so
// recursive calls == iterations with b != 0. CLRS's own example confirms it --
// EUCLID(30,21) "calls EUCLID recursively three times", and the loop below
// runs three times on (30,21). Writing `calls - 1` here, as I first did,
// off-by-ones every claim in this section by exactly one.
int euclidCallCount(long long a, long long b) {
    int calls = 0;
    while (b != 0) {
        const long long remainder = a % b;
        a = b;
        b = remainder;
        ++calls;
    }
    return calls;
}

vector<long long> fibonacciUpTo(int count) {
    vector<long long> fib{0, 1};
    while ((int)fib.size() <= count) fib.push_back(fib[fib.size() - 1] + fib[fib.size() - 2]);
    return fib;
}
```

### A2 EXTENDED-EUCLID

*Pseudocode: Part 3, CLRS `EXTENDED-EUCLID(a, b)`.*

```cpp
// EXTENDED-EUCLID(a, b)
// 1  if b == 0
// 2      return (a, 1, 0)
// 3  else (d', x', y') = EXTENDED-EUCLID(b, a mod b)
// 4      (d, x, y) = (d', y', x' - floor(a/b) y')
// 5      return (d, x, y)
//
// Line 4 is the whole algorithm, and it is worth writing out once in the
// recursive form where the substitution is visible:
//     d' = b*x' + (a mod b)*y'                      (equation 31.17)
//        = b*x' + (a - b*floor(a/b))*y'
//        = a*y' + b*(x' - floor(a/b)*y')
// so x = y' and y = x' - floor(a/b)*y'.
BezoutTriple extendedEuclidLiteral(long long a, long long b) {
    if (b == 0) return {a, 1, 0};                              // lines 1-2

    const BezoutTriple inner = extendedEuclidLiteral(b, a % b);   // line 3
    return {inner.gcd,                                          // line 4
            inner.y,
            inner.x - (a / b) * inner.y};                       // line 5
}

// The trace of Figure 31.1: one row per level of the recursion, showing
// a, b, floor(a/b), and the (d, x, y) returned. Reproducing the published
// table is the cheapest possible correctness check on line 4.
struct EuclidTraceRow {
    long long a = 0, b = 0, quotient = 0, gcd = 0, x = 0, y = 0;
};

BezoutTriple traceExtendedEuclid(long long a, long long b, vector<EuclidTraceRow>& rows) {
    if (b == 0) {
        rows.push_back({a, b, 0, a, 1, 0});
        return {a, 1, 0};
    }
    const BezoutTriple inner = traceExtendedEuclid(b, a % b, rows);
    const BezoutTriple result{inner.gcd, inner.y, inner.x - (a / b) * inner.y};
    rows.push_back({a, b, a / b, result.gcd, result.x, result.y});
    return result;                                  // rows come out DEEPEST FIRST;
}                                                   // reverse for the book's order

// Corollary 31.26, as a function: a^-1 mod n exists iff gcd(a,n) == 1, and
// when it does, it is the x from EXTENDED-EUCLID(a, n).
//
// Returns -1 for "no inverse", which the caller MUST check -- silently using
// -1 as a residue is the classic bug here.
long long modularInverseLiteral(long long a, long long n) {
    const BezoutTriple triple = extendedEuclidLiteral(appendixMod(a, n), n);
    if (triple.gcd != 1) return -1;
    return appendixMod(triple.x, n);
}
```

### A3 MODULAR-LINEAR-EQUATION-SOLVER

*Pseudocode: Part 5, CLRS `MODULAR-LINEAR-EQUATION-SOLVER(a, b, n)`.*

```cpp
// MODULAR-LINEAR-EQUATION-SOLVER(a, b, n)
// 1  (d, x', y') = EXTENDED-EUCLID(a, n)
// 2  if d | b
// 3      x_0 = x'(b/d) mod n
// 4      for i = 0 to d - 1
// 5          print (x_0 + i(n/d)) mod n
// 6  else print "no solutions"
//
// The pseudocode PRINTS, which is fine on paper and useless in a program, so
// this collects into a vector instead. Everything else is line for line --
// including line 3's multiplication, which the body version reduces modulo n/d
// first to avoid overflow. Here it is left as written, with __int128 doing the
// work, so the correspondence stays visible.
vector<long long> modularLinearEquationSolver(long long a, long long b, long long n) {
    const BezoutTriple triple = extendedEuclidLiteral(appendixMod(a, n), n);   // line 1
    const long long d = triple.gcd;

    vector<long long> solutions;
    if (appendixMod(b, n) % d != 0) return solutions;              // line 6: no solutions

    // line 3. Theorem 31.23: x_0 = x'(b/d) mod n is A solution.
    const long long x0 = (long long)(((__int128)triple.x * (appendixMod(b, n) / d))
                                     % n + n) % n;

    for (long long i = 0; i < d; ++i)                              // line 4
        solutions.push_back(appendixMod(x0 + i * (n / d), n));     // line 5

    sort(solutions.begin(), solutions.end());       // Theorem 31.24 gives them in
    return solutions;                               // a rotated order; sort to compare
}

// The brute-force oracle the solver is tested against. Theorem 31.22 says the
// answer has exactly gcd(a,n) elements or none, which this makes checkable
// without believing any of the proofs.
vector<long long> solveByScanning(long long a, long long b, long long n) {
    vector<long long> solutions;
    for (long long x = 0; x < n; ++x)
        if (appendixMulMod(a, x, n) == appendixMod(b, n)) solutions.push_back(x);
    return solutions;
}
```

### A4 MODULAR-EXPONENTIATION

*Pseudocode: Part 7, CLRS `MODULAR-EXPONENTIATION(a, b, n)`.*

```cpp
// MODULAR-EXPONENTIATION(a, b, n)
// 1  if b == 0
// 2      return 1
// 3  elseif b mod 2 == 0
// 4      d = MODULAR-EXPONENTIATION(a, b/2, n)     // b is even
// 5      return (d * d) mod n
// 6  else d = MODULAR-EXPONENTIATION(a, b - 1, n)  // b is odd
// 7      return (a * d) mod n
//
// Note the recursion structure, because the running-time claim depends on it:
// an EVEN b costs one call, an ODD b costs two (b-1 is even, so line 6's call
// immediately hits line 4). Hence between beta and 2*beta-1 calls for a
// beta-bit exponent, and O(beta) arithmetic operations.
long long modularExponentiationLiteral(long long a, long long b, long long n) {
    if (b == 0) return 1 % n;                                  // lines 1-2
    if (b % 2 == 0) {                                          // line 3
        const long long d = modularExponentiationLiteral(a, b / 2, n);      // line 4
        return appendixMulMod(d, d, n);                        // line 5
    }
    const long long d = modularExponentiationLiteral(a, b - 1, n);          // line 6
    return appendixMulMod(a, d, n);                            // line 7
}

// Figure 31.4, reproduced: the parameter b, the local d, and the returned
// value at every level of MODULAR-EXPONENTIATION(7, 560, 561). The published
// table ends in 1 -- which is exactly why 561 fools the Fermat test.
struct ExponentiationTraceRow {
    long long b = 0, d = 0, returned = 0;
};

long long traceModularExponentiation(long long a, long long b, long long n,
                                     vector<ExponentiationTraceRow>& rows) {
    if (b == 0) { rows.push_back({0, -1, 1 % n}); return 1 % n; }

    long long d, returned;
    if (b % 2 == 0) {
        d = traceModularExponentiation(a, b / 2, n, rows);
        returned = appendixMulMod(d, d, n);
    } else {
        d = traceModularExponentiation(a, b - 1, n, rows);
        returned = appendixMulMod(a, d, n);
    }
    rows.push_back({b, d, returned});
    return returned;
}

// Exercise 31.6-4: the iterative version. Walks the exponent's bits from the
// bottom, which is both faster (no call overhead) and safe at any exponent
// size, since there is no stack to overflow.
long long modularExponentiationIterative(long long a, long long b, long long n) {
    long long result = 1 % n, base = appendixMod(a, n);
    while (b > 0) {
        if (b & 1) result = appendixMulMod(result, base, n);
        base = appendixMulMod(base, base, n);
        b >>= 1;
    }
    return result;
}

// Exercise 31.6-5: "Assuming that you know phi(n), explain how to compute
// a^-1 mod n using MODULAR-EXPONENTIATION." By Euler, a^phi(n) == 1, so
// a * a^(phi(n)-1) == 1, so a^(phi(n)-1) IS the inverse.
long long inverseViaEuler(long long a, long long n, long long phiOfN) {
    return modularExponentiationIterative(a, phiOfN - 1, n);
}
```

### A5 PSEUDOPRIME

*Pseudocode: Part 8, CLRS `PSEUDOPRIME(n)`.*

```cpp
// PSEUDOPRIME(n)
// 1  if MODULAR-EXPONENTIATION(2, n-1, n) != 1 (mod n)
// 2      return COMPOSITE      // definitely
// 3  else return PRIME         // we hope!
//
// One direction is a theorem, the other is a hope, and the asymmetry is the
// whole point: line 2 is a PROOF (by Fermat), line 3 is a guess. Only 22 odd
// n below 10,000 make it guess wrong.
enum class Primality { Composite, Prime };

Primality pseudoprime(long long n) {
    if (modularExponentiationIterative(2, n - 1, n) != 1)      // line 1
        return Primality::Composite;                           // line 2: definitely
    return Primality::Prime;                                   // line 3: we hope
}

// The 22 values below 10,000 where PSEUDOPRIME errs -- the base-2
// pseudoprimes. CLRS names the first four: 341, 561, 645, 1105. Computing the
// list rather than quoting it is a test of both this and the primality code.
vector<long long> baseTwoPseudoprimesBelow(long long limit,
                                           const function<bool(long long)>& reallyPrime) {
    vector<long long> liars;
    for (long long n = 3; n < limit; n += 2)
        if (!reallyPrime(n) && modularExponentiationIterative(2, n - 1, n) == 1)
            liars.push_back(n);
    return liars;
}

// Carmichael numbers: composite n that satisfy Fermat for EVERY base coprime
// to n. These are why adding more bases does not rescue the Fermat test, and
// why Miller-Rabin needs its second idea.
bool isCarmichael(long long n, const function<bool(long long)>& reallyPrime) {
    if (n < 3 || n % 2 == 0 || reallyPrime(n)) return false;
    for (long long a = 2; a < n; ++a) {
        if (euclidIterative(a, n) != 1) continue;              // only bases in Z_n^*
        if (modularExponentiationIterative(a, n - 1, n) != 1) return false;
    }
    return true;
}
```

### A6 MILLER-RABIN and WITNESS

*Pseudocode: Part 8, CLRS `MILLER-RABIN(n, s)` and `WITNESS(a, n)`.*

```cpp
// WITNESS(a, n)
// 1  let t and u be such that t >= 1, u is odd, and n - 1 = 2^t u
// 2  x_0 = MODULAR-EXPONENTIATION(a, u, n)
// 3  for i = 1 to t
// 4      x_i = x_{i-1}^2 mod n
// 5      if x_i == 1 and x_{i-1} != 1 and x_{i-1} != n - 1
// 6          return TRUE          // found a nontrivial square root of 1
// 7  if x_t != 1
// 8      return TRUE              // composite, as in PSEUDOPRIME
// 9  return FALSE
//
// This version keeps the ENTIRE sequence X = <x_0, ..., x_t>, exactly as the
// pseudocode's subscripted x_i implies, so that the four cases in the text can
// be examined directly. The body version keeps one value and exits early --
// same verdict, less memory, no trace.
//
// Line 5 is the line everyone mistranscribes. Dropping `x_{i-1} != n-1` makes
// the routine report primes as composite: -1 squares to 1 for every n, and
// that is a TRIVIAL square root, not evidence of anything.
bool witnessLiteral(long long a, long long n, vector<long long>* sequenceOut) {
    long long u = n - 1;                                       // line 1
    int t = 0;
    while (u % 2 == 0) { u /= 2; ++t; }                        // n - 1 == 2^t * u

    vector<long long> x;                                       // the sequence X
    x.push_back(modularExponentiationIterative(a, u, n));      // line 2: x_0 = a^u

    for (int i = 1; i <= t; ++i) {                             // line 3
        x.push_back(appendixMulMod(x[i - 1], x[i - 1], n));    // line 4: x_i = x_{i-1}^2
        if (x[i] == 1 && x[i - 1] != 1 && x[i - 1] != n - 1) { // line 5
            if (sequenceOut) *sequenceOut = x;
            return true;                                       // line 6: nontrivial root
        }
    }
    if (sequenceOut) *sequenceOut = x;
    if (x[t] != 1) return true;                                // lines 7-8: Fermat fails
    return false;                                              // line 9
}

// MILLER-RABIN(n, s)      // n > 2 is odd
// 1  for j = 1 to s
// 2      a = RANDOM(2, n - 2)
// 3      if WITNESS(a, n)
// 4          return COMPOSITE   // definitely
// 5  return PRIME               // almost surely
//
// RANDOM(2, n-2) excludes 1 and n-1 deliberately: for a == +-1 the sequence X
// is all 1s or starts at -1, so the test learns nothing and a round is wasted.
Primality millerRabinLiteral(long long n, int s, mt19937_64& randomEngine) {
    uniform_int_distribution<long long> pickBase(2, n - 2);    // line 2's RANDOM(2, n-2)
    for (int j = 1; j <= s; ++j)                               // line 1
        if (witnessLiteral(pickBase(randomEngine), n, nullptr))  // line 3
            return Primality::Composite;                       // line 4: definitely
    return Primality::Prime;                                   // line 5: almost surely
}

// The four shapes of X from the text, as a classification. Naming them is what
// makes a failing implementation debuggable: you can print which case fired
// rather than guessing.
enum class WitnessCase {
    DoesNotEndInOne,       // 1. <..., d> with d != 1 -- Fermat fails, TRUE
    AllOnes,               // 2. <1, 1, ..., 1>       -- FALSE
    LastNonOneIsMinusOne,  // 3. <..., -1, 1, ..., 1> -- FALSE
    NontrivialSquareRoot   // 4. <..., d, 1, ..., 1>, d != +-1 -- TRUE
};

WitnessCase classifyWitness(const vector<long long>& x, long long n) {
    if (x.back() != 1) return WitnessCase::DoesNotEndInOne;

    bool allOnes = true;
    for (long long value : x) if (value != 1) { allOnes = false; break; }
    if (allOnes) return WitnessCase::AllOnes;

    // Walk back to the last entry that is not 1; its value decides cases 3 vs 4.
    size_t i = x.size() - 1;
    while (i > 0 && x[i] == 1) --i;
    return x[i] == n - 1 ? WitnessCase::LastNonOneIsMinusOne
                         : WitnessCase::NontrivialSquareRoot;
}

// Exercise 31.8-3: a nontrivial square root of 1 does not merely PROVE that n
// is composite -- it factors it. Both gcds are nontrivial divisors.
pair<long long, long long> divisorsFromWitness(const vector<long long>& x, long long n) {
    size_t i = x.size() - 1;
    while (i > 0 && x[i] == 1) --i;
    return {euclidIterative(x[i] - 1, n), euclidIterative(x[i] + 1, n)};
}
```

### A7 RSA

*Pseudocode: Part 9, CLRS's six-step RSA key-generation procedure and equations (31.37)–(31.38).*

```cpp
// The RSA key-creation procedure, step by step as CLRS numbers it:
//
// 1. Select at random two large primes p and q with p != q.
// 2. Compute n = pq.
// 3. Select a small odd e relatively prime to phi(n) = (p-1)(q-1).
// 4. Compute d as the multiplicative inverse of e, modulo phi(n).
// 5. Publish P = (e, n) as the public key.
// 6. Keep secret S = (d, n) as the secret key.
//
// Steps 1, 3 and 4 are Miller-Rabin, Euclid and extended Euclid respectively:
// this whole module exists to make these six lines possible.
struct AppendixRsaKeys {
    long long p = 0, q = 0;          // SECRET
    long long n = 0;                 // public
    long long phi = 0;               // SECRET -- as good as the factorisation
    long long e = 0;                 // public
    long long d = 0;                 // SECRET
};

AppendixRsaKeys createRsaKeys(long long p, long long q) {
    AppendixRsaKeys keys;
    keys.p = p;                                     // step 1 (supplied by the caller
    keys.q = q;                                     //         so the example is exact)
    keys.n = p * q;                                 // step 2
    keys.phi = (p - 1) * (q - 1);                   // phi(pq) = (p-1)(q-1)

    keys.e = 3;                                     // step 3: small, odd, coprime
    while (euclidIterative(keys.e, keys.phi) != 1) keys.e += 2;

    keys.d = modularInverseLiteral(keys.e, keys.phi);   // step 4
    return keys;                                        // steps 5-6 are a policy,
}                                                       // not a computation

// P(M) = M^e mod n            (31.37)   -- encrypt, or VERIFY a signature
long long rsaPublicTransform(long long m, const AppendixRsaKeys& keys) {
    return modularExponentiationIterative(m, keys.e, keys.n);
}

// S(C) = C^d mod n            (31.38)   -- decrypt, or CREATE a signature
long long rsaSecretTransform(long long c, const AppendixRsaKeys& keys) {
    return modularExponentiationIterative(c, keys.d, keys.n);
}

// Theorem 31.36, as a runnable predicate. The proof is Fermat separately
// modulo p and modulo q, then Corollary 31.29 to the CRT to glue the two
// congruences into one modulo n = pq. Checking BOTH compositions is checking
// equations (31.35) and (31.36).
bool rsaRoundTrips(long long m, const AppendixRsaKeys& keys) {
    const long long viaPublicFirst = rsaSecretTransform(rsaPublicTransform(m, keys), keys);
    const long long viaSecretFirst = rsaPublicTransform(rsaSecretTransform(m, keys), keys);
    return viaPublicFirst == appendixMod(m, keys.n)
        && viaSecretFirst == appendixMod(m, keys.n);
}

// The intermediate step of the correctness proof, isolated so it can be tested
// on its own: M^(ed) == M (mod p) and (mod q), each by Fermat, BEFORE the CRT
// glues them. If the round trip ever fails, this says which half broke.
bool rsaCongruentModEachPrime(long long m, const AppendixRsaKeys& keys) {
    const __int128 exponent = (__int128)keys.e * keys.d;
    const long long modP = modularExponentiationIterative(
        appendixMod(m, keys.p), (long long)(exponent % (keys.p - 1)), keys.p);
    const long long modQ = modularExponentiationIterative(
        appendixMod(m, keys.q), (long long)(exponent % (keys.q - 1)), keys.q);
    return modP == appendixMod(m, keys.p) && modQ == appendixMod(m, keys.q);
}
```

### A8 The Chinese remainder theorem

*Pseudocode: Part 6, CLRS equations (31.31) and (31.32) — the theorem is constructive, so its proof is the algorithm.*

```cpp
// Theorem 31.27's construction, written exactly as the proof states it:
//     m_i = n / n_i
//     c_i = m_i (m_i^-1 mod n_i)                   (31.31)
//     a   = (a_1 c_1 + ... + a_k c_k) mod n        (31.32)
//
// The c_i are what make this click: c_i corresponds to the k-tuple that is 1 in
// position i and 0 everywhere else, so equation (31.32) is a linear combination
// in a basis. Returning them lets a test check that directly.
long long chineseRemainderLiteral(const vector<long long>& a,
                                  const vector<long long>& moduli,
                                  vector<long long>* basisOut) {
    long long n = 1;
    for (long long modulus : moduli) n *= modulus;

    if (basisOut) basisOut->clear();
    long long result = 0;
    for (size_t i = 0; i < moduli.size(); ++i) {
        const long long m_i = n / moduli[i];                       // m_i = n / n_i
        const long long inverse = modularInverseLiteral(m_i, moduli[i]);
        if (inverse < 0) return -1;                                // moduli not coprime
        const long long c_i = appendixMulMod(m_i, inverse, n);     // equation (31.31)
        if (basisOut) basisOut->push_back(c_i);
        result = appendixMod(result + appendixMulMod(appendixMod(a[i], n), c_i, n), n);
    }
    return result;                                                 // equation (31.32)
}

// The "basis" property, as a predicate: c_i == 1 (mod n_i) and c_i == 0
// (mod n_j) for every j != i. This is the sentence "the c_i thus form a
// 'basis' for the representation", made checkable.
bool basisVectorsAreCorrect(const vector<long long>& basis,
                            const vector<long long>& moduli) {
    for (size_t i = 0; i < moduli.size(); ++i)
        for (size_t j = 0; j < moduli.size(); ++j) {
            const long long expected = (i == j) ? 1 : 0;
            if (appendixMod(basis[i], moduli[j]) != expected) return false;
        }
    return true;
}

// Corollary 31.29, used twice in the RSA proof: x == a (mod n_i) for every i
// if and only if x == a (mod n). Worth an executable check, because the RSA
// correctness argument rests on it entirely.
bool corollary3129Holds(long long x, long long a, const vector<long long>& moduli) {
    long long n = 1;
    for (long long modulus : moduli) n *= modulus;

    bool agreesEverywhere = true;
    for (long long modulus : moduli)
        if (appendixMod(x, modulus) != appendixMod(a, modulus)) agreesEverywhere = false;

    return agreesEverywhere == (appendixMod(x, n) == appendixMod(a, n));
}
```

### A9 The binary GCD

*Pseudocode: Part 3, CLRS Problem 31-1 (parts a–d).*

```cpp
// Problem 31-1. The three identities the algorithm is built from:
//   a. both even     : gcd(a, b) = 2 * gcd(a/2, b/2)
//   b. a odd, b even : gcd(a, b) = gcd(a, b/2)
//   c. both odd      : gcd(a, b) = gcd((a-b)/2, b)
//
// "Most computers can perform the operations of subtraction, testing the parity
// of a binary integer, and halving more quickly than computing remainders."
// That is the whole motivation: same O(lg a) bound, no division at all.
//
// Written with an explicit loop per case rather than __builtin_ctzll, so the
// three identities are visible one by one; the body version uses the intrinsic.
long long binaryGcdLiteral(long long a, long long b) {
    a = llabs(a); b = llabs(b);
    if (a == 0) return b;
    if (b == 0) return a;

    int commonPowerOfTwo = 0;
    while ((a % 2 == 0) && (b % 2 == 0)) {         // case (a), applied repeatedly
        a /= 2; b /= 2; ++commonPowerOfTwo;
    }
    while (a % 2 == 0) a /= 2;                     // case (b), with the roles swapped
    do {
        while (b % 2 == 0) b /= 2;                 // case (b): a is odd, so halve b
        if (a > b) swap(a, b);                     // keep a <= b so b - a >= 0
        b -= a;                                    // case (c): both odd, so b-a is even
    } while (b != 0);

    return a << commonPowerOfTwo;                  // restore the common factor of 2
}

// Problem 31-2(b): Euclid's bit-operation cost is bounded by the drop in
// lambda(a,b) = (1 + lg a)(1 + lg b) across each reduction step. Computing the
// potential makes the telescoping argument observable rather than abstract.
double euclidPotential(long long a, long long b) {
    const double lgA = a > 0 ? log2((double)a) : 0.0;
    const double lgB = b > 0 ? log2((double)b) : 0.0;
    return (1.0 + lgA) * (1.0 + lgB);
}
```

**Complexity. Every appendix routine matches its body counterpart except where the literal form is deliberately slower or heavier: `euclidLiteral` recurses instead of looping; `witnessLiteral` stores the whole sequence `X` rather than one value; `modularExponentiationLiteral` recurses `β` to `2β−1` times; `modularLinearEquationSolver` materialises all `d` solutions; `binaryGcdLiteral` halves in a loop instead of using `__builtin_ctzll`. None changes the asymptotics.**

*Verified:* every appendix routine was cross-checked against its body counterpart and against brute force.

`euclidLiteral`, `euclidIterative` and `binaryGcdLiteral` agreed with `std::gcd` on 200 000 random pairs up to `10¹⁸`. **`euclidCallCount` was off by one the first time, and the Fibonacci test is what caught it** — I wrote `return calls - 1`, reasoning that the final `b == 0` call is the base case, which is wrong: `EUCLID(a,b)` with `b ≠ 0` makes one recursive call *plus* whatever that call makes, so the number of recursive calls equals the number of loop iterations exactly. CLRS's own example settles it — *"This computation calls `EUCLID` recursively three times"* for `gcd(30, 21)`, and the loop runs three times. With the fix, **Lamé's tightness claim holds exactly**: `euclidCallCount(F_{k+1}, F_k)` returns precisely `k − 1` for every `k` from 2 to 88, **0 mismatches**. And **Lemma 31.10 was checked directly**: over 200 000 random pairs, `k` recursive calls always implied `a ≥ F_{k+2}` **and** `b ≥ F_{k+1}` — **0 violations**.

`extendedEuclidLiteral` satisfied `a·x + b·y == d` (verified in `__int128`) on all 200 000 pairs. `traceExtendedEuclid(99, 78)`, reversed, prints Figure 31.1 **row for row**: `(99,78,1,3,−11,14)`, `(78,21,3,3,3,−11)`, `(21,15,1,3,−2,3)`, `(15,6,2,3,1,−2)`, `(6,3,2,3,0,1)`, `(3,0,–,3,1,0)`. Exercise 31.2-2 returns `(29, −6, 11)`.

`modularLinearEquationSolver` returned exactly `solveByScanning`'s set on 50 000 random `(a,b,n)` with `n ≤ 3 000`, and `14x ≡ 30 (mod 100)` gives `{45, 95}`.

`modularExponentiationLiteral` and `modularExponentiationIterative` agreed on 200 000 triples. `traceModularExponentiation(7, 560, 561)` reproduces **Figure 31.4 exactly** — the `b` row `560, 280, 140, 70, 35, 34, 17, 16, 8, 4, 2, 1, 0` and the `d` row `67, 166, 298, 241, 355, 160, 103, 526, 157, 49, 7, 1`. `inverseViaEuler` (Exercise 31.6-5) matched `modularInverseLiteral` on **1 216 587** `(a, n)` pairs — every `n ≤ 2 000` and every `a ∈ Zₙ*` — with **0** mismatches.

`baseTwoPseudoprimesBelow(10000, …)` returned **exactly 22** values, CLRS's count, beginning `341, 561, 645, 1105`. `isCarmichael` identified `561, 1105, 1729, 2465, 2821, 6601, 8911` below 10 000 and nothing else — the first three matching the text.

`witnessLiteral(7, 561)` returns `true` with `X = ⟨241, 298, 166, 67, 1⟩` — the sequence in the text — `classifyWitness` reports `NontrivialSquareRoot`, and `divisorsFromWitness` returns `(33, 17)`. Across 100 000 random `(a, n)` pairs with `n ≤ 20 000` odd, `classifyWitness`'s verdict agreed with `witnessLiteral`'s return value on **every** case, and **all four cases occurred** — 76 654 `DoesNotEndInOne`, 7 602 `AllOnes`, 15 269 `LastNonOneIsMinusOne`, 471 `NontrivialSquareRoot`. That last count is the point of the whole test: the nontrivial-square-root branch is rare, so an implementation that gets line 5 wrong still passes casual testing. `millerRabinLiteral` with `s = 20` made **0 errors in 200 000 trials** against a sieve. **Theorem 31.39 was measured, not assumed:** for every odd composite `n ≤ 5 000`, the fraction of bases in `[2, n−2]` that are witnesses was computed exhaustively; the minimum over all of them was **0.763**, at `n = 1891 = 31·61` — comfortably above the guaranteed `1/2`.

`chineseRemainderLiteral` returns **23** for Sun-Tsŭ and **42** for CLRS's `(2 mod 5, 3 mod 13)`, with basis `c₁ = 26`, `c₂ = 40` — exactly the published values. Over the 9 700 pairwise-coprime systems drawn, it matched brute force on every one, and `basisVectorsAreCorrect` — the executable form of *"the `cᵢ` thus form a 'basis'"* — held on **all 9 700**. `corollary3129Holds` passed on 100 000 random `(x, a)` pairs modulo `{3,5,7}`.

`createRsaKeys(11, 29)` — Exercise 31.7-1 — gives `n = 319`, `φ = 280`, `e = 3`, **`d = 187`**, and `rsaPublicTransform(100)` is **254**, decrypting back to `100`. `rsaRoundTrips` held for **all 319** messages under that key, and for 20 messages under each of 2 000 random key pairs with 4-to-5-digit primes — **39 980 checks, both directions, no failures**. `rsaCongruentModEachPrime` held on every one, confirming that the Fermat half of Theorem 31.36 is where the work happens and the CRT half is bookkeeping.

`binaryGcdLiteral` matched `std::gcd` on 200 000 pairs. `euclidPotential` never increased across a reduction step in 100 000 trials — **0** violations — which is the monotonicity Problem 31-2(b)'s telescoping argument needs.

---

*Next: [M22 — Linear Programming](M22-linear-programming.md) (CLRS 29 + Skiena 13.6) — the general-purpose optimiser behind half the algorithms in [M20](M20-heuristics.md).*
