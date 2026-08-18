# Maths for DSA — Complete Notes (C++)
*Based on Striver's A2Z DSA Course — Maths Playlist, 8 Videos*

---

## 📌 Setup (use this everywhere)

```cpp
#include <iostream>
#include <vector>
#include <cmath>
#include <climits>
using namespace std;
```

---

## 📌 L1a — Count Digits in a Number

```cpp
// Repeatedly strip the last digit until number becomes 0
int countDigits(int n) {
    if (n == 0) return 1;
    n = abs(n);
    int count = 0;
    while (n > 0) {
        n /= 10;
        count++;
    }
    return count;
}

// O(1) ALTERNATIVE using logarithms
int countDigitsLog(int n) {
    if (n == 0) return 1;
    return (int)log10(abs(n)) + 1;
}
// TC: O(digits) for loop version, O(1) for log version
// SC: O(1)
// KEY: number of digits in n (base 10) = floor(log10(n)) + 1
```

---

## 📌 L1b — Reverse a Number

```cpp
// Build reversed number digit by digit from the last digit forward
long reverseNumber(int n) {
    long reversed = 0;
    while (n != 0) {
        int lastDigit = n % 10;
        reversed = reversed * 10 + lastDigit;
        n /= 10;
    }
    return reversed;
}
// TC: O(digits), SC: O(1)
// KEY: use `long`/`long long` for the accumulator — reversing near
// INT_MAX can overflow a plain int
// NOTE: n % 10 can be negative for negative n in C++ — handle sign
// separately if negative numbers are allowed as input
```

---

## 📌 L1c — Check if a Number is a Palindrome

```cpp
// A number is a palindrome if it reads the same forwards & backwards
bool isPalindrome(int n) {
    if (n < 0) return false;     // negatives never palindromic (the '-' sign)
    int original = n;
    long reversed = 0;
    while (n != 0) {
        reversed = reversed * 10 + n % 10;
        n /= 10;
    }
    return reversed == original;
}
// TC: O(digits), SC: O(1)
// KEY: exactly the reverse-a-number logic, then compare with original
```

---

## 📌 L1d — GCD / HCF: Two Approaches

```cpp
// ── APPROACH 1: BRUTE FORCE (subtraction/modulo loop) ──
// Keep subtracting the smaller from the larger until they're equal,
// OR equivalently reduce the larger by modulo repeatedly.
int gcdBrute(int a, int b) {
    while (a != b) {
        if (a > b) a -= b;
        else b -= a;
    }
    return a;
}
// TC: O(max(a,b)) worst case (e.g. gcd(1, 1000000) subtracts a lot)

// ── APPROACH 2: EUCLIDEAN ALGORITHM (optimal) ──
// gcd(a, b) = gcd(b, a % b), base case gcd(a, 0) = a
int gcdEuclidean(int a, int b) {
    while (b != 0) {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

// Recursive form (same logic, cleaner to state)
int gcdRecursive(int a, int b) {
    if (b == 0) return a;
    return gcdRecursive(b, a % b);
}
// TC: O(log(min(a, b))) — each step roughly halves the smaller number
// SC: O(1) iterative, O(log(min(a,b))) recursive (call stack)
// KEY: modulo shrinks the problem MUCH faster than repeated
// subtraction — this is why Euclidean beats brute force

// LCM using GCD relationship
long long lcm(int a, int b) {
    return (long long)a / gcdEuclidean(a, b) * b;
    // divide first to avoid overflow before multiplying
}
// IDENTITY: gcd(a,b) * lcm(a,b) = a * b
```

---

## 📌 L1e — Check Armstrong Number

```cpp
// A number is Armstrong if sum of (each digit ^ number-of-digits) == number
// e.g. 153 = 1^3 + 5^3 + 3^3 -> 1 + 125 + 27 = 153 ✓
bool isArmstrong(int n) {
    int original = n;
    int numDigits = countDigits(n);   // from L1a
    long long sum = 0;

    while (n != 0) {
        int digit = n % 10;
        sum += (long long)pow(digit, numDigits);
        n /= 10;
    }
    return sum == original;
}
// TC: O(digits * log(numDigits)) using pow(), or O(digits^2) with a
// manual power loop, SC: O(1)
// KEY: must know digit COUNT before summing, since the exponent
// depends on it — two passes conceptually, though can be combined
// if digit count is computed upfront
```

