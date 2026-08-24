# Striver Bit Manipulation Series — Complete Notes (C++)

*Based on TakeUForward Bit Manipulation Playlist — 9 Videos (L1 to L9)*

---

## 📌 C++ Bit Manipulation Setup (reference this everywhere)

```cpp
#include <bits/stdc++.h>
using namespace std;

// ── HOW INTEGERS ARE STORED ─────────────────────────────
// int = 32 bits. The 31st (leftmost) bit is the SIGN bit: 0 = positive, 1 = negative.
// Positive numbers are stored as plain binary.
// Negative numbers are stored as the 2's COMPLEMENT of their positive form:
//     Step 1: write the positive binary
//     Step 2: 1's complement — flip every bit
//     Step 3: 2's complement — add 1 to the result
// INT_MAX =  2^31 - 1   (all bits 1 except the sign bit)
// INT_MIN = -2^31       (sign bit 1, every other bit 0)

// ── DECIMAL <-> BINARY ───────────────────────────────────
string toBinary(int x) {                 // repeatedly divide by 2, collect remainders
    string result = "";
    while (x != 1) {
        result += (x % 2 == 1) ? '1' : '0';
        x /= 2;
    }
    result += '1';
    reverse(result.begin(), result.end());
    return result;
}
int toDecimal(string& s) {                // traverse right to left, sum bit * 2^position
    int number = 0, p2 = 1;
    for (int i = s.size() - 1; i >= 0; i--) {
        if (s[i] == '1') number += p2;
        p2 *= 2;
    }
    return number;
}

// ── THE CORE ONE-LINERS (reused in almost every problem below) ──
bool isSet(int n, int i)      { return (n & (1 << i)) != 0; }   // is the i-th bit set?
int  setBit(int n, int i)     { return n | (1 << i); }           // set i-th bit to 1
int  clearBit(int n, int i)   { return n & ~(1 << i); }          // clear i-th bit to 0
int  toggleBit(int n, int i)  { return n ^ (1 << i); }           // flip i-th bit
int  removeLastSetBit(int n)  { return n & (n - 1); }            // clear the rightmost 1
bool isPowerOfTwo(int n)      { return n > 0 && (n & (n - 1)) == 0; }
int  countSetBitsSlow(int n)  {                                   // O(number of bits)
    int cnt = 0;
    while (n) { cnt += (n & 1); n >>= 1; }
    return cnt;
}
int  countSetBitsFast(int n)  {                                   // O(number of SET bits) — Brian Kernighan's
    int cnt = 0;
    while (n) { n = n & (n - 1); cnt++; }
    return cnt;
}
// __builtin_popcount(n) — GCC built-in, does the same as countSetBitsFast in one call

// ── SHIFT OPERATOR IDENTITIES ────────────────────────────
// n << k  ==  n * 2^k     (watch for overflow — the top bits fall off the cliff)
// n >> k  ==  n / 2^k     (integer division, floor)
```

```
OPERATOR QUICK REFERENCE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AND (&)   → 1 only if BOTH bits are 1        "all true means true"
OR  (|)   → 1 if AT LEAST ONE bit is 1       "one true means true"
XOR (^)   → 1 if the bits DIFFER             "odd number of 1s → 1, even → 0"
NOT (~)   → flips every bit, then re-interprets sign via 2's complement
<<        → shift left  = multiply by 2^k    (drops high bits — can overflow)
>>        → shift right = divide by 2^k      (drops low bits)

XOR IDENTITIES (the single most reused fact in this whole playlist):
  x ^ x = 0        (a number XORed with itself cancels to zero)
  x ^ 0 = x         (XOR with zero is a no-op)
  XOR is commutative and associative — order/grouping doesn't matter,
  which is why "XOR everything, pairs cancel, survivor remains" works.
```

---

## 📌 L1 — Introduction to Bit Manipulation (L1)