---

## 📌 L1f — Print All Divisors (Two Approaches)

```cpp
// ── APPROACH 1: BRUTE FORCE O(N) ──
vector<int> printDivisorsBrute(int n) {
    vector<int> divisors;
    for (int i = 1; i <= n; i++) {
        if (n % i == 0) divisors.push_back(i);
    }
    return divisors;
}

// ── APPROACH 2: OPTIMAL O(sqrt(N)) ──
// Divisors come in PAIRS: if i divides n, then n/i also divides n.
// Only need to check up to sqrt(n).
vector<int> printDivisorsOptimal(int n) {
    vector<int> divisors;
    for (int i = 1; (long long)i * i <= n; i++) {
        if (n % i == 0) {
            divisors.push_back(i);
            if (i != n / i) divisors.push_back(n / i);  // avoid dup for perfect squares
        }
    }
    return divisors;   // NOTE: not sorted — sort if order matters
}
// TC: O(sqrt(N)), SC: O(number of divisors)
// KEY: the sqrt(N) bound is the single most reused trick in this
// entire playlist — it reappears in prime-checking and prime
// factorization too
```

---

## 📌 L2 — Print All Divisors of a Number (Dedicated Video)

```
This video reinforces L1f's O(sqrt(N)) divisor-pair technique as
its own standalone problem, contrasting it against the O(N) brute
force explicitly.

BRUTE FORCE:  for i in [1, n], check n % i == 0        -> O(N)
OPTIMAL:      for i in [1, sqrt(n)], check n % i == 0,
              push both i and n/i                       -> O(sqrt(N))

EDGE CASE: perfect squares (e.g. n = 36) — when i == n/i (i.e. i=6),
push only ONCE, not twice.
```
*(see L1f code above — same technique)*

---

## 📌 L3 — Check if a Number is Prime or Not

```cpp
// A number is prime if it has EXACTLY two divisors: 1 and itself.
// Reuses the sqrt(N) divisor-pair insight from L1f/L2.

// ── BRUTE FORCE O(N) ──
bool isPrimeBrute(int n) {
    if (n <= 1) return false;
    int count = 0;
    for (int i = 1; i <= n; i++) {
        if (n % i == 0) count++;
    }
    return count == 2;
}

// ── OPTIMAL O(sqrt(N)) ──
bool isPrimeOptimal(int n) {
    if (n <= 1) return false;
    for (int i = 2; (long long)i * i <= n; i++) {
        if (n % i == 0) return false;   // found a divisor other than 1,n
    }
    return true;
}
// TC: O(sqrt(N)), SC: O(1)
// KEY: only need to check divisors up to sqrt(n) — if n has a
// divisor greater than sqrt(n), it must pair with one smaller than
// sqrt(n), which would already have been caught
```

---

## 📌 L4 — Print All Prime Factors of a Number

```cpp
// ── APPROACH 1: BRUTE FORCE O(N) or O(N log N) ──
vector<int> primeFactorsBrute(int n) {
    vector<int> factors;
    for (int i = 2; i <= n; i++) {
        while (n % i == 0) {
            factors.push_back(i);
            n /= i;
        }
    }
    return factors;
}

// ── APPROACH 2: OPTIMAL O(sqrt(N)) ──
// Trial-divide up to sqrt(n); whatever's left over after the loop
// (if > 1) is itself a prime factor (there can be at most ONE
// prime factor left that's greater than sqrt(original n)).
vector<int> primeFactorsOptimal(int n) {
    vector<int> factors;
    for (int i = 2; (long long)i * i <= n; i++) {
        while (n % i == 0) {
            factors.push_back(i);
            n /= i;
        }
    }
    if (n > 1) factors.push_back(n);   // leftover prime > sqrt(original n)
    return factors;
}
// TC: O(sqrt(N)) amortized — dividing n down as factors are found
// shrinks the sqrt(n) bound as you go, SC: O(number of prime factors)
// KEY: a number can have AT MOST ONE prime factor greater than
// sqrt(itself) — that's why the "leftover n" check at the end works
```

---

## 📌 L5 — Power / Exponentiation (Fast Power)

```cpp
// Compute a^b efficiently using BINARY EXPONENTIATION
// (also called "fast power" or "exponentiation by squaring")

// ── BRUTE FORCE O(B) ──
long long powerBrute(long long a, int b) {
    long long result = 1;
    for (int i = 0; i < b; i++) result *= a;
    return result;
}

// ── OPTIMAL O(log B) — ITERATIVE ──
long long powerFast(long long a, int b) {
    long long result = 1;
    while (b > 0) {
        if (b & 1) {          // if current bit of b is 1
            result *= a;
        }
        a *= a;                // square the base
        b >>= 1;               // move to next bit
    }
    return result;
}

// ── OPTIMAL O(log B) — RECURSIVE ──
long long powerRecursive(long long a, int b) {
    if (b == 0) return 1;
    long long half = powerRecursive(a, b / 2);
    long long result = half * half;
    if (b % 2 == 1) result *= a;   // odd exponent -> one extra factor of a
    return result;
}
// TC: O(log B), SC: O(1) iterative, O(log B) recursive (call stack)
// KEY: a^b = (a^(b/2))^2 when b is even, times one extra `a` when
// b is odd — this halves the exponent each step instead of
// decrementing by 1, which is what gives the log speedup
// COMMON EXTENSION: take result % MOD after every multiplication
// for "modular exponentiation" (used heavily in competitive programming)
```

---

## 📌 L6 — Sieve of Eratosthenes

```cpp
// Precompute ALL primes up to N in one shot — much faster than
// calling isPrime() individually for every number up to N.
vector<bool> sieveOfEratosthenes(int n) {
    vector<bool> isPrime(n + 1, true);
    isPrime[0] = isPrime[1] = false;

    for (int i = 2; (long long)i * i <= n; i++) {
        if (isPrime[i]) {
            // start marking multiples from i*i (smaller multiples
            // of i were already marked by smaller primes)
            for (int j = i * i; j <= n; j += i) {
                isPrime[j] = false;
            }
        }
    }
    return isPrime;
}
// TC: O(N log log N)  — the classic sieve complexity
// SC: O(N)
// KEY: outer loop only needs to run to sqrt(N) (any composite <= N
// has a prime factor <= sqrt(N)); inner loop starts at i*i, not
// 2*i, because all smaller multiples of i are already marked by
// smaller primes that ran earlier
```

---

## 📌 L7 — Count Primes in a Range [L, R]

```cpp
// Naive: call isPrime() for every number in [L, R] -> O((R-L) * sqrt(R))
// Optimal: precompute a sieve up to R ONCE, then answer range
// queries (or multiple queries) in O(1) each using a prefix count.

vector<int> buildPrimePrefixCount(int maxR) {
    vector<bool> isPrime = sieveOfEratosthenes(maxR);   // from L6
    vector<int> prefixCount(maxR + 1, 0);

    for (int i = 1; i <= maxR; i++) {
        prefixCount[i] = prefixCount[i - 1] + (isPrime[i] ? 1 : 0);
    }
    return prefixCount;
}

int countPrimesInRange(vector<int>& prefixCount, int L, int R) {
    return prefixCount[R] - prefixCount[L - 1];
}
// PRECOMPUTE: O(maxR log log maxR), SC: O(maxR)
// PER QUERY: O(1)
// KEY: this is "sieve + prefix sum" — a pattern that generalizes to
// ANY query-based problem over precomputable per-number properties
// (not just primality)
```

---

## 📌 L8 — Smallest Prime Factor (SPF) + Fast Prime Factorization