```
COVERED: decimal↔binary conversion (see toBinary/toDecimal above),
how the computer actually stores an int (32 bits, sign bit + magnitude
via 2's complement for negatives — see setup section above), and the
core operators (AND, OR, XOR, NOT, left shift, right shift).

1'S COMPLEMENT: flip every bit.                     13 → 1101 → 0010
2'S COMPLEMENT: 1's complement, then add 1.          0010 + 1 → 0011
  (this is exactly how negative numbers get stored — see -13 example
  in the setup section's comment block)

NOT OPERATOR MECHANICS — a 2-step process, not a single flip:
  Step 1: flip every bit (including the sign bit)
  Step 2: if the result's sign bit says negative, the VALUE shown is
          obtained by taking THAT result's 2's complement in turn
  (this is why ~5 == -6, not some simple bit-pattern reading — the
  sign flip changes how the remaining bits get interpreted)
```
**GOTCHA:** `INT_MIN = -2^31` has no positive counterpart in a 32-bit int (`2^31` itself doesn't fit) — this is precisely why negating `INT_MIN` overflows, a recurring edge case (see L9).

---

## 📌 L2 — Must-Know Bit Tricks (L2)

### Swap two numbers without a third variable
```cpp
void swapXOR(int &a, int &b) {
    a = a ^ b;
    b = a ^ b;   // = (a^b) ^ b = a
    a = a ^ b;   // = (a^b) ^ a = b   (using the just-updated b)
}
// TC: O(1), SC: O(1)
```
**KEY:** works because `a ^ b ^ b = a` and `a ^ b ^ a = b` — XOR's self-cancelling property (`x^x=0`, `x^0=x`) does the swap in three lines with zero extra memory.

### Check / Set / Clear / Toggle the i-th bit
```cpp
// Check: shift a lone 1 to position i, AND with n — nonzero means set
bool checkBit(int n, int i) { return (n & (1 << i)) != 0; }
// (equivalently: right-shift n by i places first, then AND with 1)

int setBit(int n, int i)    { return n | (1 << i); }    // OR forces that position to 1
int clearBit(int n, int i)  { return n & ~(1 << i); }   // AND with everything-except-that-bit
int toggleBit(int n, int i) { return n ^ (1 << i); }    // XOR flips exactly that position
```

### Remove the rightmost (last) set bit
```cpp
int removeLastSetBit(int n) { return n & (n - 1); }
```
**KEY — why this works:** `n - 1` turns the rightmost set bit to 0 and flips every bit to its right from 0 to 1, while every bit to the LEFT of it stays identical to `n`. ANDing the two: the rightmost set bit meets a 0 (from `n-1`) and dies; the now-1 trailing bits meet 0s from `n` and stay 0; the identical leading bits meet themselves and survive unchanged.

### Check if a number is a power of 2
```cpp
bool isPowerOfTwo(int n) { return n > 0 && (n & (n - 1)) == 0; }
```
**KEY:** a power of 2 has EXACTLY one set bit. Removing "the last set bit" from a number with only one set bit leaves nothing — hence `n & (n-1) == 0`.

### Count set bits — two approaches
```cpp
// Approach 1: check every bit position (odd check + right shift, one bit at a time)
int countSetBitsSlow(int n) {
    int cnt = 0;
    while (n) {
        cnt += (n & 1);     // faster than n % 2 == 1 — same odd-check
        n >>= 1;            // faster than n /= 2
    }
    return cnt;
}
// TC: O(log N) — proportional to the number of BITS in n

// Approach 2 — Brian Kernighan's: only loop once per SET bit, not per bit position
int countSetBitsFast(int n) {
    int cnt = 0;
    while (n) {
        n = n & (n - 1);    // strips the rightmost set bit each iteration
        cnt++;
    }
    return cnt;
}
// TC: O(number of set bits) — strictly faster than Approach 1 whenever
//     n is sparse (few 1s); same worst case if every bit happens to be set
// STL SHORTCUT: __builtin_popcount(n) does exactly this internally
```


---

## 📌 L3 — Minimum Bit Flips to Convert a Number (L3)

```
Given start and goal, find the minimum number of bit flips to turn
start into goal.
KEY IDEA: XOR marks exactly the positions that DIFFER between two
numbers with a 1 (x^y has a 1 wherever x and y disagree, a 0 wherever
they agree — same identity underlying Single Number, L5/L7). So the
positions that need flipping are exactly the set bits of (start ^ goal)
— count them.
```

```cpp
int minBitFlips(int start, int goal) {
    int xorVal = start ^ goal;
    return countSetBitsFast(xorVal);      // reuse L2's Brian Kernighan counter
}
// TC: O(log(start ^ goal)), SC: O(1)
```

---

## 📌 L4 — Power Set: Print All Subsets Using Bits (L4)

```
Given an array of N elements, print every subset (2^N of them).
KEY IDEA: every subset corresponds to exactly one N-bit number from 0
to 2^N - 1 — bit i of that number says "include arr[i]?" (1) or "skip
it?" (0). Looping the mask from 0 to 2^N-1 and checking each bit
mechanically enumerates every subset without recursion.
```

```cpp
vector<vector<int>> subsets(vector<int>& nums) {
    int n = nums.size();
    int totalSubsets = 1 << n;                     // 2^n
    vector<vector<int>> ans;
    for (int mask = 0; mask < totalSubsets; mask++) {
        vector<int> subset;
        for (int i = 0; i < n; i++) {
            if (mask & (1 << i))                    // is bit i set in this mask?
                subset.push_back(nums[i]);
        }
        ans.push_back(subset);
    }
    return ans;
}
// TC: O(N * 2^N) — 2^N masks, O(N) work checking bits for each
// SC: O(N * 2^N) for the output (exact total size depends on subset sizes,
//     roughly bounded by N * 2^N)
```
**KEY:** this is the bitwise alternative to the recursive "pick / not-pick" subset generation — same set of subsets, but iterative and driven entirely by counting in binary instead of a call stack.

---

## 📌 L5 — Single Number I (L5)

```
Every number in the array appears exactly twice except one, which
appears once. Find it.
KEY IDEA: XOR everything. Every pair cancels to 0 (x^x=0); the survivor
gets XORed with a running 0 and comes out unchanged (x^0=x). Order
doesn't matter — XOR is commutative and associative.
```

```cpp
int singleNumber(vector<int>& nums) {
    int xorAll = 0;
    for (int x : nums) xorAll ^= x;
    return xorAll;
}
// TC: O(N), SC: O(1)
```
**MEMORY AID:** brute force is a hashmap counting frequencies (O(N) time, O(N) space) — XOR gets the same answer in O(1) space. Every "find the odd one out among pairs" problem in this playlist builds on this exact identity.

---

## 📌 L6 — Single Number II (L6)

```
Every number appears exactly THREE times except one, which appears
once. Find it. Plain XOR no longer works (three copies XOR to the
number itself, not 0) — needs a mod-3 argument instead.
```

**Approach 1 — count each of the 32 bit positions across all numbers:**
```cpp
int singleNumberBitCount(vector<int>& nums) {
    int ans = 0;
    for (int bitIndex = 0; bitIndex < 32; bitIndex++) {
        int count = 0;
        for (int x : nums)
            if (x & (1 << bitIndex)) count++;
        if (count % 3 == 1)                 // the lone survivor contributed this bit
            ans = ans | (1 << bitIndex);
    }
    return ans;
}
// TC: O(32*N), SC: O(1)
```
**KEY:** for any bit position, if every number appeared exactly 3 times, the count of set bits at that position would always be a multiple of 3. The ONE extra count beyond a multiple of 3 can only have come from the single survivor — so `count % 3 == 1` exactly identifies the survivor's bits.

**Approach 2 — optimal, "ones/twos" bucket state machine:**
```cpp
int singleNumberOptimal(vector<int>& nums) {
    int ones = 0, twos = 0;
    for (int x : nums) {
        ones = (ones ^ x) & ~twos;   // add x to "ones" only if it's not already in "twos"
        twos = (twos ^ x) & ~ones;   // add x to "twos" only if it's not (now) in "ones"
    }
    return ones;    // whatever survives in "ones" at the end appeared exactly once
}
// TC: O(N), SC: O(1)
```
**KEY:** think of `ones` and `twos` as two bit-level buckets tracking "appeared once so far" / "appeared twice so far" **per bit position simultaneously** — a number enters `ones` on its 1st occurrence, moves from `ones` to `twos` on its 2nd, and vanishes entirely on its 3rd (since it's neither added back to `ones`, being in neither bucket triggers no further action). Because this runs independently at every bit position via bitwise ops, it transparently handles the whole 32-bit number at once rather than needing to reason about one specific value.
**GOTCHA:** this exact state-machine trick is genuinely non-obvious to derive live — Striver is explicit that this is a "know it beforehand" pattern, not something to invent under interview pressure. Knowing Approach 1 (the 32-bit counting method) is enough to clear most interviews; Approach 2 is the one to memorize for the follow-up "can you do better?"

---

## 📌 L7 — Single Number III (L7)

```
Every number appears exactly twice except TWO distinct numbers, which
each appear once. Find both (any order).
KEY IDEA: XOR everything first — pairs cancel, leaving xorAll = a ^ b
(the XOR of the two survivors). Since a != b, xorAll has AT LEAST one
set bit — pick any one (conventionally the rightmost) to use as a
splitter: every number's value at that bit position is either 0 or 1,
and a and b are GUARANTEED to land on opposite sides (since that bit is
exactly where they differ). Every PAIRED number lands on the same side
as its twin (identical value → identical bit → same group), so
splitting into two groups and XORing each group separately isolates a
and b independently.
```

```cpp
vector<int> singleNumberIII(vector<int>& nums) {
    long long xorAll = 0;                       // long: see overflow gotcha below
    for (int x : nums) xorAll ^= x;

    long long rightmostSetBit = xorAll ^ (xorAll & (xorAll - 1));   // isolate lowest set bit
    // (equivalently: xorAll & (-xorAll), the standard two's-complement one-liner)

    int bucket1 = 0, bucket2 = 0;
    for (int x : nums) {
        if (x & rightmostSetBit) bucket1 ^= x;
        else bucket2 ^= x;
    }
    return {bucket1, bucket2};
}
// TC: O(N), SC: O(1)
```
**GOTCHA:** if `xorAll` happens to equal `INT_MIN` (-2^31), computing `xorAll - 1` overflows a 32-bit int (there's no valid `+2^31` to represent the magnitude). Use `long`/`long long` for the XOR accumulator and the isolation step to stay safe — a detail worth mentioning out loud in an interview even if the test cases don't happen to trigger it.

---

## 📌 L8 — XOR of Numbers in a Given Range (L8)

```
Find XOR(1, 2, ..., n) in O(1), then extend to XOR(L, L+1, ..., R).

KEY IDEA — PATTERN, not derivation: XOR(1..n) cycles with period 4
based on n % 4:
  n % 4 == 1  →  answer = 1
  n % 4 == 2  →  answer = n + 1
  n % 4 == 3  →  answer = 0
  n % 4 == 0  →  answer = n
(This is a memorизable pattern discovered by tabulating small cases —
not something to re-derive live in an interview.)

Once XOR(1..n) is O(1), XOR(L..R) follows from the same trick used to
isolate a single pair in prefix-sum-style problems:
  XOR(L..R) = XOR(1..R) ^ XOR(1..L-1)
  (everything from 1 to L-1 appears in BOTH terms and cancels via x^x=0,
   leaving exactly L..R)
```

```cpp
int xorFrom1ToN(int n) {
    if (n % 4 == 1) return 1;
    if (n % 4 == 2) return n + 1;
    if (n % 4 == 3) return 0;
    return n;                 // n % 4 == 0
}
int xorInRange(int L, int R) {
    return xorFrom1ToN(R) ^ xorFrom1ToN(L - 1);
}
// TC: O(1), SC: O(1) — down from the brute force's O(R - L + 1)
```

---

## 📌 L9 — Divide Two Integers Without Multiplication or Division (L9)

```
Divide dividend by divisor using only +, -, and bit shifts, returning
the truncated integer quotient.

KEY IDEA: instead of subtracting the divisor one copy at a time (too
slow — O(dividend) in the worst case), subtract the LARGEST possible
power-of-2 multiple of the divisor at each step. Any quotient q can be
written as a sum of powers of 2 (its own binary representation), so
repeatedly finding "how many doublings of the divisor still fit" and
subtracting that chunk converges in O(log^2) instead of O(N).
```

```cpp
int divide(int dividend, int divisor) {
    if (dividend == divisor) return 1;

    bool negative = ((dividend > 0) != (divisor > 0));   // XOR-like sign check
    long long n = abs((long long)dividend);
    long long d = abs((long long)divisor);

    long long quotient = 0;
    while (n >= d) {
        int count = 0;
        while (n >= (d << (count + 1))) count++;   // find largest doubling that still fits
        quotient += (1LL << count);                 // add that power of 2 to the answer
        n -= (d << count);                          // remove that chunk from the remainder
    }

    if (!negative) {
        if (quotient > INT_MAX) return INT_MAX;
        return (int)quotient;
    } else {
        if (-quotient < INT_MIN) return INT_MIN;
        return (int)(-quotient);
    }
}
// TC: O(log^2(dividend)) — outer loop halves the remaining range each pass
//     (logarithmic), inner loop searches the doubling count (also logarithmic)
// SC: O(1)
```
**GOTCHA — two distinct overflow traps:**
1. `abs(INT_MIN)` doesn't fit in an `int` (magnitude `2^31` exceeds `INT_MAX`) — cast to `long`/`long long` BEFORE taking the absolute value.
2. The specific case `dividend = INT_MIN, divisor = -1` produces a true quotient of `2^31`, which overflows `int` — must be clamped to `INT_MAX` explicitly (the problem statement requires this rather than wrapping/crashing).


---

## 📌 All Patterns — Quick Revision

```
BIT MANIPULATION CHEAT SHEET:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CORE IDENTITIES (everything in this playlist reduces to these):
  x ^ x = 0,  x ^ 0 = x            → XOR cancels pairs, survivor remains
  n & (n-1)                        → removes the rightmost set bit
  n & (-n)   or   n ^ (n & (n-1))  → isolates the rightmost set bit
  n & (1<<i) / n | (1<<i) /
  n & ~(1<<i) / n ^ (1<<i)         → check / set / clear / toggle bit i
  n << k  ==  n * 2^k              → left shift = multiply (watch overflow)
  n >> k  ==  n / 2^k              → right shift = divide (floor)

PROBLEM → PATTERN:
  Swap without a temp variable        → 3-line XOR swap
  Check/set/clear/toggle a bit         → the 4 one-liners in the setup section
  Remove the last set bit              → n & (n-1)
  Check power of 2                     → n & (n-1) == 0 (only 1 set bit to remove)
  Count set bits, don't care about speed → loop + (n&1), n >>= 1, O(log N)
  Count set bits, fewer bits are set     → Brian Kernighan's n = n & (n-1), O(set bits)
  Min flips to convert A to B            → popcount(A ^ B)
  Print all subsets                       → iterate mask 0..2^N-1, bit i of
                                             mask = "include arr[i]?"
  ONE number appears once, rest TWICE      → XOR everything
  ONE number once, rest exactly THRICE     → mod-3 bit counting (32 passes),
                                             or the ones/twos state-machine trick
  TWO distinct numbers once, rest twice     → XOR all → isolate any set bit in
                                             that XOR → split into 2 groups on
                                             that bit → XOR each group separately
  XOR of a full range 1..N                   → memorized mod-4 pattern, O(1)
  XOR of an arbitrary range L..R              → xor(1..R) ^ xor(1..L-1), prefix-XOR style
  Divide without * or /                        → subtract the largest possible
                                             power-of-2 multiple of the divisor
                                             at each step (binary long division)
  Any "found the answer, need it as an actual  → build it bit by bit: loop bit
    number rather than just a count/bool"        positions, OR in (1<<i) when
                                                   that bit belongs in the answer

WHEN TO REACH FOR EACH SHIFT DIRECTION:
  Testing/building around a SPECIFIC bit index i   → 1 << i  (put a lone 1 there)
  Reading a specific bit down to position 0          → n >> i, then & 1
  Isolating the lowest set bit of n                    → n & (-n)  or  n ^ (n&(n-1))

C++ SPECIFIC TIPS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
__builtin_popcount(n) / __builtin_popcountll(n) — built-in fast set-bit count
Use long long when a XOR/subtraction result could hit INT_MIN's -2^31 edge
  (negating or subtracting 1 from INT_MIN overflows a 32-bit int)
abs(INT_MIN) itself overflows int — cast to long/long long BEFORE calling abs()
1 << i needs i < 31 for a positive int result — 1LL << i for wider ranges
Prefer n & 1 over n % 2, and n >> 1 over n / 2 — equivalent, bitwise is faster
A "state machine per bit position" (ones/twos in L6) generalizes to any
  "appears exactly K times except one" variant by extending the bucket count

COMPLEXITY QUICK REF:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Decimal <-> binary conversion       O(log N) time, O(log N) space
Check/set/clear/toggle a bit        O(1) time, O(1) space
Count set bits (simple)             O(log N) time, O(1) space
Count set bits (Brian Kernighan's)  O(set bits) time, O(1) space
Power Set                           O(N * 2^N) time, O(N * 2^N) space
Single Number I                     O(N) time, O(1) space
Single Number II                    O(32*N) or O(N) time, O(1) space
Single Number III                   O(N) time, O(1) space
XOR of range [1,N]                  O(1) time, O(1) space
XOR of range [L,R]                  O(1) time, O(1) space
Divide two integers                 O(log^2 N) time, O(1) space
```

---

## 📌 LeetCode / GFG Problem Map

```
TOPIC                                       | LC / SOURCE  | DIFFICULTY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Introduction — Binary/Decimal, Operators    | GFG           | —
Swap Two Numbers Without a Third Variable   | GFG           | Easy
Check/Set/Clear/Toggle the i-th Bit         | GFG           | Easy
Remove the Last Set Bit                     | GFG           | Easy
Check if a Number is a Power of 2           | LC 231         | Easy
Count Set Bits                              | GFG            | Easy
Minimum Bit Flips to Convert Number         | LC 2220        | Easy
Power Set (Print All Subsets)               | LC 78          | Medium
Single Number                               | LC 136         | Easy
Single Number II                            | LC 137         | Medium
Single Number III                           | LC 260         | Medium
XOR of Numbers in a Given Range             | GFG            | Easy
Divide Two Integers                         | LC 29          | Medium
```