```cpp
// Precompute the smallest prime factor of every number up to N.
// Then ANY number's full prime factorization can be found in
// O(log N) by repeatedly dividing by its SPF — much faster than
// L4's O(sqrt(N))-per-number when there are MANY factorization
// queries (query-based problems).

vector<int> computeSPF(int n) {
    vector<int> spf(n + 1);
    for (int i = 1; i <= n; i++) spf[i] = i;   // default: itself

    for (int i = 2; (long long)i * i <= n; i++) {
        if (spf[i] == i) {   // i is prime (nothing smaller marked it)
            for (int j = i * i; j <= n; j += i) {
                if (spf[j] == j) spf[j] = i;   // only set if not already set
                // (ensures we store the SMALLEST prime factor, since
                // we process primes in increasing order)
            }
        }
    }
    return spf;
}

// Use SPF to factorize any number in O(log N)
vector<int> primeFactorizeWithSPF(int n, vector<int>& spf) {
    vector<int> factors;
    while (n != 1) {
        factors.push_back(spf[n]);
        n /= spf[n];
    }
    return factors;
}
// PRECOMPUTE: O(N log log N), SC: O(N)
// PER QUERY: O(log N) (number of prime factors, counted with multiplicity,
// is at most log2(N))
// KEY: this is the SIEVE OF ERATOSTHENES modified to store "which
// prime first marked me" instead of just true/false — classic
// technique for query-heavy factorization problems
```

---

## 📌 All Patterns — Quick Revision

```
MATHS FOR DSA — CHEAT SHEET:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CONCEPT                  → TECHNIQUE:
  Count digits              → divide by 10 in a loop, or log10(n)+1
  Reverse a number           → extract last digit, build reversed number
  Palindrome number          → reverse it, compare to original
  GCD / HCF                  → Euclidean: gcd(a,b) = gcd(b, a%b)
  LCM                        → (a / gcd(a,b)) * b
  Armstrong number           → sum of digit^numDigits == number
  All divisors of N          → loop to sqrt(N), push i and N/i
  Check prime                → loop to sqrt(N), no divisor found
  Prime factors of N         → trial-divide to sqrt(N), leftover > 1 is prime
  a^b (large exponent)       → binary exponentiation, halve b each step
  All primes up to N         → Sieve of Eratosthenes
  Prime count in range/query → sieve + prefix sum
  Repeated factorization     → sieve variant: Smallest Prime Factor (SPF)

THE ONE INSIGHT THAT REPEATS EVERYWHERE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
sqrt(N) BOUND: any composite number N has at least one factor
<= sqrt(N). This single fact is why divisor-finding, primality
checking, and prime factorization all drop from O(N) to O(sqrt(N)).

WHEN TO PRECOMPUTE (SIEVE-STYLE) vs COMPUTE PER-QUERY:
  Single number, asked once     → direct O(sqrt(N)) method (L3/L4)
  Many numbers / many queries   → precompute once with a sieve
                                   (L6/L7/L8), amortize cost across queries

COMPLEXITY QUICK REF:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Count/reverse/palindrome   O(digits) ~ O(log N) time, O(1) space
GCD (Euclidean)            O(log(min(a,b))) time, O(1) space
Divisors (optimal)         O(sqrt(N)) time, O(divisor count) space
Primality check (optimal)  O(sqrt(N)) time, O(1) space
Prime factorization        O(sqrt(N)) time, O(log N) space (factor count)
Binary exponentiation      O(log B) time, O(1) space
Sieve of Eratosthenes       O(N log log N) time, O(N) space
SPF precompute + query     O(N log log N) precompute, O(log N) per query
```

---

## 📌 Problem Map

```
TOPIC                              | SOURCE          | DIFFICULTY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Count Digits                       | GFG/Basic       | Easy
Reverse Integer                    | LC 7            | Medium
Palindrome Number                  | LC 9            | Easy
GCD / HCF of Two Numbers           | GFG/Basic       | Easy
Armstrong Number                   | GFG/Basic       | Easy
Print All Divisors of a Number     | GFG/Basic       | Easy
Primality Test                     | GFG/Basic       | Easy
Prime Factors of a Number          | GFG/Basic       | Medium
Pow(x, n)                          | LC 50           | Medium
Count Primes                       | LC 204          | Medium
Sieve of Eratosthenes              | GFG/CP staple   | Medium
Smallest Prime Factor (SPF)        | CP staple       | Medium
Super Ugly Number (uses primes)    | LC 313          | Medium
```
